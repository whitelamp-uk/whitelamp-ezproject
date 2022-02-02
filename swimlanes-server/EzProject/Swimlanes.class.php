<?php

/* Copyright 2020 Whitelamp http://www.whitelamp.co.uk */

namespace EzProject;

class Swimlanes {

    public $hpapi;
    public $userId;

    public function __construct (\Hpapi\Hpapi $hpapi) {
        $this->hpapi            = $hpapi;
        $this->timezone         = $this->hpapi->tzName;
        $this->userId           = $this->hpapi->userId;
    }

    public function __destruct ( ) {
    }

    public function authenticate ( ) {
        try {
            $result = $this->hpapi->dbCall (
                'ezpSwimlanesSwimpools'
            );
            $pools = $this->hpapi->parse2D ($result);
            $result = $this->hpapi->dbCall (
                'ezpSwimlanesUsers'
               ,$this->userId
            );
        }
        catch (\Exception $e) {
            $this->hpapi->diagnostic ($e->getMessage());
            throw new \Exception (EZP_SWIMLANES_STR_DB);
            return false;
        }
        if (!count($result)) {
            throw new \Exception (EZP_SWIMLANES_STR_USER);
            return false;
        }
        $user = $this->hpapi->parse2D ($result)[0];
        $user->swimpools = [];
        if ($user->groups) {
            $groups = explode (':',$user->groups);
            $user->groups = [];
            foreach ($groups as $g) {
                foreach ($pools as $p) {
                    if ($p->usergroup==$g) {
                        $user->swimpools[] = $p;
                    }
                }
            }
        }
        else {
            $user->groups = [];
        }
        $user->templates = $this->templates ();
        return $user;
    }

    public function config ( ) {
        $out                        = new \stdClass ();
        try {
            $out->timezoneExpected  = $this->timezone;
            $out->agentfunctions    = $this->hpapi->parse2D (
                $this->hpapi->dbCall ('ezpThingy')
            );
        }
        catch (\Exception $e) {
            $this->hpapi->diagnostic ($e->getMessage());
            throw new \Exception (EZP_SWIMLANES_STR_DB);
            return false;
        }
        // Done
        return $out;
    }

    public function statuses ( ) {
        try {
            $result = $this->hpapi->dbCall (
                'ezpSwimlanesStatuses'
            );
            return $this->hpapi->parse2D ($result);
        }
        catch (\Exception $e) {
            $this->hpapi->diagnostic ($e->getMessage());
            throw new \Exception (EZP_SWIMLANES_STR_DB);
            return false;
        }
    }

    public function passwordReset ($answer,$code,$newPassword) {
        if (!$this->hpapi->object->response->pwdSelfManage) {
            $this->hpapi->diagnostic (HPAPI_DG_RESET);
            throw new \Exception (HPAPI_STR_AUTH_DENIED);
            return false;
        }
        try {
            if (!$this->passwordTest($newPassword,$this->hpapi->object->response->pwdScoreMinimum,$msg)) {
                $this->hpapi->addSplash ($msg);
                throw new \Exception (EZP_SWIMLANES_STR_PASSWORD);
                return false;
            }
        }
        catch (\Exception $e) {
            throw new \Exception ($e->getMessage());
            return false;
        }

        try {
            $user                           = $this->hpapi->dbCall (
                'ezpSwimlanesUserDetails'
               ,$this->userId
            );
            $answerHash                     = $user[0]['secretAnswerHash'];
            $verifyCode                     = $user[0]['verifyCode'];
            $verifyCodeExpiry               = $user[0]['verifyCodeExpiry'];
        }
        catch (\Exception $e) {
            $this->hpapi->diagnostic ($e->getMessage());
            throw new \Exception (EZP_SWIMLANES_STR_DB);
            return false;
        }
        if (!password_verify($this->answerCondense($answer),$answerHash)) {
            throw new \Exception (EZP_SWIMLANES_STR_PWD_RESET_ANSWER);
            return false;
        }
        if ($code!=$verifyCode) {
            throw new \Exception (EZP_SWIMLANES_STR_PWD_RESET_CODE);
            return false;
        }
        if ($this->hpapi->timestamp>$verifyCodeExpiry) {
            throw new \Exception (EZP_SWIMLANES_STR_PWD_RESET_EXPIRY);
            return false;
        }
        $expires                            = null;
        if (HPAPI_PASSWORD_DAYS) {
            $expires                        = $this->hpapi->timetamp;
            $expires                       += HPAPI_PASSWORD_DAYS * 86400;
        }
        try {
            $this->hpapi->dbCall (
                'ezpSwimlanesSetPasswordHash'
               ,$this->userId
               ,$this->hpapi->passwordHash ($newPassword)
               ,$expires
               ,1
            );
            return true;
        }
        catch (\Exception $e) {
            $this->hpapi->diagnostic ($e->getMessage());
            throw new \Exception (EZP_SWIMLANES_STR_DB);
            return false;
        }
    }

    public function passwordTest ($pwd,$minscore,&$msg='OK') {

        // Loosely based on https://www.the-art-of-web.com/php/password-strength/
        // /etc/security/pwquality.conf can be used to configure pwscore.
        // Turns out pwscore uses cracklib by default anyway so perhaps we should simplify this.

        $CRACKLIB           = "/usr/sbin/cracklib-check";
        if (!file_exists($CRACKLIB)) {
            $this->hpapi->diagnostic ('passwordTest(): cracklib-check not found');
            throw new \Exception (EZP_SWIMLANES_STR_PASSWORD_TEST.' [1]');
            return false;
        }
        $PWSCORE            = "/usr/bin/pwscore";
        if (!file_exists($PWSCORE)) {
            $this->hpapi->diagnostic ('passwordTest(): pwscore not found');
            throw new \Exception (EZP_SWIMLANES_STR_PASSWORD_TEST.' [2]');
            return false;
        }
        $this->hpapi->diagnostic ('pwscore config: /etc/security/pwquality.conf');

        // Prevent UTF-8 characters being stripped by escapeshellarg
        setlocale (LC_ALL,'en_GB.utf-8'); //TODO check side-effects of this!

        $out                = [];
        $ret                = null;
        $command            = "echo '".escapeshellarg($pwd)."' | {$CRACKLIB}";
        exec ($command,$out,$ret);
        if ($ret>0) {
            throw new \Exception (EZP_SWIMLANES_STR_PASSWORD_TEST.' [3]');
            return false;
        }
        // Check response after the colon
        preg_match ('<:\s+([^:]+)$>', $out[0], $match);
        if (!is_array($match) || !array_key_exists(1,$match)) {
            throw new \Exception (EZP_SWIMLANES_STR_PASSWORD_TEST.' [4]');
            return false;
        }
        if ($match[1]!='OK') {
            $this->hpapi->diagnostic ('cracklib result="'.$match[1].'"');
            if (stripos($match[1],'dictionary word')!==false) {
                $msg        = EZP_SWIMLANES_STR_PASSWORD_DICTIONARY;
                return false;
            }
            if (stripos($match[1],'DIFFERENT characters')!==false) {
                $msg        = EZP_SWIMLANES_STR_PASSWORD_CHARACTERS;
                return false;
            }
            $msg            = EZP_SWIMLANES_STR_PASSWORD_OTHER;
            return false;
        } 
        // cracklib is happy (or perhaps preg_match() failed?)
        $out                = [];
        $ret                = null;
        $command            = "echo '".escapeshellarg($pwd)."' | {$PWSCORE} 2>&1"; // NB to get stderr
        exec ($command,$out,$ret);
        if (is_numeric($out[0])) {
            $this->hpapi->diagnostic ('pwscore: '.$out[0]);
            if (1*$out[0]<$minscore) {
                $msg        = EZP_SWIMLANES_STR_PASSWORD_SCORE.' score='.$out[0].' but '.$minscore.' required';
                return false;
            }
        }
        else {
            $msg            = trim ($out[1]);
            return false;
        }
        return true;
    }

    public function phoneParse ($number) {
        $number                 = preg_replace ('/[^0-9]+/','',$number);
        if (strpos($number,'0')===0 && strpos($number,'00')!==0) {
            $number             = EZP_SWIMLANES_PHONE_DEFAULT_COUNTRY_CODE.substr($number,1);
        }
        return $number;
    }

    public function report ($args) {
        try {
            $result                         = $this->hpapi->dbCall (
                ...$args
            );
            return $this->hpapi->parse2D ($result);
        }
        catch (\Exception $e) {
            throw new \Exception ($e->getMessage());
            return false;
        }
    }

    public function reports ( ) {
        try {
            $result                         = $this->hpapi->dbCall (
                'hpapiSprargs'
               ,'whitelamp-ezproject'
               ,'swimlanes-server'
               ,'\Ezp\Swimlanes'
               ,'report'
            );
            $rows                           = array ();
            foreach ($result as $row) {
                $spr                        = $row['spr'];
                if (!array_key_exists($spr,$rows)) {
                    $rows[$spr]             = new \stdClass ();
                    $rows[$spr]->arguments  = array ();
                    $rows[$spr]->spr        = $row['spr'];
                    $rows[$spr]->reportName = $row['notes'];
                }
                if (!$row['argument']) {
                    continue;
                }
                unset ($row['spr']);
                unset ($row['notes']);
                $arg                        = new \stdClass ();
                $arg->pattern               = $row['expression'];
                $arg->isCompulsory          = 1 - $row['emptyAllowed'];
                unset ($row['pattern']);
                unset ($row['expression']);
                unset ($row['emptyAllowed']);
                foreach ($row as $property=>$value) {
                    $arg->{$property}       = $value;
                }
                if (defined($arg->constraints)) {
                    $arg->constraints       = constant ($arg->constraints);
                }
                array_push ($rows[$spr]->arguments,$arg);
            }
            $reports                        = array ();
            foreach ($rows as $row) {
                array_push ($reports,$row);
            }
            return $reports;
        }
        catch (\Exception $e) {
            $this->hpapi->diagnostic ($e->getMessage());
            throw new \Exception (EZP_SWIMLANES_STR_DB);
            return false;
        }
    }

    public function secretQuestion ($phoneEnd) {
        if (!$this->hpapi->groupAvailable($groups)) {
            $this->hpapi->diagnostic (HPAPI_DG_ACCESS_GRP);
            throw new \Exception (HPAPI_STR_AUTH_DENIED);
            return false;
        }
        if (!$this->hpapi->object->response->pwdSelfManage) {
            $this->hpapi->diagnostic (HPAPI_DG_RESET);
            throw new \Exception (HPAPI_STR_AUTH_DENIED);
            return false;
        }
        try {
            $user                           = $this->hpapi->dbCall (
                'ezpSwimlanesUserQuestion'
               ,$this->userId
               ,$phoneEnd
            );
        }
        catch (\Exception $e) {
            $this->hpapi->diagnostic ($e->getMessage());
            throw new \Exception (EZP_SWIMLANES_STR_DB);
            return false;
        }
        if (!count($user)) {
            throw new \Exception (EZP_SWIMLANES_STR_DB);
            return false;
        }
        return $user[0]['secretQuestion'];
    }

    public function sms ($number,$message) {
        try {
            $voodoosms                      = $this->hpapi->jsonDecode (file_get_contents(EZP_SWIMLANES_VOODOOSMS_JSON),false,3);
            $voodoosms->parameters->dest    = $this->phoneParse ($number);
            $voodoosms->parameters->msg     = $message;
            $url                            = $voodoosms->url;
            $url                           .= $this->objectToQueryString ($voodoosms->parameters);
            $ch                             = \curl_init ();
            \curl_setopt ($ch,CURLOPT_URL,$url);
            \curl_setopt ($ch,CURLOPT_SSL_VERIFYPEER,false);
            \curl_setopt ($ch,CURLOPT_SSL_VERIFYHOST,2);
            \curl_setopt ($ch,CURLOPT_RETURNTRANSFER,TRUE);
            $json                           = \curl_exec ($ch)."\n";
            if ($e=\curl_error($ch)) {
                $this->hpapi->diagnostic ("Curl error: ".$e);
            }
            else {
                $response                   = $this->hpapi->jsonDecode ($json,false,3);
            }
            \curl_close($ch);
            if ($e) {
                throw new \Exception (EZP_SWIMLANES_STR_SMS);
                return false;
            }
            if ($response->result!=200) {
                throw new \Exception (EZP_SWIMLANES_STR_SMS);
                return false;
            }
            return true;
        }
        catch (\Exception $e) {
            $this->hpapi->diagnostic ($e->getMessage());
            throw new \Exception (EZP_SWIMLANES_STR_SMS);
            return false;
        }
    }

    public function swimmers ( ) {
        try {
            $result = $this->hpapi->dbCall (
                'ezpSwimlanesSwimpools'
            );
            $pools = $this->hpapi->parse2D ($result);
            $result = $this->hpapi->dbCall (
                'ezpSwimlanesUsers'
               ,null
            );
            $users = $this->hpapi->parse2D ($result);
            $swimmers_by_id = [];
            foreach ($users as $i=>$u) {
                if ($u->groups) {
                    $u->groups = explode (':',$u->groups);
                }
                else {
                    $u->groups = [];
                }
                foreach ($u->groups as $g) {
                    foreach ($pools as $p) {
                        if ($p->usergroup==$g) {
                            if (!array_key_exists($u->userId,$swimmers_by_id)) {
                                $swimmers_by_id[$u->userId] = $u;
                                $swimmers_by_id[$u->userId]->swimpools = [];
                            }
                            $swimmers_by_id[$u->userId]->swimpools[] = $p;
                        }
                    }
                }
            }
            $swimmers = [];
            foreach ($swimmers_by_id as $s) {
                $swimmers[] = $s;
            }
        }
        catch (\Exception $e) {
            $this->hpapi->diagnostic ($e->getMessage());
            throw new \Exception (EZP_SWIMLANES_STR_DB);
            return false;
        }
        return $swimmers;
    }

    public function swimlanes ($swimpoolCode) {
        try {
            $result = $this->hpapi->dbCall (
                'ezpSwimlanesSwimlanes',
                $this->hpapi->email,
                $swimpoolCode
            );
            return $this->hpapi->parse2D ($result);
        }
        catch (\Exception $e) {
            $this->hpapi->diagnostic ($e->getMessage());
            throw new \Exception (EZP_SWIMLANES_STR_DB);
            return false;
        }
    }

    public function swims ($swimpoolCode,$swimlaneCode,$statusCode) {
        try {
            if (count($this->swimlanes($swimpoolCode))) {
                $result = $this->hpapi->dbCall (
                    'ezpSwimlanesSwims',
                    $swimpoolCode,
                    $swimlaneCode,
                    $statusCode
                );
                return $this->hpapi->parse2D ($result);
            }
            else {
                throw new \Exception (EZP_SWIMLANES_STR_403);
                return false;
            }
        }
        catch (\Exception $e) {
            $this->hpapi->diagnostic ($e->getMessage());
            throw new \Exception (EZP_SWIMLANES_STR_DB);
            return false;
        }
    }

    public function templates ( ) {
        $g                      = array ();
        $t                      = array ();
        foreach (glob(EZP_SWIMLANES_GLOB_TEMPLATE_GLOBAL) as $f) {
            array_push ($g,basename($f));
        }
        foreach (glob(EZP_SWIMLANES_GLOB_TEMPLATE_APP) as $f) {
            $f                  = basename ($f);
            if (!in_array($f,$g)) {
                array_push ($t,explode('.',$f)[0]);
            }
        }
        return $t;
    }

}


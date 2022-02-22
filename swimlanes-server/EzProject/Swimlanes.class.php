<?php

/* Copyright 2022 Whitelamp http://www.whitelamp.co.uk */

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
        // The framework does the actual authentication every request
        // This method is for client app authentication of a browser session
        // The standard base class hpapi.js expects to receive user details
        // having the property templates (for Handlebars)
        $result = $this->hpapi->dbCall (
            'ezpSwimlanesUsers',
            $this->hpapi->email
        );
        $user = $this->hpapi->parse2D ($result) [0];
        $user->templates = $this->templates ();
        $user->adminerUrl = EZP_ADMINER_URL;
        return $user;
    }

    public function config ( ) {
        $out = new \stdClass ();
        try {
            $out->timezoneExpected = $this->timezone;
        }
        catch (\Exception $e) {
            $this->hpapi->diagnostic ($e->getMessage());
            throw new \Exception (EZP_SWIMLANES_STR_DB);
            return false;
        }
        try {
            $result = $this->hpapi->dbCall (
                'ezpSwimlanesUsers',
                null
            );
            $users = $this->hpapi->parse2D ($result);
            $result = $this->hpapi->dbCall (
                'ezpSwimlanesSwimpools'
            );
            $pools = $this->hpapi->parse2D ($result);
            $result = $this->hpapi->dbCall (
                'ezpSwimlanesStatuses'
            );
            $out->statuses = $this->hpapi->parse2D ($result);
        }
        catch (\Exception $e) {
            $this->hpapi->diagnostic ($e->getMessage());
            throw new \Exception (EZP_SWIMLANES_STR_DB);
            return false;
        }
        $out->swimpools = [];
        foreach ($pools as $i=>$pool) {
            $pool->allowed = false;
            if ($pool->swimmers) {
                $pool->swimmers = explode (';;',$pool->swimmers);
                foreach ($pool->swimmers as $j=>$swimmer) {
                    $swimmer = explode ('::',$swimmer);
                    $pool->swimmers[$j] = new \stdClass ();
                    $pool->swimmers[$j]->code = $swimmer[0];
                    $pool->swimmers[$j]->email = $swimmer[1];
                    foreach ($users as $user) {
                        if ($user->email==$pool->swimmers[$j]->email) {
                            $swimmers[$j]->name = $user->name;
                            if ($user->email==$this->hpapi->email) {
                                $pool->allowed = true;
                            }
                        }
                    }
                }
            }
            if ($pool->allowed) {
                $out->swimpools[] = $pool;
            }
        }
        return $out;
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
            $user = $this->hpapi->dbCall (
                'ezpSwimlanesUserDetails',
                $this->userId
            );
            $answerHash         = $user[0]['secretAnswerHash'];
            $verifyCode         = $user[0]['verifyCode'];
            $verifyCodeExpiry   = $user[0]['verifyCodeExpiry'];
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
        $expires                = null;
        if (HPAPI_PASSWORD_DAYS) {
            $expires            = $this->hpapi->timetamp;
            $expires           += HPAPI_PASSWORD_DAYS * 86400;
        }
        try {
            $this->hpapi->dbCall (
                'ezpSwimlanesSetPasswordHash',
                $this->userId,
                $this->hpapi->passwordHash ($newPassword),
                $expires,
                1
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

        $CRACKLIB = "/usr/sbin/cracklib-check";
        if (!file_exists($CRACKLIB)) {
            $this->hpapi->diagnostic ('passwordTest(): cracklib-check not found');
            throw new \Exception (EZP_SWIMLANES_STR_PASSWORD_TEST.' [1]');
            return false;
        }
        $PWSCORE = "/usr/bin/pwscore";
        if (!file_exists($PWSCORE)) {
            $this->hpapi->diagnostic ('passwordTest(): pwscore not found');
            throw new \Exception (EZP_SWIMLANES_STR_PASSWORD_TEST.' [2]');
            return false;
        }
        $this->hpapi->diagnostic ('pwscore config: /etc/security/pwquality.conf');

        // Prevent UTF-8 characters being stripped by escapeshellarg
        setlocale (LC_ALL,'en_GB.utf-8'); //TODO check side-effects of this!

        $out = [];
        $ret = null;
        $command = "echo '".escapeshellarg($pwd)."' | {$CRACKLIB}";
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
                $msg = EZP_SWIMLANES_STR_PASSWORD_DICTIONARY;
                return false;
            }
            if (stripos($match[1],'DIFFERENT characters')!==false) {
                $msg = EZP_SWIMLANES_STR_PASSWORD_CHARACTERS;
                return false;
            }
            $msg = EZP_SWIMLANES_STR_PASSWORD_OTHER;
            return false;
        } 
        // cracklib is happy (or perhaps preg_match() failed?)
        $out = [];
        $ret = null;
        $command = "echo '".escapeshellarg($pwd)."' | {$PWSCORE} 2>&1"; // NB to get stderr
        exec ($command,$out,$ret);
        if (is_numeric($out[0])) {
            $this->hpapi->diagnostic ('pwscore: '.$out[0]);
            if (1*$out[0]<$minscore) {
                $msg = EZP_SWIMLANES_STR_PASSWORD_SCORE.' score='.$out[0].' but '.$minscore.' required';
                return false;
            }
        }
        else {
            $msg = trim ($out[1]);
            return false;
        }
        return true;
    }

    public function phoneParse ($number) {
        $number = preg_replace ('/[^0-9]+/','',$number);
        if (strpos($number,'0')===0 && strpos($number,'00')!==0) {
            $number = EZP_SWIMLANES_PHONE_DEFAULT_COUNTRY_CODE.substr($number,1);
        }
        return $number;
    }

    public function report ($args) {
        try {
            $result = $this->hpapi->dbCall (
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
            $result = $this->hpapi->dbCall (
                'hpapiSprargs',
                'whitelamp-ezproject',
                'swimlanes-server',
                '\Ezp\Swimlanes',
                'report'
            );
            $rows = [];
            foreach ($result as $row) {
                $spr = $row['spr'];
                if (!array_key_exists($spr,$rows)) {
                    $rows[$spr] = new \stdClass ();
                    $rows[$spr]->arguments  = [];
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
                $rows[$spr]->arguments[]    = $arg;
            }
            $reports = [];
            foreach ($rows as $row) {
                $reports[] = $row;
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
            $user = $this->hpapi->dbCall (
                'ezpSwimlanesUserQuestion',
                $this->userId,
                $phoneEnd
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

    public function swimlanes ($swimpoolCode) {
        try {
            $result = $this->hpapi->dbCall (
                'ezpSwimlanesSwimlanes',
                $this->hpapi->email,
                $swimpoolCode
            );
            if (!count($result)) {
                throw new \Exception (EZP_SWIMLANES_STR_POOL);
                return false;
            }
            if (count($result)==1 && !$result[0]['id']) {
                return [];
            }
        }
        catch (\Exception $e) {
            $this->hpapi->diagnostic ($e->getMessage());
            throw new \Exception (EZP_SWIMLANES_STR_DB);
            return false;
        }
        $lanes = $this->hpapi->parse2D ($result);
        foreach ($lanes as $i=>$lane) {
            if ($lanes[$i]->swims) {
                $swims = explode (';;',$lanes[$i]->swims);
                $lanes[$i]->swims = new \stdClass ();
                foreach ($swims as $qty) {
                    $qty = explode ('::',$qty);
                    $lanes[$i]->swims->{$qty[0]} = 1 * $qty[1];
                }
            }
            else {
                $lanes[$i]->swims = new \stdClass ();
            }
        }
        return $lanes;
    }

    public function swims ($swimpoolCode,$swimlaneCode,$statusCode) {
        $output = new \stdClass ();
        $dt = new \Datetime ();
        $output->datetime = $dt->format ('Y-m-d H:i:s');
        try {
            if (count($this->swimlanes($swimpoolCode))) {
                $result = $this->hpapi->dbCall (
                    'ezpSwimlanesSwims',
                    $swimpoolCode,
                    $swimlaneCode,
                    $statusCode
                );
                $output->swims = $this->hpapi->parse2D ($result);
                return $output;
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
        $g = [];
        $t = [];
        foreach (glob(EZP_SWIMLANES_GLOB_TEMPLATE_GLOBAL) as $f) {
            $g[] = basename ($f);
        }
        foreach (glob(EZP_SWIMLANES_GLOB_TEMPLATE_APP) as $f) {
            $f = basename ($f);
            if (!in_array($f,$g)) {
                $t[] = explode ('.',$f) [0];
            }
        }
        return $t;
    }

    public function updates ($swimpoolCode,$datetime_after) {
        $output = new \stdClass ();
        $dt = new \Datetime ();
        $output->datetime = $dt->format ('Y-m-d H:i:s');
        try {
            if (count($this->swimlanes($swimpoolCode))) {
                $result = $this->hpapi->dbCall (
                    'ezpSwimlanesUpdates',
                    $swimpoolCode,
                    $datetime_after,
                    EZP_SWIMLANES_UPDATES_LIMIT + 1
                );
                $output->swims = $this->hpapi->parse2D ($result);
                if (count($swims)>EZP_SWIMLANES_UPDATES_LIMIT) {
                    array_pop ($output->swims);
                    $output->warning = EZP_SWIMLANES_STR_LIMIT.EZP_SWIMLANES_UPDATES_LIMIT;
                }
                $result = $this->hpapi->dbCall (
                    'ezpSwimlanesDeparts',
                    $swimpoolCode,
                    $datetime_after
                );
                $output->departs = $this->hpapi->parse2D ($result);
                return $output;
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

}


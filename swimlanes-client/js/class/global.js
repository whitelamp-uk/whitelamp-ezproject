
import {Generic} from './generic.js';

export class Global extends Generic {

    async authAuto ( ) {
        var response;
        this.log ('Authenticating automatically');
        this.screenLockRefreshInhibit = 1;
        try {
            response = await super.authenticate (
                this.qs(document.body,'#gui-email').value
               ,null
               ,'swimlanes-server'
               ,'\\EzProject\\Swimlanes'
            );
            this.authCheck (response);
        }
        catch (e) {
            console.log (e.message);
        }
        this.screenLockRefreshInhibit = null;
    }

    async authenticate (evt) {
        var email,pwd,request,response;
        evt.preventDefault ();
        try {
            this.loginTried = 1;
            email = evt.currentTarget.form.email.value;
            if (email.length==0) {
                this.log ('No email given');
                return;
            }
            pwd = evt.currentTarget.form.password.value;
            if (pwd.length==0) {
                this.log ('No password given');
                return;
            }
            request = {
                "email" : email
               ,"password" : pwd
               ,"method" : {
                    "vendor" : "whitelamp-ezproject"
                   ,"package" : "swimlanes-server"
                   ,"class" : "Swimlanes"
                   ,"method" : "authenticate"
                   ,"arguments" : [
                    ]
                }
            }
            if (pwd) {
                request.password = pwd;
            }
            if ('key' in this) {
                request.key = this.key;
            }
            response = await this.request (request);
            if ('currentUser' in this) {
                console.log ('authenticate(): clearing current user details');
                this.currentUser = {};
                this.data.currentUser = {};
            }
            throw new Error (e.message);
            this.authCheck (response);
        }
        catch (e) {
            console.log (e.message);
        }
    }

    async authForget ( ) {
        await this.screenRender ('home');
        super.authForget ();
    }

    async authOk ( ) {
        super.authOk ();
        // Now get business configuration data
        await this.configRequest ();
        // Render a screen by URL (only when page loads)
        if (this.urlScreen) {
            await this.templateFetch (this.urlScreen);
            await this.screenRender (this.urlScreen);
            this.urlScreen = null;
            return;
        }
        // Render a default screen
        if (!this.currentScreen) {
            await this.templateFetch ('home');
            await this.screenRender ('home');
        }
    }

    async configRequest ( ) {
    var request = {
            "email" : this.access.email.value
           ,"method" : {
                "vendor" : "whitelamp-ezproject"
               ,"package" : "swimlanes-server"
               ,"class" : "\\EzProject\\Swimlanes"
               ,"method" : "config"
               ,"arguments" : [
                ]
            }
        }
        try {
        var response                = await this.request (request);
            this.data.config        = response.returnValue;
            return true;
        }
        catch (e) {
            console.log ('configRequest(): could not get config: '+e.message);
            return false;
        }
    }

    constructor (cfg) {
        super (cfg);
        console.log ('App config: ');
        console.table (this.cfg);
    }

    async globalInit ( ) {
        var doctitle, keys, i, nav, unlock, userScope;
        this.log ('API='+this.cfg.url);
        this.reset                  = null;
        this.templates              = {};
        if (this.cfg.diagnostic.data) {
            this.templateFetch ('data');
        }
        this.templateFetch ('lock');
        this.templateFetch ('splash');
        this.templateFetch ('place');
        await this.templateFetch ('login');
        this.currentScreen          = null;
        this.currentTemplates       = {};
        this.currentInserts         = [];
        this.parametersClear ();
        this.dataRefresh ();
        this.globalLoad ();
        this.access.innerHTML       = this.templates.login ({badge:this.cfg.loginByBadge});
        doctitle                    = this.qs (document,'title');
        if (doctitle) {
            nav                     = this.qs (this.access,'nav.navigator');
            if (nav) {
                nav.setAttribute ('title',doctitle.getAttribute('title'));
            }
        }
        unlock                      = this.qs (document.body,'#gui-unlock');
        unlock.addEventListener ('click',this.authenticate.bind(this));
        // Define user scope
        userScope                   = this.userScope ();
        this.authAutoPermit         =  0;
        if (this.cfg.loginByBadge) {
            userScope.addEventListener ('keyup',this.badgeListen.bind(this));
            userScope.addEventListener ('change',this.badgeListen.bind(this));
        }
        if (this.urlUser.length>0) {
            // Passed in URL so allow instant login
            this.authAutoPermit     =  1;
            userScope.value         = this.urlUser;
            if (this.cfg.loginByBadge) {
                this.badgeListen (userScope);
            }
        }
        this.saveScopeSet (userScope.value);
        userScope.addEventListener ('keyup',this.saveScopeListen.bind(this));
        userScope.addEventListener ('change',this.saveScopeListen.bind(this));
        if ((typeof this.authAuto)=='function') {
            // Multiple window mode is defined by existence of this.authAuto()
            this.screenLocker       = window.setInterval (this.screenLockRefresh.bind(this),2000);
            this.windowLogger       = window.setInterval (this.windowLog.bind(this),900);
            this.windowLog ();
        }
        keys                        = Object.keys (this.urlParameters);
        for (i=0;i<keys.length;i++) {
            this.parameterWrite (keys[i],this.urlParameters[keys[i]]);
        }
    }

    async globalLoad ( ) {
        await super.globalLoad ();
        if (!('globalLoaded' in this)) {
            this.queueInit ();
        }
    }

    handlebarsHelpers ( ) {
        super.handlebarsHelpers ();
        Handlebars.registerHelper (
            'hasAnAt',
            function (thing,opts) {
                thing = thing.split ('@');
                if (thing.length>1) {
                    return opts.fn (this);
                }
                return opts.inverse (this);
            }
        );
    }

    async init ( ) {
        console.log ('Admin GUI initialising');
        try {
            await this.globalInit ();
        }
        catch (e) {
            throw new Error (e.message);
            return false;
        }
        this.data.test = {
            name        : "Susan"
           ,colHeads    : [
                "Col1"
               ,"Col2"
            ]
           ,cols        : [
                "c1"
               ,"c2"
            ]
           ,rows       : [
                {
                    c1 : "r1c1"
                   ,c2 : "r1c2"
                }
               ,{
                    c1 : "r2c1"
                   ,c2 : "r2c2"
                }
            ]
        }
        this.log ('admin-gui initialised');
    }

}


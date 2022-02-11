
/* Copyright 2022 Whitelamp http://www.whitelamp.co.uk */

// Symbolic link to library file in hpapi/whitelamp-uk/generic-client
import {Generic} from './generic.js';

export class Global extends Generic {

    actorsTest (evt) {
        console.error ('actorsTest():');
        console.error (evt.currentTarget);
    }

    adminer (action,table,column=null,operator=null,value=null) {
        var db_name,db_suffix,db_user,url,win;
        db_user = this.qs (this.restricted,'#swimlanes-settings input[name="db_user"]');
        db_name = this.qs (this.restricted,'#swimlanes-settings input[name="db_name"]');
        db_suffix = this.qs (this.restricted,'#swimlanes-settings input[name="db_suffix"]');
        if (db_user.value && db_name.value) {
            url  = this.adminerUrl;
            url += '?username=' + db_user.value;
            url += '&db=' + db_name.value + db_suffix.value;
            url += '&' + action + '=' + table;
            if (action=='select' && column) {
                url += '&where[0][col]=' + column;
                url += '&where[0][op]=' + operator;
                url += '&where[0][val]=' + value;
            }
            else if (action=='edit' && column) {
                url += '&where[' + column + ']=' + value;
            }
            console.log ('URL: '+url);
            win = 'swimlanes-adminer-' + action;
            if (action=='edit' && column) {
                win += '-' + column;
            }
            win = window.open (url,win);
            win.focus ();
        }
        else {
            this.statusShow ('DB log-in required - set your SQL user and database name');
        }
    }

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
                   ,"class" : "\\EzProject\\Swimlanes"
                   ,"method" : "authenticate"
                   ,"arguments" : [
                    ]
                }
            }
            if (pwd) {
                request.password = pwd;
            }
            response = await this.request (request);
            if ('currentUser' in this) {
                console.log ('authenticate(): clearing current user details');
                this.currentUser = {};
                this.data.currentUser = {};
            }
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

    async authOk (response) {
        this.currentUser = response.returnValue;
        super.authOk ();
        // Now get business configuration data this.data.config
        await this.configRequest ();
        // Object reference
        this.data.currentUser = this.currentUser;
        // A literal copy
        this.adminerUrl = this.currentUser.adminerUrl;
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
        await this.templateFetch ('login');
        this.currentScreen          = null;
        this.currentTemplates       = {};
        this.currentInserts         = [];
        this.parametersClear ();
        this.dataRefresh ();
        this.globalLoad ();
        this.access.innerHTML       = this.templates.login ({});
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
        if (this.urlUser.length>0) {
            // Passed in URL so allow instant login
            this.authAutoPermit     =  1;
            userScope.value         = this.urlUser;
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
        console.log ('gui.js initialising');
        try {
            await this.globalInit ();
        }
        catch (e) {
            throw new Error ('gui.js: '+e.message);
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
        this.log ('gui.js initialised');
    }

    async report (evt) {
        var args, err, form, file, i, link, report, target, title, type;
        form        = this.qs (this.restricted,'form[data-report]');
        target      = this.qs (this.restricted,'#'+evt.currentTarget.dataset.target);
        title       = evt.currentTarget.dataset.title;
        file        = title.replace(/[^a-zA-Z ]/g,'').replace(/ /g,'-');
        args        = [];
        type        = 'xml';
        if (evt.currentTarget.dataset.download=='csv') {
            type    = 'csv';
        }
        for (i=0;form.elements[i];i++) {
            args.push (form.elements[i].value);
        }
        try {
            report  = await this.reportRequest (args);
        }
        catch (e) {
            err     = this.errorSplit (e.message);
            if (err.hpapiCode=='400') {
                this.splash (2,'Invalid input(s)','Error','OK');
            }
            else {
                this.splash (2,e.message,'Error','OK');
            }
            return false;
        }
        if (type=='csv') {
            link = this.downloadLink (
                'Here is your download'
               ,file+'.csv'
               ,'text/csv'
               ,this.objectToCsv (report)
            );
            target.appendChild (link);
            return true;
        }
        link = this.downloadLink (
            'Here is your download'
           ,file+'.xml'
           ,'text/xml'
           ,this.objectToMsExcel2003Xml (report,title)
        );
        target.appendChild (link);
        return true;
    }

    settingsInit ( ) {
        var menu,open,settings,updates;
        settings = this.qs (this.restricted,'#swimlanes-settings');
        menu = this.qs (settings,'menu');
        // Insert a swim
        open = document.createElement ('span');
        open.classList.add ('button');
        open.textContent = 'New swim';
        open.addEventListener ('click',this.swimNew.bind(this));
        menu.appendChild (open);
        // List swims
        open = document.createElement ('span');
        open.classList.add ('button');
        open.textContent = 'Swims';
        open.addEventListener ('click',this.swimSearch.bind(this));
        menu.appendChild (open);
        // List logs
        open = document.createElement ('span');
        open.classList.add ('button');
        open.textContent = 'Updates';
        open.addEventListener ('click',this.logsList.bind(this));
        menu.appendChild (open);
        updates = this.qs (settings,'.updates');
        // List swimlanes
        open = document.createElement ('span');
        open.textContent = 'Pool/lane codes';
        open.addEventListener ('click',this.swimlanesList.bind(this));
        menu.appendChild (open);
        // List statuses
        open = document.createElement ('span');
        open.classList.add ('button');
        open.textContent = 'Statuses';
        open.addEventListener ('click',this.statusesList.bind(this));
        menu.appendChild (open);
        // Settings
        this.settingsLoad ();
        this.qs(settings,'form').addEventListener ('input',this.settingsUpdate.bind(this));
    }

    settingsLoad ( ) {
        var form,pool,s;
        s = this.storageRead ('settings',s);
        if (s && Object.keys(s).length) {
            form = this.qs (this.restricted,'#swimlanes-settings form');
            pool = this.qs (this.restricted,'#input-pool');
            form.db_user.value = s.user;
            form.db_name.value = s.db;
            form.db_suffix.value = '';
            if (s.db_per_pool) {
                form.db_use_suffix.checked = true;
                if (pool.value) {
                    form.db_suffix.value = '_' + pool.value;
                }
                else {
                    form.db_suffix.value = '_[pool code]';
                }
            }
            form.db_store.checked = true;
        }
    }

    settingsToggle (evt) {
        var settings;
        settings = this.qs (this.restricted,'#swimlanes-settings');
        if (settings) {
            if (settings.classList.contains('selected')) {
                settings.classList.remove ('selected');
                evt.currentTarget.classList.remove ('selected');
            }
            else {
                settings.classList.add ('selected');
                evt.currentTarget.classList.add ('selected');
            }
        }
    }

    settingsUpdate ( ) {
        var form,pool,s;
        form = this.qs (this.restricted,'#swimlanes-settings form');
        pool = this.qs (this.restricted,'#input-pool');
        form.db_suffix.value = '';
        if (form.db_use_suffix.checked) {
            if (pool.value) {
                form.db_suffix.value = '_' + pool.value;
            }
            else {
                form.db_suffix.value = '_[pool code]';
            }
        }
        if (form.db_store.checked) {
            s = {
                user : form.db_user.value,
                db_per_pool : 1 * form.db_use_suffix.checked,
                db : form.db_name.value
            };
        }
        else {
            s = {};
        }
        this.storageWrite ('settings',s);
    }

}


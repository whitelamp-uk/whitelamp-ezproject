
/* Copyright 2020 Whitelamp http://www.whitelamp.co.uk */

import {Swimlanes} from './swimlanes.js';

export class Gui extends Swimlanes {

    swimlanesListen ( ) {
        var e, element, elements;
        elements            = this.qsa (this.restricted,'form#agentallows [data-agentallow]');
        for (e of elements) {
            e.addEventListener ('change',this.agentallowToggle.bind(this));
        }
        elements            = this.qsa (this.restricted,'form#agentallows [data-agentfunction]');
        for (element of elements) {
            if ('prohibit' in element.dataset) {
                continue;
            }
            element.addEventListener ('change',this.agentpermitToggle.bind(this));
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
               ,'admin-server'
               ,'\\Bab\\Admin'
            );
            this.authCheck (response);
        }
        catch (e) {
            console.log (e.message);
        }
        this.screenLockRefreshInhibit = null;
    }

    async authenticate (evt) {
        var email, pwd, response;
        evt.preventDefault ();
        try {
            pwd         = evt.currentTarget.form.password.value;
            if (pwd.length==0) {
                this.log ('No password given');
                return;
            }
            evt.currentTarget.form.password.value  = '';
            email       = evt.currentTarget.form.email.value;
            response    = await super.authenticate (
                evt.currentTarget.form.email.value
               ,pwd
               ,'swimlanes-server'
               ,'\\EzProject\\Swimlanes'
            );
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

    constructor (config) {
        super (config);
    }

    contractsListen ( ) {
        var e, elements;
        elements            = this.qsa (this.restricted,'form#contracts [data-contract]');
        for (e of elements) {
            e.addEventListener ('change',this.contractToggle.bind(this));
        }
    }

    async swimlanes ( ) {
        try {
            await this.swimlanesRequest (
            );
            this.statusShow ('Contract changed');
            this.screenRender (this.currentScreen,null,false);
        }
        catch (e) {
            this.splash (2,'Could not load swimlanes','Error','OK');
        }
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
        this.log ('gui.js initialised');
    }

    async keyRelease ( ) {
        var dt, expires;
        if (!confirm('Are you sure?')) {
            return true;
        }
        try {
            expires         = await this.keyReleaseRequest (this.parameters.userId);
        }
        catch (e) {
            this.splash (2,'Failed to release new key','Error','OK');
            return false;
        }
        dt                  = new Date (expires*1000);
        this.splash (0,'New key created and released by successful log-in before '+dt.toUTCString());
        this.find(this.data.users,'userId',this.parameters.userId,false).hasKey = 1;
        this.screenRender ('user',null,false);
        return true;
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

    testHandler (evt) {
        // Bespoke handler
        alert ('So you want to do stuff, eh?');
    }

}


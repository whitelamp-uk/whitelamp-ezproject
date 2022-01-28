
/* Copyright 2020 Whitelamp http://www.whitelamp.co.uk */

import {Global} from './global.js';

export class Swimlanes extends Global {

    constructor (config) {
        super (config);
    }

    async passwordResetRequest (answer,code,password) {
        var request, response;
        request     = {
            "email" : this.access.email.value
           ,"method" : {
                "vendor" : "whitelamp-ezproject"
               ,"package" : "swimlanes-server"
               ,"class" : "\\Whitelamp\\Swimlanes"
               ,"method" : "passwordReset"
               ,"arguments" : [
                    answer,code,password
                ]
            }
        }
        try {
            response = await this.request (request,true);
            return response.returnValue;
        }
        catch (e) {
            throw e;
            return false;
        }
    }

    async secretQuestionRequest (phoneEnd) {
    var request = {
            "email" : this.access.email.value
           ,"method" : {
                "vendor" : "whitelamp-ezproject"
               ,"package" : "admin-server"
               ,"class" : "\\Bab\\Admin"
               ,"method" : "secretQuestion"
               ,"arguments" : [
                  phoneEnd
                ]
            }
        }
        try {
        var response                = await this.request (request,true);
            return response.returnValue;
        }
        catch (e) {
            console.log ('secretQuestionRequest(): failed: '+e.message);
            throw new Error (e.message);
            return false;
        }
    }

    async swimlaneRequest (swimlaneCode) {
        var request;
        request     = {
            "email" : this.access.email.value
           ,"method" : {
                "vendor" : "whitelamp-ezproject"
               ,"package" : "swimlanes-server"
               ,"class" : "\\Whitelamp\\Swimlanes"
               ,"method" : "swimlane"
               ,"arguments" : [
                    swimlaneCode
                ]
            }
        }
        var response;
        try {
            response = await this.request (request);
            return response.returnValue;
        }
        catch (e) {
            console.error ('Could not get swimlane: '+e.message);
            return false;
        }
    }

    async swimlanesRequest (swimpoolCode) {
        var request;
        request     = {
            "email" : this.access.email.value
           ,"method" : {
                "vendor" : "whitelamp-ezproject"
               ,"package" : "swimlanes-server"
               ,"class" : "\\Whitelamp\\Swimlanes"
               ,"method" : "swimlanes"
               ,"arguments" : [
                    swimpoolCode
                ]
            }
        }
        var response;
        try {
            response = await this.request (request);
            return response.returnValue;
        }
        catch (e) {
            console.error ('Could not get swimlanes: '+e.message);
            return false;
        }
    }

    async usersRequest (swimpoolCode) {
        var request, response;
        request     = {
            "email" : this.access.email.value
           ,"method" : {
                "vendor" : "whitelamp-ezproject"
               ,"package" : "swimlanes-server"
               ,"class" : "\\Whitelamp\\Swimlanes"
               ,"method" : "users"
               ,"arguments" : [
                    swimpoolCode
                ]
            }
        }
        try {
            response = await this.request (request);
            this.data.users         = response.returnValue;
            return true;
        }
        catch (e) {
            console.error ('Could not get users for "'+swimpoolCode+'": '+e.message);
            return false;
        }
    }

    async verifyRequest ( ) {
    var request = {
            "email" : this.access.email.value
           ,"method" : {
                "vendor" : "whitelamp-ezproject"
               ,"package" : "swimlanes-server"
               ,"class" : "\\Whitelamp\\Swimlanes"
               ,"method" : "verify"
               ,"arguments" : []
            }
        }
        try {
        var response            = await this.request (request,true);
            return true;
        }
        catch (e) {
            throw new Error ('Could not verify: '+e.message);
            return false;
        }
    }

}


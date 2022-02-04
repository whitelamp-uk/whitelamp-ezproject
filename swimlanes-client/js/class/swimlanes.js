
/* Copyright 2022 Whitelamp http://www.whitelamp.co.uk */

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
               ,"class" : "\\EzProject\\Swimlanes"
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
               ,"class" : "\\EzProject\\Swimlanes"
               ,"method" : "secretQuestion"
               ,"arguments" : [
                  phoneEnd
                ]
            }
        }
        try {
        var response = await this.request (request,true);
            return response.returnValue;
        }
        catch (e) {
            console.log ('secretQuestionRequest(): failed: '+e.message);
            throw new Error (e.message);
            return false;
        }
    }

    async swimsRequest (swimpoolCode,swimlaneCode,statusCode) {
        var request;
        request = {
            "email" : this.access.email.value,
            "method" : {
                "vendor" : "whitelamp-ezproject",
                "package" : "swimlanes-server",
                "class" : "\\EzProject\\Swimlanes",
                "method" : "swims",
                "arguments" : [
                    swimpoolCode,
                    swimlaneCode,
                    statusCode
                ]
            }
        }
        var response;
        try {
            response = await this.request (request);
            return response.returnValue;
        }
        catch (e) {
            console.error ('Could not get swims: '+e.message);
            return false;
        }
    }

    async swimlanesRequest (swimpoolCode) {
        var request;
        request = {
            "email" : this.access.email.value
           ,"method" : {
                "vendor" : "whitelamp-ezproject"
               ,"package" : "swimlanes-server"
               ,"class" : "\\EzProject\\Swimlanes"
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

    async verifyRequest ( ) {
    var request = {
            "email" : this.access.email.value
           ,"method" : {
                "vendor" : "whitelamp-ezproject"
               ,"package" : "swimlanes-server"
               ,"class" : "\\EzProject\\Swimlanes"
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


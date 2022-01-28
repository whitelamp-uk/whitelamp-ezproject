
/* Copyright 2020 Whitelamp http://www.whitelamp.co.uk */

import {Gui} from './gui.js';

export class Enforcer extends Gui {

    // In MVC you might say the enforcer is a collection of "controllers"
    // but no adherance to MVC principles is intended or claimed

    async loaders (evt,params) {
        switch (evt.target.id) {
            case 'swimlanes':
                this.swimlanesListen ();
            default:
                return null;
        }
    }

}


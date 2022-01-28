
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

    constructor (config) {
        super (config);
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

    testHandler (evt) {
        // Bespoke handler
        alert ('So you want to do stuff, eh?');
    }

}


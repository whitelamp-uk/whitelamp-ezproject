
/* Copyright 2022 Whitelamp http://www.whitelamp.co.uk */

import {Gui} from './gui.js';

export class Enforcer extends Gui {

    // In MVC you might say the enforcer is a collection of "controllers"
    // but no strict adherance to MVC principles is intended or claimed

    actors (templateName) {
        // For a given screen, set up required event handlers
        var defns;
        this.editModeReset ();
        switch (templateName) {
            case 'home':
                defns = [
                    { id: 'actors-test', event: 'click', function: this.actorsTest }
                ];
                break;
            default:
                return;
        }
        console.log ('actors(): '+JSON.stringify(defns));
        this.actorsListen (defns);
    }

    hotkeys ( ) {
        return {
            "#" : [ this.hotkeysShow, "(~) show hot keys" ],
            "," : [ this.entryPrevious, "(<) select previous form input" ],
            "." : [ this.entryNext, "(>) select next form input" ],
            "'" : [ this.entryNew, "(@) new item toggle" ],
            "/" : [ this.filterHotkeyToggle, "(?) filter toggle" ],
            "]" : [ this.burger, "(}) burger menu toggle" ]
        }
    }

    async loaders (evt,templateName) {
        // For a given screen, do post-load process(es)
        switch (templateName) {
            case 'home':
                this.swimlanesInit ();
            default:
                return null;
        }
    }

    navigatorsSelector ( ) {
        return 'a.navigator,button.navigator,.nugget.navigator';
    }

    preloaders (templateName) {
        // For a given screen, do pre-load process(es)
        switch (templateName) {
            case 'home':
                return [this.configRequest];
            default:
                return [];
        }
    }

}


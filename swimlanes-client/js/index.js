
// Import
import {Config} from './class/config.js';
import {Enforcer} from './class/enforcer.js';

// Executive
function execute ( ) {
    try {
        new Enforcer (new Config()) .init ();
    }
    catch (e) {
        document.querySelector('body').innerHTML = 'Failed to initialise application: '+e.message;
    }
}
if (window.document.readyState=='interactive' || window.document.readyState=='complete') {
    execute ();
}
else {
    window.document.addEventListener ('DOMContentLoaded',execute);
}

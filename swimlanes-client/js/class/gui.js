
/* Copyright 2022 Whitelamp http://www.whitelamp.co.uk */

import {Swimlanes} from './swimlanes.js';

export class Gui extends Swimlanes {

    adminer (action,table,column,operator,value) {
        var db_user,url;
        db_user = this.qs (this.restricted,'#toolbar input[name="db_user"]');
alert (db_user);
        if (db_user && db_user.value) {
            url  = '/adm22/?username='+db_user.value;
            url += '&db=ezproject&'+action+'='+table;
            if (action=='select') {
                url += '&where[0][col]='+column;
                url += '&where[0][op]='+operator;
                url += '&where[0][val]='+value;
            }
            else if (action=='edit') {
                url += '&where['+column+']='+value;
            }
            console.log ('URL: '+url);
this.splash (0,url);
        }
else {
this.splash (0,'Need database user to calculate link');
}
    }

    buttonSetSelect (evt) {
        evt.preventDefault();
        var button;
        button = evt.currentTarget;
        if (button.classList.contains('selected')) {
            button.classList.remove ('selected');
        }
        else {
            button.classList.add ('selected');
        }
    }

    constructor (config) {
        super (config);
    }

    async sayHello (evt) {
        console.log (evt.currentTarget);
    }

    resize (evt) {
        if (this.resizeTimeout) {
            clearTimeout (this.resizeTimeout);
        }
        this.resizeTimeout = setTimeout (this.resizeEnd.bind(this),250);
    }

    resizeEnd (evt) {
        var btn,btns,count,height,lane,lanes,status,statuses,width;
        lanes = this.qsa (this.restricted,'#swimpool section.swimlane.selected');
        height = this.qs (this.restricted,'section.splits .y-'+lanes.length);
        btns = this.qsa (this.restricted,'#toolbar .set.status button.selected');
        width = this.qs (this.restricted,'section.splits .x-'+btns.length);
        statuses = this.qsa (this.restricted,'#swimpool section.status.selected');
        if (height) {
            for (lane of lanes) {
                lane.style.height = height.offsetHeight + 'px';
            }
            for (status of statuses) {
                status.style.height = (height.offsetHeight-2) + 'px';
            }
        }
        if (width) {
            for (status of statuses) {
                status.style.width = width.offsetWidth + 'px';
            }
        }
    }

    swimEdit (evt) {
        this.adminer ('edit','ezp_swim','id','%3D',evt.currentTarget.dataset.id);
    }

    swimlanesInit ( ) {
        var buttonset,i,form,pool,opts,status;
        form = this.qs (this.restricted,'#toolbar');
        pool = document.createElement ('select');
        pool.id = 'input-pool';
        pool.name = 'pool';
        opts = [];
        opts[0] = document.createElement ('option');
        opts[0].value = '';
        opts[0].textContent = 'Swimpool:';
        pool.appendChild (opts[0]);
        for (i=0;i<this.data.config.swimpools.length;i++) {
            opts[i+1] = document.createElement ('option');
            opts[i+1].value = this.data.config.swimpools[i].code;
            opts[i+1].textContent = this.data.config.swimpools[i].name;
            pool.appendChild (opts[i+1]);
        }
        form.appendChild (pool);
        i = document.createElement ('input');
        i.name = 'db_user';
        i.setAttribute ('placeholder','Database user');
        form.appendChild (i);
        pool.addEventListener ('input',this.swimpool.bind(this));
        buttonset = document.createElement ('span');
        buttonset.classList.add ('set');
        buttonset.classList.add ('status');
        form.appendChild (buttonset);
        for (i=0;i<this.data.config.statuses.length;i++) {
            status = document.createElement ('button');
            status.dataset.swimstate = this.data.config.statuses[i].code;
            status.dataset.icon = this.data.config.statuses[i].icon;
            status.textContent = this.data.config.statuses[i].code;
            status.setAttribute ('title',this.data.config.statuses[i].name);
            buttonset.appendChild (status);
            status.addEventListener ('click',this.buttonSetSelect.bind(this));
            status.addEventListener ('click',this.toggleStatus.bind(this));
            if (this.data.config.statuses[i].show_by_default) {
                status.click ();
            }
        }
        buttonset = document.createElement ('span');
        buttonset.classList.add ('set');
        buttonset.classList.add ('swimlane');
        form.appendChild (buttonset);
        window.addEventListener ('resize',this.resize.bind(this));
    }

    async swimlanes (swimpoolCode) {
        var button,buttons,buttonset,cell,height,i,j,labelc,label1,label2,lane,lanesNew,lanesOld,pool,qty;
        pool        = this.qs (this.restricted,'#swimpool');
        buttonset   = this.qs (pool,'#toolbar .set.swimlane');
        if (!buttonset) {
            console.error ('Could not find <span class="set swimlane">');
            return;
        }
        buttons     = this.qsa (buttonset,'[data-swimpool][data-swimlane]');
        lanesOld    = this.qsa (pool,'section.swimlane');
        lanesNew    = await this.swimlanesRequest (swimpoolCode);
        // Remove unwanted buttons
        for (button of buttons) {
            if (!this.find(lanesNew,'swimpool',button.dataset.swimpool)) {
                if (!this.find(lanesNew,'code',button.dataset.code)) {
                    button.remove ();
                }
            }
        }
        // Remove unwanted lanes
        for (lane of lanesOld) {
            if (!this.find(lanesNew,'swimpool',lane.dataset.swimpool)) {
                if (!this.find(lanesNew,'code',lane.dataset.code)) {
                    lane.remove ();
                }
            }
        }
        // Add missing buttons
        for (i=0;i<lanesNew.length;i++) {
            button = this.qs (
                pool,
                '#toolbar .set.swimlane [data-swimpool="'+lanesNew[i].swimpool+'"][data-swimlane="'+lanesNew[i].code+'"]'
            );
            if (!button) {
                button = document.createElement ('button');
                button.classList.add ('selected');
                button.dataset.swimpool = lanesNew[i].swimpool;
                button.dataset.swimlane = lanesNew[i].code;
                button.setAttribute ('title',lanesNew[i].name);
                button.textContent = lanesNew[i].swimpool+'-'+lanesNew[i].code
                buttonset.appendChild (button);
                button.addEventListener ('click',this.buttonSetSelect.bind(this));
                button.addEventListener ('click',this.toggleLane.bind(this));
            }
        }
        // Add missing lanes
        for (i=0;i<lanesNew.length;i++) {
            lane = this.qs (
                pool,
                'section.swimlane[data-swimpool="'+lanesNew[i].swimpool+'"][data-swimlane="'+lanesNew[i].code+'"]'
            );
            if (!lane) {
                lane = document.createElement ('section');
                lane.classList.add ('selected');
                lane.dataset.swimpool = lanesNew[i].swimpool;
                lane.dataset.swimlane = lanesNew[i].code;
                label1 = document.createElement ('label');
                label1.setAttribute ('title',lanesNew[i].name);
                label1.classList.add ('after');
                label1.textContent = lane.dataset.swimpool + '-' + lane.dataset.swimlane;
                lane.appendChild (label1);
                label2 = document.createElement ('label');
                label2.setAttribute ('title',lanesNew[i].name);
                label2.classList.add ('before');
                label2.textContent = lane.dataset.swimpool + '-' + lane.dataset.swimlane;
                lane.appendChild (label2);
                lane.classList.add ('swimlane');
                // Status cells
                for (j=0;j<this.data.config.statuses.length;j++) {
                    cell = document.createElement ('section');
                    cell.classList.add ('status');
                    button = this.qs (
                        pool,
                        '#toolbar .set [data-swimstate="'+this.data.config.statuses[j].code+'"]'
                    );
                    if (button && button.classList.contains('selected')) {
                        // If the status button is selected
                        cell.classList.add ('selected');
                    }
                    cell.dataset.swimstate = this.data.config.statuses[j].code;
                    labelc = document.createElement ('label');
                    labelc.setAttribute ('title',this.data.config.statuses[j].name);
                    labelc.textContent = cell.dataset.swimstate;
                    if (cell.dataset.swimstate in lanesNew[i].swims) {
                        qty = document.createElement ('span');
                        qty.classList.add ('swims');
                        qty.textContent = '('+lanesNew[i].swims[cell.dataset.swimstate]+')';
                        labelc.appendChild (qty);
                    }
                    cell.appendChild (labelc);
                    lane.appendChild (cell);
                }
                pool.appendChild (lane);
                this.swimsByLane (lane);
            }
        }
        this.resizeEnd ();
    }

    swimpool (evt) {
        var code,lane,lanes;
        code = evt.currentTarget.value;
        lanes = this.qsa (this.restricted,'#swimpool section.swimlane');
        for (lane of lanes) {
            lane.remove ();
        }
        if (code) {
            this.swimlanes (code);
        }
    }

    async swims (cell) {
        var i,swim,swims;
        swims = await this.swimsRequest (
            cell.parentElement.dataset.swimpool,
            cell.parentElement.dataset.swimlane,
            cell.dataset.swimstate
        );
// TODO: not this easy because existing swims must not be replicated
        for (i=0;i<swims.length;i++) {
            swim = document.createElement ('span');
            swim.classList.add ('swim');
            swim.dataset.id = swims[i].id;
            swim.textContent = '#'+swims[i].id;
            cell.appendChild (swim);
            swim.addEventListener ('click',this.swimEdit.bind(this));
        }
    }

    swimsByLane (lane) {
        var cell,cells;
        cells = this.qsa (lane,'section.status.selected');
        for (cell of cells) {
            this.swims (cell);
        }
    }

    toggleLane (evt) {
        var l,lane,p;
        p = evt.currentTarget.dataset.swimpool;
        l = evt.currentTarget.dataset.swimlane;
        lane = this.qs (
            this.restricted,
            '#swimpool section.swimlane[data-swimpool="'+p+'"][data-swimlane="'+l+'"]'
        );
        if (lane) {
            if (lane.classList.contains('selected')) {
                lane.classList.remove ('selected');
            }
            else {
                lane.classList.add ('selected');
                this.swimsByLane (lane);
            }
        }
        this.resizeEnd ();
    }

    toggleStatus (evt) {
        var cell,cells,s;
        s = evt.currentTarget.dataset.swimstate;
        cells = this.qsa (
            this.restricted,
            '#swimpool section.swimlane section[data-swimstate="'+s+'"]'
        );
        for (cell of cells) {
            if (cell.classList.contains('selected')) {
                cell.classList.remove ('selected');
            }
            else {
                cell.classList.add ('selected');
                this.swims (cell);
            }
        }
        this.resizeEnd ();
    }

}


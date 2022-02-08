
/* Copyright 2022 Whitelamp http://www.whitelamp.co.uk */

import {Swimlanes} from './swimlanes.js';

export class Gui extends Swimlanes {

    adminer (action,table,column=null,operator=null,value=null) {
        var db_user,url,win;
        db_user = this.qs (this.restricted,'#toolbar input[name="db_user"]');
        if (db_user && db_user.value) {
            url  = this.cfg.adminerUrl;
            url += '?username=' + db_user.value;
            url += '&db=ezproject';
            url += '&' + action + '=' + table;
            if (action=='select' && column) {
                url += '&where[0][col]=' + column;
                url += '&where[0][op]=' + operator;
                url += '&where[0][val]=' + value;
            }
            else if (action=='edit') {
                if (!column) {
                    this.statusShow ('Sorry something went wrong...');
                    return;
                }
                url += '&where[' + column + ']=' + value;
            }
            console.log ('URL: '+url);
            win = 'swimlanes-adminer-' + action;
            if (action=='select') {
                win += '-' + table;
            }
            win = window.open (url,win);
            win.focus ();
        }
        else {
            this.flash (db_user);
            this.statusShow ('Enter your database user for Adminer editing');
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

    async flash (elmt) {
        elmt.classList.add ('flash');
        await this.sleep (1500);
        elmt.classList.remove ('flash');
    }

    nullToEmpty (val) {
        if (val===null) {
            return '';
        }
        return val;
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

    async sayHello (evt) {
        console.log (evt.currentTarget);
    }

    sleep (msecs) {
        return new Promise (
            (resolve) => {
                setTimeout (resolve,msecs);
            }
        );
    }

    sort (rows,sort) {
        if (!this.sorts()['sort']) {
            return rows;
        }
        if (sort=='close') {
            rows.sort (
                function (a,b) {
                    return this.sortFunction(a.close_by_date,b.close_by_date,true,true).bind(this);
                }
            );
        }
        else if (sort=='progress') {
            rows.sort (
                function (a,b) {
                    return this.sortFunction(a.progress_by_date,b.progress_by_date,true,true).bind(this);
                }
            );
        }
        else if (sort=='updated') {
            rows.sort (
                function (a,b) {
                    var ta,tb;
                    if (a.updated) {
                        ta = a.updated;
                    }
                    else {
                        ta = a.created;
                    }
                    if (b.updated) {
                        tb = b.updated;
                    }
                    else {
                        tb = b.created;
                    }
                    return this.sortFunction(ta,tb,false,false).bind(this);
                    
                }
            );
        }
        else if (sort=='edits') {
            rows.sort (
                function (a,b) {
                    return this.sortFunction(a.edits_recent,b.edits_recent,false).bind(this);
                }
            );
        }
        else if (sort=='oldest') {
            rows.sort (
                function (a,b) {
                    return this.sortFunction(a.created,b.created,true).bind(this);
                }
            );
        }
        else if (sort=='youngest') {
            rows.sort (
                function (a,b) {
                    return this.sortFunction(a.created,b.created,false).bind(this);
                }
            );
        }
        return rows;
    }

    sortAll (evt) {
        var cell,cells;
        cells = this.qsa (this.restricted,'#swimpool section.status.selected');
        for (cell of cells) {
            this.sortCell (cell,evt.currentTarget.value);
        }
    }

    sortCell (cell,sortOption) {
        var arr,i,swim,swims;
        swims = this.qsa (cell,'.swim[data-id]');
        arr = [];
        for (swim of swims) {
            arr.push (swim);
        }
        arr = this.sort (arr,sortOption);
        for (i=0;i<arr.length;i++) {
            cell.removeChild (arr[i]);
            cell.prepend (arr[i]);
        }
    }

    sortFunction (a,b,ascending=true,missingIsHigh=false) {
        if (a==b) {
            return 0;
        }
        if (missingIsHigh) {
            // 0, null or "" treated as high
            if (!b || b>a) {
                if (ascending) {
                    return -1;
                }
                return 1;
            }
            if (!a || b<a) {
                if (ascending) {
                    return 1;
                }
                return -1;
            }
        }
        // 0, null or "" treated as low
        if (b>a) {
            if (ascending) {
                return -1;
            }
            return 1;
        }
        if (a<b) {
            if (ascending) {
                return -1;
            }
            return 1;
        }
        return 0;
    }

    sorts (rows,sort) {
        return {
            close : "By closure deadline",
            progress : "By progress deadline",
            updated : "By most recent update",
            edits : "By most edits recently",
            oldest : "By oldest first",
            youngest : "By youngest first",
        };
    }

    swim (cell,swim) {
        var p,s,sm,sp;
        s = this.qs (cell,'.swim[data-id="'+swim.id+'"]');
        if (s) {
            // Update swim
            this.qs(s,'summary').textContent
                = '#' + swim.id + ' ' + swim.name;
            // The first <pre> tag is the navigation bit
            this.qs(s,'pre:nth-of-type(2)').textContent
                = 'STATUS: ' + cell.parentElement.dataset.swimpool
                + '-' + cell.parentElement.dataset.swimlane
                + ' ' + swim.status;
            this.qs(s,'pre:nth-of-type(3)').textContent
                = 'PROGRESS BY: ' + this.nullToEmpty(swim.progress_by_date);
            this.qs(s,'pre:nth-of-type(4)').textContent
                = 'CLOSE BY: ' + this.nullToEmpty(swim.close_by_date);
            this.qs(s,'pre:nth-of-type(5)').textContent
                = 'NOTES: ' + swim.notes;
            this.qs(s,'pre:nth-of-type(6)').textContent
                = 'SPEC: ' + swim.specification;
            this.qs(s,'pre:nth-of-type(7)').textContent
                = 'CREATED: ' + swim.created;
            this.qs(s,'pre:nth-of-type(8)').textContent
                = 'UPDATED: ' + swim.updated;
            this.qs(s,'pre:nth-of-type(9)').textContent
                = 'UPDATER: ' + swim.updater;
        }
        else {
            // Create swim
            s = document.createElement ('details');
            s.classList.add ('swim');
            s.dataset.id = swim.id;
            sm = document.createElement ('summary');
            sm.textContent = '#' + swim.id + ' ' + swim.name;
            s.appendChild (sm);
            p = document.createElement ('pre');
            p.dataset.id = swim.id;
            sp = document.createElement ('span');
            sp.classList.add ('close');
            sp.innerHTML  = '<span class="arrow">&swarr;</span> Close';
            sp.addEventListener ('click',this.swimClose.bind(this));
            p.appendChild (sp);
            sp = document.createElement ('span');
            sp.classList.add ('link');
            sp.innerHTML += 'Edit <span class="arrow">&nearr;</span>';
            sp.addEventListener ('click',this.swimEdit.bind(this));
            p.appendChild (sp);
            s.appendChild (p);
            p = document.createElement ('pre');
            p.textContent = 'STATUS: ' + cell.parentElement.dataset.swimpool;
            p.textContent += '-' + cell.parentElement.dataset.swimlane;
            p.textContent += ' ' + swim.status;
            s.appendChild (p);
            p = document.createElement ('pre');
            p.textContent = 'PROGRESS BY: ' + this.nullToEmpty(swim.progress_by_date);
            s.appendChild (p);
            p = document.createElement ('pre');
            p.textContent = 'CLOSE BY: ' + this.nullToEmpty(swim.close_by_date);
            s.appendChild (p);
            p = document.createElement ('pre');
            p.textContent = 'NOTES: ' + swim.notes;
            s.appendChild (p);
            p = document.createElement ('pre');
            p.textContent = 'SPEC: ' + swim.specification;
            s.appendChild (p);
            p = document.createElement ('pre');
            p.textContent = 'CREATED: ' + swim.created;
            s.appendChild (p);
            p = document.createElement ('pre');
            p.textContent = 'UPDATED: ' + swim.updated;
            s.appendChild (p);
            p = document.createElement ('pre');
            p.textContent = 'UPDATER: ' + swim.updater;
            s.appendChild (p);
            cell.appendChild (s);
        }
    }

    swimClose (evt) {
        var details;
        details = evt.currentTarget.parentElement.parentElement;
        if (details.hasAttribute('open')) {
            details.removeAttribute ('open');
        }
    }

    swimEdit (evt) {
        this.adminer ('edit','ezp_swim','id','%3D',evt.currentTarget.parentElement.dataset.id);
    }

    swimlanesInit ( ) {
        var buttonset,i,form,open,pool,opt,opts,sort,sorter,sorts,status;
        form = this.qs (this.restricted,'#toolbar');
        pool = document.createElement ('select');
        pool.id = 'input-pool';
        pool.name = 'pool';
        opts = [];
        opts[0] = document.createElement ('option');
        opts[0].value = '';
        opts[0].textContent = 'Select pool:';
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
        i.setAttribute ('title','Facilitates seamless Adminer linking');
        i.setAttribute ('placeholder','Database user');
        form.appendChild (i);
        pool.addEventListener ('input',this.swimpool.bind(this));
        // Status button set
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
            status.addEventListener ('click',this.buttonSetSelect.bind(this));
            status.addEventListener ('click',this.toggleStatus.bind(this));
            buttonset.appendChild (status);
            if (this.data.config.statuses[i].show_by_default) {
                status.click ();
            }
        }
        open = document.createElement ('span');
        open.classList.add ('open');
        open.innerHTML = '&nearr;';
        open.addEventListener ('click',this.statusesList.bind(this));
        buttonset.appendChild (open);
        // Select sort method
        sorter = document.createElement ('select');
        sorter.id = 'input-sort';
        sorts = this.sorts ();
        for (sort of Object.keys(sorts)) {
            opt = document.createElement ('option');
            opt.value = sort;
            opt.textContent = sorts[sort];
            sorter.appendChild (opt);
        }
        sorter.addEventListener ('input',this.sortAll.bind(this));
        form.appendChild (sorter);
        // Swimlane button set
        buttonset = document.createElement ('span');
        buttonset.classList.add ('set');
        buttonset.classList.add ('swimlane');
        open = document.createElement ('span');
        open.classList.add ('open');
        open.innerHTML = '&nwarr;';
        open.addEventListener ('click',this.swimlanesList.bind(this));
        buttonset.appendChild (open);
        form.appendChild (buttonset);
        window.addEventListener ('resize',this.resize.bind(this));
        this.updatesRequest ();
    }

    async swimlanes (swimpoolCode) {
        var all,button,buttons,buttonset,cell,height,i,j;
        var labelc,label1,label2,lane,lanesNew,lanesOld,pool,qty;
        pool        = this.qs (this.restricted,'#swimpool');
        buttonset   = this.qs (pool,'#toolbar .set.swimlane');
        if (!buttonset) {
            console.error ('Could not find <span class="set swimlane">');
            return;
        }
        buttons     = this.qsa (buttonset,'[data-swimpool][data-swimlane]');
        lanesOld    = this.qsa (pool,'section.swimlane');
        if (swimpoolCode) {
            lanesNew    = await this.swimlanesRequest (swimpoolCode);
        }
        // Remove unwanted buttons
        for (button of buttons) {
            if (swimpoolCode) {
                if (!this.find(lanesNew,'swimpool',button.dataset.swimpool)) {
                    if (!this.find(lanesNew,'code',button.dataset.code)) {
                        button.remove ();
                    }
                }
            }
            else {
                button.remove ();
            }
        }
        // Remove unwanted lanes
        for (lane of lanesOld) {
            if (swimpoolCode) {
                if (!this.find(lanesNew,'swimpool',lane.dataset.swimpool)) {
                    if (!this.find(lanesNew,'code',lane.dataset.code)) {
                        lane.remove ();
                    }
                }
            }
            else {
                lane.remove ();
            }
        }
        if (swimpoolCode) {
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
                    button.textContent = lanesNew[i].code
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
                            qty.innerHTML = '<span class="count">('+lanesNew[i].swims[cell.dataset.swimstate]+') &nearr;</span>';
                            labelc.appendChild (qty);
                        }
                        cell.appendChild (labelc);
                        labelc.addEventListener ('click',this.swimsList.bind(this));
                        lane.appendChild (cell);
                    }
                    pool.appendChild (lane);
                    this.swimsByLane (lane);
                }
            }
            this.resizeEnd ();
        }
    }

    swimlanesList (evt) {
        var p;
        p = this.qs (this.restricted,'#input-pool');
        if (p.value) {
             this.adminer ('select','ezp_swimlane','swimpool','%3D',p.value);
        }
    }

    statusesList (evt) {
        this.adminer ('select','ezp_status');
    }

    swimpool (evt) {
        var code,lane,lanes;
        code = evt.currentTarget.value;
        lanes = this.qsa (this.restricted,'#swimpool section.swimlane');
        for (lane of lanes) {
            lane.remove ();
        }
        this.swimlanes (code);
        if (code) {
            evt.currentTarget.classList.add ('selected');
        }
        else {
            evt.currentTarget.classList.remove ('selected');
        }
    }

    async swims (cell) {
        var i,p,s,sort,swim,swimsNew,swimsOld;
        swimsNew = await this.swimsRequest (
            cell.parentElement.dataset.swimpool,
            cell.parentElement.dataset.swimlane,
            cell.dataset.swimstate
        );
        sort = this.qs (this.restricted,'#input-sort');
        swimsNew = this.sort (swimsNew,sort.options[sort.selectedIndex].value);
        swimsOld = this.qsa (cell,'.swim');
        // Remove unwanted swims
        for (swim of swimsOld) {
            if (!this.find(swimsNew,'id',swim.dataset.id)) {
                swim.remove ();
            }
        }
        for (i=0;i<swimsNew.length;i++) {
            this.swim (cell,swimsNew[i]);
        }
    }

    swimsByLane (lane) {
        var cell,cells;
        cells = this.qsa (lane,'section.status.selected');
        for (cell of cells) {
            this.swims (cell);
        }
    }

    swimsList (evt) {
        var ids,swim,swims;
        swims = this.qsa (evt.currentTarget.parentElement,'.swim[data-id]');
        if (swims.length) {
            ids = '';
            for (swim of swims) {
                ids += swim.dataset.id + ',';
            }
            this.adminer ('select','ezp_swim','id','IN',ids.substring(0,ids.length-1));
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
        cells = this.qsa (this.restricted,'#swimpool section.swimlane section[data-swimstate="'+s+'"]');
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

    updates (swims) {
        var i,button,cell,swim;
        for (i=0;i<swims.length;i++) {
            cell = this.qs (
                this.restricted,
                '#swimpool section.swimlane[data-swimpool="'+swims[i].swimpool+'"][data-swimlane="'+swims[i].swimlane+'"] .status[data-swimstate="'+swims[i].status+'"]'
            );
            swim = this.qs (
                this.restricted,
                '#swimpool section.swimlane .status details[data-id="'+swims[i].id+'"]'
            );
            if (swim && swim.parentElement!=cell) {
                swim.parentElement.removeChild (swim);
                if (!cell.classList.contains('selected')) {
                    cell.classList.add ('selected');
                    button = this.qs (this.restricted,'#toolbar .set.status [data-swimstate="'+cell.dataset.swimstate+'"]');
                    button.classList.add ('selected');
                }
                cell.prepend (swim);
                this.statusShow ('Update (and move): '+cell.parentElement.dataset.swimpool+'-'+cell.parentElement.dataset.swimlane+' '+swims[i].status);
            }
            else {
                this.statusShow ('Update: '+cell.parentElement.dataset.swimpool+'-'+cell.parentElement.dataset.swimlane+' '+swims[i].status);
            }
            this.swim (cell,swims[i]);
        }
    }

}


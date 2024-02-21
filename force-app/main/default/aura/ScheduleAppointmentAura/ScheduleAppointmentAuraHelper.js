({
    
    getColumnAndAction : function(component) {
     /*   var actions = [
            {label: 'Edit', name: 'edit'},
            {label: 'Delete', name: 'delete'},
            {label: 'View', name: 'view'}
        ];*/
        component.set('v.columns', [
            { fieldName: 'sno', type: 'text',class: 'textWidth',initialWidth: 10,hideDefaultActions: true},
            { label: 'Name',fieldName: 'Name', type: 'button',  typeAttributes: {
                label: { fieldName: 'Name' },
                title: { fieldName: 'Name' },
                variant: 'base',
                class: 'text-button'
            }},
            {label: 'Specialty', fieldName: 'Specialty', type: 'button',  typeAttributes: {
                label: { fieldName: 'Specialty' },
                title: { fieldName: 'Specialty' },
                variant: 'base',
                class: 'text-button'
            } },
            {label: 'City', fieldName: 'MailingCity', type: 'button' ,  typeAttributes: {
                label: { fieldName: 'MailingCity' },
                title: { fieldName: 'MailingCity' },
                variant: 'base',
                class: 'text-button'
            }},
            {label: 'State', fieldName: 'MailingState', type: 'button',  typeAttributes: {
                label: { fieldName: 'MailingState' },
                title: { fieldName: 'MailingState' },
                variant: 'base',
                class: 'text-button'
            }},
            {label: 'Phone', fieldName: 'Phone', type: 'button',  typeAttributes: {
                label: { fieldName: 'Phone' },
                title: { fieldName: 'Phone' },
                variant: 'base',
                class: 'text-button'
            }},
            {label: 'Location', fieldName: 'Location', type: 'button',  typeAttributes: {
                label: { fieldName: 'Location' },
                title: { fieldName: 'Location' },
                variant: 'base',
                class: 'text-button'
            }},
           /* {label: 'Next Available Slot', fieldName: 'NextAvailSlot', sortable: true, wrapText: true, type: 'button',  typeAttributes: {
                label: { fieldName: 'NextAvailSlot' },
                title: { fieldName: 'NextAvailSlot' },
                variant: 'base',
                class: 'text-button'
            }},*/
             {label: 'Next Available Slot', fieldName: 'NextAvailSlot', type: 'date',sortable: true, typeAttributes: {  
                                                                            day: 'numeric',  
                                                                            month: 'short',  
                                                                            year: 'numeric',  
                                                                            hour: '2-digit',  
                                                                            minute: '2-digit',  
                                                                            hour12: true}},
            { label:  "Search Availability",fieldName: 'moreSlots', type: 'button', initialWidth: 150, typeAttributes: { label: 'Search', title: 'More Available slots', target: '_blank' , name: 'recLink',variant: 'neutral', size: 'small',class: 'slds-m-left_medium' } }
    
        ]);
    },

    globalFlagToast : function(component,title,message,type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message":  message,
            "type" :type
        });
        toastEvent.fire();
    },
    
    getAccountTeamMember : function(component, AccountId,SpecId,LocId,GenderVal,Filter) {
        var action = component.get("c.getAccountTeamMember");
        component.find("Id_spinner").set("v.class" , 'slds-show');
        
        action.setParams({
            'accountId': AccountId,
            'specialityId': SpecId,
            'locationId': LocId,
            'genderVal': GenderVal,
            'filter': Filter
        });
        action.setCallback(this,function(response) {
            var state = response.getState();
            console.log('acc team state***',state);
            if (state === "SUCCESS") {
                console.log('inside state success');
                var rows = response.getReturnValue();  
                console.log('new', rows);
                    var accountName = rows[0].accountName;
                    component.set("v.accName", accountName);
                    var genderVal = rows[0].genderSet;
                    component.set("v.genderOptions", genderVal);

                    if(rows.length>1){
                    
                    for (var i = 1; i < rows.length; i++) {
                        var row = rows[i];

                        console.log('row[i]',row);

                        row.Name = row.pracName;
                        row.MailingCity = row.pracCity;
                        row.MailingState = row.pracState;
                        row.Phone = row.pracPhone;
                        row.Location = row.provName;
                        row.Specialty = row.specialityName;
                        row.NextAvailSlot = row.nextAvailableSlot;
                        row.moreSlots = '...';
                       // row.nxtAvailSlotDateTm = row.nextAvailableSlotDateTm;
                    }
                    
                    if (rows && rows.length > 0) {
                        
                        rows.shift();
                        component.set("v.appointmentList" , rows);
                   // component.set("v.data", rows);
                    component.set("v.recordsAvailable", true);
                    component.find("Id_spinner").set("v.class" , 'slds-hide');
                    this.preparePagination(component, rows);
                    this.sortData(component, component.get("v.sortedBy"), component.get("v.sortedDirection"));
                        
                    }
                }
                else if(rows.length==1){
                    console.log('row length zero');
                    component.find("Id_spinner").set("v.class" , 'slds-hide');
                    component.set("v.recordsAvailable", false);
                }
                
            }
            else if (state === "ERROR") {
                console.log('inside state error');
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            this.globalFlagToast(component,errors[0].message,' ','error');
                        }
                    }
                    component.find("Id_spinner").set("v.class" , 'slds-hide');
                component.set("v.recordsAvailable", false);
                }
            else{
                console.log('inside state unknown');
                component.find("Id_spinner").set("v.class" , 'slds-hide');
                component.set("v.recordsAvailable", false);
                
            }
        });
        $A.enqueueAction(action);
    },
    
    getAllProviders : function(component, AccountId,SpecId,LocId,GenderVal,Filter) {
        var action = component.get("c.getProviders");
        component.find("Id_spinner").set("v.class" , 'slds-show');
        var today = new Date();
       // let day = today.getDate();
       // let month = today.getMonth();
       // let year = today.getFullYear();
      
        action.setParams({
            'accountId': AccountId,
            'specialityId': SpecId,
            'locationId': LocId,
            'genderVal': GenderVal,
            'filter': Filter
        });
        action.setCallback(this,function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                /*const monthNames = ["January", "February", "March", "April", "May", "June",
                                    "July", "August", "September", "October", "November", "December"
                                    ];*/
                console.log('inside state success');
                var rows = response.getReturnValue();
                console.log('rows*****',JSON.stringify(rows));
                for (var i = 0; i < rows.length; i++) {
                    var row = rows[i];
                    row.Name = row.pracName;
                    row.MailingCity = row.pracCity;
                    row.MailingState = row.pracState;
                    row.Phone = row.pracPhone;
                    row.Location = row.provName;
                    row.Specialty = row.specialityName;
                    row.NextAvailSlot = row.nextAvailableSlot;
                }
                if (rows && rows.length > 0) {
                    component.set("v.appointmentList" , rows);
                   // component.set("v.data", rows);
                    component.set("v.recordsAvailable", true);
                    component.find("Id_spinner").set("v.class" , 'slds-hide');
                    this.preparePagination(component, rows);
                    this.sortData(component, component.get("v.sortedBy"), component.get("v.sortedDirection"));
                   
                }
                else{
                    component.find("Id_spinner").set("v.class" , 'slds-hide');
                    component.set("v.recordsAvailable", false);
                }
            }
            else if (state === "ERROR") {
                console.log('inside state error');
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            this.globalFlagToast(component,errors[0].message,' ','error');
                        }
                    }
                    component.find("Id_spinner").set("v.class" , 'slds-hide');
                component.set("v.recordsAvailable", false);
                }
            else{
                console.log('inside state unknown');
                component.find("Id_spinner").set("v.class" , 'slds-hide');
                component.set("v.recordsAvailable", false);
                
            }
        });
        $A.enqueueAction(action);
    },

    preparePagination: function (component, records) {
        let countTotalPage = Math.ceil(records.length / component.get("v.pageSize"));
        let totalPage = countTotalPage > 0 ? countTotalPage : 1;
        component.set("v.totalPages", totalPage);
        component.set("v.pageNumber", 1);
          console.log('a',component.get("v.totalPages"));
      
       // component.set("v.totalRecords", records.length);
        this.setPaginateData(component);
    },
     
    setPaginateData: function(component){
        let data = [];
        let pageNumber = component.get("v.pageNumber");
        let pageSize = component.get("v.pageSize");
        let accountData = component.get('v.appointmentList');
          console.log('b',component.get("v.pageNumber"));
          console.log('v',component.get("v.pageSize"));
          console.log('f',component.get("v.appointmentList"));
        let currentPageCount = 0;
        let x = (pageNumber - 1) * pageSize;
        console.log('f5555',x);
        currentPageCount = x;
        for (; x < (pageNumber) * pageSize; x++){
            if (accountData[x]) {
                data.push(accountData[x]);
                currentPageCount++;
            }
        }
        console.log('f55553333333',currentPageCount);
        component.set("v.data", data);
        component.set("v.parentData",JSON.parse(JSON.stringify(data)));
        component.set("v.currentPageRecords", currentPageCount);
    },
    
    sortData: function (component, fieldName, sortDirection) {
        var data = component.get("v.appointmentList");
        var reverse = sortDirection !== 'asc';
        data.sort(this.sortBy(fieldName, reverse));
          for (var i = 0; i < data.length; i++) {
                    var row = data[i];
                    row.sno = i+1;
                }
        component.set("v.appointmentList", data);
        this.setPaginateData(component);
    },
    sortBy: function (field, reverse) {
        var key = function(x) {return x[field]};
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    },
    /*sortBy: function (field, reverse, primer) {
        var key = primer ?
            function(x) {return primer(x[field])} :
            function(x) {return x[field]};
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    }*/
    
    //added for portal appointments functionality
    getUrlParameter: function(component, event, helper, paramName) {
         var url = window.location.href;
         var paramStartIndex = url.indexOf('?');
         if (paramStartIndex === -1) return '';
         var paramsString = url.slice(paramStartIndex + 1);
         var params = new URLSearchParams(paramsString);
         return params.get(paramName);
  }
    
})
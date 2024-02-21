({
    doInitHelper : function(component) {
        //   this.fetchDropdownValues(component);
        
        $A.util.toggleClass(component.find('resultsDiv'),'slds-is-open');
        var value = component.get('v.value');
        var values = component.get('v.values');
        
        if( !$A.util.isEmpty(value) || !$A.util.isEmpty(values) ) {
            var searchString;
            var count = 0;
            var multiSelect = component.get('v.multiSelect');
            var options = component.get('v.options');
            
            options.forEach( function(element, index) {
                if(multiSelect) {
                    if(values.includes(element.value)) {
                        element.selected = true;
                        count++;
                    }  
                } else {
                    if(element.value == value) {
                        searchString = element.label;
                    }
                }
            });
            if(multiSelect)
                component.set('v.searchString', count + ' options selected');
            else
                component.set('v.searchString', searchString);
            component.set('v.options', options);
            
            if(count == 0){
                component.set('v.searchString', 'Select an option');
            }
        }
        
    },
    
    filterOptionsHelper : function(component) {
        component.set("v.message", '');
        var searchText = component.get('v.searchString');
        var options = component.get("v.options");
        var minChar = component.get('v.minChar');
        if(searchText.length >= minChar) {
            var flag = true;
            options.forEach( function(element,index) {
                if(element.label.toLowerCase().trim().startsWith(searchText.toLowerCase().trim())) {
                    element.isVisible = true;
                    flag = false;
                } else {
                    element.isVisible = false;
                }
            });
            component.set("v.options",options);
            if(flag) {
                component.set("v.message", "No results found for '" + searchText + "'");
            }
        }
        $A.util.addClass(component.find('resultsDiv'),'slds-is-open');
    },
    
    selectItemHelper : function(component, event) {
       
        var options = component.get('v.options');
        var multiSelect = component.get('v.multiSelect');
        var searchString = component.get('v.searchString');
        var values = component.get('v.values') || [];
        var value;
        var count = 0;
        options.forEach( function(element, index) {
            if(element.value === event.currentTarget.id) {
                if(multiSelect) {
                    if(values.includes(element.value)) {
                        values.splice(values.indexOf(element.value), 1);
                    } else {
                        values.push(element.value);
                    }
                    element.selected = element.selected ? false : true;   
                } else {
                    value = element.value;
                    searchString = element.label;
                }
            }
            if(element.selected) {
                count++;
            }
        });
        component.set('v.value', value);
        component.set('v.values', values);
        
        component.set('v.options', options);
        if(multiSelect)
            component.set('v.searchString', count + ' options selected');
        else
            component.set('v.searchString', searchString);
        if(multiSelect)
            event.preventDefault();
        else
            $A.util.removeClass(component.find('resultsDiv'),'slds-is-open');
        var len =  component.get('v.options');
        var count = 0;
        for(let rec in len){
            if(len[rec].selected){
                count++;  
            }
        }
       /* if(count==5){
            var optnLst = component.get('v.options'); 
            for(let rec in optnLst){
                optnLst[rec]['disabled'] = true;
            }
            component.set('v.options',optnLst); 
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "MAXIMUM OPTIONS(5) SELECTED!",
                "message": "Please remove records to add new",
                "type" : "warning"
            });
            toastEvent.fire();
        }
        else {
            var optnLst = component.get('v.options'); 
            for(let rec in optnLst){
                optnLst[rec]['disabled'] = false;
            }
            component.set('v.options',optnLst); 
        }*/
        if(count == 0){
            component.set('v.searchString', 'Select an option');
        }
        if(count>0){
            component.set("v.isSetUpKeySelected",true);
        }
        else {
            component.set("v.isSetUpKeySelected",false);
        }
        var selectedApprovers = JSON.parse(JSON.stringify(component.get("v.values")));
        var mapOfselectedApproversIdAndName = component.get("v.mapOfSetUpKey_MarkupAttibute");
        //   alert('1234 '+JSON.stringify(component.get("v.dropDownOptionsForLocation")));
        if(!$A.util.isUndefinedOrNull(mapOfselectedApproversIdAndName)){
            var nameArray = [];
            let existingData = component.get("v.dropDownSelectedValueToName");
            let mapOfData = {};
            let toDelRecords = component.get("v.toDelRecords");
            for(let obj in existingData){
                mapOfData[existingData[obj].selectedUserId] =  existingData[obj];
                if(!selectedApprovers.includes(existingData[obj].selectedUserId)){
                    toDelRecords.push(existingData[obj].selectedUserId);  
                }
            }
              component.set("v.toDelRecords",toDelRecords); 
            for(let rec in selectedApprovers){
                if(mapOfData.hasOwnProperty(selectedApprovers[rec])){
                    let singleInstance = mapOfData[selectedApprovers[rec]];
                    nameArray.push(
                        {'selectedLocations':singleInstance.selectedLocations,
                         'locationOptions' : JSON.parse(JSON.stringify(component.get("v.dropDownOptionsForLocation"))),
                         'selectedUser' : singleInstance.selectedUser,
                         'selectedUserId' : singleInstance.selectedUserId,
                         'searchString_Location' : singleInstance.searchString_Location,
                         'enableAbility' : singleInstance.enableAbility}
                    );   
                }
                else {
                  
                    nameArray.push(
                        {'selectedLocations':[],
                         'locationOptions' : JSON.parse(JSON.stringify(component.get("v.dropDownOptionsForLocation"))),
                         'selectedUser' : mapOfselectedApproversIdAndName[selectedApprovers[rec]],
                         'selectedUserId' : selectedApprovers[rec],
                         'searchString_Location' : '',
                         'enableAbility' : false,}
                    );
                }
            }
            if(nameArray.length==0){
                 component.set("v.enableSaveButton",false);
            }
            else {
               component.set("v.enableSaveButton",true);  
            }
            component.set("v.dropDownSelectedValueToName",nameArray);
            console.log('dropDownSelectedValueToName ***  '+JSON.stringify(component.get("v.dropDownSelectedValueToName"))); 
            
            
        }
    },
    
    removePillHelper : function(component, event) {
        var value = event.getSource().get('v.name');
        var multiSelect = component.get('v.multiSelect');
        var count = 0;
        var options = component.get("v.options");
        var values = component.get('v.values') || [];
        options.forEach( function(element, index) {
            if(element.value === value) {
                element.selected = false;
                values.splice(values.indexOf(element.value), 1);
            }
            if(element.selected) {
                count++;
            }
        });
        if(multiSelect)
            component.set('v.searchString', count + ' options selected');
        component.set('v.values', values)
        component.set("v.options", options);
        if(count == 0){
            component.set('v.searchString', 'Select an option');
        }
        var len =  component.get('v.values');
        if(len.length<5){
            var optnLst = component.get('v.options'); 
            for(let rec in optnLst){
                optnLst[rec]['disabled'] = false;
            }
            component.set('v.options',optnLst); 
            
        }
        if(count>0){
            component.set("v.isSetUpKeySelected",true);
        }
        else {
            component.set("v.isSetUpKeySelected",false);
        }
    },
    
    blurEventHelper : function(component, event) {
        var selectedValue = component.get('v.value');
        var multiSelect = component.get('v.multiSelect');
        var previousLabel;
        var count = 0;
        var options = component.get("v.options");
        options.forEach( function(element, index) {
            if(element.value === selectedValue) {
                previousLabel = element.label;
            }
            if(element.selected) {
                count++;
            }
        });
        if(multiSelect)
            component.set('v.searchString', count + ' options selected');
        else
            component.set('v.searchString', previousLabel);
        
        if(multiSelect)
            //   $A.util.removeClass(component.find('resultsDiv'),'slds-is-open');
            if(count>0){
                component.set("v.isSetUpKeySelected",true);
            }
            else {
                component.set("v.isSetUpKeySelected",false);
            }
        
        if(count == 0){
            component.set('v.searchString', 'Select an option');
        }
    }
})
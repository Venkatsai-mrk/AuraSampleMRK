({
    helperMethod : function(component, event, helper) {
        let approvalLevelValues = {'approver' : '','approverList' : []}; 
        component.set("v.approvalLevelValues",approvalLevelValues);
        component.set("v.loaded",false);
        
        console.log('setupKeySelected is  '+JSON.stringify(component.get("v.setupKeySelected")));
        var action = component.get('c.fetchExistingLocationRecordForGivenEntity');        
        action.setParams({
            "approvalLevel": component.get("v.index"),
            "formName" : component.get("v.formName"),
            "entityName" : component.get("v.setupKeySelected")
        });        
        action.setCallback(this, function(response) { 
            var state = response.getState();
            if (state === "SUCCESS") {
                if(component.get("v.setupKeySelected")=='Profile'){
                    helper.populateScreenForProfile(component,event,helper,response.getReturnValue());
                }
                else if(component.get("v.setupKeySelected")=='User'){
                    helper.populateScreenForUser(component,event,helper,response.getReturnValue());
                }
                    else if(component.get("v.setupKeySelected")=='Role'){
                        helper.populateScreenForRole(component,event,helper,response.getReturnValue()); 
                    }
                component.set("v.loaded",true);
                
                console.log('All Setup Key '+JSON.stringify(response.getReturnValue()));
                
            }
            else if (state === "ERROR") {
                component.find("Id_spinner").set("v.class" , 'slds-hide');
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }                
            }
            
        });
        $A.enqueueAction(action);
    },
    populateScreenForRole : function(component, event, helper,serverResp){
        if(!$A.util.isEmpty(serverResp.allUserLocRecord)){
            var record  = serverResp.allUserLocRecord;
            var approvalTree =  component.get("v.approvalLevelValues");
            component.set("v.recordID",record[0].Id);
            /*****************CREATE MAP OF SETUP KEY ***********************/
            var mapOfsetUp = {};
            var allValues = serverResp.setkeyMap;
            if(!$A.util.isUndefinedOrNull(allValues)){
                for (var i = 0; i < allValues.length; i++) {
                    mapOfsetUp[allValues[i].Id] = allValues[i].Name;                            
                }
            }
            
            component.set("v.mapOfSetUpKey_MarkupAttibute", mapOfsetUp);                        
            
            
            var opts= [];
            var allValues = JSON.parse(serverResp.allUserLocRecord[0].ElixirSuite__Dropdown_Options__c);
            var count = 0;
            var dropDownSelectedValues = [];
            var isDisabled = false;
            var allApproverMembers = [];
            let allresult = serverResp.allUserLocRecord;
            for(let rec in allresult){
                allApproverMembers.push(allresult[rec].ElixirSuite__Role__c);
            }
            /* if(allApproverMembers.length==5){
                isDisabled = true;
            }*/
            if(allApproverMembers.length>=1){
                component.set("v.isSetUpKeySelected",true);
            }
            for (var i = 0; i < allValues.length; i++) {
                if(allApproverMembers.includes(allValues[i].value)){
                    count++;
                    opts.push({'label':allValues[i].label,'value' : allValues[i].value,'selected' : true,
                               'disabled' :isDisabled });
                    dropDownSelectedValues.push(allValues[i].value);
                }
                else {
                    opts.push({'label':allValues[i].label,'value' : allValues[i].value,'selected' : false,
                               'disabled' :isDisabled});
                }
            }
            component.set("v.dropDownSelectedValues", dropDownSelectedValues);
            component.set("v.dropDownOptions", opts);
            component.set('v.searchString', count + ' options selected');
            console.log('mpl options set'+ JSON.stringify(component.get("v.dropDownOptions")));		
            component.set("v.approvalLevelValues", approvalTree);
            component.set("v.isdisAbled", true);
            component.set("v.isApprovalLevelAdded", true); 
            component.set("v.enableEditpencilIcon", true);
            component.set("v.enableSaveButton", false);
            
            try{
                helper.arrangevaluesForLocationPerRole(component, event, helper,serverResp.allUserLocRecord,
                                                       serverResp.allProvider);
            }
            catch(e){
                alert('error '+e);
            }
            
        } 
    },
    populateScreenForProfile : function(component, event, helper,serverResp){
        if(!$A.util.isEmpty(serverResp.allUserLocRecord)){
            var record  = serverResp.allUserLocRecord;
            var approvalTree =  component.get("v.approvalLevelValues");
            component.set("v.recordID",record[0].Id);
            /*****************CREATE MAP OF SETUP KEY ***********************/
            var mapOfsetUp = {};
            var allValues = serverResp.setkeyMap;
            if(!$A.util.isUndefinedOrNull(allValues)){
                for (var i = 0; i < allValues.length; i++) {
                    mapOfsetUp[allValues[i].Id] = allValues[i].Name;                            
                }
            }
            
            component.set("v.mapOfSetUpKey_MarkupAttibute", mapOfsetUp);                        
            
            
            var opts= [];
            var allValues = JSON.parse(serverResp.allUserLocRecord[0].ElixirSuite__Dropdown_Options__c);
            var count = 0;
            var dropDownSelectedValues = [];
            var isDisabled = false;
            var allApproverMembers = [];
            let allresult = serverResp.allUserLocRecord;
            for(let rec in allresult){
                allApproverMembers.push(allresult[rec].ElixirSuite__Profile__c);
            }
            /* if(allApproverMembers.length==5){
                isDisabled = true;
            }*/
            if(allApproverMembers.length>=1){
                component.set("v.isSetUpKeySelected",true);
            }
            for (var i = 0; i < allValues.length; i++) {
                if(allApproverMembers.includes(allValues[i].value)){
                    count++;
                    opts.push({'label':allValues[i].label,'value' : allValues[i].value,'selected' : true,
                               'disabled' :isDisabled });
                    dropDownSelectedValues.push(allValues[i].value);
                }
                else {
                    opts.push({'label':allValues[i].label,'value' : allValues[i].value,'selected' : false,
                               'disabled' :isDisabled});
                }
            }
            component.set("v.dropDownSelectedValues", dropDownSelectedValues);
            component.set("v.dropDownOptions", opts);
            component.set('v.searchString', count + ' options selected');
            console.log('PARENT dropDownOptions'+ JSON.stringify(component.get("v.dropDownOptions")));		
            component.set("v.approvalLevelValues", approvalTree);
            component.set("v.isdisAbled", true);
            component.set("v.isApprovalLevelAdded", true); 
            component.set("v.enableEditpencilIcon", true);
            component.set("v.enableSaveButton", false);
            
            try{
                helper.arrangevaluesForLocationPerProfile(component, event, helper,serverResp.allUserLocRecord,
                                                          serverResp.allProvider);
            }
            catch(e){
                alert('error '+e);
            }
          
        } 
        /* else {
            helper.fetchDropdownValues(component);
            component.set('v.searchString', '');
           
        }*/
    },
    populateScreenForUser : function(component, event, helper,serverResp){
        if(!$A.util.isEmpty(serverResp.allUserLocRecord)){
            var record  = serverResp.allUserLocRecord;
            var approvalTree =  component.get("v.approvalLevelValues");
            component.set("v.recordID",record[0].Id);
            /*****************CREATE MAP OF SETUP KEY ***********************/
            var mapOfsetUp = {};
            var allValues = serverResp.setkeyMap;
            if(!$A.util.isUndefinedOrNull(allValues)){
                for (var i = 0; i < allValues.length; i++) {
                    mapOfsetUp[allValues[i].Id] = allValues[i].Name;                            
                }
            }
            
            component.set("v.mapOfSetUpKey_MarkupAttibute", mapOfsetUp);                        
            
            
            var opts= [];
            var allValues = JSON.parse(serverResp.allUserLocRecord[0].ElixirSuite__Dropdown_Options__c);
            var count = 0;
            var dropDownSelectedValues = [];
            var isDisabled = false;
            var allApproverMembers = [];
            let allresult = serverResp.allUserLocRecord;
            for(let rec in allresult){
                allApproverMembers.push(allresult[rec].ElixirSuite__User__c);
            }
            /* if(allApproverMembers.length==5){
                isDisabled = true;
            }*/
            if(allApproverMembers.length>=1){
                component.set("v.isSetUpKeySelected",true);
            }
            for (var i = 0; i < allValues.length; i++) {
                if(allApproverMembers.includes(allValues[i].value)){
                    count++;
                    opts.push({'label':allValues[i].label,'value' : allValues[i].value,'selected' : true,
                               'disabled' :isDisabled });
                    dropDownSelectedValues.push(allValues[i].value);
                }
                else {
                    opts.push({'label':allValues[i].label,'value' : allValues[i].value,'selected' : false,
                               'disabled' :isDisabled});
                }
            }
            component.set("v.dropDownSelectedValues", dropDownSelectedValues);
            component.set("v.dropDownOptions", opts);
            component.set('v.searchString', count + ' options selected');
            console.log('mpl options set'+ JSON.stringify(component.get("v.dropDownOptions")));		
            component.set("v.approvalLevelValues", approvalTree);
            component.set("v.isdisAbled", true);
            component.set("v.isApprovalLevelAdded", true); 
            component.set("v.enableEditpencilIcon", true);
            component.set("v.enableSaveButton", false);
            
            try{
                helper.arrangevaluesForLocationPerUser(component, event, helper,serverResp.allUserLocRecord,
                                                       serverResp.allProvider);
            }
            catch(e){
                alert('error '+e);
            }
           
        }
    },
    arrangeProviderAsSelectSkeleton : function(component, event, helper,toArrangeData) {
        let arr = [];
        for(let rec in toArrangeData){
            let obj = {'label' : toArrangeData[rec].Name,
                       'value' : toArrangeData[rec].Id,
                       'isVisible' : true,
                       'disabled' : false};
            arr.push(obj);
        }
        return arr;
    },
    arrangevaluesForLocationPerRole : function(component, event, helper,serverResp,allProvider) {
        console.log('allProvider '+JSON.stringify(allProvider));
        console.log('serverResp '+JSON.stringify(serverResp));
        let mapOfSetUpKey_MarkupAttibute = component.get("v.mapOfSetUpKey_MarkupAttibute");
        let mapOfProviderAndLocation = {};
        for(let rec in serverResp){
            if(mapOfProviderAndLocation.hasOwnProperty(serverResp[rec].ElixirSuite__Role__c)){
                if(!mapOfProviderAndLocation[serverResp[rec].ElixirSuite__Role__c].includes(serverResp[rec].ElixirSuite__Provider__c)){
                    mapOfProviderAndLocation[serverResp[rec].ElixirSuite__Role__c].push(serverResp[rec].ElixirSuite__Provider__c);
                }
            }
            else {
                mapOfProviderAndLocation[serverResp[rec].ElixirSuite__Role__c] = [];
                mapOfProviderAndLocation[serverResp[rec].ElixirSuite__Role__c].push(serverResp[rec].ElixirSuite__Provider__c);
            }
            
        }
        
        
        let locationArray = [];
        for(let rec in mapOfProviderAndLocation){
            console.log('loop mapOfProviderAndLocation '+JSON.stringify(mapOfProviderAndLocation[rec]));
            let objInstance = {'selectedLocations':mapOfProviderAndLocation[rec],
                               'locationOptions' : helper.arrangeProviderAsSelectSkeleton(component, event, helper,allProvider),
                               'selectedUser' : mapOfSetUpKey_MarkupAttibute[rec],
                               'selectedUserId' : rec,
                               'searchString_Location' : mapOfProviderAndLocation[rec].length + ' options selected',
                               'enableAbility' : true,
                              };
             console.log('objInstance  '+JSON.stringify(objInstance));
            locationArray.push(objInstance);
        }
        console.log('locationArray '+JSON.stringify(locationArray));
        component.set("v.dropDownSelectedValueToName",locationArray);
        component.set("v.closeForce",true);
        console.log('mapOfProviderAndLocation '+JSON.stringify(mapOfProviderAndLocation));
       
    },
    arrangevaluesForLocationPerProfile : function(component, event, helper,serverResp,allProvider) {
        console.log('allProvider '+JSON.stringify(allProvider));
        console.log('serverResp '+JSON.stringify(serverResp));
        let mapOfSetUpKey_MarkupAttibute = component.get("v.mapOfSetUpKey_MarkupAttibute");
        let mapOfProviderAndLocation = {};
        for(let rec in serverResp){
            if(mapOfProviderAndLocation.hasOwnProperty(serverResp[rec].ElixirSuite__Profile__c)){
                if(!mapOfProviderAndLocation[serverResp[rec].ElixirSuite__Profile__c].includes(serverResp[rec].ElixirSuite__Provider__c)){
                    mapOfProviderAndLocation[serverResp[rec].ElixirSuite__Profile__c].push(serverResp[rec].ElixirSuite__Provider__c);   
                }
                
            }
            else {
                mapOfProviderAndLocation[serverResp[rec].ElixirSuite__Profile__c] = [];
                mapOfProviderAndLocation[serverResp[rec].ElixirSuite__Profile__c].push(serverResp[rec].ElixirSuite__Provider__c);
            }
            
        }
        
        
        let locationArray = [];
        for(let rec in mapOfProviderAndLocation){
            console.log('loop mapOfProviderAndLocation '+JSON.stringify(mapOfProviderAndLocation[rec]));
            let objInstance = {'selectedLocations':mapOfProviderAndLocation[rec],
                               'locationOptions' : helper.arrangeProviderAsSelectSkeleton(component, event, helper,allProvider),
                               'selectedUser' : mapOfSetUpKey_MarkupAttibute[rec],
                               'selectedUserId' : rec,
                               'searchString_Location' : mapOfProviderAndLocation[rec].length + ' options selected',
                               'enableAbility' : true,
                              };
            
            locationArray.push(objInstance);
        }
        console.log('locationArray '+JSON.stringify(locationArray));
        component.set("v.dropDownSelectedValueToName",locationArray);
        component.set("v.closeForce",true);
        console.log('mapOfProviderAndLocation '+JSON.stringify(mapOfProviderAndLocation));
        
    },
    arrangevaluesForLocationPerUser: function(component, event, helper,serverResp,allProvider) {
        
        console.log('allProvider '+JSON.stringify(allProvider));
        console.log('serverResp '+JSON.stringify(serverResp));
        let mapOfSetUpKey_MarkupAttibute = component.get("v.mapOfSetUpKey_MarkupAttibute");
        let mapOfProviderAndLocation = {};
        for(let rec in serverResp){
            if(mapOfProviderAndLocation.hasOwnProperty(serverResp[rec].ElixirSuite__User__c)){
                mapOfProviderAndLocation[serverResp[rec].ElixirSuite__User__c].push(serverResp[rec].ElixirSuite__Provider__c);
            }
            else {
                mapOfProviderAndLocation[serverResp[rec].ElixirSuite__User__c] = [];
                mapOfProviderAndLocation[serverResp[rec].ElixirSuite__User__c].push(serverResp[rec].ElixirSuite__Provider__c);
            }
            
        }
        
        
        let locationArray = [];
        for(let rec in mapOfProviderAndLocation){
            console.log('loop mapOfProviderAndLocation '+JSON.stringify(mapOfProviderAndLocation[rec]));
            let objInstance = {'selectedLocations':mapOfProviderAndLocation[rec],
                               'locationOptions' : helper.arrangeProviderAsSelectSkeleton(component, event, helper,allProvider),
                               'selectedUser' : mapOfSetUpKey_MarkupAttibute[rec],
                               'selectedUserId' : rec,
                               'searchString_Location' : mapOfProviderAndLocation[rec].length + ' options selected',
                               'enableAbility' : true,
                              };
 			console.log('objInstance '+JSON.stringify(objInstance));
            locationArray.push(objInstance);
        }
        console.log('locationArray '+JSON.stringify(locationArray));
        component.set("v.dropDownSelectedValueToName",locationArray);
        component.set("v.closeForce",true);
        console.log('mapOfProviderAndLocation '+JSON.stringify(mapOfProviderAndLocation));
        
    },
    buildAttributeWrapper : function(component, event, helper) {
        let mapOfSetUpKey = {'User' : 'allUsers', 'Role':'allUserRoles','Profile':'allProfiles'};
        
        let masterTree = {'lstOfUser' : [], 'isUserSelected' : true,
                          'lstOfProfile' : [],'isProfileSelected' : false,
                          'lstofRole' : [],'isRoleSelected' : false,
                          'lstOfPatient' : 'Patient' , 'isPatientselected' : false,
                          'setupKeyMap' : mapOfSetUpKey};
        
        component.set("v.setupKeyWrapper",masterTree);
        
        
        
    },
    arrangelevaluesForSetupKey : function(component, event, helper,resp,setupKey) {
        var masterTree = component.get("v.setupKeyWrapper");
        switch (setupKey) {
            case 'User':
                
                masterTree.lstOfUser = resp.allUsers;
                masterTree.isUserSelected = true; 
                component.set("v.isSetUpKeySelected",false);
                break;
                
            case 'Role':
                
                masterTree.lstofRole = resp.allUserRoles;
                masterTree.isRoleSelected = true;
                component.set("v.isSetUpKeySelected",false);
                break;
                
            case 'Profile' : 
                
                masterTree.lstOfProfile = resp.allProfiles;
                masterTree.isProfileSelected = true;
                component.set("v.isSetUpKeySelected",false);
                break;
            case 'Patient' : 
                masterTree.isPatientselected = true;
                masterTree.lstOfPatient = 'Patient';
                var forPatient = component.get("v.dropDownSelectedValues");
                forPatient.push('Patient');
                component.set("v.dropDownSelectedValues",forPatient);
                component.set("v.isSetUpKeySelected",true);
                break;
        }
        component.set("v.setupKeyWrapper",masterTree);
    },
    fetchDropdownValues :  function(component){
        var param = component.get("v.setupKeySelected");
        var masterTree = component.get("v.setupKeyWrapper").setupKeyMap;
        var setupKey = component.get('v.setupKeyWrapper');
        var action = component.get( 'c.fetchOptions_SetupKey' );
        component.set("v.loaded",false);
        
        action.setParams({
            "setUpKey": param
        });
        
        action.setCallback(this, function(response) { 
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.loaded",true);
                console.log('mpl options '+JSON.stringify(response.getReturnValue()));
                console.log('mpl options set'+ JSON.stringify(response.getReturnValue()[masterTree[param]]));	
                component.set("v.mapOfSetUpKey_MarkupAttibute", response.getReturnValue()[masterTree[param]]);
                var opts = [];
                var mapOfsetUp = {};
                var allValues = response.getReturnValue()[masterTree[param]];
                for (var i = 0; i < allValues.length; i++) {
                    mapOfsetUp[allValues[i].Id] = allValues[i].Name;
                    opts.push({'label':allValues[i].Name,'value' : allValues[i].Id});
                }
                component.set("v.mapOfSetUpKey_MarkupAttibute", mapOfsetUp);
                component.set("v.dropDownOptions", opts);
                console.log('mpl options set'+ JSON.stringify(component.get("v.dropDownOptions")));		 
                /********FETCH LOCATION/PROVIDER SET*************/
                let allProviderValues = response.getReturnValue().allProvider;
                let opts_Location = [];
                for (var i = 0; i < allProviderValues.length; i++) {
                    mapOfsetUp[allProviderValues[i].Id] = allProviderValues[i].Name;
                    opts_Location.push({'label':allProviderValues[i].Name,'value' : allProviderValues[i].Id});
                }
                
                component.set("v.dropDownOptionsForLocation", opts_Location);
                console.log('dropDownOptionsForLocation '+ JSON.stringify(component.get("v.dropDownOptionsForLocation")));		
                
            } 
            else if (state === "ERROR") {
                //  component.find("Id_spinner").set("v.class" , 'slds-hide');
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
                
                
            }
            
        });
        $A.enqueueAction(action);
    },
    setSetupKeyName : function(component, event, helper) {
        var selectedApprovers = JSON.parse(JSON.stringify(component.get("v.dropDownSelectedValues")));
        var mapOfselectedApproversIdAndName = component.get("v.mapOfSetUpKey_MarkupAttibute");
        if(selectedApprovers.includes('Patient')){
            mapOfselectedApproversIdAndName = null;
        }
        if(!$A.util.isUndefinedOrNull(mapOfselectedApproversIdAndName)){
            var nameArray = [];
            for(let rec in selectedApprovers){
                nameArray.push(mapOfselectedApproversIdAndName[selectedApprovers[rec]]);
            }
            component.set("v.dropDownSelectedValueToName",nameArray);
            console.log('name array  '+nameArray); 
        }
        else {
            let patientName =  [];
            patientName.push('Patient');
            component.set("v.dropDownSelectedValueToName",patientName);
        }
    },
    
    setUpKeyNotSelected : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": component.get("v.setupKeySelected") +" IS MANDATORY",
            "message": "Please select "+ component.get("v.setupKeySelected") +" first",
            "type" : "error"
        });
        toastEvent.fire();
    },
    validateEmptyUser_Location : function(component, event, helper) {
        var obj = {'flag' : true,
                   'nameOfKey' : ''};
        let toSaveData  = component.get("v.dropDownSelectedValueToName")
        for(let rec in toSaveData){
            if($A.util.isEmpty(toSaveData[rec].selectedLocations)){
                obj.flag = false;
                obj.nameOfKey = toSaveData[rec].selectedUser;
                break;
            }
        }
        return obj; 
    },
    locationNotSelected : function(component, event, helper,obj) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "LOCATION NOT SELECTED FOR "+obj.nameOfKey,
            "message": "Please select location for "+obj.nameOfKey+"!",
            "type" : "error"
        });
        toastEvent.fire();
    },
})
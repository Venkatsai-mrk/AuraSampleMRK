({
    helperMethod : function(component, event, helper) {
        let approvalLevelValues = {'approver' : '','approverList' : []}; 
        component.set("v.approvalLevelValues",approvalLevelValues);
        component.set("v.loaded",false);
        
        console.log('setupKeySelected is  '+JSON.stringify(component.get("v.setupKeySelected")));
        var action = component.get('c.fetchExistingLocationRecordForGivenEntity');        
        action.setParams({
            "entityName" : component.get("v.setupKeySelected")
        });        
        action.setCallback(this, function(response) { 
            var state = response.getState();
            if (state === "SUCCESS") {
                    if(component.get("v.setupKeySelected")=='Account'){
                        helper.populateScreenForAccount(component,event,helper,response.getReturnValue());
                    }
                    else if(component.get("v.setupKeySelected")=='Opportunity'){ // Do retrival of Opportunity here
                        helper.populateScreenForUser(component,event,helper,response.getReturnValue());
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
    
    populateScreenForAccount : function(component, event, helper,serverResp){
       // if(!$A.util.isEmpty(serverResp.allpatientTileRecord)){
            var allDropdownValues = component.get("v.dropDownOptions"); 
            
            var allValues = serverResp.allpatientTileRecord;
             console.log('allValues'+ JSON.stringify(allValues));
            let objArr = [];
            let opts = [];
             // objArr.push('Name');
            // objArr.push('ElixirSuite__Last_Name__c');
         /*   objArr.push('ElixirSuite__Profile_Picture__c');
            objArr.push('ElixirSuite__Patient_s_Birth_Date__c'); */
            objArr.push('ElixirSuite__Age__c');
            objArr.push('ElixirSuite__MRN_Number_New__c');
            objArr.push('ElixirSuite__Gender__c');
            
        

        
            let mapOfOrder = {};
            for(let rec in allValues){
                objArr.push(allValues[rec].ElixirSuite__Field_Api__c);
                mapOfOrder[allValues[rec].ElixirSuite__Field_Api__c] = allValues[rec].ElixirSuite__Patient_Tile_Order__c
            }
            var selectedOptions = [];
            for(let rec in allDropdownValues){
                if(objArr.includes(allDropdownValues[rec].value)){
                    selectedOptions.push(allDropdownValues[rec].value);
                }
                opts.push({'label' : allDropdownValues[rec],'value':rec});
            }
            let forSortArr = [];
            for(let rec in selectedOptions){
                let sObj = {'value' :selectedOptions[rec],'order' : mapOfOrder[selectedOptions[rec]]}
                forSortArr.push(sObj); 
            }
            forSortArr.push({'value' :'Name','order' : 0});
            forSortArr.sort(function(a, b) {
                return parseFloat(a.order) - parseFloat(b.order);
            });
            selectedOptions = [];
            for(let sObj in forSortArr){
                selectedOptions.push(forSortArr[sObj].value);
            }
            component.set("v.selectedOptions", selectedOptions);
            
            console.log('selectedOptions'+ JSON.stringify(component.get("v.selectedOptions")));
            // component.set("v.dropDownOptions", opts);
            console.log('PARENT dropDownOptions'+ JSON.stringify(component.get("v.dropDownOptions")));		
            console.log('PARENT selected options'+ JSON.stringify(component.get("v.selectedGenreList")));		
            
            
            
            console.log('PARENT dropDownOptions'+ JSON.stringify(component.get("v.dropDownOptions")));		
            // component.set("v.approvalLevelValues", approvalTree);
            component.set("v.isdisAbled", true);
            component.set("v.isApprovalLevelAdded", true); 
            component.set("v.enableEditpencilIcon", true);
            component.set("v.enableSaveButton", false);
            component.set("v.enableAbility", true);
            
            
            
       /* }
        else{
            component.set("v.isdisAbled", true);
            component.set("v.isApprovalLevelAdded", true); 
            component.set("v.enableEditpencilIcon", true);
            component.set("v.enableSaveButton", false);
            component.set("v.enableAbility", true);
        }*/
        
    },
    populateScreenForUser : function(component, event, helper,serverResp){
      //  if(!$A.util.isEmpty(serverResp.allUserLocRecord)){
            // Venkat
             var allDropdownValues = component.get("v.dropDownOptions");
            var record  = serverResp.allUserLocRecord;
              console.log('record'+ JSON.stringify(record));
             let objArr = [];
            let optss = [];
            // objArr.push('Name');
            /*objArr.push('ElixirSuite__Profile_Picture__c');
            objArr.push('ElixirSuite__Patient_s_DOB__c');*/
        objArr.push('ElixirSuite__Gender__c');
            let mapOfOrder = {};
            for(let rec in record){
                objArr.push(record[rec].ElixirSuite__Field_Api__c);
                mapOfOrder[record[rec].ElixirSuite__Field_Api__c] = record[rec].ElixirSuite__Patient_Tile_Order__c
            }
            var selectedOptions = [];
            for(let rec in allDropdownValues){
                if(objArr.includes(allDropdownValues[rec].value)){
                    selectedOptions.push(allDropdownValues[rec].value);
                }
                optss.push({'label' : allDropdownValues[rec],'value':rec});
            }
            let forSortArr = [];
            for(let rec in selectedOptions){
                let sObj = {'value' :selectedOptions[rec],'order' : mapOfOrder[selectedOptions[rec]]}
                forSortArr.push(sObj); 
            }
            forSortArr.push({'value' :'Name','order' : 9000});
            forSortArr.sort(function(a, b) {
                return parseFloat(a.order) - parseFloat(b.order);
            });
             selectedOptions = [];
            for(let sObj in forSortArr){
                selectedOptions.push(forSortArr[sObj].value);
            }
             console.log('selectedOptions&&&&&'+ JSON.stringify(selectedOptions));
            component.set("v.selectedOptions", selectedOptions);
            
             component.set("v.isdisAbled", true);
            component.set("v.isApprovalLevelAdded", true); 
            component.set("v.enableEditpencilIcon", true);
            component.set("v.enableSaveButton", false);
            component.set("v.enableAbility", true);
             component.set("v.loaded",true);
           var approvalTree =  component.get("v.approvalLevelValues");
             console.log('approvalTree'+ JSON.stringify(approvalTree));
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
           
            try{
                helper.arrangevaluesForLocationPerUser(component, event, helper,serverResp.allUserLocRecord,serverResp.allProvider);
            }
            catch(e){
                alert('error '+e);
            }
            
      /*  } else{
            component.set("v.isdisAbled", true);
            component.set("v.isApprovalLevelAdded", true); 
            component.set("v.enableEditpencilIcon", true);
            component.set("v.enableSaveButton", false);
            component.set("v.enableAbility", true);
        }*/
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
            
            locationArray.push(objInstance);
        }
        console.log('locationArray '+JSON.stringify(locationArray));
        component.set("v.dropDownSelectedValueToName",locationArray);
        component.set("v.closeForce",true);
        console.log('mapOfProviderAndLocation '+JSON.stringify(mapOfProviderAndLocation));
        
    },
    buildAttributeWrapper : function(component, event, helper) {
        let mapOfSetUpKey = {'User' : 'allUsers', 'Role':'allUserRoles','Profile':'allProfiles'};
        
        let masterTree = {'lstOfUser' : [], 'isUserSelected' : true, // Account
                          'lstOfProfile' : [],'isProfileSelected' : false, // Can be used as Opportunity
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
                
                
                var opts = [];
                var mapOfsetUp = {};
                var allValues = response.getReturnValue().labelApiMapForSelectedEntity;
                component.set("v.labelApiMapForSelectedEntity",JSON.parse(JSON.stringify(allValues)));
                let objArr = [];
                // objArr.push('ElixirSuite__Patient_s_Birth_Date__c');
                objArr.push('ElixirSuite__MRN_Number__c');
                // objArr.push('ElixirSuite__Age__c');
                //  objArr.push('ElixirSuite__Gender__c');
                objArr.push('Id');
                objArr.push('Name');
                objArr.push('ElixirSuite__Treatment_Center__c');
                objArr.push('ElixirSuite__House__c');
                objArr.push('ElixirSuite__Rooms__c');
                for(let rec in allValues){
                    if(!objArr.includes(rec)){
                        opts.push({'label':allValues[rec],'value' : rec,'entity' :param });
                    }
                }
                
                component.set("v.dropDownOptions", opts);
                
                
                
                console.log('mpl options set'+ JSON.stringify(component.get("v.dropDownOptions")));		 
                /********FETCH LOCATION/PROVIDER SET*************/
                
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
    setDefaultSelectedValue :   function(component, event, helper) {
        
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
        let flag = true;
        if($A.util.isEmpty(component.get("v.selectedOptions"))){
            flag = false;
        }
        return flag; 
        
    },
    satSaveValues :  function(component, event, helper,obj) {
    },
    locationNotSelected : function(component, event, helper,obj) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "NO FIELD SELECTED!",
            "message": "Please select field!",
            "type" : "error"
        });
        toastEvent.fire();
    },
    arrangeApiAndLabel : function(component, event, helper) {
        let arr = component.get("v.selectedOptions");
        let labelApiMapForSelectedEntity =  component.get("v.labelApiMapForSelectedEntity");
        let toSaveArr = [];
        let index = 0;
        for(let key in arr){
            toSaveArr.push({'label' : labelApiMapForSelectedEntity[arr[key]],
                            'order' : index,
                            'value' : arr[key]});
            index++;
        }
        if(toSaveArr.length<1){
             var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Mandatory fields can not be removed!",
            "message": " ",
            "type" : "error"
        });
        toastEvent.fire();
        }
        console.log('BUILD SUCESS '+JSON.stringify(toSaveArr));
        return toSaveArr;
    }
})
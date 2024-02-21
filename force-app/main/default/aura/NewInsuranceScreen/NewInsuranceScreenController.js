({
    doInit: function(component, event, helper) {
		
        var base_url = window.location.origin;
        
        console.log('base_url****',base_url);
        
       // console.log('app type**',sforce.console.isInConsole());
        
        var pageRef = component.get("v.pageReference");

        console.log('pageref',JSON.stringify(pageRef));

        var state = pageRef.state; // state holds any query params

        console.log('state = '+JSON.stringify(state));

        var base64Context = state.inContextOfRef;

        console.log('base64Context = '+base64Context);

        if (base64Context.startsWith("1\.")) {

            base64Context = base64Context.substring(2);

            console.log('base64Context = '+base64Context);

        }

        var addressableContext = JSON.parse(window.atob(base64Context));

        console.log('addressableContext = '+JSON.stringify(addressableContext));

         if(addressableContext.type==="standard__component"){

            component.set("v.recordId", addressableContext.state.force__recordId)

        }

        else if(addressableContext.type==="standard__recordPage" || addressableContext.type==="standard__recordRelationshipPage"){

            component.set("v.recordId", addressableContext.attributes.recordId)

        }

         console.log("recordId insurance page ref*** "+component.get("v.recordId"));
        
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            var issubTab = response.isSubtab;
             console.log('tabId***',focusedTabId);
            if(issubTab)
            {
                workspaceAPI.getTabInfo(
                    { tabId:focusedTabId}
                ).then(function(response1){
                    
                });
                workspaceAPI.setTabLabel({
                    
                    label: "New Insurance"
                });                
            }
            else 
            { 
                workspaceAPI.getTabInfo({ tabId:response.subtabs[0].tabId}).then(function(response1){                 
                    //  console.log('afctabinfo',response1);
                });
                workspaceAPI.setTabLabel({
                    label: "New Insurance"
                });         
            }     
            workspaceAPI.setTabIcon({
                tabId: focusedTabId,
                icon: "utility:collection_alt",
                iconAlt: "New Insurance"
            });
        })

		        
        var action = component.get("c.getRecordTypeValues");
        action.setParams({'accId' : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var recordTypes = result.insuranceRecordTypes;
                var accRec = result.accountRec;
                
                 workspaceAPI.isConsoleNavigation().then(function(response) {
            console.log('app type**',response);
                     component.set("v.isConsoleApp",response);
        })
                
                if(accRec){
                console.log('accRec****',accRec);
        console.log('accRec****phone',accRec.Phone);
        console.log('accRec****dob',accRec.ElixirSuite__DOB__c);
                
                component.set("v.accountRecord",result.accountRec);
            }
                var recordtypeMap = [];
                for(var key in recordTypes){
                    recordtypeMap.push({label: recordTypes[key], value: key});
                }
                component.set("v.recordTypeMap", recordtypeMap);
                component.set("v.selectedRecordTypeId", result.defaultRecordTypeId);
            }
        });
        $A.enqueueAction(action);
    },
    
    handleCancel: function(component, event, helper) {
        
        var isConsole = component.get("v.isConsoleApp");
        console.log('isConsole***',isConsole);
        
        
        if(isConsole){
              // Close the current subtab
        
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getEnclosingTabId().then(function(tabId) {
            workspaceAPI.closeTab({tabId: tabId});
        });
    }
        else{
            helper.navToListView(component, event, helper);//added by Anmol
        }
        
    },
     
    handleCreateRecord: function(component, event, helper) { 
        var selectedRecordTypeId = component.get("v.selectedRecordTypeId");
        var accRec = component.get("v.accountRecord");
        console.log('accRec****',accRec);
        console.log('accRec****phone',accRec.Phone);
        console.log('accRec****dob',accRec.ElixirSuite__DOB__c);
        if(accRec){
        if(selectedRecordTypeId){
            var createRecordEvent = $A.get("e.force:createRecord");
            var patientAddress = '';
            if(accRec.BillingStreet != null && accRec.BillingCity != null && accRec.BillingState!=null && accRec.BillingCountry!=null && accRec.BillingPostalCode!=null){
            patientAddress = accRec.BillingStreet +', '+ accRec.BillingCity +', '+ accRec.BillingState+', '+accRec.BillingCountry+', '+accRec.BillingPostalCode;
            }
            createRecordEvent.setParams({
                "entityApiName": 'ElixirSuite__VOB__c',
                "recordTypeId": selectedRecordTypeId,
                "defaultFieldValues": {
                "ElixirSuite__InsPhone__c" : accRec.Phone,
                    "ElixirSuite__Date_Of_Birth__c" : accRec.ElixirSuite__DOB__c,
                    "ElixirSuite__Patient_Relationship_With_Insured__c" : 'Self',
                    "ElixirSuite__Insured_SSN__c" : accRec.ElixirSuite__SSN__c,
                    "ElixirSuite__Insured_First_Name__c" : accRec.ElixirSuite__First_Name__c,
                    "ElixirSuite__Insured_Last_Name__c" : accRec.ElixirSuite__Last_Name__c,
                    "ElixirSuite__Insured_City__c" : accRec.BillingCity,
                    "ElixirSuite__Insured_State__c" : accRec.BillingState,
                    "ElixirSuite__Insured_Country__c" : accRec.BillingCountry,
                    "ElixirSuite__Insured_Zipcode__c" : accRec.BillingPostalCode,
                    "ElixirSuite__Insured_Address__c" : patientAddress,
                    "ElixirSuite__Account__c" : accRec.Id
                    
            },
            });
            createRecordEvent.fire();
        }
    }
        else{
            
            var createRecordEvent = $A.get("e.force:createRecord");
            createRecordEvent.setParams({
                "entityApiName": 'ElixirSuite__VOB__c',
                "recordTypeId": selectedRecordTypeId,
              
            });
            createRecordEvent.fire();
            
        }
    }
})
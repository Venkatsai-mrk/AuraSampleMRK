({
    doInit : function(component, event, helper) {
        helper.setDefaultJSON(component, event, helper);
        helper.initPayload(component, event, helper);
        // helper.locationDetails(component, event, helper);
        console.log('doInit() Finished');
    },
    selectAllRows: function(component, event, helper) {
        var isChecked = event.getSource().get("v.checked");
        var patientProcedureLst = component.get("v.patientProcedureLst");
        
        for (var i = 0; i < patientProcedureLst.length; i++) {
            patientProcedureLst[i].isSelected = isChecked;
        }
        
        component.set("v.patientProcedureLst", patientProcedureLst);
    },
    selectAllDiagnosis: function(component, event, helper) {
        var isChecked = event.getSource().get("v.checked");
        var patientDiagnosisLst = component.get("v.patientDiagnosisLst");
        
        for (var i = 0; i < patientDiagnosisLst.length; i++) {
            patientDiagnosisLst[i].isSelected = isChecked;
        }
        
        component.set("v.patientDiagnosisLst", patientDiagnosisLst);
    },
    parentComponentEvent : function(component, event, helper) {
        console.log('NewRef parentComponentEvent() called ');
        var lookupVal = event.getParam("lookUpData");         
        const str1 = lookupVal;
        
        console.log('startsWith '+str1.startsWith('003'));
        console.log("lookupVal "+lookupVal);
        var contactIdVal = lookupVal;
        if(lookupVal)
        {
            if(str1.startsWith('003'))
            {
                component.set("v.contactId",lookupVal);
                console.log('lookupVal for Contact Id'+lookupVal);                
                var action = component.get("c.contactDetails");       
                action.setParams({
                    "contactId" :  lookupVal 
                });
                action.setCallback(this, function(response){
                    var STATE = response.getState();
                    if(STATE === "SUCCESS") {  
                        
                        var resp =  response.getReturnValue()[0];
                        console.log('Account Lookup in  NewRef Helper - Reffered out Org Account Details '+ JSON.stringify(resp));
                        var accRecord =  component.get("v.referralRecord"); 
                        accRecord.ElixirSuite__Email_Referred_To__c = resp.Email ;
                        accRecord.ElixirSuite__Phone_Referred_To__c = resp.Phone;
                        component.set("v.referredOutOrgName",resp.Name);
                    	component.set("v.contactName",resp.Name);
                        component.set("v.accountName",resp.Name);
                        if($A.util.isUndefinedOrNull(resp.AccountId)){
                            helper.globalFlagToast(component, event, helper,'NO ACCOUNT FOR THIS CONTACT', ' ','error');
                        }
                        
                        if(resp.hasOwnProperty('Account')){
                          component.set("v.accountName",resp.Account.Name);
                      }
                      accRecord.ElixirSuite__Referred_Out_Organization__c = resp.AccountId;
                       // accRecord.ElixirSuite__Referred_Out_Organization__c = resp.Id; // Setting Account of contact
                        accRecord.ElixirSuite__Phone_Referred_To__c = resp.Phone;                                               
                        component.set("v.referralRecord",accRecord); 
                        component.set("v.referralRecord.ElixirSuite__Email_Referred_To__c",resp.Email ); 
                        component.set("v.referralRecord.ElixirSuite__Phone_Referred_To__c",resp.Phone);
                        component.set("v.referralRecord.ElixirSuite__Referred_Out_Organization__c",resp.AccountId ); 
                       
                    }
                    else if (state === "ERROR") {
                        var errors = response.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                
                            }
                        } else {  
                            
                        }
                    }
                    // component.set("v.LoadingText", false);
                });
                $A.enqueueAction(action);
            } 
            if(str1.startsWith('005'))
            {
                component.set("v.userId",lookupVal);
                console.log('lookupVal for UserId Id'+lookupVal);                
                var action = component.get("c.userDetails");       
                action.setParams({
                    "userId" :  lookupVal 
                });
                action.setCallback(this, function(response){
                    var STATE = response.getState();
                    if(STATE === "SUCCESS") {  
                        
                        let resp =  response.getReturnValue()[0];          
                        let accRecord =  component.get("v.referralRecord"); 
                        accRecord.ElixirSuite__Email_CTM__c = resp.Email;
                        accRecord.ElixirSuite__Phone_CTM__c = resp.Phone;
                        component.set("v.referralRecord",accRecord);  
                    }
                    else if (state === "ERROR") {
                        var errors = response.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                
                            }
                        } else {  
                            
                        }
                    }
                    // component.set("v.LoadingText", false);
                });
                $A.enqueueAction(action);
            }
           if(str1.startsWith('001'))
           {
               console.log("lookupVal "+lookupVal);
               var accountId = lookupVal;
               component.set("v.accountId",accountId);
               console.log("lookupVal accountId "+accountId);
              
                var action = component.get("c.accountDetails");
            action.setParams({
                accountId : accountId
            });
            action.setCallback(this, function(response){
                var STATE = response.getState();
                if(STATE === "SUCCESS") { 
                    //component.set("v.loaded",true);
                    let resp =  response.getReturnValue()[0];          
                    let accRecord =  component.get("v.referralRecord"); 
                    accRecord.ElixirSuite__Email_Referred_To__c = resp.ElixirSuite__Email_Id__c ;
                    accRecord.ElixirSuite__Phone_Referred_To__c = resp.Phone;
                    if(resp.hasOwnProperty('Account')){
                            accRecord.ElixirSuite__Referred_Out_Organization__c = resp.Id;
                            //component.set("v.referredOutOrgName",resp.Name);
                            //component.set("v.accountName",resp.Name);//referralRecord.ElixirSuite__Referred_Out_Organization__c
                            component.set("v.referralRecord.ElixirSuite__Email_Referred_To__c",resp.ElixirSuite__Email_Id__c ); 
                            component.set("v.referralRecord.ElixirSuite__Phone_Referred_To__c",resp.Phone); 
                         component.set("v.referralRecord.ElixirSuite__Referred_Out_Organization__c",resp.Id);
                        }
                        
                        component.set("v.referredOutOrgName",resp.Name);
                        //component.set("v.accountName",resp.Name);   
                        accRecord.ElixirSuite__Referred_Out_Organization__c = resp.Id; // Setting Account of contact
                        accRecord.ElixirSuite__Phone_Referred_To__c = resp.Phone;
                        component.set("v.referralRecord.ElixirSuite__Referred_Out_Organization__c",resp.Id);         
                        
                        component.set("v.referralRecord",accRecord); 
                        component.set("v.referralRecord.ElixirSuite__Email_Referred_To__c",resp.ElixirSuite__Email_Id__c ); 
                        component.set("v.referralRecord.ElixirSuite__Phone_Referred_To__c",resp.Phone); 
                       
                    
                }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            
                        }
                    } else {  
                        
                    }
                }
                component.set("v.LoadingText", false);
            });
            $A.enqueueAction(action);
           } 
        }
        
        /** if(lookupVal)
        {
            component.set("v.contactId",lookupVal);
            console.log('lookupVal for Contact Id'+lookupVal);
            console.log('accountId - '+component.get("v.accountId"));     
            console.log('userId - '+component.get("v.userId"));     
                var action = component.get("c.getReferralLookupDetails");       
                action.setParams({
                    "accountId" :  component.get("v.accountId"),
                    "contactId" :  lookupVal ,
                    "userId" : component.get("v.userId")
                });
                action.setCallback(this, function(response){
                    var STATE = response.getState();
                    if(STATE === "SUCCESS") {  
                        
                         var resp =  response.getReturnValue();   
                         console.log('Referal Lookup Response Details '+resp);
                         console.log('Location/Provider - '+resp.accountProvider);
                         var provider = resp.accountProvider;
                        
                         console.log('referredToContact - '+resp.referredToContact);
                         console.log('referredOutOrganization - '+resp.referredOutOrganization );
                         console.log('careTeamMember - '+resp.careTeamMember );
                         console.log('loggedInUserDetail - '+resp.loggedInUserDetail);
                         var refRecord =  component.get("v.referralRecord");
                         
                        refRecord.ElixirSuite__User__c = resp.loggedInUserDetail.Id;
                   		refRecord.ElixirSuite__Phone_CTM__c = resp.loggedInUserDetail.Phone;
                    	refRecord.ElixirSuite__Email_CTM__c = resp.loggedInUserDetail.Email;
                        //Contact Data
                        refRecord.ElixirSuite__Email_Referred_To__c = resp.referredToContact.Email;
                        refRecord.ElixirSuite__Phone_Referred_To__c = resp.referredToContact.Phone;
                        
                        }
                    else if (state === "ERROR") {
                        var errors = response.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                
                            }
                        } else {  
                            
                        }
                    }
                   // component.set("v.LoadingText", false);
                });
                $A.enqueueAction(action);
                  
        }**/
        
        /**  **/      
    },
   
    onSelected : function(component, event, helper) {
        let nameChartSummary = event.getSource().get("v.name");       
        let checked = event.getSource().get("v.checked");  
        let chartSummaryOptions = component.get("v.chartSummaryOptions");
        for(var key in chartSummaryOptions) {
            if(chartSummaryOptions[key].label ===nameChartSummary ){
                chartSummaryOptions[key].isOpenOnlyforSelected=checked;
                
            }
        }
        
        component.set("v.chartSummaryOptions",chartSummaryOptions);
        console.log('chartSummaryOptions in onselect '+JSON.stringify(chartSummaryOptions));
    },
    /**  
    resetData : function(component, event, helper) {
        var cmpEvent = component.getEvent("SelectedId");
        component.set("v.selectRecordName", cmpEvent);
       component.set("v.contactName", cmpEvent);
        component.set("v.referralRecord.ElixirSuite__Phone_Referred_To__c",cmpEvent);
        component.set("v.ElixirSuite__Phone_CTM__c",cmpEvent);
        component.set("v.referralRecord.ElixirSuite__Email_Referred_To__c",cmpEvent);
        component.set("v.referralRecord.ElixirSuite__Email_CTM__c",cmpEvent);
        component.set("v.userName",cmpEvent);
        component.set("v.referralRecord.ElixirSuite__User__c",cmpEvent);       
        
    } , **/
    // To remove the selected item.
    removeItem : function( component, event, helper ){
        
        var objectName = event.getParam("objectName");         
        console.log('Inside remove Item --> '+objectName+' '+JSON.stringify(objectName));
        var cmpEvent = component.getEvent("lookupVal");
        console.log('Inside remove Item cmpEvent--> '+cmpEvent+' '+JSON.stringify(cmpEvent));
        
        
        if(objectName=='Account' ||objectName=='Contact'  ){
                                    component.set("v.accountName",'');

            component.set("v.contactName", '');
            component.set("v.referralRecord.ElixirSuite__Phone_Referred_To__c",'');
        //component.set("v.ElixirSuite__Phone_CTM__c",cmpEvent);
            component.set("v.referralRecord.ElixirSuite__Email_Referred_To__c",'');
        //component.set("v.referralRecord.ElixirSuite__Email_CTM__c",cmpEvent);
        //component.set("v.userName",cmpEvent);
        //component.set("v.referralRecord.ElixirSuite__User__c",cmpEvent);
        } 
        if (objectName=='User'){
            component.set("v.referralRecord.ElixirSuite__Phone_CTM__c",'');
            component.set("v.referralRecord.ElixirSuite__Email_CTM__c",'');
        }
    },
    
    closePageOne : function(component, event, helper) {
        try{ 
            if(component.get("v.locationName")){  //v.referralRecord").ElixirSuite__Provider__c                          
                if(component.get("v.userName")){ //v.referralRecord").ElixirSuite__User__c                   
                    if(component.get("v.referralRecord").ElixirSuite__Email_CTM__c){
                        if(component.get("v.referralRecord").ElixirSuite__Referred_Out_Organization__c){
                            //if(component.get("v.referralRecord").ElixirSuite__Referred_To__c){
                                if(component.get("v.referralRecord").ElixirSuite__Email_Referred_To__c){
                                var cmpEvent = component.getEvent("ElixirOEM_ReferralToggle");        
                                cmpEvent.setParams({            
                                    "pageNumber" : "One" });        
                                cmpEvent.fire();
                            }
                            else {
                                helper.globalFlagToast(component, event, helper,'Email is mandatory', ' ', 'error');
                                }
                           /* }
                            else {
                                helper.globalFlagToast(component, event, helper,'REFERRED TO IS MANDATORY', ' ', 'error');
                            }*/
                            
                        }
                        else{
                            helper.globalFlagToast(component, event, helper,'Referred Out Organization', ' ', 'error');                     
                        }
                        
                    }
                    else{
                        helper.globalFlagToast(component, event, helper,'Care Team Member Email', ' ', 'error');
                    }
                }
                else {
                    helper.globalFlagToast(component, event, helper,'Care Team Member is mandatory', ' ', 'error');
                }
                
            }
            else {
                helper.globalFlagToast(component, event, helper,'Location is mandatory', ' ', 'error');
            }
            
        }
        catch(e){
            console.log('event error '+e);
        }
        
    },
    closeModal : function(component, event, helper) {
        try{  
            //component.set("v.isOpen",false);
            
        /************Nikhil**************/ 
        var workspaceAPI =component.find("workspace");
        if(component.get("v.backPage2")){
          component.set("v.isOpen",false);       
        }else{
            window.history.go(-2);
        }
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
        })
        .catch(function(error){
            console.log(error);
        });
            
        }
        catch(e){
            alert('event error '+e);
        }
        
    }, 
    resetData : function(component, event, helper) {
        var cmpEvent = component.getEvent("SelectedId");
        component.set("v.selectRecordName", cmpEvent);
       component.set("v.contactName", cmpEvent);
        component.set("v.referralRecord.ElixirSuite__Phone_Referred_To__c",cmpEvent);
        //component.set("v.ElixirSuite__Phone_CTM__c",cmpEvent);
        component.set("v.referralRecord.ElixirSuite__Email_Referred_To__c",cmpEvent);
        //component.set("v.referralRecord.ElixirSuite__Email_CTM__c",cmpEvent);
        //component.set("v.userName",cmpEvent);
        //component.set("v.referralRecord.ElixirSuite__User__c",cmpEvent);
       
        
    }
})
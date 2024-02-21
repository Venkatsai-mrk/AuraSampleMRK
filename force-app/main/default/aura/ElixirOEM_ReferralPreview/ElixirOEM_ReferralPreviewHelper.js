({
    sendDataForPDF : function(component, event, helper) {
          component.set("v.loaded",false);  
        
        try{
            var action = component.get("c.saveReferral");
            action.setParams({
                "parentReferral1" :  [component.get("v.referralRecord")],
                "patientDiagnosisLst" :  JSON.stringify({'key' : component.get("v.patientDiagnosisLst")}),
                "patientProcedureLst" :   JSON.stringify({'key' : component.get("v.patientProcedureLst")}),
                "chartSummaryOptions" :   JSON.stringify({'key' : component.get("v.chartSummaryOptions")}),
                "emailReferredOut" : component.get("v.referralRecord").ElixirSuite__Email_Referred_To__c,
                "files" :  JSON.stringify({'key' : component.get("v.files")}),
            });
            action.setCallback(this, function(response){
                var STATE = response.getState();
                if(STATE === "SUCCESS") {
                    component.set("v.loaded",true);
                    helper.globalFlagToast(component, event, helper,'Referral Form is Saved!', ' ', 'success');
                    //component.set("v.isOpen",false);   
                    var cmpEvent = component.getEvent("ProblemRefreshEvt");                                      
                    cmpEvent.fire(); 
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
                else if (STATE === "ERROR") {
                    //  component.set("v.loaded",true); 
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            
                        }
                    } else {  
                        // component.set("v.loaded",true); 
                    }
                }
                
            });
            $A.enqueueAction(action);
        }
        catch(e){
            alert(e)
        }
        
    },
    fetchDetails : function(component, event, helper) {
        component.set("v.loaded",false);       
        try{
            var action = component.get("c.fetchPreviewInitDetails");
            action.setParams({
                "accountId" :  component.get("v.referralRecord").ElixirSuite__Referred_Out_Organization__c,
                "contactId" :  component.get("v.referralRecord").ElixirSuite__Referred_To__c,
            });
            action.setCallback(this, function(response){
                var STATE = response.getState();
                if(STATE === "SUCCESS") {
                    component.set("v.loaded",true);
                    component.set("v.accountName",response.getReturnValue().accountName);  
                    component.set("v.contactName",response.getReturnValue().contactName);     
                }
                else if (STATE === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            
                        }
                    } else {  
                        
                    }
                }
                
            });
            $A.enqueueAction(action);
        }
        catch(e){
            alert(e)
        }
        
    },
    globalFlagToast : function(component, event, helper,title,message,type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message":  message,
            "type" :type
        });
        toastEvent.fire();
    },
})
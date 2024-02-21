({
    fetchContactDetailsFromId : function(component, event, helper,contactId) {
        try{
              component.set("v.loaded",false);
            var action = component.get("c.contactDetails");
            action.setParams({
                contactId : contactId
            });
            action.setCallback(this, function(response){
                var STATE = response.getState();
                if(STATE === "SUCCESS") { 
                     component.set("v.loaded",true); 
                    let resp =  response.getReturnValue()[0];          
                    let accRecord =  component.get("v.referralRecord"); 
                    accRecord.ElixirSuite__Email_Referred_To__c = resp.Email;
                    accRecord.ElixirSuite__Phone_Referred_To__c = resp.Phone;
                    if($A.util.isUndefinedOrNull(resp.AccountId)){
                        helper.globalFlagToast(component, event, helper,'NO ACCOUNT FOR THIS CONTACT', ' ','error');
                    }
                      if(resp.hasOwnProperty('Account')){
                          component.set("v.accountName",resp.Account.Name);
                      }
                    
                    accRecord.ElixirSuite__Referred_Out_Organization__c = resp.AccountId; // Setting Account of contact
                    accRecord.ElixirSuite__Phone_Referred_To__c = resp.Phone;
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
                component.set("v.LoadingText", false);
            });
            $A.enqueueAction(action);
        }
        catch(e){
            alert(e);
        }
    },
    fetchAccountDemographics : function(component, event, helper,accountId) {
        var action = component.get("c.accountDetails");
        action.setParams({
            "accountId" : accountId
        });
        action.setCallback(this, function(response){
            var STATE = response.getState();
            if(STATE === "SUCCESS") {               
                let referralRecord = component.get("v.referralRecord");
                referralRecord.ElixirSuite__Email_Referred_To__c = response.getReturnValue()[0].ElixirSuite__Email_Id__c;
                referralRecord.ElixirSuite__Phone_Referred_To__c = response.getReturnValue()[0].Phone; 
                component.set("v.referralRecord",referralRecord);              
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
    },
    globalFlagToast : function(component, event, helper,title,message,type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message":  message,
            "type" :type
        });
        toastEvent.fire();
    }
    })
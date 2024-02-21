({
    fetchAccountDetailsFromId : function(component, event, helper,accountId) {
        try{
            component.set("v.loaded",false);
            var action = component.get("c.accountDetails");
            action.setParams({
                accountId : accountId
            });
            action.setCallback(this, function(response){
                var STATE = response.getState();
                if(STATE === "SUCCESS") { 
                    component.set("v.loaded",true);
                    let resp =  response.getReturnValue()[0];          
                    let accRecord =  component.get("v.referralRecord"); 
                    accRecord.ElixirSuite__Email_Referred_To__c = resp.ElixirSuite__Email_Id__c;
                    accRecord.ElixirSuite__Phone_Referred_To__c = resp.Phone;
                    accRecord.ElixirSuite__Referred_To__c = '';
                   component.set("v.contactName",''); 
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
    }
})
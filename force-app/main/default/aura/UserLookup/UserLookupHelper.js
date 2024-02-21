({
    fetchUserDetailsFromId : function(component, event, helper,userId) {
        try{
             component.set("v.loaded",false);
            var action = component.get("c.userDetails");
            action.setParams({
                userId : userId
            });
            action.setCallback(this, function(response){
                var STATE = response.getState();
                if(STATE === "SUCCESS") {   
                     component.set("v.loaded",true);
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
                component.set("v.LoadingText", false);
            });
            $A.enqueueAction(action);
        }
        catch(e){
            alert(e);
        }
    }
})
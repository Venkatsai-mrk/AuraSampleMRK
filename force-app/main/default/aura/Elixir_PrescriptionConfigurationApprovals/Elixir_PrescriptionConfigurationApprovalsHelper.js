({
    initHelperCallback : function(component, event, helper) {
           component.set("v.loaded",false);
        var action = component.get('c.initCalled_fetchApprovalData');      
      
        action.setParams({
           "ApprovalForInPlainText": component.get("v.ApprovalFor")
        });        
        action.setCallback(this, function(response) { 
            var state = response.getState();
            if (state === "SUCCESS") {
                   component.set("v.loaded",true);
             	var approvalFor=component.get("v.ApprovalFor");
                console.log('approvalFor '+approvalFor);
                console.log('resp '+JSON.stringify(response.getReturnValue()));
                var numberOfApprovalLevels=3;
                if(!$A.util.isEmpty(response.getReturnValue().numberOfApprovalLevels)){
                    var prescriptionCount=response.getReturnValue().numberOfApprovalLevels[0].ElixirSuite__Prescription_Approval_Level_Count__c;
                    var labOrderCount=response.getReturnValue().numberOfApprovalLevels[0].ElixirSuite__Lab_Order_Approval_Level_Count__c;
                    if(approvalFor == 'Prescription Order' &&  prescriptionCount != null ){
                         numberOfApprovalLevels = prescriptionCount;
                    }
                    if(approvalFor == 'Lab Order' && labOrderCount != null ){
                         numberOfApprovalLevels = labOrderCount;
                    }
                    
                    if(!$A.util.isUndefinedOrNull(numberOfApprovalLevels)){   
                        if(numberOfApprovalLevels<=3){                                                    
                            var arr = [];
                            for(let i=1;i<=numberOfApprovalLevels;i++){
                                var isOpen = false;
                                if(i==1){
                                    isOpen = true;
                                }
                                else {
                                    isOpen = false;
                                }
                                let tabSetRecordInstance = {'label' : 'Level '+i.toString(),'Id' : i.toString(),'isOpen':isOpen,'tabIndex':i};
                                arr.push(tabSetRecordInstance);
                            }
                            console.log('arr'+JSON.stringify(arr));
                            component.set("v.tabs",arr);
                            component.set("v.isInit",false);
                        }
                        else {
                            helper.approvalLevelsNotValid(component, event, helper);
                        }
                    }
                    else {
                        helper.noCustomSettingsDefinedForFormApprovalMessage(component, event, helper);
                    }
                }
                else {
                    helper.noCustomSettingsDefinedForFormApprovalMessage(component, event, helper);
                }
            } 
            else if (state === "ERROR") {
               
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
    noCustomSettingsDefinedForFormApprovalMessage : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Approval level not defined in custom setting!",
            "message": "Please define approval levels first!",
            "type" : "error"
        });
        toastEvent.fire();
    },
    approvalLevelsNotValid : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Maximum 3 level of approval is allowed!",
            "message": "Please define approval level less or equal to 3.",
            "type" : "error"
        });
        toastEvent.fire();
    } 
    
})
({
    doInit : function(component, event, helper) {
        console.log('2nd comp '+JSON.stringify(component.get("v.statementID")));
        var action = component.get("c.singleStatementRecordDetils");
        component.find("Id_spinner").set("v.class" , 'slds-show');
        action.setParams({ statementId : component.get("v.statementID")});        
        action.setCallback(this, function (response){           
            var state = response.getState(); 
            if (state === "SUCCESS") {
                component.find("Id_spinner").set("v.class" , 'slds-hide');
                component.set("v.statementRecord",response.getReturnValue().singPaymentStatementRecord);
                component.set("v.totalSum",response.getReturnValue().totalSum);
                component.set("v.newCharges",response.getReturnValue().newCharges);
                component.set("v.paymentAdjustments",response.getReturnValue().paymentAdjustments); 
                component.set("v.accountDetails",response.getReturnValue().acctDetails);
                component.set("v.billDate",response.getReturnValue().statementDate);
                 component.set("v.allOperatedProcedures",response.getReturnValue().paymentStatements);
                
                // component.set("v.statementRecords",response.getReturnValue().allPatientStatements);
                
            }
            else{
                component.find("Id_spinner").set("v.class" , 'slds-hide');
                //getting errors if callback fails
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                                    errors[0].message);
                    }        }
            }
        });
        
        $A.enqueueAction(action);
    },
    closeModel : function(component, event, helper) {
        component.set("v.isOpen",false);
    }
})
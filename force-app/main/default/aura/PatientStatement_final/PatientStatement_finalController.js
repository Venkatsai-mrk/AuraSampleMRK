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
                component.set("v.payFullBy",response.getReturnValue().payFullBy);
                component.set("v.statementRecord",response.getReturnValue().singPaymentStatementRecord);
                component.set("v.totalSum",response.getReturnValue().totalSum);
                component.set("v.newCharges",response.getReturnValue().newCharges);
                component.set("v.prevBal",response.getReturnValue().prevBalance);
                component.set("v.newBalance",response.getReturnValue().newBalance);
                component.set("v.providerName",response.getReturnValue().providerName);
                component.set("v.paymentAdjustments",response.getReturnValue().paymentAdjustments); 
                component.set("v.accountDetails",response.getReturnValue().acctDetails);
                component.set("v.billDate",response.getReturnValue().statementDate);
                component.set("v.PrivateProcedures",response.getReturnValue().privateProcedures);
                component.set("v.InsuranceProcedures",response.getReturnValue().insuranceProcedures);
                component.set("v.primaryInsuranceName",response.getReturnValue().primaryInsuranceName);
                component.set("v.secInsuranceName",response.getReturnValue().secInsuranceName); 
                component.set("v.headerLogo",response.getReturnValue().headerLogo); 
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
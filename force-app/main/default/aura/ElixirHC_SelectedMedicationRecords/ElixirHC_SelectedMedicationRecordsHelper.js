({
    helperMethod : function(component , valid) {
        var procedureStartCmp = component.find("procedure-start_time");
        var strtProcedureTime = procedureStartCmp.get('v.value');
        
        var procedureEndCmp = component.find("procedure-end_time");
        var endProcedureTime = procedureEndCmp.get('v.value');
       if(!($A.util.isUndefinedOrNull(strtProcedureTime)))
        {
            var today = new Date();
            var dte = new Date(strtProcedureTime);
            var endte = new Date(endProcedureTime);
            
            dte.setHours(dte.getHours(),dte.getMinutes(),0,0);
            endte.setHours(endte.getHours(),endte.getMinutes(),0,0);
            today.setHours(today.getHours(),today.getMinutes(),0,0);
            
            
            if((endte.setDate(endte.getDate()) > today))
            {
                procedureEndCmp.setCustomValidity("End Time cannot be greater than the Current Time.");
                procedureEndCmp.reportValidity();
                valid = false;
            }
            else
            {
                procedureEndCmp.setCustomValidity("");
                procedureEndCmp.reportValidity();
            }
          
            if((dte.setDate(dte.getDate()) >today))
            {
                procedureStartCmp.setCustomValidity("Start Time cannot be greater than the Current Time.");
                procedureStartCmp.reportValidity();
                valid = false;
                console.log('ss');
            }
            else 
            {
                procedureStartCmp.setCustomValidity("");
                procedureStartCmp.reportValidity();
                
            }
        }
        else if($A.util.isUndefinedOrNull(endProcedureTime))
        {
            valid = false;
            procedureEndCmp.setCustomValidity("Complete this field");
            procedureEndCmp.reportValidity();
        }
      
        return valid;
    },

    fetchUserName : function(component) {

        var action = component.get("c.fetchUser");
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('in helper fetch username**',response.getReturnValue());
               component.set("v.userName",response.getReturnValue());
            }
            else {
                    console.log("failure for namespace");
            }
              });
              $A.enqueueAction(action);
    },

    attachApprovalDataToParentPrescriptionJS : function(component, event, helper, parentPrescriptionId) {
        try {
            // at max 3 approval levels will be there, ex-
            //'[{"approvalLevel":1,"comments":"comm1","customLabel":"Aditya-user","dateOfApproval":"2023-04-20T14:06:18.758Z","signatureContentDocumentId":"069N0000002DHmcIAG","userName":"User User","userRole":"CEO"},{"approvalLevel":2,"comments":"comm2","customLabel":"Aditya-user","dateOfApproval":"2023-04-20T14:06:31.832Z","signatureContentDocumentId":"069N0000002DHmcIAG","userName":"User User","userRole":"CEO"},{"approvalLevel":3,"comments":"comm3","customLabel":"Aditya-user","dateOfApproval":"2023-04-20T14:06:41.884Z","signatureContentDocumentId":"069N0000002DHmcIAG","userName":"User User","userRole":"CEO"}]'
            let approvedValues = component.get("v.approvedValues");

            let action = component.get("c.attachApprovalDataToParentPrescription");
            action.setParams({
                parentPrescriptionId : parentPrescriptionId,
                approvedValues : approvedValues
            });

            action.setCallback(this, function(response) {
                alert(response.getReturnValue());
                if (response.getState() == "ERROR") {
                    alert("Failed to attach approval data");
                    console.log("Failed to attach approval data", JSON.stringify(response.getError()));
                }
            }); 

            $A.enqueueAction(action);
        } catch (error) {
            console.error('error in attachApprovalDataToParentPrescriptions: ', error);
        }
    }
    
})
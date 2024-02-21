({
    
    addDays : function (component, event, helper,date, days) {
        var a = parseInt(days);
        const copy = new Date(Number(date))
        copy.setDate(date.getDate() + a)
        return copy
    },
    isValidationRequiered :  function (component,obj) {
        for (var key in obj) {
            if (obj[key] !== null && obj[key] != "")
                return false;
        }
        return true;
    },
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

    //added by Anmol for LX3-5961
    fetchSessionCompleted : function(component,accId,revDate) {

        var action = component.get("c.fetchEvent");
        action.setParams({ accountId : accId,
                            reviewDate : revDate
                         });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
            console.log('in helper fetchSessionCompleted**',response.getReturnValue());
            component.set("v.sessionCompleted",response.getReturnValue());
            var apsession = component.get('v.approvedSession');
            this.fetchSessionAvail(component,apsession);
            }
            else {
                    console.log("failure for namespace");
            }
              });
              $A.enqueueAction(action);
              var apsession = component.get('v.approvedSession');
              this.fetchSessionAvail(component,apsession);
    },

    fetchSessionAvail : function(component,apsession) {

        var sesComp = component.get("v.sessionCompleted");
        var sesAvail = apsession - sesComp;
        component.set("v.sessionAvail",sesAvail);

    }
    //end by Anmol for LX3-5961
})
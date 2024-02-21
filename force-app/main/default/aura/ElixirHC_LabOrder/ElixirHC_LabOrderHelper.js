({
    getAllPicklistValues: function(component) {
        var action = component.get("c.getAllPicklistValues");
        action.setCallback(this,function(response) {
            var res = response.getReturnValue();           
            // console.log('helper ret ' + JSON.stringify(response.getReturnValue()));
            // component.set("v.AvailableTest", res['AvailableTest']);
            component.set("v.AllUsers", res['AllUsers']);
            component.set("v.AvailableFrequencies", res['FrequencyValues']);
            component.set("v.OrderViaValues", res['OrderViaValues']);
            // alert('order via val '+JSON.stringify( res['OrderViaValues']));
        });       
        $A.enqueueAction(action);
        
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
    
    validateRequired: function(component) {
        var re = /^[A-Za-z0-9]+$/
        var message = '';
        console.log('inside validate');
        
        var isValid = true;
        
        isValid = component.find('field').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            console.log(validSoFar);
            console.log('s',inputCmp.get('v.validity').valid);
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true); 
        var nameSpace = 'ElixirSuite__';
        var allRows = component.get("v.ProcReqToSave");
        if (allRows[nameSpace + 'Order_By__c'] == '') {
            
            message = 'Please fill required fields.'
            isValid = false;
            
        } else if (allRows[nameSpace + 'Ordered_Via__c'] == '') {
            message = 'Please fill required fields.'
            isValid = false;
            
        } else if (!re.test(allRows[nameSpace + 'Fax__c']) && allRows[nameSpace + 'Fax__c'] != '') {
            // alert('inside els eif' + event.getSource().get("v.value"));
            
            
            message = 'Special characters are not allowed in FAX field!'
            isValid = false;
            
        }
        
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Notification!",
            "type": 'info',
            "message": message
        });
        toastEvent.fire();
        
        return isValid;
    },
    
    getAllUser: function(component) {
        var action = component.get("c.getAllUser");
        action.setCallback(this, function(response) {
            var res = response.getReturnValue();
            console.log('users' + JSON.stringify(response.getReturnValue()));
            component.set("v.AllUsers", res);
        });
        $A.enqueueAction(action);
        
    },
    getNameSpaceOrgWide: function(component) {
        var action = component.get("c.fetchNameSpace");
        action.setCallback(this,function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var res = response.getReturnValue();
                console.log('name space org wide' + JSON.stringify(response.getReturnValue()));
                component.set("v.NameSpaceOrgWide", res);
            }
        });
        $A.enqueueAction(action);
        
    }
})
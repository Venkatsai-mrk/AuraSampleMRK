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
    
    fetchCheckBoxesValues : function(component) {        
        var action = component.get("c.fetchCusomMetadataRecord");
  		 action.setCallback(this, function(response) {
            var res = response.getReturnValue();
  			 var state = response.getState();
            if (state === "SUCCESS") {
                console.log('final ' + JSON.stringify(res));
                var c= [];
                var filter = component.get("v.ProcReqToSave.UASampleDetails.ElixirSuite__Necessity_Details__c");
                var nameSpace = 'ElixirSuite__';
                for (var i = 0; i < res['MedicalNecessity'].length; i++) {
                    console.log('inside for');
                   if(!$A.util.isUndefinedOrNull(filter) && filter.includes(res['MedicalNecessity'][i][nameSpace + 'Picklist_Value__c'])){
                        c[i] = {
                        'label': res['MedicalNecessity'][i][nameSpace + 'Picklist_Label__c'],
                        'value': '\n\n' + res['MedicalNecessity'][i][nameSpace + 'Picklist_Value__c'],
                         'hasValue' : true
                    }; 
                    }
                    else {
                        c[i] = {
                        'label': res['MedicalNecessity'][i][nameSpace + 'Picklist_Label__c'],
                        'value': '\n\n' + res['MedicalNecessity'][i][nameSpace + 'Picklist_Value__c'],
                         'hasValue' : false
                    };  
                    }
        	  }
                var arr = [];
                for (var k=0;k<res['AvailableTest'].length;k++){
                    var item = res['AvailableTest'][k][nameSpace + 'Available_Tests__c'].split('\n')
                    arr = arr.concat(item);                                        
                }
                 component.set("v.AvailableTest",arr);
                console.log('arr value '+JSON.stringify(arr));
                console.log('p value '+JSON.stringify(arr));
                component.set("v.checkOptions", c);
                component.set("v.IsSpinner", false);                
                console.log('option value '+JSON.stringify(component.get("v.options")));
           }
            
        });
        
        $A.enqueueAction(action);
        
    },
    getAllPicklistValues: function(component) {
        var action = component.get("c.getAllPicklistValues");
        action.setCallback(this, function(response) {
            var res = response.getReturnValue();            
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('order via val '+JSON.stringify( res['AllUsers']));
                component.set("v.AllUsers", res['AllUsers']);
                component.set("v.AvailableFrequencies", res['FrequencyValues']);
                component.set("v.OrderViaValues", res['OrderViaValues']);
                  console.log('getAll ' + JSON.stringify(res['AllUsers']));
            }
        });
        
        $A.enqueueAction(action);                
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
    objectsAreSame : function(component,OrignalResponse, UpdatedResponse)  {
        console.log('org re '+JSON.stringify(OrignalResponse));
        console.log('up res '+JSON.stringify(UpdatedResponse));
        var objectsAreSame = true;
        for(var propertyName in OrignalResponse) {
            if(OrignalResponse[propertyName] !== UpdatedResponse[propertyName]) {
                objectsAreSame = false;
                break;
            }
        }
        return objectsAreSame;
    },
    getNameSpaceOrgWide: function(component) {
        var action = component.get("c.fetchNameSpace");
        action.setCallback(this, function(response) {           
            var res = response.getReturnValue();
            console.log('name space org wide' + JSON.stringify(response.getReturnValue()));
            component.set("v.NameSpaceOrgWide", res);
            
        });
        $A.enqueueAction(action);
    }
})
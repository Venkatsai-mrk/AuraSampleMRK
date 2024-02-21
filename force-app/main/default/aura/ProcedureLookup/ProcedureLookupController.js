({
    searchField : function(component, event, helper) {
        var currentText = event.getSource().get("v.value");   
        component.set("v.LoadingText", true);
        if(currentText.length > 0) {
            component.set('v.EmpList',true);
        }
        else {
            component.set('v.EmpList',false);
        }
        
        var action = component.get("c.procedureList");
        action.setParams({
            "searchKeyWord" : component.get("v.selectRecordName"),
            "acctId" :  component.get("v.PatientId")
        });
        action.setCallback(this, function(response){
            var STATE = response.getState();
            if(STATE === "SUCCESS") {                
                component.set("v.searchRecords", response.getReturnValue());
                
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
        
    }, //!allData.cptCode_Procedure
    setSelectedRecord : function(component, event, helper) {
        component.set('v.EmpList',false);
        var currentText = event.currentTarget.id;
        component.set("v.selectRecordName", event.currentTarget.dataset.name);
        if(event.currentTarget.dataset.name=='Other | N/A'){
            component.set("v.EmpOther",true);
        }else{ component.set("v.EmpOther",false);
             }
        component.set("v.selectRecordId", currentText);   
        console.log('set id '+event.currentTarget.dataset.name);
      
    }, 
    resetData : function(component, event, helper) {
        component.set("v.selectRecordName", "");
        component.set("v.selectRecordId", "");
        var cmpEvent = component.getEvent("FiringSelectedId");
        // Get the value from Component and set in Event
        cmpEvent.setParams( { "SelectedId" : ""} );
        cmpEvent.fire();
    }
})
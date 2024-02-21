({    
    searchField : function(component, event, helper) {
        var currentText = '';
        currentText = event.getSource().get("v.value");   
            component.set("v.LoadingText", true);
            if(currentText.length > 0) {
                component.set('v.EmpList',true);
            }
            else {
                component.set('v.EmpList',false);
            }
          var recId = component.get("v.recId");
      
            var action = component.get("c.getDiagnosisItems");
            action.setParams({
                "searchKeyWord" : currentText
            });
            action.setCallback(this, function(response){
                var STATE = response.getState();
                if(STATE === "SUCCESS") {
                    component.set("v.searchRecords", response.getReturnValue());
                   
                }
               //    alert('in init-- '+ JSON.stringify(component.get("v.accName")));
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
        
    },
    setSelectedRecord : function(component, event, helper) {
        var currentText = event.currentTarget.id;
        if(currentText == undefined){
            currentText = event.target.id;
        }
        component.set("v.selectRecordId", currentText);
        var records = component.get("v.searchRecords");
        var idx = records.findIndex(obj => obj.Id === currentText);
        var selectedValue = records[idx];
        component.set("v.selectRecordName", event.currentTarget.dataset.name);
        component.set("v.EmpList", false);
    }, 
    resetData : function(component, event, helper) {
        component.set("v.selectRecordId",'');
        component.set("v.selectRecordName",'');
        component.set("v.EmpList",false);
    }
})
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
        var action = component.get("c.searchKeyResult");
        action.setParams({
            "searchKey": currentText
        });
        action.setCallback(this, function(response){
            var STATE = response.getState();
            if(STATE === "SUCCESS") {
                component.set("v.searchRecords", response.getReturnValue());
                
                if(response.getReturnValue() != null)
                {
                    for(var i in response.getReturnValue())
                    {
                        if(response.getReturnValue()[i]['Name'] != null && response.getReturnValue()[i]['Name'] != undefined)
                        {
                            component.set("v.accName",response.getReturnValue()[i]['Name']);
                            break;
                        }
                    }
                }
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
        console.log('&&',selectedValue);
        component.set("v.selectRecordName", event.currentTarget.dataset.name);
        //helper.openSubTabs(component, event);
        //component.set("v.selectRecordId",'');
        //component.set("v.selectRecordName",'');
        component.set('v.EmpList',false);
        var cmpEvent = component.getEvent("SearchBarToNotes");
        cmpEvent.setParams( { "selectedValue" : selectedValue } );
        cmpEvent.fire();
    }, 
    resetData : function(component, event, helper) {
        component.set("v.selectRecordId",'');
        component.set("v.selectRecordName",'');
        component.set("v.EmpList",false);
    }
})
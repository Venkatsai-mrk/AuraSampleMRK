({    
    searchField : function(component, event, helper) {
        console.log(component.get("v.typeOfNote"));
        var currentText = '';
        currentText = event.getSource().get("v.value");   
            component.set("v.LoadingText", true);
            if(currentText.length > 0) {
                component.set('v.EmpList',true);
            }
            else {
                component.set('v.EmpList',false);
            }
            if(currentText.length < 3) {
                return;
            }
          var recId = component.get("v.recId");
            var action = component.get("c.getMenuItems");
            action.setParams({
                "searchKeyWord" : currentText,
                "recId" : recId,
                "typeOfNote" : component.get("v.typeOfNote")
            });
            action.setCallback(this, function(response){
                var STATE = response.getState();
                if(STATE === "SUCCESS") {
                    console.log('#### response : ' + JSON.stringify(response.getReturnValue()));
                    if(!$A.util.isUndefinedOrNull(response.getReturnValue()))
                    {
                        if(component.get("v.typeOfNote") == 'Medication'){
                            let medications = response.getReturnValue();
                            let newMeds = [];
                            for(let medicine in medications){
                                medications[medicine]['medicine']['FieldName'] = medications[medicine]['medicine'].ElixirSuite__Drug_Name__c;
                                newMeds.push(medications[medicine]['medicine']);
                            }
                            console.log('medications '+JSON.stringify(newMeds));
                            component.set("v.searchRecords", newMeds);
                        }else{
                            component.set("v.searchRecords", response.getReturnValue());
                            for(var i in response.getReturnValue())
                            {
                                console.log('#### i ---- ' + JSON.stringify(response.getReturnValue()[i]));
                                if(response.getReturnValue()[i]['innerWrap'] != null && response.getReturnValue()[i]['innerWrap'] != undefined)
                                {
                                console.log('Value --- : ' + JSON.stringify(response.getReturnValue()[i]['innerWrap']));
                                component.set("v.accName",response.getReturnValue()[i]['innerWrap']);
                                break;
                                }
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
        helper.openSubTabs(component, event);
        component.set("v.selectRecordId",'');
        component.set("v.selectRecordName",'');
        component.set('v.EmpList',false);
        if(component.get("v.viewRec")== true){
        var cmpEvent = component.getEvent("SearchBarToNotesEdit");
        cmpEvent.setParams( { "selectedValue" : selectedValue,
                             "noteType" :  component.get("v.typeOfNote")} );
        cmpEvent.fire();
        }
        else{
        var cmpEvent = component.getEvent("SearchBarToNotes");
        cmpEvent.setParams( { "selectedValue" : selectedValue,
                             "noteType" : component.get("v.typeOfNote")} );
        cmpEvent.fire();
        }
    },
    setSelectedRecordOther : function(component, event, helper) {
        console.log('ither');
        var currentText = event.currentTarget.id;
        if(currentText == undefined){
            currentText = event.target.id;
        }
        component.set("v.selectRecordId", currentText);
        var selectedValue = 'Other' ;
        component.set("v.selectRecordName", event.currentTarget.dataset.name);
        helper.openSubTabs(component, event);
        component.set("v.selectRecordId",'');
                component.set("v.selectRecordName",'');
        component.set('v.EmpList',false);
        if(component.get("v.viewRec")== true){
        var cmpEvent = component.getEvent("SearchBarToNotesEdit");
        cmpEvent.setParams( { "selectedValue" : selectedValue,
                             "noteType" :  component.get("v.typeOfNote") } );
        cmpEvent.fire();
        }
        else{
        var cmpEvent = component.getEvent("SearchBarToNotes");
        cmpEvent.setParams( { "selectedValue" : selectedValue,
                            "noteType" : component.get("v.typeOfNote")} );
        cmpEvent.fire();
    }
    },
    
    resetData : function(component, event, helper) {
        component.set("v.selectRecordId",'');
        component.set("v.selectRecordName",'');
        component.set("v.EmpList",false);
    }
})
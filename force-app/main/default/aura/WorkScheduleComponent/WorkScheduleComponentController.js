({
    handleKeyUp : function(component, event, helper) {
        var searchText = component.find('searchPractitionerText').get('v.value');
        var action = component.get('c.getPractitionerList');
        action.setParams({
            searchText : searchText
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                var responseValue = response.getReturnValue();
                component.set('v.recordList', responseValue);
            }
        });
        $A.enqueueAction(action);
    },
    doSelect : function(component, event, helper) {
        var index = event.currentTarget.id;
        var selectedRecord = component.get('v.recordList')[index];
        console.log('selectedRecord ', selectedRecord);
        component.set('v.selectedRecordId', selectedRecord.Id);
        console.log('record.Id ', selectedRecord.Id);
        component.set('v.lookupValue',selectedRecord.Name);
        console.log('contact name ', selectedRecord.Name);
        component.set('v.recordList', null);
        console.log('recordList ',component.get('v.recordList'));
    },
    showAvailability : function(component, event, helper) {
        var jsonList;
        var jsonListfinal=[];
        
        console.log('Inside WprkScheduleComp showAvailability() called ');
        console.log(' v.selectedRecordId  '+component.get('v.selectedRecordId'));
        var action = component.get('c.getPractitionerAvailability'); 
        action.setParams({
            practitionerId : component.get("v.selectedRecordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(state+ 'state');
            if(state === "SUCCESS"){
                var records = response.getReturnValue();
                console.log(JSON.stringify(records)+' work schedule records');
                jsonList = records;
                for (var i=0; i<jsonList.length ; i++){	
                    var obj = {};
                    var recordId = jsonList[i]["Id"]; 
                    obj['id'] = jsonList[i]["Id"];
                    obj['title'] = 'Available';            
                    obj['start'] = jsonList[i]["ElixirSuite__Start_Date_Time__c"];
                    obj['end'] = jsonList[i]["ElixirSuite__End_Date_Time__c"];
                    obj['url'] =  '/lightning/r/ElixirSuite__Work_Schedule__c/'+recordId+'/view';
                    obj['backgroundColor'] = 'green';
                    obj['textColor'] = 'white';
                    jsonListfinal.push(obj);
                }
                component.set("v.jsonToSave",jsonListfinal);  
                console.log(JSON.stringify(jsonListfinal)+' jsonListfinal');
                component.set("v.showCalendar",true);
            } 
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                }
            }
        });
        $A.enqueueAction(action);
        component.set("v.showCalendar",false);
    }
})
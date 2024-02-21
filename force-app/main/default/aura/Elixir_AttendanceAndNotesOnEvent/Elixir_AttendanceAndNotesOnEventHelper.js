({
    
    getAttachedPatientGroup : function(component, eventId) {  
        var action = component.get("c.getEventPatientGroup");
        action.setParams({
            'recordId': eventId
        });
        action.setCallback(this,function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var accLst = result.accList;
                var grpNote = result.groupNoteValue;
                
                console.log('accLst**',accLst.length);
                if(accLst.length > 0){
                    component.set("v.recordsAvailable", true);
                    component.set("v.accValues", accLst);
                    
                    var attend = 0;
                    var lstSize = accLst.length;
                    var invValues = [];
                    for (var i = 0; i < accLst.length; i++) {
                        var row = accLst[i];
                        if(row.attended == true){
                            attend = attend + 1;
                        }
                        var singleObj = {};
                        singleObj['eventId'] = row.eventId;
                        singleObj['accId'] = row.accountId;
                        singleObj['attended'] = row.attended;
                        singleObj['notes'] = row.individualNoteValue;
                        singleObj['notesChange'] = false;
                        invValues.push(singleObj);
                    }
                    component.set("v.attended",attend);
                    var notAttended = lstSize - attend;
                    component.set("v.count",notAttended);
                    component.set("v.accIdToAttended",invValues);
                    component.set("v.actualGroupNote",grpNote);

                    component.set("v.groupNote",grpNote);
                    
                }
                console.log('result**',result);
                component.set("v.Ehr",true);
                component.set("v.loaded",false);
                component.set("v.eventData",result.eventData);
            }
            else{
                component.set("v.recordsAvailable", false);
            }
        });
        $A.enqueueAction(action);
        
    },
})
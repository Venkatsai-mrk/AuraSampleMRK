({
    doInit: function(component, event, helper) {
        // component.set("v.LabOrders",true);     
        var action = component.get("c.fetchNoteRecord");
        component.set("v.loaded",false);
        action.setParams({
            noteId: component.get("v.noteId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                try{
                    component.set("v.loaded",true);  
                    console.log('form data ' + JSON.stringify(response.getReturnValue()));
                    console.log('jsonData ' + JSON.stringify(response.getReturnValue().jsonData)); 
                    let jsonData = JSON.parse(response.getReturnValue().jsonData);
                    let lst = jsonData.key;
                    let attended = false;
                    for(let rec in lst){
                        if(lst[rec].patientId ==   component.get("v.patientID")){
                            attended = lst[rec].attended;
                        }
                    }
                    if(attended){
                        component.set("v.attended",'Attended');   
                    }
                    else {
                        component.set("v.attended",'Not Attended');  
                    }
                    let ntsArr = response.getReturnValue().ntsArr;
                    let relatedEventArr = response.getReturnValue().relatedEventArr;
                    component.set("v.eventRec",relatedEventArr[0]);
                    component.set("v.noteRec",ntsArr[0]);
                    let coFaciliator = response.getReturnValue().coFaciliator;
                    coFaciliator = coFaciliator.slice(0, -1);
                    component.set("v.coFaciliator",coFaciliator); 
                    component.set("v.patientName",response.getReturnValue().patientName); 
                    component.set("v.allGroupNames",response.getReturnValue().allGroupNames); 
                    component.set("v.allPatientName",response.getReturnValue().allPatientName);  
                    component.set("v.AssignedToName",response.getReturnValue().AssignedToName); 
                    component.set("v.eventCreatedByName",response.getReturnValue().eventCreatedByName); 
                    let copyRelatedEventArr = JSON.parse(JSON.stringify(relatedEventArr));
                    const monthNames = ["January", "February", "March", "April", "May", "June",
                                        "July", "August", "September", "October", "November", "December"
                                       ];
                    var dateObj = new Date(copyRelatedEventArr[0].StartDateTime);
                    var month = dateObj.getUTCMonth() + 1; 
                    var day = dateObj.getUTCDate();
                    var year = dateObj.getUTCFullYear();                            
                    let newdate = monthNames[dateObj.getMonth()] +' '+ day +', '+year;
                    component.set("v.StartDateTime",newdate);
                    let mapOfIdAndEvent = {};
                    for (let rec in relatedEventArr) {
                        mapOfIdAndEvent[relatedEventArr[rec].Id] = relatedEventArr[rec];
                    }
                    
                    for (let rec in ntsArr) {
                        let ntSObj = mapOfIdAndEvent[ntsArr[rec].ElixirSuite__EventId__c];
                        if(!$A.util.isUndefinedOrNull(ntSObj)){
                            var dateObj = new Date(ntSObj.StartDateTime);
                            var month = dateObj.getUTCMonth() + 1; //months from 1-12
                            var day = dateObj.getUTCDate();
                            var year = dateObj.getUTCFullYear();                            
                            let newdate = monthNames[dateObj.getMonth()] +' '+ day +', '+year;
                            ntsArr[rec]['NameCombined'] = ntSObj.Subject +' - '+ dateObj; 
                        }
                    }
                    component.set("v.data",ntsArr);
                }
                catch(e){
                    alert(e)
                }
                
            }
        });
        
        $A.enqueueAction(action);
        
        
        
        
    },
    handleClick : function(component, event, helper) {
        component.set("v.isOpen" ,false);
    },
    handleSave : function(component, event, helper) {
        var action = component.get("c.updateNoteRecord");
        component.set("v.loaded",false);
        action.setParams({
            noteIndividual: component.get("v.noteRec.ElixirSuite__Note__c"),
            noteGroup: component.get("v.noteRec.ElixirSuite__Group_Notes__c"),
            noteRecId : component.get("v.noteId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.loaded",true);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "NOTE UPDATED SUCESSFULLY!",
                    "message": "Record Updated!",
                    "type" : "success"
                });
                toastEvent.fire();
                component.set("v.isOpen" ,false);
            }
            else{               
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && online[0].message) {
                        console.log("Error message: " +
                                    errors[0].message);
                    }        }
            }
        });
        
        $A.enqueueAction(action); 
    }
})
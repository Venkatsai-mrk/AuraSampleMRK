({
    
    doInit: function(component,event,helper){
        helper.fetchNotesRecords(component,event);
    },
    //To add new Row for adding follow up note data
    addNoteRecord : function(component, event, helper) {
        var selectedItem = event.currentTarget;
        var index = selectedItem.dataset.record;
        var noteId = component.get("v.recid");                            
        var nList = component.get("v.noteList");
        var todayDate = $A.localizationService.formatDateUTC(new Date(), "YYYY-MM-DD'T'HH:mm:ss.SSS'Z'");
		if(nList[index].ElixirSuite__Follow_Up_Notes__c !='' && nList[index].ElixirSuite__Elixir_Assigned_To__c !='' && nList[index].ElixirSuite__Elixir_Follow_up_Date__c !='' ){
            if(nList[index].ElixirSuite__Elixir_Follow_up_Date__c<todayDate)
            {
              nList.push({
                'sobjectType': 'ElixirSuite__Notes__c',
                'ElixirSuite__Follow_Up_Notes__c': '',
                'ElixirSuite__Elixir_Assigned_To__c': '',
                'ElixirSuite__Elixir_Follow_up_Date__c': '',
                'ElixirSuite__ERA_Notes__c': noteId,
                'Id': null,
            
              });
                 component.set("v.noteList", nList);
            }
            else{
                var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Please Select Follow Up Date less than today",
                        "type" : "error"
                    });
                    toastEvent.fire(); 
            }
        }
        else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": "Please Complete this Row",
                    "type" : "error"
                });
                toastEvent.fire(); 
        }
    },
    
     //To remove Row from follow up note section
    removeNoteRecord: function(component, event, helper) {        
        var noteList = component.get("v.noteList");
        var noteId = component.get("v.recid");        
        var selectedItem = event.currentTarget; 
        var deleteNoteList = component.get("v.deleteNoteList");
        var index = selectedItem.dataset.record;  
        if(noteList.length!=1){
            if(noteList[index].Id != null)
            {
                deleteNoteList.push(noteList[index]);
                component.set("v.deleteNoteList",deleteNoteList);
                console.log("delete"+JSON.stringify(deleteNoteList));
                noteList.splice(index, 1);
                component.set("v.noteList", noteList);
            }else{
            noteList.splice(index, 1);
            component.set("v.noteList", noteList);
            }
        }else{
            if(noteList[index].Id != null){
              deleteNoteList.push(noteList[index]);
              component.set("v.deleteNoteList",deleteNoteList);
              noteList.splice(index, 1);
              noteList.push({
                        'sobjectType': 'ElixirSuite__Notes__c',
                        'ElixirSuite__Follow_Up_Notes__c': '',
                        'ElixirSuite__Elixir_Assigned_To__c': '',
                        'ElixirSuite__Elixir_Follow_up_Date__c': '',
                        'ElixirSuite__ERA_Notes__c': noteId,
                        'Id': null,
                        
                    });  
              component.set("v.noteList", noteList);  
                
            }
            else{
            var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Can not delete last row",
                    "message": " ",
                    "type" : "error"
                });
                toastEvent.fire();
            }
        }
    },
    //To save follow up note data to database
    saveNotes: function(component, event, helper) { 
        var data= component.get("v.noteList");
        if (helper.validateNoteRecords(component, event)) {
            if(component.get("v.noteList")){
             component.get("v.noteList").forEach(function(rec){
                rec['ElixirSuite__ERA_Notes__c'] = component.get("v.eraId");
             });
            }
            var action = component.get("c.saveNoteList");
            action.setParams({
                "noteList": component.get("v.noteList"),
                "delNoteList": component.get("v.deleteNoteList")
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                   /* var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": "Follow Up Notes Saved successfully",
                        "type" : "success"
                    });
                    toastEvent.fire()*/
                    return true;
                }else{
                    return false;
                }
            }); 
            $A.enqueueAction(action);
        }        
    },
    
    handleSectionToggle: function (cmp, event) {
        var openSections = event.getParam('openSections');   
    },
});
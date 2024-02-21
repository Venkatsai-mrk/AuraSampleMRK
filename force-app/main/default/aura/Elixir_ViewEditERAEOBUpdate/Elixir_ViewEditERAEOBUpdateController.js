({
    
    doInit: function(component,event,helper){
        helper.fetchNotesRecords(component,event);
        helper.fetchRecommendations(component,event);
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
    getNotesData : function(component, event, helper) { 
        var data= component.get("v.noteList");
        var cmpEvent = component.getEvent("cmpEvent");
        cmpEvent.setParams({
            "notesData" :  data});
        cmpEvent.fire();
    },
    //To add new Row for adding Recommendations
    addRecommendation : function(component, event, helper) {
        var selectedItem = event.currentTarget;
        var index = selectedItem.dataset.record;
        var claimERAId = component.get("v.recid");  
        var recommendationList = component.get("v.recommendationList");
        if(recommendationList[index].ElixirSuite__Elixir_Recommendation__c ==''){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "message": "Please fill Recommendation.",
                "type" : "error"
            });
            toastEvent.fire(); 
            
        }
        else{
            recommendationList.push({
                'sobjectType': 'ElixirSuite__Recommendation__c',
                'ElixirSuite__Elixir_Recommendation__c': '',
                'ElixirSuite__Elixir_Assign_To__c': '',
                'ElixirSuite__Elixir_ERA__c': claimERAId,
                'Id': null,
                
            });
            component.set("v.recommendationList", recommendationList);
        }
    },
    //To remove row from Recommendation Section
    removeRecommendation: function(component, event, helper) {        
        var recommendationList = component.get("v.recommendationList"); 
        var recordId = component.get("v.recid");
        var deleteRecommendationList = component.get("v.deleteRecommendationList");  
        var selectedItem = event.currentTarget;        
        var index = selectedItem.dataset.record; 
        if(recommendationList.length!=1){
            if(recommendationList[index].Id != null)
            {
                deleteRecommendationList.push(recommendationList[index]);
                component.set("v.deleteRecommendationList",deleteRecommendationList);
                console.log("delete"+JSON.stringify(deleteRecommendationList));
                recommendationList.splice(index, 1);
                component.set("v.recommendationList", recommendationList);
            }else{
                recommendationList.splice(index, 1);
                component.set("v.recommendationList", recommendationList);
            }
        }else{
            if(recommendationList[index].Id != null){
                deleteRecommendationList.push(recommendationList[index]);
                component.set("v.deleteRecommendationList",deleteRecommendationList);
                console.log("delete"+JSON.stringify(deleteRecommendationList));
                recommendationList.splice(index, 1);
                recommendationList.push({
                    'sobjectType': 'ElixirSuite__Recommendation__c',
                    'ElixirSuite__Elixir_Recommendation__c': '',
                    'ElixirSuite__Elixir_Assign_To__c': '',
                    'ElixirSuite__Elixir_ERA__c': recordId,
                    'Id': null,
                    
                });
                component.set("v.recommendationList", recommendationList);
                
            }else{
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
    //To save Recommendation Data
    saveNotesRecommendations: function(component, event, helper) { 
        console.log("vale 1 "+JSON.stringify(component.get("v.noteList")));
        if (helper.validateRecommendations(component, event)) {
            console.log("val 2 ");
            if (helper.validateNoteRecords(component, event)) {
                 console.log("val 3 ");
                var action = component.get("c.saveRecommendationsList");
                action.setParams({
                    "recommendationList": component.get("v.recommendationList"),
                    "delRecList": component.get("v.deleteRecommendationList"),
                    "noteList": component.get("v.noteList"),
                    "delNoteList": component.get("v.deleteNoteList")
                });
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        /*var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": "Recommendations Saved successfully",
                        "type" : "success"
                    });
                    toastEvent.fire();*/
                   
                }
            }); 
            $A.enqueueAction(action);
            return true;    
        }else{
            return false;
        }
        }else{
            return false;
        }
    },
    handleSectionToggle: function (cmp, event) {
        var openSections = event.getParam('openSections');   
    },
});
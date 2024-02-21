({
    
    doInit: function(component,event,helper){
        helper.fetchNotesRecords(component,event);
        helper.fetchRecommendations(component,event);
    },
    //To add new Row for adding follow up note data
    addNoteRecord : function(component, event, helper) {
        var selectedItem = event.currentTarget;
       // var index = selectedItem.dataset.record;
        var noteId = component.get("v.recid");  
        var nList = component.get("v.noteList");
       // var todayDate = $A.localizationService.formatDateUTC(new Date(), "YYYY-MM-DD'T'HH:mm:ss.SSS'Z'");
        
        if (helper.validateNoteRecords(component, event)) { 
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
        
        var nList = component.get("v.noteList");
        var deleteNoteList = component.get("v.deleteNoteList");
        var recommendationList = component.get("v.recommendationList");
        var deleteRecommendationList = component.get("v.deleteRecommendationList");
        var cmpEvent = component.getEvent("cmpEvent");
        var mapIndex = component.get("v.ERAIndex");
        cmpEvent.setParams({
            "notesData" :  nList,
            "delNotesData" : deleteNoteList,
            "recommendationData" : recommendationList,
            "delRecommendationData" : deleteRecommendationList,
            "mapIndex" : mapIndex
        });
        cmpEvent.fire();
        
    },
    
    //To remove Row from follow up note section
    removeNoteRecord: function(component, event) {        
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
        var nList = component.get("v.noteList");
        var deleteNoteList = component.get("v.deleteNoteList");
        var recommendationList = component.get("v.recommendationList");
        var deleteRecommendationList = component.get("v.deleteRecommendationList");
        var cmpEvent = component.getEvent("cmpEvent");
        var mapIndex = component.get("v.ERAIndex");
        cmpEvent.setParams({
            "notesData" :  nList,
            "delNotesData" : deleteNoteList,
            "recommendationData" : recommendationList,
            "delRecommendationData" : deleteRecommendationList,
            "mapIndex" : mapIndex
        });
        cmpEvent.fire();  
    },
    getLookupData : function(component, event, helper) {
        var dataLookup = event.getParam("lookUpData");
        console.log("Lookup "+dataLookup);
        var nList = component.get("v.noteList");
        var deleteNoteList = component.get("v.deleteNoteList");
        var recommendationList = component.get("v.recommendationList");
        var deleteRecommendationList = component.get("v.deleteRecommendationList");
        var mapIndex = component.get("v.ERAIndex");
        var cmpEvent = component.getEvent("cmpEvent");
        cmpEvent.setParams({
            "notesData" :  nList,
            "delNotesData" : deleteNoteList,
            "recommendationData" : recommendationList,
            "delRecommendationData" : deleteRecommendationList,
            "mapIndex" : mapIndex
        });
        cmpEvent.fire();  
    },
    getNotesData : function(component, event, helper) { 
        var data= component.get("v.noteList");
        var deleteNoteList = component.get("v.deleteNoteList");
        var recommendationList = component.get("v.recommendationList");
        var deleteRecommendationList = component.get("v.deleteRecommendationList");  
        var mapIndex = component.get("v.ERAIndex");
        var cmpEvent = component.getEvent("cmpEvent");
        cmpEvent.setParams({
            "notesData" :  data,
            "delNotesData" : deleteNoteList,
            "recommendationData" : recommendationList,
            "delRecommendationData" : deleteRecommendationList,
            "mapIndex" : mapIndex
        });
        cmpEvent.fire();
    },
    //To add new Row for adding Recommendations
    addRecommendation : function(component, event, helper) {
        var selectedItem = event.currentTarget;
        var index = selectedItem.dataset.record;
        var claimERAId = component.get("v.recid");  
        var recommendationList = component.get("v.recommendationList");
        var ERAHash = component.get("v.eraHash");
        if (helper.validateRecommendations(component, event)) {
          recommendationList.push({
                'sobjectType': 'ElixirSuite__Recommendation__c',
                'ElixirSuite__Elixir_Recommendation__c': '',
                'ElixirSuite__Elixir_Assign_To__c': '',
                'ElixirSuite__Elixir_ERA__c': claimERAId,
                'ElixirSuite__Elixir_ERA__r':{'ElixirSuite__Claim__r':{'Name':ERAHash}},
                'Id': null,
                
            });
            component.set("v.recommendationList", recommendationList);   
        }
            
       
        var nList = component.get("v.noteList");
        var deleteNoteList = component.get("v.deleteNoteList");
        var recommendationList = component.get("v.recommendationList");
        var deleteRecommendationList = component.get("v.deleteRecommendationList");
        var cmpEvent = component.getEvent("cmpEvent");
        var mapIndex = component.get("v.ERAIndex");
        cmpEvent.setParams({
            "notesData" :  nList,
            "delNotesData" : deleteNoteList,
            "recommendationData" : recommendationList,
            "delRecommendationData" : deleteRecommendationList,
            "mapIndex" : mapIndex
        });
        cmpEvent.fire();
    },
    //To remove row from Recommendation Section
    removeRecommendation: function(component, event, helper) {        
        var recommendationList = component.get("v.recommendationList"); 
        var recordId = component.get("v.recid");
        var deleteRecommendationList = component.get("v.deleteRecommendationList");  
        var selectedItem = event.currentTarget;        
        var index = selectedItem.dataset.record; 
        var ERAHash = component.get("v.eraHash");
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
                    'ElixirSuite__Elixir_ERA__r':{'ElixirSuite__Claim__r':{'Name':ERAHash}},
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
        var nList = component.get("v.noteList");
        var deleteNoteList = component.get("v.deleteNoteList");
        var recommendationList = component.get("v.recommendationList");
        var deleteRecommendationList = component.get("v.deleteRecommendationList");
        var mapIndex = component.get("v.ERAIndex");
        var cmpEvent = component.getEvent("cmpEvent");
        cmpEvent.setParams({
            "notesData" :  nList,
            "delNotesData" : deleteNoteList,
            "recommendationData" : recommendationList,
            "delRecommendationData" : deleteRecommendationList,
            "mapIndex" : mapIndex
        });
        cmpEvent.fire();  
    },
    
    handleSectionToggle: function (cmp, event) {
     //   var openSections = event.getParam('openSections');
       
    },
});
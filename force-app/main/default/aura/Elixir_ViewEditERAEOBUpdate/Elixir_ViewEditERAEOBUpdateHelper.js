({
    //Call on doInIt fetch related Follow Up Notes
    fetchNotesRecords : function(component, event){
        var action = component.get("c.fetchNotes");
        var noteId = component.get("v.recid");
        action.setParams({
            "recId":noteId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                if(response.getReturnValue() != null && response.getReturnValue()!=""){
                    component.set("v.noteList", response.getReturnValue());
                }
                else{
                    var nList = component.get("v.noteList");
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
            }
        });
        $A.enqueueAction(action);
        
	},
    //Call on doInIt fetch related Recommendations
    fetchRecommendations : function(component, event){
        var action = component.get("c.fetchRecommendations");
        var recordId = component.get("v.recid");
        action.setParams({
            "recId":recordId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                if(response.getReturnValue() != null && response.getReturnValue()!=""){
                    component.set("v.recommendationList", response.getReturnValue());
                }
                else{
                    var nList = component.get("v.recommendationList");
                    nList.push({
                        'sobjectType': 'ElixirSuite__Recommendation__c',
                        'ElixirSuite__Elixir_Recommendation__c': '',
                        'ElixirSuite__Elixir_Assign_To__c': '',
                        'ElixirSuite__Elixir_ERA__c': recordId,
                        'Id': null,
                        
                    });
                    component.set("v.recommendationList", nList); 
                }
            }
        });
        $A.enqueueAction(action);
        
	},
    validateNoteRecords: function(component, event) {
        var noteList = component.get("v.noteList");
        var todayDate = $A.localizationService.formatDateUTC(new Date(), "YYYY-MM-DD'T'HH:mm:ss.SSS'Z'");
        if(noteList.length == 1){
            if (noteList[0].ElixirSuite__Follow_Up_Notes__c == '' && noteList[0].ElixirSuite__Elixir_Assigned_To__c == '' && noteList[0].ElixirSuite__Elixir_Follow_up_Date__c == '') {
              return true;  
            }else if(noteList[0].ElixirSuite__Follow_Up_Notes__c != '' && noteList[0].ElixirSuite__Elixir_Assigned_To__c != '' && noteList[0].ElixirSuite__Elixir_Follow_up_Date__c != ''){
                  if(noteList[0].ElixirSuite__Elixir_Follow_up_Date__c >= todayDate){
                   var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Please Select Follow Up Date less than today.",
                        "type" : "error"
                    });
                    toastEvent.fire(); 
                    return false;
                }
                return true;
            }else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": "Please Complete Follow up Notes Row Number 1",
                    "type" : "error"
                });
                toastEvent.fire(); 
                return false;
            }
            
        }else{
        for (var i = noteList.length-1; i >= 0; i--) {
            if (noteList[i].ElixirSuite__Follow_Up_Notes__c == '' || noteList[i].ElixirSuite__Elixir_Assigned_To__c == '' || noteList[i].ElixirSuite__Elixir_Follow_up_Date__c == '') {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": "Please Complete Follow up Notes Row Number "+(i+1),
                    "type" : "error"
                });
                toastEvent.fire(); 
                return false;
            }
            else if(noteList[i].ElixirSuite__Elixir_Follow_up_Date__c >= todayDate){
                   var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Please Select Follow Up Date less than today in Row Number "+(i+1),
                        "type" : "error"
                    });
                    toastEvent.fire(); 
                    return false;
                }
        }
        
        return true;
        }
    },
    validateRecommendations: function(component, event) {
        var rList = component.get("v.recommendationList");
        if(rList.length == 1){
            if((rList[0].ElixirSuite__Elixir_Recommendation__c == '' && rList[0].ElixirSuite__Elixir_Assign_To__c =='') || rList[0].ElixirSuite__Elixir_Recommendation__c != ''){
               return true; 
            }else{
                 var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": "Please fill in the recommendation for Assign To users",
                    "type" : "error"
                });
                toastEvent.fire(); 
                return false;
            }
            
        }else{
        for (var i = rList.length-1; i >= 0; i--) {
            if (rList[i].ElixirSuite__Elixir_Recommendation__c == '') {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": "Please fill in Recommendation of Row Number "+(i+1),
                    "type" : "error"
                });
                toastEvent.fire(); 
                return false;
            }
        }
        return true;
        }
    },
})
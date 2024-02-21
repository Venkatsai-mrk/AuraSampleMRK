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
        var ERAHash = component.get("v.eraHash");
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
                        'ElixirSuite__Elixir_ERA__r':{'ElixirSuite__Claim__r':{'Name':ERAHash}},
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
        for (var i = 0; i < noteList.length; i++) {
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
            else if(noteList[i].ElixirSuite__Elixir_Follow_up_Date__c <= todayDate){
                   var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Follow-up date should be greater than today's date on row "+(i+1),
                        "type" : "error"
                    });
                    toastEvent.fire(); 
                    return false;
                }
        }
        return true;
    },
    validateRecommendations: function(component, event) {
        var rList = component.get("v.recommendationList");
        for (var i = 0; i < rList.length; i++) {
            if (rList[i].ElixirSuite__Elixir_Recommendation__c == '') {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": "Recommendation is mandatory on row "+(i+1),
                    "type" : "error"
                });
                toastEvent.fire(); 
                return false;
            }
        }
        return true;
        
    },
})
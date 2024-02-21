({
	validateRecommends: function(component, event) {
        
     
        var rList = component.get("v.recommendationList");
        if(rList.length == 1){
            if((rList[0].ElixirSuite__Elixir_Recommendation__c == '' && rList[0].ElixirSuite__Elixir_Assign_To__c =='') || rList[0].ElixirSuite__Elixir_Recommendation__c != ''){
               return true; 
            }else{
                 var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": "Please Complete Recommendation",
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
                    "message": "Please Complete Recommendation Row Number "+(i+1),
                    "type" : "error"
                });
                toastEvent.fire(); 
                return false;
            }
        }
        return true;
        }

    },

fetchRecommends : function(component, event){
        
    	var action = component.get("c.fetchRecs");
        var recId = component.get("v.rec1id");
    
        action.setParams({
            "rec2Id":recId
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
                        'Id': null,
                        'ElixirSuite__Elixir_ERA__c': recId,
                        
                    });
                    component.set("v.recommendationList", nList); 
                }
            }
        });
        $A.enqueueAction(action);
        
	}
})
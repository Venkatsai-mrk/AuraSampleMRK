({
	doInit : function(component, event, helper) {
        
		helper.fetchRecommends(component,event);
	}, 
      addRecommendation : function(component, event, helper) {
        var selectedItem = event.currentTarget;
        var index = selectedItem.dataset.record;
        console.log("index "+index)  
        var recId = component.get("v.rec1id");  
        var nList = component.get("v.recommendationList");
          
           if(nList[index].ElixirSuite__Elixir_Recommendation__c ==''){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "message": "Please fill Recommendation.",
                "type" : "error"
            });
            toastEvent.fire(); 
            
        }
        else{
            nList.push({
                'sobjectType': 'ElixirSuite__Recommendation__c',
                'ElixirSuite__Elixir_Recommendation__c': '',
                'ElixirSuite__Elixir_Assign_To__c': '',
                'ElixirSuite__Elixir_ERA__c': recId,
                'Id': null,
                
            });
            component.set("v.recommendationList", nList);
        }
          
          
          
          
          
          
       //console.log("UUUUU "+JSON.stringify(nList[index].ElixirSuite__Elixir_Recommendation__c));   
       //console.log("nList"+JSON.stringify(nList));
		/* if(nList[index].ElixirSuite__Elixir_Recommendation__c !=''  ){
            //console.log("jjjjj "+JSON.stringify(nList[index].ElixirSuite__Elixir_Recommendation__c));
            
              nList.push({
                'sobjectType': 'ElixirSuite__Recommendation__c',
                'ElixirSuite__Elixir_Assign_To__c': '',
                'ElixirSuite__Elixir_ERA__c': null,
                'Id': null,
            
              });
                 component.set("v.recommendationList", nList);
            }
          
          /*else if(nList[index].ElixirSuite__Elixir_Recommendation__c !='' ){
              
               nList.push({
                'sobjectType': 'ElixirSuite__Recommendation__c',
                'ElixirSuite__Elixir_Assign_To__c': '',
                   'ElixirSuite__Elixir_ERA__c': recId,
                'Id': null,
            
              });
                 component.set("v.recommendationList", nList);
          }*/
          
      /* else if(nList[index].ElixirSuite__Elixir_Recommendation__c !=''){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": "Please fill in the recommendation for all the Assign To users for the claim ERA ",
                    "type" : "error"
                });
                toastEvent.fire(); 
        } 
            
        
        else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": "Please Complete this Row",
                    "type" : "error"
                });
                toastEvent.fire(); 
        } */
    },
     removeRecommendation: function(component, event, helper) {  
         
        var recordId = component.get("v.rec1id");       
        var recommendationList = component.get("v.recommendationList");        
        var selectedItem = event.currentTarget; 
        var deleteRecommendationList = component.get("v.deleteRecommendationList");
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
                recommendationList.splice(index, 1);
                recommendationList.push({
                        'sobjectType': 'ElixirSuite__Recommendation__c',
                        'ElixirSuite__Elixir_Recommendation__c': '',
                        'ElixirSuite__Elixir_Assign_To__c': '',
                        'ElixirSuite__Elixir_ERA__c': recordId,
                        'Id': null,
                        
                    });
                component.set("v.recommendationList", recommendationList);
                
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
    
    
     
      //To save Recommendation Data
    saveRecommends: function(component, event, helper) { 
        if (helper.validateRecommends(component, event)) {
            
            if(component.get("v.recommendationList")){
             component.get("v.recommendationList").forEach(function(rec){
                rec['ElixirSuite__Elixir_ERA__c'] = component.get("v.eraId");
             });
            }
            var action = component.get("c.saveRecList");
            action.setParams({
                "recommendationList": component.get("v.recommendationList"),
                "delRecommendationList": component.get("v.deleteRecommendationList")
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
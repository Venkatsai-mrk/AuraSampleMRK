({
	init : function(component, event, helper) {
		
        var action = component.get("c.getCriteriaFilter");
        
        action.setParams({
            "groupRecordId": component.get("v.recordId")
        });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state ==='SUCCESS'){
                component.set("v.criteriaFilter",response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
	},
    submitCriteriaFilter :  function(component, event, helper){
        var enteredFIlter = component.find("criteriafilterId").get("v.value");
        var recordId = component.get("v.recordId");
        console.log('enteredFIlter' +enteredFIlter);
        if(enteredFIlter === null || enteredFIlter ===''){
            /*console.log('enteredFIlter in' +enteredFIlter);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error",
                "type": "error",
                "message": "Please Provide Criteria Logic"
            });
            toastEvent.fire();
            console.log('enteredFIlter' +enteredFIlter);*/
            /*Nikhil------*/            
            var action = component.get("c.forEmptyLogicCriteria");
            action.setParams({
                "groupRecordId": recordId
            });           
            action.setCallback(this, function(response){
                var state = response.getState();
                if(state ==='SUCCESS'){
                    if(response.getReturnValue()=='GroupPatientUpdated'){
                        console.log('enteredFIlter--null--in--return1' +recordId);
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Success!",
                            "type":  "Success",
                            "message": "All Related Patients Removed Successfully."
                        });
                        toastEvent.fire();
                    }else if(response.getReturnValue()=='NoRelatedExit'){
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Error",
                            "type":  "error",
                            "message": "No Related Patient Exist!"
                        });
                        toastEvent.fire();
                    }
                }else if(state ==='ERROR'){                    
                    var errors = response.getError();
                    if(errors){
                        if (errors[0] && errors[0].message){                               
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title: 'Error',
                                type:  'error',
                                message: errors[0].message
                            });
                            toastEvent.fire();                            
                        }        
                     }
                 }
              });
            $A.enqueueAction(action);   
            /*Nikhil--End*/
        }else if(enteredFIlter != null){
            var action = component.get("c.saveCriteriaFilter")
            action.setParams({
                "groupRecordId": recordId,
                "filter": enteredFIlter
            });
            
            action.setCallback(this, function(response){
                var state = response.getState();
                if(state ==='SUCCESS'){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "type": "Success",
                        "message": "The Group Patients created successfully."
                    });
                    toastEvent.fire();
                }else if(state ==='ERROR'){
                    
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " +
                                        errors[0].message);
                            
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title: 'Error',
                                type: 'error',
                                message: errors[0].message
                            });
                            toastEvent.fire();
                            
                        }        
                    }
                    // alert('Please add Starting ( and ending ) in the filter wheresoever OR is present');
                }
                
            });
            $A.enqueueAction(action);
        }
    },
    handleChange : function(component, event, helper){
        
        var enteredFIlter = component.find("criteriafilterId").get("v.value");
        var recordId = component.get("v.recordId");
        
        var action = component.get("c.updateCriteriaFilterOnChange")
        action.setParams({
            "groupRecordId": recordId,
            "filter": enteredFIlter
        });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state ==='SUCCESS'){
             
                
            }else if(state ==='ERROR'){
                
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
    },
    handleFilterEvent : function(component,event){
        
        var message = event.getParam("filterLogic");
		console.log('message',message);
        component.set("v.criteriaFilter", message);
    }
})
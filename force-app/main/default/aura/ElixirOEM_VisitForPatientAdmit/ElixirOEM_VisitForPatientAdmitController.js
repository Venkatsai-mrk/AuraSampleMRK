({
    myAction : function(component, event, helper) {
    /*    var action = component.get("c.generateAutoNumber");    
        action.setParams({
            patientID:  component.get("v.patientID")
            
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var createRecordEvent = $A.get('e.force:createRecord');
                if ( createRecordEvent ) {
                    createRecordEvent.setParams({
                        'entityApiName': 'ElixirSuite__Visits__c',
                        'defaultFieldValues': {
                            'ElixirSuite__Account__c' : component.get("v.recId"),
                            'ElixirSuite__Status__c' : 'Active', 
                            'Name' : response.getReturnValue().accName+"'"+'s'+' Visit - '+response.getReturnValue().countRecords
                        }
                    });
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Info',
                        message: 'This Visit is considered until the new one is created.',
                        duration:' 6000',
                        key: 'info_alt',
                        type: 'info',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
                    createRecordEvent.fire();
                    
                    console.log("Visit creation not supported"+component.get("v.newVisit"));
                } else {
                    alert("Visit creation not supported");
                }
                alert("complete"); 
            }
        });           
        $A.enqueueAction(action);*/
    },
})
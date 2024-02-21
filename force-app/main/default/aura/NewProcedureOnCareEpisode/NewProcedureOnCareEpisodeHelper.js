({
	fetchPatientDetails: function (component, event, helper) {
        
        var action = component.get("c.getPatientDetails");
        
        action.setParams({
            'careId' : component.get("v.recordId")
        });
        action.setCallback(this,function(response) {
            
            var state = response.getState();
            console.log('fetchPatientDetails***',state);
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('result fetchPatientDetails***upd1',result);
                component.set('v.patientId',result.patientRecId);
                component.set('v.preAuthNum',result.preAuthNumber);

                component.set('v.medicalCodingScreen',true);
        }
            else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            this.globalFlagToast(component, event, helper,errors[0].message,' ','error');
                        }
                    }
                }
            });
        $A.enqueueAction(action);
        
    },
    
    globalFlagToast : function(cmp, event, helper,title,message,type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message":  message,
            "type" :type
        });
        toastEvent.fire();
    }
})
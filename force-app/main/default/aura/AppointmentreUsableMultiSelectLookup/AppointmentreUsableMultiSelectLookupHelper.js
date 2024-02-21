({


    mg: [],

    alertMessage: function (component, event, Patientarray) {
        //remove if statement for multiple patients
        if (Patientarray.length === 1) {
            var alertCount = component.get("v.alertCountByAdmin");
            var sessionCount = component.get("v.Count");
            console.log('Length ', Patientarray.length);
            console.log('Patient ', Patientarray[Patientarray.length - 1].Id);
            console.log('Patient', Patientarray[Patientarray.length - 1].Name);
            var action = component.get("c.getsessionPredefinedNo");
            action.setCallback(this, function (response) {
                var state = response.getState();
                console.log('alertstate', state)
                if (state === "SUCCESS") {
                    component.set("v.alertCountByAdmin", response.getReturnValue());
                    alertCount = (component.get("v.alertCountByAdmin")[0].ElixirSuite__UR_Alert_when_usable_session_count_below__c);
                    console.log('alertCount:', alertCount);
                }
            });
            $A.enqueueAction(action);
            var patient_ID = Patientarray[Patientarray.length - 1].Id;
            console.log('patient_ID', patient_ID);
            var action = component.get("c.getSessionCount");
            //action.setParams({recId :"0011m00000c5vreAAA"});
            action.setParams({
                recId: patient_ID
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                console.log('sessionstate', state);
                if (state === "SUCCESS") {
                    component.set("v.Count", response.getReturnValue());
                    sessionCount = (component.get("v.Count")[0].ElixirSuite__Sessions_Available__c);
                    console.log('sessionCount:', sessionCount);
                    //Showing the alert based on the if conditions
                    if (sessionCount < alertCount && alertCount != undefined) {
                        var patient_Name = Patientarray[Patientarray.length - 1].Name;
                        console.log('Patient', patient_Name);
                        var message = 'There are only ' + sessionCount + ' authorized sessions remaining for ' + patient_Name;
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title: 'Alert',
                            type: 'Warning',
                            message: message
                        });
                        toastEvent.fire();
                    }
                }

            });
            $A.enqueueAction(action);
        }
    },

    searchHelper: function (component, event, getInputkeyWord) {
        // call the apex class method 
        var action = component.get("c.fetchLookUpValues");
        // set param to method  
        console.log('assignedTo', component.get("v.selectedAssignedToRecord"));

        var assignedToId = '';
        if (component.get("v.selectedAssignedToRecord")) {
            assignedToId = component.get("v.selectedAssignedToRecord").Id;
        }

        var coFacId = '';
        if (component.get("v.selectedCofacToRecord")) {
            coFacId = component.get("v.selectedCofacToRecord").Id;
        }
        console.log('cofac', component.get("v.selectedCofacToRecord").Id);


        action.setParams({
            'searchKeyWord': getInputkeyWord,
            'ObjectName': component.get("v.objectAPIName"),
            'ExcludeitemsList': component.get("v.lstSelectedRecords"),
            'assignedTo': assignedToId,
            'coFacilitator': coFacId
        });
        // set a callBack    
        action.setCallback(this, function (response) {
            $A.util.removeClass(component.find("mySpinner"), "slds-show");
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                // if storeResponse size is equal 0 ,display No Records Found... message on screen.                }
                if (storeResponse.length == 0) {
                    component.set("v.Message", 'No Records Found...');
                } else {
                    component.set("v.Message", '');
                    // set searchResult list with return value from server.
                }
                component.set("v.listOfSearchRecords", storeResponse);
            }
        });
        // enqueue the Action  
        $A.enqueueAction(action);
    },
})
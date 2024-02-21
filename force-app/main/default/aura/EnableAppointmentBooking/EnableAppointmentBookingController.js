({
  doInit: function (component, event, helper) {
    component.set("v.showSpinner", true);
    var action = component.get("c.getAppointmentTypes");

    action.setCallback(this, function (response) {
        var state = response.getState();

        if (state === "SUCCESS") {
            var picklistValues = response.getReturnValue();
            console.log('picklistValues:', picklistValues);

            // Map the picklist values to the expected structure
            var options = picklistValues.map(function (entry) {
                return { label: entry.label, value: entry.value };
            });

            component.set("v.picklistOptions", options);

            var appointmentColumns = component.get("c.getAppointmentColumns");

            appointmentColumns.setCallback(this, function(response) {
                var result = response.getReturnValue();
                console.log('getting values for appointmentColumns**** '+result);
                var state = response.getState();
                console.log('state '+state);
                if (state === "SUCCESS") {
                
                    var result = response.getReturnValue();
                  //  var resCol  = result.appointmentColumns;
                    var reqFieldsMap  = result.mapRequiredFields;
                    
                    var reqFieldsList = [];
                    for (var key in reqFieldsMap) {
                        if (reqFieldsMap.hasOwnProperty(key)) {
                            var label = key;
                            var value = reqFieldsMap[key];

                            // Check for specific labels and modify them accordingly
                            if (label === 'Created By ID') {
                                label = 'Created By';
                            } else if (label === 'Last Modified By ID') {
                                label = 'Last Modified By';
                            }
                            else if (label === 'Name ID') {
                                label = 'Name';
                            }

                            reqFieldsList.push({ label: label, value: value });
                           // reqFieldsList.push({ label: key, value: reqFieldsMap[key] });
                        }
                    }
                    console.log('reqFieldsList lemmgth'+reqFieldsList.length) 
                    console.log('reqFieldsList list'+JSON.stringify(reqFieldsList))
                    component.set("v.options", reqFieldsList);
                    
                    var reqFieldsApi  = result.requiredFieldsApi;
                    var reqFieldsLabel = result.requiredFieldsLabel;
                    component.set("v.reqFieldApi", reqFieldsApi);
                    component.set("v.reqFieldLabel", reqFieldsLabel);
                }
                else{
                    var errors = response.getError();
                    if (errors && Array.isArray(errors) && errors.length > 0) {                   
                        console.log(errors[0].message);
                    }
                }
            });
            $A.enqueueAction(appointmentColumns); 

            var fetchRecordAction = component.get("c.fetchRecordWithSelectedValues");

            fetchRecordAction.setCallback(this, function (response) {
                var state = response.getState();

                if (state === "SUCCESS") {
                    var record = response.getReturnValue();
                    console.log('Fetched record:', record);
                    
                    if (record) {
                        if(!$A.util.isUndefinedOrNull(record.ElixirSuite__Appointment_types__c)){
                            var selectedValues = JSON.parse(record.ElixirSuite__Appointment_types__c);
                            var selectedValuesArray = selectedValues.map(item => item.value);
                            component.set("v.selectedValues", selectedValuesArray);
                        }

                        if (!$A.util.isUndefinedOrNull(record.ElixirSuite__Columns_for_Portal_Appointment__c)) {
                            var selectedValuesforAppointmentColumns = record.ElixirSuite__Columns_for_Portal_Appointment__c.split(';');
                            component.set("v.values", selectedValuesforAppointmentColumns);
                        }
                        component.set("v.appointmentBookingValue", record.ElixirSuite__Enable_Appointment_Booking__c);
                        component.set("v.enablePayNowValue", record.ElixirSuite__Enable_Pay_Now__c);
                        component.set("v.enableScheduleZoomMeeting", record.ElixirSuite__Allow_patient_to_schedule_zoom_meeting__c);

                    }
                } else {
                    console.log("Failed with state: " + state);
                }
                component.set("v.showSpinner", false);
            });

            $A.enqueueAction(fetchRecordAction);
        } else {
            console.log("Failed with state: " + state);
        }
    });

    $A.enqueueAction(action);
},



    handleCheckboxChange: function (component, event, helper) {
        var isChecked = component.get("v.appointmentBookingValue");
        var action = component.get("c.updateMasterRecord");
        action.setParams({ "enableAppointmentBookingValue": isChecked });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("Success");
            } else {
                console.error("Error: " + state);
            }
        });

        $A.enqueueAction(action);
    },
    
    handleSave: function (component, event, helper) {
    component.set("v.showSpinner", true);
    var selectedValues = component.get("v.selectedValues");
    var appointmentBookingValue = component.get("v.appointmentBookingValue");
    var enablePayNowValue = component.get("v.enablePayNowValue");
    var enableScheduleZoomMeeting = component.get("v.enableScheduleZoomMeeting");
    var valuesForAppointmentColumns = component.get("v.values");
    var valuesForAppointmentColumnsString = valuesForAppointmentColumns.join(';');

    console.log('valuesForAppointmentColumns in enable appointment : '+valuesForAppointmentColumns);

    console.log('valuesForAppointmentColumns.length: '+valuesForAppointmentColumns.length);
    if (valuesForAppointmentColumns.length > 15) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: "Error",
            message: "You can only select up to 15 values for Appointment Columns.",
            type: "error"
        });
        toastEvent.fire();
        component.set("v.showSpinner", false);
        return;
    }

    if (appointmentBookingValue && selectedValues.length === 0) {
        // Display a toast message and exit the function
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: "Error",
            message: "Please select at least one Appointment Type to proceed",
            type: "error"
        });
        toastEvent.fire();
        component.set("v.showSpinner", false);
        return;
    }
    
    var picklistOptions = component.get("v.picklistOptions");
    var result = selectedValues.map(selectedValue => {
        var matchingItem = picklistOptions.find(item => item.value === selectedValue);
        return matchingItem ? { label: matchingItem.label, value: matchingItem.value } : null;
    }).filter(item => item !== null);
    var action = component.get("c.saveRecord");
    action.setParams({
        selectedValues: JSON.stringify(result),
        appointmentBookingValue: appointmentBookingValue,
        enablePayNowValue: enablePayNowValue,
        enableScheduleZoomMeeting: enableScheduleZoomMeeting,
        valuesForAppointmentColumns: valuesForAppointmentColumnsString
    });
    
    action.setCallback(this, function (response) {
        var state = response.getState();
        if (state === "SUCCESS") {
            console.log("Record saved successfully");
            component.set("v.showSpinner", false);
            var refreshEvt = $A.get("e.c:AppointmentColumnRefreshEvent");
                refreshEvt.setParams({
                    "columns": component.get("v.values"),
                    "finalColumnsApi": component.get("v.reqFieldApi"),
                    "finalColumnsLabel": component.get("v.reqFieldLabel")
                });
                refreshEvt.fire();
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                message: "Appointment Settings saved.",
                type: "success"
            });
            toastEvent.fire();
        } else {
            console.error("Error: " + state);
        }
    });
    
    $A.enqueueAction(action);
}

})
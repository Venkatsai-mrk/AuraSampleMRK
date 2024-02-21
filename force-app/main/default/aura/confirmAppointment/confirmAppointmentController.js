({
    doInit : function(component, event, helper) {
        var meetingNameValue = $A.get("$Label.c.MeetingName");
        component.set("v.meetingName",meetingNameValue);
        helper.getPatientId(component, event, helper);
        helper.getScheduleZoomMeetingValue(component, event, helper);
        var sub = 'Appointment with ' + component.get("v.practionerName");
        component.set("v.subject",sub);
        component.set("v.confirmPatientBooking", false);
        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD")
        component.set("v.startDateVal",today);
        var providerId = component.get("v.locationId");
        var accId = component.get("v.recordId");
        var action = component.get("c.wrapperRec");
        var pratId =  component.get("v.practionerId");
        action.setParams({
            'recId' : accId,
            'proId' : providerId,
            'practId' : pratId
        });
        action.setCallback(this,function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var resultData = response.getReturnValue();
                component.set("v.locationLst", resultData.providerRecord);
                var providerId = component.get("v.locationLst");
                component.set("v.providerId", providerId[0].Id);
                component.set("v.accLst", resultData.accrecord);
                var accList = component.get("v.accLst");
                component.set("v.patientName", accList[0].Name);
                component.set("v.conLst", resultData.conrecord);
                
                var discRecordsValues = resultData.generalDiscLst;
                                var allDiscJson = [];
                
                var accType = component.get("v.appointmentType");
                console.log('accType2***',accType);
                                if(discRecordsValues == null){
                                        component.set("v.noDisclaimer", true);
                }
                else{
                                        
                    for (let i = 0; i < discRecordsValues.length; i++) {
                        var singleObj = {};
                        if(discRecordsValues[i].ElixirSuite__Type__c =='General'){
                            
                            singleObj['disclaimerId'] = discRecordsValues[i].Id;
                            singleObj['description'] = discRecordsValues[i].ElixirSuite__Description__c;
                            singleObj['agreement'] = false;
                            singleObj['requireAgreement'] = discRecordsValues[i].ElixirSuite__Require_Agreement__c;
                            singleObj['priorityOrder'] = discRecordsValues[i].ElixirSuite__Priority_Order__c;
                            
                            singleObj['inputType'] = discRecordsValues[i].ElixirSuite__Input_type__c;
                            singleObj['inputBox'] = '';
                            
                            if(discRecordsValues[i].ElixirSuite__Input_type__c ==null){
                                singleObj['noneType'] = true;
                            }
                            else{
                                singleObj['noneType'] = false;
                            }
                            if(discRecordsValues[i].ElixirSuite__Input_type__c =='Checkbox'){
                                singleObj['checkBoxType'] = true;
                            }
                            else{
                                singleObj['checkBoxType'] = false;
                            }
                            allDiscJson.push(singleObj);
                        }
                        }
                    
                    for (let i = 0; i < discRecordsValues.length; i++) {
                        var singleObj = {};
                        if(discRecordsValues[i].ElixirSuite__Type__c =='Appointment' && discRecordsValues[i].ElixirSuite__Template_Procedure__c !=null && discRecordsValues[i].ElixirSuite__Template_Procedure__r.Name ==accType){
                          
                            singleObj['disclaimerId'] = discRecordsValues[i].Id;
                            singleObj['description'] = discRecordsValues[i].ElixirSuite__Description__c;
                            singleObj['agreement'] = false;
                            singleObj['requireAgreement'] = discRecordsValues[i].ElixirSuite__Require_Agreement__c;
                            singleObj['priorityOrder'] = discRecordsValues[i].ElixirSuite__Priority_Order__c;
                            
                            singleObj['inputType'] = discRecordsValues[i].ElixirSuite__Input_type__c;
                            singleObj['inputBox'] = '';
                            
                            if(discRecordsValues[i].ElixirSuite__Input_type__c ==null){
                                singleObj['noneType'] = true;
                            }
                            else{
                                singleObj['noneType'] = false;
                            }
                            if(discRecordsValues[i].ElixirSuite__Input_type__c =='Checkbox'){
                                singleObj['checkBoxType'] = true;
                            }
                            else{
                                singleObj['checkBoxType'] = false;
                            }

                            allDiscJson.push(singleObj);
                        }
                        
                        
                    }
                    
                        
                        for (let i = 0; i < discRecordsValues.length; i++) {
                        var singleObj = {};
                        
                        if(discRecordsValues[i].ElixirSuite__Type__c =='Practitioner' && discRecordsValues[i].ElixirSuite__Practitioner__c ==pratId){
                          
                        singleObj['disclaimerId'] = discRecordsValues[i].Id;
                            singleObj['description'] = discRecordsValues[i].ElixirSuite__Description__c;
                            singleObj['agreement'] = false;
                            singleObj['requireAgreement'] = discRecordsValues[i].ElixirSuite__Require_Agreement__c;
                            singleObj['priorityOrder'] = discRecordsValues[i].ElixirSuite__Priority_Order__c;
                            
                            singleObj['inputType'] = discRecordsValues[i].ElixirSuite__Input_type__c;
                            singleObj['inputBox'] = '';
                            
                            if(discRecordsValues[i].ElixirSuite__Input_type__c ==null){
                                singleObj['noneType'] = true;
                            }
                            else{
                                singleObj['noneType'] = false;
                            }
                            if(discRecordsValues[i].ElixirSuite__Input_type__c =='Checkbox'){
                                singleObj['checkBoxType'] = true;
                            }
                            else{
                                singleObj['checkBoxType'] = false;
                            }

                            allDiscJson.push(singleObj);
                        }
}
                        
                        
                                        
                    console.log('allDiscJson***',allDiscJson);
                    component.set("v.allDisclaimersJson", allDiscJson);
                    if(allDiscJson.length == 0){
                        component.set("v.noDisclaimer", true);
                    }
                    else{
                        component.set("v.noDisclaimer", false);
                    }
                                    }
                
            }
        });
        $A.enqueueAction(action); 
    },

    
    onValueChanged1 :  function(component, event, helper){
        var checkVal = event.getSource().get("v.checked");
        var checkId = event.getSource().get("v.name");
                var discJson = component.get("v.allDisclaimersJson");
        
        for (let i = 0; i < discJson.length; i++) {
            
        if(discJson[i].disclaimerId == checkId){
            discJson[i].agreement = checkVal;
            }
        }
        
        component.set("v.allDisclaimersJson", discJson);
        
    },
        
    handlePrev : function(component) {
        component.set("v.showAvalibility", true);
    },
    handleNext :  function(component, event, helper){
        var confirmLabel = event.getSource().get("v.label");
        if(confirmLabel == 'Confirm'){
            component.set("v.confirmPatientBooking", true);
            component.set("v.byPassPatientBooking", false);
        }else{
            component.set("v.confirmPatientBooking", false);
        }
                
        var allDisclaimersLst =  component.get("v.allDisclaimersJson");
        
        var discNotCheck = false;
        
        console.log('allDisclaimersLst***',allDisclaimersLst);
        
        for (let i = 0; i < allDisclaimersLst.length; i++) {
            if(allDisclaimersLst[i].agreement != allDisclaimersLst[i].requireAgreement && allDisclaimersLst[i].checkBoxType == true){
                discNotCheck = true;
                break;
            }
            if(allDisclaimersLst[i].requireAgreement && allDisclaimersLst[i].checkBoxType == false && allDisclaimersLst[i].inputBox == ''){
                discNotCheck = true;
                break;
            }
        }
        
        if(discNotCheck){
            
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error",
                "message": "Please accept all disclaimers before proceeding!!",
                "type" : "error",
                "mode" : "dismissible"
            });
            toastEvent.fire();
            return;
        }
        
        var currentTime = new Date();
        var jsDatetime = currentTime.toISOString();
        // Add 30 minutes to the current time
        var futureTime = new Date();
        futureTime.setMinutes(currentTime.getMinutes() + 30);
        var jsendDatetime = futureTime.toISOString();
        
        component.set("v.StartDateTime",jsDatetime);
        component.set("v.EndDateTime",jsendDatetime);
        var accId = component.get("v.recordId");
        var locId = component.get("v.locationId");
        var praId = component.get("v.practionerId");
        var accType = component.get("v.appointmentType");
        var accTypeLabel = component.get("v.appointmentTypeLabel");
        var schedulemetting =  component.get("v.isChecked");
        var mettingLink =  component.get("v.virtualMeetingLink");
        var addattendees =  component.get("v.additionalAttendees");
        var message = component.get("v.addComments");
        var sObjLst;
        if(allDisclaimersLst.length > 0){
            sObjLst = {'keysToSave' : component.get("v.allDisclaimersJson")};
        }
        console.log('message****',message);
        console.log('accTypeLabel****',accTypeLabel);
        var action = component.get("c.saveMethod");
        action.setParams({
            'startDate' : (component.get("v.selectedSlot")).startDate,
            'endDate' : (component.get("v.selectedSlot")).endDate,
            'whatId' : accId,
            'locationId' : locId,
            'practitonerId' : praId,
            'acctype' : accType,
            'accTypeLabel' : accTypeLabel,
            'roomId' : (component.get("v.selectedRoomRecord")).value,
            'confirmAppointment' : component.get("v.confirmPatientBooking"),
            'checkbox' : schedulemetting,
            'link' : mettingLink,
            'attendees' : addattendees,
            'additionalComments' : message,
            'disclaimerLst': JSON.stringify(sObjLst)
        });
        action.setCallback(this,function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var workspaceAPI = component.find("workspace"); 
                workspaceAPI.getFocusedTabInfo().then(function(response) {
                    var focusedTabId = response.tabId;
                    workspaceAPI.closeTab({tabId: focusedTabId});
                })
                .catch(function(error) {
                    console.log(error);
                });
                
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Success',
                    message: 'Your appointment has been scheduled',
                    duration:' 5000',
                    type: 'success',
                    mode: 'pester'
                });
                toastEvent.fire();
                
                var patientAccountId = component.get("v.portalAccountId");
                if(!$A.util.isUndefinedOrNull(patientAccountId)){
                    switch(component.get("v.route")) {
                        case "AppointmentTab" :
                            var navService = component.find("navigationService");
                            var pageReference = {
                                type: "standard__webPage", 
                                attributes: {
                                    url: "/myappointments"
                                }
                            }
                            navService.navigate(pageReference);
                            break;
                        case "homePageAppointment" :
                            var navService1 = component.find("navigationService");
                            var pageReference1 = {
                                type: "standard__webPage", 
                                attributes: {
                                    url: "/"
                                }
                            }
                            navService1.navigate(pageReference1);
                    }
                }
                else{
                    var redirectURL = response.getReturnValue().eventId;
                    component.find("navigationService").navigate({
                        "type": "standard__recordPage",
                        "attributes": {
                            "recordId": redirectURL,
                            "objectApiName": "Event",
                            "actionName": "view"
                        }
                    });
                }
$A.get('e.force:refreshView').fire();
                
            }else if(state === "ERROR"){
                
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        var toastEvent1 = $A.get("e.force:showToast");
                        if(errors[0].message == 'Appointment is already booked for this slot, please select a new time.'){
                            toastEvent1.setParams({
                                "title": "Slot already booked!",
                                "message": errors[0].message,
                                "type" : "error"
                            });
                        }
                        else if(errors[0].message == 'The room is already booked for this slot, please select a new room or time.'){
                            helper.getConflictRoom(component, locId, praId,errors[0].message);
                        }
                            else if(errors[0].message == 'Patient already has an appointment for this time slot.'){
                                component.set("v.byPassPatientBooking",true);
                                let customLabelValue = $A.get("$Label.c.PatientBookingAlert");
                                let customValue = customLabelValue.replace("<Patient Name>", "");
                                var proceedText = customValue.split('. ')[1];
                                component.set("v.patientBookingAlert2",proceedText);
                                customValue = customValue.replace(proceedText, "");
                                component.set("v.patientBookingAlert",customValue);
                            }else{
                                toastEvent1.setParams({
                                    "title": errors[0].message,
                                    "message": errors[0].message,
                                    "type" : "error"
                                });
                            }
                        toastEvent1.fire();   
                    }
                }
                $A.get('e.force:refreshView').fire();
            }
        });
        $A.enqueueAction(action);
    },
    closePopUp:function(component){
        component.set("v.byPassPatientBooking", false);
    },
    handleCheckboxChange:function(component){
        
        var isChecked = component.get("v.isChecked");
        if (isChecked) {
            component.set("v.schedule", true);
            var conList = component.get("v.conLst");
            component.set("v.virtualMeetingLink", conList[0].ElixirSuite__Virtual_Meeting_Link__c);
        } else {
            component.set("v.schedule", false);
            component.set("v.virtualMeetingLink", '');
            component.set("v.additionalAttendees", '');
        }
    }
})
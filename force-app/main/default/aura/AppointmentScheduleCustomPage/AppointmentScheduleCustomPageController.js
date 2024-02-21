({
    doInit: function (component, event, helper) {
       /* var action = component.get("c.getSubject");
        var inputIndustry = component.find("InputSubject");
        var opts = [];
        var weekday = component.get("v.weekDays");
        console.log("weekday====" + weekday);
        var timeZone = component.get("v.timeZone");
        console.log("timeZone====" + timeZone);


        action.setCallback(this, function (a) {
            opts.push({
                class: "optionClass",
                label: "--- None ---",
                value: ""
            });
            for (var i = 0; i < a.getReturnValue().length; i++) {
                opts.push({ "class": "optionClass", label: a.getReturnValue()[i], value: a.getReturnValue()[i] });
            }
            inputIndustry.set("v.options", opts);


        });
        $A.enqueueAction(action); */
        helper.statusListItemsView(component);
    },

    onPicklistChange: function (component, event, helper) {
        //get the value of select option
        var selectedIndustry = component.find("InputSubject");
        alert(selectedIndustry.get("v.value"));
    },
    ondaysChange: function (component, event, helper) {
        //get the value of select option
        var selectedDays = component.find("InputSubject");
        alert(selectedDays.get("v.value"));
    },


    closeModel: function (component, event, helper) {
        component.set("v.isModalOpen", false);
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/lightning/o/Event/home"
        });
        urlEvent.fire();
    },
    moveNext: function (component, event, helper) {
        console.log('inside moveNext function');
        let grpArr = component.get("v.selectedGroupRecords");
        let idArr = [];
        for (let obj in grpArr) {
            idArr.push(grpArr[obj].Id);
        }
        var action = component.get("c.getAllPatientDetailsFromGroupIDs");
        action.setParams({
            groupIDs: idArr
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('rep 1 complete ' + JSON.stringify(response.getReturnValue()));
                var respForPatientDataFromGroup = response.getReturnValue();
                var patientArray = [];
                var patientIds = [];
                var patientGroupArray = [];
                var patientGroupIds = [];
                var accountArray = [];
                var accountIds = [];
                var coFacilitatorArray = [];
                var coFacilitatorIds = [];

                var equipArray = [];
                var equipIds = [];
                var accAdditional = [];
                var practitionerArray = [];
                var practitionerIds = [];
                var equipmentArray = []; //added by 
                var equipmentIds = [];
                var subjectIds;

                var byPassCheck = component.get("v.ByPassEvent");
                var locationId = component.get("v.selectedRecordOfLocation").Id;
                var roomId = component.get("v.selectedRecordOfRoom").Id;
                var roomSet = component.get("v.selectedRecordOfRoom");
                var assignedTo = component.get("v.selectedRecordOfAssignedTo").Id;
                var subject = component.get("v.selectedSubjectRecords").Id; //added

                var locCheck = 'Matched';
                equipArray = component.get("v.equipList");
                equipArray.forEach(eq => equipIds.push({ 'Id': eq.Id, 'EquipmentNeed': eq.Needed }));
                var matchedCount = 0;
                console.log('llnn', equipArray);
                console.log('llnn', locationId);

                var invalidEquipQuantity = false;
                var invalidEquipQuantityMessage = 'Equipment quantity incorrect for Equipment ';

                equipArray.forEach(function (eq) {
                    console.log('inside', eq.Needed);
                    console.log('inside', eq);
                    if (eq.Needed != '') {
                        if (eq.Needed > 0) {

                        } else {
                            invalidEquipQuantity = true;
                            invalidEquipQuantityMessage += eq.Equipment + ',';
                        }
                    }
                });

                console.log('invalidEquipQuantity', invalidEquipQuantity);

                invalidEquipQuantityMessage = invalidEquipQuantityMessage.replace(/,\s*$/, "");
                console.log('invalidEquipQuantity', invalidEquipQuantityMessage);
                var eqLength = 0;
                equipArray.forEach(function (eq) {
                    if (eq.location == locationId) {
                        // locCheck='Unmatched';
                        matchedCount = matchedCount + 1;
                    }
                    if (eq.Id) {
                        eqLength = eqLength + 1;
                    }
                });


                if (roomId) {
                    if (roomSet.ElixirSuite__Location__c != locationId) {
                        locCheck = 'Unmatched';
                    } else {
                        locCheck = 'Matched';
                    }
                }
                console.log('llnn', equipArray.length);
                console.log('count', matchedCount);
                console.log('locCheck', locCheck);

                //practitionerArray = component.get("v.selectedAccountRecords");
                //practitionerArray.forEach( practitioner => practitionerIds.push( practitioner.Id));

                patientArray = component.get("v.selectedAccountRecords");
                patientArray.forEach(patient => patientIds.push(patient.Id));
                let profilePicId = '';

                patientArray.forEach(function (patient) {
                    if (patient.hasOwnProperty('ElixirSuite__Profile_Picture__c')) {
                        profilePicId = patient.ElixirSuite__Profile_Picture__c;
                    }

                    accAdditional.push({
                        'patientId': patient.Id, 'patientName': patient.Name, 'attended': true, 'profilePicIId': profilePicId
                    });
                });
                respForPatientDataFromGroup.forEach(function (patient) {
                    if (patient.hasOwnProperty('ElixirSuite__Current_Patient_Name__r')) {
                        accAdditional.push({
                            'patientId': patient.ElixirSuite__Current_Patient_Name__r.Id, 'patientName': patient.ElixirSuite__Current_Patient_Name__r.Name, 'attended': true, 'profilePicIId': patient.ElixirSuite__Current_Patient_Name__r.ElixirSuite__Profile_Picture__c
                        });

                    }


                });

                const uniqueIds = [];

                const unique = accAdditional.filter(element => {
                    const isDuplicate = uniqueIds.includes(element.patientId);

                    if (!isDuplicate) {
                        uniqueIds.push(element.patientId);

                        return true;
                    }

                    return false;
                });


                console.log('unique ' + unique);
                console.log('parentAA', JSON.stringify(accAdditional));

                patientGroupArray = component.get("v.selectedGroupRecords");
                patientGroupArray.forEach(patientGroup => patientGroupIds.push(patientGroup.Id));

                accountArray = component.get("v.selectedBussinessAccountsRecords");
                accountArray.forEach(acc => accountIds.push(acc.Id));

                coFacilitatorArray = component.get("v.selectedCoFacilitatorsRecords");
                coFacilitatorArray.forEach(cofacilitator => coFacilitatorIds.push(cofacilitator.Id));

                subjectArray = component.get("v.selectedSubjectRecords");
                subjectArray.forEach(subject => subjectIds.push(subject.Id));
                console.log('Subject Id: ---' + subject);

                practitionerArray = component.get("v.selectedContactRecords");
                practitionerArray.forEach(practitioner => practitionerIds.push(practitioner.Id));
                console.log('Practtioner Id: ---' + practitionerIds);

                if (!$A.util.isEmpty(practitionerArray)) {
                    var selectedpractitioner = practitionerIds[0];

                }

                var whatId = '';
                if (!$A.util.isEmpty(component.get("v.selectedAccountRecords"))) {
                    var whatId = component.get("v.selectedAccountRecords")[0].Id;
                }

                var isChecked = component.get("v.AllDayEvent");
                var starttime;
                var endtime;
                if (isChecked) {

                    starttime = component.get("v.StartDate");
                    endtime = component.get("v.EndDate");
                } else {

                    starttime = component.get("v.StartTime");
                    endtime = component.get("v.EndTime");
                }


                console.log('equip', JSON.stringify(component.get("v.equipList")));

                if (starttime === null) {
                    helper.showToast(component, event, 'Please Provide Start Date and Time');
                }
                if (endtime === null) {
                    helper.showToast(component, event, 'Please Provide End Date and Time');
                }
                if (patientIds.length === 0 && patientGroupIds.length === 0) {
                    helper.showToast(component, event, 'Please Provide Either patient or patient group');
                }

                // var action = component.get("c.insertEventDataObject");

                action.setParams({
                    "currentUserId": assignedTo,
                    "byPass": byPassCheck,
                    "patients": JSON.stringify(patientIds),
                    "patientGroups": JSON.stringify(patientGroupIds),
                    "bussinessAccounts": JSON.stringify(accountIds),
                    "coFacilitators": JSON.stringify(coFacilitatorIds),
                    "startdate": new Date(starttime),
                    "enddate": endtime,
                    "locId": locationId,
                    "roomId": roomId,
                    "allDayEvent": isChecked,
                    "equipments": JSON.stringify(equipIds),
                    "accountAdditionalInfo": JSON.stringify({ 'key': unique })
                });


                if (starttime.length > 0 && endtime.length > 0 && (patientIds.length > 0 || patientGroupIds.length > 0)) {
                    if (endtime >= starttime) {
                        if (!coFacilitatorIds.includes(assignedTo)) {
                            if (!invalidEquipQuantity) {
                                console.log('locCheck', locCheck);
                                if (eqLength == matchedCount && locCheck == 'Matched') {
                                    console.log('bypassErr', component.get("v.showByPassErr"));
                                    console.log('multierr', component.get("v.showByPassErrForMultiSelect"));
                                    console.log('lookuperr', component.get("v.showByPassErrForLookupSelect"));
                                    console.log('equipmentErr', component.get("v.equipmentErr"));

                                    console.log('bypassevent', component.get("v.ByPassEvent"));
                                    if (component.get("v.ByPassEvent")) {
                                        action.setCallback(this, function (response) {

                                            var state = response.getState();
                                            console.log('state', state);
                                            if (state === 'SUCCESS') {
                                                try {
                                                    var res = response.getReturnValue();
                                                    console.log('res', res);

                                                    var createEvent = $A.get("e.force:createRecord");
                                                    createEvent.setParams({
                                                        "entityApiName": "Event",
                                                        "defaultFieldValues": {
                                                            'IsAllDayEvent': isChecked,
                                                            'StartDateTime': new Date(starttime).toISOString(),
                                                            'EndDateTime': new Date(endtime).toISOString(),
                                                            'OwnerId': assignedTo,
                                                            'WhatId': whatId,
                                                            'ElixirSuite__By_Pass_Check__c': byPassCheck,
                                                            'ElixirSuite__Event_Data_Object__c': res,
                                                            'ElixirSuite__Is_custom_screen__c': true,
                                                            'ElixirSuite__Practitioner__c': selectedpractitioner

                                                        }
                                                    });
                                                    createEvent.fire();
                                                }
                                                catch (e) {
                                                    alert(e);
                                                }
                                            }
                                        });
                                        $A.enqueueAction(action);

                                    } else {

                                        if (component.get("v.showByPassErrForMultiSelect") === false && component.get("v.showByPassErrForLookupSelect") === false && component.get("v.equipmentErr") === false) {
                                            //no error

                                            action.setCallback(this, function (response) {

                                                var state = response.getState();
                                                console.log('state', state);
                                                if (state === 'SUCCESS') {
                                                    try {
                                                        var res = response.getReturnValue();
                                                        console.log('res', res);
                                                        var createEvent = $A.get("e.force:createRecord");
                                                        createEvent.setParams({
                                                            "entityApiName": "Event",
                                                            "defaultFieldValues": {
                                                                'IsAllDayEvent': isChecked,
                                                                'StartDateTime': new Date(starttime).toISOString(),
                                                                'EndDateTime': new Date(endtime).toISOString(),
                                                                'OwnerId': assignedTo,
                                                                'WhatId': whatId,
                                                                'ElixirSuite__By_Pass_Check__c': byPassCheck,
                                                                'ElixirSuite__Event_Data_Object__c': res,
                                                                'ElixirSuite__Is_custom_screen__c': true,
                                                                'ElixirSuite__Practitioner__c': selectedpractitioner
                                                            }
                                                        });
                                                        createEvent.fire();
                                                    }
                                                    catch (e) {
                                                        alert(e);
                                                    }
                                                }
                                            });
                                            $A.enqueueAction(action);
                                        } else {
                                            helper.showToast(component, event, component.get("v.ByPassErrMessage"));
                                        }
                                    }
                                } else {
                                    helper.showToast(component, event, 'The Room and Equipment selected do not match the selected Location');
                                    //Please re-select room and Equipment Since location is changed
                                }
                            } else {
                                helper.showToast(component, event, invalidEquipQuantityMessage);
                            }
                        } else {
                            helper.showToast(component, event, 'Assigned To and Co-facilitator cannot be same');
                        }
                    } else {
                        helper.showToast(component, event, 'Start date/Time should not be greater than End Date/Time');
                    }
                }
            }
        });

        $A.enqueueAction(action);

    },
    checkboxSelect: function (component, event, helper) {

        component.set("v.AllDayEvent", event.getSource().get('v.checked'));

        component.set("v.StartDate", $A.localizationService.formatDate(new Date(), "YYYY-MM-DD"));
        component.set("v.EndDate", $A.localizationService.formatDate(new Date(), "YYYY-MM-DD"));

        var checked = event.getSource().get('v.checked');
        if (!checked) {
            component.set("v.StartTime", '');
            component.set("v.EndTime", '');
        }
    },
    bypassSelect: function (component, event, helper) {

        component.set("v.ByPassEvent", event.getSource().get('v.checked'));

    },

    starttimeChange: function (component, event, helper) {

        var startd = event.getSource().get('v.value');
        component.set("v.StartDateTime", startd);
        if (component.get("v.EndTime") != undefined || component.get("v.EndTime") != null) {
            helper.startOrEndDateHandler(component, event);
        }

    },
    endtimeChange: function (component, event, helper) {

        var endd = event.getSource().get('v.value');
        component.set("v.EndDateTime", endd);

        if (component.get("v.StartTime") != undefined || component.get("v.StartTime") != null) {

            helper.startOrEndDateHandler(component, event);
        }
    },
    startdateChange: function (component, event, helper) {

        var startd = event.getSource().get('v.value');
        if (component.get("v.EndDate") != undefined || component.get("v.EndDate") != null) {
            component.set("v.StartDate", $A.localizationService.formatDate(new Date(startd), "YYYY-MM-DD"));
            helper.startOrEndDateHandler(component, event);
        }
    },
    enddateChange: function (component, event, helper) {

        var endd = event.getSource().get('v.value');
        if (component.get("v.StartDate") != undefined || component.get("v.StartDate") != null) {
            component.set("v.EndDate", $A.localizationService.formatDate(new Date(endd), "YYYY-MM-DD"));

            helper.startOrEndDateHandler(component, event);
        }
    },




 mySave1: function(cmp,event,helper){
        var weekday =cmp.get("v.weekDays");
        var changedtimeZone = cmp.get("v.TimeZones");
        var lastIdx = changedtimeZone.lastIndexOf(")");  
        var startIdx = changedtimeZone.lastIndexOf("(")+1;
        var todayDate = Date();
        var assignedTo = cmp.get("v.selectedRecordOfAssignedTo").Id;
     	
        var timeZoneValue = changedtimeZone.substring(startIdx,lastIdx);
        console.log('timeZoneValue ===='+timeZoneValue);
        var PractitionerTimeZones = cmp.get("v.PractitionerTimeZone");
        
        console.log("timeZoneSaved===="+changedtimeZone); 
        var repeat = cmp.get("v.showButton");
        var startTime= cmp.get('v.StartDate');		//  StartDateTime   to StartDate
        var endTime= cmp.get('v.EndDateTime');      
        var sub= cmp.get('v.Subject');
        
        var roomId = cmp.get("v.selectedRecordOfRoom").Id;
        
        // For patient 
        var patientIds =[];
        var patientId = cmp.get("v.selectedAccountRecords");
        patientId.forEach(patient => patientIds.push(patient.Id));
        console.log('patientId========'+JSON.stringify(patientId));
        
        // For Patient group
        var patientGroupIds =[];
        var  patientGroupId = cmp.get("v.selectedGroupRecords");
        patientGroupId.forEach(patientGroup => patientGroupIds.push(patientGroup.Id));
        
        //For Related business
        var relatedBusinessIds =[];
        var relatedBusinessId = cmp.get("v.selectedBussinessAccountsRecords");
        relatedBusinessId.forEach(relatedBusiness => relatedBusinessIds.push(relatedBusiness.Id));
        console.log('Business IDs' + JSON.stringify(relatedBusinessIds));
        
        //For practitioner         
        var practitionerIds =[]; 
        var  practitionerId = cmp.get("v.selectedContactRecords"); 
        practitionerId.forEach(practitioner => practitionerIds.push(practitioner.Id));
        
        //For cofacilitatorId
        var coFacilitatorIds =[];
        var  coFacilitatorId = cmp.get("v.selectedCoFacilitatorsRecords");
        coFacilitatorId.forEach(coFacilitator => coFacilitatorIds.push(coFacilitator.Id));
        
        // For Equipments Id
    var equipmentIds = [];
    var equipmentId = cmp.get("v.equipList");
        
        equipmentId.forEach(equipments => equipmentIds.push(equipments.Id));
    console.log("equipmentId=====" + equipmentIds);
        console.log("Before calling functionSave method");
    console.log("timeZoneSaved====" + changedtimeZone);
        // for validation   
    if (startTime === null) {
        helper.showToast(cmp, event, 'Please Provide Start Date and Time');
        }
    if (endTime === null) {
        helper.showToast(cmp, event, 'Please Provide End Date and Time');
        }
    if (patientIds.length === 0 && patientGroupIds.length === 0) {
        helper.showToast(cmp, event, 'Please Provide Either patient or patient group');
        }
    if (startTime > endTime) {
        helper.showToast(cmp, event, 'Start date/Time should not be greater than End Date/Time');
        }
    console.log("timeZoneSaved====" + changedtimeZone);
        var action = cmp.get("c.functionSave");
        console.log('Inside js Function Save');
        action.setParams({
            "startDateTime": startTime,
            "endDateTime":endTime,
            "roomID":roomId,
            "subject":sub, 
            "patientIds":patientIds,
            "patientGroupId":patientGroupIds,
            "practitionerIds":practitionerIds,
            "coFacilitatorIds":coFacilitatorIds,
            "relatedBusinessId":relatedBusinessIds,
            "equipmentIds":equipmentIds,
            "repeat":repeat,
            "weekDays":weekday,
            "tzIds":timeZoneValue,
            "assignedTo":assignedTo
            
        });
        if (!sub) {
            helper.showToast(cmp, event, 'Subject cannot be blank');
          return;
        }

        console.log("After the method");
        action.setCallback(this, function(response) { 
            var recordIds=[];
            var state = response.getState();
            
            var recordId= response.getReturnValue();
            recordId.forEach(record => recordIds.push(record.Id));
            
            var finalRecordId= recordIds[0];
            console.log('state====$$',finalRecordId);
            console.log('state====$$',recordId);
            if (state === "SUCCESS") {
                //toast
                cmp.set("v.PractitionerTimeZone",response.getState())
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Success',
                    message: 'Appointment '+sub+' was created.',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'success',
                    mode: 'pester'
                });
                toastEvent.fire();
                
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": '/lightning/r/Event/' + finalRecordId +'/view'
                });
                urlEvent.fire();
                
            }
            else if(cmp.set('v.isModalOpen',true)) {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error',
                    message:'Appointment are not created.',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();
            }
        });
        
        $A.enqueueAction(action);
    },
    
    handleClick: function (component, event, helper) {
        component.set("v.isDailyClick", true);
    },
    toggleButton: function (component, event, helper) {
        component.set("v.showButton", event.getSource().get('v.checked'));
    },



})
({
    showToast: function (component, event, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: 'Error',
            type: 'error',
            message: message
        });
        toastEvent.fire();
    },

    startOrEndDateHandler: function (component, event) {
        console.log('timehandler');
        component.set("v.ConflictMessage", '');
        var patientArray = [];
        var patientIds = [];
        var patientGroupArray = [];
        var patientGroupIds = [];
        var accountArray = [];
        var accountIds = [];
        var coFacilitatorArray = [];
        var coFacilitatorIds = [];
        var coFacilitatorIds = [];
        var equipArray = [];
        var equipIds = [];
        var practitionerIds = [];
        var practitionerArray = [];


        equipArray = component.get("v.equipList");
        equipArray.forEach(eq => equipIds.push({ 'Id': eq.Id, 'EquipmentNeed': eq.Needed }));

        patientArray = component.get("v.selectedAccountRecords");
        patientArray.forEach(patient => patientIds.push(patient.Id));

        practitionerArray = component.get("v.selectedAccountRecords");
        practitionerArray.forEach(practitioner => practitionerIds.push(practitioner.Id));

        practitionerArray = component.get("v.selectedContactRecords");
        practitionerArray.forEach(practitioner => practitionerIds.push(practitioner.Id));

        patientGroupArray = component.get("v.selectedGroupRecords");
        patientGroupArray.forEach(patientGroup => patientGroupIds.push(patientGroup.Id));

        accountArray = component.get("v.selectedBussinessAccountsRecords");
        accountArray.forEach(acc => accountIds.push(acc.Id));

        coFacilitatorArray = component.get("v.selectedCoFacilitatorsRecords");
        coFacilitatorArray.forEach(cofacilitator => coFacilitatorIds.push(cofacilitator.Id));

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

        //console.log('starttime',new Date(starttime).toISOString());
        //console.log('endtime',new Date(endtime).toISOString());

        var roomId = component.get("v.selectedRecordOfRoom").Id;
        var assignedTo = component.get("v.selectedRecordOfAssignedTo").Id
        console.log('room', component.get("v.selectedRecordOfRoom"));
        console.log('room', component.get("v.selectedRecordOfRoom").Id);


        var action = component.get("c.checkConflictingOnTimeChange");



        if (patientIds.length > 0 || patientGroupIds.length > 0 || accountIds.length > 0 || (roomId != undefined) || equipIds.length > 0) {

            if (endtime >= starttime) {
                console.log('timehandler2');
                action.setParams({
                    "patients": JSON.stringify(patientIds),
                    "patientGroups": JSON.stringify(patientGroupIds),
                    "bussinessAccounts": JSON.stringify(accountIds),
                    "coFacilitators": JSON.stringify(coFacilitatorIds),
                    "startdate": new Date(starttime),
                    "enddate": endtime,
                    "roomId": roomId,
                    "equipments": JSON.stringify(equipIds)
                });

                action.setCallback(this, function (response) {
                    var state = response.getState();
                    if (state === 'SUCCESS') {
                        try {
                            var res = response.getReturnValue();
                            if (res != undefined) {

                                var message = '';
                                message = res + component.get("v.FixedMessagePart");

                                this.showToast(component, event, message);
                                console.log('resIN', res);
                                /*component.set("v.byPassMessage",message);
                            var forclose = component.find("conflictingEvent");
                            $A.util.addClass(forclose, 'slds-show');
                            */
                                if (res.includes("User") || res.includes("Patient") || res.includes("Group") || res.includes("Business Account")) {
                                    component.set("v.showByPassErrForMultiSelect", true);
                                }
                                if (res.includes("Equipment")) {
                                    component.set("v.equipmentErr", true);
                                }
                                if (res.includes("Room")) {
                                    component.set("v.showByPassErrForLookupSelect", true);
                                }
                                //component.set("v.showByPassErr",true);

                            } else {
                                component.set("v.GroupMessage", '');
                                component.set("v.PatientMessage", '');
                                component.set("v.coFaciltatorMessage", '');
                                component.set("v.bussinessAccountMessage", '');
                                component.set("v.roomMessage", '');
                                component.set("v.equipMessage", '');
                                // component.set("v.showByPassErr",false);
                                component.set("v.showByPassErrForMultiSelect", false);
                                component.set("v.showByPassErrForLookupSelect", false);
                                component.set("v.equipmentErr", false);
                            }
                        }
                        catch (e) {
                            alert(e);
                        }
                    }
                });
                $A.enqueueAction(action);
            }
        }

    },
    statusListItemsView: function (component, event, helper) {
        var action = component.get('c.pickList');

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state == "SUCCESS") {
                var result = response.getReturnValue();
                component.set('v.timeZoneListItems', result);
            }
        });
        $A.enqueueAction(action);
    }
})
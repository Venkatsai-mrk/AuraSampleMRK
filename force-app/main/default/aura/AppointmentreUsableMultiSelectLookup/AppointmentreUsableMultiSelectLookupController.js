({

    onblur: function (component, event, helper) {
        // on mouse leave clear the listOfSeachRecords & hide the search result component 
        component.set("v.listOfSearchRecords", null);
        component.set("v.SearchKeyWord", '');
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
    },
    onfocus: function (component, event, helper) {
        // show the spinner,show child search result component and call helper function
        $A.util.addClass(component.find("mySpinner"), "slds-show");
        component.set("v.listOfSearchRecords", null);
        var forOpen = component.find("searchRes");
        $A.util.addClass(forOpen, 'slds-is-open');
        $A.util.removeClass(forOpen, 'slds-is-close');
        // Get Default 5 Records order by createdDate DESC 
        var getInputkeyWord = '';
        helper.searchHelper(component, event, getInputkeyWord);
    },

    keyPressController: function (component, event, helper) {
        $A.util.addClass(component.find("mySpinner"), "slds-show");
        // get the search Input keyword   
        var getInputkeyWord = component.get("v.SearchKeyWord");
        // check if getInputKeyWord size id more then 0 then open the lookup result List and 
        // call the helper 
        // else close the lookup result List part.   
        if (getInputkeyWord.length > 0) {
            var forOpen = component.find("searchRes");
            $A.util.addClass(forOpen, 'slds-is-open');
            $A.util.removeClass(forOpen, 'slds-is-close');
            helper.searchHelper(component, event, getInputkeyWord);
        }
        else {
            component.set("v.listOfSearchRecords", null);
            var forclose = component.find("searchRes");
            $A.util.addClass(forclose, 'slds-is-close');
            $A.util.removeClass(forclose, 'slds-is-open');
        }
    },

    // function for clear the Record Selaction 
    clear: function (component, event, helper) {
        var selectedPillId = event.getSource().get("v.name");
        var AllPillsList = component.get("v.lstSelectedRecords");
        console.log('selectedPillId', selectedPillId);
        console.log('AllPillsList', JSON.stringify(AllPillsList));


        for (var i = 0; i < AllPillsList.length; i++) {
            if (AllPillsList[i].Id == selectedPillId) {
                console.log('inside for loop');
                helper.mg.splice(i, 1);//added by Anmol
                var compEvent = component.getEvent("selectedRecordRemovalEvent");
                // set the Selected sObject Record to the event attribute.  
                compEvent.setParams({ "clearedRecordByEvent": AllPillsList[i] });
                // fire the event  
                compEvent.fire();
                AllPillsList.splice(i, 1);

                component.set("v.lstSelectedRecords", AllPillsList);
                // alert('AllPillsList',JSON.stringify(AllPillsList));
            }
        }
        var busAccList = component.get("v.bussinessAccountList");
        var accList = component.get("v.accountList");
        var coFacList = component.get("v.cofacilitatorList");
        var gpList = component.get("v.groupList");

        console.log('bussinessAccountList', component.get("v.bussinessAccountList"));
        console.log('accountList', component.get("v.accountList"));
        console.log('cofac', component.get("v.cofacilitatorList"));

        var indexBA = busAccList.indexOf(selectedPillId);
        if (indexBA !== -1) {
            busAccList.splice(indexBA, 1);
        }
        var indexA = accList.indexOf(selectedPillId);
        if (indexA !== -1) {
            accList.splice(indexA, 1);
        }
        var indexCF = coFacList.indexOf(selectedPillId);
        if (indexCF !== -1) {
            coFacList.splice(indexCF, 1);
        }
        var indexGP = gpList.indexOf(selectedPillId);
        if (indexGP !== -1) {
            gpList.splice(indexGP, 1);
        }
        console.log('bussinessAccountList', busAccList);
        console.log('accountList', accList);
        console.log('cofac', coFacList);

        if (accList.length > 0 || busAccList.length > 0 || coFacList.length > 0 || gpList.length > 0) {
            component.set("v.showByPassErrForMultiSelect", true);
        }
        else {
            component.set("v.showByPassErrForMultiSelect", false);
        }

        component.set("v.bussinessAccountList", busAccList);
        component.set("v.accountList", accList);
        component.set("v.cofacilitatorList", coFacList);
        component.set("v.groupList", gpList);

        console.log('showByPassErrForMultiSelect', component.get("v.showByPassErrForMultiSelect"));

        var AllTempList = component.get("v.templstSelectedRecords");
        for (var i = 0; i < AllTempList.length; i++) {
            if (AllTempList[i].Id == selectedPillId) {

                AllTempList.splice(i, 1);
                component.set("v.templstSelectedRecords", AllTempList);



                console.log('tempSelectedList', JSON.stringify(tempSelectedList));
                var tempSelectedList = component.get("v.templstSelectedRecords");

                if (tempSelectedList.length > 0) {

                    var forclose = component.find("conflictingEvent");
                    $A.util.addClass(forclose, 'slds-show');
                    $A.util.addClass(forclose, 'slds-text-color_error');
                    var mss = '';
                    for (var i = 0; i < tempSelectedList.length; i++) {
                        mss = mss + tempSelectedList[i].Name + ',';

                    }
                    mss = mss.substring(0, mss.length - 1);
                    var fixmessage = component.get("v.fixedMessage");
                    if (component.get("v.label") === 'Patients') {
                        component.set("v.PatientMessage", mss + fixmessage);
                    }
                    if (component.get("v.label") === 'Co-Facilitators') {
                        component.set("v.coFaciltatorMessage", mss + fixmessage);
                    }
                    if (component.get("v.label") === 'Related Business Accounts') {
                        component.set("v.bussinessAccountMessage", mss + fixmessage);
                    }
                    if (component.get("v.label") === 'Patient Groups') {
                        console.log('inside clear function');
                        //helper.mg.pop();
                        console.log('clear helper mg**', helper.mg);
                        component.set("v.GroupMessage", helper.mg);
                    }
                    //component.set("v.ConflictMessage", mss + fixmessage);


                } else {
                    var forclose = component.find("conflictingEvent");
                    /*for(var i = 0; i < AllPillsList.length; i++){
                        
                        if(AllPillsList[i].Id == selectedPillId){
                            
                            console.log('AllPillsList[i].Name',AllPillsList[i].Name);
                            
                            if(helper.mg.includes(AllPillsList[i].Name)){
                                 helper.mg.splice(i,1);//added by Anmol
                            }
                        }
                        
                        
                    }*/

                    console.log('clear helper mg**', helper.mg);
                    component.set("v.GroupMessage", helper.mg);//added by Anmol
                    $A.util.addClass(forclose, 'slds-hide');
                    // component.set("v.showByPassErrForMultiSelect",false);

                }
            }
        }
        component.set("v.SearchKeyWord", null);
        component.set("v.listOfSearchRecords", null);
    },

    // This function call when the end User Select any record from the result list.   
    handleComponentEvent: function (component, event, helper) {
        component.set("v.SearchKeyWord", null);
        // get the selected object record from the COMPONENT event 	 
        var listSelectedItems = component.get("v.lstSelectedRecords");
        var selectedAccountGetFromEvent = event.getParam("recordByEvent");
        //var mg='hello';
        listSelectedItems.push(selectedAccountGetFromEvent);
        component.set("v.lstSelectedRecords", listSelectedItems);
        console.log('listSelectedItems', JSON.stringify(listSelectedItems));

        console.log('label', component.get("v.label"));
        if (component.get("v.label") == 'Patients') {
            helper.alertMessage(component, event, component.get("v.lstSelectedRecords"));//nithin
        }
        var forclose = component.find("lookup-pill");
        $A.util.addClass(forclose, 'slds-show');
        $A.util.removeClass(forclose, 'slds-hide');

        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');

        console.log('action');
        var action;
        if (component.get("v.label") == 'Patient Groups') {
            console.log('pg');
            action = component.get("c.checkConflictingEventForGroup");

        } else {
            action = component.get("c.checkConflictingEvent");
        }
        console.log('action');
        var starting;
        var ending;
        if (component.get("v.AllDayEvent") === true) {
            starting = component.get("v.SelectedStartDate");
            ending = component.get("v.SelectedEndDate");
        } else {
            starting = component.get("v.SelectedStartTime");
            ending = component.get("v.SelectedEndTime");
        }

        console.log('starting', starting);
        console.log('objectAPI', component.get("v.label"));

        if (starting != undefined && ending != undefined) {
            action.setParams({
                'startt': starting,
                'endt': ending,
                'recordId': selectedAccountGetFromEvent.Id,
                'objName': component.get("v.label")
            });
            // set a callBack    
            action.setCallback(this, function (response) {

                var state = response.getState();
                console.log('sts', state);
                if (state === "SUCCESS") {
                    var storeResponse = response.getReturnValue();
                    console.log('res', storeResponse);
                    if (component.get("v.label") == 'Patient Groups') {
                        var mss = '';
                        if (storeResponse == 'Group') {
                            // var selectedList = component.get("v.lstSelectedRecords");
                            mss = '';
                        } else if (storeResponse == 'Patient') {
                            mss = mss + component.get("v.FixedgroupMessage");
                        }

                        var tempSelectedList = component.get("v.templstSelectedRecords");
                        console.log('res', storeResponse);
                        tempSelectedList.push(selectedAccountGetFromEvent);
                        console.log('tempSelectedList', tempSelectedList);

                        var forclose = component.find("conflictingEvent");
                        $A.util.removeClass(forclose, 'slds-hide');
                        $A.util.addClass(forclose, 'slds-show');
                        $A.util.addClass(forclose, 'slds-text-color_error');

                        var gpList = component.get("v.groupList");
                        var busAccList = component.get("v.bussinessAccountList");
                        var accList = component.get("v.accountList");
                        var coFacList = component.get("v.cofacilitatorList");

                        //   var mg = [];


                        for (var i = 0; i < tempSelectedList.length; i++) {


                            mss = mss + tempSelectedList[i].Name + ',';

                            gpList.push(tempSelectedList[i].Id);
                        }

                        component.set("v.groupList", gpList);

                        component.set("v.gpMessage", mss);

                        console.log('gpmsg', component.get("v.gpMessage"));

                        helper.mg.push(storeResponse);//added by Anmol

                        console.log('mss*---', mss);
                        console.log('mg****', helper.mg);

                        mss = mss.substring(0, mss.length - 1);
                        console.log('mss*****', mss);
                        var fixmessage = component.get("v.fixedMessage");

                        component.set("v.GroupMessage", helper.mg);//updated by Anmol

                        component.set("v.ConflictMessage", mss + fixmessage);
                        component.set("v.templstSelectedRecords", tempSelectedList);


                        if (accList.length > 0 || busAccList.length > 0 || coFacList.length > 0 || gpList.length > 0) {
                            component.set("v.showByPassErrForMultiSelect", true);
                        } else {
                            component.set("v.showByPassErrForMultiSelect", false);
                        }

                        console.log('mss', mss + fixmessage);


                    } else {
                        if (storeResponse === true) {
                            // var selectedList = component.get("v.lstSelectedRecords");
                            var tempSelectedList = component.get("v.templstSelectedRecords");
                            console.log('res', storeResponse);
                            tempSelectedList.push(selectedAccountGetFromEvent);

                            var forclose = component.find("conflictingEvent");
                            $A.util.removeClass(forclose, 'slds-hide');
                            $A.util.addClass(forclose, 'slds-show');
                            $A.util.addClass(forclose, 'slds-text-color_error');

                            var busAccList = component.get("v.bussinessAccountList");
                            var accList = component.get("v.accountList");
                            var coFacList = component.get("v.cofacilitatorList");
                            var gpList = component.get("v.groupList");
                            var mss = '';
                            for (var i = 0; i < tempSelectedList.length; i++) {
                                mss = mss + tempSelectedList[i].Name + ',';
                            }
                            mss = mss.substring(0, mss.length - 1);
                            var fixmessage = component.get("v.fixedMessage");
                            if (component.get("v.label") === 'Patients') {
                                component.set("v.PatientMessage", mss + fixmessage);
                                for (var i = 0; i < tempSelectedList.length; i++) {
                                    accList.push(tempSelectedList[i].Id);
                                }
                            }
                            if (component.get("v.label") === 'Co-Facilitators') {
                                component.set("v.coFaciltatorMessage", mss + fixmessage);
                                for (var i = 0; i < tempSelectedList.length; i++) {
                                    coFacList.push(tempSelectedList[i].Id);
                                }
                            }
                            if (component.get("v.label") === 'Related Business Accounts') {
                                component.set("v.bussinessAccountMessage", mss + fixmessage);

                                for (var i = 0; i < tempSelectedList.length; i++) {
                                    busAccList.push(tempSelectedList[i].Id);
                                }
                            }
                            component.set("v.ConflictMessage", mss + fixmessage);
                            component.set("v.templstSelectedRecords", tempSelectedList);
                            console.log('mss', mss + fixmessage);

                            console.log('tempSelectedList', JSON.stringify(tempSelectedList));

                            component.set("v.bussinessAccountList", busAccList);
                            component.set("v.accountList", accList);
                            component.set("v.cofacilitatorList", coFacList);

                            console.log('bussinessAccountList', component.get("v.bussinessAccountList"));
                            console.log('accountList', component.get("v.accountList"));
                            console.log('cofac', component.get("v.cofacilitatorList"));

                            if (accList.length > 0 || busAccList.length > 0 || coFacList.length > 0 || gpList.length > 0) {
                                component.set("v.showByPassErrForMultiSelect", true);
                            } else {
                                component.set("v.showByPassErrForMultiSelect", false);
                            }
                            console.log('showByPassErrForMultiSelect', component.get("v.showByPassErrForMultiSelect"));

                        }
                    }

                }

            });
            // enqueue the Action  
            $A.enqueueAction(action);
        }
    },
})
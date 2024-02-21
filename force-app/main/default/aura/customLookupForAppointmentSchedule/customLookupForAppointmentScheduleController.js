({
    doInit: function (component, event, helper) {


        if (component.get("v.label") === 'Assigned To') {

            var action = component.get("c.getCurrentUser");
            action.setCallback(this, function (response) {
                var state = response.getState();

                if (state === "SUCCESS") {
                    var storeResponse = response.getReturnValue();

                    component.set("v.selectedRecord", storeResponse);

                    console.log('ss', component.get("v.selectedRecord"))
                    var forclose = component.find("lookup-pill");
                    $A.util.addClass(forclose, 'slds-show');
                    $A.util.removeClass(forclose, 'slds-hide');

                    var forclose = component.find("searchRes");
                    $A.util.addClass(forclose, 'slds-is-close');
                    $A.util.removeClass(forclose, 'slds-is-open');

                    var lookUpTarget = component.find("lookupField");
                    $A.util.addClass(lookUpTarget, 'slds-hide');
                    $A.util.removeClass(lookUpTarget, 'slds-show');

                }
            });
            $A.enqueueAction(action);
        }


    },
    onfocus: function (component, event, helper) {
        $A.util.addClass(component.find("mySpinner"), "slds-show");
        var forOpen = component.find("searchRes");
        $A.util.addClass(forOpen, 'slds-is-open');
        $A.util.removeClass(forOpen, 'slds-is-close');
        // Get Default 5 Records order by createdDate DESC  
        var getInputkeyWord = '';
        helper.searchHelper(component, event, getInputkeyWord);
    },
    onblur: function (component, event, helper) {
        component.set("v.listOfSearchRecords", null);
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
    },
    keyPressController: function (component, event, helper) {
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
    clear: function (component, event, heplper) {
        //if(component.get("v.label") !='Equipment'){
        /*if(component.get("v.label") =='Location'){
            component.set("v.selectedRoomRecord",'');
            component.set("v.roomMessage",'');

        }*/
        var pillTarget = component.find("lookup-pill");
        var lookUpTarget = component.find("lookupField");

        $A.util.addClass(pillTarget, 'slds-hide');
        $A.util.removeClass(pillTarget, 'slds-show');

        $A.util.addClass(lookUpTarget, 'slds-show');
        $A.util.removeClass(lookUpTarget, 'slds-hide');

        component.set("v.SearchKeyWord", null);
        component.set("v.listOfSearchRecords", null);
        component.set("v.selectedRecord", {});

        var forclose = component.find("conflictingEvent");
        $A.util.addClass(forclose, 'slds-hide');
        component.set("v.showByPassErrForLookupSelect", false);

        if (component.get("v.label") == 'Equipment') {

            var compEvent = component.getEvent("eqipmentEvent");
            compEvent.setParams({ "currentIndex": component.get("v.indexVal") });
            compEvent.fire();
        }
    },

    // This function call when the end User Select any record from the result list.   
    handleComponentEvent: function (component, event, helper) {

        var selectedAccountGetFromEvent = event.getParam("recordByEvent");

        component.set("v.selectedRecord", selectedAccountGetFromEvent);
        component.set("v.SelectRecordName", selectedAccountGetFromEvent.Name);

        if (component.get("v.label") === 'Equipment') {

            let equip = component.get("v.equip");
            let index = component.get("v.indexVal");
            let equipLst = component.get("v.equipmentList");
            equipLst[index].noOfAvEquip = selectedAccountGetFromEvent.ElixirSuite__No_of_Available_Equipment__c;
            equipLst[index].Id = selectedAccountGetFromEvent.Id;
            equipLst[index].disabled = false;
            equipLst[index].location = selectedAccountGetFromEvent.ElixirSuite__Location__c;

            component.set("v.equipLst", equipLst);

            let tempArr = component.get("v.EuipIdLst")
            tempArr.push(selectedAccountGetFromEvent.Id);

            console.log('equip ' + JSON.stringify(equipLst));

            var compEvent = component.getEvent("eqipSelectedRecordEvent");
            compEvent.fire();
            var forclose = component.find("lookup-pill");
            $A.util.addClass(forclose, 'slds-show');
            $A.util.removeClass(forclose, 'slds-hide');

            var forclose = component.find("searchRes");
            $A.util.addClass(forclose, 'slds-is-close');
            $A.util.removeClass(forclose, 'slds-is-open');

            var lookUpTarget = component.find("lookupField");
            $A.util.addClass(lookUpTarget, 'slds-hide');
            $A.util.removeClass(lookUpTarget, 'slds-show');
        } else {


            var forclose = component.find("lookup-pill");
            $A.util.addClass(forclose, 'slds-show');
            $A.util.removeClass(forclose, 'slds-hide');

            var forclose = component.find("searchRes");
            $A.util.addClass(forclose, 'slds-is-close');
            $A.util.removeClass(forclose, 'slds-is-open');

            var lookUpTarget = component.find("lookupField");
            $A.util.addClass(lookUpTarget, 'slds-hide');
            $A.util.removeClass(lookUpTarget, 'slds-show');


            var action = component.get("c.checkConflictingEvent");
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
                        if (storeResponse === true) {


                            var forclose = component.find("conflictingEvent");
                            $A.util.removeClass(forclose, 'slds-hide');
                            $A.util.addClass(forclose, 'slds-show');
                            $A.util.addClass(forclose, 'slds-text-color_error');
                            var mss = selectedAccountGetFromEvent.Name;

                            var fixmessage = component.get("v.fixedMessage");

                            component.set("v.roomMessage", mss + fixmessage);
                            component.set("v.showByPassErrForLookupSelect", true);
                            console.log('mss', mss + fixmessage);
                        }
                    }

                });
                // enqueue the Action  
                $A.enqueueAction(action);
            }
        }
    },
})
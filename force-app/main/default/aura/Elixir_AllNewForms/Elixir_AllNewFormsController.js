({
    //fetch category information
    doInit : function(component, event, helper) {   
         try{
             var pageReference = component.get("v.pageReference");
             console.log('pageReference in allnewforms: '+JSON.stringify(pageReference));
        
        var customCategory = pageReference.state.c__customCategory;
        if(customCategory != null && customCategory != '' && Object.keys(customCategory).length === 0 && customCategory.constructor === Object){
            component.set("v.customCategory", []);
        }
        var isOpen = pageReference.state.c__isOpen;
        if(isOpen != null && isOpen != ''){
            component.set("v.isOpen", isOpen);
        }
        var categorized = pageReference.state.c__categorized;
        if(categorized != null && categorized != ''){
            component.set("v.categorized", categorized);
        }
        var subCategorized = pageReference.state.c__subCategorized;
        if(subCategorized != null && subCategorized != ''){
            component.set("v.subCategorized", subCategorized);
        }
        var patientID = pageReference.state.c__patientID;
        if(patientID != null && patientID != ''){
            component.set("v.patientID", patientID);
        }
        var forPatientPortal = pageReference.state.c__forPatientPortal;
        if(forPatientPortal != null && forPatientPortal != ''){
            component.set("v.forPatientPortal", forPatientPortal);
        }
             var workspaceAPI = component.find("workspace");
             workspaceAPI.getFocusedTabInfo().then(function (response) {
                 var focusedTabId = response.tabId;
                 var issubTab = response.isSubtab;
                 console.log('afctab', focusedTabId);
                 
                 if (issubTab) {
                     workspaceAPI.getTabInfo({ tabId: focusedTabId }).then(function (response1) {
                         console.log('afctabinfo', response1);
                     });
                     workspaceAPI.setTabLabel({
                         label: "All Notes"
                     });
                 } else if (response.subtabs && response.subtabs.length > 0) {
                     workspaceAPI.getTabInfo({ tabId: response.subtabs[0].tabId }).then(function (response1) {
                         console.log('tabId: response.subtabs[0].tabId: ' + response1);
                     });
                     workspaceAPI.setTabLabel({
                         label: "All Notes"
                     });
                 } else {
                     console.error("No subtabs found");
                 }
                 
                 workspaceAPI.setTabIcon({
                     tabId: focusedTabId,
                     icon: "utility:answer",
                     iconAlt: "Notes"
                 });
             }).catch(function (error) {
                 console.error("Error:", error);
             });
        if($A.util.isEmpty( component.get("v.customCategory"))){
            
            component.set("v.isActualNotes",true);
            var action = component.get("c.fetchCategory"); 
            action.setCallback(this, function(response) {
                var data = response.getReturnValue();
                
                var state = response.getState();
                if (state === "SUCCESS") {
                    component.set("v.customCategory",data);
                    helper.myAction(component, event, helper); 
                    
                }
                console.log('category values' +component.get("v.customCategory")); 
            });
            
            $A.enqueueAction(action);
        }
        else {
            helper.filterByCategoryIfCategoryProvided(component, event, helper); 
            console.log('Already present');
        }
        
         }
        catch(e){
            alert('Error in init all'+e)
        }
    },
    handleSendForms: function(component, event, helper) {
        // alert(typeof(event.getParam('value')));
        component.set("v.formsToSendForPortal",event.getParam('value'));
        console.log('selecreed forms '+JSON.stringify( component.get("v.formsToSendForPortal")));
    },

    handleChange: function(component, event, helper) {
        
        component.set("v.RecordId",event.getParam("value"));
        //component.set("v.formName",event.getParam("label"));
        console.log('label value >'+event.getSource().get("v.name"));
        console.log('HANDLE CHANGE>'+event.getSource().get("v.value"));
        //  alert('meg' + component.get("v."))
    },
    navigateToSpecificForm : function(component, event, helper) {
        
        console.log('acc Name ', component.get("v.patientID"));
        console.log('formName ', component.get("v.RecordId"));
        if(component.get("v.RecordId") == undefined){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Notification!",
                        "type": 'info',
                        "message": 'PLEASE SELECT FORM TYPE!'
                    });
                    toastEvent.fire();
                    
        }else{
        
            var actionType = 'NEW';
            helper.getCustomFormsHelper(component, event, helper, actionType)
                .then(function (result) {
                    if (result) {
                        const customFormNames = component.get("v.customFormCmp").map(i => i.ElixirSuite__Form_name__c);
                        if (customFormNames.includes(component.get("v.RecordId"))) {
                            // for this form, custom form mapping exists so open that custom form instead
                            var workspaceAPI = component.find("workspace");
                            workspaceAPI.openSubtab({
                                pageReference: {
                                    "type": "standard__component",
                                    "attributes": {
                                        "componentName": "ElixirSuite__subscriberComponent"
                                    },
                                    "state": {
                                        c__customFormCmp: component.get("v.customFormCmp"),
                                        c__accountId: component.get("v.patientID"),
                                        c__formName: component.get("v.RecordId"),
                                        c__actionType: 'NEW'
                                    }
                                },
                                focus: true
                            }).then(function (subtabId) {
                                workspaceAPI.setTabLabel({
                                    tabId: subtabId,
                                    label: component.get("v.RecordId")
                                });
                            }).catch(function (error) {
                                console.log(error);
                            });
                        }

                        else {
                            console.log('isActual ' + component.get("v.isActualNotes"));
                            component.set("v.openForm", true);
                        }
                    }
                    else {
                        console.log('isActual ' + component.get("v.isActualNotes"));
                        component.set("v.openForm", true);
                    }

                })
                .catch(function (error) {
                    console.error('Error occurred:', error);
                });
        }
        
        
    },
   	closeTab: function(component, event, helper) {
        try{
            var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
            console.log('im closed');
        })
        .catch(function(error) {
            console.log('Not closed, check the error: '+error);
        });
        var evt = $A.get("e.force:navigateToComponent");
                    evt.setParams({
                        componentDef:"c:Elixir_NewAccountAssociatedForms",
                        componentAttributes: {
                            recordVal : component.get("v.recordId"),
                            //  categorized : "Other",
                            subCategorized: "Assessment",
                            headingTitle: "All Notes"
                        }
                    });
                    evt.fire(); 
        }
        catch(e){
            console.log('ERROR IN CLOSING TAB'+e)
        }
        
    },
    closeModal : function(component, event, helper) {
        component.set("v.forPatientPortal",false);
        component.set("v.isOpen",false);
        if(component.get("v.isActualNotes")){
            component.set("v.customCategory",[]); 
        }
        var closeTabAction = component.get("c.closeTab");
        closeTabAction.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("closeTab method called successfully");
            } else if (state === "ERROR") {
                console.log("Error calling closeTab method: " + response.getError());
            }
        });
        $A.enqueueAction(closeTabAction);
    },
    searchKeyChange: function(component, event,helper) {
        //debugger;
        component.set("v.notFound",false);
        component.set("v.searchKey",component.find("searchKey").get("v.value"));
        var searchKey = component.get("v.searchKey");
        /***************/
        var existingList =   component.get("v.optionsForSearching");
        
        
        var fillData = existingList.filter(function(dat) {
            return (dat['label'].toLowerCase()).startsWith(searchKey.toLowerCase());
        });
        component.set("v.options",fillData);
        
        /***************/
        /* console.log('typed keyword '+searchKey );
        console.log('searchKey:::::'+searchKey +' category '+component.get("v.Category"));
        var action = component.get("c.getSearchForms");
        action.setParams({
            "searchKey": searchKey,
            "category": component.get("v.Category"),
            "categorized" : component.get("v.categorized")
        });
        action.setCallback(this, function(a) {
            
            var allData =  a.getReturnValue();
            if(allData.length == 0){
                component.set("v.notFound",true);
            }
            console.log('123 '+allData);
            var b = [];
            for (var i = 0; i < allData.length; i++) {
                console.log('inside for' +b);
                b[i] = {
                    'label': allData[i],
                    'value': allData[i]
                };     
            }
            console.log('response + data  bee  '+JSON.stringify(b));       
            component.set("v.options", b);          
        });
        $A.enqueueAction(action);*/
    },
    onChange: function (cmp, evt, helper) {
        // alert(cmp.find('select').get('v.value') + ' pie is good.');
        var action = cmp.get("c.filterForms");
        cmp.set("v.searchKey",'');
        var categoryCustom = cmp.get("v.customCategoryResults");
        
        
        action.setParams({
            "category": cmp.find('select').get('v.value')
        });
        console.log('value '+cmp.find('select').get('v.value'));
        action.setCallback(this, function(a) {
            
            var allData=  a.getReturnValue();
            console.log('123 '+allData);
            var b = [];
            for (var i = 0; i < allData.length; i++) {
                console.log('inside for' +b);
                b[i] = {
                    'label': allData[i],
                    'value': allData[i]
                };                
            }
            console.log('response + data  bee  '+JSON.stringify(b));       
            cmp.set("v.options", b);
            cmp.set("v.optionsForSearching", JSON.parse(JSON.stringify(b)));
            if(!cmp.find('select').get('v.value')){
                if(categoryCustom.length>0){
                    cmp.set("v.options", cmp.get("v.customCategoryResults"));
                }
            }
            
        });
        $A.enqueueAction(action);
        
    },
    sendToPatientPortal :  function(cmp, event, helper) { 
        console.log('response + data  bee  '+JSON.stringify(cmp.get("v.patientID")));   
        console.log('response + data  bee  '+JSON.stringify(cmp.get("v.formsToSendForPortal")));  
        var action = cmp.get("c.sendFormsToPP");
        cmp.set("v.searchKey",'');
        action.setParams({
            "formsToSendOnPortal": cmp.get("v.formsToSendForPortal"),
            "accountId" : cmp.get("v.patientID"),
        });
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "The record has been updated successfully."
                });
                toastEvent.fire();
            }
            
            
        });
        $A.enqueueAction(action);
    }
})
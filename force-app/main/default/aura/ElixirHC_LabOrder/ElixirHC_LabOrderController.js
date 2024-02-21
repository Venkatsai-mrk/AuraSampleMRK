({
    doInit: function(component, event, helper) {
        helper.getAllPicklistValues(component);
        helper.getAllUser(component);
        // helper.getNameSpaceOrgWide(component);
        // var today = new Date();
        //component.set('v.ProcReqToSave.Start_Date__c', today.getFullYear() + "-" + (today.getMonth() + 1) + "-" + today.getDate());
        var today = new Date();
        var dd = String(today.getDate()).padStart(2, '0');
        var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
        var yyyy = today.getFullYear();
        today = mm + '/' + dd + '/' + yyyy;
        component.set('v.ProcReqToSave.ElixirSuite__Start_Date__c',today); //Hardcoded namespace here
        console.log('COMPLEX ID' + component.get("v.AcctIden"));
        component.set('v.todayString', new Date().toISOString());
        var action = component.get("c.fetchCusomMetadataRecord");
        action.setCallback(this,function(response) {
            var res = response.getReturnValue();
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('final ' + JSON.stringify(res));
                var nspc = '';
                var nameSpace = '' ;
                console.log('NSPC ORG WIDE  '+JSON.stringify(nspc));
                //component.set("v.CustomMetadataValues", res);				
                //var a = res;
                var b = [];
                for (var i = 0; i < res['MedicalNecessity'].length; i++) {
                    console.log('inside for');
                    b[i] = {
                        'label': res['MedicalNecessity'][i][nspc+'ElixirSuite__Picklist_Label__c'],
                        'value': '\n\n' + res['MedicalNecessity'][i][nspc+'ElixirSuite__Picklist_Value__c']
                    };
                }
                
                //alert('length '+res['AvailableTest'].length);
                
                /* var lo; 
                 
                 for (var j=0;j<res['AvailableTest'].length;j++) {
                    lo = lo.concat(res['AvailableTest'][i]['Available_Tests__c'].split('\r'));
                     
                     
                     
                 }
                 */
                
                // console.log('jk k '+JSON.stringify(lo));
                var arr = [];
                
                for (var k=0;k<res['AvailableTest'].length;k++){
                    var item = res['AvailableTest'][k][nameSpace + 'ElixirSuite__Available_Tests__c'].split('\n')
                    arr = arr.concat(item);                                        
                }
                component.set("v.AvailableTest",arr);
                
                //var filtered = arr.filter(function (el) {
                  //  return el != null;
                //});
                
                console.log('arr value '+JSON.stringify(arr));
                console.log('p value '+JSON.stringify(arr));
                //  var allAvailableTests = res['AvailableTest'][0][nspc+'Available_Tests__c'].split('\r');
                // var allAvailableTests2 = res['AvailableTest'][1][nspc+'Available_Tests__c'].split('\r');
                //var p = allAvailableTests.concat(allAvailableTests2);          
                component.set("v.options", b);
                console.log('567--> '+JSON.stringify( component.get("v.options")));
            }
            
        });
        
        
        
        $A.enqueueAction(action);
        
        
        var action1 = component.get("c.getLabNames");
        
        action1.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.labName", response.getReturnValue());
            }
        });
        
        $A.enqueueAction(action1);
        
        var action2 = component.get("c.getAvailableTestName");
        
        action2.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.AvailableTest", response.getReturnValue());
            }
        });
        
        $A.enqueueAction(action2);
        
        
    },
    
    handleEventForLabOrderAcct: function(component, event) {
        var acct = event.getParam("StringIdRecord");
        component.set("v.AcctIden", acct);
    },
    onTextChanges: function() {
        console.log('insoide ' + JSON.stringify(component.get("v.ProcReqToSave")));
        // console.log('gr '+event.getsource().get("v.value"));
    },
    handleSelect: function(component, event) {
        
        
        component.set("v.MedicalValue", event.getSource().get("v.value"));
        component.set("v.OrderedTests", true);
        
    },
    handleCheckboxChange: function(component, event) {
        var e = event.getParam('value');
        var l = event.getParam('label')
        console.log('value----- ' + e);
        console.log('label------ ' + l);
        //var map1 = new Map();
        var storeIndex;
        var slectedNecessity = [];
        slectedNecessity = event.getParam('value');
        console.log('label------ ' + slectedNecessity);
        for (var i = 0; i < slectedNecessity.length; i++) {
            
            console.log('inside for');
            var item = slectedNecessity[i];
            if ((i + 1) == (slectedNecessity.length)) {
                console.log('inside if');
                storeIndex = item;
                console.log('last item ' + storeIndex);
            }
            
        }
        var finalVal = slectedNecessity; // component.get("v.NecessityDescription") +'\n '+'\n'+ storeIndex ;
        component.set("v.NecessityDescription", '');
        component.set("v.NecessityDescription", finalVal);
        
        
        
        // alert(event.getParam('value'));
    },
    procedureValidity  : function(component ,event ,helper){
        var valid = true;
        valid = helper.helperMethod(component , valid);
        console.log('valid'+valid);
    },
    handleCheck: function(component) {
        var isChecked = component.find("OnAdmissionCheckBox").get("v.checked");
        component.set("v.ProcReqToSave.ElixirSuite__On_Admission__c", isChecked);
    },
    closeModel: function(component) {
        // component.set("v.isOpen",false);
        
        /************Nikhil**************/
        var appEvent = $A.get("e.c:Elixir_RefreshViewsGenericAppEvt");
        appEvent.setParams({
            "screenType" : "LabTest",
            "action" : "New",
            "recordIds" : "",
            "button" :"Cancel"
        });
        appEvent.fire();
        var workspaceAPI = component.find("workspace");
        if (component.get("v.popFlag")) {
            component.set("v.isOpen",false);
        } else {
            window.history.go(-2);
        }
        
        workspaceAPI
        .getFocusedTabInfo()
        .then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({ tabId: focusedTabId });
        })
        .catch(function(error) {
            console.log(error);
        });
    },
    
    
    /*  isFormValid: function (cmp, evt, helper) {
    const requiredFields = cmp.find('yourAuraId') || [];
    var isValid = true;
    requiredFields.forEach(e => {        if (e.get('v.value')=='' || e.get('v.value').trim().length==0 ) {
            isValid = false;
        }
    })
    return isValid;
},*/
    
    handleConfirmDialogNo:function(component) {
        component.set("v.showConfirmDialog",false);
    },
    
    handleConfirmDialogYes :  function(component, event, helper) {
        
        var valid = true;
        
        var procedureStartCmp = component.find("procedure-start_time");
        console.log('procedureStartCmp'+procedureStartCmp);
        //var strtProcedureTime = procedureStartCmp.get("v.value");
        var procedureEndCmp = component.find("procedure-end_time");
        var endProcedureTime = procedureEndCmp.get("v.value");
        
        if(endProcedureTime == null)
        {
            var today = new Date();
            endProcedureTime = today;
        }
        if (helper.validateRequired(component, event)) {
            
            if (component.get("v.NecessityDescription") == undefined) {
                component.set("v.NecessityDescription", "");
            }
            if(valid == true){
                var action = component.get("c.saveRecord");
                var newProcRec = component.get("v.ProcReqToSave");
                var arr = [];
                arr.push(newProcRec);
                var necessityDes = "" + component.get("v.NecessityDescription");
                console.log('new proc value ' + JSON.stringify(component.get("v.ProcReqToSave")));
                console.log('new proc necessity value ' + necessityDes);
                console.log('wfh '+JSON.stringify(component.get("v.AcctIden")));
                
                action.setParams({
                    
                    "procReq": arr,
                    "necessityDetails": necessityDes,
                    "acct": component.get("v.AcctIden"),
                    "medVal": component.get("v.MedicalValue"),
                    "starttimeProcedure" : component.get("v.todayString"),
                    "endtimeProcedure" : endProcedureTime
                });console.log(component.get("v.todayString"), 'f', component.get('v.endString'));
                action.setCallback(this, function(response) {
                    
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        try {
                            let labOrderId = response.getReturnValue().Id;
                            
                            // at max 3 approval levels will be there, ex-
                            //'[{"approvalLevel":1,"comments":"comm1","customLabel":"Aditya-user","dateOfApproval":"2023-04-20T14:06:18.758Z","signatureContentDocumentId":"069N0000002DHmcIAG","userName":"User User","userRole":"CEO"},{"approvalLevel":2,"comments":"comm2","customLabel":"Aditya-user","dateOfApproval":"2023-04-20T14:06:31.832Z","signatureContentDocumentId":"069N0000002DHmcIAG","userName":"User User","userRole":"CEO"},{"approvalLevel":3,"comments":"comm3","customLabel":"Aditya-user","dateOfApproval":"2023-04-20T14:06:41.884Z","signatureContentDocumentId":"069N0000002DHmcIAG","userName":"User User","userRole":"CEO"}]'
                            let approvedValues = JSON.stringify(component.get("v.approvedValues"));
                            
                            let action = component.get("c.attachApprovalDataToLabOrder");
                            action.setParams({
                                labOrderId: labOrderId,
                                approvedValues: approvedValues
                            });
                            
                            action.setCallback(this, function (response) {
                                if (response.getState() == "ERROR") {
                                    alert("Failed to attach approval data");
                                    console.log("Failed to attach approval data", JSON.stringify(response.getError()));
                                }
                                
                                // start success
                                var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    "type": "Success",
                                    "title": "LAB ORDER CREATED SUCCESSFULLY!",
                                    "message": "Creation Successfull!"
                                });
                                toastEvent.fire();
                                var appEvent = $A.get("e.c:Elixir_RefreshViewsGenericAppEvt");
                                appEvent.setParams({
                                    "screenType": "LabTest",
                                    "action": "New",
                                    "recordIds": [response.getReturnValue().Id]
                                });
                                appEvent.fire();
                                component.set("v.isOpen", false);
                                // end success
                            });
                            
                            $A.enqueueAction(action);
                        } catch (error) {
                            console.error("Failed to attach approval data: ", error);
                        }
                        // ************Nikhil**************
                        /* 
                    
              var workspaceAPI = component.find("workspace");
              if (component.get("v.popFlag")) {
                  window.history.go(-1);
              } else {
                  window.history.go(-2);
              }
              
              workspaceAPI
              .getFocusedTabInfo()
              .then(function(response) {
                  var focusedTabId = response.tabId;
                  workspaceAPI.closeTab({ tabId: focusedTabId });
              })
              .catch(function(error) {
                  console.log(error);
              });
              */
                    } else if (state === "ERROR") {
                        
                        var errors = response.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                console.log("Error message: " +
                                            errors[0].message);
                            }
                        } else {
                            console.log("Unknown error");
                        }
                        
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "type": "error",
                            "title": "PROCEDURE REQUEST INSERTION FAILED!",
                            "message": "Failed!"
                        });
                        toastEvent.fire();
                    }
                });
                $A.enqueueAction(action);
            }
        }
        
        
    },
    
    save: function(component, event, helper) {
        
        
        var procedureStartCmp = component.find("procedure-start_time");
        console.log('procedureStartCmp'+procedureStartCmp);
        //var strtProcedureTime = procedureStartCmp.get("v.value");
        var procedureEndCmp = component.find("procedure-end_time");
        var endProcedureTime = procedureEndCmp.get("v.value");
        var selectedTest = component.get("v.MedicalValue");
        
        console.log('component.get("v.MedicalValue") = ', component.get("v.MedicalValue"));
        if($A.util.isUndefinedOrNull(selectedTest) || $A.util.isEmpty(selectedTest)){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "type": 'error',
                "message": 'Please select test.'
            });
            toastEvent.fire();
            return;
        }
        
        var valid = true;
        
        valid = helper.helperMethod(component, valid);
        if (helper.validateRequired(component, event)){
            if (component.get("v.NecessityDescription") == undefined) {
                component.set("v.NecessityDescription", "");
            }
            if(endProcedureTime == null){
                component.set("v.showConfirmDialog", true);
                return;
            }
            if (valid == true) {
                var action = component.get("c.saveRecord");

                var newProcRec = component.get("v.ProcReqToSave");
                var arr = [];
                arr.push(newProcRec);
                var necessityDes = "" + component.get("v.NecessityDescription");
                console.log(
                    "new proc value " + JSON.stringify(component.get("v.ProcReqToSave"))
                );
                console.log("new proc necessity value " + necessityDes);
                console.log("wfh " + JSON.stringify(component.get("v.AcctIden")));
                action.setParams({
                    procReq: arr,
                    necessityDetails: necessityDes,
                    acct: component.get("v.AcctIden"),
                    medVal: component.get("v.MedicalValue"),
                    starttimeProcedure: component.get("v.todayString"),
                    endtimeProcedure: component.get("v.endString"),
                    
                });
                console.log(
                    component.get("v.todayString"),
                    "f",
                    component.get("v.endString")
                );
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        try {
                            let labOrderId = response.getReturnValue().Id;
                            
                            // at max 3 approval levels will be there, ex-
                            //'[{"approvalLevel":1,"comments":"comm1","customLabel":"Aditya-user","dateOfApproval":"2023-04-20T14:06:18.758Z","signatureContentDocumentId":"069N0000002DHmcIAG","userName":"User User","userRole":"CEO"},{"approvalLevel":2,"comments":"comm2","customLabel":"Aditya-user","dateOfApproval":"2023-04-20T14:06:31.832Z","signatureContentDocumentId":"069N0000002DHmcIAG","userName":"User User","userRole":"CEO"},{"approvalLevel":3,"comments":"comm3","customLabel":"Aditya-user","dateOfApproval":"2023-04-20T14:06:41.884Z","signatureContentDocumentId":"069N0000002DHmcIAG","userName":"User User","userRole":"CEO"}]'
                            let approvedValues = JSON.stringify(component.get("v.approvedValues"));
                            
                            let action = component.get("c.attachApprovalDataToLabOrder");
                            action.setParams({
                                labOrderId: labOrderId,
                                approvedValues: approvedValues
                            });
                            
                            action.setCallback(this, function (response) {
                                if (response.getState() == "ERROR") {
                                    alert("Failed to attach approval data");
                                    console.log("Failed to attach approval data", JSON.stringify(response.getError()));
                                }
                                
                                // start success
                                
                                var refreshevt = component.getEvent("RefreshLaborder");
                                refreshevt.fire();
                                
                                var appEvent = $A.get("e.c:Elixir_RefreshViewsGenericAppEvt");
                                appEvent.setParams({
                                    "screenType": "LabTest",
                                    "action": "New",
                                    "recordIds": [response.getReturnValue()]
                                }); 
                                appEvent.fire();
                                
                                var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    type: "Success",
                                    title: "LAB ORDER CREATED SUCCESSFULLY!",
                                    message: "Creation Successfull!"
                                });
                                toastEvent.fire();
                                
                                
                                var workspaceAPI = component.find("workspace");
                                if (component.get("v.popFlag")) {
                                    component.set("v.isOpen", false);
                                } else {
                                    window.history.go(-2);
                                }
                                
                                workspaceAPI
                                .getFocusedTabInfo()
                                .then(function (response) {
                                    var focusedTabId = response.tabId;
                                    workspaceAPI.closeTab({ tabId: focusedTabId });
                                })
                                .catch(function (error) {
                                    console.log(error);
                                });
                                // end success
                            });
                            
                            $A.enqueueAction(action);
                        } catch (error) {
                            console.error("Failed to attach approval data: ", error);
                        }
                        
                    } else if (state === "ERROR") {
                        var errors = response.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                console.log("Error message: " + errors[0].message);
                            }
                        } else {
                            console.log("Unknown error");
                        }
                        var appEvent = $A.get("e.c:Elixir_RefreshViewsGenericAppEvt");
                        appEvent.setParams({
                            "screenType" : "LabTest",
                            "action" : "New",
                            "recordIds" : [response.getReturnValue().Id] ,
                            "button" :"Cancel"
                        });
                        appEvent.fire();
                        
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            type: "error",
                            title: "PROCEDURE REQUEST INSERTION FAILED!",
                            message: "Failed!"
                        });
                        toastEvent.fire();
                    }
                });
                $A.enqueueAction(action);
            }
        }
        
    }
})
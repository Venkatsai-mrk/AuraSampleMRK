({
    myAction: function(component, event, helper) {	
        component.set("v.accountId",component.get("v.recordId"));
     /*   var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            
            var focusedTabId = response.tabId;
            var issubTab = response.isSubtab;
            // console.log('afctab',focusedTabId);
            if(issubTab)
            {
                workspaceAPI.getTabInfo(
                    { tabId:focusedTabId}
                ).then(function(response1){
                    
                    //  console.log('afctabinfo',response1);
                });
                workspaceAPI.setTabLabel({
                    
                    label: "Notes"
                });                
            }
            else 
            { 
                workspaceAPI.getTabInfo({ tabId:response.subtabs[0].tabId}).then(function(response1){                 
                    //  console.log('afctabinfo',response1);
                });
                workspaceAPI.setTabLabel({
                    label: "Notes"
                });         
            }     
            workspaceAPI.setTabIcon({
                tabId: focusedTabId,
                icon: "utility:note",
                iconAlt: "note"
            });
        })*/
        helper.initHelper(component, event, helper);
    },
    closeObservation : function(component, event, helper) {
        var index = event.getSource().get("v.name");
        var parentList = component.get("v.parentProblemTable");
        parentList[index].isTemplateObservationvisible = false;
        component.set("v.parentProblemTable",parentList);
    },
    handleChange: function (component, event) {
        component.set("v.selectedValues",event.getParam("value"));
    },
    createCareplanBegin : function(component, event, helper) {		
        let action = component.get("c.getAcctSpecificProblem");
        component.find("Id_spinner").set("v.class" , 'slds-show');
        // alert('id '+component.get("v.accountId"));
        action.setParams({
            acctId : component.get("v.accountId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {   
                component.find("Id_spinner").set("v.class" , 'slds-hide');
                var resp = response.getReturnValue();  
                component.set("v.problemsForPatient" ,resp.relatedProblems);
                component.set("v.problemsForPatientCopy" ,JSON.parse(JSON.stringify(resp.relatedProblems)));
                console.log('data '+JSON.stringify(resp));
                var problemrecordCreation = {'isTemplateObservationvisible' : false,
                                             'istextVisible' : false,
                                             'selectedObservation' : [],
                                             'selectedProblem' : '',
                                             'freeText' : false};
                var parentProblemArray = [];
                //for(var rec in resp.relatedProblems){
                parentProblemArray.push(problemrecordCreation);
                // }
                var goalList = [];
                var mapOfGoals = {};
                var templateIntervaentions = resp.templateIntervaentions;
                for(var goalrec in templateIntervaentions){
                    goalList.push({value:templateIntervaentions[goalrec].Id,
                                   label:templateIntervaentions[goalrec].Name}); //For options map
                    mapOfGoals[templateIntervaentions[goalrec].Id] = templateIntervaentions[goalrec]; //all goals map
                }
                component.set("v.parentProblemTable" ,parentProblemArray);
                component.set("v.options",goalList);
                component.set("v.mapOfGoals",mapOfGoals);
                component.set("v.createPlan",true);
            }else{    
                var errors = response.getError();
                if (errors) {
                    if (errors[0]) {
                        console.log("Error message: " +
                                    errors[0].message);
                    }        }
            }
            
        });
        $A.enqueueAction(action);
    },
    addObservation : function(component, event, helper) {
        var index = event.getSource().get("v.name");
        //   var value = event.getSource().get("v.value");      
        var parentList = component.get("v.parentProblemTable");
        parentList[index].istextVisible = false;
        parentList[index].isTemplateObservationvisible = true;
        component.set("v.parentProblemTable",parentList);
    },
    addObservationToParentTable : function(component, event, helper) {
        var selectedOptionValue = component.get("v.selectedValues");
        var index = event.getSource().get("v.name");
        // var value = event.getSource().get("v.value");      
        var parentList = component.get("v.parentProblemTable");
        var mapOfGoals = component.get("v.mapOfGoals")
        var selectedOptionValue = component.get("v.selectedValues");
        /*  for(var goalrec in listOfAllGoals){
            mapOfExistingGoals[listOfAllGoals[goalrec].Id] = listOfAllGoals[goalrec]; 
        }
        */
        var arr = [];
        for(var rec in selectedOptionValue){
            //  if(!$A.util.isUndefinedOrNull(mapOfExistingGoals[selectedOptionValue[rec]])){
            arr.push(mapOfGoals[selectedOptionValue[rec]]);
            //  }            
        }
        parentList[index].selectedObservation = arr;
        parentList[index].isTemplateObservationvisible = false;
        parentList[index].istextVisible = true;
        component.set("v.parentProblemTable",parentList);
    },
    createObjectData: function(component, event) {
        
        // var Id = component.get("v.recordId");
        var RowItemList = component.get("v.parentProblemTable");
        var problemrecordCreation = {'isTemplateObservationvisible' : false,
                                     'istextVisible' : false,
                                     'selectedObservation' : [],
                                     'selectedProblem' : '',
                                     'freeText' : false};
        RowItemList.push({problemrecordCreation});
                          component.set("v.parentProblemTable", []);      
                          component.set("v.parentProblemTable", RowItemList);
                          
                         }, 
                          removeDeletedRow: function(component, event, helper) {   
                              //    alert('meghna start');
                              var ctarget = event.currentTarget;
                              var index = ctarget.dataset.value;      
                              var AllRowsList = component.get("v.parentProblemTable");
                              AllRowsList.splice(index, 1);
                              //   alert('meghna');
                              component.set("v.parentProblemTable", AllRowsList);
                          },
                          abc :  function(component, event, helper) {
                              if(component.get("v.typeOfNote") == 'Problem'){
                                  var myVal =  component.get("v.myVal");
                                  var column = component.get("v.column");
                                  column['problemNote'] = component.get("v.myVal");
                              }
                              if(component.get("v.typeOfNote") == 'Diagnosis'){
                                  var myVal =  component.get("v.myVal");
                                  var column = component.get("v.column");
                                  column['diagnosisNote'] = component.get("v.myVal");
                              }
                              if(component.get("v.typeOfNote") == 'Procedure'){
                                  var myVal =  component.get("v.myVal");
                                  var column = component.get("v.column");
                                  column['procedureNote'] = component.get("v.myVal")``;
                              }
                          },
                          
                          handleComponentEvent: function(component, event, helper) {
                              var myVal = component.get("v.myVal");
                              var eventValue = event.getParams().selectedValue;
                              console.log('##new'+JSON.stringify(event.getParams().noteType));
                              var description = eventValue.Description;
                              if(description == undefined){
                                  description = '';
                              }
                              if(event.getParams().noteType == 'Problem'){
                              if(eventValue.Type == undefined){
                                  if(eventValue == 'Other'){
                                   let medications = component.get("v.medications");
                                      if($A.util.isUndefinedOrNull(medications)){
                                          medications = [];
                                      }
                                      medications.push({'Id': eventValue.Id, 'FieldName': eventValue.FieldName, 'Description': eventValue.Description});
                                      component.set("v.medications",medications);
                                      component.set("v.Vital" , true);
                                      component.set("v.CM" , false);
                                      component.set("v.ROS" , false);                  
                                      component.set("v.isMeasurement" , false);
                                      component.set("v.HPI" , false);
                                      component.set("v.isDietary" , false);
                                      component.set("v.isPrescriptions" , false);
                                      component.set("v.isChiefComplaints" , false);
                                      component.set("v.isVital" , false);
                                      component.set("v.isLab" , false);
                                      component.set("v.isSocial" , false);
                                      component.set("v.isFamily" , false);
                                      component.set("v.ishealthDiagnosis" , false);
                                }
                              }
                              else{
                              if(eventValue.Type.toLowerCase() == 'problems'){
                                  if(myVal.includes('Problems:')){
                                      let splitMyval = [];
                                      splitMyval = myVal.split('Problems:</b>');
                                   //   splitMyval[0]+= 'Problems:</b>';
                                    //  splitMyval[0]+= '<br/>' + eventValue.FieldName+ ' - ' + description;
                                    splitMyval[0]+= eventValue.FieldName+ ' - ' + description;
                                      myVal = splitMyval.join();
                                  }else{
                                      myVal+=' <b style="color:#493266;font-size:15px;">Problems:</b><br/> '+eventValue.FieldName + ' - ' + description;   
                                  }
                                  
                                  let problemsToSave = [];
                                  problemsToSave = component.get("v.problemsToSave");
                                  problemsToSave.push({'Id' : eventValue.Id, 'FieldName' : eventValue.FieldName, 'Description' : description});
                                  component.set("v.problemsToSave",problemsToSave);
                              }
                              }
                              }
                              //for diagnosis
                               if(event.getParams().noteType == 'Diagnosis'){
                                   if(eventValue.Type == undefined){
                                  if(eventValue == 'Other'){
                                   let diagnosis = component.get("v.diagnosis");
                                      if($A.util.isUndefinedOrNull(diagnosis)){
                                          diagnosis = [];
                                      }
                                      diagnosis.push({'Id': eventValue.Id, 'FieldName': eventValue.FieldName, 'Description': eventValue.Description});
                                      component.set("v.diagnosis",diagnosis);
                                      component.set("v.Vital" , true);
                                      component.set("v.CM" , false);
                                      component.set("v.ROS" , false);                  
                                      component.set("v.isMeasurement" , false);
                                      component.set("v.HPI" , false);
                                      component.set("v.isDietary" , false);
                                      component.set("v.isPrescriptions" , false);
                                      component.set("v.isChiefComplaints" , false);
                                      component.set("v.isVital" , false);
                                      component.set("v.isLab" , false);
                                      component.set("v.isSocial" , false);
                                      component.set("v.isFamily" , false);
                                      component.set("v.ishealthDiagnosis" , false);
                                    }
                              }
                                   else{
                                       if(eventValue.Type.toLowerCase() == 'diagnosis'){
                                           if(myVal.includes('Diagnosis:')){
                                               let splitMyval = [];
                                               splitMyval = myVal.split('Diagnosis:</b>');
                                               splitMyval[0]+= eventValue.FieldName+ ' - ' + description;
                                            //   splitMyval[0]+= 'Diagnosis:</b>';
                                            //   splitMyval[0]+= '<br/>' + eventValue.FieldName+ ' - ' + description;
                                               myVal = splitMyval.join();
                                           }else{
                                               myVal+=' <b style="color:#493266;font-size:15px;">Diagnosis:</b><br/>'+eventValue.FieldName + ' - ' + description;  
                                           }
                                           let diagToSave = [];
                                           diagToSave = component.get("v.diagnosisToSave");
                                           diagToSave.push({'Id' : eventValue.Id, 'FieldName' : eventValue.FieldName, 'Description' : description});
                                           component.set("v.diagnosisToSave",diagToSave);
                                       }
                               }   
                          
                                }
                              
                               //for procedure
                               if(event.getParams().noteType == 'Procedure'){
                                   if(eventValue.Type == undefined){
                                  if(eventValue == 'Other'){
                                   let procedure = component.get("v.procedure");
                                      if($A.util.isUndefinedOrNull(procedure)){
                                          procedure = [];
                                      }
                                      procedure.push({'Id': eventValue.Id, 'FieldName': eventValue.FieldName, 'Description': eventValue.Description});
                                      component.set("v.procedure",procedure);
                                      component.set("v.Vital" , true);
                                      component.set("v.CM" , false);
                                      component.set("v.ROS" , false);                  
                                      component.set("v.isMeasurement" , false);
                                      component.set("v.HPI" , false);
                                      component.set("v.isDietary" , false);
                                      component.set("v.isPrescriptions" , false);
                                      component.set("v.isChiefComplaints" , false);
                                      component.set("v.isVital" , false);
                                      component.set("v.isLab" , false);
                                      component.set("v.isSocial" , false);
                                      component.set("v.isFamily" , false);
                                      component.set("v.ishealthDiagnosis" , false);
                                    }
                                }
                                   else{
                                       if(eventValue.Type.toLowerCase() == 'procedure'){
                                           if(myVal.includes('Procedures:')){
                                               let splitMyval = [];
                                               splitMyval = myVal.split('Procedures:</b>');
                                               splitMyval[0]+= eventValue.FieldName+ ' - ' + description;
                                             //  splitMyval[0]+= 'Procedures:</b>';
                                             //  splitMyval[0]+= '<br/>' + eventValue.FieldName+ ' - ' + description;
                                               myVal = splitMyval.join();
                                           }else{
                                               myVal+=' <b style="color:#493266;font-size:15px;">Procedures:</b><br/>'+eventValue.FieldName + ' - ' + description;  
                                           }
                                           let procToSave = [];
                                           procToSave = component.get("v.procedureToSave");
                                           procToSave.push({'Id' : eventValue.Id, 'FieldName' : eventValue.FieldName, 'Description' : description});
                                           component.set("v.procedureToSave",procToSave);
                                       }
                               }   
                          
                                }
                                if(event.getParams().noteType == 'Medication'){
                                myVal = component.get("v.column").procedureNote;
                                if($A.util.isUndefinedOrNull(myVal)){
                                    myVal = '';
                                }
                                if(myVal.includes('Medications:')){
                                    let splitMyval = [];
                                    splitMyval = myVal.split('Medications:</b>');
                                    splitMyval[0]+= 'Medications:</b><br/>';
                                    splitMyval[0]+= 'Medication Name - ' + helper.checkUndefined(eventValue.FieldName);
                                    splitMyval[0]+= ', Frequency - ' + helper.checkUndefined(eventValue.ElixirSuite__Ferquency__c);
                                    splitMyval[0]+= ', Route - ' + helper.checkUndefined(eventValue.ElixirSuite__Route_New__c);
                                    splitMyval[0]+= '<br>';
                                    splitMyval[0]+= 'Instructions - ' + helper.checkUndefined(eventValue.ElixirSuite__Notes__c);
                                    myVal = splitMyval.join();
                                }else{                                   
                                    // myVal+=' <b style="color:#493266;font-size:15px;">Medications:</b><br/>'+'Medication Name - ' + helper.checkUndefined(eventValue.FieldName)
                                    myVal+=' <b style="font-size:15px;">Medications:</b><br/>'+'Medication Name - ' + helper.checkUndefined(eventValue.FieldName)
                                    + ', Frequency - ' + helper.checkUndefined(eventValue.ElixirSuite__Ferquency__c)
                                    + ', Route - ' + helper.checkUndefined(eventValue.ElixirSuite__Route_New__c)
                                    + '<br>'
                                    + 'Instructions - ' + helper.checkUndefined(eventValue.ElixirSuite__Notes__c);
                                }
                            }
                              //procedure ends
                              
                              if(event.getParams().noteType == 'Diagnosis'){
                                  component.set("v.myVal",myVal);
                                  var column = component.get("v.column");
                                  column['diagnosisNote'] = component.get("v.myVal");
                                  column['diagnosisList'] = component.get("v.diagnosisToSave");
                              }
                              if(event.getParams().noteType == 'Procedure'){
                                  component.set("v.myVal",myVal);
                                  var column = component.get("v.column");
                                  column['procedureNote'] = component.get("v.myVal");
                                  column['procedureList'] = component.get("v.procedureToSave");
                              }
                              if(event.getParams().noteType == 'Problem'){
                                  component.set("v.myVal",myVal);
                                  var column = component.get("v.column");
                                  column['problemNote'] = component.get("v.myVal");
                                  column['problemNoteList'] = component.get("v.problemsToSave");
                              }
                              if(event.getParams().noteType == 'Medication'){
                                var column = component.get("v.column");
                                column['procedureNote'] = myVal;
                                }
                              component.set("v.column",column);
                          },
                          addNotes: function(component, event, helper) {
                              if(component.get("v.typeOfNote") == 'Problem'){
                                  helper.addNotesHelper(component, event, helper);
                              }
                              else if(component.get("v.typeOfNote") == 'Diagnosis') {
                                  helper.addNotesHelperDiagnosis(component, event, helper);
                              }
                                  else{
                                      helper.addNotesHelperProcedure(component, event, helper);
                                  }
                          },
                          handleClickFreeTextCode : function(component, event, helper) {
                              var selectedOptionValue = component.get("v.selectedValues");
                              var index = event.getSource().get("v.name");
                              var parentList = component.get("v.parentProblemTable");
                              var getObservationArray = parentList[index].selectedObservation;
                              getObservationArray.push({'Name': ''});
                              parentList[index].istextVisible = true;
                              component.set("v.parentProblemTable",parentList);
                          },
                          removeNote: function(component, event, helper){
                              let value = event.getSource().get("v.class");
                              let arr = [];
                              arr = value.split('$');
                              let idx = arr[0];
                              let name = arr[1];
                              if(name == 'MED'){
                                  let medications = component.get("v.medications");      
                                  medications.splice(parseInt(idx),1);
                                  component.set("v.medications",medications);
                              }else if(name == 'LAB'){
                                  let labOrders = component.get("v.labOrders");      
                                  labOrders.splice(parseInt(idx),1);
                                  component.set("v.labOrders",labOrders);
                              }
                          },
                          
                            
                          submitNotes: function(component, event, helper){
                              
                              var stringvalue = JSON.parse(JSON.stringify(component.get("v.myVal")));
                              stringvalue = stringvalue.replace('<p>', '');  
                              stringvalue = stringvalue.replace('</p>', '');
                              if (!stringvalue.replace(/\s/g, '').length) {
                                  var toastEvent = $A.get("e.force:showToast");
                                  toastEvent.setParams({
                                      title : 'NOTHING WRITTEN',
                                      message: 'Please write something.',
                                      
                                      type: 'error',
                                      
                                  });
                                  toastEvent.fire();
                                  console.log('string only contains whitespace (ie. spaces, tabs or line breaks)');
                              }
                              else {
                                  let myValCopy = component.get("v.myVal");
                                  console.log('my vlaue to save '+JSON.parse(JSON.stringify(myValCopy)));
                                  let action = component.get("c.saveNotes");
                                  //  let accountId = component.get("v.recordId");
                                  let accountId = component.get("v.accountId");
                                  var addData  = component.get("v.myVal");
                                  let myVal = component.get("v.myVal");
                                  
                                  let medicationsToSave = component.get("v.medicationsToSave");
                                  
                                  action.setParams({
                                      noteType :component.get("v.noteType"), 
                                      accountId : accountId,
                                      textBody : myVal,
                                      medicationsToSave : JSON.stringify({'medicines' : medicationsToSave})
                                      
                                  });
                                  action.setCallback(this, function(response) {
                                      var state = response.getState();
                                      if (state === "SUCCESS") {   
                                          component.set("v.cmpName" , '');
                                          //component.set("v.isOpen",false);
                                          var resp = response.getReturnValue(); 
                                          component.set("v.myVal",'');
                                          //component.set("v.disbaled",f);
                                          var toastEvent = $A.get("e.force:showToast");
                                          toastEvent.setParams({
                                              title : 'Success',
                                              message: 'Notes have been successfully submitted.',
                                              duration:' 5000',
                                              key: 'info_alt',
                                              type: 'success',
                                              mode: 'pester'
                                          });
                                          toastEvent.fire();
                                          var workspaceAPI = component.find("workspace");
                                          workspaceAPI.getFocusedTabInfo().then(function(response) {
                                              var focusedTabId = response.tabId;
                                              workspaceAPI.refreshTab({
                                                  tabId: focusedTabId,
                                                  includeAllSubtabs: true
                                              });
                                          })
                                          .catch(function(error) {
                                              console.log(error);
                                          });
                                          /*var workspaceAPI = component.find("workspace");
                                                          workspaceAPI.getFocusedTabInfo().then(function(response) {
                                                              var focusedTabId = response.tabId;
                                                              workspaceAPI.closeTab({tabId: focusedTabId});
                                                          })
                                                          .catch(function(error) {
                                                              console.log(error);
                                                          });*/
                                          
                                      }else{    
                                          var errors = response.getError();
                                          if (errors) {
                                              if (errors[0]) {
                                                  console.log("Error message: " +
                                                              errors[0].message);
                                              }        }
                                      }
                                      
                                  });
                                  $A.enqueueAction(action);
                                  
                                  var btn = component.find('btn1');
                                  
                              }
                              
                              
                          },
                          cancelNotes : function(component, event, helper){
                              component.set("v.cmpName" , '');
                              component.set("v.isOpen" , false);
                          },
                          handleHPi: function(component, event, helper){
                              component.set("v.HpiInput",component.get("v.HpiInput"))
                          },
                          handleRos: function(component, event, helper){
                              var name =[];
                              name= event.getSource().get("v.label");
                              var value = event.getSource().get("v.value");
                              console.log('values '+value);
                              console.log('name '+name); 
                              var dataMap = component.get("v.ROSDisplayData");;
                              console.log('Json 00'+JSON.stringify(dataMap));
                              
                              dataMap[name] = value;
                              
                              component.set("v.ROSDisplayData",dataMap);
                              console.log('JSON '+JSON.stringify(dataMap));
                          },
                          
                          addNewChiefComplaintsRow: function(component, event, helper) {
                              
                              helper.createChiefComplaintsObjectData(component, event);
                          },
                          
                          removeDeletedChiefComplaintsRow: function(component, event, helper) {
                              
                              var ctarget = event.currentTarget;
                              var index = ctarget.dataset.value;
                              
                              var AllRowsList = component.get("v.EhrConditions");
                              AllRowsList.splice(index, 1);
                              
                              component.set("v.EhrConditions", AllRowsList);
                          },
                          addNewPrescriptionsRow: function(component, event, helper) {
                              
                              helper.createPrescriptionsObjectData(component, event);
                          },
                          
                          removeDeletedPrescriptionsRow: function(component, event, helper) {
                              
                              var ctarget = event.currentTarget;
                              var index = ctarget.dataset.value;
                              
                              var AllRowsList = component.get("v.PrescriptionsList");
                              AllRowsList.splice(index, 1);
                              
                              component.set("v.PrescriptionsList", AllRowsList);
                          },
                          addNewRow: function(component, event, helper) {
                              
                              helper.createPastData(component, event);
                          },
                          removeDeletedRow: function(component, event, helper) {
                              
                              var ctarget = event.currentTarget;
                              var index = ctarget.dataset.value;
                              
                              var AllRowsList = component.get("v.parentProblemTable");
                              
                              AllRowsList.splice(index, 1);
                              
                              component.set("v.parentProblemTable", AllRowsList);
                          },
                          handleSocial: function(component, event, helper){
                              component.set("v.newSocial",component.get("v.newSocial"))
                          },
                          handleFamily: function(component, event, helper){
                              component.set("v.newFamily",component.get("v.newFamily"))
                          },
                          handlenewHelthDia: function(component, event, helper){
                              component.set("v.newhealthDiagnosis",component.get("v.newhealthDiagnosis"))
                          } ,                     
                          removeDeletedRowDiet   : function(component, event, helper){
                              component.set("v.dietaryHistory",[]);
                              component.set("v.isDietary",false);
                              helper.pushDietType(component);
                          },
                          removeDeletedRowMeasurement: function(component, event, helper){
                              component.set("v.measurements",[]);
                              component.set("v.isMeasurement",false);
                          },
                          removeDeletedRowVitals: function(component, event, helper){
                              component.set("v.isVital",false);
                              component.set("v.newVitalSign",[]);
                          },
                          removeDeletedRowCheif: function(component, event, helper){
                              component.set("v.isChiefComplaints",false);
                              component.set("v.EhrConditions",[]);
                          },
                          removeDeletedRowpres: function(component, event, helper){
                              component.set("v.isPrescriptions",false);
                              component.set("v.PrescriptionsList",[]);
                          },
                          removeDeletedRowWeightHistory: function(component, event, helper){
                              component.set("v.isWeightHistory",false);
                              component.set("v.weightHistory",[]);
                          },
                          removeAll: function(component, event, helper) {
                              //component.set("v.myVal",""); 
                              
                              component.set("v.diagnosis",[]);
                              component.set("v.medications",[]);
                              component.set("v.procedure",[]);
                              component.set("v.Vital",false);
                              component.set("v.isDietary",false);
                              component.set("v.isPrescriptions",false);
                              component.set("v.isChiefComplaints",false);
                              component.set("v.PrescriptionsList",[]);
                              component.set("v.EhrConditions",[]);
                              component.set("v.isWeightHistory",false);
                              component.set("v.weightHistory",[]);
                              component.set("v.dietaryHistory",[]);
                              component.set("v.measurements",[]);
                              component.set("v.isMeasurement",false);
                              component.set("v.newVitalSign",[]);
                              component.set("v.additionalNotes",'');
                              component.set("v.description",'');
                              component.set("v.frequency",'');
                              component.set("v.testName",'');
                              component.set("v.labName",'');
                              component.set("v.statByPhone",'');
                              component.set("v.statByFax",'');
                          }
                         })
({
    myAction: function(component, event, helper) {	
        
       var action = component.get('c.abc');
        component.set("v.ROSDisplayData",{});
        action.setParams({
            acctId : component.get("v.accountId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {   
                var resp = response.getReturnValue(); 
                component.set("v.optionsnew",resp.relatedProblems1);                
                component.set("v.ROSData",resp.formFields);
                component.set("v.currentMedi" , resp.currentMed);
                if(!$A.util.isUndefinedOrNull(resp.medHistorySocial)){
                    component.set("v.newSocial" , JSON.stringify(resp.medHistorySocial[0].ElixirSuite__Description__c));
                    component.set("v.newFamily" , JSON.stringify(resp.medHistoryFamily[0].ElixirSuite__Description__c));
                }
                if(!$A.util.isUndefinedOrNull(resp.medHistoryPast)){
                    component.set("v.newhealthDiagnosis" , JSON.stringify(resp.medHistoryPast[0].ElixirSuite__Description__c));
                }
                
                var data1= resp.currentMed ;
                var selections1 = '';
                 var i = 0 ;
                data1.forEach(option => {
                    i++ ;
                    selections1 += i+'.'+' ' + option.ElixirSuite__MedicationName__c+' '+'-'+' '+ option.ElixirSuite__Notes__c+'\n';
                });
                    component.set("v.newc" ,selections1);
                //alert('data-- '+JSON.stringify(resp.currentMed));
                
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
                              var ctarget = event.currentTarget;
                              var index = ctarget.dataset.value;      
                              var AllRowsList = component.get("v.parentProblemTable");
                              AllRowsList.splice(index, 1);
                              
                              component.set("v.parentProblemTable", AllRowsList);
                          },
                          
                          handleComponentEvent: function(component, event, helper) {
                              var myVal = component.get("v.myVal");
                              var eventValue = event.getParams().selectedValue;
                              console.log('##new'+JSON.stringify(eventValue));
                              var description = eventValue.Description;
                              if(description == undefined){
                                  description = '';
                              }
                              if(eventValue.Type.toLowerCase() == 'problems'){
                                  if(myVal.includes('Problems:')){
                                      let splitMyval = [];
                                      splitMyval = myVal.split('Problems:</b>');
                                      splitMyval[0]+= 'Problems:</b>';
                                      splitMyval[0]+= '<br/>' + eventValue.FieldName+ ' - ' + description;
                                      myVal = splitMyval.join();
                                  }else{
                                      myVal+=' <b style="color:#493266;font-size:15px;">Problems:</b><br/> '+eventValue.FieldName + ' - ' + description;   
                                  }
                                  
                                  let problemsToSave = [];
                                  problemsToSave = component.get("v.problemsToSave");
                                  problemsToSave.push({'Id' : eventValue.Id, 'FieldName' : eventValue.FieldName, 'Description' : description});
                                  component.set("v.problemsToSave",problemsToSave);
                              }
                              else if(eventValue.Type.toLowerCase() == 'healthcarediagnosis'){
                                  if(myVal.includes('Diagnosis:')){
                                      let splitMyval = [];
                                      splitMyval = myVal.split('Diagnosis:');
                                      splitMyval[0]+= 'Diagnosis:</b>';
                                      splitMyval[0]+= '<br/>' + eventValue.FieldName;
                                      myVal = splitMyval.join();
                                  }else{
                                      myVal+=' <b style="color:#493266;font-size:15px;">Diagnosis:</b><br/>'+eventValue.FieldName;  
                                  }
                                  let diagToSave = [];
                                  diagToSave = component.get("v.diagToSave");
                                  diagToSave.push({'Id' : eventValue.Id, 'FieldName' : eventValue.FieldName, 'Description' : description});
                                  component.set("v.diagToSave",diagToSave);
                              }
                                  else if(eventValue.Type.toLowerCase() == 'medications'){
                                      let medications = component.get("v.medications");
                                      if($A.util.isUndefinedOrNull(medications)){
                                          medications = [];
                                      }
                                      medications.push({'Id': eventValue.Id, 'FieldName': eventValue.FieldName, 'Description': eventValue.Description});
                                      component.set("v.medications",medications);
                                      component.set("v.isMeasurement" , false);
                                      component.set("v.Vital" , true);
                                      component.set("v.CM" , false);
                                      component.set("v.ROS" , false);
                                      component.set("v.HPI" , false);
                                      component.set("v.isPrescriptions" , false);
                                      component.set("v.isChiefComplaints" , false);
                                      component.set("v.isVital" , false);
                                        component.set("v.isLab" , false);
                                      component.set("v.isSocial" , false);
                                                        component.set("v.isFamily" , false);
                                                        component.set("v.ishealthDiagnosis" , false);
                                  }    
                                      else if(eventValue.Type.toLowerCase() == 'laborders'){
                                          let labOrders = component.get("v.labOrders");
                                          if($A.util.isUndefinedOrNull(labOrders)){
                                              labOrders = [];
                                          }
                                          component.set("v.isMeasurement" , false);
                                          labOrders.push({'Id': eventValue.Id, 'FieldName': eventValue.FieldName, 'Description': eventValue.Description});
                                          component.set("v.labOrders",labOrders);
                                      }
                                          else if(eventValue.Type.toLowerCase() == 'custommetadatatype'){
                                              if(eventValue.FieldName == 'Vital Signs'){   
                                                  component.set("v.Vital" , true);
                                                  component.set("v.isVital" , true);
                                                  component.set("v.CM" , false);
                                                  component.set("v.ROS" , false);
                                                  component.set("v.HPI" , false);
                                                  component.set("v.isLab" , false);
                                                  component.set("v.isMeasurement" , false);
                                                  component.set("v.isPrescriptions" , false);
                                                  component.set("v.isChiefComplaints" , false);
                                                  component.set("v.isSocial" , false);
                                                        component.set("v.isFamily" , false);
                                                        component.set("v.ishealthDiagnosis" , false);
                                              }
                                              else if(eventValue.FieldName == 'HPI' || eventValue.FieldName == 'History of Present Illness'){    
                                                  component.set("v.Vital" , true);   
                                                  component.set("v.HPI" , true);
                                                  component.set("v.CM" , false);
                                                  component.set("v.ROS" , false);
                                                  component.set("v.isPrescriptions" , false);
                                                  component.set("v.isChiefComplaints" , false);
                                                  component.set("v.isVital" , false);
                                                    component.set("v.isLab" , false);
                                                  component.set("v.isSocial" , false);
                                                  component.set("v.isMeasurement" , false);
                                                        component.set("v.isFamily" , false);
                                                        component.set("v.ishealthDiagnosis" , false);
                                              }
                                                  else if(eventValue.FieldName == 'Review of system' ){    
                                                      component.set("v.Vital" , true);
                                                      component.set("v.ROS" , true);
                                                      component.set("v.CM" , false);
                                                      component.set("v.HPI" , false);
                                                      component.set("v.isMeasurement" , false);
                                                      component.set("v.isPrescriptions" , false);
                                                      component.set("v.isChiefComplaints" , false);
                                                      component.set("v.isVital" , false);
                                                        component.set("v.isLab" , false);
                                                      component.set("v.isSocial" , false);
                                                        component.set("v.isFamily" , false);
                                                        component.set("v.ishealthDiagnosis" , false);
                                                      
                                                  }
                                              else if(eventValue.FieldName == 'Current Medications'){    
                            
                                                  component.set("v.Vital" , true);
                                                  component.set("v.CM" , true);
                                                  component.set("v.ROS" , false);
                                                  component.set("v.HPI" , false);
                                                    component.set("v.isLab" , false);
                                                  component.set("v.isMeasurement" , false);
                                                  component.set("v.isPrescriptions" , false);
                                                  component.set("v.isChiefComplaints" , false);
                                                  component.set("v.isVital" , false);
                                                  component.set("v.isSocial" , false);
                                                        component.set("v.isFamily" , false);
                                                        component.set("v.ishealthDiagnosis" , false);
                                                }
                                                  else if(eventValue.FieldName == 'Physical Exam'){    
                                                      if(myVal.includes('Physical Exam:')){
                                                          let splitMyval = [];
                                                          splitMyval = myVal.split('Physical Exam:');
                                                          splitMyval[0]+= 'Physical Exam:</b>';
                                                          splitMyval[0]+= '<br/>' + 'HEENT: Positive JVD'+'<br/>'+'Lungs: Bibasilar crackles'+'<br/>'+'CV: RRR, no MRGs'+'<br/>'+'Extremities:  3+ bipedal edema; no digital cyanosis'+'<br/>'+'Psyche: A&O times 3, with appropriate affect'+'<br/>'+'Labs: BUN 33, creatinine 1.6, K 4.0, HCO3 20, HGB 11.0, BNP 1750'+'<br/>'+'CXR was reviewed and showed increased pulmonary vascular congestion and a small left effusion';
                                                          myVal = splitMyval.join();
                                                      }else{
                                                          myVal+=' <b style="color:#493266;font-size:15px;">Physical Exam:</b><br/>'+'HEENT: Positive JVD'+'<br/>'+'Lungs: Bibasilar crackles'+'<br/>'+'CV: RRR, no MRGs'+'<br/>'+'Extremities:  3+ bipedal edema; no digital cyanosis'+'<br/>'+'Psyche: A&O times 3, with appropriate affect'+'<br/>'+'Labs: BUN 33, creatinine 1.6, K 4.0, HCO3 20, HGB 11.0, BNP 1750'+'<br/>'+'CXR was reviewed and showed increased pulmonary vascular congestion and a small left effusion';
                                                          
                                                      }
                                                      component.set("v.Vital" , false);
                                                      component.set("v.CM" , false);
                                                      component.set("v.ROS" , false);
                                                      component.set("v.HPI" , false);
                                                      component.set("v.isMeasurement" , false);
                                                      component.set("v.isPrescriptions" , false);
                                                      component.set("v.isChiefComplaints" , false);
                                                      component.set("v.isVital" , false);
                                                        component.set("v.isLab" , false);
                                                      component.set("v.isSocial" , false);
                                                        component.set("v.isFamily" , false);
                                                        component.set("v.ishealthDiagnosis" , false);
                                                  }
                                              else if(eventValue.FieldName == 'Chief Complaints')
                                                {
                                                    
                                                    helper.createChiefComplaintsObjectData(component, event);
                                                    component.set('v.isChiefComplaints',true);
                                                    component.set('v.isPrescriptions',false);
                                                    component.set("v.Vital" , true);
                                                    component.set("v.CM" , false);
                                                    component.set("v.ROS" , false);
                                                    component.set("v.HPI" , false);
                                                    component.set("v.isMeasurement" , false);
                                                    component.set("v.isVital" , false);
                                                      component.set("v.isLab" , false);
                                                    component.set("v.isSocial" , false);
                                                        component.set("v.isFamily" , false);
                                                        component.set("v.ishealthDiagnosis" , false);
                                                    console.log('#### inside chief complaints');
                                                }
                                                else if(eventValue.FieldName == 'Prescriptions')
                                                {
                                                    helper.createPrescriptionsObjectData(component, event);
                                                    component.set('v.isPrescriptions',true);
                                                    component.set('v.isChiefComplaints',false);
                                                    component.set("v.Vital" , true);
                                                    console.log('#### inside isPrescriptions');
                                                    component.set("v.CM" , false);
                                                    component.set("v.isMeasurement" , false);
                                                    component.set("v.ROS" , false);
                                                    component.set("v.HPI" , false);
                                                    component.set("v.isVital" , false);
                                                     component.set("v.isLab" , false);
                                                    component.set("v.isSocial" , false);
                                                        component.set("v.isFamily" , false);
                                                        component.set("v.ishealthDiagnosis" , false);
                                                }
                                                    else if(eventValue.FieldName == 'Lab Orders'){    
                                                        component.set("v.Vital" , true);
                                                        component.set("v.isLab" , true);
                                                        component.set('v.isPrescriptions',false);
                                                        component.set('v.isChiefComplaints',false);
                                                        component.set("v.CM" , false);
                                                        component.set("v.ROS" , false);
                                                        component.set("v.HPI" , false);
                                                        component.set("v.isMeasurement" , false);
                                                        component.set("v.isVital" , false);
                                                        component.set("v.isSocial" , false);
                                                        component.set("v.isFamily" , false);
                                                        component.set("v.ishealthDiagnosis" , false);
                                                    }
                                               else if(eventValue.FieldName == 'Social History'){    
                                                        component.set("v.Vital" , true);
                                                        component.set("v.isSocial" , true);
                                                        component.set('v.isPrescriptions',false);
                                                        component.set('v.isChiefComplaints',false);
                                                        component.set("v.CM" , false);
                                                        component.set("v.ROS" , false);
                                                        component.set("v.HPI" , false);
                                                   component.set("v.isMeasurement" , false);
                                                        component.set("v.isVital" , false);
                                                   		component.set("v.isLab" , false);
                                                    }
                                               else if(eventValue.FieldName == 'Family History'){    
                                                        component.set("v.Vital" , true);
                                                        component.set("v.isFamily" , true);
                                                        component.set('v.isPrescriptions',false);
                                                        component.set('v.isChiefComplaints',false);
                                                        component.set("v.CM" , false);
                                                        component.set("v.ROS" , false);
                                                        component.set("v.HPI" , false);
                                                   component.set("v.isMeasurement" , false);
                                                        component.set("v.isVital" , false);
                                                   		component.set("v.isLab" , false);
                                                    }
                                               else if(eventValue.FieldName == 'Past Medical/Surgical History'){    
                                                        component.set("v.Vital" , true);
                                                        component.set("v.ishealthDiagnosis" , true);
                                                        component.set('v.isPrescriptions',false);
                                                        component.set('v.isChiefComplaints',false);
                                                        component.set("v.CM" , false);
                                                        component.set("v.ROS" , false);
                                                   component.set("v.isMeasurement" , false);
                                                        component.set("v.HPI" , false);
                                                        component.set("v.isVital" , false);
                                                   		component.set("v.isLab" , false);
                                                    }
                                                   else if(eventValue.FieldName == 'Measurements'){
                                                       component.set("v.Vital" , false);
                                                       component.set("v.ishealthDiagnosis" , false);
                                                       component.set('v.isPrescriptions',false);
                                                       component.set('v.isChiefComplaints',false);
                                                       component.set("v.CM" , false);
                                                       component.set("v.ROS" , false);
                                                       component.set("v.HPI" , false);
                                                       component.set("v.isVital" , false);
                                                       component.set("v.isLab" , false);
                                                       component.set("v.isLab" , false);
                                                       component.set("v.isMeasurement" , true);
                                                   }
                                              
                                              
                                          }
                              
                                              else{
                                                  myVal+= eventValue.FieldName;
                                                  component.set("v.Vital" , false);
                                                  component.set("v.CM" , false);
                                                  component.set("v.ROS" , false);
                                                  component.set("v.HPI" , false);
                                                  component.set("v.isMeasurement" , false);
                                                  component.set("v.isPrescriptions" , false);
                                                  component.set("v.isChiefComplaints" , false);
                                                  component.set("v.isVital" , false);
                                                    component.set("v.isLab" , false);
                                              } 
                              component.set("v.myVal",myVal);
                          },
addNotes: function(component, event, helper) {
                              helper.addNotesHelper(component, event, helper);
                              helper.addLabOrdersHelper(component, event, helper);
                              helper.addVitalsHelper(component, event, helper);
                              helper.addHPIHelper(component, event, helper);
                              helper.addRosHelper(component, event, helper);
                              helper.addCurrentMedicationsHelper(component, event, helper);
    						helper.addChiefComplaintsHelper(component, event, helper);
        					helper.addPrescriptionsHelper(component, event, helper);
    helper.addLabOrders(component, event, helper);
    helper.addSocialHelper(component, event, helper);
        helper.addFamilyHelper(component, event, helper);
        //helper.addPastMedicalHelper(component, event, helper);
        helper.addPastMedicalHelperTable(component, event, helper);
                          },
handleClickFreeTextCode : function(component, event, helper) {
                              var selectedOptionValue = component.get("v.selectedValues");
                              var index = event.getSource().get("v.name");
                              // var value = event.getSource().get("v.value");      
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
                              let myValCopy = component.get("v.myVal");
                             var careplandataStringified =  helper.arrangeCareplandata(component, event, helper);
                              console.log('my vlaue to save '+JSON.parse(JSON.stringify(myValCopy)));
                              let action = component.get("c.saveNotes");
                              //  let accountId = component.get("v.recordId");
                              let accountId = component.get("v.recordId");
                              
                               var addData  = component.get("v.myVal");
                               addData = addData +  careplandataStringified;
                              component.set("v.myVal",addData);
                              let myVal = component.get("v.myVal");
                           
                              console.log('my vlaue to save '+JSON.parse(JSON.stringify(myVal)));
                              let medicationsToSave = component.get("v.medicationsToSave");
                              let labOrdersToSave = component.get("v.labOrdersToSave");
                              let diagToSave = component.get("v.diagnosis");
                              let problemsToSave = component.get("v.problemsToSave");
                              let vitalsToSave = component.get("v.newVitalSign");
                              var careplanData = {'cpData' :  component.get("v.parentProblemTable")};
                              let newSocial = component.get("v.newSocial");
        					let newFamily = component.get("v.newFamily");
                              let newDia = component.get("v.newhealthDiagnosis");
                              
                              action.setParams({
                                  accountId : accountId,
                                  textBody : myVal,
                                   newSocial :newSocial,
            						newFamily : newFamily,
                                   newDiagnosis : newDia,
                                  medicationsToSave : JSON.stringify({'medicines' : medicationsToSave}),
                                  labOrdersToSave : JSON.stringify({'labOrders' : labOrdersToSave}),
                                  diagToSave : JSON.stringify({'diagnosis' : diagToSave}),
                                  problemsToSave : JSON.stringify({'problems' : problemsToSave}),
                                  vitalsToSave :  JSON.stringify({'vitals':vitalsToSave}),
                                  carePlanDataParent : JSON.stringify(careplanData),
                                  prescriptionsToSave : component.get("v.PrescriptionsToSave"),
                                   caseId : component.get("v.selectedValue")
                                  
                              });
                              action.setCallback(this, function(response) {
                                  var state = response.getState();
                                  if (state === "SUCCESS") {   
                                      component.set("v.cmpName" , '');
                                      //component.set("v.isOpen",false);
                                      var resp = response.getReturnValue(); 
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
                            chosenPlan: function(component, event, helper){
                              var myVal = component.get("v.myVal");
                              var selectedValue = component.get("v.selectedValue");
                              var carePlanName = '';
                              for(let rec in component.get("v.optionsnew")){
                                  if(component.get("v.optionsnew")[rec].Id == selectedValue){
                                      carePlanName = component.get("v.optionsnew")[rec].ElixirSuite__Care_Plan_Name__c;
                                  	  break;
                                  }
                              }
                              if(myVal.includes('Care Plan:')){
                                      let splitMyval = [];
                                      splitMyval = myVal.split('Care Plan:</b>');
                                      splitMyval[0]+= 'Care Plan:</b>';
                                      splitMyval[0]+= '<br/>' + carePlanName;
                                      myVal = splitMyval.join();
                                  }else{
                                      myVal+=' <b style="color:#493266;font-size:15px;">Care Plan:</b><br/>'+carePlanName;
                                  }
                              component.set("v.myVal",myVal);
                              
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
 	 removeDeletedRowCheif: function(component, event, helper){
                              component.set("v.isChiefComplaints",false);
                          },
                          removeDeletedRowpres: function(component, event, helper){
                              component.set("v.isPrescriptions",false);
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
       
        var AllRowsList = component.get("v.MedicalHistory");
        AllRowsList.splice(index, 1);
       
        component.set("v.MedicalHistory", AllRowsList);
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
    removeAll: function(component, event, helper) {
                              component.set("v.myVal","");  
                              component.set("v.Vital",false);
                          }                      
                          
})
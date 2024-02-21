({
    searchField : function(component, event, helper, selectedLabel,selectedId) {
        try{
            var recordsListLabel = selectedLabel;
            component.set("v.selectedRecordName", recordsListLabel);
            // var searchString = component.get('v.searchString');
            var action = component.get("c.searchRelatedProblem");
            action.setParams({
                "searchKeyWord" : recordsListLabel,
                'icdVersion' : component.get('v.ICDSearchParam')
            });
            action.setCallback(this, function(response){
                var STATE = response.getState();
                if(STATE === "SUCCESS") {
                    let allRecArr = [];
                    let junctionRec = response.getReturnValue().lstOfRecords;
                    let recTemplateProblem = response.getReturnValue().recTemplateProblem;
                    console.log('junctionRec in addonlydiagnosis'+JSON.stringify( junctionRec));
                    console.log('recTemplateProblem in addonlydiagnosis'+JSON.stringify( recTemplateProblem));
                    if(!$A.util.isEmpty(junctionRec)){
                        for(let rec in junctionRec){
                            if(!$A.util.isUndefinedOrNull(junctionRec[rec].ElixirSuite__Template_Problem__r)){
                                allRecArr.push({ 'diagnosisCodeName' :  junctionRec[rec].ElixirSuite__Diagnosis_Code__r.Name,
                                                'diagnosisId' :  junctionRec[rec].ElixirSuite__Diagnosis_Code__r.Id,
                                                'icdVersion' :  junctionRec[rec].ElixirSuite__Diagnosis_Code__r.ElixirSuite__Version__c,
                                                'description' :  junctionRec[rec].ElixirSuite__Diagnosis_Code__r.ElixirSuite__Code_Description1__c,
                                                'templateProbName' : junctionRec[rec].ElixirSuite__Template_Problem__r.Name,
                                                'snowmed' : junctionRec[rec].ElixirSuite__Template_Problem__r.ElixirSuite__SNOMED_CT_Code__c,
                                                'notes':  junctionRec[rec].ElixirSuite__Template_Problem__r.ElixirSuite__Note__c,
                                                'Id' : junctionRec[rec].ElixirSuite__Template_Problem__r.Id,
                                                'problemDescription': junctionRec[rec].ElixirSuite__Template_Problem__r.ElixirSuite__Description__c
                                               });
                            }else{
                                allRecArr.push({ 'diagnosisCodeName' :  junctionRec[rec].ElixirSuite__Diagnosis_Code__r.Name,
                                                'diagnosisId' :  junctionRec[rec].ElixirSuite__Diagnosis_Code__r.Id,
                                                'icdVersion' :  junctionRec[rec].ElixirSuite__Diagnosis_Code__r.ElixirSuite__Version__c,
                                                'description' :  junctionRec[rec].ElixirSuite__Diagnosis_Code__r.ElixirSuite__Code_Description1__c,
                                               });
                            }
                        }
                    }
                    else if(!$A.util.isEmpty(recTemplateProblem)){
                        for(let rec in recTemplateProblem){
                            allRecArr.push({
                                
                                'diagnosisCodeName' :  recTemplateProblem[rec].Name,
                                'diagnosisId' :  recTemplateProblem[rec].Id,
                                'icdVersion' :  recTemplateProblem[rec].ElixirSuite__Version__c,
                                'description' :  recTemplateProblem[rec].ElixirSuite__Code_Description1__c
                            });
                        }  
                    }
                    let res  = allRecArr;
                    console.log('res'+JSON.stringify( res));
                    let mapOfIdAndSObj = {};
                    for(let sObj in res){
                        mapOfIdAndSObj  = res[sObj];
                    }
                    component.set("v.MapOfIdAndSObj",res); 
                    console.log('map value '+JSON.stringify( mapOfIdAndSObj));
                    console.log('ret value '+JSON.stringify(allRecArr));
                    helper.setValue( component, event, helper,selectedId);
                }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            
                        }
                    } else {  
                        
                    }
                }
            });
            $A.enqueueAction(action);
        }
        catch(e){
            alert('error 1'+e);
        }
    },
    setValue : function(component, event, helper, selectedId) {
        try{
            let mapOfIdAndsObj = JSON.stringify(component.get('v.MapOfIdAndSObj')); 
            if (!$A.util.isEmpty(mapOfIdAndsObj)){
                console.log('mapOfIdAndsObj'+mapOfIdAndsObj);
                var currentText = selectedId;
                console.log('currentText '+currentText);
                component.set("v.selectRecordId", currentText);
                var cmpEvent = component.getEvent("diagnosisEvent");
                cmpEvent.setParams( { "recordAsObject" :  mapOfIdAndsObj, 
                                      "index" : component.get("v.index") // this is index
                                    } );
                cmpEvent.fire();
            }
        }
        catch(e){
            alert('error 11'+e.stack);
        }  
    }
})
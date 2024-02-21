({
    checkValNull : function(component, event, helper,repSobj) {
        if($A.util.isUndefinedOrNull(repSobj.ElixirSuite__Template_Problem__r)){
            repSobj['ElixirSuite__Template_Problem__r'] = {'Name' : ''};
            repSobj['ElixirSuite__Template_Problem__r'] = {'ElixirSuite__SNOMED_CT_Code__c' : ''};
            repSobj['ElixirSuite__Template_Problem__r'] = {'ElixirSuite__Note__c' : ''};
             repSobj['ElixirSuite__Template_Problem__r'] = {'ElixirSuite__Description__c' : ''};
        }
        if($A.util.isUndefinedOrNull(repSobj.ElixirSuite__Diagnosis_Code__r)){
            repSobj['ElixirSuite__Diagnosis_Code__r'] = {'Name' : ''};
        }
    },
    searchWithICDFilter :  function(component, event, helper,param,currentText) {
        console.log('searchWithICDFilter '+JSON.stringify(param)+'currenttext '+currentText); 
        var action = component.get("c.searchWithParam");
        action.setParams({
            "searchKeyWord" : currentText,
            "param" : param
        });
        action.setCallback(this, function(response){
            var STATE = response.getState();
            if(STATE === "SUCCESS") {
                console.log('Calling searchWithICDFilter');
                let allRecArr = [];
                let junctionRec = response.getReturnValue().lstOfRecords;
                   console.log('junctionRec length Loading' + junctionRec.length);
                let recTemplateProblem = response.getReturnValue().recTemplateProblem;
                 console.log('recTemplateProblem length Loading' + recTemplateProblem.length);
                console.log('recTemplateProblem ' + JSON.stringify(recTemplateProblem));
                for(let rec in junctionRec){
                    helper.checkValNull(component, event, helper,junctionRec[rec]);
                    if(!$A.util.isUndefinedOrNull(junctionRec[rec].ElixirSuite__Diagnosis_Code__r)){
                    allRecArr.push({'templateProbName' : junctionRec[rec].ElixirSuite__Template_Problem__r.Name,
                                    'snowmed' : junctionRec[rec].ElixirSuite__Template_Problem__r.ElixirSuite__SNOMED_CT_Code__c,
                                    'notes':  junctionRec[rec].ElixirSuite__Template_Problem__r.ElixirSuite__Note__c,
                                    'Id' : junctionRec[rec].ElixirSuite__Template_Problem__r.Id,
                                            'problemDescription': junctionRec[rec].ElixirSuite__Template_Problem__r.ElixirSuite__Description__c,
                                    'diagnosisCodeName' :  junctionRec[rec].ElixirSuite__Diagnosis_Code__r.Name,
                                    'diagnosisId' :  junctionRec[rec].ElixirSuite__Diagnosis_Code__r.Id,
                                           // 'diagnosisType':'',
                                    'icdVersion' :  junctionRec[rec].ElixirSuite__Diagnosis_Code__r.ElixirSuite__Version__c,
                                            'description' :  junctionRec[rec].ElixirSuite__Diagnosis_Code__r.ElixirSuite__Code_Description1__c
                                   });
                              }else{
                                allRecArr.push({'templateProbName' : junctionRec[rec].ElixirSuite__Template_Problem__r.Name,
                                            'snowmed' : junctionRec[rec].ElixirSuite__Template_Problem__r.ElixirSuite__SNOMED_CT_Code__c,
                                            'notes':  junctionRec[rec].ElixirSuite__Template_Problem__r.ElixirSuite__Note__c,
                                            'Id' : junctionRec[rec].ElixirSuite__Template_Problem__r.Id,
                                            'problemDescription': junctionRec[rec].ElixirSuite__Template_Problem__r.ElixirSuite__Description__c,
                                           // 'diagnosisCodeName' : '',
                                           // 'diagnosisId' :  '',
                                            //'diagnosisType':'',
                                           // 'icdVersion' :  '',
                                           // 'description' :  ''
                                           });   
                              }
                }
                  console.log('allRecArr 1 '+JSON.stringify(allRecArr));
                for(let rec in recTemplateProblem){
                    if(!recTemplateProblem[rec].ElixirSuite__SNOMED_CT_Code__c){
                      //  recTemplateProblem[rec].ElixirSuite__SNOMED_CT_Code__c = 'N/A';
                    }
                    allRecArr.push({'templateProbName' : recTemplateProblem[rec].Name,
                                    'snowmed' : recTemplateProblem[rec].ElixirSuite__SNOMED_CT_Code__c,
                                    'Id' : recTemplateProblem[rec].Id,
                                  'problemDescription': recTemplateProblem[rec].ElixirSuite__Description__c,
                                   // 'diagnosisCodeName' : '',
                                  //  'icdVersion' :  '',
                                  //   'diagnosisType':'',
                                    'notes':  recTemplateProblem[rec].ElixirSuite__Note__c
                                  //   'description' :  ''
                                   });
                }
                
                 console.log('allRecArr 2 '+JSON.stringify(allRecArr)); 
            
                let res  = allRecArr;
                let mapOfIdAndSObj = {};
                for(let sObj in res){
                    mapOfIdAndSObj[res[sObj].Id]  = res[sObj];
                }
                component.set("v.MapOfIdAndSObj",mapOfIdAndSObj); 
                console.log('map value '+JSON.stringify( mapOfIdAndSObj));
                const unique = [];
   for (const item of allRecArr) {
    const isDuplicate = unique.find((obj) => obj.Id === item.Id);
     if (!isDuplicate) {
    unique.push(item);
  }
}
        console.log(' unique '+JSON.stringify(unique)); 
                
                component.set("v.searchRecords", unique);
                console.log('ret value '+JSON.stringify(unique));
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        
                    }
                } else {  
                    
                }
            }
            component.set("v.LoadingText", false);
        });
        $A.enqueueAction(action);
    },
    searchDiagnosisRelated : function(component, event, helper,diagnosisName) {
       try{
                       component.set("v.LoadingText", true);

            var recordsListLabel = diagnosisName;
                var action = component.get("c.searchProblemDiagnosis");
                action.setParams({
                    "searchKeyWord" : recordsListLabel,
                    "param" : component.get("v.ICDSearchParam")
                });
                action.setCallback(this, function(response){
                    var STATE = response.getState();
                    if(STATE === "SUCCESS") {
                        console.log('Calling searchDiagnosisRelated');
                        let allRecArr = [];
                        let junctionRec = response.getReturnValue().lstOfRecords;
                        let recTemplateProblem = response.getReturnValue().recTemplateProblem;
                        console.log('junctionRec length ' + junctionRec.length);
                        console.log('junctionRec :-'+JSON.stringify(junctionRec));
                        /* junctionRec.forEach(function(element, index) {
                             console.log('element :-'+element.ElixirSuite__Template_Problem__r);
                             if(!element.ElixirSuite__Template_Problem__r.Name){
                                 helper.searchDiagnosisRelated1(component, event, helper); 
                             }
                              console.log('element :-'+element.ElixirSuite__Template_Problem__r);
                             
                         });*/
                     //  helper.searchDiagnosisRelated1(component, event, helper); 
                        if(junctionRec.length>=1){
                        for(let rec in junctionRec){
                             if(!$A.util.isUndefinedOrNull(junctionRec[rec].ElixirSuite__Diagnosis_Code__r)){
                            allRecArr.push({'templateProbName' : junctionRec[rec].ElixirSuite__Template_Problem__r.Name,
                                            'snowmed' : junctionRec[rec].ElixirSuite__Template_Problem__r.ElixirSuite__SNOMED_CT_Code__c,
                                            'notes':  junctionRec[rec].ElixirSuite__Template_Problem__r.ElixirSuite__Note__c,
                                            'Id' : junctionRec[rec].ElixirSuite__Template_Problem__r.Id,
                                            'problemDescription': junctionRec[rec].ElixirSuite__Template_Problem__r.ElixirSuite__Description__c,
                                            'diagnosisCodeName' :  junctionRec[rec].ElixirSuite__Diagnosis_Code__r.Name,
                                            'diagnosisId' :  junctionRec[rec].ElixirSuite__Diagnosis_Code__r.Id,
                                           // 'diagnosisType':'',
                                            'icdVersion' :  junctionRec[rec].ElixirSuite__Diagnosis_Code__r.ElixirSuite__Version__c,
                                            'description' :  junctionRec[rec].ElixirSuite__Diagnosis_Code__r.ElixirSuite__Code_Description1__c
                                           });
                              }else{
                                allRecArr.push({'templateProbName' : junctionRec[rec].ElixirSuite__Template_Problem__r.Name,
                                            'snowmed' : junctionRec[rec].ElixirSuite__Template_Problem__r.ElixirSuite__SNOMED_CT_Code__c,
                                            'notes':  junctionRec[rec].ElixirSuite__Template_Problem__r.ElixirSuite__Note__c,
                                            'Id' : junctionRec[rec].ElixirSuite__Template_Problem__r.Id,
                                            'problemDescription': junctionRec[rec].ElixirSuite__Template_Problem__r.ElixirSuite__Description__c,
                                              //    'diagnosisCodeName' : '',
                                           // 'diagnosisId' :  '',
                                           // 'diagnosisType':'',
                                          //  'icdVersion' :  '',
                                           // 'description' :  ''
                                           });   
                        }
                        }
                        
                        }else{
                           helper.searchDiagnosisRelated1(component, event, helper);  
                        }
                         for(let rec in recTemplateProblem){
                            if(!recTemplateProblem[rec].ElixirSuite__SNOMED_CT_Code__c){
                                recTemplateProblem[rec].ElixirSuite__SNOMED_CT_Code__c = '';
                            }
                            allRecArr.push({'templateProbName' : recTemplateProblem[rec].Name,
                                            'snowmed' : recTemplateProblem[rec].ElixirSuite__SNOMED_CT_Code__c,
                                            'Id' : recTemplateProblem[rec].Id,
                                            'problemDescription': recTemplateProblem[rec].ElixirSuite__Description__c,
                                          //  'diagnosisCodeName' : '',
                                          //  'icdVersion' :  '',
                                            'notes':  recTemplateProblem[rec].ElixirSuite__Note__c,
                                           //'description' : ''
                                           });
                        }
                        console.log('allRecArr length ' + allRecArr.length);
                        let res  = allRecArr;
                        let mapOfIdAndSObj = {};
                        for(let sObj in res){
                            mapOfIdAndSObj[res[sObj].Id]  = res[sObj];
                        }
                        component.set("v.MapOfIdAndSObj",mapOfIdAndSObj); 
                        console.log('map value 123'+JSON.stringify( mapOfIdAndSObj));
                        
                         const unique = [];
   for (const item of allRecArr) {
    const isDuplicate = unique.find((obj) => obj.Id === item.Id);
     if (!isDuplicate) {
    unique.push(item);
  }
}
        console.log(' unique '+JSON.stringify(unique)); 
                
                component.set("v.searchRecords", unique);
                      //  component.set("v.searchRecords", allRecArr);
                        console.log('ret value 123 '+JSON.stringify(allRecArr));
                        console.log('allRecArr length :-' + JSON.stringify(allRecArr).length);
                    }
                    else if (state === "ERROR") {
                        var errors = response.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                        
                            }
                        }
                    }
                    component.set("v.LoadingText", false);
                });
                $A.enqueueAction(action);
        }
         catch(e){
            alert('error 1'+e.stack);
         }
                                   },
    searchDiagnosisRelated1 : function(component, event, helper) {
       try{
                       component.set("v.LoadingText", true);
            var recordsListLabel = component.get("v.currentTextProblem");
           console.log('recordsListLabel '+recordsListLabel);
                var action = component.get("c.searchProblemDiagnosis");
                action.setParams({
                    "searchKeyWord" : recordsListLabel,
                    "param" : component.get("v.ICDSearchParam")
                });
                action.setCallback(this, function(response){
                    var STATE = response.getState();
                    if(STATE === "SUCCESS") {
                         console.log('Calling searchDiagnosisRelated1');
                        let allRecArr = [];
                        let junctionRec = response.getReturnValue().lstOfRecords;
                         let recTemplateProblem = response.getReturnValue().recTemplateProblem;
                        for(let rec in junctionRec){
                          if(!$A.util.isUndefinedOrNull(junctionRec[rec].ElixirSuite__Diagnosis_Code__r)){
                            allRecArr.push({'templateProbName' : junctionRec[rec].ElixirSuite__Template_Problem__r.Name,
                                            'snowmed' : junctionRec[rec].ElixirSuite__Template_Problem__r.ElixirSuite__SNOMED_CT_Code__c,
                                            'notes':  junctionRec[rec].ElixirSuite__Template_Problem__r.ElixirSuite__Note__c,
                                            'Id' : junctionRec[rec].ElixirSuite__Template_Problem__r.Id,
                                            'problemDescription': junctionRec[rec].ElixirSuite__Template_Problem__r.ElixirSuite__Description__c,
                                            'diagnosisCodeName' :  junctionRec[rec].ElixirSuite__Diagnosis_Code__r.Name,
                                            'diagnosisId' :  junctionRec[rec].ElixirSuite__Diagnosis_Code__r.Id,
                                           // 'diagnosisType':'',
                                            'icdVersion' :  junctionRec[rec].ElixirSuite__Diagnosis_Code__r.ElixirSuite__Version__c,
                                            'description' :  junctionRec[rec].ElixirSuite__Diagnosis_Code__r.ElixirSuite__Code_Description1__c
                                           });
                              }else{
                                allRecArr.push({'templateProbName' : junctionRec[rec].ElixirSuite__Template_Problem__r.Name,
                                            'snowmed' : junctionRec[rec].ElixirSuite__Template_Problem__r.ElixirSuite__SNOMED_CT_Code__c,
                                            'notes':  junctionRec[rec].ElixirSuite__Template_Problem__r.ElixirSuite__Note__c,
                                            'Id' : junctionRec[rec].ElixirSuite__Template_Problem__r.Id,
                                            'problemDescription': junctionRec[rec].ElixirSuite__Template_Problem__r.ElixirSuite__Description__c,
                                              //    'diagnosisCodeName' : '',
                                            //'diagnosisId' :  '',
                                            //'diagnosisType':'',
                                            //'icdVersion' :  '',
                                            //'description' :  ''
                                           });   
                              }
                        }
                         for(let rec in recTemplateProblem){
                            if(!recTemplateProblem[rec].ElixirSuite__SNOMED_CT_Code__c){
                                recTemplateProblem[rec].ElixirSuite__SNOMED_CT_Code__c = '';
                            }
                            allRecArr.push({'templateProbName' : recTemplateProblem[rec].Name,
                                            'snowmed' : recTemplateProblem[rec].ElixirSuite__SNOMED_CT_Code__c,
                                            'Id' : recTemplateProblem[rec].Id,
                                             'problemDescription': recTemplateProblem[rec].ElixirSuite__Description__c,
                                           // 'diagnosisCodeName' : '',
                                           // 'icdVersion' :  '',
                                            'notes':  recTemplateProblem[rec].ElixirSuite__Note__c,
                                           //'description' : ''
                                           });
                        }
                        let res  = allRecArr;
                        let mapOfIdAndSObj = {};
                        for(let sObj in res){
                            mapOfIdAndSObj[res[sObj].Id]  = res[sObj];
                        }
                        component.set("v.MapOfIdAndSObj",mapOfIdAndSObj); 
                        console.log('map value 123'+JSON.stringify( mapOfIdAndSObj));
                        const unique = [];
   for (const item of allRecArr) {
    const isDuplicate = unique.find((obj) => obj.Id === item.Id);
     if (!isDuplicate) {
    unique.push(item);
  }
}
        console.log(' unique '+JSON.stringify(unique)); 
                       
                component.set("v.searchRecords", unique);
                     //   component.set("v.searchRecords", allRecArr);
                        console.log('ret value 123 '+JSON.stringify(allRecArr));
                                            
                    }
                    else if (state === "ERROR") {
                        var errors = response.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                
                            }
                        }
                    }
                    component.set("v.LoadingText", false);
                });
                $A.enqueueAction(action);
        }
         catch(e){
            alert('error 1'+e);
         }
                                   }
})
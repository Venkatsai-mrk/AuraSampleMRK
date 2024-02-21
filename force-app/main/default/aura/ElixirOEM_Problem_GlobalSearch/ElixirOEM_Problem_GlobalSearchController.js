({
    searchField : function(component, event, helper) {
        try{
            if(!$A.util.isUndefinedOrNull(component.get("v.ICDSearchParam"))){
            let searchParam = JSON.parse(JSON.stringify(component.get("v.ICDSearchParam")));
            component.set("v.currentVersion",searchParam.slice(-2));
                 }
           /* else{
            component.set('v.EmpList',true);
        }*/
            var currentText = event.getSource().get("v.value");   
            console.log('currentText '+JSON.stringify( currentText));
             component.set('v.EmpList',true);
            component.set("v.currentTextProblem", currentText);
            console.log('currentTextProblem '+component.get("v.currentTextProblem"));
            if(currentText.length > 0) {
                component.set('v.EmpList',true);}
            else {
                component.set('v.EmpList',false);
            }
          var diagnosisName =  component.get("v.diagnosisName");
            console.log('diagnosisName '+JSON.stringify( diagnosisName));
            if(component.get("v.ICDSearchParam") && diagnosisName==''){
                helper.searchWithICDFilter(component, event, helper, component.get("v.ICDSearchParam"),currentText);
            }
            else {  
                console.log('without icd filter');
                var action = component.get("c.searchProblemDiagnosis");
                action.setParams({
                    "searchKeyWord" : currentText,
                    "param" : component.get("v.ICDSearchParam")
                });
                action.setCallback(this, function(response){
                    var STATE = response.getState();
                    if(STATE === "SUCCESS") {
                        console.log('Calling searchField');
                        let allRecArr = [];
                        let junctionRec = response.getReturnValue().lstOfRecords;
                        let recTemplateProblem = response.getReturnValue().recTemplateProblem;
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
                                             //   'diagnosisCodeName' : '',
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
                                recTemplateProblem[rec].ElixirSuite__SNOMED_CT_Code__c = '';
                            }
                            allRecArr.push({'templateProbName' : recTemplateProblem[rec].Name,
                                            'snowmed' : recTemplateProblem[rec].ElixirSuite__SNOMED_CT_Code__c,
                                            'Id' : recTemplateProblem[rec].Id,
                                             'problemDescription': recTemplateProblem[rec].ElixirSuite__Description__c,
                                           // 'diagnosisCodeName' : '',
                                            //'icdVersion' :  '',
                                          //  'diagnosisType':'',
                                            'notes':  recTemplateProblem[rec].ElixirSuite__Note__c,
                                          // 'description' : ''
                                           });
                        }
                         console.log('allRecArr 2 '+JSON.stringify(allRecArr));
                        
                        let res  = allRecArr;
                        let mapOfIdAndSObj = {};
                        for(let sObj in res){
                            mapOfIdAndSObj[res[sObj].Id]  = res[sObj];
                        }
                         if(diagnosisName==''){
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
                        console.log('ret value '+JSON.stringify(allRecArr));
                         }else{
                helper.searchDiagnosisRelated(component, event, helper,diagnosisName);                      
                         }
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
               
        }
        catch(e){
            alert('error '+e);
        }
        
        
        
    },
    setSelectedRecord : function(component, event, helper) {
        try{
              var diagnosisName =  component.get("v.diagnosisName");
            console.log('diagnosisName set sele'+JSON.stringify( diagnosisName));
             var currentText = event.currentTarget.id;
            var selectedEventName = event.currentTarget.dataset.name;
            component.set('v.EmpList',false);
                 var action = component.get("c.countOfRecords");
                action.setParams({
                    "searchKeyWord" : event.currentTarget.dataset.name,
                    "param" : component.get("v.ICDSearchParam")
                });
                action.setCallback(this, function(response){
                    var STATE = response.getState();
                    if(STATE === "SUCCESS") {
                        console.log('Calling searchCountOfProblemRelated');
                        var countOfRecords = response.getReturnValue();
                        console.log('countOfRecords length ' + countOfRecords);
                        if(countOfRecords<=1){
                            component.set('v.DuplicateDiagnosisNames',true);
                             console.log('duplicateDiag without duplic '+component.get('v.DuplicateDiagnosisNames'));
                        }else{
                             component.set('v.DuplicateDiagnosisNames',false);
                             console.log('duplicateDiag with duplic '+component.get('v.DuplicateDiagnosisNames'));
                        }
            let mapOfIdAndsObj = component.get('v.MapOfIdAndSObj');
            let listOfRecords = component.get('v.DuplicateDiagnosisNames');
console.log('DuplicateDiagnosisNames '+listOfRecords);
            
             console.log('currentText 1 '+currentText);
            component.set("v.selectRecordName",selectedEventName);
            if(selectedEventName=='Other | N/A'){
                component.set("v.EmpOther",true);
            }else{ component.set("v.EmpOther",false);
                 }
            component.set("v.selectRecordId", currentText);
             console.log('currentText 2'+currentText);
             console.log('recordasobject'+JSON.stringify( mapOfIdAndsObj[currentText]));
            var cmpEvent = component.getEvent("FiringSelectedId");
            // Get the value from Component and set in Event
            cmpEvent.setParams( { "recordAsObject" :  mapOfIdAndsObj[currentText],
                                 "IsDuplicate" : listOfRecords
                                } );
            cmpEvent.fire();
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
            alert('error '+e);
        }
        
    },
    diagnosisComponent : function(component, event, helper) {
        try{
            let recsObj = JSON.parse(JSON.parse(JSON.stringify(event.getParam("recordAsObject"))));
            console.log('recsObj '+JSON.stringify(recsObj));
             component.set("v.searchRecords", recsObj);
      
        }
        catch(e){
            alert('error 22 '+e.stack);
        }
    },
    resetData : function(component, event, helper) {
        component.set("v.selectRecordName", "");
        component.set("v.selectRecordId", "");        
    }
})
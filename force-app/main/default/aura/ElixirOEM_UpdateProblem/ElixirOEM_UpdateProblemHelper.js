({
    setDefaultJSON : function(component, event, helper,icdVal) {
        let defaultJSON = 
            {'problemId' : '',
             'problemName' : '',
             'ICDCodeLabel' : '',
             'ICDVersion' : '',
             'SnomedCode' : '',
             'Status' : '',
             'ProblemType' : '',
             'DateDiagnised' : '',
             'DateOnset' : '',
             'notes':'',
             'diagnosisId' : '',
             'problemDescription':'',
             'diagnosisAttestationOn':'',
             'diagnoseValue' : ''
            };
        if(icdVal){
            defaultJSON.ICDVersion = icdVal;
        }else{
            defaultJSON.ICDVersion = 'ICD 10'; 
        }
        component.set("v.recordDetail",defaultJSON);
    },
    arrangeDate : function(component, event, helper) {
        let result = component.get("v.recordDetail");
        if(result.DateDiagnised){
            result.DateDiagnised = result.DateDiagnised+ ' 00:00:00';           
        }
        if(result.DateOnset){
            result.DateOnset = result.DateOnset+ ' 00:00:00';
        }
    },
    featchRecordInView :  function(component, event, helper) {
        try{
            helper.setDefaultJSON(component, event, helper,'');
            var action = component.get("c.fetchViewRecord");
            component.set("v.loaded",false);
            action.setParams({ recId : component.get("v.RowId") });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {  
                    component.set("v.loaded",true);
                    let parentResponse = response.getReturnValue();
                    let res = parentResponse.viewRecord;  
                    let conObj =  parentResponse.conIdName;
                    if(!$A.util.isUndefinedOrNull(conObj)){
                        console.log('conObj conObj '+conObj);
                        component.set("v.selectedRecord",conObj);
                    }
                    let recordDefault =  component.get("v.recordDetail");
                   if(!$A.util.isUndefinedOrNull(res.ElixirSuite__Problem__r)){
                    recordDefault.problemId = res.ElixirSuite__Problem__r.ElixirSuite__Template_Problem__c;
                     if((res.ElixirSuite__Problem__r.Id).includes((res.ElixirSuite__Problem__r.Name))){
                         recordDefault.problemName ='';
                     }else{
                    recordDefault.problemName = res.ElixirSuite__Problem__r.Name;
                     }
                    recordDefault.ICDCodeLabel = res.ElixirSuite__Diagnosis_Code__r.Name;
                    recordDefault.ICDVersion = res.ElixirSuite__Diagnosis_Code__r.ElixirSuite__Version__c;
                    recordDefault.SnomedCode = res.ElixirSuite__Problem__r.ElixirSuite__SNOMED_CT_Code__c;
                    recordDefault.diagnosisType = res.ElixirSuite__Diagnosis_Code__r.ElixirSuite__Diagnosis_Type__c;
                    recordDefault.description = res.ElixirSuite__Diagnosis_Code__r.ElixirSuite__Code_Description1__c;
                    recordDefault.Status = res.ElixirSuite__Problem__r.ElixirSuite__Status__c;
                    recordDefault.ProblemType = res. ElixirSuite__Problem__r.ElixirSuite__Problem_Type__c;
                    recordDefault.DateDiagnised = res.ElixirSuite__Problem__r.ElixirSuite__Date_Diagonised__c;
                    recordDefault.DateOnset = res.ElixirSuite__Problem__r.ElixirSuite__Date_Onset__c;
                    recordDefault.notes = res.ElixirSuite__Problem__r.ElixirSuite__Note__c;
                    recordDefault.diagnosisId = res.ElixirSuite__Diagnosis_Code__r.Id;
                        component.set("v.selectRecordName",res.ElixirSuite__Problem__r.Name);
                    component.set("v.selectRecordId",res.ElixirSuite__Problem__r.Id);
                   }else{
                      recordDefault.ICDCodeLabel = res.ElixirSuite__Diagnosis_Code__r.Name;
                    recordDefault.ICDVersion = res.ElixirSuite__Diagnosis_Code__r.ElixirSuite__Version__c;  
                        recordDefault.diagnosisId = res.ElixirSuite__Diagnosis_Code__r.Id;
                       recordDefault.diagnosisType = res.ElixirSuite__Diagnosis_Code__r.ElixirSuite__Diagnosis_Type__c;
                    recordDefault.description = res.ElixirSuite__Diagnosis_Code__r.ElixirSuite__Code_Description1__c;
                       
                   }
                    var diagAttestation = res.ElixirSuite__Diagnosis_Code__r.ElixirSuite__Diagnosis_Attestation_on__c;
                       var diagnosedBy = res.ElixirSuite__Diagnosis_Code__r.ElixirSuite__Diagnosed_By__c;
                       if(diagAttestation){
                           recordDefault.diagnosisAttestationOn = res.ElixirSuite__Diagnosis_Code__r.ElixirSuite__Diagnosis_Attestation_on__c;
                       }
                       if(diagnosedBy){
                           recordDefault.diagnoseValue = res.ElixirSuite__Diagnosis_Code__r.ElixirSuite__Diagnosed_By__c;
                       }
                    for(let rec in recordDefault){
                        if($A.util.isUndefinedOrNull(recordDefault[rec])){
                            recordDefault[rec] = '';
                        }
                    }
                    component.set("v.recordDetail",recordDefault);
                    JSON.stringify('complete'+ component.get("v.recordDetail")); 
                }
                else{
                    
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && online[0].message) {
                            console.log("Error message: " +
                                        errors[0].message);
                        }        }
                }
                
            });
            
            $A.enqueueAction(action); 
        }
        catch(e){
            alert('error '+e);
        }
    },
    getFieldSet : function(component, event, helper) {
        var action = component.get('c.getFieldSet');
        action.setParams({
            "ObjectName" : 'ElixirSuite__ICD_Codes__c',
            "fieldSetName" : 'ElixirSuite__Diagnose_Field_Set'
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log(state+' state');
            if(state === 'SUCCESS'){
                if(!$A.util.isUndefinedOrNull(response.getReturnValue())){
                console.log('field set wrapper '+JSON.stringify(response.getReturnValue()));
                component.set("v.fieldSetData",response.getReturnValue());
                }
            }
        });
        $A.enqueueAction(action);
    }
    
})
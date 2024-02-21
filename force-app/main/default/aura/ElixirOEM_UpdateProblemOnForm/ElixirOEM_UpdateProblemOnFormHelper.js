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
             'junctionId' : '',
             'problemDescription':''
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
                    console.log('parentResponse '+JSON.stringify(parentResponse));
                    let res = parentResponse.viewRecord;   
                    console.log('res '+JSON.stringify(res));
                    let recordDefault =  component.get("v.recordDetail");
                    recordDefault.junctionId = res.Id;
                        if(!$A.util.isUndefinedOrNull(res.ElixirSuite__Problem__r)){
                        recordDefault.problemId = res.ElixirSuite__Problem__r.Id;
                    recordDefault.problemName = res.ElixirSuite__Problem__r.Name;
                    recordDefault.ICDCodeLabel = res.ElixirSuite__Diagnosis_Code__r.Name;
                    recordDefault.ICDVersion = res.ElixirSuite__Diagnosis_Code__r.ElixirSuite__Version__c;
                    recordDefault.SnomedCode = res.ElixirSuite__Problem__r.ElixirSuite__SNOMED_CT_Code__c;
                    recordDefault.Status = res.ElixirSuite__Problem__r.ElixirSuite__Status__c;
                    recordDefault.ProblemType = res. ElixirSuite__Problem__r.ElixirSuite__Problem_Type__c;
                    recordDefault.diagnosisType = res.ElixirSuite__Diagnosis_Code__r.ElixirSuite__Diagnosis_Type__c;
                    recordDefault.description = res.ElixirSuite__Diagnosis_Code__r.ElixirSuite__Code_Description1__c;
                    recordDefault.DateDiagnised = res.ElixirSuite__Problem__r.ElixirSuite__Date_Diagonised__c;
                    recordDefault.DateOnset = res.ElixirSuite__Problem__r.ElixirSuite__Date_Onset__c;
                    recordDefault.notes = res.ElixirSuite__Problem__r.ElixirSuite__Note__c;
                    recordDefault.diagnosisId = res.ElixirSuite__Diagnosis_Code__r.Id;
                     component.set("v.selectRecordName",res.ElixirSuite__Problem__r.Name);
                    component.set("v.selectRecordId",res.ElixirSuite__Problem__r.Id);
                        }else{
                             recordDefault.ICDCodeLabel = res.ElixirSuite__Diagnosis_Code__r.Name;
                             recordDefault.diagnosisType = res.ElixirSuite__Diagnosis_Code__r.ElixirSuite__Diagnosis_Type__c;
                    recordDefault.description = res.ElixirSuite__Diagnosis_Code__r.ElixirSuite__Code_Description1__c;
                    recordDefault.ICDVersion = res.ElixirSuite__Diagnosis_Code__r.ElixirSuite__Version__c;  
                        recordDefault.diagnosisId = res.ElixirSuite__Diagnosis_Code__r.Id;
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
    updateOnListView: function(component, event, helper) {
        component.set("v.loaded",true);
        let dataOnView = component.get("v.listDetails");
        let problemArr = component.get("v.toUpdateProblem");
        console.log('record detail '+JSON.stringify(component.get("v.recordDetail")));
        console.log('row id  '+component.get("v.RowId"));        
        let delArr = component.get("v.toDelProblemFromUpdate");
        if(!delArr.includes(component.get("v.RowId"))){
            delArr.push(component.get("v.RowId")); 
        }        
        component.set("v.toDelProblemFromUpdate",delArr);        
        if(problemArr.some(problemArr => problemArr.junctionId === component.get("v.RowId"))){
            let arrIndex = problemArr.findIndex(obj => obj.junctionId == component.get("v.RowId"));
            problemArr[arrIndex] = component.get("v.recordDetail")

        } else{
            problemArr.push(component.get("v.recordDetail"));
        }            
        component.set("v.toUpdateProblem",problemArr);
        let lstViewArr = dataOnView.findIndex(obj => obj.Id == component.get("v.RowId"));
        dataOnView[lstViewArr].ProblemName = component.get("v.recordDetail").problemName;
        dataOnView[lstViewArr].ICD = component.get("v.recordDetail").ICDCodeLabel;
        dataOnView[lstViewArr].icdVersion = component.get("v.recordDetail").ICDVersion;
        dataOnView[lstViewArr].snowmedCtCode = component.get("v.recordDetail").SnomedCode;
        dataOnView[lstViewArr].status = component.get("v.recordDetail").Status;
        dataOnView[lstViewArr].problemType = component.get("v.recordDetail").ProblemType;
        dataOnView[lstViewArr].dateDiagonised = component.get("v.recordDetail").DateDiagnised;
        dataOnView[lstViewArr].dateOnset = component.get("v.recordDetail").DateOnset;
        dataOnView[lstViewArr].Notes = component.get("v.recordDetail").notes; 
        dataOnView[lstViewArr].description = component.get("v.recordDetail").description;
        dataOnView[lstViewArr].diagnosisType = component.get("v.recordDetail").diagnosisType;
        dataOnView[lstViewArr]['diagnosisId'] = component.get("v.recordDetail").diagnosisId; 
        dataOnView[lstViewArr]['problemId'] = component.get("v.recordDetail").problemId; 
        component.set("v.listDetails",dataOnView); 
        component.set("v.isView",false);
    },
    setDeafaultVlaues : function(component, event, helper) {
        try{
            let dataOnView = component.get("v.listDetails");
            let arrIndex = dataOnView.findIndex(obj => obj.Id == component.get("v.RowId"));            
            component.set("v.recordDetail.junctionId",dataOnView[arrIndex].Id);
            component.set("v.recordDetail.problemName",dataOnView[arrIndex].ProblemName);
            component.set("v.recordDetail.ICDCodeLabel", dataOnView[arrIndex].ICD);
            component.set("v.recordDetail.ICDVersion", dataOnView[arrIndex].icdVersion);
            component.set("v.recordDetail.SnomedCode", dataOnView[arrIndex].snowmedCtCode);
            component.set("v.recordDetail.Status",dataOnView[arrIndex].status);
            component.set("v.recordDetail.ProblemType",dataOnView[arrIndex].problemType);
            component.set("v.recordDetail.DateDiagnised",dataOnView[arrIndex].dateDiagonised);
            component.set("v.recordDetail.DateOnset",dataOnView[arrIndex].dateOnset);
            component.set("v.recordDetail.notes",dataOnView[arrIndex].Notes); 
            component.set("v.recordDetail.description",dataOnView[arrIndex].description);
            component.set("v.recordDetail.diagnosisType",dataOnView[arrIndex].diagnosisType); 
            component.set("v.recordDetail.problemId",dataOnView[arrIndex].problemId); 
            component.set("v.recordDetail.diagnosisId",dataOnView[arrIndex].diagnosisId);
        }
        catch(e){
            alert(e);
        }
        
    }
    
})
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
             'DateDiagnised' :  new Date(),
             'DateOnset' : '',
             'notes':'',
             'diagnosisId' : '',
             'description' : '',
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
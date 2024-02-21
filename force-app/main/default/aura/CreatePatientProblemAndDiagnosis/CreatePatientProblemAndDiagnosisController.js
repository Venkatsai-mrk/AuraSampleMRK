({
    doInit : function(component, event, helper) {
        //console.log('component.get("v.recordId")', component.get("v.recordId"));
        var pageRef = component.get("v.pageReference");
        console.log(JSON.stringify(pageRef));
        var state = pageRef.state; // state holds any query params
        console.log('state = '+JSON.stringify(state));
        var base64Context = state.inContextOfRef;
        console.log('base64Context = '+base64Context);
        if (base64Context.startsWith("1\.")) {
            base64Context = base64Context.substring(2);
            console.log('base64Context = '+base64Context);
        }
        var addressableContext = JSON.parse(window.atob(base64Context));
        console.log('addressableContext = '+JSON.stringify(addressableContext));
        component.set("v.recordId", addressableContext.attributes.recordId);
        
        var recordId = addressableContext.attributes.recordId;
        console.log('recordId = ', addressableContext.attributes.recordId);
        console.log('accoundId = ', addressableContext.state.ws);
        
        var urlString = addressableContext.state.ws;
        if(urlString != null){
                var urlArray = urlString.split('/');
                var accId = urlArray[4];
        }
        
        if(($A.util.isUndefinedOrNull(accId) || $A.util.isEmpty(accId))){
            var action = component.get('c.getAccountId');
        action.setParams({
            'recordId' : recordId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log('state',state);
            if(state === 'SUCCESS'){
                console.log('response.getReturnValue()',response.getReturnValue());
                accId = response.getReturnValue();
                              
            }
        });
        $A.enqueueAction(action);

        }
       
        
        console.log('Account Id: ' + accId);
        var diagnosisId = '';
        var problemId = '';
        var careEpisodeId='';
        var action = component.get('c.getCareEpisodeId');
        action.setParams({
            'recordId' : recordId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log('state',state);
            if(state === 'SUCCESS'){
                console.log('response.getReturnValue()',response.getReturnValue());
                 careEpisodeId = response.getReturnValue();
                              
            }
        });
        $A.enqueueAction(action);
        console.log('careEpisodeId'+careEpisodeId);
        var action = component.get('c.patientDiagnosisAndProblemType');
        action.setParams({
            'recordId' : recordId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log('state',state);
            if(state === 'SUCCESS'){
                console.log('response.getReturnValue()',response.getReturnValue());
                var objectType = response.getReturnValue();
                if(objectType == 'ElixirSuite__ICD_Codes__c'){
                    diagnosisId = recordId;
                }
                else if(objectType == 'ElixirSuite__Dataset1__c'){
                    problemId = recordId;
                }
                
                var createPatientProblemAndDiagnosisEvent = $A.get("e.force:createRecord");
                
                createPatientProblemAndDiagnosisEvent.setParams({
                    "entityApiName": "ElixirSuite__Diagnosis_Code__c",
                    "defaultFieldValues": {                
                        'ElixirSuite__Account_Id__c' : accId,
                        'ElixirSuite__Diagnosis_Code__c' : diagnosisId,
                        'ElixirSuite__Problem__c' : problemId,
                        'ElixirSuite__Care_Episode__c' : careEpisodeId
                    }
                });
                createPatientProblemAndDiagnosisEvent.fire();              
            }
        });
        $A.enqueueAction(action);
        
    }
})
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
    pushRecordAndIds : function(component, event, helper,resp) {
        let diagnosisIdLst =  component.get("v.accountRelatedDiagnosisDataId");
        diagnosisIdLst.push(resp);
        component.set("v.accountRelatedDiagnosisDataId",diagnosisIdLst);
        var action = component.get("c.fetchDiagnosisDetails");
        action.setParams({'lstRecordId' : resp
                         });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {                
                component.set("v.loaded",true);
                let serverResp = response.getReturnValue();
                let diagnosisRecordLst = component.get("v.accountRelatedDiagnosisData");
                diagnosisRecordLst.push({'disabled' : false,'ElixirSuite__Code_Description1__c' : serverResp[0].ElixirSuite__Code_Description1__c
                                         , 'Name' : serverResp[0].Name,'Id' : serverResp[0].Id});
                component.set("v.accountRelatedDiagnosisData",diagnosisRecordLst);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "PROBLEM SAVED!", 
                    "message": " ",
                    "type" : "success"
                });
                toastEvent.fire();               
                component.set("v.isView",false);
            }
            else{
                component.set("v.loaded",true); 
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
})
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
             'description' : '' ,
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
    updateOnListView: function(component, event, helper,insertedId,flag) {
        try{
            helper.fetchRecordDetails(component, event, helper,insertedId,flag);           
        }
        catch(e){
            alert(e);
        }       
    },
    fetchRecordDetails: function(component, event, helper,insertedId,flag) {
         component.set("v.loaded",false);
        var action = component.get("c.fetchEntityRecord");
        action.setParams({'junctionRecId' : insertedId
                         });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {   
                 component.set("v.loaded",true);
                component.set("v.loaded",true);
                let dataOnView = component.get("v.listDetails");
                console.log('record detail '+JSON.stringify(component.get("v.recordDetail")));
                console.log('row id  '+component.get("v.RowId"));
                let sObj = {};
                sObj['Id'] = insertedId;
                sObj['problemId'] = component.get("v.recordDetail").problemId; 
                sObj['ProblemName'] = component.get("v.recordDetail").problemName;
                sObj['ICD'] = component.get("v.recordDetail").ICDCodeLabel;
                sObj['icdVersion'] = component.get("v.recordDetail").ICDVersion;
                sObj['snowmedCtCode'] = component.get("v.recordDetail").SnomedCode;
                sObj['status'] = component.get("v.recordDetail").Status;
                sObj['problemType'] = component.get("v.recordDetail").ProblemType;
                sObj['description'] = component.get("v.recordDetail").description;
                sObj['diagnosisType'] = component.get("v.recordDetail").diagnosisType;
                sObj['dateDiagonised'] = component.get("v.recordDetail").DateDiagnised;
                sObj['dateOnset'] = component.get("v.recordDetail").DateOnset;
                sObj['Notes'] = component.get("v.recordDetail").notes;  
                sObj['diagnosisId'] = component.get("v.recordDetail").diagnosisId;  
                sObj['createdBy'] = response.getReturnValue().CreatedBy.Name;   
                sObj['CreatedDate'] = response.getReturnValue().CreatedDate;  
                sObj['LastModifiedDate'] = response.getReturnValue().LastModifiedDate; 
                dataOnView.push(sObj);                                
                component.set("v.listDetails",dataOnView); 
                 component.set("v.allSectionListView",false); 
                 component.set("v.allSectionListView",true); 
                component.set("v.isView",false); 
                if(flag){
                     component.set("v.isView",true); 
                }
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
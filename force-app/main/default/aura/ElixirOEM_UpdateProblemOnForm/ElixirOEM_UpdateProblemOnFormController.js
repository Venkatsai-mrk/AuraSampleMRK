({
    doInit : function(component, event, helper) {
        try{
            helper.setDefaultJSON(component, event, helper,'');
            var action = component.get("c.newScreenProblemDomain");
            component.set("v.loaded",false);
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {  
                    component.set("v.loaded",true);
                    let res = response.getReturnValue().mapPickListValues;  
                    let defaultValuePicklist = response.getReturnValue().defValue;   
                    let arr = [];
                    for(let obj in res){
                        let sObj = {'label' : obj, 'value' : res[obj]};
                        arr.push(sObj);
                    }
                    console.log('list val '+JSON.stringify(arr));
                    component.set("v.ICDPickList",arr);
                    if(!$A.util.isUndefinedOrNull(defaultValuePicklist)){
                        component.set("v.recordDetail.ICDVersion",defaultValuePicklist);
                    }
                    console.log('rec detail '+JSON.stringify(component.get("v.recordDetail")));                   
                      helper.featchRecordInView(component, event, helper);
                  //  helper.setDeafaultVlaues(component, event, helper);                     
                    component.set("v.runSetDefaultValue",true);
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
    closeModel : function(component, event, helper) {
        component.set("v.isView",false);
    },
    parentComponentEvent : function(component, event, helper) {
        try{
             var recsObj = JSON.parse(JSON.stringify(event.getParam("recordAsObject")));
             var listRecords = event.getParam("IsDuplicate");
            console.log('parentComponentEvent '+JSON.stringify(recsObj));
            console.log('listRecords :  '+JSON.stringify(listRecords));
            console.log('recsObj.length '+listRecords);
             if (!$A.util.isEmpty(recsObj) && listRecords){
            var recordProblem =  component.get("v.recordDetail");
            recordProblem.problemId = recsObj.Id;
            recordProblem.problemName = recsObj.templateProbName;
                  recordProblem.problemDescription = recsObj.problemDescription;
                   recordProblem.SnomedCode = recsObj.snowmed;
                 if(!$A.util.isUndefinedOrNull(recsObj.diagnosisCodeName)){
                     console.log('recsObj.diagnosisCodeName '+recsObj.diagnosisCodeName);
            recordProblem.ICDCodeLabel = recsObj.diagnosisCodeName;
            recordProblem.ICDVersion = recsObj.icdVersion;
                     //recordProblem.diagnosisType = recsObj.diagnosisType;
            recordProblem.description = recsObj.description;
            recordProblem.diagnosisId = recsObj.diagnosisId;
                 }
            component.set("v.recordDetail",recordProblem);
            component.set("v.ICDSearchParam",recsObj.icdVersion);
             }else{
              let recordProblem =  component.get("v.recordDetail");
            recordProblem.problemId = recsObj.Id;
            recordProblem.problemName = recsObj.templateProbName;
                  recordProblem.problemDescription = recsObj.problemDescription;
          //  recordProblem.ICDCodeLabel = '';
            recordProblem.ICDVersion = recsObj.icdVersion;
            recordProblem.SnomedCode = recsObj.snowmed;
            // recordProblem.diagnosisType = '';
           // recordProblem.description = '';
          //  recordProblem.diagnosisId = recsObj.diagnosisId;
            component.set("v.recordDetail",recordProblem);
            component.set("v.ICDSearchParam",recsObj.icdVersion); 
             }
        }
        catch(e){
            alert('error 2 '+e.stack);
        }
    },
     diagnosisComponentEvent : function(component, event, helper) {
        try{
            var recsObj = JSON.parse(JSON.parse(JSON.stringify(event.getParam("recordAsObject"))));
            var mapOfIdAndSObj = {};
             for(var sObj in recsObj){
                 mapOfIdAndSObj  = recsObj[sObj];
                }
            console.log('diagnosisComponentEvent '+JSON.stringify(recsObj));
            console.log('diagnosisPoppup '+JSON.stringify(mapOfIdAndSObj));
              console.log('mapOfIdAndSObj.length '+ recsObj.length);
            if (!$A.util.isEmpty(mapOfIdAndSObj) && recsObj.length==1){ 
              var recordProblem =  component.get("v.recordDetail");
            recordProblem.ICDCodeLabel = mapOfIdAndSObj.diagnosisCodeName;
            recordProblem.ICDVersion = mapOfIdAndSObj.icdVersion;
          //  recordProblem.diagnosisType = mapOfIdAndSObj.diagnosisType;
            recordProblem.description = mapOfIdAndSObj.description;
            recordProblem.diagnosisId = mapOfIdAndSObj.diagnosisId;
                if(!$A.util.isUndefinedOrNull(mapOfIdAndSObj.templateProbName)){
                  recordProblem.problemId = mapOfIdAndSObj.Id;
                     console.log('mapOfIdAndSObj.templateProbName '+mapOfIdAndSObj.templateProbName);
                      recordProblem.problemDescription = mapOfIdAndSObj.problemDescription;
            recordProblem.problemName = mapOfIdAndSObj.templateProbName;
                     recordProblem.SnomedCode = mapOfIdAndSObj.snowmed;
                    component.set("v.selectRecordName",mapOfIdAndSObj.templateProbName);
                }
            component.set("v.recordDetail",recordProblem);
            component.set("v.ICDSearchParam",mapOfIdAndSObj.icdVersion);
            }else{
                let recordProblem =  component.get("v.recordDetail");
             //   recordProblem.problemId = mapOfIdAndSObj.Id;
               //  recordProblem.problemName = ' ';
            recordProblem.ICDCodeLabel = mapOfIdAndSObj.diagnosisCodeName;
           // recordProblem.SnomedCode = mapOfIdAndSObj.snowmed;
           // recordProblem.diagnosisType = mapOfIdAndSObj.diagnosisType;
            recordProblem.description = mapOfIdAndSObj.description;
            component.set("v.recordDetail",recordProblem);
                component.set("v.ICDSearchParam",mapOfIdAndSObj.icdVersion);
            // component.set("v.selectRecordName",mapOfIdAndSObj.templateProbName);  
            }
        }
        catch(e){
            alert('error 22 '+e.stack);
        }
    },
    updateRecord : function(component, event, helper) {
        try{
            if(component.get("v.recordDetail").ICDCodeLabel){
                component.set("v.loaded",false);
                //  helper.arrangeDate(component, event, helper);
                let payloadToSave = {'keysToSave' : component.get("v.recordDetail")};      
                console.log('data to update '+JSON.stringify(payloadToSave));
                helper.updateOnListView(component, event, helper);
                
            }
            else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                   "title": "PLEASE SELECT ICD-CM Code",
                    "message": "Please search for ICD-CM Code!",
                    "type" : "error"
                });
                toastEvent.fire();   
            }
            
        }
        catch(e){
            alert('error '+e);
        }
    },
    updateAndNew :  function(component, event, helper) {
        try{
            if(component.get("v.recordDetail").ICDCodeLabe){
                component.set("v.loaded",false);
                component.set("v.runSetDefaultValue",false);
                helper.updateOnListView(component, event, helper);
                component.set("v.isView",false);
                component.set("v.isViewForNew",true);                
            }
            else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "PLEASE SELECT ICD-CM Code",
                    "message": "Please search for ICD-CM Code!",
                    "type" : "error"
                });
                toastEvent.fire();   
            }
            
        }
        catch(e){
            alert('error '+e);
        }
    },
    
    handleICDVersionChange:  function(component, event, helper) {
        let rec = component.get("v.recordDetail");      
        if(rec.problemName || rec.ICDCodeLabel){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "VALUES ARE RESET || ICD FILTER APPLIED || PLEASE SEARCH AGAIN",
                "message": "Please search for problems again!",
                "type" : "info"
            });
            toastEvent.fire();  
        }
        helper.setDefaultJSON(component, event, helper,event.getSource().get("v.value"));
        component.set("v.selectRecordName", "");
        component.set("v.selectRecordId", "");
         var appEvent = $A.get("e.c:diagnosisRemoveCmpEvent"); 
            appEvent.fire();
        
    }
})
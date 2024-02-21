({
    doInit : function(component, event, helper) {
        try{
            helper.setDefaultJSON(component, event, helper,'');
            helper.getFieldSet(component, event, helper);
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
        //component.set("v.isView",false);
        /************Nikhil**************/ 
        var workspaceAPI =component.find("workspace");
        if(component.get("v.backPage")){
          component.set("v.isView",false);
        }else{
            window.history.go(-2);
        }
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
        })
        .catch(function(error){
            console.log(error);
        });
		
    },
    parentComponentEvent : function(component, event, helper) {
        try{
            var recsObj = JSON.parse(JSON.stringify(event.getParam("recordAsObject")));
             var listRecords = event.getParam("IsDuplicate");
            console.log('parentComponentEvent '+JSON.stringify(recsObj));
            console.log('listRecords :  '+JSON.stringify(listRecords));
            console.log('recsObj.length '+listRecords);
             if (!$A.util.isEmpty(recsObj) && listRecords){
                  console.log('if ');
            var recordProblem =  component.get("v.recordDetail");
            recordProblem.problemId = recsObj.Id;
            recordProblem.problemName = recsObj.templateProbName;
             recordProblem.problemDescription = recsObj.problemDescription;
                   recordProblem.SnomedCode = recsObj.snowmed;
                 if(!$A.util.isUndefinedOrNull(recsObj.diagnosisCodeName)){
                     console.log('recsObj.diagnosisCodeName '+recsObj.diagnosisCodeName);
            recordProblem.ICDCodeLabel = recsObj.diagnosisCodeName;
            recordProblem.ICDVersion = recsObj.icdVersion;
                    // recordProblem.diagnosisType = recsObj.diagnosisType;
            recordProblem.description = recsObj.description;
            recordProblem.diagnosisId = recsObj.diagnosisId;
                 }
            component.set("v.recordDetail",recordProblem);
            component.set("v.ICDSearchParam",recsObj.icdVersion);
            var appEvent = $A.get("e.c:diagnosisLookupComponentEvent"); 
            appEvent.fire(); 
             }else{
                  console.log('else ');
              let recordProblem =  component.get("v.recordDetail");
            recordProblem.problemId = recsObj.Id;
            recordProblem.problemName = recsObj.templateProbName;
            recordProblem.problemDescription = recsObj.problemDescription;
           // recordProblem.ICDCodeLabel = '';
                 if(!$A.util.isUndefinedOrNull(recsObj.icdVersion)){
                     recordProblem.ICDVersion = recsObj.icdVersion;
                 }
                 else{
                     recordProblem.ICDVersion = component.get("v.recordDetail.ICDVersion");
                 }
            
            recordProblem.SnomedCode = recsObj.snowmed;
           // recordProblem.diagnosisType = '';
            //recordProblem.description = '';
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
             console.log('if ');
            var recordProblem =  component.get("v.recordDetail");
            recordProblem.ICDCodeLabel = mapOfIdAndSObj.diagnosisCodeName;
            recordProblem.ICDVersion = mapOfIdAndSObj.icdVersion;
           // recordProblem.diagnosisType = mapOfIdAndSObj.diagnosisType;
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
                console.log('else ');
                let recordProblem =  component.get("v.recordDetail");
               // recordProblem.problemId = mapOfIdAndSObj.Id;
               //  recordProblem.problemName = ' ';
            recordProblem.ICDCodeLabel = mapOfIdAndSObj.diagnosisCodeName;
           // recordProblem.SnomedCode = '';
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
    saveRecord : function(component, event, helper) {
        try{
            if(component.get("v.recordDetail").diagnosisId != ''){
                component.set("v.loaded",false);
                //  helper.arrangeDate(component, event, helper);
                let payloadToSave = {'keysToSave' : component.get("v.recordDetail")};      
                console.log('data to save '+JSON.stringify(payloadToSave));
                var action = component.get("c.saveProblemRec");
                action.setParams({'payload' : JSON.stringify(payloadToSave),
                                  'accountId' : component.get("v.recordVal")});
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {                
                        component.set("v.loaded",true);
                         let recIds = component.get("v.insertedProblem");
                        recIds.push(response.getReturnValue());
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "PROBLEM SAVED!",
                            "message": " ",
                            "type" : "success"
                        });
                        toastEvent.fire();
                        var cmpEvent = component.getEvent("ProblemRefreshEvt");
                        cmpEvent.fire();
                        
                        
                        var workspaceAPI =component.find("workspace");
                        if(component.get("v.backPage")){
                           component.set("v.isView",false);
                        }else{
                            window.history.go(-2);
                        }
                        workspaceAPI.getFocusedTabInfo().then(function(response) {
                            var focusedTabId = response.tabId;
                            workspaceAPI.closeTab({tabId: focusedTabId});
                        })
                        .catch(function(error){
                            console.log(error);
                        });
                        
                        
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
            else {
               
                if(component.get("v.recordDetail").diagnosisId == ''){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "PLEASE SELECT ICD-CM Code",
                    "message": "Please search for ICD-CM Code!",
                    "type" : "error"
                });
                toastEvent.fire();   
                }
            }
            
        }
        catch(e){
            alert('error '+e);
        }
    },
    saveAndNew:  function(component, event, helper) {
        try{
            if(component.get("v.recordDetail").diagnosisId != ''){
                component.set("v.loaded",false);
                let payloadToSave = {'keysToSave' : component.get("v.recordDetail")};      
                console.log('data to save '+JSON.stringify(payloadToSave));
                var action = component.get("c.saveProblemRec");
                action.setParams({'payload' : JSON.stringify(payloadToSave),
                                  'accountId' : component.get("v.recordVal")});
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {                
                        component.set("v.loaded",true);
                        let recIds = component.get("v.insertedProblem");
                        recIds.push(response.getReturnValue());
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "PROBLEM SAVED!",
                            "message": "  ",
                            "type" : "success"
                        });
                        toastEvent.fire();
                        var cmpEvent = component.getEvent("ProblemRefreshEvt");
                        cmpEvent.fire();
                        component.set("v.isView",false);
                        component.set("v.isView",true);
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
            else{
                 
                if(component.get("v.recordDetail").diagnosisId == ''){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "PLEASE SELECT ICD-CM Code",
                    "message": "Please search for ICD-CM Code!",
                    "type" : "error"
                });
                toastEvent.fire();   
                }
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
       // component.set("v.diagnosisVersionChange" , true);
        var appEvent = $A.get("e.c:diagnosisRemoveCmpEvent"); 
            appEvent.fire(); 
    }
})
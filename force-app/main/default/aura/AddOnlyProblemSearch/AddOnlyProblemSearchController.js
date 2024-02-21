({
    searchField : function(component, event, helper) {
        try{
            var currentText = event.getSource().get("v.value");   
            console.log('currentText '+currentText);
            component.set('v.EmpList',true);
            component.set("v.currentTextProblem", currentText);
            console.log('currentTextProblem '+component.get("v.currentTextProblem"));
            if(currentText.length >= 3) {
                component.set('v.EmpList',true);}
            else {
                component.set('v.EmpList',false);
            }
            if(currentText.length >= 3) {
                var action = component.get("c.searchOnlyProblem");
                action.setParams({
                    "searchKeyWord" : currentText 
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
                                            'notes':  recTemplateProblem[rec].ElixirSuite__Note__c,
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
                        console.log('ret value '+JSON.stringify(allRecArr));
                        
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
              
             var currentText = event.currentTarget.id;
            var selectedEventName = event.currentTarget.dataset.name;
            component.set('v.EmpList',false);
                 
            let mapOfIdAndsObj = component.get('v.MapOfIdAndSObj');
            component.set("v.selectRecordName",selectedEventName);
            component.set("v.selectRecordId", currentText);
             console.log('recordasobject'+JSON.stringify( mapOfIdAndsObj[currentText]));
            var cmpEvent = component.getEvent("FiringSelectedId");
            // Get the value from Component and set in Event
            cmpEvent.setParams( { "recordAsObject" :  mapOfIdAndsObj[currentText], 
                                 "SelectedId" : component.get("v.name") // this is index
                                } );
            cmpEvent.fire();
       
        }
        catch(e){
            alert('error '+e);
        }
        
    },
    resetData : function(component, event, helper) {
        component.set("v.selectRecordName", "");
        component.set("v.selectRecordId", "");        
    }
})
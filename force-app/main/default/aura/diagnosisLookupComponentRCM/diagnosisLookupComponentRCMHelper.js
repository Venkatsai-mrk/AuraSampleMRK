({
    searchRecordsHelper : function(component, event, helper, value) {
        $A.util.removeClass(component.find("Spinner"), "slds-hide");
        var searchString = component.get('v.searchString');
        component.set('v.message', '');
        component.set('v.recordsList', []); 
       
        // Calling Apex Method
        console.log('objectName '+ component.get('v.objectName'));
        console.log('filterField '+ component.get('v.fieldName'));
        console.log('filterClause '+ component.get('v.filterClause'));
        console.log('searchString '+ searchString);
        console.log('value '+ value);
        console.log('icdVersion'+ component.get('v.ICDSearchParam'));
        
        var action = component.get('c.fetchRecords');
        action.setParams({
            'objectName' : component.get('v.objectName'),
            'filterField' : component.get('v.fieldName'),
            'filterClause' : component.get('v.filterClause'),
            'searchString' : searchString,
            'value' : value,
            'icdVersion' : component.get('v.ICDSearchParam'),
            'accountId' : component.get('v.accountId'),
            'filterOnAccountId' : component.get('v.filterOnAccountId')
        });
        action.setCallback(this,function(response){
            var result = response.getReturnValue();
            if(response.getState() === 'SUCCESS') {
                if(result.length > 0) {
                    // To check if value attribute is prepopulated or not
                    if( $A.util.isEmpty(value) ) {
                         console.log('result '+ JSON.stringify(result));
                        component.set('v.recordsList',result);     
                        component.set('v.recordsListDuplicate',result);
                        console.log('list '+ JSON.stringify( component.get('v.recordsList')));
                    } else {
                         console.log('result 0  '+ JSON.stringify(result[0]));
                        //component.set('v.selectedRecord', result[0]);
                    }
                } else {
                    component.set('v.message', "No Records Found for '" + searchString + "'");
                }
            } else {
                // If server throws any error
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    component.set('v.message', errors[0].message);
                }
            }
            // To open the drop down list of records
            //if( $A.util.isEmpty(value) )
            //$A.util.addClass(component.find('resultsDiv'),'slds-is-open');
            $A.util.addClass(component.find("Spinner"), "slds-hide");
        });
        $A.enqueueAction(action);
    },
    
    searchRecordsHelperDup : function(component, event, helper, value) {
        $A.util.removeClass(component.find("Spinner"), "slds-hide");
        var searchString = component.get('v.searchString');
        component.set('v.message', '');
        component.set('v.recordsList', []);
         
        // Calling Apex Method
        console.log('objectName '+ component.get('v.objectName'));
        console.log('filterField '+ component.get('v.fieldName'));
        console.log('filterClause '+ component.get('v.filterClause'));
        console.log('searchString '+ searchString);
        console.log('value '+ value);
        console.log('icdVersion'+ component.get('v.ICDSearchParam'));
        var action = component.get('c.fetchRecords');
        action.setParams({
            'objectName' : component.get('v.objectName'),
            'filterField' : component.get('v.fieldName'),
            'filterClause' : component.get('v.filterClause'),
            'searchString' : searchString,
            'value' : value,
            'icdVersion' : component.get("v.ICDSearchParam"),
            'accountId' : component.get('v.accountId'),
            'filterOnAccountId' : component.get('v.filterOnAccountId')
        });
        action.setCallback(this,function(response){
            var result = response.getReturnValue();
            if(response.getState() === 'SUCCESS') {
                if(result.length > 0) {
                    // To check if value attribute is prepopulated or not
                    if( $A.util.isEmpty(value) ) {
                        component.set('v.recordsList',result);     
                        
                    } else {
                        component.set('v.selectedRecord', result[0]);
                    }
                } else {
                    component.set('v.message', "No Records Found for '" + searchString + "'");
                }
            } else {
                // If server throws any error
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    component.set('v.message', errors[0].message);
                }
            }
            // To open the drop down list of records
            //if( $A.util.isEmpty(value) )
            //$A.util.addClass(component.find('resultsDiv'),'slds-is-open');
            $A.util.addClass(component.find("Spinner"), "slds-hide");
        });
        $A.enqueueAction(action);
    },
    searchProblemRelatedDiagnosis : function(component, event, helper,problemName) {
        console.log('problem Name: '+problemName);
          $A.util.removeClass(component.find("Spinner"), "slds-hide");
        component.set('v.message', '');
        component.set('v.recordsList', []);
        console.log('icdVersion '+component.get('v.ICDSearchParam'));
        var action = component.get('c.searchProblemRelatedDiagnosis');
        action.setParams({
                    "searchKeyWord" : problemName,
            'icdVersion' : component.get('v.ICDSearchParam')
                });
        action.setCallback(this,function(response){
            var result = response.getReturnValue();
            console.log('result length '+result.length);
 console.log('result Problme diagn '+JSON.stringify(result));
            if(response.getState() === 'SUCCESS') {
                 console.log('result Problme diagn 1'+JSON.stringify(result));
                if(result.length >=1) {
                    // To check if value attribute is prepopulated or not
                   
                        component.set('v.recordsList',result);     
                        
                   
                       // component.set('v.selectedRecord', result[0]);
                    
                } else {
                    //component.set('v.message', "No Records Found for '" + searchString + "'");
                 helper.searchRecordsHelperDup( component, event, helper, '' );
                }
            } 
          
            $A.util.addClass(component.find("Spinner"), "slds-hide");
        });
        $A.enqueueAction(action);
    },
     searchField : function(component, event, helper, selectedLabel,selectedId) {
        try{
            var recordsListLabel = selectedLabel;
            var recordsListId=selectedId;
            // var searchString = component.get('v.searchString');
                var action = component.get("c.searchRelatedProblem");
                action.setParams({
                    "searchKeyWord" : recordsListLabel,
            'icdVersion' : component.get('v.ICDSearchParam'),
                    'recordids': recordsListId
                });
                action.setCallback(this, function(response){
                    var STATE = response.getState();
                    if(STATE === "SUCCESS") {
                        let allRecArr = [];
                        let junctionRec = response.getReturnValue().lstOfRecords;
                     let recTemplateProblem = response.getReturnValue().recTemplateProblem;
                         console.log('junctionRec '+JSON.stringify( junctionRec));
                      console.log('recTemplateProblem '+JSON.stringify( recTemplateProblem));
                        console.log('recTemplateProblem '+$A.util.isEmpty(recTemplateProblem));
                        if(!$A.util.isEmpty(junctionRec)){
                            console.log('inside juction');
                        for(let rec in junctionRec){
                            if(!$A.util.isUndefinedOrNull(junctionRec[rec].ElixirSuite__Template_Problem__r)){
                                  console.log('inside juction undefined');
                            allRecArr.push({ 'diagnosisCodeName' :  junctionRec[rec].ElixirSuite__Diagnosis_Code__r.Name,
                                            'diagnosisId' :  junctionRec[rec].ElixirSuite__Diagnosis_Code__r.Id,
                                          //  'diagnosisType':junctionRec[rec].ElixirSuite__Diagnosis_Code__r.ElixirSuite__Diagnosis_Type__c,
                                            'icdVersion' :  junctionRec[rec].ElixirSuite__Diagnosis_Code__r.ElixirSuite__Version__c,
                                            'description' :  junctionRec[rec].ElixirSuite__Diagnosis_Code__r.ElixirSuite__Code_Description1__c,
                                           'templateProbName' : junctionRec[rec].ElixirSuite__Template_Problem__r.Name,
                                            'snowmed' : junctionRec[rec].ElixirSuite__Template_Problem__r.ElixirSuite__SNOMED_CT_Code__c,
                                            'notes':  junctionRec[rec].ElixirSuite__Template_Problem__r.ElixirSuite__Note__c,
                                            'Id' : junctionRec[rec].ElixirSuite__Template_Problem__r.Id,
                                            'problemDescription': junctionRec[rec].ElixirSuite__Template_Problem__r.ElixirSuite__Description__c
                                           });
                            }else{
                              allRecArr.push({ 'diagnosisCodeName' :  junctionRec[rec].ElixirSuite__Diagnosis_Code__r.Name,
                                            'diagnosisId' :  junctionRec[rec].ElixirSuite__Diagnosis_Code__r.Id,
                                           // 'diagnosisType':junctionRec[rec].ElixirSuite__Diagnosis_Code__r.ElixirSuite__Diagnosis_Type__c,
                                            'icdVersion' :  junctionRec[rec].ElixirSuite__Diagnosis_Code__r.ElixirSuite__Version__c,
                                            'description' :  junctionRec[rec].ElixirSuite__Diagnosis_Code__r.ElixirSuite__Code_Description1__c,
                                           });
                        }
                        }
                        }
                        else if(recTemplateProblem != null){
                            console.log('inside recTemplateProblem'+recTemplateProblem[rec].Id);
                           for(let rec in recTemplateProblem){
                            allRecArr.push({
                                            'diagnosisCodeName' :  recTemplateProblem[rec].Name,
                                            'diagnosisId' :  recTemplateProblem[rec].Id,
                                            'icdVersion' :  recTemplateProblem[rec].ElixirSuite__Version__c,
                                            'description' :  recTemplateProblem[rec].ElixirSuite__Code_Description1__c
                                           });
                        }  
                        }
                        let res  = allRecArr;
                        console.log('res'+JSON.stringify( res));
                        let mapOfIdAndSObj = {};
                        for(let sObj in res){
                            mapOfIdAndSObj  = res[sObj];
                        }
                         console.log('1');
                        
                        component.set("v.MapOfIdAndSObj",res); 
                        console.log('map value '+JSON.stringify( mapOfIdAndSObj));
                        console.log('ret value '+JSON.stringify(allRecArr));
                        helper.setValue( component, event, helper,selectedId);
                    }
                    else if (state === "ERROR") {
                        var errors = response.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                
                            }
                        } else {  
                            
                        }
                    }
                    component.set("v.LoadingText", false);
                });
                $A.enqueueAction(action);
        }
         catch(e){
            alert('error 1'+e.stack);
         }
        },
    setValue : function(component, event, helper, selectedId) {
       try{
            component.set('v.EmpList',false);
            let mapOfIdAndsObj = JSON.stringify(component.get('v.MapOfIdAndSObj')); 
            if (!$A.util.isEmpty(mapOfIdAndsObj)){
            console.log('mapOfIdAndsObj'+mapOfIdAndsObj);
           var currentText = selectedId;
             console.log('currentText '+currentText);
             console.log('2');
             console.log('recordasobject '+JSON.stringify( mapOfIdAndsObj[currentText]));
           
            component.set("v.selectRecordId", currentText);
         // var cmpEvent = $A.get("e.c:diagnosisEvent");
            console.log('cmpEvent '+JSON.stringify(cmpEvent));
            var cmpEvent = component.getEvent("diagnosisEvent");
             cmpEvent.setParams( { "recordAsObject" :  mapOfIdAndsObj} );
            cmpEvent.fire();
        }
        }
        catch(e){
            alert('error 11'+e.stack);
        }  
    },
     insertDiagnosisCode : function(component, event, helper,selectedRecord) {
         console.log("Inside Dianosis"+ JSON.stringify(selectedRecord));
         console.log("Inside Dianosis123"+ JSON.stringify({'keysToSave' : selectedRecord}));
         console.log("Inside Dianosis"+ {'keysToSave' : JSON.stringify(selectedRecord)});
        var accountId = component.get("v.accountId");

        // Call the Apex controller method to insert the diagnosis code
        var action = component.get("c.insertDiagnosisCodesApex");
        action.setParams({
            "selectedRecords": JSON.stringify({'keysToSave' : selectedRecord}),
            "accountId": accountId
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // Handle success, if needed
                console.log("Diagnosis code inserted successfully");
                var insertedRecords = response.getReturnValue();
                console.log('insertedRecords '+insertedRecords)
                if (insertedRecords && insertedRecords.length > 0) {
                    console.log("Inserted Records:", JSON.stringify(insertedRecords));
                    component.set('v.selectedRecord', insertedRecords[0]);
                    component.set('v.value',insertedRecords[0].value);
                    component.set("v.modalVisibility", 'slds-hide');
           			component.set("v.showModal", false);
                    component.set("v.checkValue" , false);
                    //helper.searchField( component, event, helper,insertedRecords[0].Name,insertedRecords[0].Id);

                } else {
                    //helper.searchField( component, event, helper,selectedRecord[0].label,selectedRecord[0].value);
                    console.log("Inserted Records:", JSON.stringify(insertedRecords));
                    component.set('v.selectedRecord', selectedRecord[0]);
                    component.set('v.value',selectedRecord[0].value);
                    component.set("v.modalVisibility", 'slds-hide');
           			component.set("v.showModal", false);
                    component.set("v.checkValue" , false);

                    console.log("No records were inserted.");
                }
              } else if (state === "ERROR") {
                // Handle errors
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.error("Error message: " + errors[0].message);
                    }
                } else {
                    console.error("Unknown error");
                }
            }
        });

        $A.enqueueAction(action);
    },
  deleteDiagnosisCode: function(component, event, helper, deleteRecord) {
    console.log("deleteRecord Diagnosis: " + JSON.stringify(deleteRecord));
   

    var accountId = component.get("v.accountId");
    // Call the Apex controller method to delete the diagnosis code
    var action = component.get("c.deleteICDCode");
    action.setParams({
        "icdCodeId": deleteRecord, // Assuming deleteRecord is the Id of the record you want to delete
        "accountId": accountId
    });

    action.setCallback(this, function(response) {
        var state = response.getState();
        if (state === "SUCCESS") {
            // Handle success, if needed
            console.log("Diagnosis code deleted successfully");
        } else if (state === "ERROR") {
            // Handle errors
            var errors = response.getError();
            if (errors) {
                if (errors[0] && errors[0].message) {
                    console.error("Error message: " + errors[0].message);
                }
            } else {
                console.error("Unknown error");
            }
        }
    });

    $A.enqueueAction(action);
},

     
})
/*
Code by CafeForce
Website: http://www.cafeforce.com
DO NOT REMOVE THIS HEADER/FOOTER FOR FREE CODE USAGE
*/
({
    setDefaultJSON : function(component,icdVal) {
        let defaultJSON = 
            {'codeCategorySelected' : '',
             'procedureSelected' : '',
             'procedureDescription' : '',
             'procedureStart' : '',
             'procedureEnd' : '',
             'placeOfService' : '',
             'unitsDuration' : '',
             'diagnosisPointer' : '',
             'preAuthCode' : '',
             'claimType' : '',
             'isReadyForBilling' : false,
             'claimNumber' : '',
             'claimStatus' : '',
             'claimGenerated' : false,
             'patientProcedure' : false,
             'isBillable' : true,
             'Notes' : '',
             'isProcessed' : false,
             'typeOfPayment' : '',
             'Status' : '',
             'cancelationReason' : ''
            };
        component.set("v.recordDetail",defaultJSON);
        let sObj = {'modfier' : '',
                    'description' : '',
                    'notes' : ''};
        
        let arr = component.get("v.modifierData");
        arr.push(sObj);
        component.set("v.modifierData",arr);
    },

    setPlaceOfServiceAndCodeCategory : function(component,event,helper) {
        
        try{
            var action = component.get("c.getPlaceOfServiceAndCodeCategory");
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {  
                    var result = response.getReturnValue();
                    console.log('setPlaceOfService result***2',result);
                    component.set("v.defPlaceOfService",result.defPlaceOfServiceValue);
                    component.set("v.defCodeCategory",result.defCodeCategoryValue);
                }
                else{
                    
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0]) {
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
     addBlankRowInDiagnosisData: function(component) {
        // Initialize diagnosis data with empty values to get atleast one row by default
        let diagnosisData = component.get("v.diagnosisData");
        diagnosisData.push({
            "Id" : undefined,
            "diagnosis" : undefined,
            "description" : undefined,
            "diagnosisPointer" : undefined,
            "notes" : undefined
        });
        component.set("v.diagnosisData", diagnosisData);
    },
    removeThisRowFromDiagnosisData : function(component, event) {
        let diagnosisData = component.get("v.diagnosisData");

        if (diagnosisData && diagnosisData.length <= 1) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error",
                "message": "Can not delete last row",
                "type" : "error"
            });
            toastEvent.fire();
            return;
        }

        let elementIndexToRemove = event.currentTarget.dataset.value;
        diagnosisData.splice(elementIndexToRemove, 1);
        component.set("v.diagnosisData", diagnosisData);
    },
	setIsDiagnosisCodeAvailableForThisAccount : function(component) {
        try {
            let action = component.get("c.isDiagnosisCodeAvailableForThisAccount");
            console.log('in the helper ')
            action.setParams({"accountId": component.get("v.accountId")});
            action.setCallback(this, function(response) {
                if (response.getState() == "SUCCESS") {
                    console.log('in the helper getReturnValue'+response.getReturnValue())
                    component.set("v.isDiagnosisCodeAvailableForThisAccount", response.getReturnValue());
                }
                else {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error",
                        "message": "Failed to query diagnosis for patient",
                        "type" : "error"
                    });
                    toastEvent.fire(); 
                }
            });

            $A.enqueueAction(action);
            
        } catch (e) {
            alert('Error in actions: '+e)
        }

    },
    setTypeOfPayment : function(component,event,recId) {
        
        try{
            var action = component.get("c.getTypeOfPament");
            action.setParams({ recordId :  recId});
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {  
                    var result = response.getReturnValue();
                    component.set("v.recordDetail.typeOfPayment",result);
                }
                else{
                    
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0]) {
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
    
    arrangeDate : function(component) {
        let result = component.get("v.recordDetail");
        if(result.DateDiagnised){
            result.DateDiagnised = result.DateDiagnised+ ' 00:00:00';           
        }
        if(result.DateOnset){
            result.DateOnset = result.DateOnset+ ' 00:00:00';
        }
    },
    checkModifiers : function(component) {
        try{
            var action = component.get("c.checkForExistingModifiers");
          //  action.setParams({ procedureCode : component.get("v.recordDetail.codeCategorySelected") });
            component.set("v.loaded",false);
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {  
                    component.set("v.loaded",true);
                    if(response.getReturnValue()){
                        component.set("v.AllFlag_Modfiers",true);
                      //  helper.emptyModifierData(component, event, helper);
                    }
                    else{
                        component.set("v.AllFlag_Modfiers",false);
                    }
                    
                }
                else{
                    
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0]) {
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
    emptyModifierData : function(component) {
        
        component.set("v.modifierData",[{'modfier' : '',
                                         'description' : '',
                                         'notes' : ''}]);    
        
    },
    enableButton: function(component, event, helper,recordId) {
        let arr = component.get("v.accountRelatedDiagnosisData");
        let arrIndex = arr.findIndex(obj => obj.Id == recordId);
        arr[arrIndex].disabled=false;
        component.set("v.accountRelatedDiagnosisData",arr);
    },
    setPlaceOfServicePicklistVal:  function(component, event, helper,res) {
        let arr = [];
        let defvalue = component.get("v.defPlaceOfService");
        if(!$A.util.isEmpty(defvalue)){
        
            let sObj = {'label' : defvalue, 'value' : defvalue};
            arr.push(sObj);
        
        }else{
           var noneVal ={ 'value': "", 'label': "NONE" };
         arr.push(noneVal); 
        }
        
        for(let obj in res){
            if(defvalue!=obj){
            let sObj = {'label' : obj, 'value' : res[obj]};
            arr.push(sObj);
        }
        }
        console.log('list val 173 upd1'+JSON.stringify(arr));
        component.set("v.POSpicklist",arr); 
        console.log('defPlaceOfService**upd5**',component.get("v.defPlaceOfService"));
        component.set("v.recordDetail.placeOfService",component.get("v.defPlaceOfService")); 
    },
    setClaimTypePicklistVal:  function(component, event, helper,res, defvalue) {
        let arr = [];
        if(!$A.util.isEmpty(defvalue)){
        for(let obj in defvalue){
            let sObj = {'label' : obj, 'value' : defvalue[obj]};
            arr.push(sObj);
        }
        }else{
           var noneVal ={ 'value': "", 'label': "NONE" };
         arr.push(noneVal); 
        }
        for(let obj in res){
            let sObj = {'label' : obj, 'value' : res[obj]};
            arr.push(sObj);
        }
        
        console.log('list val '+JSON.stringify(arr));
        component.set("v.claimType",arr); 
    },
     setStatusPicklistVal:  function(component,res,resDefault) {
        let arr = [];
        let defVal;
       if(!$A.util.isEmpty(resDefault)){
      for(let obj in resDefault){
          defVal = obj;
          let sObj = {'value' : obj, 'label' : resDefault[obj]};
          arr.push(sObj);
      }
      }
      for(let obj in res){
          if(defVal!=obj){
          let sObj = {'value' : obj, 'label' : res[obj]};
          arr.push(sObj);
          }
      }
      console.log('list val '+JSON.stringify(arr));
      console.log('line274***upd1');
      component.set("v.statusLst",arr); 
    },
     setpaymentTypePicklistVal: function(component, event, helper,res) {
        let arr = [];
        for(let obj in res){
            let sObj = {'label' : obj, 'value' : res[obj]};
            arr.push(sObj);
        }
        component.set("v.paymentType",arr); 
    },
    
    setDiagnosisRecords : function(component, event, helper,res) {
        let arr = [];
        let diagnosisIds = [];
        res.forEach((element) => {  
            element['disabled'] = false;
            element['description'] = element.ElixirSuite__Code_Description1__c;
            arr.push(element);
            diagnosisIds.push(element.Id);
        });  
            component.set("v.accountRelatedDiagnosisData",arr); 
            component.set("v.accountRelatedDiagnosisDataId",diagnosisIds); 
            console.log('diagnosis id '+JSON.stringify(component.get("v.accountRelatedDiagnosisDataId")));
        },
            setIdInDomain : function(component, event, helper,res) {
                let domainWrapper  = component.get("v.procedureWrapper");
                domainWrapper.insertedProcedure.push(res[0].Id);
                component.set("v.procedureWrapper",domainWrapper);
            },
            updateOnListView : function(component, event, helper,res,diagnosisLst) {              
                let dataOnView = component.get("v.listDetails");
                console.log('record detail '+JSON.stringify(component.get("v.recordDetail")));
                console.log('row id  '+component.get("v.RowId"));
                let column = {};
                column['Id'] = res[0].Id; 
                column['procedureName'] = res[0].Name; //proc code/name 
  				column['procedureId'] =  res[0].Id; 
                column['Name'] =   res[0].Name;	
                column['procDesc'] = res[0].ElixirSuite__Code_Description__c;
                column['modifier1']= res[0].ElixirSuite__modifier_1__c;
                column['modifier2']= res[0].ElixirSuite__modifier_2__c;
                column['modifier3']= res[0].ElixirSuite__modifier_3__c;
                column['modifier4']= res[0].ElixirSuite__modifier_4__c;
                column['diagCode']= ' ';
                column['procStart']= res[0].ElixirSuite__From_Date_of_Service__c;
                column['procEnd']= res[0].ElixirSuite__To_Date_of_Service__c;
                column['duration']= res[0].ElixirSuite__Days_Units__c;
                column['placeOfService']= res[0].ElixirSuite__Place_Of_Service_Picklist__c;
                column['CreatedDate'] = res[0].CreatedDate;  
                column['LastModifiedDate'] = res[0].LastModifiedDate; 
                column['codeCategory'] =  res[0].ElixirSuite__Code_Category__c
                column['readyForBilling'] =  res[0].ElixirSuite__Ready_for_Billing__c;     
                column['claimGenerated']=  res[0].ElixirSuite__Claim_Generation__c;      
                column['isProcessed']=  res[0].ElixirSuite__Is_Processed__c;  
                column['preAuthCode'] = res[0].ElixirSuite__Pre_auth_Code__c;  
                column['isBillable'] = res[0].ElixirSuite__Is_Billable__c;
                column['claimType'] =   res[0].ElixirSuite__Claim_type__c;
                column['diagnosisData'] = helper.setDiagnosisData(component, event, helper,diagnosisLst);
                let modifierData = component.get("v.modifierData");
                for(let i=1;i<=modifierData.length;i++){
                    column['modifier'+i] = modifierData[i-1].modfier;
                    column['description'+i] = modifierData[i-1].description;
                    column['notes'+i] = modifierData[i-1].notes;
                }
                if(res.ElixirSuite__Claim__c !== undefined)
                    column['claimName']= res.ElixirSuite__Claim__r.Name;  
                var column2 = [];
                column2 = component.get("v.diagnosisData") ;
                if(!$A.util.isUndefinedOrNull(res[0])){
                    column2.forEach(function(col2){
                        if(column['diagCode'] === ' ')
                            column['diagCode']= col2.diagnosis;  
                        else{
                            column['diagCode']= column['diagCode'] + ', ' + col2.diagnosis; 
                        }
                    });
                }
                
                dataOnView.push(column);                                
                component.set("v.listDetails",dataOnView); 
            },
            setDiagnosisData :  function(component, event, helper,res) {
                if(!$A.util.isEmpty(res)){
                    let idArr = [];
                    res.forEach((element) => {  
                        idArr.push({'diagnosis'  : element.ElixirSuite__ICD_Codes__r.Name,
                        'description' : element.ElixirSuite__Description__c,
                        'notes' : element.ElixirSuite__Notes__c,'Id' :  element.ElixirSuite__ICD_Codes__c}); 
                });
                return idArr;
            }
            else {
            return [];
        }
                    }, 
                    saveRecordHelper : function(component,event,helper){
            			component.set("v.loaded",false);
                        let payloadToSave = {'keysToSave' : component.get("v.recordDetail")};      
                        console.log('data to save '+JSON.stringify(payloadToSave));
                        console.log('diagnosisData '+JSON.stringify(component.get("v.diagnosisData")));
                        console.log('modifierData '+JSON.stringify(component.get("v.modifierData")));
                        var action = component.get("c.saveProcedure");
                        action.setParams({'payload' : JSON.stringify(payloadToSave),
                                          'accountId' : component.get("v.accountId"),
                                          'diagnosisData' : JSON.stringify(component.get("v.diagnosisData")),
                                          'modifierData' : JSON.stringify(component.get("v.modifierData"))});
                        action.setCallback(this, function(response) { 
                            var state = response.getState();
                            if (state === "SUCCESS") {                
                                component.set("v.loaded",true);
                                var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    "title": "PROCEDURE SAVED!",
                                    "message": " ",
                                    "type" : "success"
                                });
                                toastEvent.fire();
                                helper.setIdInDomain(component, event, helper,response.getReturnValue().procRecord);
                                helper.updateOnListView(component, event, helper,response.getReturnValue().procRecord,response.getReturnValue().diagnosisLst);    
                                component.set("v.isView",false);                        
                            }
                            else{
                                component.set("v.loaded",true); 
                                var errors = response.getError();
                                if (errors) {
                                    if (errors[0]) {
                                        console.log("Error message: " +
                                                    errors[0].message);
                                    }        }
                            }
                            
                        });
                        
                        $A.enqueueAction(action);
        },
            
        saveAndNewRecordHelper : function(component,event,helper){
            component.set("v.loaded",false);
            let payloadToSave = {'keysToSave' : component.get("v.recordDetail")};      
            console.log('data to save '+JSON.stringify(payloadToSave));
            var action = component.get("c.saveProcedure");
            action.setParams({'payload' : JSON.stringify(payloadToSave),
                              'accountId' : component.get("v.accountId"), 
                              'diagnosisData' : JSON.stringify(component.get("v.diagnosisData")),
                              'modifierData' : JSON.stringify(component.get("v.modifierData"))});
            action.setCallback(this, function(response) { 
                var state = response.getState();
                if (state === "SUCCESS") {                
                    component.set("v.loaded",true);
                    helper.setIdInDomain(component, event, helper,response.getReturnValue().procRecord);
                    helper.updateOnListView(component, event, helper,response.getReturnValue().procRecord);    
                    component.set("v.isView",false);   
                    component.set("v.isView",true);     
                }
                else{
                    component.set("v.loaded",true); 
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0]) {
                            console.log("Error message: " +
                                        errors[0].message);
                        }        }
                }
                
            });
            
            $A.enqueueAction(action); 
        }
        
        
        
                    })
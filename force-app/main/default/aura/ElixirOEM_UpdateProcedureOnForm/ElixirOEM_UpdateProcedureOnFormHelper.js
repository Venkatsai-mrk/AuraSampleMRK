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
             'Notes' : '',
             'diagnosisPointer' : '',
             'preAuthCode' : '',
             'claimType' : '',
             'isReadyForBilling' : '',
             'claimNumber' : '',
             'claimStatus' : '',
             'claimGenerated' : false,
             'patientProcedure' : false,
             'isBillable' : false,
             'isProcessed' : false,
             'Id' : '',
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
    setIsDiagnosisCodeAvailableForThisAccount : function(component) {
                            try {
                                let action = component.get("c.isDiagnosisCodeAvailableForThisAccount");
                                
                                action.setParams({"accountId": component.get("v.accountId")});
                                action.setCallback(this, function(response) {
                                    if (response.getState() == "SUCCESS") {
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
                                
                            } catch (error) {
                                console.log("error in update diagnosis: ", error.message);
                            }
                        },
     setDiagnosisData :  function(component, event, helper,res) {
        if(!$A.util.isEmpty(res)){
            let idArr = [];
            let diagnosisData =  component.get("v.diagnosisData");
            res.forEach((element) => {  
                diagnosisData.push({'diagnosis'  : element.ElixirSuite__ICD_Codes__r.Name,
                'description' : element.ElixirSuite__Description__c,
                'notes' : element.ElixirSuite__Notes__c,'Id' :  element.ElixirSuite__ICD_Codes__c}); 
            idArr.push(element.ElixirSuite__ICD_Codes__c);
        });
        component.set("v.diagnosisData",diagnosisData);
        component.set("v.procedureRelatedDiagnosisDataId",idArr);
    }
    else {
    helper.addBlankRowInDiagnosisData(component, event, helper);
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
    
    updateOnListView : function(component) {
        /****SET RECORD FOR UPDATE IN DOMAIN**********/ 
        let payloadToSave = {'keysToSave' : component.get("v.recordDetail")};       
        console.log('data to save '+JSON.stringify(payloadToSave));
        let sObj = {'payload' : JSON.stringify(payloadToSave),
                    'accountId' : component.get("v.accountId"),
                    'diagnosisData' : JSON.stringify(component.get("v.diagnosisData")),
                    'modifierData' : JSON.stringify(component.get("v.modifierData")),
                    'procedureId' : component.get("v.RowId"),
                    'deletediagnosisData' : JSON.stringify(component.get("v.deleteDiagnosisData"))};
        let domainWrapper  = component.get("v.procedureWrapper");
        let procedureArr = domainWrapper.updatedProcedure;
        if(procedureArr.some(procedureArr => procedureArr.procedureId === component.get("v.RowId"))){
            let arrIndex = procedureArr.findIndex(obj => obj.procedureId == component.get("v.RowId"));
            procedureArr[arrIndex] = sObj;
            
        } else{
            procedureArr.push(sObj);
        }  
        component.set("v.procedureWrapper",domainWrapper);
        console.log('procedureWrapper'+JSON.stringify(component.get("v.procedureWrapper")));
        /****UPDATE LIST VIEW**********/ 
        let dataOnView = component.get("v.listDetails");  
        let lstViewArr = dataOnView.findIndex(obj => obj.Id == component.get("v.RowId"));
        console.log('record detail '+JSON.stringify(component.get("v.recordDetail")));
        console.log('row id  '+component.get("v.RowId"));
        let column = {};   
        let res =  component.get("v.recordDetail");
        dataOnView[lstViewArr]['procedureName'] = res.procedureSelected; //proc code/name 
        dataOnView[lstViewArr]['procDesc'] = res.procedureDescription;
        dataOnView[lstViewArr]['diagCode']= ' ';
        dataOnView[lstViewArr]['procStart']= res.procedureStart;
        dataOnView[lstViewArr]['procEnd']= res.procedureEnd;
        dataOnView[lstViewArr]['duration']= res.unitsDuration;
        dataOnView[lstViewArr]['placeOfService']= res.placeOfService;
        dataOnView[lstViewArr]['CreatedDate'] = new Date();  
        dataOnView[lstViewArr]['LastModifiedDate'] = new Date();       
        dataOnView[lstViewArr]['codeCategory'] =  res.codeCategory
        dataOnView[lstViewArr]['placeOfService']=  res.placeOfService;
        dataOnView[lstViewArr]['readyForBilling'] =  res.isReadyForBilling;     
        dataOnView[lstViewArr]['claimGenerated']=  res.claimGenerated;      
        dataOnView[lstViewArr]['isProcessed']=  res.isProcessed;  
        dataOnView[lstViewArr]['preAuthCode'] = res.preAuthCode;  
        dataOnView[lstViewArr]['isBillable'] = res.isBillable;
        dataOnView[lstViewArr]['claimType'] =   res.claimType;
        dataOnView[lstViewArr]['diagnosisData'] =  component.get("v.diagnosisData");
        
        let modifierData = component.get("v.modifierData");
        for(let i=1;i<=modifierData.length;i++){
            dataOnView[lstViewArr]['modifier'+i] = modifierData[i-1].modfier;
            dataOnView[lstViewArr]['description'+i] = modifierData[i-1].description;
            dataOnView[lstViewArr]['notes'+i] = modifierData[i-1].notes;
        }
        if(res.ElixirSuite__Claim__c !== undefined)
            column['claimName']= res.ElixirSuite__Claim__r.Name;  
        var column2 = [];
        column2 = component.get("v.diagnosisData") ;
        if(!$A.util.isUndefinedOrNull(res)){
            column2.forEach(function(col2){
                if(dataOnView[lstViewArr]['diagCode'] === ' ')
                    dataOnView[lstViewArr]['diagCode']= col2.diagnosis;  
                else{
                    dataOnView[lstViewArr]['diagCode']= dataOnView[lstViewArr]['diagCode'] + ', ' + col2.diagnosis; 
                }
            });
        }
        
        component.set("v.listDetails",dataOnView); 
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
    checkModifiers : function(component, event, helper) {
        try{
            var action = component.get("c.checkForExistingModifiers");
            action.setParams({ procedureCode : component.get("v.recordDetail.codeCategorySelected") });
            component.set("v.loaded",false);
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {  
                    component.set("v.loaded",true);
                    if(response.getReturnValue()){
                        component.set("v.AllFlag_Modfiers",true);
                        helper.emptyModifierData(component, event, helper);
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
    setStatusPicklistVal:  function(component,res,resDefault) {
        let arr = [];
        /* if(!$A.util.isEmpty(resDefault)){
        for(let obj in resDefault){
            let sObj = {'label' : obj, 'value' : resDefault[obj]};
            arr.push(sObj);
        }
        }*/
        for(let obj in res){
            let sObj = {'value' : obj, 'label' : res[obj]};
            arr.push(sObj);
        }
        console.log('list val '+JSON.stringify(arr));
        component.set("v.statusLst",arr); 
    },
    setPlaceOfServicePicklistVal:  function(component, event, helper,res) {
        let arr = [];
        for(let obj in res){
            let sObj = {'label' : obj, 'value' : res[obj]};
            arr.push(sObj);
        }
        console.log('list val '+JSON.stringify(arr));
        component.set("v.POSpicklist",arr); 
    },
    setProcedureData :  function(component, event, helper,res) {
        if(!$A.util.isEmpty(res)){
            let data = res[0];
            component.set("v.procedureName",data.Name); 
            component.set("v.recordDetail.codeCategorySelected",data.ElixirSuite__Code_Category__c); 
            component.set("v.recordDetail.procedureSelected",data.Name); 
            component.set("v.recordDetail.procedureDescription",data.ElixirSuite__Code_Description__c); 
            component.set("v.recordDetail.procedureStart",data.ElixirSuite__From_Date_of_Service__c); 
            component.set("v.recordDetail.procedureEnd",data.ElixirSuite__To_Date_of_Service__c); 
            component.set("v.recordDetail.unitsDuration",data.ElixirSuite__Days_Units__c); 
            component.set("v.recordDetail.placeOfService",data.ElixirSuite__Place_Of_Service_Picklist__c); 
            component.set("v.recordDetail.preAuthCode",data.ElixirSuite__Pre_auth_Code__c); 
            component.set("v.recordDetail.isReadyForBilling",data.ElixirSuite__Ready_for_Billing__c); 
            component.set("v.recordDetail.isReadyForBilling",data.ElixirSuite__Ready_for_Billing__c); 
            component.set("v.recordDetail.isBillable",data.ElixirSuite__Is_Billable__c); 
            component.set("v.recordDetail.codeCategory",data.ElixirSuite__Code_Category__c); 
            component.set("v.recordDetail.claimType",data.ElixirSuite__Claim_type__c);  
            component.set("v.recordDetail.Id",data.Id);   
            component.set("v.recordDetail.typeOfPayment",data.ElixirSuite__Type_of_Procedure__c); 
            component.set("v.recordDetail.Status",data.ElixirSuite__Status__c);
            component.set("v.recordDetail.cancelationReason",data.ElixirSuite__Cancelation_Reason__c);
        }
        helper.setModfierData(component, event, helper,res[0]);
    },
    setDeafaultVlaues : function(component, event, helper) {
        try{
            let dataOnView = component.get("v.listDetails");
            let arrIndex = dataOnView.findIndex(obj => obj.Id == component.get("v.RowId")); 
            helper.setProcedureRelatedDiagnosisDataId(component, event, helper,dataOnView[arrIndex].diagnosisData);
            //component.set("v.diagnosisData",dataOnView[arrIndex].diagnosisData);
            component.set("v.procedureName",dataOnView[arrIndex].Name); 
            component.set("v.recordDetail.codeCategorySelected",dataOnView[arrIndex].ElixirSuite__Code_Category__c);  
            component.set("v.recordDetail.procedureSelected",dataOnView[arrIndex].procedureName); 
            component.set("v.recordDetail.procedureDescription",dataOnView[arrIndex].procDesc); 
            component.set("v.recordDetail.procedureStart",dataOnView[arrIndex].procStart); 
            component.set("v.recordDetail.procedureEnd",dataOnView[arrIndex].procEnd); 
            component.set("v.recordDetail.unitsDuration",dataOnView[arrIndex].duration); 
            component.set("v.recordDetail.placeOfService",dataOnView[arrIndex].placeOfService); 
            component.set("v.recordDetail.preAuthCode",dataOnView[arrIndex].preAuthCode); 
            component.set("v.recordDetail.isReadyForBilling",dataOnView[arrIndex].readyForBilling);  
            component.set("v.recordDetail.isBillable",dataOnView[arrIndex].isBillable); 
            component.set("v.recordDetail.codeCategorySelected",dataOnView[arrIndex].codeCategory); 
            component.set("v.recordDetail.claimType",dataOnView[arrIndex].claimType);  
            component.set("v.recordDetail.Id",dataOnView[arrIndex].Id);   
            component.set("v.recordDetail.codeCategory",dataOnView[arrIndex].codeCategory); 
            component.set("v.recordDetail.claimType",dataOnView[arrIndex].claimType);   
            let arr = component.get("v.modifierData");  
            arr = [];
            for(let i=1;i<=4;i++){
                if(!$A.util.isUndefinedOrNull(dataOnView[arrIndex]['modifier'+i])){
                    arr.push({'modfier' : dataOnView[arrIndex]['modifier'+i],
                              'description' : dataOnView[arrIndex]['description'+i],
                              'notes' : dataOnView[arrIndex]['notes'+i]});
                }
                
            } 
            if($A.util.isEmpty(arr)){        
                arr.push({'modfier' : '',
                          'description' : '',
                          'notes' : ''});                
            }
            component.set("v.modifierData",arr);
            
        }
        catch(e){
            alert(e);
        }
        
    },
    setProcedureRelatedDiagnosisDataId :  function(component, event, helper,res) {
        if(!$A.util.isEmpty(res)){
            let idArr = [];
            res.forEach((element) => {  
                idArr.push(element.Id);
            });
                component.set("v.procedureRelatedDiagnosisDataId",idArr);
            }
            },
                setModfierData :  function(component, event, helper,data) {
                    //  debugger;
                    let totalModfiers = data.ElixirSuite__Count_of_total_modifiers_used__c;
                    let modData = component.get("v.modifierData");
                    if(totalModfiers!=0){
                        modData = [];
                        for(let i = 1 ; i<= totalModfiers ; i++ ){
                            modData.push({'modfier' : data['ElixirSuite__modifier_'+i+'__c'],
                                          'description' :   data['ElixirSuite__Description_'+i+'__c'],
                                          'notes' : data['ElixirSuite__Notes_'+i+'__c']});
                        }
                        component.set("v.modifierData",modData)
                    }
                },
              /*  setDiagnosisData :  function(component, event, helper,res) {
                    if(!$A.util.isEmpty(res)){
                        let idArr = [];
                        let diagnosisData =  component.get("v.diagnosisData");
                        res.forEach((element) => {  
                            diagnosisData.push({'diagnosis'  : element.ElixirSuite__ICD_Codes__r.Name,
                            'description' : element.ElixirSuite__Description__c,
                            'notes' : element.ElixirSuite__Notes__c,'Id' :  element.ElixirSuite__ICD_Codes__c}); 
                        idArr.push(element.ElixirSuite__ICD_Codes__c);
                    });
                    //   component.set("v.diagnosisData",diagnosisData);
                    component.set("v.procedureRelatedDiagnosisDataId",idArr);
                }
            },*/
                        setIsProcessed : function(component, event, helper,res) {
                if(res){
                    component.set("v.recordDetail.isProcessed",true); 
                }
            },
                setClaimData : function(component, event, helper,res) {
                    if(!$A.util.isUndefinedOrNull(res)){
                        component.set("v.claimData",res); 
                        component.set("v.AllFlag",true);  
                        component.set("v.AllFlag_Modfiers",true);  
                        component.set("v.recordDetail.claimGenerated",true);
                        helper.disableAccountRelatedDiagnosisData(component, event, helper);
                    }
                    else{
                        let sObj = {'Name': 'Claim not yet generated',
                                    'ElixirSuite__Claim_Status__c' : 'Claim not yet generated'};
                        component.set("v.claimData",sObj); 
                    }
                }, 
                    disableAccountRelatedDiagnosisData : function(component) {
                        let res = component.get("v.accountRelatedDiagnosisData");
                        res.forEach((element) => {            
                            element['disabled'] = true;
                        });  
                            component.set("v.accountRelatedDiagnosisData",res); 
                            
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
                            
                            setpaymentTypePicklistVal: function(component, event, helper,res) {
                                let arr = [];
                                for(let obj in res){
                                    let sObj = {'label' : obj, 'value' : res[obj]};
                                    arr.push(sObj);
                                }
                                component.set("v.paymentType",arr); 
                            },
                            
                            setDiagnosisRecords : function(component, event, helper,res) {
                                let idAr = component.get("v.procedureRelatedDiagnosisDataId");
                                let arr = [];
                                let diagnosisIds = [];
                                res.forEach((element) => { 
                                    if(idAr.includes(element.Id)){
                                    element['disabled'] = true;
                                }
                                            else{ 
                                            element['disabled'] = false;
                                            }                
                                            element['description'] = element.ElixirSuite__Code_Description1__c;
                                            arr.push(element);
                                diagnosisIds.push(element.Id);
                            });  
                            component.set("v.accountRelatedDiagnosisData",arr); 
                            component.set("v.accountRelatedDiagnosisDataId",diagnosisIds); 
                            console.log('diagnosis id '+JSON.stringify(component.get("v.accountRelatedDiagnosisDataId")));
                        }
                                    })
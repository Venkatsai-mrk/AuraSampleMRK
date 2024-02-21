({
    
    getprocedureRecord : function(component, helper, fromDate, toDate) {
        var action = component.get("c.getDataForRangeApex");
        action.setParams({
            "fromDate" : fromDate,
            "toDate" : toDate,
            "recordVal" : component.get("v.patId"),
            "transId" : component.get("v.transactionalDataId")
        });
        action.setCallback(this,function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var allData = response.getReturnValue();
                console.log('Aggregate Data:', allData);
                console.log('bwd' , component.get("v.transactionaljsonList"));
                var procedureData = allData.procedure ; 
                var payerData = allData.payer ; 
                var providerData = allData.provider ; 
                var mapOfCodeAndPriceList = allData.codeandPricelist ;  // based on contracted price
                var mapOfCodeAndPricelistForProvider = allData.codeandPricelistForProvider ;  // based on actual/List price
                var procedureLength = allData.procedure.length;
                var transactionaljsonList = [];
                var insideJson = {};
                var completeJson = [];
                console.log('procedures' , procedureData);
                
                console.log('map ' , mapOfCodeAndPriceList);
                if($A.util.isEmpty(allData.procedure) || $A.util.isUndefinedOrNull(allData.procedure)){     
                    console.log('******j') ;
                    component.set("v.messege" , true);
                    
                }
                /*else{
                component.set("v.messege" , false);
                }*/
                var totalAmount = 0;
                var keysRec=Object.keys(mapOfCodeAndPriceList);
                console.log('******keysRec '+keysRec) ;
                console.log('### SOnal procedureLength : ' + procedureLength);
                for (var m = 0; m < procedureLength ; m++) {
                    var procPrice = ' ';
                    if(keysRec.includes(allData.procedure[m].ElixirSuite__CPT_HCPCS_Code__c)){
                        console.log('in if');
                        procPrice = mapOfCodeAndPricelistForProvider[allData.procedure[m].ElixirSuite__CPT_HCPCS_Code__c].ElixirSuite__List_Price__c ;
                        console.log('### SOnal procPrice : ' + procPrice);
                        console.log('meghna next ',  mapOfCodeAndPriceList[allData.procedure[m].ElixirSuite__CPT_HCPCS_Code__c].ElixirSuite__Contracted_Amount__c );
                        
                    }
                    else{
                        console.log('in else');
                        procPrice = mapOfCodeAndPriceList[allData.procedure[m].ElixirSuite__CPT_HCPCS_Code__c].ElixirSuite__Contracted_Amount__c ;
                        // procPrice = mapOfCodeAndPricelistForProvider[allData.procedure[m].CPT_HCPCS_Code__c].List_Price__c ;
                    }
                    console.log('dnwb' , allData.procedure[m].ElixirSuite__Days_Units__c);
                    if ($A.util.isUndefinedOrNull(allData.procedure[m].ElixirSuite__Days_Units__c) || $A.util.isEmpty(allData.procedure[m].ElixirSuite__Days_Units__c)){
                        allData.procedure[m].ElixirSuite__Days_Units__c = 1;
                    }
                    var units = allData.procedure[m].ElixirSuite__Days_Units__c ;
                    var totalAmount = totalAmount + (units * procPrice );
                    insideJson = {"Id" : allData.procedure[m].Id ,
                                  "fromDate" : allData.procedure[m].ElixirSuite__From_Date__c,
                                  "toDate" : allData.procedure[m].ElixirSuite__To_Date__c ,
                                  "CPTcode" : allData.procedure[m].ElixirSuite__CPT_HCPCS_Code__c , 
                                  "procedureName" : allData.procedure[m].Name ,
                                  "daysUnits" : allData.procedure[m].ElixirSuite__Days_Units__c ,
                                  "payerName" : allData.payer[0].Name , 
                                  "providerName" : allData.provider[0].Name,
                                  "Charges" : procPrice
                                  
                                 }
                    console.log('dwb' , insideJson);
                    completeJson.push(insideJson);
                }
                var rec ={};
                rec = {
                    
                    "Record" : JSON.parse(JSON.stringify(completeJson))
                };
                transactionaljsonList.push(rec);
                component.set("v.transactionaljsonList",JSON.parse(JSON.stringify(transactionaljsonList)));
                component.set("v.noData" , false);
                // component.set("v.transactionalDataId" ,res.tcData[0].Id );
                console.log('check this list' , component.get("v.transactionaljsonList"));
                console.log('check this list also' ,JSON.parse(JSON.stringify(transactionaljsonList)));
                component.set("v.totalAmount" , totalAmount);
                console.log('fnj' , component.get("v.totalAmount"));
                
            }
        });
        $A.enqueueAction(action);
    },
    buildPicklistWrapperForClaimFields : function(component, event,helper) {
        let arrQual = [{'label' : '431 Onset of Current Symptoms or Illness', 'value' : '431'},
                       {'label' : '484 Last Menstrual Period', 'value' : '484'}];
        let qual_OtherDatesArr =  [{'label' : '454 Initial Treatment', 'value' : '454'},
                                   {'label' : '304 Latest Visit or Consultation', 'value' : '304'},
                                   {'label' : '453 Acute Manifestation of a Chronic Condition', 'value' : '453'},
                                   {'label' : '439 Accident', 'value' : '439'},
                                   {'label' : '455 Last X-ray', 'value' : '455'},
                                   {'label' : '471 Prescription', 'value' : '471'},
                                   {'label' : '090 Report Start (Assumed Care Date)', 'value' : '090'},
                                   {'label' : '091 Report End (Relinquished Care Date)', 'value' : '091'},
                                   {'label' : '444 First Visit or Consultation', 'value' : '444'}];
        let npiValues = [{'label' : '0B', 'value' : '0B'},
                         {'label' : '1G', 'value' : '1G'},
                         {'label' : 'G2', 'value' : 'G2'},
                         {'label' : 'LU', 'value' : 'LU'}];
        let outsideLabValues = [];
        outsideLabValues.push("Yes");
        outsideLabValues.push("No");
        let referringProviderQualifier =[{'label' : 'DN', 'value' : 'DN'},
                                         {'label' : 'DK', 'value' : 'DK'},
                                         {'label' : 'DQ', 'value' : 'DQ'}
                                        ];
        let espdtValues = [{'label' : 'AV', 'value' : 'AV'},
                           {'label' : 'S2', 'value' : 'S2'},
                           {'label' : 'ST', 'value' : 'ST'},
                           {'label' : 'NU', 'value' : 'NU'}
                          ];
        let qualifierForProcedure = 
            [{'label' : 'AV', 'value' : 'AV'},
             {'label' : '0B', 'value' : '0B'},
             {'label' : '1G', 'value' : '1G'},
             {'label' : 'G2', 'value' : 'G2'},
             {'label' : 'LU', 'value' : 'LU'},
             {'label' : 'ZZ', 'value' : 'ZZ'}
            ];
        component.set("v.qualifierForProcedure",qualifierForProcedure); 
        component.set("v.espdtValues",espdtValues); 
        component.set("v.referringProviderQualifier",referringProviderQualifier); 
        component.set("v.outsideLabValues",outsideLabValues); 
        component.set("v.npiValues",npiValues);
        component.set("v.qualifierForDateOfCurrentIllness",arrQual);
        component.set("v.qualifierForOtherDates",qual_OtherDatesArr);
        
    },
    buildDataForProcedure :  function(component, event,helper,serverResponse) {
        
        var transactionaljsonList = [];
        var insideJson = {};
        var completeJson = [];
        
        for(let i=1;i<=6;i++){
            insideJson = {"Id" : '',
                          "isRowDisabled" : true,
                          "isDateSearchingDisabled" : true,
                          "fromDate_Procedure" : '',
                          "toDate_Procedure" : '',
                          "placeOfService_Procedure" : '',
                          "emergency_Procedure" : '',
                          "emergency_FreeText_Procedure" : '',
                          "cptCode_Procedure" : '',
                          "cptCodeName_Procedure" : '',
                          "modifier_Procedure" : '',
                          "modifier_Procedure2" : '',
                          "modifier_Procedure3" : '',
                          "modifier_Procedure4" : '',
                          "diagnosisPointer_Procedure" : '',
                          "daysOrUnit_Procedure" : 0,
                          "espdtSelectedValueFromDropDown_Procedure" : '',
                          "espdtSelectedValueFromText_Procedure" : '',
                          "qualifier_Procedure" : '',
                          "rendringProviderNonNPI_Procedure" : '',
                          "rendringProviderNPI_Procedure" : '',
                          "charges_Procedure" : 0
                          
                         };
            if(i==1){
                insideJson.isDateSearchingDisabled = false;
            }
            completeJson.push(insideJson);
        }
        console.log('dwb' , insideJson);
        
        
        var rec ={};
        rec = {
            
            "Record" : JSON.parse(JSON.stringify(completeJson))
        };
        transactionaljsonList.push(rec);
        component.set("v.transactionaljsonList",JSON.parse(JSON.stringify(transactionaljsonList)));
        
        
    },
    flagIfCodesFieldNotFilled : function(component, event, helper,allRelatedICD) { 
        let isCodeEmpty = false;
        for(let rec in allRelatedICD){
            if(!allRelatedICD[rec].hasOwnProperty('Name')){
                isCodeEmpty = true;
                break;
            }
        }
        if(isCodeEmpty){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "1 OR MORE ICD IS MISSING THE CODE FIELD",
                "message": "No code defined for 1 or more diagnosis",
                "type" : "warning"
            });
            toastEvent.fire();
        }
    },
    fillDataForAllDiagnosis : function(component, event, helper,mapOfPointerAndICD,allRelatedICD,insideArr,valueForPointer,
                                       filledPointers) { 
        let emptyBoxes = component.get("v.emptiedDiagnosisBoxes");
        let emptyBoxesCopy = JSON.parse(JSON.stringify(emptyBoxes));
        let arrFilledPointers =  filledPointers.split('');
        
        for(let fillEmpty in allRelatedICD){       
            if(!mapOfPointerAndICD.hasOwnProperty(allRelatedICD[fillEmpty].Name)){
                insideArr[0]['diagnosis_'+emptyBoxes[fillEmpty]]= allRelatedICD[fillEmpty].Name;                   
                valueForPointer+=emptyBoxes[fillEmpty];                        
                mapOfPointerAndICD[allRelatedICD[fillEmpty].Name] = emptyBoxes[fillEmpty];  
                let index = emptyBoxesCopy.indexOf(allRelatedICD[fillEmpty]);
                if (index > -1) {
                    emptyBoxesCopy.splice(index, 1);
                }
            }
            else {
                valueForPointer+= mapOfPointerAndICD[allRelatedICD[fillEmpty].Name];  
                
            }
        }
        component.set("v.emptiedDiagnosisBoxes",emptyBoxesCopy); 
    },
    fillDataForLimitedDiagnosis :  function(component, event, helper,mapOfPointerAndICD,allRelatedICD,
                                            insideArr,valueForPointer,filledPointers) {
        let emptyBoxes = component.get("v.emptiedDiagnosisBoxes");
        let emptyBoxesCopy = JSON.parse(JSON.stringify(emptyBoxes));
        let arrFilledPointers =  filledPointers.split('');
        
        for(let fillEmpty in emptyBoxes){       
            if(!mapOfPointerAndICD.hasOwnProperty(allRelatedICD[fillEmpty].Name)){
                insideArr[0]['diagnosis_'+emptyBoxes[fillEmpty]]= allRelatedICD[fillEmpty].Name;                   
                valueForPointer+=emptyBoxes[fillEmpty];                        
                mapOfPointerAndICD[allRelatedICD[fillEmpty].Name] = emptyBoxes[fillEmpty];  
                let index = emptyBoxesCopy.indexOf(emptyBoxes[fillEmpty]);
                if (index > -1) {
                    emptyBoxesCopy.splice(index, 1);
                }
            }
            else {
                valueForPointer+= mapOfPointerAndICD[allRelatedICD[fillEmpty].Name];  
                
            }
        }
        component.set("v.emptiedDiagnosisBoxes",emptyBoxesCopy); 
        
    },
    fillEqualDataForBoxesAndDiagnosis : function(component, event, helper,mapOfPointerAndICD,allRelatedICD,
                                                 insideArr,valueForPointer,filledPointers) {
        let emptyBoxes = component.get("v.emptiedDiagnosisBoxes");
        let emptyBoxesCopy = JSON.parse(JSON.stringify(emptyBoxes));
        let arrFilledPointers =  filledPointers.split('');
        
        for(let fillEmpty in emptyBoxes){       
            if(!mapOfPointerAndICD.hasOwnProperty(allRelatedICD[fillEmpty].Name)){
                insideArr[0]['diagnosis_'+emptyBoxes[fillEmpty]]= allRelatedICD[fillEmpty].Name;                   
                valueForPointer+=emptyBoxes[fillEmpty];                        
                mapOfPointerAndICD[allRelatedICD[fillEmpty].Name] = emptyBoxes[fillEmpty];  
                let index = emptyBoxesCopy.indexOf(emptyBoxes[fillEmpty]);
                if (index > -1) {
                    emptyBoxesCopy.splice(index, 1);
                }
            }
            else {
                valueForPointer+= mapOfPointerAndICD[allRelatedICD[fillEmpty].Name];  
                
            }
        }
        component.set("v.emptiedDiagnosisBoxes",emptyBoxesCopy); 
        
    },
    flagNoChargesPresentForThisProcedure : function(component, event, helper,Name) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "No charges present for PROCEDURE : "+Name,
            "message": "No charges present for this Procedure.",
            "type" : "warning"
        });
        toastEvent.fire();
    },
    calculateTotalCharges :  function(component, event, helper,res) {
        let daysUnit = 0;
        let charges = 0;
        if(res[0].hasOwnProperty('ElixirSuite__Procedure__r')){
            daysUnit =  res[0].ElixirSuite__Procedure__r.ElixirSuite__Days_Units__c;
            charges =   res[0].ElixirSuite__Procedure__r.ElixirSuite__Charges__c;
        }
        let jsonList = component.get("v.jsonList");
        let existingCharge = jsonList[0].Record[0].TotalCharges;
        let amountToAdd = daysUnit*charges;
        if(!$A.util.isUndefinedOrNull(existingCharge)){
            if(existingCharge){
                existingCharge+=parseInt(amountToAdd);
            }
        }
        
        jsonList[0].Record[0].TotalCharges = existingCharge;
        component.set("v.jsonList",jsonList);
    },
    flagProcedure : function(component, event, helper,res){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": " PROCEDURE  "+res[0].Name+" WAS FOUND.",
            "message": "Procedure found!",
            "type" : "info"
        });
        toastEvent.fire();
    },
    emptyRow :  function(component, event, helper,parentJSON,res,parentIndex,childIndex) {
        let  insideJson = {"Id" : '',
                           "isRowDisabled" : true,
                           "isDateSearchingDisabled" : true,
                           "fromDate_Procedure" : '',
                           "toDate_Procedure" : '',
                           "placeOfService_Procedure" : '',
                           "emergency_Procedure" : '',
                           "emergency_FreeText_Procedure" : '',
                           "cptCode_Procedure" : '',
                           "cptCodeName_Procedure" : '',
                           "modifier_Procedure" : '',
                           "modifier_Procedure2" : '',
                           "modifier_Procedure3" : '',
                           "modifier_Procedure4" : '',
                           "diagnosisPointer_Procedure" : '',
                           "daysOrUnit_Procedure" : 0,
                           "espdtSelectedValueFromDropDown_Procedure" : '',
                           "espdtSelectedValueFromText_Procedure" : '',
                           "qualifier_Procedure" : '',
                           "rendringProviderNonNPI_Procedure" : '',
                           "rendringProviderNPI_Procedure" : '',
                           "charges_Procedure" : 0
                           
                          };
        parentJSON[parentIndex].Record[childIndex] = insideJson;
        component.set("v.jsonList",jsonList);   
        
        
        
    },
    populateProcedureData : function(component, event, helper,parentJSON,res,parentIndex,childIndex,serverResponse) {
        //   helper.flagProcedure(component, event, helper,res);
        var errorMessageValue = $A.get("$Label.c.ProcedureCancelationCMS1500");
        component.set("v.errorMessage",errorMessageValue);
        component.set("v.parentindexValue",parentIndex);
        component.set("v.childindexValue",childIndex);
        if(res[0].ElixirSuite__Procedure__r.ElixirSuite__Status__c == 'Canceled' && res[0].ElixirSuite__Procedure__r.ElixirSuite__Type_of_Procedure__c == 'Insurance Payment' 
          && res[0].ElixirSuite__Procedure__r.ElixirSuite__Ready_for_Billing__c == true){
            component.set("v.showConfirmation", true);
        }
        var getProcData =  component.get("v.alreadyexistingProcedure");
        getProcData.push(res[0].Id);
       /* if(serverResponse.hasOwnProperty('relatedRenderingProvider')){
            if(!$A.util.isEmpty(serverResponse.relatedRenderingProvider)){
                parentJSON[parentIndex].Record[childIndex].rendringProviderNonNPI_Procedure = serverResponse.relatedRenderingProvider[0].Name;
                parentJSON[parentIndex].Record[childIndex].rendringProviderNPI_Procedure = serverResponse.relatedRenderingProvider[0].ElixirSuite__ID_Qualifier__c;
            }
        }*/
        parentJSON[parentIndex].Record[childIndex].Id = res[0].ElixirSuite__Procedure__c; // Procedure id
        parentJSON[parentIndex].Record[childIndex].placeOfService_Procedure = res[0].ElixirSuite__Procedure__r.ElixirSuite__Place_Of_Service_Picklist__c;       
        parentJSON[parentIndex].Record[childIndex].cptCodeName_Procedure = res[0].ElixirSuite__Procedure__r.Name; //Anusha - replaced ElixirSuite__CPT_HCPCS_Code__c with Name
        parentJSON[parentIndex].Record[childIndex].charges_Procedure = res[0].ElixirSuite__Procedure__r.ElixirSuite__Charges__c;
        if(!$A.util.isUndefinedOrNull(res[0].ElixirSuite__Procedure__r.ElixirSuite__Surgeon__c)){
        parentJSON[parentIndex].Record[childIndex].rendringProviderNPI_Procedure = res[0].ElixirSuite__Procedure__r.ElixirSuite__Surgeon__r.ElixirSuite__Practitioner_NPI__c;
        parentJSON[parentIndex].Record[childIndex].rendringProviderNonNPI_Procedure = res[0].ElixirSuite__Procedure__r.ElixirSuite__Surgeon__r.ElixirSuite__Tax_Id__c;
          }
        if(res[0].hasOwnProperty('ElixirSuite__Procedure__r')){
            parentJSON[parentIndex].Record[childIndex].daysOrUnit_Procedure = res[0].ElixirSuite__Procedure__r.ElixirSuite__Days_Units__c;
        }
        else {
            parentJSON[parentIndex].Record[childIndex].daysOrUnit_Procedure = 1;
        }
        if(res[0].hasOwnProperty('ElixirSuite__Procedure__r')){
            if(res[0].ElixirSuite__Procedure__r.hasOwnProperty('ElixirSuite__Charges__c')){ 
                helper.calculateTotalCharges(component, event, helper,JSON.parse(JSON.stringify(res)));
            }
            else {
                helper.flagNoChargesPresentForThisProcedure(component, event, helper,JSON.parse(JSON.stringify(res[0].ElixirSuite__Procedure__r.Name)));
            }
        }
        console.log('res## '+JSON.stringify(res));
        console.log('mod1 name## '+res[0].ElixirSuite__Procedure__r.hasOwnProperty('ElixirSuite__Modifier1__r'));
        
        parentJSON[parentIndex].Record[childIndex].modifier_Procedure = res[0].ElixirSuite__Procedure__r.hasOwnProperty('ElixirSuite__Modifier1__r')? res[0].ElixirSuite__Procedure__r.ElixirSuite__Modifier1__r.Name : '';
        parentJSON[parentIndex].Record[childIndex].modifier_Procedure2 = res[0].ElixirSuite__Procedure__r.hasOwnProperty('ElixirSuite__Modifier2__r')? res[0].ElixirSuite__Procedure__r.ElixirSuite__Modifier2__r.Name : '';
        parentJSON[parentIndex].Record[childIndex].modifier_Procedure3 = res[0].ElixirSuite__Procedure__r.hasOwnProperty('ElixirSuite__Modifier3__r')? res[0].ElixirSuite__Procedure__r.ElixirSuite__Modifier3__r.Name : '';
        parentJSON[parentIndex].Record[childIndex].modifier_Procedure4 = res[0].ElixirSuite__Procedure__r.hasOwnProperty('ElixirSuite__Modifier4__r')? res[0].ElixirSuite__Procedure__r.ElixirSuite__Modifier4__r.Name : '';
        parentJSON[parentIndex].Record[childIndex].qualifier_Procedure = res[0].ElixirSuite__Procedure__r.ElixirSuite__ID_Qualifier__c;
        //console.log('mod1 name## '+res[0].ElixirSuite__Procedure__r.ElixirSuite__Modifier1__r.Name);
        
        
        var jsonList = component.get("v.jsonList");
        var insideArr = jsonList[0].Record;
        var allRelatedICD = serverResponse.relatedICDCodes;
        
        if(!$A.util.isEmpty(allRelatedICD)){
            let existingID = component.get("v.existingProcedurePrePopulated");
            let attachedProcId = component.get("v.attachedProcId");
            existingID.push(res[0].Id);
            attachedProcId.push(res[0].ElixirSuite__Procedure__c);
            component.set("v.existingProcedurePrePopulated",existingID);
            component.set("v.attachedProcId",attachedProcId);
            console.log('PD Helper '+component.get("v.existingProcedurePrePopulated"));
            console.log('Pro Helper '+component.get("v.attachedProcId"));
            //  helper.flagIfCodesFieldNotFilled(component, event, helper,allRelatedICD);
            var arrrNum = component.get("v.fetchedRowIndexArray");
            
            
            var alphaNumbericMap = {'1' : 'A','2' : 'B','3':'C','4' :'D','5' :'E','6':'F','7':'G','8':'H','9':'I','10':'J',
                                    '11':'K','12':'L'};
            let i = 1;
            let valueForPointer = '';
            let lastPointerFilled = parseInt(component.get("v.lastPointerFilled"));
            if(lastPointerFilled == 12){
                let filledPointers =  parentJSON[parentIndex].Record[childIndex].diagnosisPointer_Procedure;                
                let emptyBoxes = component.get("v.emptiedDiagnosisBoxes");                              
                if(!$A.util.isEmpty(emptyBoxes)){
                    if(allRelatedICD.length<emptyBoxes.length){
                        helper.fillDataForAllDiagnosis(component, event, helper,mapOfPointerAndICD,allRelatedICD,insideArr,
                                                       valueForPointer,filledPointers);
                    }
                    else if(allRelatedICD.length>emptyBoxes.length){
                        helper.fillDataForLimitedDiagnosis(component, event, helper,mapOfPointerAndICD,allRelatedICD,insideArr,
                                                           valueForPointer,filledPointers);
                    }
                        else if(allRelatedICD.length>emptyBoxes.length){
                            helper.fillEqualDataForBoxesAndDiagnosis(component, event, helper,mapOfPointerAndICD,allRelatedICD,insideArr,
                                                                     valueForPointer,filledPointers);
                        }
                    
                    
                }
                else {
                    helper.allPOintersFilledToast(component, event, helper);
                    parentJSON[parentIndex].Record[childIndex].isRowDisabled = true;// xxx 
                }
            }
            else {
                // if(lastPointerFilled!=1){
                    lastPointerFilled++;
                // }
                let alreadyExistingICDCode =  component.get("v.alreadyExistingICDCode");
                var mapOfPointerAndICD = component.get("v.mapOfPointerAndICD");
                var mapOfchildIndexAndFilledPointers = component.get("v.mapOfchildIndexAndFilledPointers");
                if(!arrrNum.includes(childIndex)){
                    try {
                        for(let rec in allRelatedICD){           
                            if(i<=12){     
                                
                                if(!mapOfPointerAndICD.hasOwnProperty(allRelatedICD[rec].Name)){
                                    
                                    var index = JSON.parse(JSON.stringify(lastPointerFilled));
                                    console.log('index'+index);
                                    console.log('alphaNumbericMap[index]'+alphaNumbericMap[index]);
                                    insideArr[0]['diagnosis_'+alphaNumbericMap[index]]= allRelatedICD[rec].Name;                   
                                    valueForPointer+=alphaNumbericMap[index];
                                    lastPointerFilled =  JSON.parse(JSON.stringify(index));  
                                    component.set("v.lastPointerFilled", JSON.parse(JSON.stringify(lastPointerFilled.toString())));
                                    console.log('lastPointerFilled'+component.get("v.lastPointerFilled"));
                                    mapOfPointerAndICD[allRelatedICD[rec].Name] = alphaNumbericMap[index];
                                    lastPointerFilled ++;
                                    
                                }
                                else {
                                    valueForPointer+= mapOfPointerAndICD[allRelatedICD[rec].Name];  
                                    
                                }
                                
                            }
                            i++;
                            
                        }
                    }
                    catch(err) { 
                        console.log('err.message' +err.message);
                    }
                }
                else { // If it was edited for an existing procedure
                    if(lastPointerFilled == 12){
                        let filledPointers =  parentJSON[parentIndex].Record[childIndex].diagnosisPointer_Procedure;                
                        let emptyBoxes = component.get("v.emptiedDiagnosisBoxes");                              
                        if(!$A.util.isEmpty(emptyBoxes)){
                            if(allRelatedICD.length<emptyBoxes.length){
                                helper.fillDataForAllDiagnosis(component, event, helper,mapOfPointerAndICD,allRelatedICD,insideArr,
                                                               valueForPointer,filledPointers);
                            }
                            else if(allRelatedICD.length>emptyBoxes.length){
                                helper.fillDataForLimitedDiagnosis(component, event, helper,mapOfPointerAndICD,allRelatedICD,insideArr,
                                                                   valueForPointer,filledPointers);
                            }
                                else if(allRelatedICD.length>emptyBoxes.length){
                                    helper.fillEqualDataForBoxesAndDiagnosis(component, event, helper,mapOfPointerAndICD,allRelatedICD,insideArr,
                                                                             valueForPointer,filledPointers);
                                }
                            
                            
                        }
                        else {
                            helper.allPOintersFilledToast(component, event, helper);
                            parentJSON[parentIndex].Record[childIndex].isRowDisabled = true;// xxx 
                        }
                    }
                    else {
                        var filledPointers =  parentJSON[parentIndex].Record[childIndex].diagnosisPointer_Procedure;
                        var arrFilledPointers =  filledPointers.split('');
                        
                        if(arrFilledPointers.length>allRelatedICD.length){ //if filled pointer is GREATER and incoming diagnosis is less
                            let toEmptyPointers = arrFilledPointers.length - allRelatedICD.length;
                            let emptyPointers = arrFilledPointers.slice(Math.max(arrFilledPointers.length - toEmptyPointers, 0)); // all boxes to empty
                            for(let rec in allRelatedICD){           
                                if(i<=4){                                                                     
                                    if(!mapOfPointerAndICD.hasOwnProperty(allRelatedICD[rec].Name)){                                    
                                        var index = JSON.parse(JSON.stringify(lastPointerFilled));
                                        for(let del in mapOfPointerAndICD){  //delete the existing key value pair if the same strip was edited                                									
                                            if(mapOfPointerAndICD[del] == arrFilledPointers[rec]){
                                                delete mapOfPointerAndICD[del];
                                            }
                                        }
                                        insideArr[0]['diagnosis_'+arrFilledPointers[rec]]= allRelatedICD[rec].Name;  
                                        valueForPointer+=arrFilledPointers[rec];                         
                                        mapOfPointerAndICD[allRelatedICD[rec].Name] = arrFilledPointers[rec];                                    
                                    }
                                    else {
                                        valueForPointer+= mapOfPointerAndICD[allRelatedICD[rec].Name];  
                                        // Empty the leftover exisiting boxes as now they are pointing to existing boxes.
                                        insideArr[0]['diagnosis_'+arrFilledPointers[rec]]= ''; 
                                        let emptiedDiagnosisBoxes = component.get("v.emptiedDiagnosisBoxes");
                                        emptiedDiagnosisBoxes.push(arrFilledPointers[rec]);
                                        component.set("v.emptiedDiagnosisBoxes",emptiedDiagnosisBoxes);                                    
                                    }
                                    
                                }
                                i++;
                                
                            }
                            for(let emptyObj in emptyPointers){ // To empty the existing diagnosis boxes
                                insideArr[0]['diagnosis_'+emptyPointers[emptyObj]]= ''; 
                                for(let del in mapOfPointerAndICD){  //delete the extra key value pair that was created for that strip                              									
                                    if(mapOfPointerAndICD[del] == emptyPointers[emptyObj]){
                                        delete mapOfPointerAndICD[del];
                                    }
                                }
                            }
                            
                            let emptiedDiagnosisBoxes = component.get("v.emptiedDiagnosisBoxes");
                            emptiedDiagnosisBoxes = emptiedDiagnosisBoxes.concat(emptyPointers);
                            component.set("v.emptiedDiagnosisBoxes",emptiedDiagnosisBoxes);
                        }
                        
                        else if(arrFilledPointers.length<allRelatedICD.length){ // if filled pointer is less and incoming diagnosis is greater
                            
                            for(let rec in allRelatedICD){  
                                if(i<=4){                                       
                                    if(arrFilledPointers.length>rec){ // First fill all existing pointer
                                        if(!mapOfPointerAndICD.hasOwnProperty(allRelatedICD[rec].Name)){  
                                            for(let del in mapOfPointerAndICD){  //delete the existing key value pair if the same strip was edited                                									
                                                if(mapOfPointerAndICD[del] == arrFilledPointers[rec]){
                                                    delete mapOfPointerAndICD[del]; 
                                                }
                                            }
                                            insideArr[0]['diagnosis_'+arrFilledPointers[rec]]= allRelatedICD[rec].Name;  
                                            //  delete mapOfPointerAndICD[arrFilledPointers[rec]];
                                            
                                            valueForPointer+=arrFilledPointers[rec];
                                            mapOfPointerAndICD[allRelatedICD[rec].Name] = arrFilledPointers[rec];
                                        }
                                        else {
                                            valueForPointer+= mapOfPointerAndICD[allRelatedICD[rec].Name];  
                                            // Empty the leftover exisiting boxes as now they are pointing to existing boxes.
                                            insideArr[0]['diagnosis_'+arrFilledPointers[rec]]= ''; 
                                            let emptiedDiagnosisBoxes = component.get("v.emptiedDiagnosisBoxes");
                                            emptiedDiagnosisBoxes.push(arrFilledPointers[rec]);
                                            component.set("v.emptiedDiagnosisBoxes",emptiedDiagnosisBoxes); 
                                        }
                                        
                                    }
                                    else { // Then Start filling into new pointers
                                        if(!mapOfPointerAndICD.hasOwnProperty(allRelatedICD[rec].Name)){                                        
                                            var index = JSON.parse(JSON.stringify(lastPointerFilled));
                                            for(let del in mapOfPointerAndICD){  //delete the existing key value pair if the same strip was edited                                									
                                                if(mapOfPointerAndICD[del] == alphaNumbericMap[index]){
                                                    delete mapOfPointerAndICD[del];
                                                }
                                            }
                                            
                                            insideArr[0]['diagnosis_'+alphaNumbericMap[index]]= allRelatedICD[rec].Name;                                                                                           
                                            valueForPointer+=alphaNumbericMap[index];
                                            lastPointerFilled =  JSON.parse(JSON.stringify(index));  
                                            component.set("v.lastPointerFilled", JSON.parse(JSON.stringify(lastPointerFilled.toString())));
                                            mapOfPointerAndICD[allRelatedICD[rec].Name] = alphaNumbericMap[index];   
                                            lastPointerFilled ++;
                                        }
                                        else {
                                            valueForPointer+= mapOfPointerAndICD[allRelatedICD[rec].Name];        
                                            // Empty the leftover exisiting boxes as now they are pointing to existing boxes.
                                            // May be this code will fail.
                                            insideArr[0]['diagnosis_'+arrFilledPointers[rec]]= ''; 
                                            let emptiedDiagnosisBoxes = component.get("v.emptiedDiagnosisBoxes");
                                            emptiedDiagnosisBoxes.push(arrFilledPointers[rec]);
                                            component.set("v.emptiedDiagnosisBoxes",emptiedDiagnosisBoxes); 
                                        }
                                        
                                        
                                    }
                                }
                                
                                i++;  
                            }
                            
                        }
                        
                            else if(arrFilledPointers.length==allRelatedICD.length){
                                for(let rec in allRelatedICD){           
                                    if(i<=4){     
                                        if(!mapOfPointerAndICD.hasOwnProperty(allRelatedICD[rec].Name)){
                                            for(let del in mapOfPointerAndICD){  //delete the existing key value pair if the same strip was edited                                									
                                                if(mapOfPointerAndICD[del] == arrFilledPointers[rec]){
                                                    delete mapOfPointerAndICD[del];
                                                }
                                            }
                                            insideArr[0]['diagnosis_'+arrFilledPointers[rec]]= allRelatedICD[rec].Name;                                      
                                            valueForPointer+=arrFilledPointers[rec];
                                            mapOfPointerAndICD[allRelatedICD[rec].Name] = arrFilledPointers[rec];
                                            
                                        }
                                        else {
                                            valueForPointer+= mapOfPointerAndICD[allRelatedICD[rec].Name]; 
                                            // Empty the leftover exisiting boxes as now they are pointing to existing boxes.
                                            insideArr[0]['diagnosis_'+arrFilledPointers[rec]]= ''; 
                                            let emptiedDiagnosisBoxes = component.get("v.emptiedDiagnosisBoxes");
                                            emptiedDiagnosisBoxes.push(arrFilledPointers[rec]);
                                            component.set("v.emptiedDiagnosisBoxes",emptiedDiagnosisBoxes);
                                            
                                        }
                                        
                                        
                                    }
                                    i++;
                                    
                                }
                            }
                    }
                }
                parentJSON[parentIndex].Record[childIndex].diagnosisPointer_Procedure = valueForPointer;
                component.set("v.jsonList",jsonList);        
                component.set("v.mapOfPointerAndICD",mapOfPointerAndICD); 
                component.set("v.mapOfchildIndexAndFilledPointers",mapOfchildIndexAndFilledPointers); 
                arrrNum.push(childIndex);
                component.set("v.fetchedRowIndexArray",arrrNum);
            }
            
            
            
        }
        else {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "NO ICD CODES FOR  PROCEDURE "+res[0].Name,
                "message": "No ICD CODE is defined for this procedure!",
                "type" : "warning"
            });
            toastEvent.fire();
        }
        
    },
    populateICDCodeCustomLookup : function(component, event, helper,icdRecord){
        var action = component.get("c.ICDCodeRecord");
        action.setParams({
            "recordId" :   icdRecord         
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {  
                component.set("v.loaded",true); // xxx 
                var res = response.getReturnValue();
                if(!$A.util.isEmpty(res)){
                    component.set("v.searchRecords",res);
                    component.set("v.searchRecords",res[0].Name)// xxx 
                }
                else {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "NO ICD CODES FOR THIS PROCEDURE",
                        "message": "No ICD CODE is defined for this procedure!",
                        "type" : "warning"
                    });
                    toastEvent.fire();
                }
                component.set("v.transactionaljsonList",parentJSON); 
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
    },
    checkFromDateValidity : function(component, event, helper,value,childIndex) { 
        var isValid = true;
        var endDateCmp = component.find('validfieldFromDate');
        var endDate = value;
        var today = new Date();        
        var dte = new Date(endDate);
        if(Array.isArray(endDateCmp)){            
            if((dte.setDate(dte.getDate()) >today)){
                endDateCmp[childIndex].setCustomValidity("Future date not allowed");
                isValid = false;
            } 
            else {
                endDateCmp[childIndex].setCustomValidity("");
                
            }
            endDateCmp[childIndex].reportValidity(); 
        }
        else {
            var endDate = endDateCmp.get('v.value');
            var today = new Date();        
            var dte = new Date(endDate);
            if((dte.setDate(dte.getDate()) >today)){
                endDateCmp.setCustomValidity("Future date not allowed");
                endDateCmp.reportValidity();  
                isValid = false;
            }
        }
        return isValid;
    },
    checkToDateValidity : function(component, event, helper,value,childIndex) { 
        var isValid = true;
        var endDateCmp = component.find('validfieldToDate');
        var endDate = value;
        var today = new Date();        
        var dte = new Date(endDate);
        
        if(Array.isArray(endDateCmp)){            
            if((dte.setDate(dte.getDate()) >today)){
                endDateCmp[childIndex].setCustomValidity("Future date not allowed"); 
                isValid = false;
            } 
            else {
                endDateCmp[childIndex].setCustomValidity("");
                
            }
            endDateCmp[childIndex].reportValidity(); 
        }
        else {
            var endDate = endDateCmp.get('v.value');
            var today = new Date();        
            var dte = new Date(endDate);
            if((dte.setDate(dte.getDate()+1) >today)){
                endDateCmp.setCustomValidity("Future date not allowed");
                endDateCmp.reportValidity();  
                isValid = false;
            }
        }
        return isValid;
    },
    validateToDate_UnableToWork_InHelper : function(component, event, helper,value,childIndex) { 
        var endDateCmp = component.find('validfieldToDateUnableToWork');
        var endDate = value;
        var today = new Date();        
        var dte = new Date(endDate);
        if(Array.isArray(endDateCmp)){            
            if((dte.setDate(dte.getDate()) >today)){
                endDateCmp[childIndex].setCustomValidity("Future date not allowed"); 
                component.set("v.isAddClaimEnabled",true); 
            } 
            else {
                endDateCmp[childIndex].setCustomValidity("");
                component.set("v.isAddClaimEnabled",false); 
            }
            endDateCmp[childIndex].reportValidity(); 
        }
        else {
            var endDate = endDateCmp.get('v.value');
            var today = new Date();        
            var dte = new Date(endDate);
            if((dte.setDate(dte.getDate()) >today)){
                endDateCmp.setCustomValidity("Future date not allowed");
                component.set("v.isAddClaimEnabled",true); 
            }
            else {
                endDateCmp.setCustomValidity("");
                component.set("v.isAddClaimEnabled",false); 
            }
            endDateCmp.reportValidity(); 
        }
    },
    allPOintersFilledToast :  function(component, event, helper,value,childIndex) { 
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "ALL DIAGNOSIS POINTERS CONSUMED!",
            "message": "POINTERS EXHAUISTED",
            "type" : "error"
        });
        toastEvent.fire();
    },
    fetchDropdownValues :  function(component){	
        component.set("v.dropDownOptions",[]);	
        component.set("v.dropDownSelectedValues",[]);	
        component.set('v.searchString','');	
        component.set('v.isdisAbled',false);	
        var action = component.get( 'c.fetchCusomMetadataRecord' );	
        component.set("v.loaded",false);	
        
        action.setParams({	
            
        });	
        
        action.setCallback(this, function(response) { 	
            var res = response.getReturnValue();	
            var state = response.getState();	
            if (state === "SUCCESS") {	
                component.set("v.loaded",true);	
                
                var opts = [];	
                console.log('final ' + JSON.stringify(res));	
                var nspc = '';	
                var nameSpace = '' ;	
                console.log('NSPC ORG WIDE  '+JSON.stringify(nspc));	
                //component.set("v.CustomMetadataValues", res);					
                var a = res;	
                var b = [];	
                var arr = [];	
                
                for (var k=0;k<res['ClaimCodes'].length;k++){	
                    opts.push({'label':res['ClaimCodes'][k][nameSpace + 'ElixirSuite__Description__c'],'value' : res['ClaimCodes'][k][nameSpace + 'Name']});	
                }	
                component.set("v.dropDownOptions", opts);	 
                // component.set("v.dropDownSelectedValues",opts);	
                // alert('mpl options set'+ JSON.stringify(component.get("v.dropDownOptions")));		  	
                
            } 	
            else if (state === "ERROR") {	
                //  component.find("Id_spinner").set("v.class" , 'slds-hide');	
                var errors = response.getError();	
                if (errors) {	
                    if (errors[0] && errors[0].message) {	
                        console.log("Error message: " +	
                                    errors[0].message);	
                    }	
                } else {	
                    console.log("Unknown error");	
                }	
                
                
            }	
            
        });	
        $A.enqueueAction(action);	
    },
    flagNoVOB : function(component, event, helper) { 
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "NO INSURANCE DETAILS WAS FOUND FOR THIS PATIENT!",
            "message": "No insurance details present in the system!",
            "type" : "warning"
        });
        toastEvent.fire();
    },
    CreateAmericaStatesJSON : function(component, event, helper) { 
        var states  = [
            {
                "name": "Alabama",
                "abbreviation": "AL"
            },
            {
                "name": "Alaska",
                "abbreviation": "AK"
            },
            {
                "name": "Arizona",
                "abbreviation": "AZ"
            },
            {
                "name": "Arkansas",
                "abbreviation": "AR"
            },
            {
                "name": "California",
                "abbreviation": "CA"
            },
            {
                "name": "Colorado",
                "abbreviation": "CO"
            },
            {
                "name": "Connecticut",
                "abbreviation": "CT"
            },
            {
                "name": "Delaware",
                "abbreviation": "DE"
            },
            {
                "name": "District Of Columbia",
                "abbreviation": "DC"
            },
            {
                "name": "Florida",
                "abbreviation": "FL"
            },
            {
                "name": "Georgia",
                "abbreviation": "GA"
            },
            {
                "name": "Hawaii",
                "abbreviation": "HI"
            },
            {
                "name": "Idaho",
                "abbreviation": "ID"
            },
            {
                "name": "Illinois",
                "abbreviation": "IL"
            },
            {
                "name": "Indiana",
                "abbreviation": "IN"
            },
            {
                "name": "Iowa",
                "abbreviation": "IA"
            },
            {
                "name": "Kansas",
                "abbreviation": "KS"
            },
            {
                "name": "Kentucky",
                "abbreviation": "KY"
            },
            {
                "name": "Louisiana",
                "abbreviation": "LA"
            },
            {
                "name": "Maine",
                "abbreviation": "ME"
            },
            {
                "name": "Maryland",
                "abbreviation": "MD"
            },
            {
                "name": "Massachusetts",
                "abbreviation": "MA"
            },
            {
                "name": "Michigan",
                "abbreviation": "MI"
            },
            {
                "name": "Minnesota",
                "abbreviation": "MN"
            },
            {
                "name": "Mississippi",
                "abbreviation": "MS"
            },
            {
                "name": "Missouri",
                "abbreviation": "MO"
            },
            {
                "name": "Montana",
                "abbreviation": "MT"
            },
            {
                "name": "Nebraska",
                "abbreviation": "NE"
            },
            {
                "name": "Nevada",
                "abbreviation": "NV"
            },
            {
                "name": "New Hampshire",
                "abbreviation": "NH"
            },
            {
                "name": "New Jersey",
                "abbreviation": "NJ"
            },
            {
                "name": "New Mexico",
                "abbreviation": "NM"
            },
            {
                "name": "New York",
                "abbreviation": "NY"
            },
            {
                "name": "North Carolina",
                "abbreviation": "NC"
            },
            {
                "name": "North Dakota",
                "abbreviation": "ND"
            },
            {
                "name": "Ohio",
                "abbreviation": "OH"
            },
            {
                "name": "Oklahoma",
                "abbreviation": "OK"
            },
            {
                "name": "Oregon",
                "abbreviation": "OR"
            },
            {
                "name": "Pennsylvania",
                "abbreviation": "PA"
            },
            {
                "name": "Rhode Island",
                "abbreviation": "RI"
            },
            {
                "name": "South Carolina",
                "abbreviation": "SC"
            },
            {
                "name": "South Dakota",
                "abbreviation": "SD"
            },
            {
                "name": "Tennessee",
                "abbreviation": "TN"
            },
            {
                "name": "Texas",
                "abbreviation": "TX"
            },
            {
                "name": "Utah",
                "abbreviation": "UT"
            },
            {
                "name": "Vermont",
                "abbreviation": "VT"
            },
            {
                "name": "Virginia",
                "abbreviation": "VA"
            },
            {
                "name": "Washington",
                "abbreviation": "WA"
            },
            {
                "name": "West Virginia",
                "abbreviation": "WV"
            },
            {
                "name": "Wisconsin",
                "abbreviation": "WI"
            },
            {
                "name": "Wyoming",
                "abbreviation": "WY"
            }
        ]
        for(let rec in states){
            states[rec]['nameAndAbbreviation'] = states[rec].name + ' - '+states[rec].abbreviation;
        }
        return states;
    },
    populateVOBDetails :function(component, event, helper,resp) { 
        try{
            if(!$A.util.isEmpty(resp) && resp!=' '){
                component.set("v.payorName",resp[0].ElixirSuite__Payer__c);
                let jsonList = component.get("v.jsonList");
                let commaSeparInsudName = '';
                 const insuranceTypeMap = {
                    'Medicare': 'Medicare',
                    'Medicaid': 'Medicaid',
                    'Tricare': 'Tricare',
                    'CHAMPVA': 'CHAMPVA',
                    'Group Health Plan': 'Group Health Plan',
                    'FECA': 'FECA BLK LUNG',
                    'Other': 'Other',
                    'MA': 'Medicare Part A',
                    'MB': 'Medicare Part B',
                    'OF': 'Other Federal Program',
                    'WC': 'Workers\' Compensation Health Claim'
                };
                for(let rec in jsonList){
                    let name = helper.formulateName(component, event, helper,resp[0]);
                    jsonList[rec].Record[0].insuredIdNumber = resp[0].ElixirSuite__Member_Id__c;
                    commaSeparInsudName = name;
                    jsonList[rec].Record[0].insuredAddress = resp[0].ElixirSuite__Insured_Address__c;
                    jsonList[rec].Record[0].relationWithInsured  = resp[0].ElixirSuite__Patient_Relationship_With_Insured__c;
                    jsonList[rec].Record[0].insuredPolicyNumber = resp[0].ElixirSuite__Insurance_Group_Number__c;
                    jsonList[rec].Record[0].insurancePlanName = resp[0].ElixirSuite__Insurance_Plan_Name__c;
                    jsonList[rec].Record[0].insuredAddress=  resp[0].ElixirSuite__Insured_Address__c;
                    jsonList[rec].Record[0].insuredCity=  resp[0].ElixirSuite__Insured_City__c;
                    jsonList[rec].Record[0].insuredState= component.get("v.StatesAndItsShotforms")[resp[0].ElixirSuite__Insured_State__c];//resp[0].ElixirSuite__Insured_State__c;
                    jsonList[rec].Record[0].insuredZipcode=  resp[0].ElixirSuite__Insured_Zipcode__c;
                    jsonList[rec].Record[0].insuredTelephone=  resp[0].ElixirSuite__InsPhone__c; //Anusha - replaced ElixirSuite__Telephone__c with ElixirSuite__InsPhone__c
                    jsonList[rec].Record[0].insuredDOB=  resp[0].ElixirSuite__Date_Of_Birth__c;
                    // added by jami as autopopulation is not happening correctly on cms1500
                   // jsonList[rec].Record[0].insuranceType=  insuranceTypeMap[resp[0].ElixirSuite__Insurance_Type__c] || resp[0].ElixirSuite__Insurance_Type__c;
                    jsonList[rec].Record[0].insuredPolicyNumber=  resp[0].ElixirSuite__Insured_Policy_Group_FECA_Number__c;
                    jsonList[rec].Record[0].insuredSex = resp[0].ElixirSuite__Gender__c === 'M' ? 'Male' : (resp[0].ElixirSuite__Gender__c === 'F' ? 'Female' : 'Unknown')
                    if(resp[0].RecordType.DeveloperName == 'Auto_accident'){
                        jsonList[rec].Record[0].autoAccident = 'YES';
                        jsonList[rec].Record[0].autoAccPlaceOrState =  resp[0].ElixirSuite__Insured_State__c;
                    }
                    else {
                        jsonList[rec].Record[0].autoAccident = 'NO'; 
                    }
                }
                component.set("v.commaSeparInsudName",commaSeparInsudName);
                component.set("v.jsonList",jsonList);  
                
            }
        }
        catch(e){
            alert(e);
        }
        
    },
    formulateName :function(component, event, helper,resp) { 
        var name = '';
        let firstName = resp.ElixirSuite__Insured_First_Name__c;
        let middleName = resp.ElixirSuite__Insured_Middle_Name__c;
        let lastName = resp.ElixirSuite__Insured_Last_Name__c;
        if(!$A.util.isUndefinedOrNull(firstName) && !$A.util.isUndefinedOrNull(middleName) && !$A.util.isUndefinedOrNull(lastName)){
            name = lastName + ',' + firstName + ',' + middleName;
        }
        else if(($A.util.isUndefinedOrNull(middleName))  && (!$A.util.isUndefinedOrNull(firstName) && !$A.util.isUndefinedOrNull(lastName))){
            name = firstName + ',' + lastName;
        }
            else if(($A.util.isUndefinedOrNull(lastName))  && (!$A.util.isUndefinedOrNull(firstName) && !$A.util.isUndefinedOrNull(middleName))){
                name = firstName + ',' + middleName;
            }
        return name;
    },
    //Anusha - create CreateStatesAndItsShotforms method - 07/11/22
   	CreateStatesAndItsShotforms:function(component, event, helper){
        var statesAndItsCodes={
            "Alabama":"AL","AL":"AL","Alaska":"AK","AK":"AK","Arizona":"AZ","AZ":"AZ","Arkansas":"AR","AR":"AR","California":"CA","CA":"CA","Colorado":"CO","CO":"CO","Connecticut":"CT","CT":"CT","Delaware":"DE","DE":"DE","District Of Columbia":"DC","DC":"DC","Florida":"FL","FL":"FL","Georgia":"GA","GA":"GA","Hawaii":"HI","HI":"HI",
            "Idaho":"ID","ID":"ID","Illinois":"IL","IL":"IL","Indiana":"IN","IN":"IN","Iowa":"IA","IA":"IA","Kansas":"KS","KS":"KS","Kentucky":"KY","KY":"KY","Louisiana":"LA","LA":"LA","Maine":"ME","ME":"ME","Maryland":"MD","MD":"MD","Massachusetts":"MA","MA":"MA","Michigan":"MI","MI":"MI","Minnesota":"MN","MN":"MN","Mississippi":"MS","MS":"MS",
            "Missouri":"MO","MO":"MO","Montana":"MT","MT":"MT","Nebraska":"NE","NE":"NE","Nevada":"NV","NV":"NV","New Hampshire":"NH","NH":"NH","New Jersey":"NJ","NJ":"NJ","New Mexico":"NM","NM":"NM","New York":"NY","NY":"NY","North Carolina":"NC","NC":"NC","North Dakota":"ND","ND":"ND","Ohio":"OH","OH":"OH","Oklahoma":"OK","OK":"OK","Oregon":"OR","OR":"OR",
            "Pennsylvania":"PA","PA":"PA","Rhode Island":"RI","RI":"RI","South Carolina":"SC","SC":"SC","South Dakota":"SD","SD":"SD","Tennessee":"TN","TN":"TN","Texas":"TX","TX":"TX","Utah":"UT","UT":"UT","Vermont":"VT","VT":"VT","Virginia":"VA","VA":"VA","Washington":"WA","WA":"WA","West Virginia":"WV","WV":"WV","Wisconsin":"WI","WI":"WI","Wyoming":"WY","WY":"WY"
         };
         component.set("v.StatesAndItsShotforms",statesAndItsCodes);
    },
    getTotalCharge : function(component, event, helper){
        var name = event.getSource().get("v.name");
        var array = name.split('$');
        var parentIndex = array[0];
        var parentJSON =  component.get("v.transactionaljsonList");
        var childData = parentJSON[parentIndex].Record;
        var sum =0;
        for(var key in childData){
            if(childData[key].charges_Procedure != undefined && childData[key].charges_Procedure != null)  { 
                if(childData[key].daysOrUnit_Procedure != undefined && childData[key].daysOrUnit_Procedure != null) {
                    console.log('daysOrUnit_Procedure '+childData[key].daysOrUnit_Procedure);
                 sum = sum + childData[key].daysOrUnit_Procedure*childData[key].charges_Procedure;   
                }else{
                sum = sum + childData[key].charges_Procedure;
                }
            }
        }
        
        var jsonList = component.get("v.jsonList");
        
        var jsonDataList =jsonList[0].Record;
        
        var childJsonData = jsonList[0].Record[0];
        
        childJsonData.TotalCharges = sum.toFixed(2);
        jsonDataList[0] = childJsonData;
        
        var jsonlisttttttttt = jsonList[0];
        jsonlisttttttttt.Record = jsonDataList;
        jsonList[0] = jsonlisttttttttt;
        
        component.set("v.jsonList",jsonList);
        
    },
    //Lokesh
    validateBillingProviderZip : function(component,event,helper){
        var bpn = component.find('reszip');
        var inputVal = bpn.get("v.value");
        console.log("tem2"+inputVal);
        var regex = /^([1-9]|[1-9][0-9]{1,11}|1[0-2][0-9]{0,11})$/;
        if(!regex.test(inputVal)){
            bpn.setCustomValidity("Zip code can't be greater than 12 char");
            bpn.showHelpMessageIfInvalid();
            console.log("Not matched NPI")
            return false;
        }
        else{
            bpn.setCustomValidity("");
            bpn.showHelpMessageIfInvalid();
            console.log("matched NPI")
            return true;
        }
    },
         validateBillProviderPhone : function(component,event,helper){
        var bpn = component.find('resphone');
        var inputVal = bpn.get("v.value");
        console.log("tem2"+inputVal);
        var regex = /^[0-9]{10}$/;
        if(!regex.test(inputVal)){
            bpn.setCustomValidity("please enter only 10 digit number");
            bpn.showHelpMessageIfInvalid();
            console.log("Not matched NPI")
            return false;
        }
        else{
            bpn.setCustomValidity("");
            bpn.showHelpMessageIfInvalid();
            console.log("matched NPI")
            return true;
        }
    },
    //Anusha
    validateBillingProviderNpi : function(component,event,helper){
        var bpn = component.find('billingProviderNpi');
        var inputVal = bpn.get("v.value");
        console.log("tem2"+inputVal);
        var regex = /^[0-9]{10}$/;
        if(!regex.test(inputVal)){
            bpn.setCustomValidity("please enter 10 digit value");
            bpn.showHelpMessageIfInvalid();
            console.log("Not matched NPI")
            return false;
        }
        else{
            bpn.setCustomValidity("");
            bpn.showHelpMessageIfInvalid();
            console.log("matched NPI")
            return true;
        }
    }


})
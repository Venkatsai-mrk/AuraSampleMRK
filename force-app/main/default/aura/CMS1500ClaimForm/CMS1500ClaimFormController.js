({
    doInit : function(component, event, helper) {
        component.set("v.mapOfPointerAndICD",{});
        component.set("v.mapOfchildIndexAndFilledPointers",{});
        
        console.log('careBillingProviderCMS***',component.get("v.careBillingProviderCMS"));
        console.log('careServiceProviderCMS***',component.get("v.careServiceProviderCMS"));
        console.log('careRenderingProviderCMS***',component.get("v.careRenderingProviderCMS"));
        
        if(component.get("v.careServiceProviderCMS") == undefined){
            component.set("v.careServiceProviderCMS",'');
        }
        if(component.get("v.careBillingProviderCMS") == undefined){
            component.set("v.careBillingProviderCMS",'');
        }
        if(component.get("v.careRenderingProviderCMS") == undefined){
            component.set("v.careRenderingProviderCMS",'');
        }
        
        var billingProvider = component.get("v.careBillingProviderCMS");
        var serviceProvider = component.get("v.careServiceProviderCMS");
        var renderingProvider = component.get("v.careRenderingProviderCMS");
        console.log('billingProvider7***',billingProvider);
        
        if ($A.util.isUndefinedOrNull(component.get('v.transactionaljsonList')) || $A.util.isEmpty(component.get('v.transactionaljsonList'))){
            //   console.log('bwd' , component.get("v.transactionaljsonList"));
            //  component.set("v.noData", false);
        }
        //   alert(component.get("v.patId"));
        var nameSpace = 'ElixirSuite__';
        var newData = {};
        newData['Name'] = '';
        newData[nameSpace + 'Insurance_Type__c'] = '' ;
        newData[nameSpace + 'Additional_Claim_Information__c'] = '' ;
        newData[nameSpace + 'Amount_Paid__c'] = '' ;
        newData[nameSpace + 'Federal_Tax_Id_Number__c'] = '' ;
        newData[nameSpace + 'Insurance_Plan_Name__c'] = '' ;
        newData[nameSpace + 'Other_Insurance_Plan_Name__c'] = '' ;
        newData[nameSpace + 'Insured_Authorized_Person_Signature__c'] = '' ;
        newData[nameSpace + 'Insured_Address__c'] = '' ;
        newData[nameSpace + 'Insured_City__c'] = '' ;
        newData[nameSpace + 'Insured_DOB__c'] = '' ;
        newData[nameSpace + 'Insured_Policy__c'] = '' ;
        newData[nameSpace + 'Insured_Sex__c'] = '' ;
        newData[nameSpace + 'Insured_State__c'] = '' ;
        newData[nameSpace + 'Insured_Telephone__c'] = '' ;
        newData[nameSpace + 'Insured_Zipcode__c'] = '' ;
        newData[nameSpace + 'Insured_s_Name__c'] = '' ;
        newData[nameSpace + 'Insured_s_ID_Number__c'] = '' ;
        newData[nameSpace + 'Name_of_referring_provider_Other_sourc__c'] = '' ;
        newData[nameSpace + 'Other_Claim_Id__c'] = '' ;
        newData[nameSpace + 'Other_Insured_s_Name__c'] = '' ;
        newData[nameSpace + 'Other_Insured_s_Policy_Group_Number__c'] = '' ;
        newData[nameSpace + 'Patient_Relationship_to_Insured__c'] = '' ;
        newData[nameSpace + 'Patient_DOB__c'] = '' ;
        newData[nameSpace + 'Patient_Name__c'] = '' ;
        newData[nameSpace + 'Patient_Sex__c'] = '' ;
        newData[nameSpace + 'Patient_Name__c'] = '' ;
        newData[nameSpace + 'Patient_Signature__c'] = '' ;
        newData[nameSpace + 'Patient_s_Account_Number__c'] = '' ;
        newData[nameSpace + 'Prior_Authorization_Number__c'] = '' ;
        newData[nameSpace + 'Service_Facility_Location_Information__c'] = '' ;
        newData[nameSpace + 'Total_Charge__c'] = '' ;
        newData[nameSpace + 'Patient_s_Phone__c'] = '' ;
        component.set("v.newData",JSON.stringify(newData));
        component.set("v.loaded",false); // xxx 
        var action = component.get("c.getAccountDetails");
        console.log('action log' +action);
        var vobId = '';
        if(!$A.util.isEmpty(component.get('v.selectedVOBList'))){
            vobId = component.get('v.selectedVOBList')[0].Id;
            console.log('vobId' +vobId);
        }
        //   alert('vobId '+vobId);
        console.log('bew', component.get("v.patId"));
        action.setParams({
            "patientId": component.get("v.patId"),
            "vobId" : vobId
        });
        
        action.setCallback(this, function (response) {
            var res = response.getReturnValue();
            var state = response.getState();
            console.log('action state' +state);
            if (state === "SUCCESS") {
                console.log('perm success' +state);
                component.set("v.loaded",true); // xxx 
                var dischargeDate = '';
                var admitDate = '';
                component.set("v.plugData",response.getReturnValue().plugDataPresent);
                if(res.patientDecision=='Inpatient'){ // xxx
                    dischargeDate = res.accDetails.ElixirSuite__dischargeDateNew__c ; 
                    admitDate  = res.accDetails.ElixirSuite__Admit_Date__c; 
                    component.set("v.isInpatient",true); 
                }
                
                helper.buildDataForProcedure(component, event, helper,res.acctRelatedProcData);
                component.set("v.StatesPicklistVal",helper.CreateAmericaStatesJSON(component, event, helper));
                helper.CreateStatesAndItsShotforms(component, event, helper) //Anusha - 07/11/22
                var allFieldList = res.mapOfNameToField;
                var allFieldListInsType = res.mapOfNameToFieldInsType;
                var allAccFieldList = res.mapOfNameToFieldAcc;
                var accountDetails = res.accDetails ;
                var transactionalData = res.vobData ;
                var claimField = res.claimFields ;
                console.log('transactionalData'+JSON.stringify(transactionalData));
                if ($A.util.isUndefinedOrNull(res.vobData) || $A.util.isEmpty(res.vobData)){
                    res.vobData = ' ' ; 
                }
                
                if (!($A.util.isUndefinedOrNull(res.vobData[0].ElixirSuite__Is_there_another_Health_Benefit_Plan__c)) || !($A.util.isEmpty(res.vobData[0].ElixirSuite__Is_there_another_Health_Benefit_Plan__c)))
                {
                    if(res.vobData[0].ElixirSuite__Is_there_another_Health_Benefit_Plan__c == 'NO')
                    {
                        component.set("v.enableSecInsurance",true);
                    }
                    else if(res.vobData[0].ElixirSuite__Is_there_another_Health_Benefit_Plan__c == 'YES')
                    {
                        component.set("v.enableSecInsurance",false);
                    }
                }
                if (!($A.util.isUndefinedOrNull(res.vobData[0].ElixirSuite__Payer__r.ElixirSuite__Claim_Processing_via__c)) || !($A.util.isEmpty(res.vobData[0].ElixirSuite__Payer__r.ElixirSuite__Claim_Processing_via__c)))
                {
                    if(res.vobData[0].ElixirSuite__Payer__r.ElixirSuite__Claim_Processing_via__c == '837/835 EDI Conversion')
                    {
                        component.set("v.claimProcessedVia",true);
                        console.log('claimProcessedVia '+component.get("v.claimProcessedVia"));
                    }else{
                        component.set("v.claimProcessedVia",false); 
                        console.log('claimProcessedVia '+component.get("v.claimProcessedVia"));
                    }   
                }
                console.log('chk');
                // console.log('Claim_Processing '+JSON.stringify(res.vobData[0].ElixirSuite__Payer__r.ElixirSuite__Claim_Processing_via__c));
                var PName = res.accDetails.Name;
                var array=[];
                array = PName.split(' ');
                let fName = '';
                let lName = '';
                if(res.accDetails.hasOwnProperty('ElixirSuite__First_Name__c')){
                    fName = res.accDetails.ElixirSuite__First_Name__c; 
                }
                if(res.accDetails.hasOwnProperty('ElixirSuite__Last_Name__c')){
                    lName = res.accDetails.ElixirSuite__Last_Name__c; 
                }
                component.set("v.commaSeparatedName",lName+','+fName);
                
                
                
                let insFName = '';
                let insLName = '';
                let insMName = '';
                if(res.vobData[0].hasOwnProperty('ElixirSuite__Insured_First_Name__c')){
                    console.log('1st name'+res.vobData[0].ElixirSuite__Insured_First_Name__c);
                    insFName =  res.vobData[0].ElixirSuite__Insured_First_Name__c;
                }
                if(res.vobData[0].hasOwnProperty('ElixirSuite__Insured_Middle_Name__c')){
                    console.log('mID name'+res.vobData[0].ElixirSuite__Insured_Middle_Name__c);
                    insMName = res.vobData[0].ElixirSuite__Insured_Middle_Name__c;
                }
                if(res.vobData[0].hasOwnProperty('ElixirSuite__Insured_Last_Name__c')){
                    console.log('Last name'+res.vobData[0].ElixirSuite__Insured_Last_Name__c);
                    insLName = res.vobData[0].ElixirSuite__Insured_Last_Name__c;
                }
                component.set("v.commaSeparInsudName",insLName+','+insFName+','+insMName);
                var insuranceTypePicklistValues = [];
                var medicareTypeCodePicklistValues = [];
                for (var outerKey in allFieldListInsType) {
                    if (outerKey.toUpperCase() == (nameSpace + 'Insurance_Type__c').toUpperCase()) {
                        var innerMap = allFieldListInsType[outerKey];
                        for (var innerKey in innerMap) {
                            var picklistValue = {
                                label: innerKey,
                                value: innerMap[innerKey]
                            };
                            insuranceTypePicklistValues.push(picklistValue);
                        }
                        component.set("v.insuranceTypePicklistValues", insuranceTypePicklistValues);
                    }
                    if (outerKey.toUpperCase() == (nameSpace + 'Medicare_Type_Code__c').toUpperCase()) {
                        var innerMap = allFieldListInsType[outerKey];
                        for (var innerKey in innerMap) {
                            var picklistValue = {
                                label: innerKey,
                                value: innerMap[innerKey]
                            };
                            medicareTypeCodePicklistValues.push(picklistValue);
                        }
                        component.set("v.medicareTypeCodePicklistValues", medicareTypeCodePicklistValues);
                    }
                }
                for(var keyInside in allFieldList){
                    if(keyInside.toUpperCase() == (nameSpace + 'Patient_Relationship_With_Insured__c').toUpperCase()){
                        component.set("v.relationshipTypePicklistValues",allFieldList[keyInside]);
                    }
                    else if(keyInside.toUpperCase() == (nameSpace + 'Employment__c').toUpperCase()){
                        component.set("v.employmentPicklistValues",allFieldList[keyInside]);
                    }
                        else if(keyInside.toUpperCase() == (nameSpace + 'Auto_accident__c').toUpperCase()){
                            component.set("v.autoAccidentPicklistValues",allFieldList[keyInside]);
                            //  console.log('autoAccidentPicklistValues'+ autoAccidentPicklistValues);
                        }
                            else if(keyInside.toUpperCase() == (nameSpace + 'Other_Accident__c').toUpperCase()){
                                component.set("v.otherAccidentPicklistValues",allFieldList[keyInside]);
                            }
                                else if(keyInside.toUpperCase() == (nameSpace + 'Is_there_another_Health_Benefit_Plan__c').toUpperCase()){
                                    component.set("v.otherHealthBenefitPicklistValues",allFieldList[keyInside]);
                                }
                                    else if(keyInside.toUpperCase() == ('ElixirSuite__Gender__c').toUpperCase()){
                                        component.set("v.InsuregenderPicklistValues",allFieldList[keyInside]);
                                    }
                                        else if(keyInside.toUpperCase() == ('ElixirSuite__Accept_Asignment__c').toUpperCase()){
                                            component.set("v.AccptAssPicklistValues",allFieldList[keyInside]);
                                        }
                                            else if(keyInside.toUpperCase() == ('ElixirSuite__Federal_Tax_ID_Number__c').toUpperCase()){
                                                component.set("v.federalPicklistValues",allFieldList[keyInside]);
                                            }
                    
                }
                console.log('insuranceTypePicklistValues@@'+JSON.stringify(component.get("v.insuranceTypePicklistValues")));
                for(var keyInside in allAccFieldList){
                    if(keyInside.toUpperCase() == ('ElixirSuite__Gender__c').toUpperCase()){
                        component.set("v.genderPicklistValues",allFieldList[keyInside]);
                    }
                }
                var jsonList = [];
                var insideJson = {};
                var completeJson = [];
                
                var isurancePlanName = '';
                if(!$A.util.isUndefinedOrNull(res.relatedResult)){
                    let resultArr = res.relatedResult;
                    if(!$A.util.isEmpty(resultArr)){
                        isurancePlanName = resultArr[0].ElixirSuite__Insurance_Plan__c;
                        console.log('result '+JSON.stringify(resultArr[0]));
                    }
                }
                
                if (!$A.util.isUndefinedOrNull(res.claimCustomSettingValues.ElixirSuite__Employment__c) || !$A.util.isEmpty(res.claimCustomSettingValues.ElixirSuite__Employment__c)){
                    var employmentU = res.claimCustomSettingValues.ElixirSuite__Employment__c.toUpperCase();
                    component.set("v.isEmployement",employmentU);  
                }else{
                    component.set("v.isEmployement",'NO');
                }
                if (!$A.util.isUndefinedOrNull(res.claimCustomSettingValues.ElixirSuite__Auto_Accident__c) || !$A.util.isEmpty(res.claimCustomSettingValues.ElixirSuite__Auto_Accident__c)){
                    var autoAccidentU = res.claimCustomSettingValues.ElixirSuite__Auto_Accident__c.toUpperCase();
                    component.set("v.isAutoAccident",autoAccidentU);  
                }else{
                    component.set("v.isAutoAccident",'NO');
                }
                if (!$A.util.isUndefinedOrNull(res.claimCustomSettingValues.ElixirSuite__Other_Accident__c) || !$A.util.isEmpty(res.claimCustomSettingValues.ElixirSuite__Other_Accident__c)){
                    var otherAccidentU = res.claimCustomSettingValues.ElixirSuite__Other_Accident__c.toUpperCase();
                    component.set("v.isOtherAccident",otherAccidentU);
                }else{
                    component.set("v.isOtherAccident",'NO');
                }
                insideJson = {"id" : res.accDetails.Id,
                              "patientName" : res.accDetails.Name ,
                              "patientDOB" : res.accDetails.ElixirSuite__DOB__c , //replaced ElixirSuite__Patient_s_Birth_Date__c with ElixirSuite__DOB__c by Anusha - 09/01/23
                              "patiSex" :res.accDetails.ElixirSuite__Gender__c === 'F' ? 'Female' : (res.accDetails.ElixirSuite__Gender__c === 'M' ? 'Male' : 'Unknown') ,
                              "insuredSex" :  res.vobData[0].ElixirSuite__Gender__c === 'M' ? 'Male' : (res.vobData[0].ElixirSuite__Gender__c === 'F' ? 'Female' : 'Unknown'), 
                              "patientAddress" : res.accDetails.BillingStreet ,
"patientAddress2" : '',
                              "patientCity" : res.accDetails.BillingCity ,
                              "patientState" : component.get("v.StatesAndItsShotforms")[res.accDetails.BillingState], //Anusha - 07/11/22
                              "patientZipcode" : res.accDetails.BillingPostalCode,
                              //"patientCountry" : res.accDetails.BillingCountry,
                              "patientPhone" : res.accDetails.Phone ,
                              "insuranceType": res.vobData[0].ElixirSuite__Insurance_Type__c,
                              "medicareTypeCode": ((res.vobData[0].ElixirSuite__Insurance_Type__c === 'MA' || res.vobData[0].ElixirSuite__Insurance_Type__c === 'MB') ? res.vobData[0].ElixirSuite__Medicare_Type_Code__c || '' : ''),
                              "relationWithInsured" : res.vobData[0].ElixirSuite__Patient_Relationship_With_Insured__c ,
                              "insuredIdNumber" : res.vobData[0].ElixirSuite__Member_Id__c ,
                              "insuredName" :  insFName+' '+insMName+' '+insLName, //res.vobData[0].ElixirSuite__Insured_First_Name__c,
                              "autoAccidentPicklistValues" : res.claimCustomSettingValues.ElixirSuite__Auto_Accident__c==null? 'No':res.claimCustomSettingValues.ElixirSuite__Auto_Accident__c, //Anusha
                              "employmentPicklistValues" : res.claimCustomSettingValues.ElixirSuite__Employment__c==null? 'No':res.claimCustomSettingValues.ElixirSuite__Employment__c, //Anusha
                              "IsthereanotherHealthBenefitPlan" : '',//res.vobData[0].ElixirSuite__Is_there_another_Health_Benefit_Plan__c,
                              "otherAccidentPicklistValues" : res.claimCustomSettingValues.ElixirSuite__Other_Accident__c==null? 'No':res.claimCustomSettingValues.ElixirSuite__Other_Accident__c, //Anusha
                              "insurancePlanName" : res.vobData[0].ElixirSuite__Insurance_Plan_Name__c,
                              "reserverdforNUCCuse1" : '' ,                    
                              "reserverdforNUCCuse2" : '' ,
                              "reservedforNUCCuse3" : '',
                              "reservedforNUCCuse4" : '',
                              "otherClaimId" : '',
                              "careId" : component.get("v.careIdCMS"),
                              "dateOfCurrentIllness" : '',
                              "qualifierForDateOfCurrentIllness_Value" : '', // xxx
                              "qualifierForOtherDates_Value" : '',//xxx
                              "npi_nucc_Value" : '', //xxx
                              "npi_nucc_description_Value" : '', //xxx
                              
                              "diagnosis_A" : '',
                              "diagnosis_B" : '',
                              "diagnosis_C" : '',
                              "diagnosis_D" : '',
                              "diagnosis_E" : '',
                              "diagnosis_F" : '',
                              "diagnosis_G" : '',
                              "diagnosis_H" : '',
                              "diagnosis_I" : '',
                              "diagnosis_J" : '',
                              "diagnosis_K" : '',  
                              "diagnosis_L" : '',
                              
                              "orignalRefNumber" : '',
                              "priorAuthNumber" : component.get("v.preAuthNumCMS"),
                              "otherDate": '',
                              "otherDate_InsuredPersonAuth" : '',
                              "datesPatientUnableTowork" : '',
                              "nameOfReferringProvider" :'',
                              "nameOfReferringProvider_FirstName" : '',
                              "nameOfReferringProvider_MiddleName" : '',
                              "nameOfReferringProvider_LastName" : '',
                              "qualifierForNameOfReferringProvider" : '',
                              "NPI" : '',
                              "hospitilizationDates": '',
                              "additionalInfo" : '',
                              "outsideLab" : false,
                              "outsideLabNo" : false,
                              "federalTaxNumber" :billingProvider.ElixirSuite__Provider_Tax_Id__c,// res.claimCustomSettingValues.ElixirSuite__Federal_Tax_Id_Number__c, //Anusha
                              "federalSsnEsnPick":billingProvider.ElixirSuite__Tax_Id_Type__c,//res.vobData[0].ElixirSuite__Federal_Tax_ID_Number__c, 
                              "acceptAssignment": res.claimCustomSettingValues.ElixirSuite__Accept_Assignment__c==null? 'No':res.claimCustomSettingValues.ElixirSuite__Accept_Assignment__c, //Anusha
                              "amountPaid" : 0,
                              "billingProviderInfoNpi" : billingProvider.ElixirSuite__Provider_Code__c,//res.claimCustomSettingValues.ElixirSuite__Billing_Provider_NPI__c, //Anusha
                              "serviceFacilityLocationInfo" : serviceProvider.Name, //Anusha
                              "serviceFacilityLocationInfoID" : serviceProvider.ElixirSuite__Provider_Tax_Id__c, //jami
                              "serviceFacilityLocationInfoNPI" : serviceProvider.ElixirSuite__Provider_Code__c, //jami
                              "serviceFacilityLocationAddress" : serviceProvider.ElixirSuite__Address__c,
                              "serviceFacilityLocationAddress2" : serviceProvider.ElixirSuite__Address_2__c,
                              "serviceFacilityLocationCity" : serviceProvider.ElixirSuite__Provider_City__c,
                              "serviceFacilityLocationState" : serviceProvider.ElixirSuite__Provider_State__c,
                              "serviceFacilityLocationZip" : serviceProvider.ElixirSuite__Provider_Zip__c,
                              "fromdatesPatientUnableTowork" : '',
                              "todatesPatientUnableTowork" : '',
                              "billingProviderInfo" : '',//res.claimCustomSettingValues.ElixirSuite__Billing_Provider_NPI__c,
                              "billingProviderInfoID" : '',
                              "billingProviderName": billingProvider.Name,//res.claimCustomSettingValues.ElixirSuite__Billing_Provider_Name__c, //Anusha - Start- 07/11/22
                              "billingProviderAddress1": billingProvider.ElixirSuite__Address__c,//res.claimCustomSettingValues.ElixirSuite__Billing_Provider_Address__c,
                              "billingProviderAddress2": billingProvider.ElixirSuite__Address_2__c,
                              "billingProviderCity": billingProvider.ElixirSuite__Provider_City__c,//res.claimCustomSettingValues.ElixirSuite__Billing_Provider_City__c,
                              "billingProviderState": billingProvider.ElixirSuite__Provider_State__c,//res.claimCustomSettingValues.ElixirSuite__Billing_Provider_State__c,
                              "billingProviderzipCode": billingProvider.ElixirSuite__Provider_Zip__c,//res.claimCustomSettingValues.ElixirSuite__Billing_Provider_Zipcode__c,
                              "billingProviderPhone": billingProvider.ElixirSuite__Provider_Phone__c,
                              "billingProviderTaxId": billingProvider.ElixirSuite__Provider_Tax_Id__c,
                              "billingProviderTaxonomy": billingProvider.ElixirSuite__Provider_Taxonomy__c,//res.claimCustomSettingValues.ElixirSuite__Billing_Provider_Tax_ID__c, //Anusha - End- 07/11/22
                              "signOfPhysician" : '',
                              "DateOfsignOfPhysician" : '',
                              "DiagnoNatureOfIllness" : '',
                              "SupsignOfPhysician" : '',
                              "ResubmissionCode" : '',
                              "AuthorizationNum" : '',
                              "PatientAccNo" : res.accDetails.ElixirSuite__Account_Number__c, //added by Ashwini
                              "claimCodes" :'',
                              "insuredAddress" : res.vobData[0].ElixirSuite__Insured_Address__c,
"insuredAddress2" : '',
                              "insuredState" :  component.get("v.StatesAndItsShotforms")[res.vobData[0].ElixirSuite__Insured_State__c], //Anusha
                              "insuredCity" : res.vobData[0].ElixirSuite__Insured_City__c ,
                              "insuredZipcode" : res.vobData[0].ElixirSuite__Insured_Zipcode__c, //added res.vobData[0].ElixirSuite__Insured_Zipcode__c by Anusha
                              "insuredCountry" : res.vobData[0].ElixirSuite__Insured_Country__c, //Anusha
                              "insuredTelephone" :  res.vobData[0].ElixirSuite__InsPhone__c, //added res.vobData[0].ElixirSuite__InsPhone__c by Anusha
                              "otherInsuredPolicyNumber" : 	res.vobData[0].ElixirSuite__Other_Insured_Policy_Group_FECA_Number__c,
                              "insuredPolicyNumber" : 	res.vobData[0].ElixirSuite__Insured_Policy_Group_FECA_Number__c,
                              "insuredDOB" : res.vobData[0].ElixirSuite__Date_Of_Birth__c, 
                              "insuredId" : res.vobData[0].Id, //Anusha
                              "autoAccPlaceOrState" : '',
                              "autoAccPlaceOrStateDisabled" : false,
                              "otherInsuredName" : res.vobData[0].ElixirSuite__Other_Insured_s_Name__c,
                              "otherInsurancePlanName" : res.vobData[0].ElixirSuite__OtherInsurancePlanName__c,
                              "billingProviderInfoOtherId" : '',
                              "hospitalisedFromDate" : admitDate,  
                              "hospitalisedToDate" : dischargeDate,
                              "outsideLabcharges" : 0, // xxx
                              "patientSign" : '',
                              "insuredSign" : '',
                              "TotalCharges" : 0,
                              "RenderingProvider_FirstName":renderingProvider.FirstName,
                              "RenderingProvider_MiddleName":renderingProvider.MiddleName,
                              "RenderingProvider_LastName":renderingProvider.LastName,
                              "RenderingProvider_Taxonomy":renderingProvider.ElixirSuite__Taxonomy__c,
                              "RenderingProvider_NPI":renderingProvider.ElixirSuite__Practitioner_NPI__c,
                              "RenderingProvider_TaxId":renderingProvider.ElixirSuite__Tax_Id__c
                             }
                if(res.territory){
                    insideJson['patientCountry'] = res.accDetails.BillingCountryCode;  
                }else{
                    insideJson['patientCountry'] = res.accDetails.BillingCountry;
                }
                if(insideJson.IsthereanotherHealthBenefitPlan == "NO"){
                    insideJson['otherInsuredName'] = '';
                    insideJson['otherInsuredPolicyNumber'] = '';
                    insideJson['reserverdforNUCCuse2'] = '';
                    insideJson['reservedforNUCCuse3'] = '';
                    insideJson['otherInsurancePlanName'] = '';
                }
                
                //console.log('fj' , insideJson);
                completeJson.push(insideJson);
                var rec ={};
                rec = {"id" : res.accDetails.Id,
                       "transactionalDataId": res.vobData[0].Id,
                       "Record" : JSON.parse(JSON.stringify(completeJson))
                      };
                jsonList.push(rec);
                
                
                component.set("v.jsonList",JSON.parse(JSON.stringify(jsonList)));
                component.set("v.transactionalDataId" ,res.vobData[0].Id );
                console.log('fnj' , JSON.stringify(component.get("v.jsonList")));
                /**********MY UPDATES ************************/
                var picklistArr = res.allPickListPlaceOfService_ValuesIntoList;
                console.log('picklistArr'+JSON.stringify(picklistArr));
                
                var arrToSet = [];
                for(let rec in picklistArr){
                    var arr = picklistArr[rec].split('-');
                    let textName = arr[arr.length - 1];
                    let codeArr = [];
                    for(let child in arr){
                        if(child<arr.length - 1){
                            codeArr.push(arr[child]); 
                        }
                    }
                    var toSetValue = textName+';'+codeArr.join('-');
                    console.log('toSetValue '+toSetValue);
                    
                    var sObj = {'label' : picklistArr[rec],'value' : toSetValue};
                    arrToSet.push(sObj);
                }
                component.set("v.placeOfServiceArray",arrToSet);
                console.log('arrToSet'+JSON.stringify(arrToSet));
                //   alert('to set val ' , JSON.stringify(component.get("v.placeOfServiceArray")));
                helper.buildPicklistWrapperForClaimFields(component, event,helper);
                if(!res.isVobPresent){ // xxx
                    helper.flagNoVOB(component, event, helper);
                    console.log('sivaif');
                }
                else {
                    helper.populateVOBDetails(component, event, helper,res.vobData);
                    console.log('sivaelse');
                }
                
                /********************************************/
                component.set("v.loaded",true);
                // alert('ins name set last '+ component.get("v.commaSeparInsudName"));
            }
            
            else if (state === "ERROR") {
                console.log('perm error' +state);
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
        component.set("v.dropDownOptions",[]);
        component.set("v.dropDownSelectedValues",[]);
        component.set('v.searchString','');
        component.set('v.isdisAbled',false);
        helper.fetchDropdownValues(component);
    },
    otherSame :  function(component, event, helper) {  
        var parentJSON =  component.get("v.jsonList");
        
        
    },
    blockSpecialCharacters :  function(component, event, helper) {   
        var val = event.getSource().get("v.value");     
        var name = event.getSource().get("v.name");
        var array = name.split('$');
        var parentIndex = array[0];
        var childIndex = array[1];
        var inputCmp = component.find("resSubcode");
        let regex = /^[a-zA-Z0-9_]*$/
        if(val){
            component.set("v.isAddClaimEnabled",false);            
            if(Array.isArray(inputCmp)){   
                if(!regex.test(event.getSource().get("v.value"))) {
                    inputCmp[childIndex].setCustomValidity("Special characters not allowed!"); 
                    component.set("v.isAddClaimEnabled",true); 
                }
                else {
                    inputCmp[childIndex].setCustomValidity("");   
                    component.set("v.isAddClaimEnabled",false); 
                }
                inputCmp[childIndex].reportValidity(); 
                
            }
            else {
                if(!regex.test(event.getSource().get("v.value"))) {
                    inputCmp.setCustomValidity("Special characters not allowed!");
                    component.set("v.isAddClaimEnabled",true); 
                }
                else {
                    inputCmp.setCustomValidity("");
                    component.set("v.isAddClaimEnabled",false); 
                }
                inputCmp.reportValidity(); 
            }
        }
        else {
            if(Array.isArray(inputCmp)){   
                inputCmp[childIndex].setCustomValidity("");   
                component.set("v.isAddClaimEnabled",false); 
                inputCmp[childIndex].reportValidity(); 
            }
            else {
                inputCmp.setCustomValidity("");
                component.set("v.isAddClaimEnabled",false); 
                inputCmp.reportValidity(); 
            }
        }
        
    },
    allowOnlyNumbers_AmountPaid : function(component, event, helper) {
        var val = event.getSource().get("v.value");
        var regex = /^[0-9]*\.?[0-9]*$/;
        //  var valid_dollar_amt_regex = /^[0-9]*\.?[0-9]*$/;
        var name = event.getSource().get("v.name");
        var array = name.split('$');
        var parentIndex = array[0];
        var childIndex = array[1];
        var inputCmp = component.find("patientAmtPaid"); 
        if(val){
            component.set("v.isAddClaimEnabled",false);
            
            if(Array.isArray(inputCmp)){   
                if(!regex.test(event.getSource().get("v.value"))) {
                    inputCmp[childIndex].setCustomValidity("Only 1-9 characters are allowed!"); 
                    component.set("v.isAddClaimEnabled",true); 
                }
                else {
                    inputCmp[childIndex].setCustomValidity("");   
                    component.set("v.isAddClaimEnabled",false); 
                }
                inputCmp[childIndex].reportValidity(); 
                
            }
            else {
                if(!regex.test(event.getSource().get("v.value"))) {
                    inputCmp.setCustomValidity("Only 1-9 characters are allowed!");
                    component.set("v.isAddClaimEnabled",true); 
                }
                else {
                    inputCmp.setCustomValidity("");
                    component.set("v.isAddClaimEnabled",false); 
                }
                inputCmp.reportValidity(); 
            }
        }
        else {
            if(Array.isArray(inputCmp)){   
                inputCmp[childIndex].setCustomValidity("");   
                component.set("v.isAddClaimEnabled",false); 
                inputCmp[childIndex].reportValidity(); 
            }
            else {
                inputCmp.setCustomValidity("");
                component.set("v.isAddClaimEnabled",false); 
                inputCmp.reportValidity(); 
            }
        }
    },
    allowOnlyNumbers_PatientAccount :  function(component, event, helper) {
        var val = event.getSource().get("v.value");
        var regex = /^[0-9]*$/;
        var name = event.getSource().get("v.name");
        var array = name.split('$');
        var parentIndex = array[0];
        var childIndex = array[1];
        var inputCmp = component.find("patientAccNum");
        if(val){
            component.set("v.isAddClaimEnabled",false);
            
            if(Array.isArray(inputCmp)){   
                if(!regex.test(event.getSource().get("v.value"))) {
                    inputCmp[childIndex].setCustomValidity("Only 1-9 characters are allowed!"); 
                    component.set("v.isAddClaimEnabled",true); 
                }
                else {
                    inputCmp[childIndex].setCustomValidity("");   
                    component.set("v.isAddClaimEnabled",false); 
                }
                inputCmp[childIndex].reportValidity(); 
                
            }
            else {
                if(!regex.test(event.getSource().get("v.value"))) {
                    inputCmp.setCustomValidity("Only 1-9 characters are allowed!");
                    component.set("v.isAddClaimEnabled",true); 
                }
                else {
                    inputCmp.setCustomValidity("");
                    component.set("v.isAddClaimEnabled",false); 
                }
                inputCmp.reportValidity(); 
            }
        }
        else {
            if(Array.isArray(inputCmp)){   
                inputCmp[childIndex].setCustomValidity("");   
                component.set("v.isAddClaimEnabled",false); 
                inputCmp[childIndex].reportValidity(); 
            }
            else {
                inputCmp.setCustomValidity("");
                component.set("v.isAddClaimEnabled",false); 
                inputCmp.reportValidity(); 
            }
        }
    },
    allowOnlyNumbers_OutsideCharges :  function(component, event, helper) {
        var val = event.getSource().get("v.value");
        var regex = /^[0-9]*$/;
        var name = event.getSource().get("v.name");
        var array = name.split('$');
        var parentIndex = array[0];
        var childIndex = array[1];
        var inputCmp = component.find("fedTaxNum");
        if(val){
            component.set("v.isAddClaimEnabled",false);
            
            if(Array.isArray(inputCmp)){   
                if(!regex.test(event.getSource().get("v.value"))) {
                    inputCmp[childIndex].setCustomValidity("Only 1-9 characters are allowed!"); 
                    component.set("v.isAddClaimEnabled",true); 
                }
                else {
                    inputCmp[childIndex].setCustomValidity("");   
                    component.set("v.isAddClaimEnabled",false); 
                }
                inputCmp[childIndex].reportValidity(); 
                
            }
            else {
                if(!regex.test(event.getSource().get("v.value"))) {
                    inputCmp.setCustomValidity("Only 1-9 characters are allowed!");
                    component.set("v.isAddClaimEnabled",true); 
                }
                else {
                    inputCmp.setCustomValidity("");
                    component.set("v.isAddClaimEnabled",false); 
                }
                inputCmp.reportValidity(); 
            }
        }
        else {
            if(Array.isArray(inputCmp)){   
                inputCmp[childIndex].setCustomValidity("");   
                component.set("v.isAddClaimEnabled",false); 
                inputCmp[childIndex].reportValidity(); 
            }
            else {
                inputCmp.setCustomValidity("");
                component.set("v.isAddClaimEnabled",false); 
                inputCmp.reportValidity(); 
            }
        }
    },
    allowOnlyNumbers :  function(component, event, helper) {
        var val = event.getSource().get("v.value");
        var regex = /^[0-9]*$/;
        var name = event.getSource().get("v.name");
        var array = name.split('$');
        var parentIndex = array[0];
        var childIndex = array[1];
        var inputCmp = component.find("fedTaxNum");
        if(val){
            component.set("v.isAddClaimEnabled",false);
            
            if(Array.isArray(inputCmp)){   
                if(!regex.test(event.getSource().get("v.value"))) {
                    inputCmp[childIndex].setCustomValidity("Only 1-9 characters are allowed!"); 
                    component.set("v.isAddClaimEnabled",true); 
                }
                else {
                    inputCmp[childIndex].setCustomValidity("");   
                    component.set("v.isAddClaimEnabled",false); 
                }
                inputCmp[childIndex].reportValidity(); 
                
            }
            else {
                if(!regex.test(event.getSource().get("v.value"))) {
                    inputCmp.setCustomValidity("Only 1-9 characters are allowed!");
                    component.set("v.isAddClaimEnabled",true); 
                }
                else {
                    inputCmp.setCustomValidity("");
                    component.set("v.isAddClaimEnabled",false); 
                }
                inputCmp.reportValidity(); 
            }
        }
        else {
            if(Array.isArray(inputCmp)){   
                inputCmp[childIndex].setCustomValidity("");   
                component.set("v.isAddClaimEnabled",false); 
                inputCmp[childIndex].reportValidity(); 
            }
            else {
                inputCmp.setCustomValidity("");
                component.set("v.isAddClaimEnabled",false); 
                inputCmp.reportValidity(); 
            }
        }
    },
    validateSpecialCharactersForAdress : function(component, event, helper) {
        var val = event.getSource().get("v.value");
        var regex = /[^a-zA-Z\d\s:]/;
        var name = event.getSource().get("v.name");
        var array = name.split('$');
        var parentIndex = array[0];
        var childIndex = array[1];
        var inputCmp = component.find("patientAdress");
        if(val){
            component.set("v.isAddClaimEnabled",false);
            
            if(Array.isArray(inputCmp)){   
                if(regex.test(event.getSource().get("v.value"))) {
                    inputCmp[childIndex].setCustomValidity("Special characters not allowed!"); 
                    component.set("v.isAddClaimEnabled",true); 
                }
                else {
                    inputCmp[childIndex].setCustomValidity("");   
                    component.set("v.isAddClaimEnabled",false); 
                }
                inputCmp[childIndex].reportValidity(); 
                
            }
            else {
                if(regex.test(event.getSource().get("v.value"))) {
                    inputCmp.setCustomValidity("Special characters not allowed!");
                    component.set("v.isAddClaimEnabled",true); 
                }
                else {
                    inputCmp.setCustomValidity("");
                    component.set("v.isAddClaimEnabled",false); 
                }
                inputCmp.reportValidity(); 
            }
        }
        else {
            if(Array.isArray(inputCmp)){   
                inputCmp[childIndex].setCustomValidity("");   
                component.set("v.isAddClaimEnabled",false); 
                inputCmp[childIndex].reportValidity(); 
            }
            else {
                inputCmp.setCustomValidity("");
                component.set("v.isAddClaimEnabled",false); 
                inputCmp.reportValidity(); 
            }
        }
        
    },
    validateSpecialCharactersForAdress_serviceFacilityLocationInfo : function(component, event, helper) {
        var val = event.getSource().get("v.value");
        var regex = /[^a-zA-Z\d\s:]/;
        var name = event.getSource().get("v.name");
        var array = name.split('$');
        var parentIndex = array[0];
        var childIndex = array[1];
        var inputCmp = component.find("serviceFacilityLocationInfor_AuraId");
        if(val){
            component.set("v.isAddClaimEnabled",false);
            
            if(Array.isArray(inputCmp)){   
                if(regex.test(event.getSource().get("v.value"))) {
                    inputCmp[childIndex].setCustomValidity("Special characters not allowed!"); 
                    component.set("v.isAddClaimEnabled",true); 
                }
                else {
                    inputCmp[childIndex].setCustomValidity("");   
                    component.set("v.isAddClaimEnabled",false); 
                }
                inputCmp[childIndex].reportValidity(); 
                
            }
            else {
                if(regex.test(event.getSource().get("v.value"))) {
                    inputCmp.setCustomValidity("Special characters not allowed!");
                    component.set("v.isAddClaimEnabled",true); 
                }
                else {
                    inputCmp.setCustomValidity("");
                    component.set("v.isAddClaimEnabled",false); 
                }
                inputCmp.reportValidity(); 
            }
            component.set("v.isAddClaimEnabled",true); 
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "32b IS MANDATORY IF 32a IS FILLED!",
                "message": "Please fill 32A also!",
                "type" : "info"
            });
            toastEvent.fire();
            var parentJSON =  component.get("v.jsonList");
            if(parentJSON[parentIndex].Record[childIndex].serviceFacilityLocationInfoID){
                component.set("v.isAddClaimEnabled",false); 
            }
            
            
        }
        else {
            var parentJSON =  component.get("v.jsonList");
            parentJSON[parentIndex].Record[childIndex].serviceFacilityLocationInfoID = '';
            component.set("v.jsonList",parentJSON);
            if(Array.isArray(inputCmp)){   
                inputCmp[childIndex].setCustomValidity("");   
                component.set("v.isAddClaimEnabled",false); 
                inputCmp[childIndex].reportValidity(); 
            }
            else {
                inputCmp.setCustomValidity("");
                component.set("v.isAddClaimEnabled",false); 
                inputCmp.reportValidity(); 
            }
        }
        
        
    },
    enableForm : function(component, event, helper) {
        var val = event.getSource().get("v.value");
        if(val){
            component.set("v.isAddClaimEnabled",false); 
        }
    },
    validateSpecialCharactersForAdress_billingProviderInfo : function(component, event, helper) {
        var val = event.getSource().get("v.value");
        var regex = /[^a-zA-Z\d\s:]/;
        var name = event.getSource().get("v.name");
        var array = name.split('$');
        var parentIndex = array[0];
        var childIndex = array[1];
        var inputCmp = component.find("billingProviderInfo_AuraID");
        if(val){
            component.set("v.isAddClaimEnabled",false);
            
            if(Array.isArray(inputCmp)){   
                if(regex.test(event.getSource().get("v.value"))) {
                    inputCmp[childIndex].setCustomValidity("Special characters not allowed!"); 
                    component.set("v.isAddClaimEnabled",true); 
                }
                else {
                    inputCmp[childIndex].setCustomValidity("");   
                    component.set("v.isAddClaimEnabled",false); 
                }
                inputCmp[childIndex].reportValidity(); 
                
            }
            else {
                if(regex.test(event.getSource().get("v.value"))) {
                    inputCmp.setCustomValidity("Special characters not allowed!");
                    component.set("v.isAddClaimEnabled",true); 
                }
                else {
                    inputCmp.setCustomValidity("");
                    component.set("v.isAddClaimEnabled",false); 
                }
                inputCmp.reportValidity(); 
            }
        }
        else {
            if(Array.isArray(inputCmp)){   
                inputCmp[childIndex].setCustomValidity("");   
                component.set("v.isAddClaimEnabled",false); 
                inputCmp[childIndex].reportValidity(); 
            }
            else {
                inputCmp.setCustomValidity("");
                component.set("v.isAddClaimEnabled",false); 
                inputCmp.reportValidity(); 
            }
        }
        
    },
    validatePatientZip : function(component, event, helper) {
        var val = event.getSource().get("v.value");
        var regex = /[^a-zA-Z\d\s:]/;
        var name = event.getSource().get("v.name");
        var array = name.split('$');
        var parentIndex = array[0];
        var childIndex = array[1];
        var inputCmp = component.find("patientzip");
        if(val){
            if(val.length==5){
                if(Array.isArray(inputCmp)){   
                    inputCmp[childIndex].setCustomValidity("");   
                    component.set("v.isAddClaimEnabled",false); 
                    inputCmp[childIndex].reportValidity(); 
                }
                else {
                    inputCmp.setCustomValidity("");
                    component.set("v.isAddClaimEnabled",false); 
                    inputCmp.reportValidity(); 
                }
            }
            else if(val.length==9){
                if(Array.isArray(inputCmp)){   
                    if(val.includes('-')){
                        inputCmp[childIndex].setCustomValidity("Hyphen(-) not allowed!"); 
                        component.set("v.isAddClaimEnabled",true); 
                    }
                    else {
                        inputCmp[childIndex].setCustomValidity("");   
                        component.set("v.isAddClaimEnabled",false); 
                    }
                    inputCmp[childIndex].reportValidity(); 
                    
                }
                else {
                    if(val.includes('-')){
                        inputCmp.setCustomValidity("Hyphen(-) not allowed!");
                        component.set("v.isAddClaimEnabled",true); 
                    }
                    else {
                        inputCmp.setCustomValidity("");
                        component.set("v.isAddClaimEnabled",false); 
                    }
                    inputCmp.reportValidity(); 
                }
            }
                else {
                    var patZ = component.find("patientzip");
                    if(Array.isArray(patZ)){   
                        
                        patZ[childIndex].setCustomValidity("Zip can be either 5 or 9 digits only."); 
                        component.set("v.isAddClaimEnabled",true); 
                        
                        patZ[childIndex].reportValidity(); 
                        
                    }
                    else {
                        
                        patZ.setCustomValidity("Zip can be either 5 or 9 digits only.");
                        component.set("v.isAddClaimEnabled",true); 
                        
                        patZ.reportValidity(); 
                    }
                }
            
        }
        else {
            if(Array.isArray(inputCmp)){   
                inputCmp[childIndex].setCustomValidity("");   
                component.set("v.isAddClaimEnabled",false); 
                inputCmp[childIndex].reportValidity(); 
            }
            else {
                inputCmp.setCustomValidity("");
                component.set("v.isAddClaimEnabled",false); 
                inputCmp.reportValidity(); 
            }
        }
    },
    validatePhoneNumber : function(component, event, helper) {
        var val = event.getSource().get("v.value");
        var regex = /^[0-9]*$/;
        var name = event.getSource().get("v.name");
        var array = name.split('$');
        var parentIndex = array[0];
        var childIndex = array[1];
        var inputCmp = component.find("patientPhoneNumber_Patient"); 
        if(val){
            component.set("v.isAddClaimEnabled",false);
            
            if(Array.isArray(inputCmp)){   
                if(!regex.test(event.getSource().get("v.value"))) {
                    inputCmp[childIndex].setCustomValidity("Only 1-9 characters are allowed!"); 
                    component.set("v.isAddClaimEnabled",true); 
                }
                else {
                    inputCmp[childIndex].setCustomValidity("");   
                    component.set("v.isAddClaimEnabled",false); 
                }
                inputCmp[childIndex].reportValidity(); 
                
            }
            else {
                if(!regex.test(event.getSource().get("v.value"))) {
                    inputCmp.setCustomValidity("Only 1-9 characters are allowed!");
                    component.set("v.isAddClaimEnabled",true); 
                }
                else {
                    inputCmp.setCustomValidity("");
                    component.set("v.isAddClaimEnabled",false); 
                }
                inputCmp.reportValidity(); 
            }
        }
        else {
            if(Array.isArray(inputCmp)){   
                inputCmp[childIndex].setCustomValidity("");   
                component.set("v.isAddClaimEnabled",false); 
                inputCmp[childIndex].reportValidity(); 
            }
            else {
                inputCmp.setCustomValidity("");
                component.set("v.isAddClaimEnabled",false); 
                inputCmp.reportValidity(); 
            }
        }
    },
    validateInsuredZip : function(component, event, helper) {
        var val = event.getSource().get("v.value");
        var regex = /[^a-zA-Z\d\s:]/;
        var name = event.getSource().get("v.name");
        var array = name.split('$');
        var parentIndex = array[0];
        var childIndex = array[1];
        var inputCmp = component.find("insuredzip");
        if(val){
            if(val.length==5){
                if(Array.isArray(inputCmp)){   
                    inputCmp[childIndex].setCustomValidity("");   
                    component.set("v.isAddClaimEnabled",false); 
                    inputCmp[childIndex].reportValidity(); 
                }
                else {
                    inputCmp.setCustomValidity("");
                    component.set("v.isAddClaimEnabled",false); 
                    inputCmp.reportValidity(); 
                }
            }
            else if(val.length==9){
                if(Array.isArray(inputCmp)){   
                    if(val.includes('-')){
                        inputCmp[childIndex].setCustomValidity("Hyphen(-) not allowed!"); 
                        component.set("v.isAddClaimEnabled",true); 
                    }
                    else {
                        inputCmp[childIndex].setCustomValidity("");   
                        component.set("v.isAddClaimEnabled",false); 
                    }
                    inputCmp[childIndex].reportValidity(); 
                    
                }
                else {
                    if(val.includes('-')){
                        inputCmp.setCustomValidity("Hyphen(-) not allowed!");
                        component.set("v.isAddClaimEnabled",true); 
                    }
                    else {
                        inputCmp.setCustomValidity("");
                        component.set("v.isAddClaimEnabled",false); 
                    }
                    inputCmp.reportValidity(); 
                }
            }
                else {
                    var patZ = component.find("patientzip");
                    if(Array.isArray(patZ)){   
                        
                        patZ[childIndex].setCustomValidity("Zip can be either 5 or 9 digits only."); 
                        component.set("v.isAddClaimEnabled",true); 
                        
                        patZ[childIndex].reportValidity(); 
                        
                    }
                    else {
                        
                        patZ.setCustomValidity("Zip can be either 5 or 9 digits only.");
                        component.set("v.isAddClaimEnabled",true); 
                        
                        patZ.reportValidity(); 
                    }
                }
            
        }
        else {
            if(Array.isArray(inputCmp)){   
                inputCmp[childIndex].setCustomValidity("");   
                component.set("v.isAddClaimEnabled",false); 
                inputCmp[childIndex].reportValidity(); 
            }
            else {
                inputCmp.setCustomValidity("");
                component.set("v.isAddClaimEnabled",false); 
                inputCmp.reportValidity(); 
            }
        }
    },
    isDataFilled : function(component, event, helper) {
        var val = event.getSource().get("v.value");
        var regex = /\s/g;           
        var name = event.getSource().get("v.name");
        var array = name.split('$');
        var parentIndex = array[0];
        var childIndex = array[1];
        var inputCmp = component.find("insuredNumber");
        if(val){
            component.set("v.isAddClaimEnabled",false);
            
            if(Array.isArray(inputCmp)){   
                if(regex.test(event.getSource().get("v.value"))) {
                    inputCmp[childIndex].setCustomValidity("White characters not allowed!"); 
                    component.set("v.isAddClaimEnabled",true); 
                }
                else {
                    inputCmp[childIndex].setCustomValidity("");   
                    component.set("v.isAddClaimEnabled",false); 
                }
                inputCmp[childIndex].reportValidity(); 
                
            }
            else {
                if(regex.test(event.getSource().get("v.value"))) {
                    inputCmp.setCustomValidity("White characters not allowed!");
                    component.set("v.isAddClaimEnabled",true); 
                }
                else {
                    inputCmp.setCustomValidity("");
                    component.set("v.isAddClaimEnabled",false); 
                }
                inputCmp.reportValidity(); 
            }
        }
        else {
            if(Array.isArray(inputCmp)){   
                if(!val){
                    inputCmp[childIndex].setCustomValidity("INSURED'S ID NUMBER IS MANDATORY!!"); 
                    component.set("v.isAddClaimEnabled",true); 
                }
                else {
                    inputCmp[childIndex].setCustomValidity("");   
                    component.set("v.isAddClaimEnabled",false); 
                }
                inputCmp[childIndex].reportValidity(); 
                
            }
            else {
                if(!val){
                    inputCmp.setCustomValidity("INSURED'S ID NUMBER IS MANDATORY!!");
                    component.set("v.isAddClaimEnabled",true); 
                }
                else {
                    inputCmp.setCustomValidity("");
                    component.set("v.isAddClaimEnabled",false); 
                }
                inputCmp.reportValidity(); 
            }
            
            component.set("v.isAddClaimEnabled",true);
        }
    },
    radioCheckOne  : function(component, event, helper) {
        var abc=  component.get("v.jsonList");
        console.log(event.getSource().get("v.value"));
        var name = event.getSource().get("v.name");
        var array = name.split('$');
        var value = array[0];
        var field = array[1];
        
        var parentJSON =  component.get("v.jsonList");
        parentJSON[0].Record[0]['insuranceType'] = array[0];
        component.set("v.jsonList",parentJSON);
        
        
        var args = component.find("checkone");
        var args = component.find("checkone");
        for (var i = 0; i < args.length; i++) {
            var currentCheckbox = args[i];
            if (currentCheckbox.get("v.name").split('$')[0] != value) {             
                currentCheckbox.set("v.selected", false);
            }
        }
        /* for(var key in args){
            if(args[key].get("v.name").split('$')[0] != value){             
                args[key].set("v.selected",false);
            }
        }*/
        
    },
    
    radioCheckTwo  : function(component, event, helper) {
        console.log(event.getSource().get("v.value"));
        var name = event.getSource().get("v.name");
        var array = name.split('$');
        var value = array[0];
        var field = array[1];
        var parentJSON =  component.get("v.jsonList");
        parentJSON[0].Record[0]['patiSex'] = array[0];
        component.set("v.jsonList",parentJSON);
        var args2 = component.find("checkTwo");
        for(var key in args2){
            if(args2[key].get("v.name").split('$')[0] != value){             
                args2[key].set("v.checked",false);
            }
        }
    },
    
    radioCheckThree  : function(component, event, helper) {
        console.log('arrr' +event.getSource().get("v.value"));
        var name = event.getSource().get("v.name");
        var array = name.split('$');
        var value = array[0];
        var field = array[1];
        var parentJSON =  component.get("v.jsonList");
        parentJSON[0].Record[0]['relationWithInsured'] = array[0];
        component.set("v.jsonList",parentJSON);
        var args3 = component.find("checkThree");
        for (var i = 0; i < args3.length; i++) {
            var currentCheckbox = args3[i];
            if (currentCheckbox.get("v.name").split('$')[0] != value) {             
                currentCheckbox.set("v.selected", false);
            }
        }
        /* for(var key in args3){
            if(args3[key].get("v.name").split('$')[0] != value){             
                args3[key].set("v.selected",false);
            }
        }*/
        
    },
    
    radioCheckFour  : function(component, event, helper) {
        console.log(event.getSource().get("v.value"));
        var name = event.getSource().get("v.name");
        var array = name.split('$');
        var value = array[0];
        var field = array[1];
        var parentJSON =  component.get("v.jsonList");
        parentJSON[0].Record[0]['employment'] = array[0];
        component.set("v.jsonList",parentJSON);
        var args4 = component.find("checkFour");
        for(var key in args4){
            if(args4[key].get("v.name").split('$')[0] != value){             
                args4[key].set("v.checked",false);
            }
        }
    },
    
    radioCheckFive  : function(component, event, helper) {
        console.log('text val'+event.getSource().get("v.value"));
        console.log('checked '+event.getSource().get("v.checked"));
        var name = event.getSource().get("v.name");
        var array = name.split('$');
        var value = array[0];
        var field = array[1];
        
        if(value == 'YES')
        {
            console.log('yes');
            
            component.set("v.autoAccPlaceOrStateDisabled",false);
        }
        else if(value == 'NO')
        {
            console.log('No');
            var parentJSON =  component.get("v.jsonList");
            parentJSON[0].Record[0]['autoAccPlaceOrState'] = '';
            component.set("v.jsonList",parentJSON);
            component.set("v.autoAccPlaceOrStateDisabled",true);
        }
        
        var parentJSON =  component.get("v.jsonList");
        parentJSON[0].Record[0]['autoAccident'] = array[0];
        component.set("v.jsonList",parentJSON);
        
        
        var args5 = component.find("checkFive");
        for(var key in args5){
            if(args5[key].get("v.name").split('$')[0] != value){             
                args5[key].set("v.checked",false);
            }
        }
        /*   var jsn = component.get("v.jsonList");
        if(value=="NO"){          
            jsn[array[2]].Record[array[3]].autoAccPlaceOrStateDisabled = true;
        }
        else {
           jsn[array[2]].Record[array[3]].autoAccPlaceOrStateDisabled = false; 
        }
        component.set("v.jsonList",jsn);*/
    },
    
    radioCheckSix  : function(component, event, helper) {
        console.log(event.getSource().get("v.value"));
        var name = event.getSource().get("v.name");
        var array = name.split('$');
        var value = array[0];
        var field = array[1];
        
        var parentJSON =  component.get("v.jsonList");
        parentJSON[0].Record[0]['otherAccident'] = array[0];
        component.set("v.jsonList",parentJSON);
        
        var args6 = component.find("checkSix");
        for(var key in args6){
            if(args6[key].get("v.name").split('$')[0] != value){             
                args6[key].set("v.checked",false);
            }
        }
    },
    
    radioCheckSeven  : function(component, event, helper) {
        console.log(event.getSource().get("v.value"));
        var name = event.getSource().get("v.name");
        var array = name.split('$');
        var value = array[0];
        var field = array[1];
        var parentJSON =  component.get("v.jsonList");
        parentJSON[0].Record[0]['insuredSex'] = array[0];
        component.set("v.jsonList",parentJSON);
        
        var args7 = component.find("checkSeven");
        for(var key in args7){
            if(args7[key].get("v.name").split('$')[0] != value){             
                args7[key].set("v.checked",false);
            }
        }
        
    },
    
    radioCheckEight  : function(component, event, helper) {
        var name = event.getSource().get("v.name");
        var array = name.split('$');
        var value = array[0];
        var field = array[1];
        
        
        if(value == 'YES')
        {
            component.set("v.enableSecInsurance",false);
        }
        else if(value == 'NO')
        {
            component.set("v.enableSecInsurance",true);
        }
        
        var parentJSON =  component.get("v.jsonList");
        parentJSON[0].Record[0]['otherInsuredName'] = '';
        parentJSON[0].Record[0]['otherInsuredPolicyNumber'] = '';
        parentJSON[0].Record[0]['reserverdforNUCCuse2'] = '';
        parentJSON[0].Record[0]['reservedforNUCCuse3'] = '';
        parentJSON[0].Record[0]['otherInsurancePlanName'] = '';
        parentJSON[0].Record[0]['IsthereanotherHealthBenefitPlan'] = array[0];
        component.set("v.jsonList",parentJSON);
        
        
        
        var args8 = component.find("checkEight");
        for(var key in args8){
            if(args8[key].get("v.name").split('$')[0] != value){             
                args8[key].set("v.checked",false);
            }
        }
    },
    
    radioCheckNine  : function(component, event, helper) {
        console.log(event.getSource().get("v.value"));
        var name = event.getSource().get("v.name");
        var array = name.split('$');
        var value = array[0];
        var field = array[1];
        
        var parentJSON =  component.get("v.jsonList");
        parentJSON[0].Record[0]['federalSsnEsnPick'] = array[0];
        component.set("v.jsonList",parentJSON);
        
        
        var args9 = component.find("checkNine");
        for(var key in args9){
            if(args9[key].get("v.name").split('$')[0] != value){             
                args9[key].set("v.checked",false);
            }
        }
    },
    
    radioCheckTen  : function(component, event, helper) {
        console.log(event.getSource().get("v.value"));
        var name = event.getSource().get("v.name");
        var array = name.split('$');
        var value = array[0];
        var field = array[1];
        
        var parentJSON =  component.get("v.jsonList");
        parentJSON[0].Record[0]['acceptAssignment'] = array[0];
        component.set("v.jsonList",parentJSON);
        
        
        
        var args10 = component.find("checkTen");
        for(var key in args10){
            if(args10[key].get("v.name").split('$')[0] != value){             
                args10[key].set("v.checked",false);
            }
        }
        console.log("hdbj" , value + ' ' + field);
        //   var physicalAnalysis = component.get("v.newData");
        //  physicalAnalysis[field] = value;  
        //  component.set("v.newData",physicalAnalysis);
    },
    
    validateFromDate_UnableToWork :  function(component, event, helper) {  // xxx
        var name = event.getSource().get("v.name");
        var array = name.split('$');
        var parentIndex = array[0];
        var childIndex = array[1];
        var parent = component.get("v.jsonList");
        
        
        var value = event.getSource().get("v.value");
        var endDateCmp = component.find('validfieldFromDateUnableToWork');
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
    validateToDate_UnableToWork : function(component, event, helper) {  // xxx
        var name = event.getSource().get("v.name");
        var array = name.split('$');
        var parentIndex = array[0];
        var childIndex = array[1];
        var parent = component.get("v.jsonList");
        var value = event.getSource().get("v.value");
        var endDateCmp = component.find('validfieldFromDateUnableToWork');
        var endDate = value;
        helper.validateToDate_UnableToWork_InHelper(component, event, helper,value,childIndex);
    },
    patternMatch : function(component, event, helper) {  // xxx
        var name = event.getSource().get("v.name");
        var array = name.split('$');
        var parentIndex = array[0];
        var childIndex = array[1];
        var value = event.getSource().get("v.value");
        var parentJSON =  component.get("v.transactionaljsonList");
        var inputCmp = component.find("validateDiagnosisPointer");
        
        
        var re = /^[a-kA-K_]*$/
        if(event.getSource().get("v.value")!=' ') {
            if(!re.test(event.getSource().get("v.value"))) {
                if(Array.isArray(inputCmp)){                       
                    inputCmp[childIndex].setCustomValidity("Only A-L characters are allowed!");               
                }               
            }
            else {
                inputCmp[childIndex].setCustomValidity("");
            }
            inputCmp[childIndex].reportValidity(); 
        }
    },
    searchProcdureInSpecifiedDate_IfFromMissed : function(component, event, helper) {
        try{
            var name = event.getSource().get("v.name");
            var array = name.split('$');
            var parentIndex = array[0];
            var childIndex = array[1];
            var value = event.getSource().get("v.value"); // fromDate
            var parentJSON =  component.get("v.transactionaljsonList");
            //console.log('transactionaljsonList '+JSON.stringify(component.get("v.transactionaljsonList")));
            var toDate= parentJSON[parentIndex].Record[childIndex].toDate_Procedure; // todate
            var allowProceed = helper.checkFromDateValidity(component, event, helper,event.getSource().get("v.value"),childIndex);
            if($A.util.isUndefinedOrNull(value) && $A.util.isUndefinedOrNull(toDate)){
                parentJSON[parentIndex].Record[childIndex].isRowDisabled = true;
                parentJSON[parentIndex].Record[childIndex].rendringProviderNonNPI_Procedure = '';
                parentJSON[parentIndex].Record[childIndex].placeOfService_Procedure ='- None -';
                parentJSON[parentIndex].Record[childIndex].cptCodeName_Procedure ='';
                parentJSON[parentIndex].Record[childIndex].charges_Procedure = 0;
                parentJSON[parentIndex].Record[childIndex].daysOrUnit_Procedure=0;
                parentJSON[parentIndex].Record[childIndex].modifier_Procedure = '';
                parentJSON[parentIndex].Record[childIndex].modifier_Procedure2 = '';
                parentJSON[parentIndex].Record[childIndex].modifier_Procedure3 = '';
                parentJSON[parentIndex].Record[childIndex].modifier_Procedure4 = '';
                parentJSON[parentIndex].Record[childIndex].qualifier_Procedure = '';
                parentJSON[parentIndex].Record[childIndex].diagnosisPointer_Procedure='';
                component.set("v.transactionaljsonList",parentJSON);
                let attachedProcId = component.get("v.attachedProcId");
                let forDeletion = [];
                forDeletion.push(parentJSON[parentIndex].Record[childIndex].Id);
                attachedProcId = attachedProcId.filter(item => !forDeletion.includes(item))
                console.log(attachedProcId);
                component.set("v.attachedProcId",attachedProcId);
            }
            if(allowProceed){
                component.set("v.isAddClaimEnabled",false); 
                if(toDate){
                    component.set("v.loaded",false); // xxx 
                    let exisitngRowsFilled = component.get("v.fetchedRowIndexArray");
                    /***** REMOVE THE PROCEDURE ID IF SAME ROW WAS EDITED****/
                    if(exisitngRowsFilled.includes(childIndex)){
                        let procID =  parentJSON[parentIndex].Record[childIndex].Id
                        let existingID = component.get("v.existingProcedurePrePopulated");
                        let attachedProcId = component.get("v.attachedProcId");
                        if(!$A.util.isEmpty(existingID)){
                            existingID.splice(childIndex,1);
                            attachedProcId.splice(childIndex,1);
                            component.set("v.existingProcedurePrePopulated",existingID); 
                            component.set("v.attachedProcId",attachedProcId); 
                            //console.log('Inside PRoDiag '+component.get("v.existingProcedurePrePopulated"));
                            //console.log('Inside PRo '+component.get("v.attachedProcId"));
                            
                        }
                        
                    }
                    //console.log('existingProcedurePrePopulated Hututu1 '+component.get("v.existingProcedurePrePopulated"));
                    /********************************************************/
                    
                    var action = component.get("c.fetchProcedureForSpecifiedDates");
                    action.setParams({
                        "fromProcedure" : value,
                        "toProcedure" : toDate,
                        "acctId" : component.get("v.patId"),
                        "existingProcIDs" :  component.get("v.existingProcedurePrePopulated"),
                        "ProcIDs" :  component.get("v.attachedProcId"),
                    });
                    action.setCallback(this, function(response) {
                        var state = response.getState();
                        if (state === "SUCCESS") {  
                            component.set("v.loaded",true); // xxx 
                            parentJSON[parentIndex].Record[childIndex].isRowDisabled = false;// xxx 
                            var res = response.getReturnValue();
                            let childIndexCopy = JSON.parse(JSON.stringify(childIndex));
                            if(parseInt(childIndexCopy)<=4){
                                parentJSON[parentIndex].Record[parseInt(childIndexCopy)+1].isDateSearchingDisabled = false;
                            }
                            if(!$A.util.isEmpty(res.fetchProcedureForSpecifiedDates)){
                                if(res.procedureCharge != 0 && res.procedureCharge != null && res.procedureCharge != undefined){
                                    helper.populateProcedureData(component, event, helper,parentJSON,res.fetchProcedureForSpecifiedDates,
                                                                 parentIndex,childIndex,res);
                                    helper.getTotalCharge(component, event, helper);
                                }else{
                                    
                                    var toastEvent = $A.get("e.force:showToast");
                                    toastEvent.setParams({
                                        "title": "No records present!",
                                        "message": "The procedure can't be added as the charges are not defined. Please contact your system admin",
                                        "type" : "error"
                                    });
                                    toastEvent.fire();
                                    
                                }
                            }
                            else {
                                var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    "title": "NO PROCEDURES WERE FOUND IN THE SPECIFIED DATES!",
                                    "message": "No records present!",
                                    "type" : "error"
                                });
                                toastEvent.fire();
                                parentJSON[parentIndex].Record[childIndex].rendringProviderNonNPI_Procedure = '';
                                parentJSON[parentIndex].Record[childIndex].placeOfService_Procedure ='- None -';
                                parentJSON[parentIndex].Record[childIndex].cptCodeName_Procedure ='';
                                parentJSON[parentIndex].Record[childIndex].charges_Procedure = 0;
                                parentJSON[parentIndex].Record[childIndex].daysOrUnit_Procedure=0;
                                parentJSON[parentIndex].Record[childIndex].modifier_Procedure = '';
                                parentJSON[parentIndex].Record[childIndex].modifier_Procedure2 = '';
                                parentJSON[parentIndex].Record[childIndex].modifier_Procedure3 = '';
                                parentJSON[parentIndex].Record[childIndex].modifier_Procedure4 = '';
                                parentJSON[parentIndex].Record[childIndex].qualifier_Procedure = '';
                                parentJSON[parentIndex].Record[childIndex].diagnosisPointer_Procedure='';
                                parentJSON[parentIndex].Record[childIndex].isRowDisabled = true;
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
                }
            }
            else {
                component.set("v.isAddClaimEnabled",true); 
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "PLEASE CHECK THE ERROR MESSAGE!",
                    "message": "DATE ERROR",
                    "type" : "error"
                });
                toastEvent.fire();
            }   
        }
        catch(e){
            alert(e);
        }
        
    },
    searchProcdureInSpecifiedDate : function(component, event, helper) { // xxx
        try{
            var name = event.getSource().get("v.name");
            
            var array = name.split('$');
            var parentIndex = array[0];
            var childIndex = array[1];
            var value = event.getSource().get("v.value");
            var parentJSON =  component.get("v.transactionaljsonList");
            
            var fromDate= parentJSON[parentIndex].Record[childIndex].fromDate_Procedure;
            var toDate= parentJSON[parentIndex].Record[childIndex].toDate_Procedure; // todate
            if($A.util.isUndefinedOrNull(fromDate) && $A.util.isUndefinedOrNull(toDate)){
                parentJSON[parentIndex].Record[childIndex].isRowDisabled = true;
                parentJSON[parentIndex].Record[childIndex].rendringProviderNonNPI_Procedure = '';
                parentJSON[parentIndex].Record[childIndex].placeOfService_Procedure ='- None -';
                parentJSON[parentIndex].Record[childIndex].cptCodeName_Procedure ='';
                parentJSON[parentIndex].Record[childIndex].charges_Procedure = 0;
                parentJSON[parentIndex].Record[childIndex].daysOrUnit_Procedure=0;
                parentJSON[parentIndex].Record[childIndex].modifier_Procedure = '';
                parentJSON[parentIndex].Record[childIndex].modifier_Procedure2 = '';
                parentJSON[parentIndex].Record[childIndex].modifier_Procedure3 = '';
                parentJSON[parentIndex].Record[childIndex].modifier_Procedure4 = '';
                parentJSON[parentIndex].Record[childIndex].qualifier_Procedure = '';
                parentJSON[parentIndex].Record[childIndex].diagnosisPointer_Procedure='';
                component.set("v.transactionaljsonList",parentJSON);
                let attachedProcId = component.get("v.attachedProcId");
                let forDeletion = [];
                forDeletion.push(parentJSON[parentIndex].Record[childIndex].Id);
                attachedProcId = attachedProcId.filter(item => !forDeletion.includes(item))
                console.log(attachedProcId);
                component.set("v.attachedProcId",attachedProcId);
            }
            if(toDate){
                var allowProceed = helper.checkToDateValidity(component, event, helper,event.getSource().get("v.value"),childIndex);
                component.set("v.table_ToDateValid",allowProceed);
                
                if(allowProceed){
                    
                    component.set("v.isAddClaimEnabled",false); 
                    if(fromDate){
                        component.set("v.loaded",false); // xxx 
                        let exisitngRowsFilled = component.get("v.fetchedRowIndexArray");
                        /***** REMOVE THE PROCEDURE ID IF SAME ROW WAS EDITED****/
                        if(exisitngRowsFilled.includes(childIndex)){
                            let procID =  parentJSON[parentIndex].Record[childIndex].Id
                            
                            let existingID = component.get("v.existingProcedurePrePopulated");
                            let attachedProcId = component.get("v.attachedProcId");
                            
                            if(!$A.util.isEmpty(existingID)){
                                existingID.splice(childIndex,1);
                                attachedProcId.splice(childIndex,1);
                                component.set("v.attachedProcId",attachedProcId); 
                                component.set("v.existingProcedurePrePopulated",existingID);
                                //console.log('Inside PRoDiag '+component.get("v.existingProcedurePrePopulated"));
                                //console.log('Inside PRo '+component.get("v.attachedProcId"));
                            }
                        }
                        // console.log('existingProcedurePrePopulated Hututu2 '+component.get("v.existingProcedurePrePopulated"));
                        /********************************************************/
                        
                        var action = component.get("c.fetchProcedureForSpecifiedDates");
                        action.setParams({
                            "fromProcedure" : fromDate,
                            "toProcedure" : value,
                            "acctId" : component.get("v.patId"),
                            "existingProcIDs" :  component.get("v.existingProcedurePrePopulated"),
                            "ProcIDs" :  component.get("v.attachedProcId"),
                            
                        });
                        action.setCallback(this, function(response) {
                            var state = response.getState();
                            if (state === "SUCCESS") {    
                                component.set("v.loaded",true);
                                parentJSON[parentIndex].Record[childIndex].isRowDisabled = false;// xxx 
                                var res = response.getReturnValue();
                                let childIndexCopy = JSON.parse(JSON.stringify(childIndex));
                                if(parseInt(childIndexCopy)<=4){
                                    parentJSON[parentIndex].Record[parseInt(childIndexCopy)+1].isDateSearchingDisabled = false;
                                }
                                if(!$A.util.isEmpty(res.fetchProcedureForSpecifiedDates)){
                                    if(res.procedureCharge != 0 && res.procedureCharge != null && res.procedureCharge != undefined){
                                        helper.populateProcedureData(component, event, helper,parentJSON,res.fetchProcedureForSpecifiedDates,
                                                                     parentIndex,childIndex,res);
                                        
                                        helper.getTotalCharge(component, event, helper);
                                    }else{
                                        
                                        var toastEvent = $A.get("e.force:showToast");
                                        toastEvent.setParams({
                                            "title": "No records present!",
                                            "message": "The procedure can't be added as the charges are not defined. Please contact your system admin",
                                            "type" : "error"
                                        });
                                        toastEvent.fire();
                                        
                                    }
                                    
                                }
                                else {
                                    //  helper.emptyRow(component, event, helper,parentJSON, parentIndex,childIndex);                           
                                    var toastEvent = $A.get("e.force:showToast");
                                    toastEvent.setParams({
                                        "title": "NO PROCEDURES WERE FOUND IN THE SPECIFIED DATES!",
                                        "message": "No records present!",
                                        "type" : "error"
                                    });
                                    toastEvent.fire();
                                    
                                    parentJSON[parentIndex].Record[childIndex].rendringProviderNonNPI_Procedure = '';
                                    parentJSON[parentIndex].Record[childIndex].placeOfService_Procedure ='- None -';
                                    parentJSON[parentIndex].Record[childIndex].cptCodeName_Procedure ='';
                                    parentJSON[parentIndex].Record[childIndex].charges_Procedure = 0;
                                    parentJSON[parentIndex].Record[childIndex].daysOrUnit_Procedure=0;
                                    parentJSON[parentIndex].Record[childIndex].modifier_Procedure = '';
                                    parentJSON[parentIndex].Record[childIndex].modifier_Procedure2 = '';
                                    parentJSON[parentIndex].Record[childIndex].modifier_Procedure3 = '';
                                    parentJSON[parentIndex].Record[childIndex].modifier_Procedure4 = '';
                                    parentJSON[parentIndex].Record[childIndex].qualifier_Procedure = '';
                                    parentJSON[parentIndex].Record[childIndex].diagnosisPointer_Procedure='';
                                    parentJSON[parentIndex].Record[childIndex].isRowDisabled = true; 
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
                    }
                    
                    
                    else {
                        let childIndexCopy = JSON.parse(JSON.stringify(childIndex));
                        childIndexCopy = parseInt(childIndexCopy)+1;
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "FROM DATE IS REQUIERED TO SEARCH PROCEDURES",
                            "message": "Please fill FROM DATE on row "+childIndexCopy,
                            "type" : "error"
                        });
                        toastEvent.fire();
                    }
                }
                
                else {  
                    component.set("v.isAddClaimEnabled",true); 
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "PLEASE CHECK THE ERROR MESSAGE!",
                        "message": "DATE ERROR",
                        "type" : "error"
                    });
                    toastEvent.fire();
                }
            }
            
        }
        catch(err) {
            alert('error '+err);
        }
    }, 
    handleNo: function(component) {
        component.set("v.showConfirmation", false);
        var parentIndex = component.get("v.parentindexValue");
        var childIndex = component.get("v.childindexValue");
        var parentJSON =  component.get("v.transactionaljsonList");
        parentJSON[parentIndex].Record[childIndex].fromDate_Procedure='';
        parentJSON[parentIndex].Record[childIndex].toDate_Procedure='';
        parentJSON[parentIndex].Record[childIndex].isRowDisabled = true;
        parentJSON[parentIndex].Record[childIndex].rendringProviderNonNPI_Procedure = '';
        parentJSON[parentIndex].Record[childIndex].placeOfService_Procedure ='- None -';
        parentJSON[parentIndex].Record[childIndex].cptCodeName_Procedure ='';
        parentJSON[parentIndex].Record[childIndex].charges_Procedure = 0;
        parentJSON[parentIndex].Record[childIndex].daysOrUnit_Procedure=0;
        parentJSON[parentIndex].Record[childIndex].modifier_Procedure = '';
        parentJSON[parentIndex].Record[childIndex].modifier_Procedure2 = '';
        parentJSON[parentIndex].Record[childIndex].modifier_Procedure3 = '';
        parentJSON[parentIndex].Record[childIndex].modifier_Procedure4 = '';
        parentJSON[parentIndex].Record[childIndex].qualifier_Procedure = '';
        parentJSON[parentIndex].Record[childIndex].diagnosisPointer_Procedure='';
        component.set("v.transactionaljsonList",parentJSON);
        let attachedProcId = component.get("v.attachedProcId");
        let forDeletion = [];
        forDeletion.push(parentJSON[parentIndex].Record[childIndex].Id);
        attachedProcId = attachedProcId.filter(item => !forDeletion.includes(item))
        console.log(attachedProcId);
        component.set("v.attachedProcId",attachedProcId);
        
    },
    
    handleYes: function(component,event,helper) {
        component.set("v.showConfirmation", false);
        
    },
    /*Validation Lokesh */
    
    /* phoneChange : function(component, event, helper) {
        var val = event.getSource().get("v.value");
        var regex = /^[0-9]*$/;
       // var name = event.getSource().get("v.name");
        var array = name.split('$');
        var parentIndex = array[0];
        var childIndex = array[1];
        var inputCmp = component.find("resphone"); 
        if(val){
            component.set("v.isAddClaimEnabled",false);
            
            if(Array.isArray(inputCmp)){   
                if(!regex.test(event.getSource().get("v.value"))) {
                    inputCmp[childIndex].setCustomValidity("Only 10 digits (0-9) are allowed!"); 
                    component.set("v.isAddClaimEnabled",true); 
                }
                else {
                    inputCmp[childIndex].setCustomValidity("");   
                    component.set("v.isAddClaimEnabled",false); 
                }
                inputCmp[childIndex].reportValidity(); 
                
            }
            else {
                if(!regex.test(event.getSource().get("v.value"))) {
                    inputCmp.setCustomValidity("Only 10 digits (0-9) are allowed!");
                    component.set("v.isAddClaimEnabled",true); 
                }
                else {
                    inputCmp.setCustomValidity("");
                    component.set("v.isAddClaimEnabled",false); 
                }
                inputCmp.reportValidity(); 
            }
        }
        else {
            if(Array.isArray(inputCmp)){   
                inputCmp[childIndex].setCustomValidity("");   
                component.set("v.isAddClaimEnabled",false); 
                inputCmp[childIndex].reportValidity(); 
            }
            else {
                inputCmp.setCustomValidity("");
                component.set("v.isAddClaimEnabled",false); 
                inputCmp.reportValidity(); 
            }
        }
    },
    
    
        zipChange : function(component, event, helper) {
        var val = event.getSource().get("v.value");
        var regex = /[^a-zA-Z\d\s:]/;
        //var name = event.getSource().get("v.name");
        var array = name.split('$');
        var parentIndex = array[0];
        var childIndex = array[1];
        var inputCmp = component.find("reszip");
        if(val){
            if(val.length==5){
                if(Array.isArray(inputCmp)){   
                    inputCmp[childIndex].setCustomValidity("");   
                    component.set("v.isAddClaimEnabled",false); 
                    inputCmp[childIndex].reportValidity(); 
                }
                else {
                    inputCmp.setCustomValidity("");
                    component.set("v.isAddClaimEnabled",false); 
                    inputCmp.reportValidity(); 
                }
            }
            else if(val.length==12){
                if(Array.isArray(inputCmp)){   
                    if(val.includes('-')){
                        inputCmp[childIndex].setCustomValidity("Hyphen(-) not allowed!"); 
                        component.set("v.isAddClaimEnabled",true); 
                    }
                    else {
                        inputCmp[childIndex].setCustomValidity("");   
                        component.set("v.isAddClaimEnabled",false); 
                    }
                    inputCmp[childIndex].reportValidity(); 
                    
                }
                else {
                    if(val.includes('-')){
                        inputCmp.setCustomValidity("Hyphen(-) not allowed!");
                        component.set("v.isAddClaimEnabled",true); 
                    }
                    else {
                        inputCmp.setCustomValidity("");
                        component.set("v.isAddClaimEnabled",false); 
                    }
                    inputCmp.reportValidity(); 
                }
            }
                else {
                    var patZ = component.find("reszip");
                    if(Array.isArray(patZ)){   
                        
                        patZ[childIndex].setCustomValidity("Zip can be either 5 or 12 digits only."); 
                        component.set("v.isAddClaimEnabled",true); 
                        
                        patZ[childIndex].reportValidity(); 
                        
                    }
                    else {
                        
                        patZ.setCustomValidity("Zip can be either 5 or 12 digits only.");
                        component.set("v.isAddClaimEnabled",true); 
                        
                        patZ.reportValidity(); 
                    }
                }
            
        }
        else {
            if(Array.isArray(inputCmp)){   
                inputCmp[childIndex].setCustomValidity("");   
                component.set("v.isAddClaimEnabled",false); 
                inputCmp[childIndex].reportValidity(); 
            }
            else {
                inputCmp.setCustomValidity("");
                component.set("v.isAddClaimEnabled",false); 
                inputCmp.reportValidity(); 
            }
        }
    },*/
    
    reEvaluateTotalCharge :  function(component, event, helper) {
        
        
        var name = event.getSource().get("v.name");
        var array = name.split('$');
        var parentIndex = array[0];
        var childIndex = array[1];
        var value = event.getSource().get("v.value"); // fromDate
        var parentJSON =  component.get("v.transactionaljsonList");
        var daysOrUnit_Procedure = parentJSON[parentIndex].Record[childIndex].daysOrUnit_Procedure; 
        var charges_Procedure  = parentJSON[parentIndex].Record[childIndex].charges_Procedure;
        let instanceAmt = daysOrUnit_Procedure*charges_Procedure;
        let iterationArr =  parentJSON[parentIndex].Record;
        let bufferTotal = 0;
        for(let rec in iterationArr){
            if(rec!=childIndex){
                bufferTotal+= iterationArr[rec].daysOrUnit_Procedure*iterationArr[rec].charges_Procedure
                //bufferTotal+= iterationArr[rec].charges_Procedure
            }
        }
        bufferTotal+= instanceAmt;
        
        let jsonList = component.get("v.jsonList");
        jsonList[0].Record[0].TotalCharges = bufferTotal;
        component.set("v.jsonList",jsonList);
        
    },
    
    checkICDValidity : function(component, event, helper) { // xxx
        var value = event.getSource().get("v.value");
        if(value){
            var action = component.get("c.fetchICDCodes");
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {               
                    var res = response.getReturnValue();
                    if(!$A.util.isEmpty(res)){
                        if(res.includes(value)){
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": "ICD CODE VALID",
                                "message": "ICD CODE VALID",
                                "type" : "success"
                            });
                            toastEvent.fire();
                        }
                        else {
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": "BAD ICD CODE",
                                "message": value +" IS NOT A VALID ICD",
                                "type" : "warning"
                            });
                            toastEvent.fire();
                        }
                    }
                    else {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "NO ICD CODES PRESENT IN THE SYSTEM!",
                            "message": "No records defined in ICD CODES!",
                            "type" : "error"
                        });
                        toastEvent.fire();
                    }
                    
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
    },
    radioCheck  : function(component, event, helper) {
        console.log(event.getSource().get("v.value"));
        var name = event.getSource().get("v.name");
        var array = name.split('$');
        var value = array[0];
        var field = array[1];
        var args = component.find("checkone");
        for(var key in args){
            if(args[key].get("v.name").split('$')[0] != value){             
                args[key].set("v.checked",false);
            }
        }
        console.log("hdbj" , value + ' ' + field);
        //   var physicalAnalysis = component.get("v.newData");
        //  physicalAnalysis[field] = value;  
        //  component.set("v.newData",physicalAnalysis);
    },
    
    cancelButton : function(component,event,helper){
        component.set("v.isActive",false);
        //  component.set("v.OpenPopUp",false);
        var compEvent = component.getEvent("cancelEvent"); //Anusha 29/10/22
        compEvent.fire(); //Anusha 29/10/22
        
    },
    
    handleChange: function (component, event) {
        console.log(event.getParam('value'));
    },
    changeIfYesForOutsideLab  : function(component, event, helper) {
        var name = event.getSource().get("v.name");
        var array = name.split('$');
        var parentIndex = array[0];
        var childIndex = array[1];
        var parent = component.get("v.jsonList");
        parent[parentIndex].Record[childIndex].outsideLabNo = false;
        component.set("v.jsonList",parent);
        component.set("v.chargeAbility",false);
        
    },
    changeIfNoForOutsideLab : function(component, event, helper) {
        var name = event.getSource().get("v.name");
        var array = name.split('$');
        var parentIndex = array[0];
        var childIndex = array[1];
        var parent = component.get("v.jsonList");
        parent[parentIndex].Record[childIndex].outsideLabcharges = 0;  
        parent[parentIndex].Record[childIndex].outsideLab = false;
        component.set("v.jsonList",parent);
        component.set("v.chargeAbility",true);
    },
    handleChangeAss: function (component, event) {
        console.log(event.getParam('value'));
    },
    
    handleBlur : function(component,event,helper){
        
        var dobcmp = component.find("dob");
        dobcmp.setCustomValidity('') ;
        var chckvalididty = dobcmp.get("v.validity");
        console.log(chckvalididty.valid); // it gives false when 1st enter wrong format then i changed to correct format still shows
        if(!chckvalididty.valid){
            dobcmp.setCustomValidity('format must be mm/dd/yyyy');
        }else{
            dobcmp.setCustomValidity('') ;
        }
        dobcmp.reportValidity();
    },
    
    toggleSection : function(component, event, helper) {    
        
        var sectionAuraId = event.target.getAttribute("data-auraId");
        var sectionDiv = component.find(sectionAuraId).getElement();
        var sectionState = sectionDiv.getAttribute('class').search('slds-is-close'); 
        if(sectionState == -1){
            sectionDiv.setAttribute('class' , 'slds-section slds-is-close');
        }
        else{
            sectionDiv.setAttribute('class' , 'slds-section slds-is-open');
        }
    },
    
    fetchData : function(component, event, helper) {
        var today = new Date();
        var dd = today.getDate();
        var mm = today.getMonth() + 1; //January is 0!
        
        var yyyy = today.getFullYear();
        if(dd<10) {
            dd = '0'+dd
        }         
        if(mm<10) {
            mm = '0'+mm
        }       
        //today = mm + ' ' + dd + ', ' + yyyy;
        var todayString = yyyy + "-" + mm + "-" + dd;
        var fromDate = component.get("v.fromDate");
        var toDate = component.get("v.toDate");
        //   var changeValue = component.get("v.value");
        console.log('toDate'+toDate  + '' + fromDate );    
        var x=364;
        if(yyyy%4==0)
        {
            x=365;
        }
        // console.log(typeof yyyy);
        // code to subtract 1 year from current Date
        var dateToSubtract=new Date(todayString);
        dateToSubtract.setDate(dateToSubtract.getDate()-x);
        console.log('Subtracted Date'+dateToSubtract);
        component.set("v.firstvalidation",false);
        component.set("v.secondvalidation",false);
        component.set("v.thirdvalidation",false);
        component.set("v.fourthvalidation",false);
        var dateForCompare=new Date(fromDate);
        console.log('dateForCompare'+dateForCompare);   
        if(dateForCompare>=dateToSubtract||toDate==null||fromDate==null){  //problematic
            if(toDate>fromDate||toDate==null||fromDate==null){
                if(toDate!=null||toDate>todayString){
                    if(toDate<=todayString){
                        if(fromDate!=null)
                        {
                            helper.getprocedureRecord(component, helper, fromDate, toDate);
                            
                        }
                        else{
                            component.set("v.secondvalidation",true);
                        }
                    }
                    else{
                        component.set("v.firstvalidation",true);
                    }
                }
                else{
                    component.set("v.thirdvalidation",true);
                }
            }
            else{
                component.set("v.fourthvalidation",true);
            }
        }
        
        else{
            component.set("v.secondvalidation",true); 
        }
    },
    save : function(component,event,helper){
        var sendDataToInsurance=false; //Anusha -start - 03/11/22
        if(event.getSource().get("v.name")!='Save'){
            sendDataToInsurance=true;
        } //Anusha -End - 03/11/22
        
        var globalReqCheckValid = component.find('globalReqCheck').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true); 
        
        var fedTaxNumInput = component.find('fedTaxNum')
        fedTaxNumInput.showHelpMessageIfInvalid();
        var fedTaxNumCheckValid=fedTaxNumInput.get('v.validity').valid;
        var isValid=helper.validateBillingProviderNpi(component,event,helper); //Anusha
        var isValidzip=helper.validateBillingProviderZip(component,event,helper); //lokesh
        var isValidphone=helper.validateBillProviderPhone(component,event,helper);
        /* if(component.get("v.claimProcessedVia") && sendDataToInsurance){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type": "error",
                "message": "Claim for this payor can’t be send out to clearing house."
            });
            toastEvent.fire();
            return;
        }*/
        // var globalReqCheckValid = true;
        if(globalReqCheckValid && fedTaxNumCheckValid && isValid && isValidzip && isValidphone){
            
            if(JSON.stringify(component.get("v.attachedProcId")) != [] && component.get("v.attachedProcId").length != 0){
                let b = component.get("v.dropDownOptions");
                let k = component.get("v.dropDownSelectedValues"); 
                var jsonData = component.get("v.jsonList");
                console.log('js 1 for my updates' , JSON.stringify(jsonData));
                var tableData = component.get("v.transactionaljsonList");
                console.log('js 2  for my updates' , JSON.stringify(tableData));
                component.set("v.loaded",false); // xxx 
                var selectedClaimCodes = JSON.parse(JSON.stringify(component.get("v.dropDownSelectedValues"))); // xxx
                var dropDownOptions = {'keysToSave' : component.get("v.dropDownOptions"),
                                      }; // xxx
                
                var action = component.get("c.saveData");
                //var vobId = component.get('v.selectedVOBList')[0].Id;
                action.setParams({
                    "jsonListData" : JSON.stringify(jsonData),
                    "tabelListData" : JSON.stringify(tableData),
                    "recordVal" : component.get("v.patId"),
                    "totalAmount" : component.get("v.totalAmount"),
                    "transId" : component.get("v.transactionalDataId"),
                    "vobId" : component.get('v.selectedVOBList')[0].Id, //Anusha
                    "payorName" : component.get("v.payorName"),
                    "dropDownOptions" : JSON.stringify(dropDownOptions),
                    "selectedClaimCodes" : selectedClaimCodes.join(';'),
                    "sendToInsurance" : sendDataToInsurance, //Anusha -03/11/22
                    "ProcIDs" :  component.get("v.attachedProcId"),
                });
                action.setCallback(this,function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        component.set("v.loaded",true); // xxx 
                        console.log('success');
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "type": "Success",
                            "title": "CLAIM GENERATED SUCCESSFULLY !!",
                            "message": "Submitted Successful!"
                        });
                        toastEvent.fire();   
                        var cmpEvent = component.getEvent("ProblemRefreshEvt");
                        cmpEvent.fire();
                        var workspaceAPI = component.find("workspace"); 
                        workspaceAPI.getFocusedTabInfo().then(function(response) {
                            var focusedTabId = response.tabId;
                            workspaceAPI.closeTab({tabId: focusedTabId});
                        })
                        .catch(function(error) {
                            console.log(error);
                        });
                        component.set("v.isActive",false);
                        /* commented by jami, as we need to redirect record page after claim creation - lx3- 11056
                         
                        var homeEvent = $A.get("e.force:navigateToObjectHome");
                        homeEvent.setParams({
                            "scope": "ElixirSuite__Claim__c"
                        });
                        homeEvent.fire();*/
                        var redirectURL = response.getReturnValue().newClaimId;
                        component.find("navigationService").navigate({
                            "type": "standard__recordPage",
                            "attributes": {
                                "recordId": redirectURL,
                                "objectApiName": "ElixirSuite__Claim__c",
                                "actionName": "view"
                            }
                        });
                        
                    }
                    else {
                        component.set("v.loaded",true); // xxx 
                        var toastEvent = $A.get("e.force:showToast"); //Anusha -Start -03/11/22
                        toastEvent.setParams({
                            "type": "error",
                            "title": "ERROR",
                            "message": "Please Clear all the Fields" //response.getError()[0].message
                        });
                        toastEvent.fire();  //Anusha -End -03/11/22
                    }
                });
                $A.enqueueAction(action);
            }else{
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "error",
                    "title": "Procedure Not Attached!",
                    "message": "Please add the procedure"
                });
                toastEvent.fire();   
                
            }
        }
        else {
            console.log("else");
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type": "error",
                "title": "PLEASE FILL ALL THE MANDATORY FIELDS !",
                "message": "Please fill mandatory fields!"
            });
            toastEvent.fire();   
        }
        
    },
    //Anusha
    handleBillingProviderInfoNpi : function(component,event,helper){
        console.log("called handle");
        helper.validateBillingProviderNpi(component,event,helper);
    },
    //Lokesh
    validatebillingProviderZipcode : function(component,event,helper){
        console.log("called handle");
        helper.validateBillingProviderZip(component,event,helper);
    },
    //Lokesh
    billingProviderPhone : function(component,event,helper){
        console.log("called handle");
        helper.validateBillProviderPhone(component,event,helper);
    },
    inputInsName : function(component,event,helper){
        try{
            console.log('ins name change#'+event.target.value);
            let insAllName = (event.target.value).split(',');
            let insNameF='';
            let insNameM='';
            let insNameL='';
            let totalJSON = component.get("v.jsonList");
            if(insAllName.length==1){
                insNameF = insAllName[0];
            }else if(insAllName.length==2){
                insNameF = insAllName[0];
                insNameL = insAllName[1];  
            }else if(insAllName.length==3){
                insNameF = insAllName[0];
                insNameL = insAllName[1];
                insNameM = insAllName[2];
            }
            console.log('ins name change@@@ name'+insNameF+' '+insNameL+' '+insNameM);
            totalJSON[0].Record[0].insuredName = insNameF+' '+insNameL+' '+insNameM;
            component.set("v.jsonList",totalJSON);
            console.log('updated json'+JSON.stringify(component.get("v.jsonList")));
        }
        catch(e){
            console.log('json e'+JSON.stringify(e.message));
        }
    }
})
({
    doInit : function(component, event, helper) {
        component.set("v.mapOfPointerAndICD",{});
        component.set("v.mapOfchildIndexAndFilledPointers",{});
        if ($A.util.isUndefinedOrNull(component.get('v.transactionaljsonList')) || $A.util.isEmpty(component.get('v.transactionaljsonList'))){
            //   console.log('bwd' , component.get("v.transactionaljsonList"));
            //  component.set("v.noData", false);
        }
        // alert(component.get("v.patId"));
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
        console.log('bew', component.get("v.recordId"));
        action.setParams({
            "claimrecordID": component.get("v.recordId"),
        });
        
        action.setCallback(this, function (response) {
            var res = response.getReturnValue();
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var dischargeDate = '';
                var admitDate = '';
                if(res.patientDecision=='Inpatient'){ // xxx
                    dischargeDate = res.accDetails.ElixirSuite__dischargeDateNew__c ; 
                    admitDate  = res.accDetails.ElixirSuite__Admit_Date__c; 
                    component.set("v.isInpatient",true); 
                }
                if(!res.isVobPresent){ // xxx
                    helper.flagNoVOB(component, event, helper);
                }
                else {
                    if(res.vobData[0].hasOwnProperty('ElixirSuite__Insurance_Providers__c')){
                        component.set("v.payorName",res.vobData[0].ElixirSuite__Insurance_Providers__c);
                    }
                }
                // added by jami for LX3-12318
                component.set("v.isSaveSendEnabled",response.getReturnValue().saveSendCustomSetting);
                helper.buildDataForProcedure(component, event, helper,res.acctRelatedProcData,res.relatedClaimLineItems);
                component.set("v.StatesPicklistVal",helper.CreateAmericaStatesJSON(component, event, helper)); 
                var allFieldList = res.mapOfNameToField;
                var allAccFieldList = res.mapOfNameToFieldAcc;
                var allFieldListInsType = res.mapOfNameToFieldInsType;
                var accountDetails = res.accDetails ;
                var transactionalData = res.vobData ;
                var claimField = res.claimFields ;
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
                    insFName =  res.vobData[0].ElixirSuite__Insured_First_Name__c;
                }
                if(res.vobData[0].hasOwnProperty('ElixirSuite__Insured_Middle_Name__c')){
                    insMName = res.vobData[0].ElixirSuite__Insured_Middle_Name__c;
                }
                if(res.vobData[0].hasOwnProperty('ElixirSuite__Insured_Last_Name__c')){
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
                        }
                            else if(keyInside.toUpperCase() == (nameSpace + 'Other_Accident__c').toUpperCase()){
                                component.set("v.otherAccidentPicklistValues",allFieldList[keyInside]);
                            }
                                else if(keyInside.toUpperCase() == (nameSpace + 'Is_there_another_Health_Benefit_Plan__c').toUpperCase()){
                                    component.set("v.otherHealthBenefitPicklistValues",allFieldList[keyInside]);
                                }
                                    else if(keyInside.toUpperCase() == ('ElixirSuite__Gender__c').toUpperCase()){
                                        var picklistValues = allFieldList[keyInside];
                                        var filteredValues = [];
                                        
                                        for (var i = 0; i < picklistValues.length; i++) {
                                            if (picklistValues[i] === 'Male' || picklistValues[i] === 'Female') {
                                                filteredValues.push(picklistValues[i]);
                                            }
                                        }
                                        
                                        //  component.set("v.InsuregenderPicklistValues", filteredValues);
                                        component.set("v.InsuregenderPicklistValues",allFieldList[keyInside]);
                                    }
                                        else if(keyInside.toUpperCase() == ('ElixirSuite__Accept_Asignment__c').toUpperCase()){
                                            component.set("v.AccptAssPicklistValues",allFieldList[keyInside]);
                                        }
                                            else if(keyInside.toUpperCase() == ('ElixirSuite__Federal_Tax_ID_Number__c').toUpperCase()){
                                                component.set("v.federalPicklistValues",allFieldList[keyInside]);
                                            }
                    
                }
                for(var keyInside in allAccFieldList){
                    if(keyInside.toUpperCase() == ('ElixirSuite__Gender__c').toUpperCase()){
                        component.set("v.genderPicklistValues",allFieldList[keyInside]);
                    }
                }
                var jsonList = [];
                var insideJson = {};
                var completeJson = [];
                console.log('dbwhjbd');
                var isurancePlanName = '';
                if(!$A.util.isUndefinedOrNull(res.relatedResult)){
                    let resultArr = res.relatedResult;
                    if(!$A.util.isEmpty(resultArr)){
                        isurancePlanName = resultArr[0].ElixirSuite__Insurance_Plan__c;
                        console.log('result '+JSON.stringify(resultArr[0]));
                    }
                }
                let employment = "NO";
                let autoAcciDent = "NO";
                let otherAcciDent = "NO";
                let anyOtherHealthBenifit = "NO";
                if(res.currentViewClaimRecord[0].ElixirSuite__Patient_Condition_Related_To_Employment__c){
                    employment = "YES";
                }
                
                if(res.currentViewClaimRecord[0].ElixirSuite__Patient_Condition_Related_To_Accident__c){
                    autoAcciDent = "YES";
                }
                
                if(res.currentViewClaimRecord[0].ElixirSuite__Patient_Condition_to_Other_Accident__c){
                    otherAcciDent = "YES";
                }
                
                
                if(res.currentViewClaimRecord[0].ElixirSuite__Any_Other_Health_Benefit_Plan__c){
                    anyOtherHealthBenifit = "YES";
                }
                try {
                    if(res.currentViewClaimRecord[0].hasOwnProperty('ElixirSuite__Claim_Codes__c')){
                        if(res.currentViewClaimRecord[0].ElixirSuite__Claim_Codes__c){
                            var allApproverMembers =  res.currentViewClaimRecord[0].ElixirSuite__Claim_Codes__c.split(';');
                            var allValues = JSON.parse(res.currentViewClaimRecord[0].ElixirSuite__Claim_Code_Options__c);
                            var opts= [];
                            var count = 0;
                            var dropDownSelectedValues = [];
                            for (var i = 0; i < allValues.length; i++) {
                                if(allApproverMembers.includes(allValues[i].value)){
                                    count++;
                                    opts.push({'label':allValues[i].label,'value' : allValues[i].value,'selected' : true,
                                               'disabled' :false });
                                    dropDownSelectedValues.push(allValues[i].value);
                                }
                                else {
                                    opts.push({'label':allValues[i].label,'value' : allValues[i].value,'selected' : false,
                                               'disabled' :false});
                                }
                            }
                            component.set("v.dropDownSelectedValues", dropDownSelectedValues);
                            component.set("v.dropDownOptions", opts);
                            component.set('v.searchString', count + ' options selected');
                        }
                    }
                }
                catch(err) {
                    alert('error '+err);
                }
                component.set('v.patId', res.currentViewClaimRecord[0].ElixirSuite__Account__c );
                insideJson = {"id" : res.currentViewClaimRecord[0].Id,
                              "patientName" : res.currentViewClaimRecord[0].ElixirSuite__Patient_Name__c ,
                              "patientDOB" : res.currentViewClaimRecord[0].ElixirSuite__Patient_DOB__c , 
                              "patiSex" : res.currentViewClaimRecord[0].ElixirSuite__Patient_Sex__c === 'F' ? 'Female' : (res.currentViewClaimRecord[0].ElixirSuite__Patient_Sex__c === 'M' ? 'Male' : 'Unknown'),
                              "patientAddress" : res.currentViewClaimRecord[0].ElixirSuite__Patient_s_Address__c ,
                              "patientCity" : res.currentViewClaimRecord[0].ElixirSuite__Patient_s_City__c , 
                              "patientState" : res.currentViewClaimRecord[0].ElixirSuite__Patient_s_State__c,
                              "patientZipcode" : res.currentViewClaimRecord[0].ElixirSuite__Patient_Zip_Code__c , 
                              "patientPhone" : res.currentViewClaimRecord[0].ElixirSuite__Patient_s_Phone__c ,
                              "insuranceType": res.currentViewClaimRecord[0].ElixirSuite__Insurance_Type__c,
                              "medicareTypeCode": ((res.currentViewClaimRecord[0].ElixirSuite__Insurance_Type__c === 'MA' || res.currentViewClaimRecord[0].ElixirSuite__Insurance_Type__c === 'MB') ? res.currentViewClaimRecord[0].ElixirSuite__Medicare_Type_Code__c || '' : ''),
                              "relationWithInsured" : res.currentViewClaimRecord[0].ElixirSuite__Patient_Relationship_to_Insured__c ,
                              "insuredIdNumber" : res.currentViewClaimRecord[0].ElixirSuite__Insured_s_ID_Number__c, 
                              "insuredName" :  res.currentViewClaimRecord[0].ElixirSuite__Insured_s_Name__c , 
                              "autoAccident" : autoAcciDent, 
                              "employment" : employment,
                              "IsthereanotherHealthBenefitPlan" : anyOtherHealthBenifit,
                              "otherAccident" : otherAcciDent,
                              "insurancePlanName" :  res.currentViewClaimRecord[0].ElixirSuite__Insurance_Plan_Name__c,
                              "reserverdforNUCCuse1" : '' ,                    
                              "reserverdforNUCCuse2" : '' ,
                              "reservedforNUCCuse3" : '',
                              "reservedforNUCCuse4" : res.currentViewClaimRecord[0].ElixirSuite__Reserved_For_NUCC_Use3__c ,
                              "otherClaimId" : res.currentViewClaimRecord[0].ElixirSuite__Other_Claim_Id__c,
                              "dateOfCurrentIllness" : res.currentViewClaimRecord[0].ElixirSuite__Date_Of_Current_Illness__c,
                              "qualifierForDateOfCurrentIllness_Value" : res.currentViewClaimRecord[0].ElixirSuite__QUAL_For_Date_current_illness_injury__c, // xxx
                              "qualifierForOtherDates_Value" : res.currentViewClaimRecord[0].ElixirSuite__QUAL_For_Other_Dates__c,//xxx
                              "npi_nucc_Value" : res.currentViewClaimRecord[0].ElixirSuite__NUCC__c, //xxx
                              "npi_nucc_description_Value" : res.currentViewClaimRecord[0].ElixirSuite__NUCC_Description__c, //xxx
                              
                              "diagnosis_A" : res.currentViewClaimRecord[0].ElixirSuite__Diagnosis_A__c,
                              "diagnosis_B" : res.currentViewClaimRecord[0].ElixirSuite__Diagnosis_B__c,
                              "diagnosis_C" : res.currentViewClaimRecord[0].ElixirSuite__Diagnosis_C__c,
                              "diagnosis_D" : res.currentViewClaimRecord[0].ElixirSuite__Diagnosis_D__c,
                              "diagnosis_E" : res.currentViewClaimRecord[0].ElixirSuite__Diagnosis_E__c,
                              "diagnosis_F" : res.currentViewClaimRecord[0].ElixirSuite__Diagnosis_F__c,
                              "diagnosis_G" : res.currentViewClaimRecord[0].ElixirSuite__Diagnosis_G__c,
                              "diagnosis_H" : res.currentViewClaimRecord[0].ElixirSuite__Diagnosis_H__c,
                              "diagnosis_I" : res.currentViewClaimRecord[0].ElixirSuite__Diagnosis_I__c,
                              "diagnosis_J" : res.currentViewClaimRecord[0].ElixirSuite__Diagnosis_J__c,
                              "diagnosis_K" : res.currentViewClaimRecord[0].ElixirSuite__Diagnosis_K__c,  
                              "diagnosis_L" : res.currentViewClaimRecord[0].ElixirSuite__Diagnosis_L__c,
                              
                              "orignalRefNumber" : res.currentViewClaimRecord[0].ElixirSuite__Original_Ref_No__c,
                              "priorAuthNumber" : res.currentViewClaimRecord[0].ElixirSuite__Prior_Authorization_Number__c,
                              "otherDate": res.currentViewClaimRecord[0].ElixirSuite__Other_Date__c,
                              "otherDate_InsuredPersonAuth" : res.currentViewClaimRecord[0].ElixirSuite__Insured_Or_Auth_Persn_Date__c,
                              "datesPatientUnableTowork" : res.currentViewClaimRecord[0].ElixirSuite__Dates_Patient_Unable_To_Work__c,
                              "nameOfReferringProvider" : res.currentViewClaimRecord[0].ElixirSuite__Name_of_referring_provider_Other_sourc__c,
                              "nameOfReferringProvider_FirstName" : res.currentViewClaimRecord[0].ElixirSuite__First_Name_NAME_OF_REFERRING_PROVIDER__c,
                              "nameOfReferringProvider_MiddleName" : res.currentViewClaimRecord[0].ElixirSuite__MiddleName_NAME_OF_REFERRING_PROVIDER__c,
                              "nameOfReferringProvider_LastName" : res.currentViewClaimRecord[0].ElixirSuite__Last_Name_NAME_OF_REFERRING_PROVIDER__c,
                              "qualifierForNameOfReferringProvider" : res.currentViewClaimRecord[0].ElixirSuite__QUAL_For_Name_of_referring_provider__c,
                              "NPI" :  res.currentViewClaimRecord[0].ElixirSuite__NPI__c,
                              "hospitilizationDates": res.currentViewClaimRecord[0].ElixirSuite__Hospitalization_Dates__c,
                              "additionalInfo" : res.currentViewClaimRecord[0].ElixirSuite__Additional_Claim_Information__c,
                              "outsideLab" : res.currentViewClaimRecord[0].ElixirSuite__Outside_Lab_new__c,
                              "outsideLabNo" : !(res.currentViewClaimRecord[0].ElixirSuite__Outside_Lab_new__c),
                              "federalTaxNumber" : res.currentViewClaimRecord[0].ElixirSuite__Federal_Tax_Id_Number__c,
                              "federalSsnEsnPick":res.currentViewClaimRecord[0].ElixirSuite__Billing_Provider_Tax_ID_Type__c,
                              "acceptAssignment": res.currentViewClaimRecord[0].ElixirSuite__Accept_Assignment__c,
                              "amountPaid" : res.currentViewClaimRecord[0].ElixirSuite__Amount_Paid__c,
                              "billingProviderInfoNpi" : res.currentViewClaimRecord[0].ElixirSuite__Billing_Provider_Info_NPI__c,
                              "serviceFacilityLocationInfo" : res.currentViewClaimRecord[0].ElixirSuite__Service_Facility_Location_Information__c,
                              "serviceFacilityLocationInfoID" : res.currentViewClaimRecord[0].ElixirSuite__Servic_Fcility_Loc_Informaton_OtherID__c,
                              "serviceFacilityLocationInfoNPI" : res.currentViewClaimRecord[0].ElixirSuite__Service_Facility_Location_NPI__c,
                              "serviceFacilityLocationAddress" : res.currentViewClaimRecord[0].ElixirSuite__Service_Facility_Loc_Address__c,
                              "serviceFacilityLocationAddress2" : res.currentViewClaimRecord[0].ElixirSuite__Service_Facility_Address_2__c,
                              "serviceFacilityLocationCity" : res.currentViewClaimRecord[0].ElixirSuite__Service_Facility_Loc_City__c,
                              "serviceFacilityLocationState" : res.currentViewClaimRecord[0].ElixirSuite__Service_Facility_Loc_State__c,
                              "serviceFacilityLocationZip" : res.currentViewClaimRecord[0].ElixirSuite__Service_Facility_Loc_Zip__c,
                              "fromdatesPatientUnableTowork" : res.currentViewClaimRecord[0].ElixirSuite__From_Date_Patient_Unable_To_Work__c,
                              "todatesPatientUnableTowork" : res.currentViewClaimRecord[0].ElixirSuite__To_Date_Patient_Unable_To_Work__c,
                              "billingProviderInfo" : res.currentViewClaimRecord[0].ElixirSuite__Billing_Provider_Info__c,
                              "billingProviderInfoID" : res.currentViewClaimRecord[0].ElixirSuite__Billing_Provider_Other_ID__c, 
                              "signOfPhysician" : res.currentViewClaimRecord[0].ElixirSuite__Referring_Physician_Signature__c,
                              "DateOfsignOfPhysician" : res.currentViewClaimRecord[0].ElixirSuite__Sign_of_Phy_or_Supplier_Date__c,
                              "DiagnoNatureOfIllness" : '',
                              "SupsignOfPhysician" : res.currentViewClaimRecord[0].ElixirSuite__Sign_of_Phy_or_Supplier_Signature__c,
                              "ResubmissionCode" : res.currentViewClaimRecord[0].ElixirSuite__Resubmission_Code__c,
                              "AuthorizationNum" : '',
                              "PatientAccNo" : res.currentViewClaimRecord[0].ElixirSuite__Patient_Account_Number__c, 
                              "claimCodes" : res.currentViewClaimRecord[0].ElixirSuite__Claim_Codes__c,
                              "insuredAddress" : res.currentViewClaimRecord[0].ElixirSuite__Insured_Address__c,
"insuredAddress2" : res.currentViewClaimRecord[0].ElixirSuite__Insured_Address_2__c,
                              "patientAddress2" : res.currentViewClaimRecord[0].ElixirSuite__Patient_Address_2__c,
                              "insuredState" :  res.currentViewClaimRecord[0].ElixirSuite__Insured_State__c,
                              "insuredCity" :res.currentViewClaimRecord[0].ElixirSuite__Insured_City__c ,
                              "insuredZipcode" :  res.currentViewClaimRecord[0].ElixirSuite__Insured_Zip_Code__c,
                              "insuredTelephone" :  res.currentViewClaimRecord[0].ElixirSuite__Insured_Telephone__c,
                              "otherInsuredPolicyNumber" : 	res.currentViewClaimRecord[0].ElixirSuite__Other_Insured_s_Policy_Group_Number__c,
                              "insuredPolicyNumber" : 	res.currentViewClaimRecord[0].ElixirSuite__Insured_Policy__c,
                              "insuredDOB" : res.currentViewClaimRecord[0].ElixirSuite__Insured_DOB__c,
                              "autoAccPlaceOrState" : res.currentViewClaimRecord[0].ElixirSuite__Auto_Accident_Related__c,
                              "autoAccPlaceOrStateDisabled" : res.currentViewClaimRecord[0].ElixirSuite__Auto_Accident_Related__c,
                              "insuredSex" :  res.currentViewClaimRecord[0].ElixirSuite__Insured_Sex__c === 'F' ? 'Female' : (res.currentViewClaimRecord[0].ElixirSuite__Insured_Sex__c === 'M' ? 'Male' : 'Unknown'),
                              "otherInsuredName" : res.currentViewClaimRecord[0].ElixirSuite__Other_Insured_s_Name__c,
                              "otherInsurancePlanName" : res.currentViewClaimRecord[0].ElixirSuite__Other_Insurance_Plan_Name__c,
                              "billingProviderInfoOtherId" : '',
                              "hospitalisedFromDate" : res.currentViewClaimRecord[0].ElixirSuite__Hospitalization_From_Date__c,  
                              "hospitalisedToDate" : res.currentViewClaimRecord[0].ElixirSuite__Hospitalization_To_Date__c,
                              "outsideLabcharges" : res.currentViewClaimRecord[0].ElixirSuite__Outside_Lab_Charges__c, // xxx
                              "patientSign" : res.currentViewClaimRecord[0].ElixirSuite__Patient_Signature__c,
                              "insuredSign" : res.currentViewClaimRecord[0].ElixirSuite__Insured_Authorized_Person_Signature__c,
                              "TotalCharges" : res.currentViewClaimRecord[0].ElixirSuite__Total_Charge__c,
                              "billingProviderInfo" :res.currentViewClaimRecord[0].ElixirSuite__Billing_Provider_Info_NPI__c,
                              "billingProviderInfoID" : res.currentViewClaimRecord[0].ElixirSuite__Billing_Provider_Other_ID__c,
                              "billingProviderName":res.currentViewClaimRecord[0].ElixirSuite__Billing_Provider_Name__c,
                              "billingProviderAddress1":res.currentViewClaimRecord[0].ElixirSuite__Billing_Provider_Address_1__c,
                              "billingProviderAddress2":res.currentViewClaimRecord[0].ElixirSuite__Billing_Provider_Address_2__c,
                              "billingProviderCity":res.currentViewClaimRecord[0].ElixirSuite__Billing_Provider_City__c,
                              "billingProviderState":res.currentViewClaimRecord[0].ElixirSuite__Billing_Provider_State__c,
                              "billingProviderzipCode":res.currentViewClaimRecord[0].ElixirSuite__Billing_Provider_Zip__c,
                              "billingProviderPhone":res.currentViewClaimRecord[0].ElixirSuite__Bill_Phone__c,
                              "billingProviderTaxId":res.currentViewClaimRecord[0].ElixirSuite__Billing_Provider_Tax_ID__c,
                              "billingProviderTaxonomy":res.currentViewClaimRecord[0].ElixirSuite__Billing_Provider_Taxonomy__c,
                              "RenderingProvider_FirstName":res.currentViewClaimRecord[0].ElixirSuite__Rendering_Provider_First_Name__c,
                              "RenderingProvider_MiddleName":res.currentViewClaimRecord[0].ElixirSuite__Rendering_Provider_Middle_Name__c,
                              "RenderingProvider_LastName":res.currentViewClaimRecord[0].ElixirSuite__Rendering_Provider_Last_Name__c,
                              "RenderingProvider_Taxonomy":res.currentViewClaimRecord[0].ElixirSuite__Rendering_Provider_Taxonomy__c,
                              "RenderingProvider_NPI":res.currentViewClaimRecord[0].ElixirSuite__Rendering_Provider_NPI__c,
                              "RenderingProvider_TaxId":res.currentViewClaimRecord[0].ElixirSuite__Rendering_Provider_Tax_Id__c
                             }
                if(insideJson.IsthereanotherHealthBenefitPlan == "NO"){
                    insideJson.otherInsuredName = '';
                    insideJson.otherInsuredPolicyNumber = '';
                    insideJson.reserverdforNUCCuse2 = '';
                    insideJson.reservedforNUCCuse3 = '';
                    insideJson.otherInsurancePlanName = '';
                }
                
                //  console.log('fj' , insideJson);
                completeJson.push(insideJson);
                var rec ={};
                rec = {"id" : res.accDetails.Id,
                       "transactionalDataId": res.vobData[0].Id,
                       "Record" : JSON.parse(JSON.stringify(completeJson))
                      };
                jsonList.push(rec);
                
                
                component.set("v.jsonList",JSON.parse(JSON.stringify(jsonList)));
                component.set("v.transactionalDataId" ,res.vobData[0].Id );
                // console.log('fnj' , component.get("v.jsonList"));
                /**********MY UPDATES ************************/
                var picklistArr = res.allPickListPlaceOfService_ValuesIntoList;
                console.log('picklistArr--'+picklistArr);
                
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
                    console.log('textName--'+textName);
                    console.log('codeArr--'+codeArr);
                    var toSetValue = textName+';'+codeArr.join('-');
                    
                    
                    var sObj = {'label' : picklistArr[rec],'value' : picklistArr[rec]};
                    
                    console.log('sObj-->'+sObj);
                    arrToSet.push(sObj);
                }
                console.log('arrToSet -- '+JSON.stringify(arrToSet));
                component.set("v.placeOfServiceArray",arrToSet);
                // alert('to set val ' , JSON.stringify(component.get("v.placeOfServiceArray")));
                helper.buildPicklistWrapperForClaimFields(component, event,helper);
                /********************************************/
                component.set("v.loaded",true);
                // alert('ins name set last '+ component.get("v.commaSeparInsudName"));
            }
            
            else if (state === "ERROR") {
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
    handleEditForSingleInstanceApprovalRecord : function(component, event, helper){
        component.set("v.editAbility",false);
        let procArr = component.get("v.transactionaljsonList"); 
        procArr[0].Record[0].isDateSearchingDisabled = false;
        let arr =   procArr[0].Record;
        let index = 0; 
        let isPrefetchedRecord = false;
        for(let rec in arr){
            if(arr[rec].claiLineItemRecordID){
                isPrefetchedRecord = true;
                arr[rec].isDateSearchingDisabled = false;
                arr[rec].isRowDisabled = false;
                index++;
            }
            
        }
        if(isPrefetchedRecord){
            if(index<=5){
                procArr[0].Record[index].isDateSearchingDisabled = false;   
            }
        }
        
        component.set("v.transactionaljsonList",procArr); 
        
        
        let parentJSON =  component.get("v.jsonList");
        if(parentJSON[0].Record[0]['IsthereanotherHealthBenefitPlan']){
            component.set("v.enableSecInsurance",false);
        }
        
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
        console.log(event.getSource().get("v.value"));
        var name = event.getSource().get("v.name");
        var array = name.split('$');
        var value = array[0];
        var field = array[1];
        
        var parentJSON =  component.get("v.jsonList");
        parentJSON[0].Record[0]['insuranceType'] = array[0];
        component.set("v.jsonList",parentJSON);
        
        
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
        console.log(event.getSource().get("v.value"));
        var name = event.getSource().get("v.name");
        var array = name.split('$');
        var value = array[0];
        var field = array[1];
        var parentJSON =  component.get("v.jsonList");
        parentJSON[0].Record[0].relationWithInsured = array[0];
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
            
            component.set("v.autoAccPlaceOrStateDisabled",false);
        }
        else if(value == 'NO')
        {
            var parentJSON =  component.get("v.jsonList");
            parentJSON[0].Record[0].autoAccPlaceOrState = '';
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
    searchProcdureInSpecifiedDate : function(component, event, helper) { // xxx
        try{
            var name = event.getSource().get("v.name");
            
            var array = name.split('$');
            var parentIndex = array[0];
            var childIndex = array[1];
            var value = event.getSource().get("v.value");
            var parentJSON =  component.get("v.transactionaljsonList");
            component.set("v.parentindexValue",parentIndex);
            component.set("v.childindexValue",childIndex);
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
                                    // parentJSON[parentIndex].Record[childIndex].isRowDisabled = true; 
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
            }
        }
        bufferTotal+= instanceAmt;
        let jsonList = component.get("v.jsonList");
        jsonList[0].Record[0].TotalCharges = bufferTotal;
        component.set("v.jsonList",jsonList);
        
    },
    searchProcdureInSpecifiedDate_IfFromMissed : function(component, event, helper) {
        try{
            var name = event.getSource().get("v.name");
            var array = name.split('$');
            var parentIndex = array[0];
            var childIndex = array[1];
            var value = event.getSource().get("v.value"); // fromDate
            var parentJSON =  component.get("v.transactionaljsonList");
            component.set("v.parentindexValue",parentIndex);
            component.set("v.childindexValue",childIndex);
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
                                //  parentJSON[parentIndex].Record[childIndex].isRowDisabled = true;
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
        var recordId = component.get("v.recordId");
        var navEvent = $A.get("e.force:navigateToSObject");
        navEvent.setParams({
            "recordId": recordId,
            "slideDevName": "detail"
        });
        navEvent.fire();
        $A.get('e.force:refreshView').fire();
        //  component.set("v.OpenPopUp",false);
        
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
    handleBillingProviderInfoNpi : function(component,event,helper){
        console.log("called handle");
        helper.validateBillingProviderNpi(component,event,helper);
    },
    validatebillingProviderZipcode : function(component,event,helper){
        console.log("called handle");
        helper.validateBillingProviderZip(component,event,helper);
    },
    billingProviderPhone : function(component,event,helper){
        console.log("called handle");
        helper.validateBillProviderPhone(component,event,helper);
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
                            alert('chkkkk');
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
        try{
            var sendDataToInsurance=false; //Anusha -start - 03/11/22
            if(event.getSource().get("v.name")!='Save'){
                sendDataToInsurance=true;
            }
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
            if(component.get("v.claimProcessedVia") && sendDataToInsurance){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "error",
                    "message": "Claim for this payor can’t be send out to clearing house."
                });
                toastEvent.fire();
                return;
            }
            //var globalReqCheckValid = true;
            if(globalReqCheckValid && fedTaxNumCheckValid && isValid && isValidzip && isValidphone){
                var jsonData = component.get("v.jsonList");
                console.log('js 1 for my updates' , JSON.stringify(jsonData));
                var tableData = component.get("v.transactionaljsonList");
                console.log('js 2  for my updates' , JSON.stringify(tableData));
                component.set("v.loaded",false); // xxx 
                var selectedClaimCodes = JSON.parse(JSON.stringify(component.get("v.dropDownSelectedValues"))); // xxx
                console.log('selectedClaimCodes--' ,selectedClaimCodes.join(';'));
                var dropDownOptions = {'keysToSave' : component.get("v.dropDownOptions"),
                                      }; // xxx
                console.log('dropDownOptions--' , JSON.stringify(dropDownOptions));
                if( $A.util.isUndefinedOrNull(component.get('v.totalAmount'))){
                    component.set("v.totalAmount",0);
                }
                var action = component.get("c.saveData");
                console.log('totalAmount--' ,  component.get("v.totalAmount"));
                console.log('transactionalDataId--' ,  component.get("v.transactionalDataId"));
                console.log('payorName--' ,  component.get("v.payorName"));
                action.setParams({
                    "jsonListData" : JSON.stringify(jsonData),
                    "tabelListData" : JSON.stringify(tableData),
                    "recordVal" : component.get("v.patId"),
                    "totalAmount" : component.get("v.totalAmount"),
                    "transId" : component.get("v.transactionalDataId"),
                    "payorName" : component.get("v.payorName"),
                    "dropDownOptions" : JSON.stringify(dropDownOptions),
                    "selectedClaimCodes" : selectedClaimCodes.join(';'),
                    "sendToInsurance" : sendDataToInsurance,
                    "ProcIDs" :  component.get("v.attachedProcId"),
                });
                action.setCallback(this,function(response) {
                    var state = response.getState();
                    console.log('state--' ,  response.getState());
                    if (state === "SUCCESS") {
                        component.set("v.loaded",true); // xxx 
                        console.log('success');
                        //var allData = response.getReturnValue();
                        //  console.log('allData--'+JSON.Stringify(allData));
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "type": "Success",
                            "title": "CLAIM UPDATED SUCCESSFULLY !!",
                            "message": "Updated Successful!"
                        });
                        toastEvent.fire();     
                        component.set("v.editAbility",true);
                        let procArr = component.get("v.transactionaljsonList"); 
                        let arr =   procArr[0].Record; 
                        for(let rec in arr){
                            arr[rec].isDateSearchingDisabled = true;
                            arr[rec].isRowDisabled = true;
                        }
                        
                        component.set("v.transactionaljsonList",procArr); 
                        var recordId = component.get("v.recordId");
                        var navEvent = $A.get("e.force:navigateToSObject");
                        navEvent.setParams({
                            "recordId": recordId,
                            "slideDevName": "detail"
                        });
                        navEvent.fire();
                        $A.get('e.force:refreshView').fire();
                        
                    }
                    else {
                        component.set("v.loaded",true); // xxx 
                        
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "type": "error",
                            "title": "ERROR!",
                            "message": "Error!"
                        });
                        toastEvent.fire();  
                        var errors = response.getError();
                        if (errors) {
                            if (errors[0] && online[0].message) {
                                console.log("Error message: " +
                                            errors[0].message);
                            }
                        }
                        
                    }
                });
                $A.enqueueAction(action); 
            }
            else {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "error",
                    "title": "PLEASE FILL ALL THE MANDATORY FIELDS !",
                    "message": "Please fill mandatory fields!"
                });
                toastEvent.fire();   
            }
            
        }
        catch(err) { 
            console.log('err.message' +err.message);
        }
    },
    navigateToRecord: function(component, event, helper) {
        var recordId = component.get("v.recordId");
        var recordUrl = "/lightning/r/ElixirSuite__Claim__c/" + recordId + "/view";
        window.location.href = recordUrl;
    }
})
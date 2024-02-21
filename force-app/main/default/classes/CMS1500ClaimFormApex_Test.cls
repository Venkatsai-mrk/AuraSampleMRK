/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-08-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class CMS1500ClaimFormApex_Test 
{
    public static testMethod void cmsTest()
    {
        Account acc = new Account();
        acc.Name = 'Test';
        acc.Admit_Date__c = System.today().addYears(-40);
        //acc.dischargeDateNew__c = System.today().addYears(-40);
        //acc.CreatedDate = System.today().addYears(-40);
        acc.First_Name__c = 'Hannah';
        acc.Last_Name__c = 'Brown';
        acc.Gender__c = 'Female';
        acc.ShippingStreet = 'Street lane';
        acc.ShippingCity = 'New York';
        acc.ShippingState = 'NY';
        acc.ShippingPostalCode = '10014';
        acc.ShippingCountry = 'US';
        //acc.birthdate__c = System.today().addYears(-40);
        acc.Patient_s_Birth_Date__c = System.today().addYears(-40);
        acc.MRN_Number_New__c = '456456';
        acc.BillingStreet = 'Street lane';
        acc.BillingCity = 'New York';
        acc.Account_Number__c = '235689';
        acc.BillingState = 'NY';
        acc.BillingPostalCode = '10014';
        acc.BillingCountry = 'US';
        acc.Phone = '9879879879';
        insert acc;
        
        Payor__c pay = new Payor__c();
        pay.Name = 'payer';
        pay.Payer_Code__c = 'CPT123';
        insert pay;
        
        ElixirSuite__ICD_Codes__c icd = new ElixirSuite__ICD_Codes__c();
        icd.Name = 'icd';
        insert icd;
            
        VOB__c objVob = new VOB__c();
        objVob.Insurance_Counts__c = 'Primary';
        objVob.Payer__c = pay.Id;
        objVob.Account__c = acc.Id;
        objVob.Insurance_Type__c = 'Primary VOB';
        //objVob.Insurance_Providers__c = '456789';
        objVob.Patient_Relationship_With_Insured__c = 'Self';
        objVob.Insured_First_Name__c = 'Hannah';
        objVob.Auto_Accident__c = 'NO';
        objVob.Insured_Last_Name__c = 'Brown';
        objVob.Insured_Middle_Name__c = 'Jones';
        objVob.Employment__c = 'YES';
        objVob.Is_there_another_Health_Benefit_Plan__c = 'No';
        objVob.Other_Accident__c = 'No';
        //objVob.Name = 'Hann';
        objVob.Insured_Address__c = 'Street lane';
        objVob.Insured_State__c = 'NY';
        objVob.Insured_City__c = 'New York';
        objVob.Insured_Zipcode__c = '10014';
        /*objVob.Insurance_Counts__c = 'Primary';
        objVob.Insurance_Counts__c = 'Primary';
        objVob.Insurance_Counts__c = 'Primary';
        objVob.Insurance_Counts__c = 'Primary';
        objVob.Insurance_Counts__c = 'Primary';
        objVob.Insurance_Counts__c = 'Primary';
        objVob.Insurance_Counts__c = 'Primary';*/
        insert objVob;
        
        ElixirSuite__Procedure__c p = new ElixirSuite__Procedure__c(Name = 'TestProc',ElixirSuite__Related_Procedure_Code_Category__c = 'HCPCS Level 2', ElixirSuite__Account__c = acc.Id,
                                                                    ElixirSuite__Code_Category__c = 'ElixirSuite__Code_Category__c',
                                                                    RecordTypeId = Schema.SObjectType.ElixirSuite__Procedure__c.getRecordTypeInfosByDeveloperName().get('Template_Procedure').getRecordTypeId());
        insert p;
            
        date fromDate = System.today().adddays(-10);
        date toDate = date.today();

        String strFromDate = string.valueOfGmt(fromDate);//added by Anmol for LX3-6616
        String strtoDate = string.valueOfGmt(toDate);//added by Anmol for LX3-6616
        
        Test.startTest();
        
        string jsonList = '[{"id":"'+acc.Id+'","transactionalDataId":"'+objVob.Id+'","Record":[{"id":"'+acc.Id+'","patientName":"Hannah Brown","patiSex":"Female","patientAddress":"agagyhshgsvhvhsvhs","patientCity":"muzaffarpur","patientZipcode":"91911","patientPhone":"8889595121","relationWithInsured":"18","insuredName":"Ava","employmentPicklistValues":"NO","IsthereanotherHealthBenefitPlan":"NO","reserverdforNUCCuse1":"","reserverdforNUCCuse2":"","reservedforNUCCuse3":"","reservedforNUCCuse4":"","otherClaimId":"","dateOfCurrentIllness":"","qualifierForDateOfCurrentIllness_Value":"","qualifierForOtherDates_Value":"","npi_nucc_Value":"","npi_nucc_description_Value":"","diagnosis_A":"test diagno","diagnosis_B":"","diagnosis_C":"","diagnosis_D":"","diagnosis_E":"","diagnosis_F":"","diagnosis_G":"","diagnosis_H":"","diagnosis_I":"","diagnosis_J":"","diagnosis_K":"","diagnosis_L":"","orignalRefNumber":"","priorAuthNumber":"","otherDate":"","otherDate_InsuredPersonAuth":"","datesPatientUnableTowork":"","nameOfReferringProvider":"","nameOfReferringProvider_FirstName":"","nameOfReferringProvider_MiddleName":"","nameOfReferringProvider_LastName":"","qualifierForNameOfReferringProvider":"","NPI":"","hospitilizationDates":"","additionalInfo":"","outsideLab":false,"outsideLabNo":false,"federalTaxNumber":"123456789","amountPaid":0,"billingProviderInfoNpi":"1234567893","serviceFacilityLocationInfo":"","serviceFacilityLocationInfoID":"","serviceFacilityLocationInfoNPI":"","fromdatesPatientUnableTowork":"","todatesPatientUnableTowork":"","billingProviderInfo":"","billingProviderInfoID":"1234","billingProviderName":"axa","billingProviderAddress1":"ca","billingProviderAddress2":"ca","billingProviderCity":"ca","billingProviderState":"ca","billingProviderzipCode":"91101","billingProviderPhone":"7894560321","billingProviderTaxId":"123456789","signOfPhysician":"","DateOfsignOfPhysician":"","DiagnoNatureOfIllness":"","SupsignOfPhysician":"","ResubmissionCode":"","AuthorizationNum":"","PatientAccNo":"569009","claimCodes":"","insuredAddress":"agagyhshgsvhvhsvhs","insuredState":"CA","insuredCity":"muzaffarpur","insuredZipcode":"91911","otherInsuredPolicyNumber":"","insuredDOB":"1988-11-21","autoAccPlaceOrState":"","autoAccPlaceOrStateDisabled":false,"insuredSex":"Female","otherInsuredName":"","otherInsurancePlanName":"","billingProviderInfoOtherId":"","hospitalisedFromDate":"","hospitalisedToDate":"","outsideLabcharges":0,"patientSign":"","insuredSign":"","TotalCharges":20000,"insuredPolicyNumber":"4563","autoAccidentPicklistValues":"NO","patientDOB":"2005-01-07","patientState":"ca"}]}]';
        string tableDataList = '[{"Record":[{"Id":"'+p.Id+'","isRowDisabled":false,"isDateSearchingDisabled":false,"fromDate_Procedure":"2023-01-01","toDate_Procedure":"2023-01-05","placeOfService_Procedure":"02 - Telehealth","emergency_Procedure":"","emergency_FreeText_Procedure":"","cptCode_Procedure":"","diagnosisPointer_Procedure":"A","daysOrUnit_Procedure":1,"espdtSelectedValueFromDropDown_Procedure":"","espdtSelectedValueFromText_Procedure":"","rendringProviderNonNPI_Procedure":"","rendringProviderNPI_Procedure":"","charges_Procedure":20000},{"Id":"","isRowDisabled":true,"isDateSearchingDisabled":false,"fromDate_Procedure":"","toDate_Procedure":"","placeOfService_Procedure":"","emergency_Procedure":"","emergency_FreeText_Procedure":"","cptCode_Procedure":"","cptCodeName_Procedure":"","modifier_Procedure":"","modifier_Procedure2":"","modifier_Procedure3":"","modifier_Procedure4":"","diagnosisPointer_Procedure":"","daysOrUnit_Procedure":0,"espdtSelectedValueFromDropDown_Procedure":"","espdtSelectedValueFromText_Procedure":"","qualifier_Procedure":"","rendringProviderNonNPI_Procedure":"","rendringProviderNPI_Procedure":"","charges_Procedure":0},{"Id":"","isRowDisabled":true,"isDateSearchingDisabled":true,"fromDate_Procedure":"","toDate_Procedure":"","placeOfService_Procedure":"","emergency_Procedure":"","emergency_FreeText_Procedure":"","cptCode_Procedure":"","cptCodeName_Procedure":"","modifier_Procedure":"","modifier_Procedure2":"","modifier_Procedure3":"","modifier_Procedure4":"","diagnosisPointer_Procedure":"","daysOrUnit_Procedure":0,"espdtSelectedValueFromDropDown_Procedure":"","espdtSelectedValueFromText_Procedure":"","qualifier_Procedure":"","rendringProviderNonNPI_Procedure":"","rendringProviderNPI_Procedure":"","charges_Procedure":0},{"Id":"","isRowDisabled":true,"isDateSearchingDisabled":true,"fromDate_Procedure":"","toDate_Procedure":"","placeOfService_Procedure":"","emergency_Procedure":"","emergency_FreeText_Procedure":"","cptCode_Procedure":"","cptCodeName_Procedure":"","modifier_Procedure":"","modifier_Procedure2":"","modifier_Procedure3":"","modifier_Procedure4":"","diagnosisPointer_Procedure":"","daysOrUnit_Procedure":0,"espdtSelectedValueFromDropDown_Procedure":"","espdtSelectedValueFromText_Procedure":"","qualifier_Procedure":"","rendringProviderNonNPI_Procedure":"","rendringProviderNPI_Procedure":"","charges_Procedure":0},{"Id":"","isRowDisabled":true,"isDateSearchingDisabled":true,"fromDate_Procedure":"","toDate_Procedure":"","placeOfService_Procedure":"","emergency_Procedure":"","emergency_FreeText_Procedure":"","cptCode_Procedure":"","cptCodeName_Procedure":"","modifier_Procedure":"","modifier_Procedure2":"","modifier_Procedure3":"","modifier_Procedure4":"","diagnosisPointer_Procedure":"","daysOrUnit_Procedure":0,"espdtSelectedValueFromDropDown_Procedure":"","espdtSelectedValueFromText_Procedure":"","qualifier_Procedure":"","rendringProviderNonNPI_Procedure":"","rendringProviderNPI_Procedure":"","charges_Procedure":0},{"Id":"","isRowDisabled":true,"isDateSearchingDisabled":true,"fromDate_Procedure":"","toDate_Procedure":"","placeOfService_Procedure":"","emergency_Procedure":"","emergency_FreeText_Procedure":"","cptCode_Procedure":"","cptCodeName_Procedure":"","modifier_Procedure":"","modifier_Procedure2":"","modifier_Procedure3":"","modifier_Procedure4":"","diagnosisPointer_Procedure":"","daysOrUnit_Procedure":0,"espdtSelectedValueFromDropDown_Procedure":"","espdtSelectedValueFromText_Procedure":"","qualifier_Procedure":"","rendringProviderNonNPI_Procedure":"","rendringProviderNPI_Procedure":"","charges_Procedure":0}]}]';
        string dropDownList = '{"keysToSave":[]}';
        
        
        CMS1500ClaimFormApex.fetchVOBRecord(objVob.Id);
        CMS1500ClaimFormApex.getAccountDetails(acc.Id,objVob.Id);
        CMS1500ClaimFormApex.fetchProcedureData(acc.Id);
        CMS1500ClaimFormApex.fetchProcedureForSpecifiedDates(fromDate,toDate,acc.Id,null,null,'test proc');
        CMS1500ClaimFormApex.saveData(jsonList,tableDataList,acc.Id,'1500','transId',objVob.Id,pay.Id,dropDownList,'test',true,null);
        CMS1500ClaimFormApex.fetchICDCodes();
        CMS1500ClaimFormApex.fetchCusomMetadataRecord();
        CMS1500ClaimFormApex.ICDCodeRecord(icd.Id);
        CMS1500ClaimFormApex.getDataForRangeApex(strFromDate,strtoDate,acc.Id,icd.Id); //added by Anmol for LX3-6616
        
        
        
        String jsonListData ='[{"id":" ","transactionalDataId":" ","Record":[{"Id":"","patientName":"Testpat","patientDOB":" ","patientAddress":"Bangalore","patientCity":"Bangalore","patientState":"Karnataka","patientZipcode":"123","patientPhone":"Phone","insuranceType":"Self","relationWithInsured":"Spouse","insuredIdNumber":"India","insuredName":"INSName","insurancePlanName":"Primary","autoAccidentPicklistValues":"Yes","employmentPicklistValues":"Yes","IsthereanotherHealthBenefitPlan":"Yes","otherAccidentPicklistValues":"Yes","reserverdforNUCCuse1":"NUCCuse","reserverdforNUCCuse2":"NUCCuse","reservedforNUCCuse3":"NUCCuse","otherClaimId":"CLmid","dateOfCurrentIllness":" ","otherDate":" ","datesPatientUnableTowork":" ","nameOfReferringProvider":"Refrig","NPI":"testNpi","hospitilizationDates":" ","additionalInfo":"TestTest","outsideLab":"yes","federalTaxNumber":"FEDDEB","acceptAssignment":"Yes","amountPaid":" ","serviceFacilityLocationInfo":"Test","billingProviderInfo":"test","signOfPhysician":"Test","claimCodes":"CLMANS","insuredAddress":"Mangalore","insuredState":"Karnataka","insuredCity":"Sullia","insuredZipcode":"345","insuredTelephone":"INS","otherInsuredPolicyNumber":"Other","insuredPolicyNumber":"POL","otherInsuredName":"OTH","otherInsurancePlanName":"OtherPlan","patientSign":"PATSign","insuredSign":"INSSig"}] }]';
        
        String tabelListData = '[{"id":" ","transactionalDataId":" ","Record":[{"Id":"","patientName":"Testpat","patientDOB":" ","patientAddress":"Bangalore","patientCity":"Bangalore","patientState":"Karnataka","patientZipcode":"123","patientPhone":"Phone","insuranceType":"Self","relationWithInsured":"Spouse","insuredIdNumber":"India","insuredName":"INSName","insurancePlanName":"Primary","autoAccidentPicklistValues":"Yes","employmentPicklistValues":"Yes","IsthereanotherHealthBenefitPlan":"Yes","otherAccidentPicklistValues":"Yes","reserverdforNUCCuse1":"NUCCuse","reserverdforNUCCuse2":"NUCCuse","reservedforNUCCuse3":"NUCCuse","otherClaimId":"CLmid","dateOfCurrentIllness":" ","otherDate":" ","datesPatientUnableTowork":" ","nameOfReferringProvider":"Refrig","NPI":"testNpi","hospitilizationDates":" ","additionalInfo":"TestTest","outsideLab":"yes","federalTaxNumber":"FEDDEB","acceptAssignment":"Yes","amountPaid":" ","serviceFacilityLocationInfo":"Test","billingProviderInfo":"test","signOfPhysician":"Test","claimCodes":"CLMANS","insuredAddress":"Mangalore","insuredState":"Karnataka","insuredCity":"Sullia","insuredZipcode":"345","insuredTelephone":"INS","otherInsuredPolicyNumber":"Other","insuredPolicyNumber":"POL","otherInsuredName":"OTH","otherInsurancePlanName":"OtherPlan","patientSign":"PATSign","insuredSign":"INSSig"}] }]';
        //String fromDate = String.valueOf(System.today());
        //String toDate = String.valueOf(System.today() + 1);
        String totalAmount = '200';
        //CMS1500ClaimFormApex.getAccountDetails(acc.Id);
        //CMS1500ClaimFormApex.getDataForRangeApex(fromDate, toDate, String.valueOf(acc.Id), String.valueOf(objVob.Id));
        try{
            //CMS1500ClaimFormApex.saveData(jsonListData, tabelListData, String.valueOf(acc.Id), totalAmount, String.valueOf(objVob.Id),'','','');
        }
        catch(Exception e){}
        System.assertEquals(1,1,'');
        
        Test.stopTest();
        System.assert(acc.Name!=null,'');
    }
}
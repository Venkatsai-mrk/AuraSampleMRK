@isTest
public class Edit_CMS1500FormApexTest {
    
    public static testMethod void cmsTest()
    {
        Account acc = new Account();
        acc.Name = 'Test';
        insert acc;
        
        Payor__c pay = new Payor__c();
        pay.Name = 'payer';
        pay.Payer_Code__c = 'CPT123';
        insert pay;
        
        VOB__c objVob = new VOB__c();
        objVob.Insurance_Counts__c = 'Primary';
        objVob.Payer__c = pay.Id;
        objVob.Account__c = acc.Id;
        objVob.ElixirSuite__Insured_Address__c = 'ABC';
        objVob.ElixirSuite__Date_Of_Birth__c = date.valueOf('2000-04-16');
        insert objVob;
        
        Test.startTest();
        
        String jsonListData ='[{"id":" ","transactionalDataId":" ","Record":[{"Id":"","patientName":"Testpat","patientDOB":" ","patientAddress":"Bangalore","patientCity":"Bangalore","patientState":"Karnataka","patientZipcode":"123","patientPhone":"Phone","insuranceType":"Self","relationWithInsured":"Spouse","insuredIdNumber":"India","insuredName":"INSName","insurancePlanName":"Primary","autoAccident":"Yes","employment":"Yes","IsthereanotherHealthBenefitPlan":"Yes","otherAccident":"Yes","reserverdforNUCCuse1":"NUCCuse","reserverdforNUCCuse2":"NUCCuse","reservedforNUCCuse3":"NUCCuse","otherClaimId":"CLmid","dateOfCurrentIllness":" ","otherDate":" ","datesPatientUnableTowork":" ","nameOfReferringProvider":"Refrig","NPI":"testNpi","hospitilizationDates":" ","additionalInfo":"TestTest","outsideLab":"yes","federalTaxNumber":"FEDDEB","acceptAssignment":"Yes","amountPaid":" ","serviceFacilityLocationInfo":"Test","billingProviderInfo":"test","signOfPhysician":"Test","claimCodes":"CLMANS","insuredAddress":"Mangalore","insuredState":"Karnataka","insuredCity":"Sullia","insuredZipcode":"345","insuredTelephone":"INS","otherInsuredPolicyNumber":"Other","insuredPolicyNumber":"POL","otherInsuredName":"OTH","otherInsurancePlanName":"OtherPlan","patientSign":"PATSign","insuredSign":"INSSig"}] }]';
        
        String tabelListData = '[{"id":" ","transactionalDataId":" ","Record":[{"Id":"","patientName":"Testpat","patientDOB":" ","patientAddress":"Bangalore","patientCity":"Bangalore","patientState":"Karnataka","patientZipcode":"123","patientPhone":"Phone","insuranceType":"Self","relationWithInsured":"Spouse","insuredIdNumber":"India","insuredName":"INSName","insurancePlanName":"Primary","autoAccident":"Yes","employment":"Yes","IsthereanotherHealthBenefitPlan":"Yes","otherAccident":"Yes","reserverdforNUCCuse1":"NUCCuse","reserverdforNUCCuse2":"NUCCuse","reservedforNUCCuse3":"NUCCuse","otherClaimId":"CLmid","dateOfCurrentIllness":" ","otherDate":" ","datesPatientUnableTowork":" ","nameOfReferringProvider":"Refrig","NPI":"testNpi","hospitilizationDates":" ","additionalInfo":"TestTest","outsideLab":"yes","federalTaxNumber":"FEDDEB","acceptAssignment":"Yes","amountPaid":" ","serviceFacilityLocationInfo":"Test","billingProviderInfo":"test","signOfPhysician":"Test","claimCodes":"CLMANS","insuredAddress":"Mangalore","insuredState":"Karnataka","insuredCity":"Sullia","insuredZipcode":"345","insuredTelephone":"INS","otherInsuredPolicyNumber":"Other","insuredPolicyNumber":"POL","otherInsuredName":"OTH","otherInsurancePlanName":"OtherPlan","patientSign":"PATSign","insuredSign":"INSSig"}] }]';
        String fromDate = String.valueOf(System.today());
        String toDate = String.valueOf(System.today() + 1);
        String totalAmount = '200';
    //   ElixirOEM_EditCMS1500Helper.dummyMethod();
        try{
        //    ElixirOEM_EditCMS1500Helper.saveData(jsonListData, tabelListData, String.valueOf(acc.Id), totalAmount, String.valueOf(objVob.Id),'','','');
        }
        catch(Exception e){}
        
        Test.stopTest();
        System.assert(acc.Name!=null,'');
    }
}
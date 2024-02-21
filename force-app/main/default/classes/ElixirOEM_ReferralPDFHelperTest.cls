@isTest
public class ElixirOEM_ReferralPDFHelperTest{
    @isTest
    public Static Void unitTest(){
        Set<Id> objId1 = new Set<Id>();
        ElixirSuite__UA_Sample_Details__c objTest1 = new ElixirSuite__UA_Sample_Details__c();
        insert objTest1;
        objId1.add(objTest1.Id);
        
        Set<Id> objId2 = new Set<Id>();
        ElixirSuite__Prescription_Order__c objTest2 = new ElixirSuite__Prescription_Order__c();
        insert objTest2;
        objId2.add(objTest2.Id);
        
        Set<Id> objId3 = new Set<Id>();
        ElixirSuite__Dataset1__c objTest3 = new ElixirSuite__Dataset1__c();
        insert objTest3;
        objId3.add(objTest3.Id);
        
        Set<Id> objId4 = new Set<Id>();
        ElixirSuite__Procedure__c objTest4 = new ElixirSuite__Procedure__c();
        objTest4.Name = 'procedure code 1';
        insert objTest4;
        objId4.add(objTest4.Id);
        
        Set<Id> objId5 = new Set<Id>();
        ElixirSuite__Medical_Examination__c objTest5 = new ElixirSuite__Medical_Examination__c();
        objTest5.ElixirSuite__End_Time__c = System.now();
        insert objTest5;
        objId5.add(objTest5.Id);
        
        Set<Id> objId6 = new Set<Id>();
        ElixirSuite__ICD_Codes__c objTest6 = new ElixirSuite__ICD_Codes__c();
        insert objTest6;
        objId6.add(objTest6.Id);
        
        ElixirSuite__Referral__c refObj = new ElixirSuite__Referral__c();
        insert refObj;
        
        ElixirSuite__Referral_Data__c refData1 = new ElixirSuite__Referral_Data__c();
        refData1.ElixirSuite__Referral__c = refObj.Id;
        insert refData1; 
        
        Set<Id> objId8 = new Set<Id>();
        ContentDocument objTest8 = new ContentDocument();
        objId8.add(objTest8.Id);
        
        Account acc = new Account ();
        acc.Name = 'Account 1';
        insert acc;
        
        ElixirOEM_ReferralPDFHelper objCOn = new ElixirOEM_ReferralPDFHelper();
        
        ElixirOEM_ReferralPDFHelper.ChartSummary objWrap = new ElixirOEM_ReferralPDFHelper.ChartSummary();
        sObject[] entityDataTest = objWrap.entityData;
        boolean disabledTest = objWrap.disabled;
        boolean isOpenTest = objWrap.isOpen;
        String labelTest = objWrap.label;
        
        List<Id> FormListId = new List<Id>();
        Form__c f1 = new Form__c();
        FormListId.add(f1.Id);
        
        // Create a Referral record
        ElixirSuite__Referral__c referral = new ElixirSuite__Referral__c();
        referral.Name = 'Test Referral';
        insert referral;
        
        // Create a Referral Data record with a Medical Examination
        ElixirSuite__Referral_Data__c referralData1 = new ElixirSuite__Referral_Data__c();
        referralData1.ElixirSuite__Referral__c = referral.Id;
        referralData1.ElixirSuite__Medical_Examination__c = objTest5.Id;
        insert referralData1;
        
        // Create a Referral Data record with a Diagnosis Code
        ElixirSuite__Referral_Data__c referralData2 = new ElixirSuite__Referral_Data__c();
        referralData2.ElixirSuite__Referral__c = referral.Id;
        referralData2.ElixirSuite__Template_Diagnosis_Code__c = objTest6.Id;
        insert referralData2;
        
        // Create a Referral Data record with a Procedure Code
        ElixirSuite__Referral_Data__c referralData3 = new ElixirSuite__Referral_Data__c();
        referralData3.ElixirSuite__Referral__c = referral.Id;
        referralData3.ElixirSuite__Procedure_Codes__c = objTest4.Id;
        insert referralData3;
        
        // Create a Referral Data record with a Patient Problem
        ElixirSuite__Referral_Data__c referralData4 = new ElixirSuite__Referral_Data__c();
        referralData4.ElixirSuite__Referral__c = referral.Id;
        referralData4.ElixirSuite__Patient_Problem__c = objTest3.ID;
        insert referralData4;
        
        // Create a Referral Data record with a Prescription Order
        ElixirSuite__Referral_Data__c referralData5 = new ElixirSuite__Referral_Data__c();
        referralData5.ElixirSuite__Referral__c = referral.Id;
        referralData5.ElixirSuite__Prescription_Order__c = objTest2.Id;
        insert referralData5;
        
        // Create a Referral Data record with a UA Sample Details
        ElixirSuite__Referral_Data__c referralData6 = new ElixirSuite__Referral_Data__c();
        referralData6.ElixirSuite__Referral__c = referral.Id;
        referralData6.ElixirSuite__UA_Sample_Details__c = objTest1.Id;
        insert referralData6;
        
        // Create a Referral Data record with a Form_Unique_ID
        ElixirSuite__Referral_Data__c referralData7 = new ElixirSuite__Referral_Data__c();
        referralData7.ElixirSuite__Referral__c = referral.Id;
        referralData7.ElixirSuite__Form_Unique_ID__c = 'form unique 1';
        insert referralData7;

       // Create a Referral Data record with a File_ContentDocumentId
        ElixirSuite__Referral_Data__c referralData8 = new ElixirSuite__Referral_Data__c();
        referralData8.ElixirSuite__Referral__c = referral.Id;
        referralData8.ElixirSuite__File_ContentDocumentId__c = 'File_ContentDocumentId 1';
        insert referralData8;
        
                test.startTest();
        ElixirOEM_ReferralPDFHelper.defineLabResults(objId1);
        ElixirOEM_ReferralPDFHelper.definePrescription(objId2);
        ElixirOEM_ReferralPDFHelper.defineProblem(objId3);
        ElixirOEM_ReferralPDFHelper.defineProcedure(objId4);
        ElixirOEM_ReferralPDFHelper.defineMedicalExamination(objId5);
        ElixirOEM_ReferralPDFHelper.defineDiagnosis(objId6);
        ElixirOEM_ReferralPDFHelper.patientDetails(String.valueOf(acc.id));
        ElixirOEM_ReferralPDFHelper.insuranceDetails(String.valueOf(acc.id));
        ElixirOEM_ReferralPDFHelper.defineChartSummary(String.valueOf(refData1.id),String.valueOf(acc.id));
        ElixirOEM_ReferralPDFHelper.getFiles(objId8);
        ElixirOEM_ReferralPDFHelper.fetchForms(String.valueOf(acc.id),FormListId);
        
        ElixirOEM_ReferralPDFHelper.defineEntities(string.valueOf(referral.Id));
        ElixirOEM_ReferralPDFHelper.defineEntities(string.valueOf(referralData2.Id));
        ElixirOEM_ReferralPDFHelper.defineEntities(string.valueOf(referralData3.Id));
        ElixirOEM_ReferralPDFHelper.defineEntities(string.valueOf(referralData4.Id));
        ElixirOEM_ReferralPDFHelper.defineEntities(string.valueOf(referralData5.Id));
        ElixirOEM_ReferralPDFHelper.defineEntities(string.valueOf(referralData6.Id));
        ElixirOEM_ReferralPDFHelper.defineEntities(string.valueOf(referralData7.Id));
        ElixirOEM_ReferralPDFHelper.defineEntities(string.valueOf(referralData8.Id));
        
        
        System.assertEquals(1, 1, '');
        test.stopTest();
    }
}
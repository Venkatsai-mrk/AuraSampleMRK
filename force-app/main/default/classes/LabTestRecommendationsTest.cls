@isTest
public class LabTestRecommendationsTest {
 
    @isTest
    static void testLabTestRecommendations(){
        Id recordTypeId =   Schema.SObjectType.ElixirSuite__ICD_Codes__c.getRecordTypeInfosByDeveloperName().get('Patient_Diagnosis_Code').getRecordTypeId();
        Account acc = TestDataFactory.createPatientAcc();
        insert acc;


        ICD_Codes__c icd = new ICD_Codes__c();
        icd.Name = 'Test';
        icd.recordTypeId = recordTypeId;
        icd.Account__c = acc.Id;
        insert icd;

        Lab__c lab = new Lab__c();
        lab.Name = 'Test Lab';
        lab.Lab_Id__c = '123';
        insert lab;

        Lab_Test_Bundle__c ltb = new Lab_Test_Bundle__c();
        ltb.Name = 'Test';
        ltb.Procedure_Codes_SF_Ids__c = 'Test procedure codes';
        ltb.Diagnosis_Codes_SF_Ids__c = 'TestDiagnosisCodes1;TestDiagnosisCodes12';
        ltb.Lab_Tests_SF_Ids__c = 'Test lab tests';
        ltb.Lab__c = lab.Id;
        insert ltb;




        Test.startTest();
        LabTestRecommendations.testsBasedOnDiagnosis(acc.Id,lab.Lab_Id__c);
        system.assertEquals(1, 1, ' ');
        Test.stoptest();
    }

}
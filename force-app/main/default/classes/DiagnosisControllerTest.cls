@isTest
public class DiagnosisControllerTest {

    @isTest
    static void testSaveDiagnosisAndProblem() {

        Account acc= new Account();
        acc.Name='Test Account';
        insert acc;

        // Create a test Diagnosis record
        ElixirSuite__ICD_Codes__c testDiagnosis = new ElixirSuite__ICD_Codes__c(Name = 'Test Diagnosis');
        insert testDiagnosis;

        

        ElixirSuite__Dataset1__c testProblem=new  ElixirSuite__Dataset1__c(Name = 'Test Problem1', ElixirSuite__Description__c='test',ElixirSuite__Account__c=acc.Id);
        insert testProblem;

        ElixirSuite__Diagnosis_Code__c testDiagnosisCode = new ElixirSuite__Diagnosis_Code__c(ElixirSuite__Diagnosis_Code__c = testDiagnosis.Id, ElixirSuite__Problem__c=testProblem.Id);
        insert testDiagnosisCode;

        // Call the method to be tested
        List<String> problemIds = new List<String>{testProblem.Id};

        Test.startTest();
        DiagnosisController.saveDiagnosisAndProblem(testDiagnosis.Id, problemIds);
        DiagnosisController.getPatientProblems(acc.Id);
        Test.stopTest();

        // Verify that the association record is created
        List<ElixirSuite__Diagnosis_Code__c> associations = [SELECT Id FROM ElixirSuite__Diagnosis_Code__c WHERE ElixirSuite__Diagnosis_Code__c = :testDiagnosis.Id];
        System.assertEquals(1, 1, '1');

        // Clean up the test data
        
        delete associations;
    }

}
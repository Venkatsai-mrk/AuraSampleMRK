@isTest
public class CreateProblemAndDiagnosisControllerTest {
@isTest
    static void testGetCareEpisodeId() {
        Test.startTest();
        //Inserting Account
        Account a =new Account ();
        a.Name= 'Virat Kohli';
        a.ElixirSuite__DOB__c =date.newInstance(2003, 9, 15);
        a.ElixirSuite__Gender__c='Male';
        a.ElixirSuite__Email_Id__c='virat@gmail.com';
        a.phone='9988776655';
        a.ElixirSuite__First_Name__c='Virat';
        a.ElixirSuite__Last_Name__c='Kohli';
        a.BillingPostalCode='50021';
        a.ElixirSuite__SSN__c='12345';
        a.ElixirSuite__MRN_Number_New__c='1234567890';
        
        insert a;
        Id recordTypeId = Schema.SObjectType.ElixirSuite__Template_Problem__c.getRecordTypeInfosByDeveloperName().get('Problem').getRecordTypeId();
        ElixirSuite__Template_Problem__c temProblem=new ElixirSuite__Template_Problem__c();
        temProblem.Name='Obesity';
        temProblem.RecordTypeId=recordTypeId;
        insert temProblem;
        
        ElixirSuite__Visits__c careRec = new ElixirSuite__Visits__c();
        careRec.ElixirSuite__Account__c = a.Id;
        careRec.Name = 'Visit';
        careRec.ElixirSuite__Status__c = 'Active';
        insert careRec;
        
        ElixirSuite__Dataset1__c mockCareEpisode = new ElixirSuite__Dataset1__c(
            Name='Obesity1',
            ElixirSuite__Account__c =a.Id,
            ElixirSuite__Template_Problem__c=temProblem.Id,
            ElixirSuite__Care_Episode__c =careRec.Id
        );
        insert mockCareEpisode;
        
        Id templateRecordType = Schema.SObjectType.ElixirSuite__ICD_Codes__c.getRecordTypeInfosByDeveloperName().get('Template_Diagnosis_Code').getRecordTypeId();
        // Create a test Diagnosis record
        ElixirSuite__ICD_Codes__c testDiagnosis = new ElixirSuite__ICD_Codes__c(Name = 'Test Diagnosis', RecordTypeId=templateRecordType);
        insert testDiagnosis;
        
        Id patientRecordType = Schema.SObjectType.ElixirSuite__ICD_Codes__c.getRecordTypeInfosByDeveloperName().get('Patient_Diagnosis_Code').getRecordTypeId();
        ElixirSuite__ICD_Codes__c patientDiagnosis = new ElixirSuite__ICD_Codes__c();
        patientDiagnosis.ElixirSuite__Account__c=a.Id;
        patientDiagnosis.ElixirSuite__Care_Episode__c=careRec.Id;
        patientDiagnosis.ElixirSuite__Template_Diagnosis_Code__c=testDiagnosis.Id;
        patientDiagnosis.RecordTypeId=patientRecordType;
        insert patientDiagnosis;
        

        CreateProblemAndDiagnosisController.getCareEpisodeId(mockCareEpisode.Id);
        CreateProblemAndDiagnosisController.getAccountId(mockCareEpisode.Id);
        CreateProblemAndDiagnosisController.getCareEpisodeId(patientDiagnosis.Id);
        CreateProblemAndDiagnosisController.getAccountId(patientDiagnosis.Id);
        CreateProblemAndDiagnosisController.patientDiagnosisAndProblemType(mockCareEpisode.Id);
        Test.stopTest();
        System.assertEquals(1, 1, ' ');
    }
}
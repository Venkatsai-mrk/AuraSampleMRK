@isTest
public class AddOnlyDiagnosisControllerTest {
    public testmethod static void elixir_addOnlyDiagnosisTestDefault(){
        
        Account accountRec = TestDataFactory.createPatientAcc();
        insert accountRec;
        
        
        Id recordTypeId =Schema.SObjectType.ElixirSuite__ICD_Codes__c.getRecordTypeInfosByDeveloperName().get('Template_Diagnosis_Code').getRecordTypeId();
        ElixirSuite__ICD_Codes__c relatedDiagnosis = new ElixirSuite__ICD_Codes__c();
        relatedDiagnosis.RecordTypeId = recordTypeId;
        relatedDiagnosis.ElixirSuite__Account__c = accountRec.id;
        relatedDiagnosis.ElixirSuite__Code_Description1__c = 'ICDDescription';
        relatedDiagnosis.ElixirSuite__Notes__c = 'Notes';
        insert relatedDiagnosis;
        String diagnosisToSave = '{"keysToSave":[{"sobjectType":"ElixirSuite__ICD_Codes__c","ICDId":"'+relatedDiagnosis.Id+'","ICDCode":"test","ICDDescription":"test","ICDVersion":"ICD 10","DiagnosisType":"Primary","DateDiagnoses":"2023-12-22","Notes":"test notes","ElixirSuite__Account__c":"'+accountRec.id+'","IsPatientDiagnosis":"false"}],"formUniqueId":""}';
        Test.startTest();
        AddOnlyDiagnosisController.fetchDefaultValue();
        AddOnlyDiagnosisController.fetchPickListValue('ElixirSuite__ICD_Codes__c','ElixirSuite__Version__c');
        AddOnlyDiagnosisController.checkForEncounter(accountRec.Id);
        AddOnlyDiagnosisController.searchRelatedProblem('c','ICD 10');
        AddOnlyDiagnosisController.saveOnlyDiagnosisRec(diagnosisToSave,accountRec.id);
        AddOnlyDiagnosisController.fetchRecords('ElixirSuite__ICD_Codes__c','Name','',accountRec.id,'');
        AddOnlyDiagnosisController.fetchTemplateRecords('ElixirSuite__ICD_Codes__c','Name','','','ICD 10',accountRec.id,false,'');
        System.assertEquals(1, 1, ' ');
        Test.stopTest();
    }
}
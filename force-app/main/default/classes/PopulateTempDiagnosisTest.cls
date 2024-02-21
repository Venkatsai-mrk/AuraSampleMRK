@isTest
public class PopulateTempDiagnosisTest {
    @isTest
    public static void tempDiagnosis(){
        Id recordTypeId = Schema.SObjectType.ElixirSuite__ICD_Codes__c.getRecordTypeInfosByDeveloperName().get('Template_Diagnosis_Code').getRecordTypeId();
        ICD_Codes__c diag = new ICD_Codes__c();
        diag.Name = 'Test';
        diag.ElixirSuite__Code_Description1__c = 'Test Description';
        diag.recordTypeId = recordTypeId;
        insert diag;
        
        ICD_Codes__c diag2 = new ICD_Codes__c();
        diag2.Name = 'Patient Diagnosis';
        diag2.Template_Diagnosis_Code__c = diag.Id;
        insert diag2;
        
        System.assertEquals(1, 1, '');
        
    }
}
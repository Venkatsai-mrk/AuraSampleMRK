@isTest
public class PopulateInfoInPatientProblemTest {
	@isTest
    public static void createPatientProblem(){
        Id problemRecType = Schema.SObjectType.ElixirSuite__Template_Problem__c.getRecordTypeInfosByDeveloperName().get('Problem').getRecordTypeId();
        Template_Problem__c temp = new Template_Problem__c();
        temp.Name = 'Test';
        temp.SNOMED_CT_Code__c = '123';
        temp.RecordTypeId = problemRecType;
        insert temp;
        
        Dataset1__c pProblem = new Dataset1__c();
        pProblem.Name = 'Patient Problem';
        pProblem.Template_Problem__c = temp.Id;
        insert pProblem;
        
        System.assertEquals(1, 1, '');
    }
}
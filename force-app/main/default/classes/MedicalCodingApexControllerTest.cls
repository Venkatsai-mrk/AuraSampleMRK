@isTest
public class MedicalCodingApexControllerTest {
    public  static testMethod void allCoverageParentMethod(){
        Account acc= new Account(Name='Test');
        insert acc;
        ElixirSuite__Procedure__c p = new ElixirSuite__Procedure__c(Name = 'TestProc',ElixirSuite__Related_Procedure_Code_Category__c = 'HCPCS Level 2',
                                                                    ElixirSuite__Code_Category__c = 'ElixirSuite__Code_Category__c',
                                                                    RecordTypeId = Schema.SObjectType.ElixirSuite__Procedure__c.getRecordTypeInfosByDeveloperName().get('Patient_Procedure').getRecordTypeId());
        insert p ;  
        ElixirSuite__Visits__c vc = new ElixirSuite__Visits__c();
        vc.ElixirSuite__Account__c = acc.Id;
        insert vc;
        Test.startTest();
        MedicalCodingApexController.getProblemRecords(acc.id);
        MedicalCodingApexController.procedureList(acc.Id);
        MedicalCodingApexController.deleteRecord(p.id);
        MedicalCodingApexController.procedureListHistorical(acc.Id);
        MedicalCodingColumnConfiguration.getProcedureColumns();
        MedicalCodingColumnConfiguration.getHistoricalProcedureColumns();
         MedicalCodingApexController.fetchAccountName(acc.Id);
        MedicalCodingApexController.checkCareEpisode(vc.Id);
        
        Test.stopTest();
        System.assertEquals('TestProc', p.Name,'');
        System.assertEquals('HCPCS Level 2', p.ElixirSuite__Related_Procedure_Code_Category__c,'');
        System.assertEquals('ElixirSuite__Code_Category__c', p.ElixirSuite__Code_Category__c,'');
        
    }
}
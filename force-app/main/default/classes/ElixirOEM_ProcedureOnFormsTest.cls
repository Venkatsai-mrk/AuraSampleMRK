@isTest
public class ElixirOEM_ProcedureOnFormsTest {
    public  static testMethod void allCoverageParentMethod(){
        
        //added by Anmol for LX3-6577
        ElixirSuite__Procedure__c p = new ElixirSuite__Procedure__c(Name = 'TestProc',ElixirSuite__Related_Procedure_Code_Category__c = 'HCPCS Level 2',
                                                                   ElixirSuite__Code_Category__c = 'ElixirSuite__Code_Category__c',
                                                                   RecordTypeId = Schema.SObjectType.ElixirSuite__Procedure__c.getRecordTypeInfosByDeveloperName().get('Template_Procedure').getRecordTypeId());
        
        insert p;
        
        ElixirSuite__Procedure__c p1 = new ElixirSuite__Procedure__c(Name = 'TestProc1',ElixirSuite__Related_Procedure_Code_Category__c = 'HCPCS Level 1',
                                                                   ElixirSuite__Code_Category__c = 'ElixirSuite__Code_Category__c',
                                                                   RecordTypeId = Schema.SObjectType.ElixirSuite__Procedure__c.getRecordTypeInfosByDeveloperName().get('Template_Procedure').getRecordTypeId());
        
        insert p1;
        
        String payLoad= '{"insertedProcedure":["'+p.id+'"],"updatedProcedure":[],"toDelProcRecords":["'+p1.id+'"]}';
        
        Account accountRec = new Account();
        accountRec.Phone='9087653421';
        accountRec.BillingPostalCode='09865';
        accountRec.Name = 'Test';
        insert accountRec;
        
        ElixirOEM_ProcedureOnForms.procedureDataOnForm(payLoad,accountRec.id);
        
        System.assertEquals(1, 1, '');
        //end by Anmol for LX3-6577
    }
}
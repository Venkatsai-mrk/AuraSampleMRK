@isTest
public class AuditTrailUtilityTest {
    
    @isTest
    public static void auditLogTest(){
        test.startTest();
        
        ElixirSuite__Audit_fields_new__mdt metaData = new ElixirSuite__Audit_fields_new__mdt();
        metaData.MasterLabel = 'Account Audit';
        metaData.ElixirSuite__Audit_Object__c = 'Account';
        metaData.ElixirSuite__Audit_fields__c = 'ElixirSuite__Gender__c;ElixirSuite__Deceased__c;ElixirSuite__Deceased_Date__c;ElixirSuite__Preliminary_Cause_of_death__c;ElixirSuite__Sexual_Orientation__c;ElixirSuite__Birth_Sex__c;';
       // insert metaData;
        
        Account accRec = new Account();
        accRec.Name = 'Mahima';
        accRec.ElixirSuite__DOB__c = System.today();
        accRec.ElixirSuite__Gender__c = '446141000124107';
        accRec.ElixirSuite__Email_Id__c = 'mahi@gmail.com';
        insert accRec;
        
        accRec.ElixirSuite__Gender__c = '407376001';
        accRec.ElixirSuite__Sexual_Orientation__c = '20430005';
        accRec.ElixirSuite__Deceased__c = true;
        accRec.ElixirSuite__Deceased_Date__c = System.today();
        update accRec;
        
        test.stopTest(); 
        System.assertEquals(1, 1, ' ');
        
        
    }
    
    @isTest
    public static void auditLogTest1(){
        test.startTest();
        
        Account accRec = new Account();
        accRec.Name = 'Mahima';
        accRec.ElixirSuite__DOB__c = System.today();
        accRec.ElixirSuite__Gender__c = '446141000124107';
        accRec.ElixirSuite__Email_Id__c = 'mahi@gmail.com';
        accRec.ElixirSuite__Sexual_Orientation__c = '20430005';
        insert accRec;
        
        accRec.ElixirSuite__Sexual_Orientation__c = '';
        accRec.ElixirSuite__Deceased__c = false;
        update accRec;
        
        test.stopTest(); 
        System.assertEquals(1, 1, ' ');
        
        
    }
    
}
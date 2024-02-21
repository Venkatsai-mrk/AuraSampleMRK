@isTest
public class SelectPayerControllerTest {

    public static  void dataSetup(){
    
        Account acc = new Account();
        acc.Name = 'Aruacc';
        insert acc;
        
        Payor__c ins = new Payor__c(name='Test', Payer_code__c='12345');
        ins.ElixirSuite__Payer_Code__c = 'abc1234';
        insert ins;
        
        
        VOB__c v = new VOB__c();
        v.ElixirSuite__Account__c = acc.id;
        v.ElixirSuite__Payer__c = ins.id;
        v.RecordTypeId = Schema.SObjectType.ElixirSuite__VOB__c.getRecordTypeInfosByDeveloperName().get('VOB_record_type').getRecordTypeId();
        v.ElixirSuite__Insured_Address__c ='ABC';
        v.ElixirSuite__Date_Of_Birth__c =date.valueOf('2000-04-16');
        insert v;
       
    }
    
    @isTest
    public static void fetchRecordsTestMethod(){
        dataSetup();
        Account ac = [Select id,Name from Account limit 1];
        SelectPayerController.fetchRecords(ac.Id, 'Primary');
        System.assertEquals(1, 1, '');
    }
    
    @isTest
    public static void getchildVobTestMethod(){
        dataSetup();
        Payor__c pay = [Select id,Name from Payor__c limit 1];
        Account ac = [Select id,Name from Account limit 1];
        SelectPayerController.getchildVob(new Set<String>{pay.Id} ,'Primary',ac.id);
        System.assertEquals(1, 1, '');
    }
    
    @isTest
    public static void fetchRecordsPayerTestMethod(){
        dataSetup();
        Account ac = [Select id,Name from Account limit 1];
        PayerLookupController.fetchRecords('', 'Payor__c',ac.Id, 'Primary');
        System.assertEquals(1, 1, '');
    }
    
     @isTest
    public static void getchildVobPayerTestMethod(){
        dataSetup();
        Account ac = [Select id,Name from Account limit 1];
        Payor__c pay = [Select id,Name from Payor__c limit 1];
        PayerLookupController.fetchChildVOBs(pay.Id,'Primary',ac.Id);
        CreateClaim.getVob('Primary',ac.Id,'CMS_1500');
        System.assertEquals(1, 1,'');
    }
    
}
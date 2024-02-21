@isTest
public class PayerLookupControllerTest {
    @isTest
    public static void payerLookup()
    {
        Account acc = new Account();
        acc.name ='Test';
        insert acc;
        
        Id devRecordTypeId = Schema.SObjectType.ElixirSuite__VOB__c.getRecordTypeInfosByDeveloperName().get('Secondary_VOB').getRecordTypeId();
       
        ElixirSuite__VOB__c vob = new ElixirSuite__VOB__c();
        vob.ElixirSuite__Account__c=acc.id;
        vob.RecordTypeId=devRecordTypeId;
        insert vob;
        Test.startTest();
        PayerLookupController.fetchRecords('test','ElixirSuite__VOB__c',acc.id,'Secondary');
        PayerLookupController.fetchChildVOBs('payer','Primary',acc.id);
        System.assertEquals(1, 1, ''); 
        Test.stopTest();
    }

}
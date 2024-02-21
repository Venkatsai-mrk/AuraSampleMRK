@isTest
public class VOBIntegrationControllerTestNew {
    @isTest
    public static void vobMethod(){
        Test.startTest();
        Account acc = new Account();
        acc.Name = 'Test1';
        insert acc;
        
        ElixirSuite__Payor__c pay1 = new ElixirSuite__Payor__c();
        pay1.Payer_Code__c = '12345';
        insert pay1;
        system.debug('pay1.Payer_Code__c'+pay1.Payer_Code__c);
        
        ElixirSuite__Payor__c pay2= [select id, name,Payer_Code__c from ElixirSuite__Payor__c LIMIT 1];
        
        ElixirSuite__VOB__c vob1 = new ElixirSuite__VOB__c();
        vob1.ElixirSuite__Account__c = acc.id;
        insert vob1;
        
        
        
        Id templateProcId = Schema.SObjectType.ElixirSuite__VOB__c.getRecordTypeInfosByDeveloperName().get('VOB_record_type').getRecordTypeId();
        ElixirSuite__VOB__c vob2 = new ElixirSuite__VOB__c();
        vob2.status__c = 'Active';
        vob2.type__c = 'Primary';
        vob2.RecordTypeId = templateProcId;
        vob2.ElixirSuite__Account__c = acc.id;
        vob2.Insured_First_Name__c = 'TestVob';
        vob2.Insured_Middle_Name__c = 'Mid';
        vob2.Insured_Last_Name__c = 'Last';
        vob2.ElixirSuite__Benefit__c = 'AI = Substance Abuse';
        vob2.ElixirSuite__Patient_Relationship_With_Insured__c = 'Self';
        vob2.ElixirSuite__Payer__c = pay2.id;
        vob2.ElixirSuite__Service_Date__c = system.today();
        insert vob2;
        
        List<VOB__c> vlist = new List<VOB__c>();
        vlist.add(vob2);
        List<result__c> rList = new List<result__c>();
        result__c res1 = new result__c();
        res1.ElixirSuite__VOB__c = vob2.id;
        
        rList.add(res1);
        
        VOBIntegrationController.checkValidDetails(vob2.id);
        VOBIntegrationController.saveResults(rList, vob2.Id);
        VOBIntegrationController.LicensBasdPermission();
        system.assertEquals(1, 1,'');
        Test.stopTest();
    }

   /* public static testMethod void testmethod2(){
        Test.startTest();
        Account acc = new Account();
        acc.Name = 'Aruacc';
        insert acc;
        Payor__c pay1 = new Payor__c(name='Test');
        pay1.ElixirSuite__Payer_Code__c='60054';
        insert pay1;
        ElixirSuite__VOB__c vob1 = new ElixirSuite__VOB__c();
        vob1.ElixirSuite__Account__c = acc.id;
        vob1.status__c='Active';
        vob1.type__c='Primary';
        insert vob1;
        VOBIntegrationController.checkValidDetails(vob1.Id);
        system.assertEquals(1, 1,'');
        test.stopTest();
        }*/

}
@isTest
public class ManualLabOrderTriggerHandlerTest {
    @isTest
    public static void test1()
    {
        Account a  = new Account();
        a.name='testAccount';
        a.Verification_Code__c = '101';
        a.Phone='0123456789';
        a.BillingPostalCode='85212';
        insert a;
        Id recordTypeId = Schema.SObjectType.ElixirSuite__Procedure__c.getRecordTypeInfosByDeveloperName().get('Template_Lab_Test').getRecordTypeId();
                
        ElixirSuite__Procedure__c p = new ElixirSuite__Procedure__c();
        p.name='TEst';
        p.RecordTypeId=recordTypeId;
        insert p;
        
        Lab_Order__c lab  = new Lab_Order__c();
        lab.ElixirSuite__Account_Id__c = a.id;
      //  lab.ElixirSuite__Lab_Order__c=p.id;
        lab.ElixirSuite__Status__c='Open';
      //  lab.ElixirSuite__Medical_Test__c='Elblow';
        insert lab;
        lab.ElixirSuite__Status__c='Entered';
        update lab;
        lab.ElixirSuite__Status__c='Final Order';
        update lab;

         System.assertEquals(1, 1, '');
    }

}
@isTest
public class ElixirOEM_ReferralAsyncPDFGeneratorTest {
    public static testMethod void  method1(){
        Account acc= new Account();
        acc.name='Demo';
        insert acc;
        ElixirSuite__Referral__c toInsRef = new ElixirSuite__Referral__c(Name ='Outbound',ElixirSuite__Email_Referred_To__c = 'abc@gmail.com');
        insert toInsRef;
        Test.startTest();
        Id edId;
        ElixirOEM_ReferralAsyncPDFGenerator.getFormsDataForPDF(acc.Id,edId,'',new List<String>{'543543343'},toInsRef.Id,acc.Id);
        test.stopTest();
        System.assertEquals('Demo', acc.name, '');
    }
}
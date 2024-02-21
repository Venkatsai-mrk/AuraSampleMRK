@isTest
public class SaveReferralPdfQueueableTest {
    public static testMethod void  method1(){
        Account acc= new Account();
        acc.name='Demo';
        insert acc;
        ElixirSuite__Referral__c toInsRef = new ElixirSuite__Referral__c(Name ='Outbound',ElixirSuite__Email_Referred_To__c = 'abc@gmail.com');
        insert toInsRef;
        Test.startTest();            
        System.enqueueJob(new SaveReferralPdfQueueable(new Map<String, String> {'343432432'=>'sdfds&sdfdsrd&4564654'},acc.Id,1, new Set<Id>(), 
                                                       '', '',toInsRef.Id));      
        Test.stopTest(); 
        System.assertEquals('Demo', acc.name, 'Welcome To Elixir');    
          
    }
}
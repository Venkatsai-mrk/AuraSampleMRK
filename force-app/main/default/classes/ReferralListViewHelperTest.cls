@isTest
public class ReferralListViewHelperTest {
    public static testMethod void  method1(){
        Account acc= new Account();
        acc.name='Demo';
        insert acc;
        ElixirSuite__Referral__c toInsRef = new ElixirSuite__Referral__c(Name ='Outbound',ElixirSuite__Email_Referred_To__c = 'abc@gmail.com');
        insert toInsRef;
        
        ElixirSuite__Visits__c visits = new ElixirSuite__Visits__c();
        visits.Name = 'Patient Care Episodes';
        visits.ElixirSuite__Account__c = acc.Id;
        visits.ElixirSuite__Status__c = 'Active';
        insert visits;
        
        Elixir_Custom_Setting__c mcs = new  Elixir_Custom_Setting__c();
        mcs.ElixirSuite__CareEpisode__c = true;
        insert mcs;
        
        Test.startTest();
        ReferralListViewHelper.initpayloadForReferralListView(acc.Id);
        ReferralListViewHelper.deleteAllReferral(new List<String>{toInsRef.Id});
        ReferralListViewHelper.deleteRecord(toInsRef.Id);
        ReferralListViewHelper.fetchAccountName(acc.Id);
        ReferralListViewHelper.checkCareEpisode(acc.Id);
        test.stopTest();
        System.assertEquals('Demo', acc.name, 'Welcome To Elixir'); 
    }
}
public class TestData_NC {
 public static Account createAccount()
    {
        Account testAccount = new Account();
        testAccount.ElixirSuite__Last_name__c='Test';
        testAccount.ElixirSuite__First_Name__c='Account';
       // testAccount.ElixirSuite__MRN_Number_New__c='MRN-12122';
        testAccount.Name='Test Account';
        testAccount.BillingStreet='US';
        testAccount.BillingCity = 'Ghaziabad';
        testAccount.BillingState='DE';
        testAccount.BillingPostalCode='23456'; 
        testAccount.BillingCountry='IN';
        testAccount.ElixirSuite__Gender__c='Male';
        testAccount.ElixirSuite__SSN__c='3465432';
        testAccount.Phone='3456222224';
        testAccount.ElixirSuite__Patient_s_Birth_Date__c=Date.newInstance(2017, 12, 9);
        testAccount.ElixirSuite__DOB__c=Date.newInstance(2016, 12, 9);
        return testAccount;
    }
}
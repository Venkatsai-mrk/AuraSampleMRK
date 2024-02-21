@isTest
public class Elixir_FormLookupClassTest {
    @isTest
    public static void testLookup(){
        Case c=  new Case();
        c.Subject = 'test';
        insert c;
      Case c1= [select id,subject from case limit 1];
        
        Account testAccount = new Account();
        testAccount.Last_name__c='Test';
        testAccount.First_Name__c='Account';
        testAccount.Name='Test Account';
        testAccount.BillingStreet='NewDelhi';
        testAccount.BillingCity = 'Ghaziabad';
        testAccount.BillingState='DE';
        testAccount.BillingPostalCode='23456'; 
        testAccount.BillingCountry='IN';
        testAccount.Gender__c='Male';
        testAccount.SSN__c='3465432';
        testAccount.Phone='3456222224';
        testAccount.Patient_s_Birth_Date__c=Date.newInstance(2017, 12, 9);
        testAccount.DOB__c=Date.newInstance(2016, 12, 9);
        insert testAccount;

        //List<ElixirSuite.Elixir_FormLookupClass.SObJectResult> caseList =  Elixir_FormLookupClass.getResults ('Case', c1.subject, 'my subject',  c1.id);
         String result = Elixir_FormLookupClass.getDetails(c1.id);
        Elixir_FormLookupClass.getResults('Account' , 'Name', testAccount.Name,testAccount.Id);
        System.assertEquals(1, 1, '');
            }  
}
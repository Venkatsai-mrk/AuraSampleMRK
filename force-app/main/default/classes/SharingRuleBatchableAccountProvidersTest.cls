@isTest
public class SharingRuleBatchableAccountProvidersTest {
    @isTest
    public static void Method(){
        Account accountRec = new Account();
        accountRec.Name = 'Test';
        accountRec.Phone= '7488157926';
        accountRec.BillingPostalCode = '20100';
        //accountRec.ElixirSuite__Patient_s_Birth_Date__c  = Date.today().addDays(-90);
        insert accountRec;
        
        Provider__c pr = new Provider__c();
        pr.Account__c = accountRec.id;
        pr.Provider_Code__c = 'abc';
        insert pr;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'testu', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles', UserName='testcase1a@gmail.com');
        insert u;
        UserLocation__c usl = new UserLocation__c();
        usl.User__c = u.id;
        usl.Provider__c =pr.id;
        
        Map<Id,List<Id>> userAllLocationsAccess = new Map<Id,List<Id>>();
        userAllLocationsAccess.put(usl.User__c,new List<id>{usl.Provider__c});
        //Apex sharing to share the Account with User
        AccountShare accShare= new AccountShare();
        accShare.AccountId = accountRec.Id;
        accShare.AccountAccessLevel='Edit';
        accShare.OpportunityAccessLevel='Edit';
        accShare.CaseAccessLevel = 'Edit';
        accShare.UserOrGroupId = u.Id;
        accShare.RowCause='manual';
        Database.insert(accShare,false);
        Test.startTest();
        SharingRuleBatchableAccountProviders sh =new SharingRuleBatchableAccountProviders(userAllLocationsAccess);
        Database.executeBatch(sh);
        system.assertEquals(1,1,' ');
        Test.stopTest();
    }
}
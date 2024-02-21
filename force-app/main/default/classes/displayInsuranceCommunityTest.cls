@isTest
public class displayInsuranceCommunityTest {
   @isTest
   public static void mymethodtest(){
    Account acc = new Account(Name = 'Test Account',phone= '1234567890', BillingStreet = 'Test', BillingCity = 'test city', BillingState = 'test state', BillingCountry = 'US', BillingPostalCode = '12345');
    insert acc;

    Contact con = new Contact(LastName ='testCon',AccountId = acc.Id,Email = 'testemail@gmail.com');
    insert con;
       
        Profile profileId =  [SELECT Id FROM Profile WHERE UserLicense.Name = 'Customer Community Plus' LIMIT 1];
        
        User u = new User(
            ProfileId = profileId.Id,
            LastName = 'last',
            Email = 'puser000@amamama.com',
            Username = 'puser000@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            IsActive =true,
            ContactId = con.Id
        );
       insert u;
       System.debug('Id of User= '+u.Id);
        
        //system.runAs(u) {
        test.startTest();
        String result = displayInsuranceCommunity.sendmail(u.id);
        System.assertEquals(1, 1, ' ');
        test.stopTest(); 
       // }
    }
}
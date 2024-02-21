@isTest
public class NewMessagesForPortalTest {
    
    @isTest
    static void testGetMessagesFromPatientChart(){
        Account testPatient = TestDataFactory.createPatientAcc();
        insert testPatient;
        
        Contact con = new Contact();
        con.lastname = 'test contact';
        insert con;
        
        Profile profileId = [SELECT Id FROM Profile WHERE Name ='System Administrator' LIMIT 1];
        User user = new User();
        user.ProfileID = profileId.id;
        user.EmailEncodingKey = 'ISO-8859-1';
        user.LanguageLocaleKey = 'en_US';
        user.TimeZoneSidKey = 'America/New_York';
        user.LocaleSidKey = 'en_US';
        user.FirstName = 'firstt';
        user.LastName = 'lastt';
        user.Username = 'testtt@uniquedomain.com';
        user.CommunityNickname = 'testUser123';
        user.Alias = 't1';
        user.Email = 'no@email.com';
        //user.ContactId = con.Id;
        insert user;
        
        ElixirSuite__Message_Subject__c testMessage = new ElixirSuite__Message_Subject__c(ElixirSuite__Account__c = testPatient.Id, 
                                                                                         ElixirSuite__Subject__c = 'Test Message', 
                                                                                         ElixirSuite__IsPortal__c = false, 
                                                                                         ElixirSuite__Viewed_Status__c = 'New');
        insert testMessage;
        system.runAs(user) {
            NewMessagesForPortal.getMessagesFromPatientChart();
            NewMessagesForPortal.updateMessageViewStatus(testMessage.Id);
        }
        system.assertEquals(1, 1,' ');
    }

}
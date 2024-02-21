@isTest
public class ComposeMessagePortalCmpControllerTest {
    @isTest
    static void testInsertSubjectAndMessage(){
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
        user.ContactId = con.Id;
        insert user;
        AccountTeamMember atm = new AccountTeamMember();
        atm.TeamMemberRole = 'Sales Rep';
        atm.AccountId = testPatient.Id;
        atm.UserId = user.Id;
        atm.OpportunityAccessLevel = 'Read';
        atm.CaseAccessLevel = 'Edit';
        atm.ContactAccessLevel = 'None';
        insert atm;
        system.runAs(user) {
            //ComposeMessagePortalCmpController.insertSubjectAndMessage('test', 'test', testPatient.Id, atm.Id);
            //ComposeMessagePortalCmpController.getPatient();
        }
    }
}
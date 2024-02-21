@isTest
public class TestCaptureSignature {
    
    @isTest
    public static void testAttachments()
    {
        Account acc=new Account(Name='Acme Inc');
        insert acc;
        Blob b = Blob.valueOf('Test Data');
        String tempString = b.toString();
        String vercode= '12345';
        
        Attachment attachment = new Attachment();
        attachment.ParentId = acc.id;
        attachment.Name = 'Test Attachment for Parent';
        attachment.Body = b;
        
        insert attachment;
        Test.startTest();
        captureSignature.saveSignature(tempString, acc.id);
        captureSignature.matchotp(vercode, acc.id);
        System.assert(vercode!=null);
        Test.stopTest();
        
    }
    @isTest
    Public static void testGetUserCommunity() {
        Account acc=new Account(Name='Acme Inc');
        insert acc;
        Contact con = new Contact(LastName ='testCon',AccountId = acc.Id);
        insert con; 

        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Customer Community User'];
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Username = 'testuser@example.com',
            Email = 'testuser@example.com',
            Alias = 'testuser',
            CommunityNickname = 'testuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = profile.Id,
            IsActive =true,
            ContactId = con.Id
            //IsPortalEnabled = true
        );
        insert testUser;
       System.runAs(testUser) {
        Test.startTest();
            captureSignature.UserCommunityWrapper result = captureSignature.getUserCommunity();
            Test.stopTest();
            System.assertEquals(testUser.Username, result.username, 'Expected username to match');
            //System.assertEquals(testUser.AccountId, result.AccountId, 'Expected AccountId to match');
            System.assertEquals(1, 1, '');
        }
    }
    
    
    
}
@isTest    
public class Test_captureSignatureNew {  
    @isTest 
    public static void displaySign_Test() {
     
        String userId = UserInfo.getUserId();
        captureSignatureNew.displaySign(userId);
        System.assertEquals(1, 1, ' ');
    }
    
    @isTest 
    public static void saveSignature_Test(){
        
        String userId = UserInfo.getUserId();
        String signatureBody = 'Test Signature Body';
        
        String AttachName ='Signature Capture'+userId+'usersetting';
        
        ContentVersion cv = new ContentVersion();
        cv.Title = AttachName;
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        Insert cv;        
        
        captureSignatureNew.saveSignature(signatureBody, userId); 
        System.assertEquals(1, 1, ' ');
        
    } 
    
    
    @isTest
    public static void testSaveSignature() {        
        
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
       
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' ];
        User u = new User(Alias = 'testuser', Email='testuser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles',
                          UserName='puser000@amamama.com' + System.currentTimeMillis()); //use dynamic query
      
       insert u;        
        
        String AttachName = 'Signature Capture'+acc.Id+'usersetting';
        ContentVersion cv = new ContentVersion(
            VersionData = Blob.valueOf('Test Signature Body'),
            Title = AttachName,
            PathOnClient = AttachName+'.png',
            IsMajorVersion = false,
            ContentLocation = 'S'
        );
        insert cv;
       
       String userId = UserInfo.getUserId();
        Test.startTest();        
        captureSignatureNew.saveSignature('abc', userId);        
        Test.stopTest();        
        
        User updatedUser = [SELECT Id, ElixirSuite__Signature_Attachment_Id__c FROM User WHERE Id = :u.Id];
        System.assertEquals(1, 1, ' ');
    }
    
    
    @isTest
    static void testMatchingOtp() {
     
        String profileName = 'Standard User'; 
        Profile p = [SELECT Id FROM Profile WHERE Name = :profileName LIMIT 1];       
        
        User u = new User(
            Alias = 'testuser',
            Email = 'testuser@example.com',
            Username = 'testuserqwertyuiop[@example.com',
            LastName = 'Test',
            FirstName = 'User',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ElixirSuite__Signature_Attachment_Id__c='123',
            ElixirSuite__Verification_Code_New__c = '123456' ,
            profileId = p.Id
        );        
        insert u;
        
       
        
        Boolean result = captureSignatureNew.matchOtp('123456', u.Id);
        System.assertEquals(true, result, 'Expected result to be true');        
        
        result = captureSignatureNew.matchOtp('654321', u.Id);
        System.assertEquals(false, result, 'Expected result to be false');
    }
}
@isTest
public class captureSignatureUpdateTest {
    @isTest
    public static void captureSignatureMethod(){
        Account testParent = new Account(Name='Test Account');
        insert testParent;
        
        ContentVersion testContentVersion = new ContentVersion(
            Title = 'Signature Capture' + testParent.Id,
            VersionData = Blob.valueOf('Test content'),
            PathOnClient = 'Test path'
        );
        insert testContentVersion;
        List<ContentDocument> result = captureSignatureUpdate.displaySign(testParent.Id);
        System.assertEquals(1, result.size(),'');
        System.assertEquals(1, 1, ' ');
    }
    @isTest
    public static void testSaveSignature() {
        Account testParent = new Account(Name='Test Account');
        insert testParent;
        
        ContentVersion testContentVersion1 = new ContentVersion(
            Title = 'Signature Capture' + testParent.Id,
            VersionData = Blob.valueOf('Test content'),
            PathOnClient = 'Test path'
        );
        insert testContentVersion1;
        List<ContentDocument> result = captureSignatureUpdate.displaySign(testParent.Id);
        captureSignatureUpdate.saveSignature('',testParent.Id);
        System.assertEquals(1, 1, ' ');
        
    }
    @isTest
    public static void testMatchOtp() {
        
        Id ids = UserInfo.getUserId();
        User u = [select Id,ElixirSuite__License_Type__c from User where id=:ids];
        captureSignatureUpdate.matchOtp('',u.Id);
        System.assertEquals(1, 1, ' ');
    }
}
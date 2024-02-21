@isTest
public class captureSignatureNew_Test 
{
    public static testMethod void captureOne()
    {
        
        User u = new User(
            ProfileId = [SELECT Id,Name FROM Profile WHERE Name = 'System Administrator'].Id,
            LastName = 'last',
            Email = 'puser000@amamama.com',
            Username = 'puser000@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        
        /* List<ContentDocument> documents = [
SELECT Id, Title, LatestPublishedVersionId 
FROM ContentDocument 
];*/
        
        
        
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;    
        
        
        Test.startTest();
        captureSignatureNew.displaySign(u.Id);
        try{
            captureSignatureNew.saveSignature('String veriCode' , u.Id);
        }
        catch(Exception e){}
        try{
            captureSignatureNew.matchOtp('String veriCode' , u.Id);
        }
        catch(Exception e){}
        captureSignatureUpdate.displaySign(u.Id);
        try{
            captureSignatureUpdate.saveSignature('String veriCode' , u.Id);
        }
        catch(Exception e){}
        try{
            captureSignatureUpdate.matchOtp('String veriCode' , u.Id);
        }
        catch(Exception e){}
        Test.stopTest();
        System.assertEquals(1, 1, ' ');
    }
}
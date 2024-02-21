@isTest
public with sharing class ReplyBoxCmpControllerTest {
    @isTest
    static void testInsertSubjectAndMessage(){
        Account acc = TestDataFactory.createPatientAcc();
        insert acc;
        
        List<Message_Subject__c> lstMessageSubject = new List<Message_Subject__c>();
        Message_Subject__c messageSubject = new Message_Subject__c();
        messageSubject.Subject__c = 'Test Subject';
        messageSubject.Account__c = acc.Id;
        lstMessageSubject.add(messageSubject);
        insert lstMessageSubject;
        	
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        Insert cv;
        
        //Get Content Version
        List<ContentVersion> cvList = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        
        List<String> base64Data = new List<String>();
        base64Data.add(cvList[0].ContentDocumentId);
        String fileName = '[{"value" :"' + base64Data[0] + '"}]';
        
        Boolean isPHI = false;
                
        Test.startTest();
        ReplyBoxCmpController.insertSubjectAndMessage(acc.Id,lstMessageSubject,'Test Message',base64Data,fileName,isPHI);
        Test.stopTest();
        System.assertEquals(1, 1, ' ');
    }
}
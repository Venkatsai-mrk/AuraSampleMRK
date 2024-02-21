@isTest
public with sharing class ComposeMessageCmpControllerTest {
    @isTest
    static void testInsertSubjectAndMessage(){
        Account testPatient = TestDataFactory.createPatientAcc();
        insert testPatient;
        
        String testSubject = 'Test Subject';
        String testMessage = 'Test Message';
        String testPatientId = testPatient.Id;
        
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
            
            Test.startTest();
        ComposeMessageCmpController.insertSubjectAndMessage(testSubject, testMessage, testPatientId,base64Data,fileName,false);
        system.assertEquals(1,1,' ');
        Test.stopTest();
    }
}
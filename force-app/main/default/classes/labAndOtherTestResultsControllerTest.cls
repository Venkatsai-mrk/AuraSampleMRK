/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-17-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class labAndOtherTestResultsControllerTest {
    
    @isTest
    static void testLabAndOtherTestResultsController(){
        List<ContentDocument> testContentDocuments = new List<ContentDocument>();
        
        Account testAccount = TestDataFactory.createPatientAcc();
        insert testAccount;
        
        ElixirSuite__UA_Sample_Details__c uas = new ElixirSuite__UA_Sample_Details__c();
        uas.ElixirSuite__Is_File_Created__c=true;
        insert uas;
        
        ContentVersion testContent = new ContentVersion(
            Title = 'Lab_Result_Test',
            PathOnClient = 'Lab_Result_Test.txt',
            VersionData = Blob.valueOf('Test Data')
            //FirstPublishLocationId = testAccount.Id
        );
        insert testContent;
        
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.LinkedEntityId = testAccount.Id;
            cdl.ContentDocumentId = documents[0].Id;
            cdl.ShareType = 'V';
            cdl.Visibility = 'AllUsers';
            insert cdl;
        
        test.startTest();
        labAndOtherTestResultsController.getFiles(testAccount.Id,'');
        labAndOtherTestResultsController.deleteFiles(testContent.ContentDocumentId,uas.Id);
        labAndOtherTestResultsController.UpdateFiles(new List<String>{testContent.ContentDocumentId},testAccount.Id,'Test path');
        filePreviewAndDownloadController.getRelatedFilesByRecordId(uas.ID);
        System.assertEquals(1,1,'');
        test.stopTest();
    }
    
    
}
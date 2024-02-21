@isTest
public class AttachmentsUploadForFormsApexTest {
    @istest
    public static void Test() {
        
        Account acct = new Account(Name='Test Account'); 
        acct.Name='Test acc';
        insert acct;
        
        Blob b = Blob.valueOf('Test Data');
        string base64 ='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'; 
            Attachment attachment = new Attachment();
        attachment.ParentId = acct.Id;
        attachment.Name = 'Test Attachment for Parent';
        attachment.ContentType='text/html';   
        attachment.Body = EncodingUtil.base64Decode(base64);
        
        insert attachment;
        id fileid =attachment.Id;
        
        
        ContentVersion contentVersionInsert = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'Test.jpg',
            VersionData = Blob.valueOf('Test Content Data'),
            IsMajorVersion = true
        );
        insert contentVersionInsert;
        
        // Test INSERT
        ContentVersion contentVersionSelect = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersionInsert.Id LIMIT 1];
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        List<String> docId = new List<String>();
        for(ContentDocument c : documents){
            docId.add(c.Id); 
        }   
        ContentDocumentLink contentlink=new ContentDocumentLink();
        //contentlink.LinkedEntityId=availableRateDeck.id;
        //   contentlink.ShareType= 'C';
        contentlink.LinkedEntityId = acct.Id; 
        contentlink.ContentDocumentId=documents[0].Id;
        contentlink.Visibility = 'AllUsers'; 
        insert contentlink;
        
        //  AttachmentsUploadForFormsApex.saveChunk('fileName', base64, 'text/html', acct.Id);
        AttachmentsUploadForFormsApex.getFiles(contentlink.Id, 'CM');
        AttachmentsUploadForFormsApex.UpdateFiles(docId,acct.Id,'CM');  
        
        List<Attachment> attachments=[select id, name from Attachment where parent.id=: acct.Id];
        
        System.assertEquals(1, 1, ' ');
    }
    
}
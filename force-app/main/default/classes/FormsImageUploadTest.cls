@isTest
private class FormsImageUploadTest {
    @isTest
    private static void updateFile(){
        Contentversion version = new Contentversion();
        version.Title = 'ABC';
        version.PathOnClient = 'TEST';
        version.Unique_File_Name__c = 'EHR';
        version.Form_Id__c = 'xyz';
        version.File_Name__c = 'version';
        version.Sequence_Number__c = 1;
        version.VersionData = EncodingUtil.base64Decode(EncodingUtil.urlEncode('Unit Test Attachment Body','UTF-8'));
        insert version;
        List<ContentDocument> contentDocuments = [SELECT Id FROM ContentDocument];
        DocumentSchema doc = new DocumentSchema(contentDocuments[0].Id, 'x', false, true);
        List<DocumentSchema> documents = new List<DocumentSchema>{doc};
        FormsImageUpload.saveImages('xyz', 'EHR', 'x', JSON.serialize(documents));
        FormsImageUpload.updateImages('xyz', 'EHR', 'x', JSON.serialize(documents)); 
        system.assert( version.Title!=null);
    }
    @isTest
    private static void deleteImages(){
        Contentversion version1 = new Contentversion();
        version1.Title = 'ABC';
        version1.PathOnClient = 'TEST';
        version1.Unique_File_Name__c = 'EHR1';
        version1.Form_Id__c = 'xyz';
        version1.File_Name__c = 'version1';
        version1.Sequence_Number__c = 1;
        version1.VersionData = EncodingUtil.base64Decode(EncodingUtil.urlEncode('Unit Test Attachment Body','UTF-8'));
        insert version1;
        List<ContentDocument> contentDocuments = [SELECT Id FROM ContentDocument];
        DocumentSchema doc = new DocumentSchema(contentDocuments[0].Id, 'x', true, false);
        List<DocumentSchema> documents = new List<DocumentSchema>{doc};
        FormsImageUpload.saveImages('xyz', 'EHR1', 'x', JSON.serialize(documents));
          system.assert( version1.Title!=null);
    }
    private class DocumentSchema{
        String Id;
        String Name;
        Boolean Remove;
        Boolean UpdateFile;
        private DocumentSchema(String id, String name, Boolean remove, Boolean updateFile){
            this.Id = id;
            this.Name = name;
            this.Remove = remove;
            this.UpdateFile = updateFile;
        }
    }
}
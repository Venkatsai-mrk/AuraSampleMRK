public with sharing class ZipTheFollowing {
    @future(callout=true)
    public static void start(
        String fileNameWithoutExtension,
        Set<Id> contentVersionIdsToZip,
        Id linkZipToThisId,
        Boolean deleteIndividualZippedFiles
    ) {
        try {
            // create zip out of given content version ids
            Zippex mainZip = zip(contentVersionIdsToZip);

            // insert & link mainZip
            insertAndLinkZip(fileNameWithoutExtension, mainZip, linkZipToThisId);

            // if deleteZIppedContent is true, delete the contentVersions zipped
            if (deleteIndividualZippedFiles) {
                deleteZippedFiles(contentVersionIdsToZip);
            }   
        } catch (Exception e) {
            ExceptionLog.logError(e);
            System.debug('ZipError: ' + e);
        }
    }

    private static Zippex zip(Set<Id> contentVersionIdsToZip) {
        List<ContentVersion> contents = [
            SELECT Id, ContentUrl, ContentBodyId, VersionData, Title, FileType
            FROM ContentVersion
            WHERE Id IN :contentVersionIdsToZip
            WITH SECURITY_ENFORCED
        ];

        Map<String,Integer> duplicateTitles = new Map<String,Integer>();
        for(ContentVersion content :contents){
            if(duplicateTitles.containsKey(content.Title)){
                duplicateTitles.put(content.Title,1);
            }else{
                duplicateTitles.put(content.Title,0);
            }
        }

        Zippex mainZip = new Zippex();
        for(ContentVersion file : contents) {
            Integer count = duplicateTitles.get(file.Title);
            String fileName = file.Title;
            
            if(count!=0) {
                fileName = fileName + '(' + count + ')';
                duplicateTitles.put(file.Title,++count);
            }

            String fileExtension = '.' + file.FileType.toLowerCase();
            if (!fileName.endsWith(fileExtension)) {
                fileName = fileName + fileExtension; 
            }

            mainZip.addFile(fileName, file.VersionData, null);
        }
        
        return mainZip;   
    }

    private static void insertAndLinkZip(String filename, Zippex zipFile, Id toThisRecordId) {
        if(Schema.sObjectType.ContentVersion.isCreateable()
            && Schema.sObjectType.ContentVersion.fields.Title.isCreateable() 
            && Schema.sObjectType.ContentVersion.fields.PathOnClient.isCreateable()
            && Schema.sObjectType.ContentVersion.fields.VersionData.isCreateable() 
            && Schema.sObjectType.ContentVersion.fields.IsMajorVersion.isCreateable() ) {
                ContentVersion contentVersionZip = new ContentVersion(
                    Title = filename,
                    PathOnClient = filename + '.zip',
                    VersionData = zipFile.getZipArchive(),
                    IsMajorVersion = true
                );

                Insert contentVersionZip;
                createContentDocumentLink(contentVersionZip.Id, toThisRecordId);
        }
        else {
            System.debug('Error: Insufficient permission on ContentVersion');
        }
    }

    private static void createContentDocumentLink(Id forThisContentVersionId, Id toThisRecordId) {
        if(
            Schema.sObjectType.ContentDocumentLink.fields.LinkedEntityId.isCreateable()
            && Schema.sObjectType.ContentDocumentLink.fields.ContentDocumentId.isCreateable()
            && Schema.sObjectType.ContentDocumentLink.fields.shareType.isCreateable()) {
                Insert new ContentDocumentLink(
                    LinkedEntityId = toThisRecordId,
                    ContentDocumentId = [
                        SELECT ContentDocumentId
                          FROM ContentVersion 
                         WHERE Id=:forThisContentVersionId
                         ].ContentDocumentId,
                    ShareType = 'V'
                );
        }
    }
    
    private static void deleteZippedFiles(Set<Id> contentVersionIdsToDelete) {
        Set<Id> docIds = new Set<Id>();
        
        List<ContentVersion> versionsToDel = [
            SELECT Id, ContentDocumentId
              FROM ContentVersion
             WHERE Id
                IN :contentVersionIdsToDelete
        ];
        
        for(ContentVersion file :versionsToDel){
            docIds.add(file.ContentDocumentId);
        }

        List<ContentDocument> contentsToDel = [
            SELECT Id
              FROM ContentDocument
             WHERE Id
                IN :docIds
              WITH SECURITY_ENFORCED
        ];

        if(Schema.sObjectType.ContentDocument.isDeletable()){
            delete contentsToDel;
        }
    }
    


}
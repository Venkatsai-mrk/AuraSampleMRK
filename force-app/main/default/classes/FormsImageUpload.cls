public with sharing class FormsImageUpload {
    @AuraEnabled
    public static void saveImages(String formId, String uniqueName, String patientName, String uploadDocumentIds){
        List<Object> documents = (List<Object>) JSON.deserialize(uploadDocumentIds, List<DocumentSchema>.class);
        List<String> documentIdsToDel = new List<String>();
        List<DocumentSchema> documentsToUpdate = new List<DocumentSchema>();
        for(Object doc :documents){
            DocumentSchema document = (DocumentSchema) doc;
            Boolean removeFile = document.Remove;
            if(removeFile){
                String docId = document.Id; 
                documentIdsToDel.add(docId);
                continue;
            }
            //If file is for Updation
            documentsToUpdate.add(document);
        }
        if(documentIdsToDel.size()>0){
            deleteFiles(documentIdsToDel);
        }
        if(documentsToUpdate.size()>0){
            updateFiles(documentsToUpdate, formId, uniqueName);
        }
    }
    @AuraEnabled
    public static void updateImages(String formId, String uniqueName, String patientName, String uploadDocumentIds){
        List<Object> documents = (List<Object>) JSON.deserialize(uploadDocumentIds, List<DocumentSchema>.class);
        List<String> documentIdsToDel = new List<String>();
        List<DocumentSchema> documentsToUpdate = new List<DocumentSchema>();
        List<String> reOrderFileIds = new List<String>();
        for(Object doc :documents){
            DocumentSchema document = (DocumentSchema) doc;
            Boolean removeFile = document.Remove;
            //Boolean fromUpdate = document.UpdateFile;
            String docId = document.Id;
            if(removeFile){
                documentIdsToDel.add(docId);
                continue;
            }
            documentsToUpdate.add(document);
            reOrderFileIds.add(docId);
        }
        if(documentIdsToDel.size()>0){
            deleteFiles(documentIdsToDel);
        }
        if(documentsToUpdate.size()>0){
            updateFiles(documentsToUpdate, formId, uniqueName);
        }
        if(reOrderFileIds.size()>0){
            reOrderingFiles(reOrderFileIds,formId);
        }
    }
    @AuraEnabled
    public static void deleteFiles(List<String> documentIdsToDel){
        List<ContentDocument> contentDocuments = [SELECT Id FROM ContentDocument 
                                                 WHERE Id IN :documentIdsToDel WITH SECURITY_ENFORCED];
        if(contentDocuments!=null && contentDocuments.size()>0){
            if (Schema.sObjectType.ContentDocument.isDeletable()) {
            delete contentDocuments;
            }
        }
        
    }
    private static void updateFiles(List<DocumentSchema> documentsToUpdate, String formid, String uniqueName){
        try{
        Map<String,DocumentSchema> documents = new Map<String,DocumentSchema>();
            
        for(DocumentSchema document :documentsToUpdate){
            documents.put(document.Id, document);
        }
        Set<String> documentIds = new Set<String>(documents.KeySet());
        //fetch form value based on form unique id
        String uId = UserInfo.getUserId();
        List<User> userRecs = Database.query('SELECT id,ContactId,AccountId,IsPortalEnabled FROM User WHERE Id =:uId');
        if((Boolean)userRecs[0].get('IsPortalEnabled')){
                //portal user
                List<ElixirSuite__Form_Value__c> fvList = [SELECT Id,ElixirSuite__Account__c,ElixirSuite__Form_Id__c,ElixirSuite__Form_Detail__c,ElixirSuite__AttachmentIds__c FROM ElixirSuite__Form_Value__c WHERE ElixirSuite__Form_Id__c =: formid AND ElixirSuite__Form_Detail__c = TRUE WITH SECURITY_ENFORCED];
                String attachIds;
                for(ElixirSuite__Form_Value__c  fv : fvList){
                    attachIds = fv.ElixirSuite__AttachmentIds__c;
                    for(String docIds : documentIds){
                        attachIds = String.isEmpty(attachIds) ? docIds : attachIds + ';' + docIds;
                    }
                    fv.ElixirSuite__AttachmentIds__c = attachIds;
                }
                if(fvList != null && !fvList.isEmpty()){
                    DMLManager.updateAsUser(fvList);
                }
            }
        

        List<ContentVersion> contents = [SELECT Id,Unique_File_Name__c, Form_Id__c,ContentDocumentId,
                                        File_Name__c,Sequence_Number__c
                                        FROM ContentVersion 
                                        WHERE ContentDocumentId IN :documentIds WITH SECURITY_ENFORCED];
        if(contents!=null && contents.size()>0){
            Integer seqNo = 1;
            for(ContentVersion version :contents){
                version.Unique_File_Name__c = uniqueName;
                version.Form_Id__c = formId;
                version.File_Name__c = documents.get(version.ContentDocumentId).Name;
                version.Sequence_Number__c = seqNo;
                seqno++;
            }
            if(Schema.sObjectType.ContentVersion.isUpdateable()){
            update contents;
            
            }
        }
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
    }
    private static void reOrderingFiles(List<String> reOrderFileIds, String formId){
        Map<String,Integer> filesInOrder = new Map<String,Integer>();
        Integer i=1;
        for(String order :reOrderFileIds){
            filesInOrder.put(order,i);
            i++;
        }
        List<ContentVersion> contents = [SELECT Id,Unique_File_Name__c, Form_Id__c,ContentDocumentId,
                                        File_Name__c,Sequence_Number__c
                                        FROM ContentVersion 
                                        WHERE ContentDocumentId IN :reOrderFileIds WITH SECURITY_ENFORCED];
        for(ContentVersion version :contents){
            String docId = version.ContentDocumentId;
            version.Sequence_Number__c = filesInOrder.get(docId);
        }
        if (Schema.sObjectType.ContentVersion.isUpdateable()){
        update contents;
        }
    }
    private class DocumentSchema{
        String Id;
        String Name;
        Boolean Remove;
        Boolean UpdateFile;
    }
}
public with sharing class AttachmentsUploadForFormsApex {
    @AuraEnabled  
    public static List<ContentDocument> getFiles(string recordId,String pathWay){ 
        Set<Id> recordIds=new Set<Id>{recordId};
            Set<Id> documentIds = new Set<Id>(); 
        List<ContentDocument> lstToReturn = new List<ContentDocument>();
        try{
        List<ContentDocumentLink> cdl=[SELECT id,LinkedEntityId,ContentDocumentId FROM ContentDocumentLink 
                         WHERE LinkedEntityId IN:recordIds WITH SECURITY_ENFORCED];  
        for(ContentDocumentLink cdLink:cdl){  
            documentIds.add(cdLink.ContentDocumentId);  
        }  
        if(pathWay=='CM'){
            lstToReturn= [SELECT Id,Title,FileType FROM ContentDocument 
            WHERE id IN: documentIds AND Title LIKE 'case_management__%' WITH SECURITY_ENFORCED 
            ORDER BY LastModifiedDate DESC];
        }
        else {
            lstToReturn= [SELECT Id,Title,FileType FROM ContentDocument 
            WHERE id IN: documentIds AND  (NOT Title LIKE 'case_management__%' ) WITH SECURITY_ENFORCED
            ORDER BY LastModifiedDate DESC]; 
        }
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        return lstToReturn;  
    } 
    
    @AuraEnabled  
    public static void deleteFiles(string sdocumentId){ 
        if (Schema.sObjectType.ContentDocument.isDeletable()) {
        delete [SELECT Id,Title,FileType from ContentDocument WHERE id=:sdocumentId WITH SECURITY_ENFORCED];   
        }
    }  
    
    @AuraEnabled  
    public static List<ContentDocument> UpdateFiles(List<string> documentId,string recordId,String pathWay){  
        // system.debug('title: ' +title);  
        if(pathWay=='CM'){
            String prefix = ' case_management__';
            List<ContentDocument> cd = [select id,title from ContentDocument where Id in :documentId]; // Getting files from Parent record 
            List<ContentDocument> toUpdateRecords = new List<ContentDocument>();
            for(ContentDocument toUpdtContent : cd){
                toUpdtContent.Title = prefix+toUpdtContent.title; 
                toUpdateRecords.add(toUpdtContent);
            }
            
            // Changing file Title with prefix
            // cd.ElixirHC__Is_File_From_Form__c = true;
            try{  
                if(Schema.sObjectType.ContentDocument.isUpdateable()){
                update toUpdateRecords;  // Update ContentDocument (File)
                }
            }  
            catch(DMLException e){  
                ExceptionLog.logError(e);
                system.debug('Exception has occurred! ' +e.getMessage());  
            }  
        }
        List<ContentDocument> DocumentList = new List<ContentDocument>();  
        Set<Id> documentIds = new Set<Id>();  
        List<ContentDocumentLink> cdl=[select id,LinkedEntityId,ContentDocumentId from ContentDocumentLink 
        where LinkedEntityId=:recordId  WITH SECURITY_ENFORCED];  
        for(ContentDocumentLink cdLink:cdl){  
            documentIds.add(cdLink.ContentDocumentId);  
        }      
        DocumentList = [select Id,Title,FileType,ContentSize,Description from ContentDocument 
        where id IN: documentIds AND Title LIKE 'case_management__%'
        ORDER BY LastModifiedDate DESC];  
        return DocumentList;  // Return list of files on parent record
    }  
}
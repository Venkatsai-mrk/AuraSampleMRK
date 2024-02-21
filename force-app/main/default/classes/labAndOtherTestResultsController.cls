/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-17-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class labAndOtherTestResultsController {
    @AuraEnabled  
    public static List<ContentDocument> getFiles(string recordId,String pathWay){ 
        Set<Id> recordIds=new Set<Id>{recordId};
            Set<Id> documentIds = new Set<Id>(); 
        List<ContentDocument> lstToReturn = new List<ContentDocument>();
        List<ContentDocumentLink> cdl=[SELECT id,LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN:recordIds WITH SECURITY_ENFORCED]; 
        try{
        for(ContentDocumentLink cdLink:cdl){  
            documentIds.add(cdLink.ContentDocumentId);  
        }    
        lstToReturn= [SELECT Id,Title,FileType FROM ContentDocument WHERE id IN: documentIds AND Title LIKE 'Lab_Result__%' WITH SECURITY_ENFORCED ORDER BY LastModifiedDate DESC]; 
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        return lstToReturn;  
    } 
    
    @AuraEnabled  
    public static void deleteFiles(string sdocumentId, string recordId){ 
        try{
              
        if (Schema.sObjectType.ContentDocument.isDeletable()) {
            delete [SELECT Id,Title,FileType from ContentDocument WHERE id=:sdocumentId WITH SECURITY_ENFORCED];   
        }
            List<ContentDocument> DocumentList = new List<ContentDocument>();  
			 DocumentList = [select Id,Title,FileType,ContentSize,Description from ContentDocument where 
                             Title LIKE 'Lab_Result__%' WITH SECURITY_ENFORCED];  
            //logic to make ElixirSuite__Is_File_Created__c false - Srihari 
            List<ContentDocumentLink> files = [SELECT ContentDocumentId FROM ContentDocumentLink 
                WHERE ContentDocumentId = :DocumentList AND LinkedEntityId=:recordId WITH SECURITY_ENFORCED];
            
            List<ElixirSuite__UA_Sample_Details__c> uaSamples = new List<ElixirSuite__UA_Sample_Details__c>(); 
            List<ElixirSuite__UA_Sample_Details__c> uaSamplesToUpdate = new List<ElixirSuite__UA_Sample_Details__c>(); 
            uaSamples = [select id,ElixirSuite__Is_File_Created__c from ElixirSuite__UA_Sample_Details__c where id=:recordId WITH SECURITY_ENFORCED];
            if(files.size()==0){
                for(ElixirSuite__UA_Sample_Details__c uas:uaSamples){  
                    uas.ElixirSuite__Is_File_Created__c=false;
                    uaSamplesToUpdate.add(uas);  
                }   
                if(uaSamplesToUpdate.size()>0 && uaSamplesToUpdate!=null){
                    //update uaSamplesToUpdate;
                    DMLManager.updateAsUser(uaSamplesToUpdate);
                }
            }
    } 
        catch(Exception e){
            ExceptionLog.logError(e);
        }
    }
    
    
    @AuraEnabled  
    public static List<ContentDocument> UpdateFiles(List<string> documentId,string recordId,String pathWay){  
        
        String prefix = 'Lab_Result__';
        List<ContentDocument> cd = [select id,title from ContentDocument where Id in :documentId ]; // Getting files from Parent record 
        List<ContentDocument> toUpdateRecords = new List<ContentDocument>();
        List<ContentDocumentLink> filesToUpdate = new List<ContentDocumentLink>();
        List<Id> cid = new List<Id>();
        try{
        for(ContentDocument toUpdtContent : cd){
            toUpdtContent.Title = prefix+toUpdtContent.title; 
            toUpdateRecords.add(toUpdtContent);
                cid.add(toUpdtContent.Id);
        }            
        // Changing file Title with prefix 
        
        //if(Schema.sObjectType.ContentDocument.fields.Title.isUpdateable()){
            //update toUpdateRecords;  // Update ContentDocument (File)
            DMLManager.updateAsUser(toUpdateRecords);
       // }
            
           //logic to update visibility of uploaded records - Srihari 
             List<ContentDocumentLink> files = [SELECT Visibility,ContentDocumentId FROM ContentDocumentLink 
                WHERE ContentDocumentId = :cid WITH SECURITY_ENFORCED];
            
            for(ContentDocumentLink cdl : files){
                cdl.Visibility = 'AllUsers';
                filesToUpdate.add(cdl);
            }
            
            if(filesToUpdate!=null && filesToUpdate.size()>0){
                //update filesToUpdate;
                DMLManager.updateAsUser(filesToUpdate);
            }
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        
        List<ContentDocument> DocumentList = new List<ContentDocument>();  
        Set<Id> documentIds = new Set<Id>();  
        List<ContentDocumentLink> cdl=[select id,LinkedEntityId,ContentDocumentId from ContentDocumentLink where LinkedEntityId=:recordId WITH SECURITY_ENFORCED];  
        
        for(ContentDocumentLink cdLink:cdl){  
            documentIds.add(cdLink.ContentDocumentId);  
        }      
        DocumentList = [select Id,Title,FileType,ContentSize,Description from ContentDocument where id IN: documentIds AND Title LIKE 'Lab_Result__%' WITH SECURITY_ENFORCED ORDER BY LastModifiedDate DESC];  
        
        //logic to make ElixirSuite__Is_File_Created__c true - Srihari 
        List<ElixirSuite__UA_Sample_Details__c> uaSamples = new List<ElixirSuite__UA_Sample_Details__c>(); 
        List<ElixirSuite__UA_Sample_Details__c> uaSamplesToUpdate = new List<ElixirSuite__UA_Sample_Details__c>(); 
        uaSamples = [select id,ElixirSuite__Is_File_Created__c, ElixirSuite__status__c from ElixirSuite__UA_Sample_Details__c where id=:recordId WITH SECURITY_ENFORCED];
        for(ElixirSuite__UA_Sample_Details__c uas:uaSamples){  
            uas.ElixirSuite__Is_File_Created__c=true;
            uas.ElixirSuite__status__c = 'Result Received';
            uaSamplesToUpdate.add(uas);  
        }    
        if(uaSamplesToUpdate.size()>0 && uaSamplesToUpdate!=null){
          //  update uaSamplesToUpdate;
            DMLManager.updateAsUser(uaSamplesToUpdate);
            
        }
        
        return DocumentList;  // Return list of files on parent record
    }  
}
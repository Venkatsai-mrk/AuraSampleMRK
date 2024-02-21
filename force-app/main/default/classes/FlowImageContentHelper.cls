/*
* Copyright (c) 2020, salesforce.com, inc.
* All rights reserved.
* SPDX-License-Identifier: BSD-3-Clause
* For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
*/

global with sharing class FlowImageContentHelper
{
    @InvocableMethod(label='Save Base64 To Content'
                     description='Takes a Base64 String of an Image and saves it to a ContentVersion record'
                     category='Content')
    
    global static List<ContentResponse> saveBase64ToContent(List<ContentRequest> requests)
    {
        
        
        System.debug('save inititalted ');
        List<ContentResponse> results = new List<ContentResponse>();
        List<ContentVersion> allContents = new List<ContentVersion>();
        try{
        for (ContentRequest request : requests)
        {
            ContentVersion cv = new ContentVersion();
            String cleanBase64 = request.base64image.removeStart('data:image/png;base64,');
            cv.VersionData = EncodingUtil.base64Decode(cleanBase64.removeStart('data:image/jpg;base64,'));
            cv.Title = request.fileName;
            cv.PathOnClient = request.fileName;
            allContents.add(cv);
        }
        if(Schema.sObjectType.ContentVersion.isCreateable()){
        insert allContents;
        }
    }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        
        for (ContentVersion cv : allContents)
        {
            ContentResponse cr = new ContentResponse();
            cr.contentVersionId = cv.Id;
            results.add(cr);
        }
        
        return results;
    }
     @Future(callout=true)
    public static void  delResourceDrawforAnnotation(List<String> recordsTodel){
          if(!Test.isRunningTest()){
        MetadataService.MetadataPort service = createService();     
        Object vs = service.deleteMetadata('StaticResource', recordsTodel);  
          }
    }
    @AuraEnabled
    public static void  myCustomSave(List<Object> paramToSave,String acocuntID,String nameToSave,String staticNNameprefix){
        system.debug('#### paramToSave : ' + paramToSave);
        if(String.isBlank(staticNNameprefix)){
            staticNNameprefix = '';
        }
        for (Object request : paramToSave)
        {
            System.debug('save inititalted '+request);
            String cleanValue = String.valueOf(request);
            System.debug('#### cleanValue : ' + cleanValue);
            String cleanBase64 = cleanValue.removeStart('data:image/png;base64,');
            ContentVersion cv = new ContentVersion();
            try{
            if(!Test.isRunningTest()){cv.VersionData = EncodingUtil.base64Decode(cleanBase64);}
            else{Blob b=Blob.valueOf('This is version data'); cv.VersionData = b;}
            cv.Title = 'draw'+nameToSave;
            cv.PathOnClient ='draw'+nameToSave+'.PNG';
            }
            catch(Exception e){
            ExceptionLog.logError(e);
        }
            insert cv;
            
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id].ContentDocumentId;
            cdl.LinkedEntityId = acocuntID;
            cdl.ShareType = 'V';
            if(Schema.sObjectType.ContentDocumentLink.isCreateable()){
            insert cdl;
            }
            
            System.debug('inserted id is '+cv.id);
            System.debug('file id is '+cdl.id);
            
        }
        
    }
    @AuraEnabled
    public static void  myCustomSaveForStatic(Object paramToSave,String acocuntID,String nameToSave,String staticNNameprefix){
        if(String.isBlank(staticNNameprefix)){
            staticNNameprefix = '';
        }
        System.debug('save inititalted '+paramToSave);
        String cleanValue = String.valueOf(paramToSave);
        String cleanBase64 = cleanValue.removeStart('data:image/png;base64,');
        ContentVersion cv = new ContentVersion();
        try{
        if(!Test.isRunningTest()){cv.VersionData = EncodingUtil.base64Decode(cleanBase64);}
        else{Blob b=Blob.valueOf('This is version data'); cv.VersionData = b;}
        cv.Title = 'staticDraw'+nameToSave;
        cv.PathOnClient ='staticDraw'+staticNNameprefix+nameToSave+'.PNG';
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        insert cv;
        
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id].ContentDocumentId;
        cdl.LinkedEntityId = acocuntID;
        cdl.ShareType = 'V';
        insert cdl;
        
        
        //System.debug('inserted id is '+cv.id);
       // System.debug('file id is '+cdl.id);
        
    }
    
    @AuraEnabled
    public static void inserStaticResourceFromLWC(String createdAttachmentID){
        copyIs(createdAttachmentID);
    }
    @AuraEnabled(cacheable=true)
    public static String savedImage(String accountId, String formUniqueId, String formCssId, Boolean isNew, String resourceName){
        Blob data;
        Id userId = UserInfo.getUserId();
        if(!isNew){
            List<ContentVersion> versions = [SELECT Id, VersionData FROM ContentVersion
            WHERE Form_css_id__c= :formCssId
            AND Form_Id__c= :formUniqueId];
            system.debug(formUniqueId + formCssId);
            system.debug(versions);
            if(versions!=null && versions.size()>0){
            data = versions[0].VersionData;
            String paramvalue = EncodingUtil.base64Encode(data);
            return paramvalue;
            }
        }
            List<StaticResource> resourceList = [
                SELECT Name, NamespacePrefix, SystemModStamp 
                FROM StaticResource 
                WHERE Name = :resourceName WITH SECURITY_ENFORCED
        ];
        system.debug('resourceName '+resourceName);                     
        system.debug('resourceList '+resourceList);                     
        if (resourceList.size() == 1) {
           String namespace = resourceList[0].NamespacePrefix;
           String preQuery= 'SELECT Id,ContactId,AccountId';
           List<User> userRecs = Database.query(Elixir_Utility.fetchUserQuery(preQuery) + ' FROM User WHERE Id =:userId');
            String accId = (String)userRecs[0].get('AccountId');
            if(userRecs != null && !userRecs.isEmpty() && String.isNotBlank(accId)){
                ElixirSuite__Elixir_Custom_Setting__c listCS = ElixirSuite__Elixir_Custom_Setting__c.getOrgDefaults();
                return listCS.ElixirSuite__Elixir_portal_url__c + '/resource/' 
              + resourceList[0].SystemModStamp.getTime() + '/' 
              + (namespace != null && namespace != '' ? namespace + '__' : '') 
              + resourceName;
            }
            else{
           return '/resource/' 
              + resourceList[0].SystemModStamp.getTime() + '/' 
              + (namespace != null && namespace != '' ? namespace + '__' : '') 
              + resourceName; 
            }
        } else return '';
    }
    
    @AuraEnabled
    public static string DeleteImage(String accountId, String formUniqueId, String formCssId, Boolean isNew, String resourceName){
        List<ContentDocument> listToDelete = new List<ContentDocument>();
        //  List<ContentVersion> listToInsert = new List<ContentVersion>();
        List<ContentVersion> versions = [SELECT Id, ContentDocumentId,VersionData FROM ContentVersion 
                                         WHERE Form_css_id__c =:formCssId AND Form_Id__c  =:formUniqueId];            
        system.debug(formUniqueId + formCssId);
        for (ContentVersion conver :versions) {
            try {
                listToDelete.add(new ContentDocument(Id =conver.ContentDocumentId));
                }
            catch(DmlException e) {
                System.debug('The following exception has occurred: ' + e.getMessage());
            }
            DMLManager.deleteAsUser(listToDelete);
        }
        
        List<StaticResource> resourceList = [
            SELECT Name, NamespacePrefix, SystemModStamp 
            FROM StaticResource 
            WHERE Name = :resourceName WITH SECURITY_ENFORCED
        ];                         
        if (resourceList.size() == 1) {
            String namespace = resourceList[0].NamespacePrefix;
            return '/resource/' 
                + resourceList[0].SystemModStamp.getTime() + '/' 
                + (namespace != null && namespace != '' ? namespace + '__' : '') 
                + resourceName; 
        } else return '';
    }
    private static MetadataService.MetadataPort createService(){ 
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();
        return service;     
    }
    @Future(callout=true)
    public static void copyIs(String createdAttachmentID){
        ContentVersion c =  [SELECT Id, VersionData, ContentDocumentId FROM ContentVersion where ContentDocumentID=:createdAttachmentID]; 
        System.debug('value c '+c);
        MetadataService.MetadataPort service = createService();     
        MetadataService.StaticResource staticResource = new MetadataService.StaticResource();
        staticResource.fullName = 'draw'+createdAttachmentID;
        staticResource.contentType = 'image/jpeg';
        staticResource.cacheControl = 'public';
        staticResource.content = EncodingUtil.base64Encode(c.VersionData);
         if (!Test.isRunningTest()) {
          Object v = service.createMetadata(new List<MetadataService.Metadata> { staticResource });
        }
      
    }
    @AuraEnabled
    public static Boolean checkStaticResourceReacordExistence(String createdAttachmentID){
        String toQuery = 'draw'+createdAttachmentID;
        List<StaticResource> checkValidity =  [SELECT ID,NAME from StaticResource where NAME =:toQuery WITH SECURITY_ENFORCED];
        if(checkValidity!=null && checkValidity.size()>0){
            //  Id toDelIDs =  [SELECT ID FROM ContentDocumentLink WHERE ContentDocumentId =: createdAttachmentID].Id;
            //   delete [ SELECT ID FROM ContentDocumentLink WHERE ID =: toDelIDs];
            // List<ContentDocumentLink> currentCreatedDocument = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId =: createdAttachmentID];
            // delete currentCreatedDocument;
            return true;
            
        }
        else {
            return false;
        }
    }
    
    global class ContentRequest
    {
        @InvocableVariable(label='Base 64 Image String' required=true)
        global String base64image;
        @InvocableVariable(label='File Name' required=true)
        global String fileName;
    }
    
    global class ContentResponse
    {
        @InvocableVariable(label='ContentVersion Id')
        global Id contentVersionId;
    }
    
}
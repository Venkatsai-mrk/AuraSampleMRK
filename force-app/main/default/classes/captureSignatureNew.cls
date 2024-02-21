public with sharing class captureSignatureNew  
{
    
    @AuraEnabled
    public static List<ContentDocument> displaySign(String parentId)
    {
        List<ContentDocument> lst_contentDoc = new List<ContentDocument>();
        String AttachName = 'Signature Capture'+parentId+'usersetting';
        try{
        for (ContentVersion conver : [SELECT id, Title, FileType,ContentUrl, createdby.name, ContentDocumentId FROM ContentVersion WHERE Title=:AttachName WITH SECURITY_ENFORCED]) 
        {
            lst_contentDoc.add(new ContentDocument( Id = conver.ContentDocumentId ));
        }
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        return lst_contentDoc;
    }
    
    @AuraEnabled
    public static void saveSignature(String signatureBody , String parentId){
        
        List<ContentDocument> lst_contentDoc = new List<ContentDocument>();
        String AttachName = 'Signature Capture'+parentId+'usersetting';
        for (ContentVersion conver : [SELECT id, Title, FileType,ContentUrl, createdby.name, ContentDocumentId FROM ContentVersion  WHERE Title=:AttachName WITH SECURITY_ENFORCED]) 
        {
            lst_contentDoc.add(new ContentDocument( Id = conver.ContentDocumentId ));
        }
        if(lst_contentDoc.size()<=0)
        {
            Set<Id> contentDocumentIdSet = new Set<Id>();
            ContentVersion ContVerFile = new ContentVersion();
            ContVerFile.IsMajorVersion = false;
            ContVerFile.VersionData = EncodingUtil.base64Decode(signatureBody);
            ContVerFile.Title = 'Signature Capture'+parentId+'usersetting';
            ContVerFile.ContentLocation= 's';
            ContVerFile.PathOnClient='Signature Capture'+parentId+'usersetting.png';
            if(Schema.sObjectType.ContentVersion.isCreateable()){
            insert ContVerFile;
            }
            
            System.debug('parent Id '+parentId);
            System.debug('file Id '+ContVerFile.Id);
            
            String contentId = [SELECT id, Title, FileType,ContentUrl, createdby.name, ContentDocumentId FROM ContentVersion  WHERE id=:ContVerFile.Id].ContentDocumentId;
            User usr = new User();
            if(schema.sobjecttype.User.isAccessible()
               && schema.sobjecttype.User.fields.Name.isAccessible()
               && schema.sobjecttype.User.fields.ElixirSuite__Signature_Attachment_Id__c.isAccessible()){
                   usr = [select id, name , ElixirSuite__Signature_Attachment_Id__c from User 
                   where id=: parentId WITH SECURITY_ENFORCED
                   LIMIT 1] ;
               }
            if (Schema.sObjectType.User.fields.ElixirSuite__Signature_Attachment_Id__c.isUpdateable()){
                usr.ElixirSuite__Signature_Attachment_Id__c = contentId ;
                update usr ;
            }
        } 
        else if(lst_contentDoc.size()>=0)
        {
            ContentVersion ContVerFile = new ContentVersion();
            ContVerFile = [select id, Title,IsMajorVersion,VersionData from ContentVersion where Title=:AttachName limit 1];
            if(ContVerFile.VersionData != null){
                ContVerFile.VersionData = EncodingUtil.base64Decode(signatureBody);
            }
            //ContVerFile.IsMajorVersion = false;
            //ContVerFile.Title = 'Signature Capture'+parentId;
            //ContVerFile.ContentLocation= 's';
            //ContVerFile.PathOnClient='Signature Capture'+parentId+'.png';
            if (Schema.sObjectType.ContentVersion.isUpdateable()) {
            update ContVerFile;
            }
            String contentId = [SELECT id, Title, FileType,ContentUrl, createdby.name, ContentDocumentId FROM ContentVersion  WHERE id=:ContVerFile.Id].ContentDocumentId;
            User usr = new User();
            if(schema.sobjecttype.User.isAccessible()
               && schema.sobjecttype.User.fields.Name.isAccessible()
               && schema.sobjecttype.User.fields.ElixirSuite__Signature_Attachment_Id__c.isAccessible()){
                   usr = [select id, name , ElixirSuite__Signature_Attachment_Id__c from User where id=: parentId limit 1] ;
               }
            if (Schema.sObjectType.User.fields.ElixirSuite__Signature_Attachment_Id__c.isUpdateable()){
                usr.ElixirSuite__Signature_Attachment_Id__c = contentId ;
                update usr ;
            }
        }     
    }
    
    @AuraEnabled
    public static Boolean matchOtp(String veriCode , Id patientId){
        Boolean matchingValue ;
        User usr = [SELECT Id,ElixirSuite__Verification_Code_New__c,name FROM User 
                    where id =: patientId WITH SECURITY_ENFORCED order by createdDate desc ];
        system.debug('ebf' + usr);
        String verCode = usr.ElixirSuite__Verification_Code_New__c ;
        system.debug('vw' + veriCode + ' ' + verCode);
        if(veriCode == verCode ){
            matchingValue = true ;
        }
        else{
            matchingValue = false ;
        }
        system.debug('the val is ' + matchingValue);
        return matchingValue ;
    }
    
    @AuraEnabled
    public static String userId() 
    {
        String userId = UserInfo.getUserId();
        return userId;
    }
}
public with sharing class captureSignatureUpdate 
{ 
	@AuraEnabled
    public static List<ContentDocument> displaySign(String parentId)
    {
        List<ContentDocument> lst_contentDoc = new List<ContentDocument>();
        String AttachName = 'Signature Capture'+parentId;
        try{
        for (ContentVersion conver : [SELECT id, Title, FileType,ContentUrl, createdby.name, ContentDocumentId FROM ContentVersion  WHERE Title=:AttachName WITH SECURITY_ENFORCED]) 
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
        String AttachName = 'Signature Capture'+parentId;
        for (ContentVersion conver : [SELECT id, Title, FileType,ContentUrl, createdby.name, ContentDocumentId FROM ContentVersion  WHERE Title=:AttachName WITH SECURITY_ENFORCED]) 
        {
            lst_contentDoc.add(new ContentDocument( Id = conver.ContentDocumentId ));
        }
        if(lst_contentDoc.size()>=0)
        {
            ContentVersion ContVerFile = new ContentVersion();
            ContVerFile = [select id, Title,IsMajorVersion,VersionData from ContentVersion where Title=:AttachName WITH SECURITY_ENFORCED limit 1];
            try{
            if(ContVerFile.VersionData != null){
            	ContVerFile.VersionData = EncodingUtil.base64Decode(signatureBody);
            }
            //ContVerFile.IsMajorVersion = false;
            //ContVerFile.Title = 'Signature Capture'+parentId;
            //ContVerFile.ContentLocation= 's';
            //ContVerFile.PathOnClient='Signature Capture'+parentId+'.png';
                }
            catch(Exception e){
            ExceptionLog.logError(e);
        }
        if (Schema.sObjectType.ContentVersion.isUpdateable()) {
            update ContVerFile;
        }
        }     
    }
    
    @AuraEnabled
    public static Boolean matchOtp(String veriCode , Id patientId){
       Boolean matchingValue ;
       User usr = [SELECT Id,ElixirSuite__Verification_Code_New__c,name FROM User 
                               where id =: patientId 
                               WITH SECURITY_ENFORCED
                               order by createdDate desc ];
        system.debug('ebf' + usr);
        String verCode = usr.ElixirSuite__Verification_Code_New__c ;
        system.debug('vw' + veriCode + ' ' + verCode);
        try{
        if(veriCode == verCode ){
            matchingValue = true ;
        }
        else{
             matchingValue = false ;
        }
        system.debug('the val is ' + matchingValue);
            }
         catch(Exception e){
            ExceptionLog.logError(e);
        }
        return matchingValue ;
        
    }
}
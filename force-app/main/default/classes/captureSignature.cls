public with sharing class captureSignature {
    @AuraEnabled
    public static void saveSignature(String signatureBody , String parentId){
        Attachment a = new Attachment();
        a.ParentId = parentId; 
        a.Body = EncodingUtil.base64Decode(signatureBody);
        a.ContentType = 'image/png';
        a.Name = 'Signature Capture.png';
        if(Schema.sObjectType.Attachment.isCreateable()
        && schema.sobjecttype.Attachment.fields.ParentId.isCreateable()
        && schema.sobjecttype.Attachment.fields.Body.isCreateable()
        && schema.sobjecttype.Attachment.fields.ContentType.isCreateable()
        && schema.sobjecttype.Attachment.fields.Name.isCreateable()){
        insert a;
    }
           
        
        Account acc = new Account();
        if(schema.sobjecttype.Account.isAccessible()
           && schema.sobjecttype.Account.fields.Name.isAccessible()
           && schema.sobjecttype.Account.fields.Signature_Attachment_Id__c.isAccessible()){
               acc = [select id, Signature_Attachment_Id__c from Account where id=: parentId WITH SECURITY_ENFORCED limit 1] ;
           }
        if (Schema.sObjectType.Account.fields.Signature_Attachment_Id__c.isUpdateable()){
            acc.Signature_Attachment_Id__c = a.id ;
            if (Schema.sObjectType.Account.isUpdateable()) {
            update acc ;
            }
        }
    }
    
    @AuraEnabled
    public static Boolean matchOtp(String veriCode , Id patientId){
       Boolean matchingValue ;
       Account acc = [SELECT Id,verification_code__c FROM Account 
                               where id =: patientId 
                               WITH SECURITY_ENFORCED
                               order by createdDate desc ];
        system.debug('ebf' + acc);
        String verCode = acc.verification_code__c ;
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
    
    
     //Added by Bharti
    @AuraEnabled
    public static tabStructureController.Sorted_List_Wrapper_For_Match sendEmails(Id recordId) {
      return tabStructureController.sendEmailFromPortal(recordId);  
}
    
        @AuraEnabled
    public static UserCommunityWrapper getUserCommunity() {
        Id userId = userinfo.getUserId();
        string query = 'SELECT Id,AccountId,Name,Username,ProfileId, Profile.Name,IsPortalEnabled,CreatedBy.IsPortalEnabled FROM User where IsPortalEnabled = true AND Id =\'' + string.escapeSingleQuotes(userId) + '\' LIMIT 1';
     User ur = Database.query(query);
        //User ur = [SELECT Id,Username,AccountId,IsPortalEnabled FROM User where Id =:userinfo.getUserId()];
        //Boolean isPortalEnabled = ur.IsPortalEnabled;
        
        UserCommunityWrapper userCommunityWrapper = new UserCommunityWrapper(ur.Username, ur.AccountId);
        //List<UserCommunityWrapper> result = new List<UserCommunityWrapper>();
        //result.add(userCommunityWrapper);
        return userCommunityWrapper;
    }
    
    public class UserCommunityWrapper {
    //@AuraEnabled public Boolean isPortalEnabled {get; set;}
    @AuraEnabled public String username {get; set;}
	@AuraEnabled public Id AccountId {get; set;}

    public UserCommunityWrapper(String username, Id AccountId ) {
        //this.isPortalEnabled = isPortalEnabled;
        this.username = username;
		this.AccountId = AccountId;
    }
    
}
}
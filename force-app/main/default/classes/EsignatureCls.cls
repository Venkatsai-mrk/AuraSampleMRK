public with sharing class EsignatureCls 
{
    public static String pwdm {get;set;}
    public static String oldCode {get;set;}
    public static String namespace {get;set;}
    
	@AuraEnabled
    public static Sorted_List_Wrapper_For_Match sendEmail ( Id recordId) {
        //AccountContactRelation acc = [SELECT id , ContactId FROM AccountContactRelation WHERE AccountId =: recordId];
        List<User> usr = [SELECT Id, Name , email FROM User WHERE Id =: recordId WITH SECURITY_ENFORCED];
        System.debug('genrate ot[p '+usr);
        if(usr[0].email != null){
            pwdm = generatePassword();
            // Send email to the account's email address  
            messaging.SingleEmailMessage email1=new messaging.SingleEmailMessage();
            string[]toAdd=new string[]{usr[0].email };
                email1.setToAddresses(toAdd);
            email1.setSubject('Verification Code For e-signing signatures');
            email1.setPlainTextBody('The verification code is' + ' ' + pwdm);
            email1.setSenderDisplayName('Treatment center');
            messaging.Email[] emails = new messaging.Email[]{email1};
                messaging.sendEmail(emails);
            
            List<User> result = new List<User>();
            try{
            result = [SELECT id , name , ElixirSuite__Verification_Code_New__c
                      FROM User where id =: recordId WITH SECURITY_ENFORCED limit 1];
            system.debug('the lost is' + result);
            for(User afv : result){
                afv.ElixirSuite__Verification_Code_New__c = pwdm ;      
            } 
            }
            catch(Exception e){
            ExceptionLog.logError(e);
               }
               if(Schema.sObjectType.User.isUpdateable()){
            update result ; 
               }
        }
        oldCode = pwdm ;
        Sorted_List_Wrapper_For_Match obj = new Sorted_List_Wrapper_For_Match(usr[0].email , oldCode );
        return obj;
    }
    @AuraEnabled
    public static String userId() 
    {
        String userId = UserInfo.getUserId();
        return userId;
    }
     public static string generatePassword(){
        Integer len = 6;
        Blob blobKey = crypto.generateAesKey(128);
        String key = EncodingUtil.convertToHex(blobKey);
        String pwd = key.substring(0,len);
        return pwd ;
    }
    
     public class Sorted_List_Wrapper_For_Match{
        
        @AuraEnabled public String regEmail;
        @AuraEnabled public String code;
        
        public Sorted_List_Wrapper_For_Match(String regEmails , String codes){
            this.regEmail = regEmails ;
            this.code = codes ;
        }
    }
 @AuraEnabled
    public static String getProfileName() 
    {
       List<Profile> prf = [SELECT Name FROM Profile WHERE Id=:userinfo.getProfileId () WITH SECURITY_ENFORCED];
       string PfName;
   for(Profile pf:prf){
     PfName = pf.Name;
  }
system.debug('PROFILE ' + prf );
system.debug('PfName ' + PfName);
        return PfName;
    }
}
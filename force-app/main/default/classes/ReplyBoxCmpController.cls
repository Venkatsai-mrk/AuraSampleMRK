public with sharing class ReplyBoxCmpController {
    @AuraEnabled
    public static string insertSubjectAndMessage(String patientId,List<Message_Subject__c> message,String messageBody,List<String> base64Data, String fileName, Boolean isPHI){
        
            List<String> fileNameLst = new  List<String>();
            //List<String> base64Lst = new  List<String>();
            List<ContentDocumentLink> conDocLinkLst= new  List<ContentDocumentLink>();

            Message_Subject__c oldMessage = message[0];
            //User ur = [Select Id,IsPortalEnabled,AccountId from User where Id=:UserInfo.getUserId() LIMIT 1];
            String userId = UserInfo.getUserId();
        List<User> users = Database.query('Select Id,IsPortalEnabled,AccountId from User where Id=:userId LIMIT 1');
       
        Boolean isPortalEnabled = (Boolean) users[0].get('IsPortalEnabled');
       
            Message_Subject__c messageSubject = new Message_Subject__c();
            if(isPortalEnabled){
                patientId = (String)users[0].get('AccountId');
                messageSubject.IsPortal__c = isPortalEnabled;
                messageSubject.Account__c = patientId;
            }else{
                messageSubject.IsPortal__c = false;
                messageSubject.Account__c = patientId;
            messageSubject.User__c = userId;
            }
            messageSubject.Subject__c = oldMessage.Subject__c;
            
            //messageSubject.User__c= oldMessage.CreatedBy.Id;
            String parentMsgId = oldMessage.Parent_Message__c;
            String grandMsgId = oldMessage.Grand_Parent_Message__c;
            if(parentMsgId==null && grandMsgId==null){
                messageSubject.Parent_Message__c = oldMessage.Id;
                messageSubject.Grand_Parent_Message__c = oldMessage.Id;
            }else if(parentMsgId!=null && grandMsgId!=null){
                messageSubject.Parent_Message__c = oldMessage.Id;
                messageSubject.Grand_Parent_Message__c = grandMsgId;
            }
        if(isPortalEnabled){
            Message_Subject__c user = [Select id, User__c from Message_Subject__c where Id =: messageSubject.Grand_Parent_Message__c WITH SECURITY_ENFORCED LIMIT 1];
            messageSubject.User__c = user.User__c;
        }
            insert messageSubject;
            
            Message_Details__c messageDetails = new Message_Details__c();
            messageDetails.Message_Body__c = messageBody;
            messageDetails.lookup_Message_Subject__c = messageSubject.Id;
            insert messageDetails;

        if(!isPortalEnabled){
            String virtualClassName = 'Messaging_Utility';
            List<Elixir_Pluggable_Classes__mdt> pluggableClass = new List<Elixir_Pluggable_Classes__mdt>();
            pluggableClass = [SELECT
                              DeveloperName,
                              Virtual_Class__c
                              FROM Elixir_Pluggable_Classes__mdt
                              WHERE DeveloperName='ReplyBoxCmpController'];
            if(!pluggableClass.isEmpty()){
                virtualClassName = pluggableClass[0].Virtual_Class__c;
            }
            Type t = Type.forName(virtualClassName);
            Messaging_Utility msgUtility = (Messaging_Utility) t.newInstance(); 
            msgUtility.sendEmail(oldMessage.Subject__c, messageBody, patientId, base64Data, fileName, isPHI);
        }
            
            List<ImageWrapper> files = (List<ImageWrapper>)JSON.deserialize(fileName , List<ImageWrapper>.class);
            for(ImageWrapper img :files){
                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.ContentDocumentId = img.value;
                cdl.LinkedEntityId = messageDetails.id;
                cdl.Visibility = 'AllUsers';
                conDocLinkLst.add(cdl);
        
                ContentDocumentLink cdlAccount = new ContentDocumentLink();
                cdlAccount.ContentDocumentId = img.value;
                cdlAccount.LinkedEntityId = patientId;
                cdlAccount.Visibility = 'AllUsers';
                conDocLinkLst.add(cdlAccount);
            }
            upsert conDocLinkLst;
        return 'success';
    }
    @AuraEnabled
    public static String getPatient(){
        String userId = UserInfo.getUserId();
        String patientId = '';
        List<User> users = Database.query('Select Id,AccountId from User where Id=:userId AND AccountId!= null');
        if(users!=null && users.size()>0){
            patientId = (String) users[0].get('AccountId');
        }
        return patientId;
        
    }
    public class ImageWrapper{
        public String name;
        public String value;
    }
}
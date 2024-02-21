public with sharing class ComposeMessageCmpController {
    @AuraEnabled
    public static string insertSubjectAndMessage(String mySubject,String myMessage,String patientId,List<String> base64Data, String fileName, Boolean isPHI){
      Boolean isPortalUser = false;
      String userId = UserInfo.getUserId();
      List<String> base64Lst = new  List<String>();
      List<Attachment> attachRecordList= new  List<Attachment>();
      List<ContentDocumentLink> conDocLinkLst= new  List<ContentDocumentLink>();
        List<User> users = Database.query('SELECT Id, IsPortalEnabled FROM User WHERE Id= :userId');
        if(users!=null){
            isPortalUser = (Boolean) users[0].get('IsPortalEnabled');
        }
        Message_Subject__c messageSubject = new Message_Subject__c();
        messageSubject.Subject__c = mySubject;
        messageSubject.Account__c = patientId;
        messageSubject.IsPortal__c = false;
        messageSubject.Viewed_Status__c = 'New';
        messageSubject.User__c = userId;
        DMLManager.insertAsUser(messageSubject); 

        Message_Details__c messageDetails = new Message_Details__c();
        messageDetails.Message_Body__c = myMessage;
        messageDetails.lookup_Message_Subject__c = messageSubject.Id;
        DMLManager.insertAsUser(messageDetails);
        
        String virtualClassName = 'Messaging_Utility';// Added in Review
        List<Elixir_Pluggable_Classes__mdt> pluggableClass = new List<Elixir_Pluggable_Classes__mdt>();
        pluggableClass = [SELECT
                        DeveloperName,
                        Virtual_Class__c
                        FROM Elixir_Pluggable_Classes__mdt
                        WHERE DeveloperName='ComposeMessageCmpController'
                        WITH SECURITY_ENFORCED];
        if(!pluggableClass.isEmpty()){
            virtualClassName = pluggableClass[0].Virtual_Class__c;
        }
        Type t = Type.forName(virtualClassName);
        Messaging_Utility msgUtility = (Messaging_Utility) t.newInstance(); 
        msgUtility.sendEmail(mySubject, myMessage, patientId, base64Data, fileName, isPHI);
        
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
        DMLManager.upsertAsUser(conDocLinkLst);
        return 'success';
    }
    @AuraEnabled  
    public static void deleteFile(String contentDocumentId){ 
        DMLManager.deleteAsUser([SELECT Id from ContentDocument WHERE Id = :contentDocumentId]);       
    }
    public class ImageWrapper{
        public String name;
        public String value;
    }
}
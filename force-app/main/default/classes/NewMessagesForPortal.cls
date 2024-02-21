public without sharing class NewMessagesForPortal {
    @AuraEnabled
    public static List<Message_Subject__c> getMessagesFromPatientChart(){
       String patientId='';
       String conId='';
       String uId = UserInfo.getUserId();
       List<User> userRecs = Database.query('SELECT id,ContactId FROM User WHERE Id =:uId');
       if(userRecs!=null && userRecs.size()>0){
           conId = (String)userRecs[0].get('ContactId');
       }
       List<Contact> contacts = Database.query('SELECT Id,AccountId FROM Contact WHERE Id= :conId');
       if(contacts!=null && contacts.size()>0){
           patientId = (String)contacts[0].get('AccountId');
       }
       List<Sobject> teamMembers = Database.query('SELECT Id,UserId FROM AccountTeamMember WHERE AccountId = :patientId');
       List<Id> userIds = new List<Id>();
       for(Sobject atm : teamMembers){
           userIds.add(String.valueOf(atm.get('UserId')));
           
       }

        List<Message_Subject__c> messageList = [SELECT Id, Account__c, CreatedDate, IsPortal__c, Subject__c, Viewed_Status__c, Sender__c, User__c 
                                        FROM Message_Subject__c 
                                        WHERE IsPortal__c = false AND Viewed_Status__c = 'New' 
                                        AND (Account__c = :patientId OR User__c IN :userIds) 
                                        WITH SECURITY_ENFORCED
                                        ORDER BY CreatedDate DESC LIMIT 3];
        return messageList;
        
    }
    @AuraEnabled
    public static void updateMessageViewStatus(String messageRecordId){

        List<Message_Subject__c> messageList = [SELECT Id,Viewed_Status__c FROM Message_Subject__c WHERE Id=:messageRecordId WITH SECURITY_ENFORCED];
        for(Message_Subject__c msg : messageList){
            msg.Viewed_Status__c = 'Viewed';
        }
        DMLManager.updateAsUser(messageList);
    }
    @AuraEnabled
    public static List<ListView> getListViews() {
        List<ListView> listviews =
            [SELECT Id,DeveloperName , Name FROM ListView WHERE SobjectType = 'ElixirSuite__Message_Subject__c' and DeveloperName ='Inbox' WITH SECURITY_ENFORCED];
        return listviews;
    }
}
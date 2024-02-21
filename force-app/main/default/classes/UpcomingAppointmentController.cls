public without sharing class UpcomingAppointmentController {
    @AuraEnabled
    public static List<Event> getData() {  
        
        User userRec = [SELECT id,ContactId FROM User WHERE Id =:UserInfo.getUserId() WITH SECURITY_ENFORCED];
        System.debug('userRec'+userRec); 
        String contactId = userRec.ContactId;
        List<Contact> contacts = [SELECT Id,AccountId FROM Contact WHERE Id= :contactId WITH SECURITY_ENFORCED];
        if(contacts!=null && contacts.size()>0){
            String accountId = contacts[0].AccountId;
            List<Account> accRec = [SELECT Id FROM Account WHERE Id= :accountId WITH SECURITY_ENFORCED];
            System.debug('accRec'+accRec);
            if(accRec!=null && accRec.size()>0){
                
                DateTime nowDateTime = DateTime.now();
                DateTime afterDateTime = nowDateTime.addMonths(1);
                List<Event> eventRecList = [SELECT Id,Location,Subject,StartDateTime FROM Event 
                                            WHERE WhatId= :accRec[0].Id AND StartDateTime >:nowDateTime AND StartDateTime <:afterDateTime
                                            WITH SECURITY_ENFORCED
                                   			ORDER BY StartDateTime];
                System.debug('eventList'+eventRecList);       
                return eventRecList;
            }
        }
        return new List<Event>{};
    }  
    @AuraEnabled
    public static String getAccountId() {  
        string acctId='';
        User userRec = [SELECT id,ContactId FROM User WHERE Id =:UserInfo.getUserId() WITH SECURITY_ENFORCED];
        System.debug('userRec'+userRec);
        String contactId = userRec.ContactId;
        List<Contact> contacts = [SELECT Id,AccountId FROM Contact WHERE Id= :contactId WITH SECURITY_ENFORCED];
        System.debug('contacts'+contacts);
        if(contacts!=null && contacts.size()>0){
            acctId = contacts[0].AccountId;
                    }
    return acctId;
    
    }
    @AuraEnabled(cacheable = true)
    public static string getProfile(){
        Id profileId = UserInfo.getProfileId();
    String profileName =[Select Id, Name from Profile where Id=:profileId].Name;
    system.debug('Profile Name'+profileName);
        return profileName;
    }      
}
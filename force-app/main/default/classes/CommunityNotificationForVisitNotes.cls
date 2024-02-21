public with sharing class CommunityNotificationForVisitNotes {
    public static Map<Id,String> accIdToName;
    public static String mySubject;
    
    public static void visitNotesNotifications(List<String> eventIdList) {
        accIdToName = new Map<Id,String>();
         ElixirSuite__Elixir_Custom_Setting__c settings = ElixirSuite__Elixir_Custom_Setting__c.getOrgDefaults();
        List<Event> appointmentLst = [SELECT Id,  
                                      WhatId, WhatCount, 
                                      ActivityDateTime, Subject,
                                      ActivityDate, StartDateTime,
                                      ElixirSuite__Practitioner__c,
                                      ElixirSuite__Practitioner__r.Id,  ElixirSuite__Practitioner__r.Name,
                                      ElixirSuite__Location__c,ElixirSuite__Location__r.Name, 
                                      AccountId,Account.Name, 
                                      EndDateTime, EndDate, 
                                      ElixirSuite__Status__c FROM Event
                                      WHERE Id IN :eventIdList WITH SECURITY_ENFORCED
                                      LIMIT 500];
         Map<Id, Event> evtMap=new Map<Id, Event>();
        for(event e: appointmentLst){
            evtMap.put(e.WhatId, e);
        }
        List<Account> scope = [SELECT ID,Name,Phone,ElixirSuite__Email_Id__c FROM Account where id =:evtMap.Keyset()  WITH security_enforced];
        Map<Id,String> accLstIds=new Map<Id,String>();
        for(Account acc :scope){
              accLstIds.put(acc.Id,acc.Email_Id__c);
              }
            
        EmailTemplate emailTemplate = [select Id, Subject, HtmlValue, 
                                       Body from EmailTemplate 
                                       where Id =: CreateFormForPortal.fetchEmailTemplateId('Notification_for_visit_notes') WITH SECURITY_ENFORCED];
        mySubject=emailTemplate.Subject;
        String templateId=emailTemplate.Id;
        Set<Id> attachmentIds =new Set<Id>();
        
        Map<Id, List<Message_Utility.OrderInfo>> patientIdToEventValueIds=new Map<Id, List<Message_Utility.OrderInfo>>();
        Map<Id,String> emailhtmlBody=new Map<Id,String>() ;
        for(Event appList :appointmentLst){
            
            DateTime startDateTime = appList.StartDateTime;
            String startTimeString = startDateTime.format('h:mm a');
            String startDateString = startDateTime.format('MMM dd, yyyy');
    		string appointSubject=appList.Subject;
            string practitionerName=appList.ElixirSuite__Practitioner__r.Name;
            
            String accountId = appList.AccountId;
           
            
            if(patientIdToEventValueIds.containsKey(accountId)){
                Message_Utility.OrderInfo info = new Message_Utility.OrderInfo();
                info.recordId = appList.Id;
                info.startDate=startDateString;
                info.appSubject=appointSubject;
                info.pracName=practitionerName;
                patientIdToEventValueIds.get(accountId).add(info);
            }else{
                Message_Utility.OrderInfo info = new Message_Utility.OrderInfo();
                info.recordId = appList.Id;
                info.startDate=startDateString;
                info.pracName=practitionerName;
                info.appSubject=appointSubject;
                accIdToName.put(accountId, appList.Account.Name);
                patientIdToEventValueIds.put(accountId, new List<Message_Utility.OrderInfo>{info});
            }
        
    }
        
        emailhtmlBody = createMessage(patientIdToEventValueIds);
        if(patientIdToEventValueIds!=null && patientIdToEventValueIds.size()>0 && settings.ElixirSuite__Common_message_utility__c == false){
            Message_Utility.sendEmail(patientIdToEventValueIds, accLstIds, templateId, mySubject, attachmentIds, false, emailhtmlBody);
        }
        }
        public static Map<Id,String> createMessage( Map<Id, List<Message_Utility.OrderInfo>> patientIdToEventValueIds){
        
        fflib_ISObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new List<Schema.SObjectType>{
                Message_Subject__c.sObjectType,
                    Message_Details__c.sObjectType
                    }
        );
        
        String timeStart = '';
            String dateStart='';
            String Practitioner='';
            String appointSubject='';
        
        Elixir_Custom_Setting__c portalUrl = ElixirSuite__Elixir_Custom_Setting__c.getOrgDefaults();
        EmailTemplate emailTemplate = [SELECT Id, Subject, HtmlValue, Body FROM EmailTemplate WHERE DeveloperName = 'Notification_for_visit_notes' WITH SECURITY_ENFORCED];
        String htmlBody = emailTemplate.HtmlValue;
        mySubject = emailTemplate.Subject;
       
        
        
        Map<Id,String> emailhtmlBody = new Map<Id,String>();
        for(String accountId :patientIdToEventValueIds.keySet()){
            
            htmlBody = htmlBody.replace('{!Account.Name}',accIdToName.get(accountId));
            List<Message_Utility.OrderInfo> orderInfoString = patientIdToEventValueIds.get(accountId);
            
            for(Message_Utility.OrderInfo info :orderInfoString){
                dateStart=info.startDate;
                Practitioner=info.pracName;
                appointSubject=info.appSubject;
                
            }
            
           mySubject = mySubject.replace('{!Organization.Name}',UserInfo.getOrganizationName()); 
            mySubject = mySubject.replace('{!Event.ActivityDate}' , dateStart);
            mySubject = mySubject.replace('{!Event.Subject}', appointSubject);
            
            htmlBody = htmlBody.replace('{!Organization.Name}' , UserInfo.getOrganizationName());
            htmlBody = htmlBody.replace('{!Event.ActivityDate}' , dateStart);
            htmlBody = htmlBody.replace('{Practitioner}' , Practitioner);
            htmlBody = htmlBody.replace('{!Event.Subject}', appointSubject);
            htmlBody = htmlBody.replace('{Patientportallink}', '<a href='+ portalUrl.Elixir_portal_url__c +'>click here</a>');
           /* if (portalUrl.ElixirSuite__Enable_portal_in_Elixir__c == true){
            htmlBody = htmlBody.replace('{Patientportallink}', '<a href=' + portalUrl.Elixir_portal_url__c + '>click here</a>');
            } else {
            // Remove the entire line by replacing it with an empty string
            htmlBody = htmlBody.replace('<p>Please login into your portal {Patientportallink}. </p>', '');
            }*/
            String htmlBodyForMessageCenter = htmlBody;
			

		// Use the replace method to remove the specified HTML content
			htmlBodyForMessageCenter = htmlBodyForMessageCenter.replace('<p>Please login into your portal {Patientportallink} to review the visit note. </p>', '');

			

            emailhtmlBody.put(accountId,htmlBody);
            
            String userId = UserInfo.getUserId();
            //Inserting a record in message subject 
            Message_Subject__c messageSubject = new Message_Subject__c();
            messageSubject.Subject__c = mySubject;
            messageSubject.Account__c = accountId;
            messageSubject.IsPortal__c = false;
            messageSubject.User__c = userId;
            uow.registerNew(messageSubject);
            
            //Inserting a record in message Detail 
            Message_Details__c messageDetails = new Message_Details__c();
            messageDetails.Message_Body__c = htmlBodyForMessageCenter;
            // messageDetails.lookup_Message_Subject__c = messageSubject.Id;
            uow.registerRelationship(messageDetails, Message_Details__c.lookup_Message_Subject__c , messageSubject);
            uow.registerNew(messageDetails);
            
         
        }
        uow.commitWork();
        return emailhtmlBody ;
        }
            
}
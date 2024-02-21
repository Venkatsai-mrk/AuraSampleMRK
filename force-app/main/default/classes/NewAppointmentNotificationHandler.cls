public without sharing class NewAppointmentNotificationHandler {
    public static void notifyPatientForNewAppointment(List<Event> eventLst){
        List<event> evtLstRecords=[SELECT Id, AccountId, WhatId, WhatCount, 
                                   Subject, ElixirSuite__Location__c,ElixirSuite__Location__r.Name, StartDateTime, EndDateTime, 
                                   EndDate, 
                                   ElixirSuite__Practitioner_Start_Time__c ,ElixirSuite__Practitioner__r.Name
                                   FROM Event WHERE Id IN :eventLst WITH SECURITY_ENFORCED];
        
        Map<Id, Event> evtMap=new Map<Id, Event>();
        for(event e: evtLstRecords){
            evtMap.put(e.WhatId, e);
        }
        List<Account> acc = [SELECT ID,Name,ElixirSuite__Preferences__c,Phone, 
                             ElixirSuite__Email_Id__c FROM Account where id =:evtMap.Keyset()  WITH security_enforced];
        Map<Id, Account> accMap=new Map<Id, Account>(acc);
        
        EmailTemplate emailTemplate = [select Id, Subject, HtmlValue, 
                                       Body from EmailTemplate where Id =: CreateFormForPortal.fetchEmailTemplateId('New_Appointments_for_Patient')];
        Elixir_Custom_Setting__c portalUrl = [SELECT Elixir_portal_url__c,ElixirSuite__Enable_portal_in_Elixir__c  FROM Elixir_Custom_Setting__c];
        
        
        fflib_ISObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new List<Schema.SObjectType>{
                Message_Subject__c.sObjectType,
                    Message_Details__c.sObjectType
                    }
        );
        
        List<OrgWideEmailAddress> specificOrgWideEmailAddress = [SELECT Id, Address FROM OrgWideEmailAddress LIMIT 1];
        for(string evt: evtMap.keySet()){
            if(accMap.get(evt).ElixirSuite__Preferences__c=='Email'){
                // Replace {Date} and {Time} merge fields in the email body
                DateTime startDateTime = evtMap.get(evt).StartDateTime;
                String startDateString = startDateTime.format('MMM dd, yyyy');
                String startTimeString = startDateTime.format('h:mm a');
                string loc=evtMap.get(evt).ElixirSuite__Location__r.Name;
                string appointSubject=evtMap.get(evt).Subject;
                
                
                String htmlBody = emailTemplate.HtmlValue;
                
                htmlBody = htmlBody.replace('{!Account.Name}',accMap.get(evt).Name); 
                // htmlBody = htmlBody.replace('{!Organization.Name}', UserInfo.getOrganizationName());
                htmlBody = htmlBody.replace('{!Contact.Name}', evtMap.get(evt).ElixirSuite__Practitioner__r.Name);
                htmlBody = htmlBody.replace('{appointment subject}', appointSubject);
                htmlBody = htmlBody.replace('{Date}', startDateString);
                htmlBody = htmlBody.replace('{Time}', startTimeString); 
                htmlBody = htmlBody.replace('{!Account.Phone}', accMap.get(evt).Phone); 
                
                htmlBody = htmlBody.replace('{!Event.Location}', loc);
                htmlBody = htmlBody.replace('{!ElixirSuite__Provider__c.Name}', loc);
                //  htmlBody = htmlBody.replace('{Patientportallink}', '<a href='+ portalUrl.Elixir_portal_url__c+ '>click here</a>');
                if (portalUrl.ElixirSuite__Enable_portal_in_Elixir__c == true){
        		htmlBody = htmlBody.replace('{Patientportallink}', '<a href=' + portalUrl.Elixir_portal_url__c + '>click here</a>');
   			 	} else {
        		// Remove the entire line by replacing it with an empty string
       		 	htmlBody = htmlBody.replace('<p>Please login into your portal {Patientportallink}. </p>', '');
    			}
                
                // process the merge fields
                String subject = emailTemplate.Subject;
                subject = subject.replace('{!Contact.Name}',evtMap.get(evt).ElixirSuite__Practitioner__r.Name); 
                String plainBody = emailTemplate.Body;
                
                
                //build the email message
                Messaging.Singleemailmessage email = new Messaging.Singleemailmessage();
                email.setTargetObjectId(UserInfo.getUserId());
                email.setSaveAsActivity(false);
                email.setTreatTargetObjectAsRecipient(false);
                if(specificOrgWideEmailAddress!=null && specificOrgWideEmailAddress.size() >0){
                    email.setOrgWideEmailAddressId(specificOrgWideEmailAddress[0].Id);   
                  }
                email.setToAddresses(new List<String>{accMap.get(evt).ElixirSuite__Email_Id__c});      
                email.setSubject(subject);
                email.setHtmlBody(htmlBody);
                email.setPlainTextBody(plainBody);
                Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {email};
                Messaging.SendEmailResult[] results;
            	// Call the sendEmailMessages method 
			 	results=sendEmailMessages(messages);
                if (portalUrl.ElixirSuite__Enable_portal_in_Elixir__c == true){
                String userId = UserInfo.getUserId();
                //Inserting a record in message subject 
                Message_Subject__c messageSubject = new Message_Subject__c();
                messageSubject.Subject__c = subject;
                messageSubject.Account__c = evt;
                messageSubject.IsPortal__c = false;
                messageSubject.User__c = userId;
                uow.registerNew(messageSubject);
                
                //Inserting a record in message Detail 
                Message_Details__c messageDetails = new Message_Details__c();
                messageDetails.Message_Body__c = htmlBody;
                uow.registerRelationship(messageDetails, Message_Details__c.lookup_Message_Subject__c , messageSubject);
                uow.registerNew(messageDetails);
                }
                
            }
        }
        
        uow.commitWork();
        
    }
    public static Messaging.SendEmailResult[] sendEmailMessages(Messaging.SingleEmailMessage[] email) {
        return Messaging.sendEmail(email);
    }
}
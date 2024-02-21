public with sharing class VisitSummaryNotificationHandler {
    public static void visitNotifications(String accountId) {
        
        
        Account acc = [SELECT ID,Name,ElixirSuite__Email_Id__c FROM Account where id = :AccountId WITH security_enforced];
        EmailTemplate emailTemplate = [select Id, Subject, HtmlValue, Body from EmailTemplate where Id =: CreateFormForPortal.fetchEmailTemplateId('Patient_Notification_for_visit_summaries') WITH security_enforced];
        String htmlBody = emailTemplate.HtmlValue;
        
        //Elixir_Custom_Setting__c portalUrl = [SELECT Elixir_portal_url__c  FROM Elixir_Custom_Setting__c];
        Elixir_Custom_Setting__c portalUrl = ElixirSuite__Elixir_Custom_Setting__c.getOrgDefaults();
        
        htmlBody = htmlBody.replace('{!Account.Name}',acc.Name); 
        htmlBody = htmlBody.replace('{!Organization.Name}', UserInfo.getOrganizationName());
        htmlBody = htmlBody.replace('{Patientportallink}', '<a href='+ portalUrl.Elixir_portal_url__c+ '>click here</a>');
        // process the merge fields
        String subject = emailTemplate.Subject;
        subject = subject.replace('{!Organization.Name}',UserInfo.getOrganizationName()); 
        String plainBody = emailTemplate.Body;
        
        List<OrgWideEmailAddress> specificOrgWideEmailAddress = [SELECT Id, Address FROM OrgWideEmailAddress LIMIT 1];
        //build the email message
        Messaging.Singleemailmessage email = new Messaging.Singleemailmessage();
        email.setTargetObjectId(UserInfo.getUserId());
        email.setSaveAsActivity(false);
        email.setTreatTargetObjectAsRecipient(false);
        email.setToAddresses(new List<String>{acc.ElixirSuite__Email_Id__c}); 
        if(specificOrgWideEmailAddress!=null && specificOrgWideEmailAddress.size() >0){
            email.setOrgWideEmailAddressId(specificOrgWideEmailAddress[0].Id);   
          }      
        email.setSubject(subject);
        email.setHtmlBody(htmlBody);
        email.setPlainTextBody(plainBody);           
        Messaging.sendEmail(new Messaging.SingleEmailmessage[] {email});  

        
        
        String userId = UserInfo.getUserId();
        //Inserting a record in message subject 
        Message_Subject__c messageSubject = new Message_Subject__c();
        messageSubject.Subject__c = subject;
        messageSubject.Account__c = accountId;
        messageSubject.IsPortal__c = false;
        messageSubject.User__c = userId;
        DMLManager.insertAsUser(messageSubject);
        
        System.debug('messageSubject: ' + messageSubject.Id);
        System.debug('messageSubject - subject: ' + messageSubject.Subject__c);
        
     
         //Inserting a record in message Detail
        Message_Details__c messageDetails = new Message_Details__c();
        messageDetails.Message_Body__c = htmlBody;
        messageDetails.lookup_Message_Subject__c = messageSubject.Id;
        DMLManager.insertAsUser(messageDetails);
        
        System.debug('messageDetails-Body: ' + messageDetails.Message_Body__c);
    }
}
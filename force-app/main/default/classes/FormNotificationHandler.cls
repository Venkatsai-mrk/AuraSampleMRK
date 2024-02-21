public with sharing class FormNotificationHandler {
    public static Map<Id,String> accIdToName;
    public static String mySubject;
    public static void formNotifications(Map<Id,String> accLstIds) {
        //  code for form notification  
        accIdToName = new Map<Id,String>();
         ElixirSuite__Elixir_Custom_Setting__c settings = ElixirSuite__Elixir_Custom_Setting__c.getOrgDefaults();
         Decimal intervalValue=48;
        if(settings.ElixirSuite__Form_reminder_Interval__c !=null){
            intervalValue=settings.ElixirSuite__Form_reminder_Interval__c;
        }
        List<ElixirSuite__Form_Value__c> formRecordsLst =[SELECT Id, Name,ElixirSuite__Form_Name__c, ElixirSuite__Account__c,ElixirSuite__Account__r.Name,
                                                          ElixirSuite__Patient_Notified__c,ElixirSuite__Form_Portal_Status__c, ElixirSuite__Status__c 
                                                          FROM ElixirSuite__Form_Value__c  
                                                          WHERE ElixirSuite__Status__c !='Completed' 
                                                          AND ElixirSuite__Form_Portal_Status__c !='Submitted to Provider'
                                                          AND ElixirSuite__Notification_Interval__c = :intervalValue
                                                          AND ElixirSuite__Patient_Notified__c != NULL 
                                                          AND  ElixirSuite__Account__c IN :accLstIds.keySet() WITH security_enforced];
        
        
        EmailTemplate emailTemplate = [select Id, Subject, HtmlValue, Body from EmailTemplate where Id =: CreateFormForPortal.fetchEmailTemplateId('Form_completion_reminder') WITH security_enforced];
        String mySubject=emailTemplate.Subject;
        String templateId=emailTemplate.Id;
        Set<Id> attachmentIds =new Set<Id>();
        List<ElixirSuite__Form_Value__c> formvalueLstUpdate = new List<ElixirSuite__Form_Value__c>();
        Map<Id, List<Message_Utility.OrderInfo>> patientIdToFormValueIds=new Map<Id, List<Message_Utility.OrderInfo>>();
        Map<Id,String> emailhtmlBody=new Map<Id,String>() ;
        for(ElixirSuite__Form_Value__c formlst :formRecordsLst){
            formlst.ElixirSuite__Patient_Notified__c = System.now();
            formvalueLstUpdate.add(formlst);
            String accountId = formlst.ElixirSuite__Account__c;
            if(patientIdToFormValueIds.containsKey(accountId)){
                Message_Utility.OrderInfo info = new Message_Utility.OrderInfo();
                info.recordId = formlst.Id;
                info.name = formlst.ElixirSuite__Form_Name__c;
                patientIdToFormValueIds.get(accountId).add(info);
            }else{
                Message_Utility.OrderInfo info = new Message_Utility.OrderInfo();
                info.recordId = formlst.Id;
                info.name = formlst.ElixirSuite__Form_Name__c;
                accIdToName.put(accountId, formlst.ElixirSuite__Account__r.Name);
                patientIdToFormValueIds.put(accountId, new List<Message_Utility.OrderInfo>{info});
            }
        }
        //update formvalueLstUpdate;
        DMLManager.updateAsUser(formvalueLstUpdate);
        emailhtmlBody = createMessage(patientIdToFormValueIds);
        if(patientIdToFormValueIds!=null && patientIdToFormValueIds.size()>0 && settings.ElixirSuite__Common_message_utility__c == false){
           Message_Utility.sendEmail(patientIdToFormValueIds, accLstIds, templateId, mySubject, attachmentIds, false, emailhtmlBody);
        }
    }
    public static Map<Id,String> createMessage( Map<Id, List<Message_Utility.OrderInfo>> patientIdToFormValueIds){
        
        fflib_ISObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new List<Schema.SObjectType>{
                Message_Subject__c.sObjectType,
                    Message_Details__c.sObjectType
                    }
        );
        
        String userId = UserInfo.getUserId();
       // Elixir_Custom_Setting__c portalUrl = [Select Elixir_portal_url__c,ElixirSuite__Form_reminder_Interval__c  from Elixir_Custom_Setting__c];
        Elixir_Custom_Setting__c portalUrl = ElixirSuite__Elixir_Custom_Setting__c.getOrgDefaults();
        EmailTemplate emailTemplate = [SELECT Id, Subject, HtmlValue, Body FROM EmailTemplate WHERE DeveloperName = 'Form_completion_reminder' WITH security_enforced];
        String htmlBody = emailTemplate.HtmlValue;
        mySubject = emailTemplate.Subject;
        Map<Id,String> emailhtmlBody = new Map<Id,String>();
        for(String accountId :patientIdToFormValueIds.keySet()){
           
            htmlBody = htmlBody.replace('{!Account.Name}',accIdToName.get(accountId));
            List<Message_Utility.OrderInfo> orderInfoString = patientIdToFormValueIds.get(accountId);
            String formName = '';
            for(Message_Utility.OrderInfo info :orderInfoString){
                formName+= info.name + ', ';
              // formName+= info.name + '\n';
            }
            formName = formName.removeEnd(',');
            htmlBody = htmlBody.replace('{!Organization.Name}' , UserInfo.getOrganizationName());
            htmlBody = htmlBody.replace('{!ElixirSuite__Form_Value__c.ElixirSuite__Form_Name__c}' , formName);
            //htmlBody = htmlBody.replace('{Patientportallink}', '<a href='+ portalUrl.Elixir_portal_url__c +'>click here</a>');
            if (portalUrl.ElixirSuite__Enable_portal_in_Elixir__c == true){
                htmlBody = htmlBody.replace('{Patientportallink}', '<a href=' + portalUrl.Elixir_portal_url__c + '>click here</a>');
                    } else {
                // Remove the entire line by replacing it with an empty string
                    htmlBody = htmlBody.replace('<p>Please login into your portal {Patientportallink}. </p>', '');
                }
            
            emailhtmlBody.put(accountId,htmlBody);
            if (portalUrl.ElixirSuite__Enable_portal_in_Elixir__c == true){
                //Inserting a record in message subject 
                Message_Subject__c messageSubject = new Message_Subject__c();
                messageSubject.Subject__c = mySubject;
                messageSubject.Account__c = accountId;
                messageSubject.IsPortal__c = false;
                messageSubject.User__c = userId;
                uow.registerNew(messageSubject);
                
                //Inserting a record in message Detail 
                Message_Details__c messageDetails = new Message_Details__c();
                messageDetails.Message_Body__c = htmlBody;
                 // messageDetails.lookup_Message_Subject__c = messageSubject.Id;
                uow.registerRelationship(messageDetails, Message_Details__c.lookup_Message_Subject__c , messageSubject);
                uow.registerNew(messageDetails);
                
            }
        }
        uow.commitWork();
        return emailhtmlBody;
    }
}
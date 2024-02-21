public with sharing class PaymentNotificationHandler {
    public static String mySubject;
    public static Map<Id,String> accIdToName;
    public static void paymentNotifications(Map<Id,String> accLstIds) {
        accIdToName = new Map<Id,String>();
        ElixirSuite__Elixir_Custom_Setting__c settings = ElixirSuite__Elixir_Custom_Setting__c.getOrgDefaults();
        Decimal intervalValue=48;
        if(settings.ElixirSuite__Payment_reminder_interval__c !=null){
            intervalValue=settings.ElixirSuite__Payment_reminder_interval__c;
        }
        
        List<ElixirSuite__Payment_Schedule__c> paymentRecordsLst =[SELECT Id, Name, RecordTypeId, ElixirSuite__Account__c,ElixirSuite__Patient_Notified__c, 
                                                                   ElixirSuite__Account__r.Name, ElixirSuite__Amount_Paid__c, 
                                                                   ElixirSuite__Due_Date__c, ElixirSuite__Installment_Amount__c, 
                                                                   ElixirSuite__Last_Payment_Amount__c, ElixirSuite__Last_Payment_Made__c, 
                                                                   ElixirSuite__Pay_Frequency__c, ElixirSuite__Payment_Schedule__c, 
                                                                   ElixirSuite__Payment_Status__c, ElixirSuite__Status__c,ElixirSuite__Balance_Due1__c, 
                                                                   ElixirSuite__Payment_Interval__c FROM ElixirSuite__Payment_Schedule__c  
                                                                   WHERE ElixirSuite__Payment_Status__c !='Paid'
                                                                   AND ElixirSuite__Patient_Notified__c=null
                                                                   AND ElixirSuite__Payment_Interval__c = :intervalValue
                                                                   AND  ElixirSuite__Account__c IN :accLstIds.keySet()  WITH security_enforced  LIMIT 500];
        
        EmailTemplate emailTemplate = [select Id, Subject, HtmlValue, Body from EmailTemplate 
                                       where Id =: CreateFormForPortal.fetchEmailTemplateId('Payment_completion_reminder') 
                                       WITH security_enforced];
        mySubject=emailTemplate.Subject;
        String templateId=emailTemplate.Id;
        Set<Id> attachmentIds =new Set<Id>();
       
        
        Map<Id, List<Message_Utility.OrderInfo>> patientIdToPaymentValueIds=new Map<Id, List<Message_Utility.OrderInfo>>();
        Map<Id,String> emailhtmlBody=new Map<Id,String>() ;
        List<ElixirSuite__Payment_Schedule__c> paymentvalueLstUpdate = new List<ElixirSuite__Payment_Schedule__c>();
        for(ElixirSuite__Payment_Schedule__c paymentList :paymentRecordsLst){
            paymentList.ElixirSuite__Patient_Notified__c = System.now();
            paymentvalueLstUpdate.add(paymentList);
            
            String accountId = paymentList.ElixirSuite__Account__c;
            
            if(patientIdToPaymentValueIds.containsKey(accountId)){
                Message_Utility.OrderInfo info = new Message_Utility.OrderInfo();
                info.recordId = paymentList.Id;
                info.amount=paymentList.ElixirSuite__Balance_Due1__c;
                info.dueDate = paymentList.ElixirSuite__Due_Date__c;
                patientIdToPaymentValueIds.get(accountId).add(info);
            }else{
                Message_Utility.OrderInfo info = new Message_Utility.OrderInfo();
                info.recordId = paymentList.Id;
                info.amount=paymentList.ElixirSuite__Balance_Due1__c;
                info.dueDate = paymentList.ElixirSuite__Due_Date__c;
                accIdToName.put(accountId, paymentList.ElixirSuite__Account__r.Name);
                patientIdToPaymentValueIds.put(accountId, new List<Message_Utility.OrderInfo>{info});
            }
        }
        DMLManager.updateAsUser(paymentvalueLstUpdate);
        
        emailhtmlBody = createMessage(patientIdToPaymentValueIds);
        if(patientIdToPaymentValueIds!=null && patientIdToPaymentValueIds.size()>0 && settings.ElixirSuite__Common_message_utility__c == false){
            Message_Utility.sendEmail(patientIdToPaymentValueIds, accLstIds, templateId, mySubject, attachmentIds, false, emailhtmlBody);
        }
        
    }
    public static Map<Id,String> createMessage( Map<Id, List<Message_Utility.OrderInfo>> patientIdToPaymentValueIds){
        
        fflib_ISObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new List<Schema.SObjectType>{
                Message_Subject__c.sObjectType,
                    Message_Details__c.sObjectType
                    }
        );
        
       
        // Elixir_Custom_Setting__c portalUrl = [Select Elixir_portal_url__c,ElixirSuite__Payment_reminder_interval__c  from Elixir_Custom_Setting__c];
        Elixir_Custom_Setting__c portalUrl = ElixirSuite__Elixir_Custom_Setting__c.getOrgDefaults();
         
        EmailTemplate emailTemplate = [SELECT Id, Subject, HtmlValue, Body FROM EmailTemplate WHERE DeveloperName = 'Payment_completion_reminder' WITH security_enforced];
        String rawHtmlBody = emailTemplate.HtmlValue;
        mySubject = emailTemplate.Subject;
        mySubject = mySubject.replace('{!Organization.Name}',UserInfo.getOrganizationName()); 
        Map<Id,String> emailhtmlBody = new Map<Id,String>();
        for(String accountId :patientIdToPaymentValueIds.keySet()){
            String htmlBody = rawHtmlBody;
            htmlBody = htmlBody.replace('{!Account.Name}',accIdToName.get(accountId));
            List<Message_Utility.OrderInfo> orderInfoString = patientIdToPaymentValueIds.get(accountId);
            
            Double pendingAmount;
            Date lastDate;
            
            for(Message_Utility.OrderInfo info :orderInfoString){
                pendingAmount= info.amount;
                lastDate=info.dueDate;
            }
             
            htmlBody = htmlBody.replace('{!Organization.Name}' , UserInfo.getOrganizationName());
            
            htmlBody = htmlBody.replace('{!ElixirSuite__Payment_Schedule__c.ElixirSuite__Balance_Due1__c}' , String.valueOf(pendingAmount));
            htmlBody = htmlBody.replace('{!ElixirSuite__Payment_Schedule__c.ElixirSuite__Due_Date__c}' , String.valueOf(lastDate));
            if (portalUrl.ElixirSuite__Enable_portal_in_Elixir__c == true){
        	htmlBody = htmlBody.replace('{Patientportallink}', '<a href=' + portalUrl.Elixir_portal_url__c + '>click here</a>');
   			 } else {
        	// Remove the entire line by replacing it with an empty string
       		 htmlBody = htmlBody.replace('<p>Please login into your portal {Patientportallink}. </p>', '');
    		}
            emailhtmlBody.put(accountId,htmlBody);
            if (portalUrl.ElixirSuite__Enable_portal_in_Elixir__c == true){
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
            messageDetails.Message_Body__c = htmlBody;
            // messageDetails.lookup_Message_Subject__c = messageSubject.Id;
            uow.registerRelationship(messageDetails, Message_Details__c.lookup_Message_Subject__c , messageSubject);
            uow.registerNew(messageDetails);
             }
        }
        
        uow.commitWork();
        
        return emailhtmlBody ;
    }
}
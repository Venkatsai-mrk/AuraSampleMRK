public with sharing class LabNotificationHandler implements Queueable{
    public static Map<Id,String> accIdToName;
    public static String mySubject;
    public static List<Attachment> attch;
    public static Map<Id,Id> labToAcc = new Map<Id,Id>();
    public static Map<Id,Message_Details__c> accIdToDetails = new Map<Id,Message_Details__c>();
    Map<Id,String> accRecordIds;
    
    public LabNotificationHandler(Map<Id,String> accRecordIdsToEmail){
        this.accRecordIds = accRecordIdsToEmail;
    }
    public void execute(QueueableContext context){
        accIdToName = new Map<Id,String>();
        
        List<Lab_Order__c> labOrderLst = [SELECT Id, Account_Id__c, Account_Id__r.Name,  ElixirSuite__Test_Name__c
                                          FROM Lab_Order__c 
                                          WHERE Order_result_received__c != null 
                                          AND Patient_notified__c = null 
                                          AND Account_Id__c=:accRecordIds.keySet() 
                                          WITH SECURITY_ENFORCED 
                                          LIMIT 500];
        system.debug('LabOrder lst = '+labOrderLst);
        Set<Id> setId = new Set<Id>();
        if(labOrderLst!=null && labOrderLst.size()>0){
            setId = (new Map<Id,Lab_Order__c>(labOrderLst)).keySet();
        }
        system.debug(setId);
        Map<Id,Id> labToAttachmentId = new Map<Id,Id>();
        Set<Id> attachIds = new Set<Id>();
        attch = new List<Attachment>();
        attch = [Select id, parentId, Body
                 FROM Attachment 
                 where ParentId IN: setId
                 ORDER BY CreatedDate ASC];
        for(Attachment a : attch){
            if(attch!=null && attch.size()>0){
                labToAttachmentId.put(a.ParentId, a.Id);
                attachIds.add(a.Id);   
            }
            system.debug(labToAttachmentId);
            system.debug(attachIds);
        }
        
        Map<Id, List<Message_Utility.OrderInfo>> patientIdToLabOrderIds = new Map<Id, List<Message_Utility.OrderInfo>>();
        List<Lab_Order__c> labOrderToUpdate = new List<Lab_Order__c>();
        Map<Id,String> emailhtmlBody;
        for(Lab_Order__c labOrder : labOrderLst){
            //patientIdToLabOrderIds.put(labOrder.Account_Id__c, new List<OrderInfo>());
            labOrder.Patient_notified__c = System.now();
            String accountId = labOrder.Account_Id__c;
            if(patientIdToLabOrderIds.containsKey(accountId)){
                Message_Utility.OrderInfo info = new Message_Utility.OrderInfo();
                info.recordId = labOrder.Id;
                info.name = labOrder.Test_Name__c;
                if(labToAttachmentId.containsKey(labOrder.Id)){
                    info.attachmentId = labToAttachmentId.get(labOrder.Id);
                }
                patientIdToLabOrderIds.get(accountId).add(info);
            }else{
                Message_Utility.OrderInfo info = new Message_Utility.OrderInfo();
                info.recordId = labOrder.Id;
                info.name = labOrder.Test_Name__c;
                if(labToAttachmentId.containsKey(labOrder.Id)){
                    info.attachmentId = labToAttachmentId.get(labOrder.Id);
                }
                accIdToName.put(accountId, labOrder.Account_Id__r.Name);
                patientIdToLabOrderIds.put(accountId, new List<Message_Utility.OrderInfo>{info});
            }
            labOrderToUpdate.add(labOrder);
            system.debug(patientIdToLabOrderIds);
            
        }
        emailhtmlBody = createMessage(patientIdToLabOrderIds, attachIds);
        system.debug(emailhtmlBody);
        
        if(patientIdToLabOrderIds!=null && patientIdToLabOrderIds.size()>0){
            Message_Utility.sendEmail(patientIdToLabOrderIds, accRecordIds, null, mySubject, attachIds, false, emailhtmlBody);
            
        }
        
        DMLManager.updateAsUser(labOrderToUpdate);    
        
    }
    
    public static Map<Id,String> createMessage( Map<Id, List<Message_Utility.OrderInfo>> patientIdToLabOrderIds, Set<Id> attachmentIds){
        
        fflib_ISObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new List<Schema.SObjectType>{
                Message_Subject__c.sObjectType,
                    Message_Details__c.sObjectType
                    }
        );
        Map<Id,Attachment> attachments = new Map<Id,Attachment>();           
        if(attachmentIds!=null && attachmentIds.size()>0){
            attachments = new Map<Id,Attachment>(attch);
            
        }
        
        Id userId = UserInfo.getUserId();
        Elixir_Custom_Setting__c portalUrl = [SELECT Elixir_portal_url__c 
                                              FROM Elixir_Custom_Setting__c
                                              WITH SECURITY_ENFORCED];
        
        EmailTemplate emailTemplate = [SELECT Id, Subject, HtmlValue, Body 
                                       FROM EmailTemplate 
                                       WHERE DeveloperName = 'Notification_for_eLab_result'
                                       WITH SECURITY_ENFORCED];
        String htmlBody = emailTemplate.HtmlValue;
        mySubject = emailTemplate.Subject;
        mySubject = mySubject.replace('{!Organization.Name}', UserInfo.getOrganizationName());
        htmlBody = htmlBody.replace('{!Organization.Name}', UserInfo.getOrganizationName());
        String templateId = emailTemplate.Id;
        Map<Id,String> emailhtmlBody = new Map<Id,String>();
        for(String accountId :patientIdToLabOrderIds.keySet()){
            htmlBody = htmlBody.replace('{!Account.Name}',accIdToName.get(accountId));
            String testName = '';
            //replace body accordingly
            for(Message_Utility.OrderInfo info :patientIdToLabOrderIds.get(accountId)){
                testName+= info.name + ', ';               
                labToAcc.put(info.recordId, accountId);
            }
            testName = testName.removeEnd(',');
            htmlBody = htmlBody.replace('{!ElixirSuite__Lab_Order__c.ElixirSuite__Test_Name__c}' , testName);
            htmlBody = htmlBody.replace('{link}', '<a href='+ portalUrl.Elixir_portal_url__c+ '>click here</a>');            
            emailhtmlBody.put(accountId,htmlBody);
            
            Message_Subject__c messageSubject = new Message_Subject__c();
            messageSubject.Subject__c = mySubject;
            messageSubject.Account__c = accountId;
            messageSubject.IsPortal__c = false;
            messageSubject.User__c = userId;
            uow.registerNew(messageSubject);
            
            Message_Details__c messageDetail = new Message_Details__c();
            messageDetail.Message_Body__c = htmlBody;
            //messageDetail.lookup_Message_Subject__c = messageSubject.Id;
            uow.registerRelationship(messageDetail, Message_Details__c.lookup_Message_Subject__c , messageSubject);
            uow.registerNew(messageDetail);   
            accIdToDetails.put(accountId, messageDetail);
        }
        uow.commitWork();
        
        
        
        List<ContentDocumentLink> links = new List<ContentDocumentLink>();
        Map<Id,ContentVersion> versionsMap = new Map<Id,ContentVersion>();
        for(String attch : attachments.keySet()){
            Attachment attach = attachments.get(attch);
            ContentVersion cv = new ContentVersion();
            cv.Title = 'pdfReport.pdf';
            cv.PathOnClient = '/'+'pdf.Report.pdf';
            cv.ContentLocation = 's';
            cv.VersionData = attach.Body;
            
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.LinkedEntityId = attach.ParentId;
            cdl.Visibility = 'AllUsers';
            links.add(cdl);
            
            versionsMap.put(attach.ParentId, cv);
        }
        insert versionsMap.values();
        system.debug(versionsMap);
        system.debug(links);
        
        List<ContentVersion> contents = [SELECT Id,ContentDocumentId 
                                         FROM ContentVersion 
                                         WHERE Id IN :versionsMap.values()
                                         WITH SECURITY_ENFORCED];
        Map<Id,ContentVersion> contentMap = new Map<Id,ContentVersion>(contents);
        system.debug(contents.size());
        system.debug('Map ==='+contentMap);
        for(ContentDocumentLink link : links){
            String parentId = link.LinkedEntityId;//Lab Id
            system.debug(parentId);
            String accId = labToAcc.get(parentId);//Account Id
            String messageId = accIdToDetails.get(accId).Id;
            if(versionsMap.containsKey(parentId)){
                String cvId = versionsMap.get(parentId).Id;
                if(contentMap.containsKey(cvId)){
                    link.ContentDocumentId = contentMap.get(cvId).ContentDocumentId;
                }
                
            }
            link.LinkedEntityId = messageId;
            
        }
        
        DMLManager.insertAsUser(links);
        system.debug(emailhtmlBody);
        return emailhtmlBody;
        
    }
}
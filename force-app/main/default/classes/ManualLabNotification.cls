public with sharing class ManualLabNotification implements Queueable{
    public static Map<Id,String> accIdToName;
    public static String mySubject;
    public static List<ContentDocumentLink> cdl;
    public static Map<Id,Id> labToAcc = new Map<Id,Id>();
    public static Map<Id,Message_Details__c> accIdToDetails = new Map<Id,Message_Details__c>();
    Map<Id,String> accRecordIds;
    public static Set<Id> contentDocLnkIds;
    public static Map<Id, Blob> labIdToAttchMap;
    
    public ManualLabNotification(Map<Id,String> accRecordIdsToEmail){
        this.accRecordIds = accRecordIdsToEmail;
    }
    
    public void execute(QueueableContext context){

    try {        
    
        accIdToName = new Map<Id,String>();
        List<UA_Sample_Details__c> labOrderLst = [SELECT Id, Account__c, Account__r.Name,  Medical_Test__c 
                               FROM UA_Sample_Details__c 
                               WHERE Is_File_Created__c = true 
                               AND Patient_notified__c = null
                               AND Account__c=:accRecordIds.keySet()
                               WITH SECURITY_ENFORCED 
                               LIMIT 500];

        Set<Id> labIds = new Set<Id>();
        if(labOrderLst!=null && labOrderLst.size()>0){
            labIds = (new Map<Id,UA_Sample_Details__c>(labOrderLst)).keySet();
        }

        Map<Id,Id> labToCdl = new Map<Id,Id>();
        contentDocLnkIds = new Set<Id>();
        cdl = new List<ContentDocumentLink>();
        cdl = [SELECT id, ContentDocumentId, LinkedEntityId
                 FROM ContentDocumentLink 
                 WHERE LinkedEntityId IN: labIds
               	 WITH SECURITY_ENFORCED
                 ORDER BY SystemModstamp ASC
              	 LIMIT 500];
        for(ContentDocumentLink a : cdl){
            if(cdl!=null && cdl.size()>0){
                labToCdl.put(a.LinkedEntityId, a.ContentDocumentId);
                contentDocLnkIds.add(a.ContentDocumentId);
            }
        }

        Map<Id, List<Message_Utility.OrderInfo>> patientIdToLabOrderIds = new Map<Id, List<Message_Utility.OrderInfo>>();
        List<UA_Sample_Details__c> labOrderToUpdate = new List<UA_Sample_Details__c>();
        Map<Id,String> emailhtmlBody;

        for(UA_Sample_Details__c labOrder : labOrderLst){
            labOrder.Patient_notified__c = System.now();
            Id accountId = labOrder.Account__c;
            String accName = labOrder.Account__r.Name;
            if(patientIdToLabOrderIds.containsKey(accountId)){
                Message_Utility.OrderInfo info = new Message_Utility.OrderInfo();
                info.recordId = labOrder.Id;
                info.name = labOrder.Medical_Test__c;
                if(labToCdl.containsKey(labOrder.Id)){
                    info.attachmentId = labToCdl.get(labOrder.Id);
                }
                patientIdToLabOrderIds.get(accountId).add(info);
            }else{
                Message_Utility.OrderInfo info = new Message_Utility.OrderInfo();
                info.recordId = labOrder.Id;
                info.name = labOrder.Medical_Test__c;
                if(labToCdl.containsKey(labOrder.Id)){
                    info.attachmentId = labToCdl.get(labOrder.Id);
                }
                accIdToName.put(accountId, accName);
                patientIdToLabOrderIds.put(accountId, new List<Message_Utility.OrderInfo>{info});
            }
            labOrderToUpdate.add(labOrder);

        }
         emailhtmlBody = createMessage(patientIdToLabOrderIds, contentDocLnkIds);
			Message_Utility.contentVersionAttributes(labIdToAttchMap);
            if(patientIdToLabOrderIds!=null && patientIdToLabOrderIds.size()>0){
                Message_Utility.sendEmail(patientIdToLabOrderIds, accRecordIds, null, mySubject, null, false, emailhtmlBody);
                
            }
            
            DMLManager.updateAsUser(labOrderToUpdate);
        } catch (Exception e) {
            ExceptionLog.logError(e);
        }
    }
    
    public static Map<Id,String> createMessage(Map<Id, List<Message_Utility.OrderInfo>> patientIdToLabOrderIds, Set<Id> cdIds){
        
        Map<Id,String> emailhtmlBody = new Map<Id,String>();
        try{
        labIdToAttchMap = new Map<Id, Blob>();
        fflib_ISObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new List<Schema.SObjectType>{
                Message_Subject__c.sObjectType,
                    Message_Details__c.sObjectType
                    }
        );
        
        Map<Id,ContentVersion> contentVersion = new Map<Id,ContentVersion>();
         Map<Id,Blob> conDocIdToVerData = new Map<Id,Blob>();
        List<ContentVersion> cvList;          
        if(cdIds!=null && cdIds.size()>0){
        cvList = [SELECT Id, Title, FileType,FileExtension, VersionData, ContentDocumentId
                  FROM ContentVersion 
                  WHERE ContentDocumentId IN: cdIds];
        }
        if(cvList!=null && cvList.size()>0){
            contentVersion = new Map<Id,ContentVersion>(cvList);
            for(ContentVersion cv : cvList){
                conDocIdToVerData.put(cv.ContentDocumentId, cv.VersionData);
            }

        }

        Map<String, String> cdlMap = new Map<String, String>();
        if(cdl!=null && cdl.size()>0){
            for(ContentDocumentLink c : cdl){
                cdlMap.put(c.ContentDocumentId, c.LinkedEntityId);
                labIdToAttchMap.put(c.LinkedEntityId, conDocIdToVerData.get(c.ContentDocumentId));
            }
        }
        

        Id userId = UserInfo.getUserId();
        Elixir_Custom_Setting__c portalUrl = [SELECT Elixir_portal_url__c 
                                              FROM Elixir_Custom_Setting__c
                                              WITH SECURITY_ENFORCED];
        
        EmailTemplate emailTemplate = [SELECT Id, Subject, HtmlValue, Body 
                                       FROM EmailTemplate 
                                       WHERE DeveloperName = 'Notification_for_Manual_Lab_result'
                                       WITH SECURITY_ENFORCED];

        String htmlBody = emailTemplate.HtmlValue;
        mySubject = emailTemplate.Subject;
        mySubject = mySubject.replace('{!Organization.Name}', UserInfo.getOrganizationName());
        htmlBody = htmlBody.replace('{!Organization.Name}', UserInfo.getOrganizationName());
        String templateId = emailTemplate.Id;
		
        for(String accountId :patientIdToLabOrderIds.keySet()){
            String newHtmlBody = htmlBody;
            newHtmlBody = newHtmlBody.replace('{!Account.Name}',accIdToName.get(accountId));
            List<String> testNames = new List<String>();
            for(Message_Utility.OrderInfo info :patientIdToLabOrderIds.get(accountId)){
                 testNames.add(info.name);             
                labToAcc.put(info.recordId, accountId);
            }
            String testName = String.join(testNames, ', ');
            newHtmlBody = newHtmlBody.replace('{!ElixirSuite__Lab_Order__c.ElixirSuite__Test_Name__c}' , testName);
            newHtmlBody = newHtmlBody.replace('{link}', '<a href='+ portalUrl.Elixir_portal_url__c+ '>click here</a>');            
            emailhtmlBody.put(accountId,newHtmlBody);
            Message_Subject__c messageSubject = new Message_Subject__c();
            messageSubject.Subject__c = mySubject;
            messageSubject.Account__c = accountId;
            messageSubject.IsPortal__c = false;
            messageSubject.User__c = userId;
            uow.registerNew(messageSubject);
            
            Message_Details__c messageDetail = new Message_Details__c();
            messageDetail.Message_Body__c = emailhtmlBody.get(accountId);
            uow.registerRelationship(messageDetail, Message_Details__c.lookup_Message_Subject__c , messageSubject);
            uow.registerNew(messageDetail);
            accIdToDetails.put(accountId, messageDetail);
        }
        uow.commitWork();


        List<ContentDocumentLink> links = new List<ContentDocumentLink>();
        Map<Id,ContentVersion> versionsMap = new Map<Id,ContentVersion>();
        for(String attch : contentVersion.keySet()){
            ContentVersion attach = ContentVersion.get(attch);
            
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.LinkedEntityId = cdlMap.get(attach.ContentDocumentId);
            cdl.Visibility = 'AllUsers';
            links.add(cdl);
            
            versionsMap.put(cdlMap.get(attach.ContentDocumentId), attach);
        }
		        
        for(ContentDocumentLink link : links){
            String parentId = link.LinkedEntityId;//Lab Id
            String accId = labToAcc.get(parentId);//Account Id
            String messageId = accIdToDetails.get(accId).Id;
            if(versionsMap.containsKey(parentId)){
                String cdId = versionsMap.get(parentId).ContentDocumentId;
                link.ContentDocumentId = cdId;
                
            }
            link.LinkedEntityId = messageId;
        }
        
        DMLManager.insertAsUser(links);
    }
    catch(Exception e){
        ExceptionLog.logError(e);
    }

        return emailhtmlBody;
    }
}
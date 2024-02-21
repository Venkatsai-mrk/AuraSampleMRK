public with sharing class Message_Utility {
    public static Map<Id, Blob> labIdToAttchMap2;
    public static Boolean isFiles = false;
    public static void sendEmail(Map<Id, List<OrderInfo>> payload, Map<Id, String> accountIdsToEmail, String templateId, String mySubject, Set<Id> attachmentIds, Boolean useTemplate, Map<Id,String> emailBody){
        Map<Id,ContentVersion> contentVersion = new Map<Id,ContentVersion>(); 
        if(isFiles){
            Set<Id> conDocIds = new Set<Id>();
            List<ContentDocumentLink> conDocLnk = [Select Id, ContentDocumentId 
                                                   FROM ContentDocumentLink
                                                   WHERE LinkedEntityId IN:labIdToAttchMap2.keySet()];
            for(ContentDocumentLink cdl : conDocLnk){
                conDocIds.add(cdl.ContentDocumentId);
            }
            
            List<ContentVersion> document = [SELECT Id, Title, FileType,FileExtension, VersionData, ContentDocumentId
                                             FROM ContentVersion 
                                             WHERE ContentDocumentId IN:conDocIds];
            
            for(ContentVersion cv : document){
                contentVersion.put(cv.ContentDocumentId, cv);
            }
        }
        
        Map<Id,Attachment> attachments = new Map<Id,Attachment>();
        if(attachmentIds!=null && attachmentIds.size()>0){
            attachments = new Map<Id,Attachment>([Select Id, Name, Body From Attachment where Id IN :attachmentIds]); 
        }
        List<OrgWideEmailAddress> specificOrgWideEmailAddress = [SELECT Id, Address FROM OrgWideEmailAddress LIMIT 1];
        for(String accountId : payload.keySet()){
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            if(specificOrgWideEmailAddress!=null && specificOrgWideEmailAddress.size() >0){
              message.setOrgWideEmailAddressId(specificOrgWideEmailAddress[0].Id);   
            }
            message.setToAddresses(new String[] {accountIdsToEmail.get(accountId)});
            message.setSubject(mySubject);
            if(useTemplate){
                message.setTemplateId(templateId);
            }else{
                message.setHtmlBody(emailBody.get(accountId));
            }
            List<Messaging.EmailFileAttachment> attachmentLst = new List<Messaging.EmailFileAttachment>();
            List<OrderInfo> info = payload.get(accountId);
            if(info!=null && info.size()>0){
                for(OrderInfo  information : info){
                    String recordId='';
                    recordId = information.recordId;
                    String attachmentId = information.attachmentId;
                    if(String.isNotBlank(attachmentId) && attachments.containsKey(attachmentId)){
                        Attachment attch = attachments.get(attachmentId);
                        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                        attachment.setFileName(attch.Name);
                        attachment.setBody(attch.Body);
                        attachmentLst.add(attachment);
                    }
                    if(isFiles && contentVersion.containsKey(attachmentId)){
                        ContentVersion cv = contentVersion.get(attachmentId);
                        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                        attachment.setFileName(cv.Title+'.'+cv.FileExtension);
                        attachment.setBody(cv.VersionData);
                        attachmentLst.add(attachment); 
                    }
                }
            }
            if(attachmentLst!=null && attachmentLst.size()>0){
                message.setFileAttachments(attachmentLst);
            }
            Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
            Messaging.SendEmailResult[] results;
            // Call the sendEmailMessages method 
			 results=sendEmailMessages(messages);
            }
    }
    

    public static Messaging.SendEmailResult[] sendEmailMessages(Messaging.SingleEmailMessage[] messages) {
        return Messaging.sendEmail(messages);
    }

   

    public static void contentVersionAttributes(Map<Id, Blob> labIdToAttchMap){
        labIdToAttchMap2 = labIdToAttchMap;
        if(!labIdToAttchMap2.isEmpty()){
            isFiles = true;
        }
    }
    
    public class OrderInfo{
        public String recordId;
        public String attachmentId;
        public String name;
        public String location;
        public String startTime;
        public String startDate;
        Public String appSubject;
        public Date dueDate;
        public Double amount;
        public String pracName;
        
    }
}
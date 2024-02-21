global virtual with sharing class Messaging_Utility {  
    @deprecated
    global virtual void sendEmail(String mySubject,String myMessage,String patientId, List<String> base64Data, List<String> fileName, Boolean isPHI){
        Account[] acc = [Select id, Email_Id__c from Account where Id =: patientId WITH SECURITY_ENFORCED];
        Elixir_Custom_Setting__c portalUrl = ElixirSuite__Elixir_Custom_Setting__c.getOrgDefaults();
        //Elixir_Custom_Setting__c portalUrl = [Select Elixir_portal_url__c from Elixir_Custom_Setting__c];
        /*List<ImageWrapper> files = (List<ImageWrapper>)JSON.deserialize(fileName , List<ImageWrapper>.class);
        Set<Id> documentIds = new Set<Id>();
        if(files!=null && files.size()>0){
            for(ImageWrapper img :files){
            documentIds.add(img.value);
            }
        }*/
        List<ContentVersion> document = [SELECT Id, Title, FileType,FileExtension, VersionData, ContentDocumentId
         FROM ContentVersion 
         WHERE ContentDocumentId IN: base64Data];
        
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setToAddresses(new String[] {acc[0].Email_Id__c});
        message.setSubject(mySubject);
        if(isPHI){
            message.setHtmlBody('Log In to the Portal to view the complete message <a href='+portalUrl.Elixir_portal_url__c+'>click here.</a>');
        }else{
            message.setHtmlBody(myMessage+'<br>'+'Log In to the Portal <a href='+portalUrl.Elixir_portal_url__c+'>click here.</a>');
            List<Messaging.EmailFileAttachment> attachmentLst = new List<Messaging.EmailFileAttachment>();
            for(ContentVersion cv : document){
                Blob Data = cv.VersionData;
                Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                attachment.setFileName(cv.Title+'.'+cv.FileExtension);
                attachment.setBody(Data);
                attachmentLst.add(attachment);
        }
        message.setFileAttachments(attachmentLst);
        }
        Messaging.SingleEmailMessage[] messages = 
            new List<Messaging.SingleEmailMessage> {message};
                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        if (results[0].success) {
            System.debug('The email was sent successfully.');
        } else {
            System.debug('The email failed to send: '
                         + results[0].errors[0].message);
        }
    }
    global virtual void sendEmail(String mySubject,String myMessage,String patientId, List<String> base64Data, String fileName, Boolean isPHI){
        Account[] acc = [Select id, Email_Id__c from Account where Id =: patientId WITH SECURITY_ENFORCED];
        //Elixir_Custom_Setting__c portalUrl = [Select Elixir_portal_url__c from Elixir_Custom_Setting__c];
        Elixir_Custom_Setting__c portalUrl = ElixirSuite__Elixir_Custom_Setting__c.getOrgDefaults();
        List<ImageWrapper> files = (List<ImageWrapper>)JSON.deserialize(fileName , List<ImageWrapper>.class);
        Set<Id> documentIds = new Set<Id>();
        if(files!=null && files.size()>0){
            for(ImageWrapper img :files){
            documentIds.add(img.value);
            }
        }
        List<ContentVersion> document = [SELECT Id, Title, FileType,FileExtension, VersionData, ContentDocumentId
         FROM ContentVersion 
         WHERE ContentDocumentId IN: documentIds];
        
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setToAddresses(new String[] {acc[0].Email_Id__c});
        message.setSubject(mySubject);
        if(isPHI){
            message.setHtmlBody('Log In to the Portal to view the complete message <a href='+portalUrl.Elixir_portal_url__c+'>click here.</a>');
        }else{
            message.setHtmlBody(myMessage+'<br>'+'Log In to the Portal <a href='+portalUrl.Elixir_portal_url__c+'>click here.</a>');
            List<Messaging.EmailFileAttachment> attachmentLst = new List<Messaging.EmailFileAttachment>();
            for(ContentVersion cv : document){
                Blob Data = cv.VersionData;
                Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                attachment.setFileName(cv.Title+'.'+cv.FileExtension);
                attachment.setBody(Data);
                attachmentLst.add(attachment);
        }
        message.setFileAttachments(attachmentLst);
        }
        Messaging.SingleEmailMessage[] messages = 
            new List<Messaging.SingleEmailMessage> {message};
                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        if (results[0].success) {
            System.debug('The email was sent successfully.');
        } else {
            System.debug('The email failed to send: '
                         + results[0].errors[0].message);
        }
    }
    public class ImageWrapper{
        public String name;
        public String value;
    }
}
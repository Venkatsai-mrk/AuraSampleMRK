public with sharing class NotifyPatients{ 
    
     @future(callout=true)
    public static void sendMakePaymentNotification(String tranId, String ReceivedFrom)
    {
        String patientName = '';
        
        List<Master_Transaction__c> mList; 
        List<Account> accList;        
        
        if(tranId !=null)
            mList=[SELECT Id,Name,Transaction_Date__c,Account__c,Payment_Type__c,Payment_By__c,
                   Total_Amount_Paid__c,CreatedDate
                   FROM Master_Transaction__c WHERE Id =:tranId
                   WITH SECURITY_ENFORCED];
        accList=[SELECT Id, Name,ElixirSuite__Email_Id__c FROM Account WHERE Id= :mList[0].Account__c
        WITH SECURITY_ENFORCED];
        
        if((accList!=null && accList.size()>0) && ReceivedFrom =='Patient'){
            patientName = accList[0].Name;
            PageReference pdf = Page.PrintReceiptPdf; //vf page name;
            pdf.getParameters().put('tranId',tranId);
            
             Blob body;                
                    try{
                        body = pdf.getcontentasPdf();
                    }catch(VisualforceException e){
                        ExceptionLog.logError(e);
                        body=Blob.valueOf('No content in PDF');
                    }
        
            if(String.isBlank(accList[0].ElixirSuite__Email_Id__c)){
                return;
            }
            Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
            
            attach.setContentType('application/pdf');
            attach.setFileName('PrintReceiptPdf.pdf'); 
            attach.Body = body;
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
            String[] sendingTo = new String[]{accList[0].ElixirSuite__Email_Id__c};
                
            mail.setToAddresses(sendingTo);
            mail.setSubject('Invoice Receipt: ' +patientName);
            mail.setPlainTextBody('Dear '+patientName+ ' Please find attached your Invoice Receipt.');
            mail.setFileAttachments(new Messaging.EmailFileAttachment[] { attach });
            
            // emails.add(mail);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
            
        }
        
    }
}
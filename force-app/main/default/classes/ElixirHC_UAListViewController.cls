public with sharing class ElixirHC_UAListViewController {
    
    @AuraEnabled
    public static wrapperForUARecords fetchAllRelatedUrineAnalysisRecordsForAccount(String accountId) {
        List<UA_Sample_Details__c> recordsLstUA = [SELECT CreatedById,CreatedDate,Account__c,Additives_if_Any__c,Collection_Datetime__c,Comments__c,
                                                              ContainerSize__c,ContainerType__c,Container_Description__c,Lab_Code__c,Lab_email__c,
                                                              Lab_Location__c,Lab_Name__c,Notes__c,Order_By__c,Order_to__c,Sample_Type__c
                                                              ,Specimen_Collector__c,Specimen_Condition__c,Specimen_Quantity__c,Id,IsDeleted,LastModifiedDate,
                                                              Name,Analysis_Result__c,Physical_Analysis_Date__c,Laboratory_Analysis_Date__c,OwnerId,Status__c,
                                                              (select id,Examined_Datetime__c,Status__c,LastModifiedDate from Sample_Analysis__r  ORDER BY CreatedDate DESC ),
                                                              (select id,LastModifiedDate from UA_Sample_Details__r ORDER BY CreatedDate DESC limit 1) FROM UA_Sample_Details__c 
                                                              WHERE Account__c= :accountId AND Sample_Type__c='Physical' AND RecordType.Name = 'Urine Analysis'    
                                                              WITH SECURITY_ENFORCED
                                                              ORDER BY CreatedDate DESC];
      /*  List<UA_Sample_Details__c> recordsLstUALab = [SELECT CreatedById,CreatedDate,Account__c,Additives_if_Any__c,Collection_Datetime__c,Comments__c,
                                                              Name,Analysis_Result__c,Physical_Analysis_Date__c,Laboratory_Analysis_Date__c,OwnerId,Status__c,
                                                              (select id,Lab_Sample_Examined_Datetime__c,Status__c from Sample_Analysis__r  ORDER BY CreatedDate DESC ),
                                                              (select id,LastModifiedDate from UA_Sample_Details__r ORDER BY CreatedDate DESC limit 1) FROM UA_Sample_Details__c 
                                                              WHERE Account__c= :accountId AND Sample_Type__c='Laboratory'     
                                                              ORDER BY CreatedDate DESC]; */
        Map<String,DateTime> relatedRecordsForLab = new Map<String,DateTime>();
        List<String> relatedLabAnalysisIDs = new List<String>();
        wrapperForUARecords dataReturn  = new wrapperForUARecords();
        try{
        for(UA_Sample_Details__c rec : recordsLstUA){
            if(rec.UA_Sample_Details__r.size()>0 && rec.UA_Sample_Details__r!=null){
                relatedLabAnalysisIDs.add(rec.UA_Sample_Details__r[0].Id);
            }
        }
        System.debug('related lab analysis ID '+relatedLabAnalysisIDs);
        List<Sample_Analysis__c> labAnalysisRecords = [SELECT id,Examined_Datetime__c,UA_Sample_Details__c,Lab_Sample_Examined_Datetime__c,
                                                                  UA_Sample_Details__r.UA_Sample_Details__r.Id from Sample_Analysis__c 
                                                                  where UA_Sample_Details__c in : relatedLabAnalysisIDs
                                                                  WITH SECURITY_ENFORCED];
        for(Sample_Analysis__c arrangeData : labAnalysisRecords){
            System.debug('parent id '+arrangeData.UA_Sample_Details__c);
            System.debug('datetime '+arrangeData.Examined_Datetime__c);
            relatedRecordsForLab.put(arrangeData.UA_Sample_Details__r.UA_Sample_Details__r.Id,arrangeData.Lab_Sample_Examined_Datetime__c);
            
        }
        System.debug('MAP VALUE '+relatedRecordsForLab);
        //wrapperForUARecords dataReturn  = new wrapperForUARecords();
        dataReturn.toReturnList = recordsLstUA ; 
        dataReturn.nameSpace=Elixir_Utility.getNamespace();
     //   dataReturn.toReturnListLab = recordsLstUALab ;
        dataReturn.toReturnMap = relatedRecordsForLab ; 
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        return dataReturn;
    }
    public class wrapperForUARecords {
        @AuraEnabled public List<UA_Sample_Details__c> toReturnList {get;set;}
        @AuraEnabled public List<UA_Sample_Details__c> toReturnListLab {get;set;}
        @AuraEnabled public  Map<String,DateTime> toReturnMap = new Map<String,DateTime>();
         @AuraEnabled public string nameSpace;
    }
    @AuraEnabled
    public static Boolean deleteRecords(List<String> lstRecordId) {
        Boolean flag = true;
        List<String> finalRecords = new List<String>(); 
        List<UA_Sample_Details__c> filterRecordsNotTodelete = [select id,Status__c 
        from UA_Sample_Details__c where id in : lstRecordId
        WITH SECURITY_ENFORCED];
        for(UA_Sample_Details__c rec : filterRecordsNotTodelete){
            System.debug('rec status '+rec.Status__c);
            if(rec.Status__c=='Open' || String.isEmpty(rec.Status__c)){
                finalRecords.add(rec.Id);
            }
        }
        List<String> oErrorMsg = new List<String> ();
        // Query Records for delete where id in lstRecordId [which is pass from client side controller] 
        List <UA_Sample_Details__c> lstDeleteRec = [select Id from UA_Sample_Details__c 
        where id IN: finalRecords
        WITH SECURITY_ENFORCED];
         Database.DeleteResult[] DR_Dels;
        if (Schema.sObjectType.UA_Sample_Details__c.isDeletable()) {
        DR_Dels = Database.delete(lstDeleteRec, false);
        }
        // Iterate through each returned result
        for (Database.DeleteResult dr: DR_Dels) {
            if (dr.isSuccess()) {
                system.debug('successful delete contact');
                // Operation was successful
            } else {
                flag = false;
                // Operation failed, so get all errors   
                oErrorMsg.add('');
                for (Database.Error err: dr.getErrors()) {
                    // add Error message to oErrorMsg list and return the list
                    oErrorMsg.add(err.getStatusCode() + ': ' + err.getMessage());
                }
            }
        }
        return flag;  
    }
    
    @AuraEnabled
    public static Boolean sendEmailNotificationToUAMember(String toSendEmailFaux,String detailPageRecordID) {
        Boolean emaiNotExistsOrDirtyEmail = false;
        Boolean allowProceed = true;
        List<User> getEmail  = [select id,email from user where id=:toSendEmailFaux WITH SECURITY_ENFORCED];
        String toValidate  = getEmail[0].email;
        if(!String.isEmpty(toValidate)){
            allowProceed = ElixirHC_UAListViewController.validateEmail(toValidate); 
        }
        else {
            emaiNotExistsOrDirtyEmail = true; 
        }
        if(allowProceed){
            String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
            //String orgWideValid  = Elixir_utility.getNamespace();  kishan comments not needed right now
            System.debug('base url '+baseUrl);
            String orgWideValid  = '';
            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();   
            for(User forEmail :  getEmail) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();                        
                mail.setSaveAsActivity(false);
                // mail.setTemplateId(theTemplate);
                // mail.setWhatId(poId);
                mail.setSenderDisplayName('Salesforce ELIXIR Support');
                mail.setSubject('UA CREATED!');                       
                mail.setPlainTextBody('UA has been created.');
                mail.setHtmlBody('UA has been created.'+ 
                                 'To view  <a href='+baseUrl+'/lightning/r/'+orgWideValid+'Create_Sample/'+detailPageRecordID+'/view>Click here.</a>');                     
                mail.setTargetObjectId(forEmail.Id);
                mail.setToAddresses(new String[] {forEmail.Email});  //add other emails here.
                emails.add(mail); 
            }
            Messaging.sendEmail(emails); 
        }
        else {
            emaiNotExistsOrDirtyEmail= !allowProceed;
        }
        // ElixirHC_UAListViewController.sendPDf(detailPageRecordID,'tanveer.ahmed@mirketa.com');
        return emaiNotExistsOrDirtyEmail; 
        
    }
    @AuraEnabled
    public static Boolean validateEmail(String email) {
        Boolean res = true;
        String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$'; 
        Pattern MyPattern = Pattern.compile(emailRegex);
        Matcher MyMatcher = MyPattern.matcher(email);
        if (!MyMatcher.matches()) 
            res = false;
        return res;	
    }
    @AuraEnabled
    public static void sendPdfForUA(String pdfName,String record,String patientId,String forpdf){
         System.debug('pdf name '+pdfName);
          System.debug('pART 2 '+pdfName);
        String patientName = '';
        List<Account> forPatientName = [select id,name from Account where id  = : patientId WITH SECURITY_ENFORCED];
        if(forPatientName.size()>0 && forPatientName!=null){
            patientName = forPatientName[0].Name;
        }
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        PageReference pdf ;
        if(pdfName=='PhysicalAnalysis'){
            pdf = Page.ElixirHC_PhysicalAnalysisPDFGenerator; 
            System.debug('for pdf data '+forpdf);
        pdf.getParameters().put('orderId',forpdf);
        }
        if(pdfName=='LabSampleAnalysis'){
            System.debug('INSIDE LAB ANLYSIS');
            pdf = Page.ElixirHC_LabAnalysisPDFGenerator;
            pdf.getParameters().put('orderId',forpdf);
        }
       
        // goToNextPage('email');
        Blob body;                
        try{
            body = pdf.getContent();
        }catch(VisualforceException e){
            body=Blob.valueOf('Some text');
        }
        Boolean emaiNotExistsOrDirtyEmail = false;
        Boolean allowProceed = true;
        List<String> allEmailAdd = new List<String>();
       // List<User> getAllUsers  = [select Id,Username,Email,profile.name,UserRole.Name,UserRole.id from user where profile.name='System Administrator' or UserRole.Name='Doctor' or UserRole.Name='Nurse'];
        List<User> getAllUsers  = [select Id,Username,Email,profile.name,UserRole.Name,UserRole.id from user where Id=: UserInfo.getUserId()
        WITH SECURITY_ENFORCED];
        for(User forEmail : getAllUsers) {
           
            System.debug('email forRepeaat '+forEmail.Email);
            if(ElixirHC_UAListViewController.validateEmail(forEmail.Email)){
                 allEmailAdd.add(forEmail.Email);
            }
           
            
        }
        Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
                attach.setContentType('application/pdf');
                attach.setFileName(pdfName+' REPORT || '+patientName +'.pdf'); 
                attach.setInline(false);
                attach.Body = body;
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setTargetObjectId( UserInfo.getUserId() );
                mail.setSaveAsActivity( false );
                mail.setUseSignature(false);
                mail.setToAddresses(allEmailAdd);
                System.debug('buffer array '+mail);
                mail.setSubject(pdfName+'REPORT');
                mail.setHtmlBody('Analysis is complete for patient '+patientName+'! Please find out the attached pdf for the results.');
                mail.setFileAttachments(new Messaging.EmailFileAttachment[] { attach }); 
        		emails.add(mail);
         		Messaging.sendEmail(emails);
       //  Messaging.sendEmail(emails);
        
    }
    
    @AuraEnabled
    public static boolean checkCareEpisode(string patientId){      
        
         //added by Anmol for LX3-7236
         Boolean result = Elixir_Utility.checkCareEpisodeUtility(patientId);
         return result;
         //end by Anmol for LX3-7236
       
    }
    
    /*  public PageReference sendPdf(){                
PageReference pdf = Page.ElixirHC_PhysicalAnalysisPDFGenerator;//mail_pdf is the name of vf page
pdf.getParameters().put('orderId','a1gN0000001pPfhIAE');
// goToNextPage('email');
Blob body;                
try{
body = pdf.getContent();
}catch(VisualforceException e){
body=Blob.valueOf('Some text');
}            
Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
attach.setContentType('application/pdf');
attach.setFileName('testPdf.pdf');
attach.setInline(false);
attach.Body = body;
Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
mail.setUseSignature(false);
mail.setToAddresses(new String[] { 'tanveer.ahmed@mirketa.com' });
mail.setSubject('PDF Email Demo');
mail.setHtmlBody('Here is the email you requested! Check the attachment!');
mail.setFileAttachments(new Messaging.EmailFileAttachment[] { attach }); 
// Send the email    
Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
// ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Email with PDF sent to '+email));
return null;
}
*/
    
}
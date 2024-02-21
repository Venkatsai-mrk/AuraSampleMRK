public with sharing class activeMedicationApex {
    public static list<ElixirSuite__Prescription_Order__c> listOfMedication {get; set;}
    public static Integer totalRecords=0;

   /* @AuraEnabled
    public static String medicationHistory(Id userId){
        String jsonDT = '';
        //Id accId = [SELECT Id, AccountId FROM User WHERE Id =: userId].AccountId;
        Id accId;
        list<user> u = [SELECT Id, AccountId FROM User WHERE Id =: userId WITH SECURITY_ENFORCED];
        if(u != null && !u.isEmpty()){
            accId = u[0].AccountId;
        }
         
        totalRecords = [SELECT count() FROM ElixirSuite__Prescription_Order__c WHERE ElixirSuite__Account__c =: accId WITH SECURITY_ENFORCED];
        ActiveMedicationWrapper objLi = new ActiveMedicationWrapper();
        objLi.totalRecords = totalRecords;

        objLi.objPO= [Select id,Name,ElixirSuite__Drug_Name__c, ElixirSuite__Dosage__c,ElixirSuite__Ferquency__c,ElixirSuite__Patient_SIG__c
        from ElixirSuite__Prescription_Order__c 
        where ElixirSuite__Archive_Status_NC__c IN ('N','') 
        AND ElixirSuite__Drug_Name__c!= Null 
        AND ElixirSuite__Account__c =: accId WITH SECURITY_ENFORCED ORDER BY CreatedDate Asc];
        
        jsonDT = JSON.serialize(objLi);
        return jsonDT;
        
        /*listOfMedication= [Select id,Name,ElixirSuite__Drug_Name__c, ElixirSuite__Dosage__c,ElixirSuite__Ferquency__c,ElixirSuite__Patient_SIG__c
        from ElixirSuite__Prescription_Order__c 
        where ElixirSuite__Archive_Status_NC__c IN ('N','') 
        AND ElixirSuite__Drug_Name__c!= Null 
        AND ElixirSuite__Account__c =: accId WITH SECURITY_ENFORCED];

        //return listOfMedication;
    }*/

    Public class DisplayMailStatus
    {
        public String status {get;set;}
        public list<ElixirSuite__Prescription_Order__c> objPO{get;set;}            
    }

     @AuraEnabled()
     public static String sendEmailMethod(Id userId , Id prescriptionId){
        String jsonDT = '';
        list<User> u  = [SELECT Id,Name, AccountId,ContactId FROM User WHERE Id =: userId WITH SECURITY_ENFORCED];
        list<Id> ids = new list<Id>();
   
        list<ElixirSuite__Prescription_Order__c> TcList = [Select id,Name,ElixirSuite__Account__c,ElixirSuite__Drug_Name__c, ElixirSuite__Dosage__c,ElixirSuite__Ferquency__c,ElixirSuite__Patient_SIG__c
                                                            from ElixirSuite__Prescription_Order__c where Id =: prescriptionId WITH SECURITY_ENFORCED];                                               
            
        
        list<Messaging.sendEmailResult> sendEmailResults = new list<Messaging.sendEmailResult>();
        List<Messaging.SingleEmailMessage> emailList1 = new List<Messaging.SingleEmailMessage>();
        EmailTemplate emailTemplate = [select Id, Subject, HtmlValue, Body from EmailTemplate where Id =: CreateFormForPortal.fetchEmailTemplateId('Email_Template_for_Refill_Request')];
        String htmlBody = emailTemplate.HtmlValue;
        htmlBody = htmlBody.replace('{!User.Name}', u[0].Name);
        htmlBody = htmlBody.replace('{!DrugName}', TcList[0].ElixirSuite__Drug_Name__c);
        String subject = emailTemplate.Subject;
        subject = subject.replace('{!User.Name}', u[0].Name);
        String plainBody = emailTemplate.Body;
         List<OrgWideEmailAddress> lstEmailAddress=[select Id,Address,DisplayName from OrgWideEmailAddress WHERE DisplayName = 'Elixir Patient Portal'];
           //Messaging.reserveSingleEmailCapacity(1);
           Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
           mail.setTargetObjectId(UserInfo.getUserId()); 
           mail.setSaveAsActivity(false);
                //mail.setToAddresses(PortalEmailRecipientsUtility.fetchPatientPortalMedicationRecipients());
            List<String> mailIdSet = new List<String>();
            Set<String> allMailNames = PortalEmailRecipientsUtility.fetchPatientPortalMedicationRecipients();
            for(String s : allMailNames) {
            mailIdSet.add(s);
            }
           mail.setToAddresses(mailIdSet);
           mail.setTreatTargetObjectAsRecipient(false);
           mail.setSubject(subject);
           mail.setHtmlBody(htmlBody);
           mail.setPlainTextBody(plainBody);
           if(lstEmailAddress != null && !lstEmailAddress.isEmpty()){
           mail.setOrgWideEmailAddressId(lstEmailAddress[0].Id);
            }
                emailList1.add(mail);
            if(!emailList1.isEmpty()){
                sendEmailResults = Messaging.sendEmail(emailList1);

                    //Do something for success
                    DisplayMailStatus dms = new DisplayMailStatus();
                    dms.status = 'sent';
                    if(!test.isRunningTest()){
                    dms.objPO = [SELECT Id,Name,ElixirSuite__Account__c,ElixirSuite__Drug_Name__c, ElixirSuite__Dosage__c,ElixirSuite__Ferquency__c,ElixirSuite__Patient_SIG__c
                    from ElixirSuite__Prescription_Order__c WHERE Id =: prescriptionId WITH SECURITY_ENFORCED];
                    }
                    jsonDT = JSON.serialize(dms);
                }
    return jsonDT;
} 

}
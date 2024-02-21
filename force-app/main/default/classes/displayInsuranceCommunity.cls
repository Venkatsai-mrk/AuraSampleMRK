public with sharing class displayInsuranceCommunity {
    public static list<ElixirSuite__VOB__c> lstInsurance {get; set;}
    public static Integer totalRecords=0;

    /*@AuraEnabled
    public static String fetchInsurance(Id userId){
        String jsonDT = '';

        list<User> u  = [SELECT Id, AccountId FROM User WHERE Id =: userId];
        if(u != null && !u.isEmpty()){
            totalRecords = [SELECT count() FROM ElixirSuite__VOB__c WHERE ElixirSuite__Account__c =: u[0].AccountId WITH SECURITY_ENFORCED];
            DisplayInsuranceWrap objLi = new DisplayInsuranceWrap();
            objLi.totalRecords = totalRecords;
            objLi.objVOB = [SELECT Id,Name,ElixirSuite__Subscriber_Name__c,ElixirSuite__Insurance_Provider_Sec__c,ElixirSuite__Insurance_Type_Sec__c,ElixirSuite__Insurance_Group_Number__c FROM ElixirSuite__VOB__c WHERE ElixirSuite__Account__c =: u[0].AccountId WITH SECURITY_ENFORCED ORDER BY CreatedDate Asc];
            //lstInsurance = [SELECT Id,Name,ElixirSuite__Subscriber_Name__c,ElixirSuite__Insurance_Provider_Sec__c,ElixirSuite__Insurance_Type_Sec__c,ElixirSuite__Insurance_Group_Number__c FROM ElixirSuite__VOB__c WHERE ElixirSuite__Account__c =: accId WITH SECURITY_ENFORCED];
            jsonDT = JSON.serialize(objLi);
        }

        return jsonDT;
    }

    Public class DisplayInsuranceWrap
    {
        public Integer totalRecords {get;set;}
        public list<ElixirSuite__VOB__c> objVOB{get;set;}            
    }*/

    Public class DisplayMailStatus
    {
        public String status {get;set;}
        public String OrganizationName{get;set;}            
    }

    @AuraEnabled
    public static String sendmail(Id userId){
        String jsonDT = '';
        //list<ElixirSuite__VOB__c> = [SELECT Id,Name,ElixirSuite__Subscriber_Name__c,ElixirSuite__Insurance_Provider_Sec__c,ElixirSuite__Insurance_Type_Sec__c,ElixirSuite__Insurance_Group_Number__c FROM ElixirSuite__VOB__c WHERE Id =: recordId WITH SECURITY_ENFORCED];
        list<User> u  = [SELECT Id, AccountId,ContactId FROM User WHERE Id =: userId WITH SECURITY_ENFORCED];
        list<Id> ids = new list<Id>();
        Set<String> sendTo = new Set<String>();
        list<Messaging.sendEmailResult> sendEmailResults = new list<Messaging.sendEmailResult>();
        //List<Messaging.MassEmailMessage> emailList = new List<Messaging.MassEmailMessage>();
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        list<EmailTemplate> emailTemp = [Select Id, Subject, Body From EmailTemplate Where name like '%Request_Update_For_Insurance%' WITH SECURITY_ENFORCED];
        system.debug('email template' + emailTemp);
        If(emailTemp != null && !emailTemp.isEmpty()){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            if(!test.isRunningTest()){
                sendTo = PortalEmailRecipientsUtility.fetchPatientPortalInsuranceRecipients();
            }
            else{
                sendTo.add('fakeemail@gmail.com');
            }
            List<String> sendToEmail = new List<String>();
            for(String obj : sendTo){
                sendToEmail.add(obj);
            }
            mail.setToAddresses(sendToEmail);
            List<OrgWideEmailAddress> lstEmailAddress=[select Id,Address,DisplayName from OrgWideEmailAddress WHERE DisplayName = 'Elixir Patient Portal'];
            Messaging.reserveSingleEmailCapacity(sendToEmail.size());
            mail.setTemplateId(emailTemp[0].Id);
            if(lstEmailAddress != null && !lstEmailAddress.isEmpty()){
            mail.setOrgWideEmailAddressId(lstEmailAddress[0].Id);
            }
            if(u != null && !u.isEmpty()){
                mail.setTargetObjectId(u[0].ContactId);
            }
            mail.setTreatTargetObjectAsRecipient(false);       
            emailList.add(mail);
            if(emailList != null && !emailList.isEmpty()){
                sendEmailResults = Messaging.sendEmail(emailList);
                system.debug('sendEmailResults'+sendEmailResults);
                for (Messaging.SendEmailResult mr : sendEmailResults) 
                {
                if (mr.isSuccess()) {
                    //Do something for success
                    DisplayMailStatus dms = new DisplayMailStatus();
                    dms.status = 'sent';
                    dms.OrganizationName = userinfo.getOrganizationName();
                    //dms.objVOB = [SELECT Id,Name,ElixirSuite__Insurance_Provider_Sec__c FROM ElixirSuite__VOB__c WHERE Id =: recordId WITH SECURITY_ENFORCED];
                    //lstInsurance = [SELECT Id,Name,ElixirSuite__Subscriber_Name__c,ElixirSuite__Insurance_Provider_Sec__c,ElixirSuite__Insurance_Type_Sec__c,ElixirSuite__Insurance_Group_Number__c FROM ElixirSuite__VOB__c WHERE ElixirSuite__Account__c =: accId WITH SECURITY_ENFORCED];
                    jsonDT = JSON.serialize(dms);
                }  else {
                    // Operation failed, so get all errors                
                    for(Messaging.SendEmailError err : mr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('fields that affected this error: ' + err.getFields());
                        DisplayMailStatus dms = new DisplayMailStatus();
                        dms.status = err.getMessage();
                        dms.OrganizationName = null;
                        jsonDT = JSON.serialize(dms);
                    }
                }
                }
                
            }
        }
        
        return jsonDT;
        //return sendEmailResults;
        /*Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {'singhvishalkumar0610@gmail.com'};
        mail.setToAddresses(toAddresses);
        mail.setSaveAsActivity(false);
        //List of ccAddress
        //String[] ccAddresses = new String[] {'singhvishalkumar0610@gmail.com'};
        // Assign the CC addresses
        //mail.setCcAddresses(ccAddresses);
 
        // Here we can set the address that will be used when a recipient replies to the email
        //mail.setReplyTo('fakeReplyToEmail301@acme.com');

        mail.setSenderDisplayName('Display name for email');
 
        mail.setSubject('Email Subject');
 
        // You can set this to true if you want to BCC yourself on the email
        mail.setBccSender(false);
 
        mail.setPlainTextBody('Sample plain text goes here');
 
        //Specify any html - for example this will display a link in the email
        mail.setHtmlBody('Your Link <a href=https://www.salesforce.com/>click here.</a>');
        mail.SetTargetObjectId(userinfo.getuserid());
        // Send the email
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });*/
    }

}
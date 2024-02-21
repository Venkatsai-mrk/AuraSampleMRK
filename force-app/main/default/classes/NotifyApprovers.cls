public with sharing class NotifyApprovers { 
    @future
    public static void sendNotification(String recordTypeName, String changedFormName, String patientId,
                                    Integer currentLevel) {
    List<Object_1_css__c> defaultApprovalLevels = [SELECT Id, Approval_Level__c, Approv__c, Approval_Members__c
                                            FROM  Object_1_css__c 
                                            WHERE Form__c= :recordTypeName AND Approval_Level__c =: currentLevel+1
                                            WITH SECURITY_ENFORCED];
        if(defaultApprovalLevels!=null && defaultApprovalLevels.size()>0){
            Elixir_Custom_Setting__c mc = Elixir_Custom_Setting__c.getOrgDefaults();
            Boolean enableApprover = mc.Enable_email_for_Approvers__c;
            Boolean enableTaskForApprovers = mc.Enable_Tasks_for_approvers__c ; 
            String allMembersText = defaultApprovalLevels[0].Approval_Members__c;
            List<String> allMembers = allMembersText.split(';');
            String approvalType = defaultApprovalLevels[0].Approv__c;
            switch on approvalType {
                when 'User' {	
                    Set<String> ids = new Set<String>(allMembers);
                    if(enableTaskForApprovers){
                    triggerTask('User', ids, changedFormName, patientId);
                    }
                    if(enableApprover){
                        triggerEmail('User', ids, changedFormName, patientId);
                    }
                }	
                when 'Profile' {
                    List<User> users = [SELECT Id FROM User WHERE ProfileId IN :allMembers WITH SECURITY_ENFORCED];
                    if(users!=null && users.size()>0){
                        Set<Id> ids = (new Map<Id,User>(users)).keySet();
                        Set<String> idStrs = (Set<String>)JSON.deserialize(JSON.serialize(ids), Set<String>.class);
                        if(enableTaskForApprovers){
                        triggerTask('Profile', idStrs, changedFormName, patientId);
                        }
                        if(enableApprover){
                            triggerEmail('Profile', idStrs, changedFormName, patientId);
                        }
                    }
                }
                when 'Role'{
                    List<User> users = [SELECT Id FROM User WHERE UserRoleId IN :allMembers WITH SECURITY_ENFORCED];
                    if(users!=null && users.size()>0){
                        Set<Id> ids = (new Map<Id,User>(users)).keySet();
                        Set<String> idStrs = (Set<String>)JSON.deserialize(JSON.serialize(ids), Set<String>.class);
                        if(enableTaskForApprovers){
                        triggerTask('Role', idStrs, changedFormName, patientId);
                        }
                        if(enableApprover){
                            triggerEmail('Role', idStrs, changedFormName, patientId);
                        }
                    }
                }
                when 'Patient' {	
                    if(enableTaskForApprovers){
                    triggerTask('Patient', new Set<String>{patientId}, changedFormName, patientId);
                    }
                    if(enableApprover){
                        triggerEmail('Patient', new Set<String>{patientId}, changedFormName, patientId);
                    }
                }
            }
        }
    }
    private static void triggerTask(String type, Set<String> ids, String formName, String patientId){
        String patientName = [SELECT Id, Name FROM Account WHERE Id= :patientId WITH SECURITY_ENFORCED LIMIT 1].Name;
        List<Task> taskToInsert = new List<Task>();
        for(String id :ids){
            Task newTask = new Task ();
            newTask.Status = 'Not Started';
            newTask.Subject = 'Approval Pending for ' + formName;
            newTask.Description = 'The approval for ' + formName + ' form for ' + patientName + ' is pending.'
                                 +'Please do the needful';
            newTask.WhatId = patientId;
            newTask.OwnerId = Id;
            taskToInsert.add(newTask);
        }
        if(Schema.sObjectType.Task.isCreateable() &&
        Schema.sObjectType.Task.fields.WhatId.isCreateable() &&
        Schema.sObjectType.Task.fields.WhoId.isCreateable() &&
        Schema.sObjectType.Task.fields.Subject.isCreateable() &&
        Schema.sObjectType.Task.fields.Description.isCreateable() &&
        Schema.sObjectType.Task.fields.OwnerId.isCreateable()){
            Database.insert(taskToInsert,false);
        }
    }
   private static void triggerEmail(String type, Set<String> ids, String formName, String patientId) {
    Account patient = [SELECT Id, Email_Id__c, Name FROM Account WHERE Id = :patientId WITH SECURITY_ENFORCED LIMIT 1];
    String patientName = patient.Name;
    String patientEmail = patient.Email_Id__c;

  
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    EmailTemplate emailTemplate = [SELECT Id,DeveloperName,HtmlValue,subject FROM EmailTemplate where DeveloperName ='Email_Template_Pending_Form_Approvals' Limit 1];
       
        String htmlBody = emailTemplate.HtmlValue;
        htmlBody = htmlBody.replace('{!ElixirSuite__Form_Value__c.ElixirSuite__Form_Name__c}',formName);
        htmlBody = htmlBody.replace('{!Account.Name}', patientName );
        String subject = emailTemplate.Subject;
        subject = subject.replace('{!ElixirSuite__Form_Value__c.ElixirSuite__Form_Name__c}', formName);
        //mail.setTemplateId(emailTemplate.Id);       
        mail.setSubject(subject);
        mail.setHtmlBody(htmlBody);
        mail.setTargetObjectId(UserInfo.getUserId()); 
        //mail.setWhatId(patientId);
        mail.setSaveAsActivity(false);
    
    if(type.equalsIgnoreCase('PATIENT')){ 
            if(String.isNotBlank(patientEmail)){
                mail.setToAddresses(new List<String>{patientEmail});
            }
        }else{
            List<User> users = [SELECT Id, Email FROM User WHERE Id IN :ids AND Email!=NULL AND IsActive=TRUE WITH SECURITY_ENFORCED];
            List<String> emails = new List<String>();
           // emails.add('shivank.singh@mirketa.com');
            if(users!=null && users.size()>0){
                for(User mailId :users){
                system.debug(mailId);
                String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';
                Pattern MyPattern = Pattern.compile(emailRegex);
                Matcher MyMatcher = MyPattern.matcher(mailId.Email);
                    if (MyMatcher.matches()) {
                        emails.add(mailId.Email);
                        system.debug(mailId.Email);
                    }
                } 
            }
            if(emails.size()>0){
                mail.setToAddresses(emails);
            }
        }
    Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
}



}
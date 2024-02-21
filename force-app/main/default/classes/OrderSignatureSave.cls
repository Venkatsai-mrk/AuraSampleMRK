public with sharing class OrderSignatureSave {
    @AuraEnabled //String formName, String changedFormName, String formId,
    public static SignAndAprroveData approveOrder(String userValues, String currentLevel, String code, String comments){
        try {
            
            SignAndAprroveData currentData = new SignAndAprroveData();
            currentData.dateOfApproval = System.now();
            currentData.comments = comments;

            UserValues userDetails = (UserValues) 
                                        JSON.deserializeStrict(userValues, UserValues.class);
            String userId = userDetails.userId;
            List<User> users = [SELECT Id, Name, userrole.name, Signature_Attachment_Id__c, Verification_Code__c, Verification_Code_New__c
                                FROM User 
                                WHERE Id= :userId WITH SECURITY_ENFORCED];
            String patientId = userDetails.patientId;
            List<Account> patients = [SELECT Id, Name, Signature_Attachment_Id__c, Verification_Code__c FROM Account 
                                WHERE Id= :patientId WITH SECURITY_ENFORCED ];

            ElixirSuite__Master_Object__c defaultApprovalLevels = (ElixirSuite__Master_Object__c)
                                        JSON.deserializeStrict(currentLevel, ElixirSuite__Master_Object__c.class);
            String approvalType = defaultApprovalLevels.ElixirSuite__Approver__c;
            String allApproversText = defaultApprovalLevels.Approval_Members__c;
            Decimal approvalLevel = defaultApprovalLevels.Approval_Level__c;

            currentData.approvalLevel = Integer.valueOf(approvalLevel);
            currentData.customLabel = defaultApprovalLevels.Approver_Custom_Label__c;

            List<String> allApprovers = allApproversText.split(';');
            
            //ElixirSuite__Prescription_Order__c approvalValue = new ElixirSuite__Prescription_Order__c();
            String signature;

            switch on approvalType {
                when 'User','Profile','Role' {  
                    //approvalValue.User__c = userId;
                    String verificationCode = users[0].Verification_Code_New__c;
                    checkValidity(code, verificationCode );
                    signature = users[0].Signature_Attachment_Id__c;
                    currentData.userName = users[0].Name;
                    currentData.userRole = users[0].userrole.name;
                    currentData.userId = users[0].Id;
                }   
                when 'Patient' {        
                    //approvalValue.Signed_Patient__c = patientId;
                    String verificationCode = patients[0].Verification_Code__c;
                    checkValidity(code, verificationCode);
                    signature = patients[0].Signature_Attachment_Id__c;
                    currentData.patientName = patients[0].Name;
                    currentData.userId = users[0].Id;
                }
            }
            if(!Test.isRunningTest() && String.isBlank(signature)){
                AuraHandledException e = new AuraHandledException('Please Register Signature First!');
                e.setMessage('Please Register Signature First!');
                throw e;
            }
            List<sObject> images;
            system.debug('signature is'+signature);
            if(approvaltype.equalsIgnoreCase('Patient')){
                images = [SELECT Id FROM Attachment WHERE Id= :signature WITH SECURITY_ENFORCED];
                if (images != null && images.size() > 0) {
                    currentData.signatureAttachmentId = images[0].Id;
                }
            }else{
                images = [SELECT Id FROM ContentDocument WHERE Id= :signature WITH SECURITY_ENFORCED];
                if (images != null && images.size() > 0) {
                    currentData.signatureContentDocumentId = images[0].Id;
                }
            }
            if(!Test.isRunningTest() &&(images==null || images.size()==0)){
                AuraHandledException e = new AuraHandledException('Please Register Signature First!');
                e.setMessage('Please Register Signature First!');
                throw e;
            }

            //approvalValue.Account__c = patientId;
            //approvalValue.Form_Id__c = formId;
            //approvalValue.Form_Name__c = changedFormName;
            //approvalValue.Approval_Level__c =  String.valueof(Integer.valueOf(approvalLevel));
            //approvalValue.Comment__c = comments;
            //approvalValue.Approved_Signature__c = signature;
            //approvalValue.Date_Of_Approval__c = System.now();
            //approvalValue.Is_Approver__c = true; 
            //system.debug(approvalValue);
            // if(Schema.sObjectType.Form_Value__c.isCreateable() &&
            // Schema.sObjectType.Form_Value__c.fields.Account__c.isCreateable() &&
            // Schema.sObjectType.Form_Value__c.fields.Form_Name__c.isCreateable() &&
            // Schema.sObjectType.Form_Value__c.fields.Approval_Level__c.isCreateable() &&
            // Schema.sObjectType.Form_Value__c.fields.Form_Id__c.isCreateable() &&
            // Schema.sObjectType.Form_Value__c.fields.Comment__c.isCreateable() &&
            // Schema.sObjectType.Form_Value__c.fields.Approved_Signature__c.isCreateable() &&
            // Schema.sObjectType.Form_Value__c.fields.Is_Approver__c.isCreateable() &&
            // Schema.sObjectType.Form_Value__c.fields.Signed_Patient__c.isCreateable()){
            //     system.debug(approvalValue);
            //     insert approvalValue;
            // }
            //NotifyApprovers.sendNotification(formName, changedformName, patientId,
            //                            Integer.valueOf(approvalLevel));// Notify Approvers
            //String formStatus  = changeStatus(formId, formName);
            //system.debug('beforeDetails');
            // List<Form_Value__c> formDetails = [SELECT Id, Status__c FROM Form_Value__c 
            //                                 WHERE Form_Id__c= :formId AND Form_Detail__c=true 
            //                                 WITH SECURITY_ENFORCED ];
            // system.debug('afterDetails');
            // if(formDetails!=null && formDetails.size()>0){
            //     formDetails[0].Status__c = formStatus;
            // }else{
            //     Form_Value__c formDetail = new Form_Value__c(
            //         Status__c = formStatus,
            //         Form_Id__c = formId,
            //         Account__c = patientId,
            //         Form_Detail__c = true,
            //         Form_Name__c = changedFormName);
            //     formDetails.add(formDetail);
            // }
            
            // if(Schema.sObjectType.Form_Value__c.isUpdateable() &&
            // Schema.sObjectType.Form_Value__c.fields.Account__c.isUpdateable() &&
            // Schema.sObjectType.Form_Value__c.fields.Form_Name__c.isUpdateable() &&
            // Schema.sObjectType.Form_Value__c.fields.Form_Id__c.isUpdateable() &&
            // Schema.sObjectType.Form_Value__c.fields.Form_Detail__c.isUpdateable() &&
            // Schema.sObjectType.Form_Value__c.fields.Status__c.isUpdateable()){
            //     upsert formDetails;
            // }

            return currentData;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    private static void checkValidity(String code, String verificationCode){
        if(code != verificationCode){
            AuraHandledException e = new AuraHandledException('Verification Failed!');
                e.setMessage('Verification Failed!');
                throw e;
        }
    }
    private static String changeStatus(String formId, String recordTypeName){
        List<Object_1_css__c> defaultApprovalLevels = new List<Object_1_css__c>();
        List<Form_Value__c> approvedValues = new List<Form_Value__c>();
        defaultApprovalLevels = [SELECT Id, Approval_Level__c, Approv__c, Approval_Members__c FROM 
                        Object_1_css__c WHERE Form__c= :recordTypeName AND Approval_Level__c!=NULL
                        WITH SECURITY_ENFORCED
                        ORDER BY Approval_Level__c ];
        approvedValues = [SELECT Id, Account__c, Is_Approver__c, Date_Of_Approval__c,
                        User__r.Name, Approval_Level__c, Comment__c, Form_Name__c, Approved_Signature__c,
                        Signed_Patient__r.Name FROM Form_Value__c
                        WHERE Is_Approver__c=true AND Form_Id__c= :formId and Is_old__c != true
                        WITH SECURITY_ENFORCED
                        ORDER BY Approval_Level__c];
        Integer defaultLevels = defaultApprovalLevels.size();
        Integer approvedLevels = approvedValues.size();
        if(defaultLevels>0){
            return adminConfiguredLevels(defaultLevels, approvedLevels);
        }else{
            return 'Open';
        }
    }
    //C
    private static String adminConfiguredLevels(Integer defaultLevels, Integer approvedLevels){
        if(approvedLevels>0){
            return checkApprovedValues(defaultLevels, approvedLevels);
        }else{
            return 'Open';
        }
    }
    private static String checkApprovedValues(Integer defaultLevels, Integer approvedLevels){
        if(defaultLevels == approvedLevels){
            return 'Completed';
        }else{
            return 'In Progress';
        }
    }
    public class UserValues{
        public String userId;
        public String patientId;
        public String profileId;
        public String roleId;
    }
    
    
    @AuraEnabled
    public static List<Form_Value__c> getStatus(String formId){
          List<Form_Value__c> status = [Select Id, ElixirSuite__Status__c 
                                  from ElixirSuite__Form_Value__c 
                                 where ElixirSuite__Form_Id__c =:formId and ElixirSuite__Form_Detail__c = true WITH SECURITY_ENFORCED];
          
          return status;
    }     
    
    //To display insert signature img for portal users - Srihari
    @AuraEnabled
    public static String getPortalFlag(String accId,String formId){
        String status='';
        string query = 'select id,AccountId__c,Is_Patient_Portal_Form__c from Object_2__c where AccountId__c =:accId AND Form_unique_id__c=:formId';
        
        List<sObject> portalStatus = Database.query(query);
        
        for(sObject obj :portalStatus){
            status=String.valueOf(obj.get('Is_Patient_Portal_Form__c'));
        }
        
        return status;
    }    

    //  approvedLevel.ElixirSuite__Date_Of_Approval__c
    //   approvedLevel.ElixirSuite__User__r.Name
    //   approvedLevel.ElixirSuite__User__r.UserRole.Name

    //   approvedLevel.ElixirSuite__Approved_Signature__c
    //   approvedLevel.ElixirSuite__Signed_Patient__r.Name

    
    public class SignAndAprroveData {
       @AuraEnabled public Datetime dateOfApproval;
       @AuraEnabled public Integer approvalLevel;
       @AuraEnabled public String userName;
       @AuraEnabled public String userRole;
       @AuraEnabled public String signatureAttachmentId;
       @AuraEnabled public String signatureContentDocumentId;
       @AuraEnabled public String patientName;
       @AuraEnabled public String customLabel;
       @AuraEnabled public String comments;
       @AuraEnabled public String userId;
    }

    @AuraEnabled
    public static void attachApprovalDataToParentPrescriptionEditMode(String parentPrescriptionId, String approvedValues){
        try {
            SelectionMedicationRecordsApexController.attachApprovalDataToParentPrescription(parentPrescriptionId, approvedValues);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void attachApprovalDataToLabOrderEditMode(String labOrderId, String approvedValues){
        try {
            LabOrderController.attachApprovalDataToLabOrder(labOrderId, approvedValues);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    
}
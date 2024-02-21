public with sharing class CareplanSignatureSaveApex {
    @AuraEnabled //String formName, String changedFormName, String formId,
    public static SignAndAprroveData approveOrder(String userValues, String currentLevel, String code, String comments){
        
        try {
            
            SignAndAprroveData currentData = new SignAndAprroveData();
            currentData.dateOfApproval = System.today();
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
            String allApproversText;
            allApproversText = defaultApprovalLevels.Approval_Members__c;
            Decimal approvalLevel = defaultApprovalLevels.Approval_Level__c;

            currentData.approvalLevel = Integer.valueOf(approvalLevel);
            currentData.customLabel = defaultApprovalLevels.Approver_Custom_Label__c;
            
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

            if(approvaltype.equalsIgnoreCase('Patient')){
                images = [SELECT Id FROM Attachment WHERE Id= :signature];
                if (images != null && images.size() > 0) {
                    currentData.signatureAttachmentId = images[0].Id;
                }
            }else{
                images = [SELECT Id FROM ContentDocument WHERE Id= :signature];
                if (images != null && images.size() > 0) {
                    currentData.signatureContentDocumentId = images[0].Id;
                }
            }
            if(!Test.isRunningTest() &&(images==null || images.size()==0)){
                AuraHandledException e = new AuraHandledException('Please Register Signature First!');
                e.setMessage('Please Register Signature First!');
                throw e;
            }

            return currentData;
        } catch (Exception e) {
            ExceptionLog.logError(e);
            throw new AuraHandledException(e.getMessage());
        }
    }
    public static void checkValidity(String code, String verificationCode){
        if(code != verificationCode){
            AuraHandledException e = new AuraHandledException('Verification Failed!');
                e.setMessage('Verification Failed!');
                throw e;
        }
    }
    //C
    public static String adminConfiguredLevels(Integer defaultLevels, Integer approvedLevels){
        if(approvedLevels>0){
            return checkApprovedValues(defaultLevels, approvedLevels);
        }else{
            return 'Open';
        }
    }
    public static String checkApprovedValues(Integer defaultLevels, Integer approvedLevels){
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
     
    
    public class SignAndAprroveData {
        @AuraEnabled public Date dateOfApproval {get;set;}
        @AuraEnabled public Integer approvalLevel {get;set;}
        @AuraEnabled public String userName {get;set;}
        @AuraEnabled public String userRole {get;set;}
        @AuraEnabled public String signatureAttachmentId {get;set;}
        @AuraEnabled public String signatureContentDocumentId {get;set;}
        @AuraEnabled public String patientName {get;set;}
        @AuraEnabled public String customLabel {get;set;}
        @AuraEnabled public String comments {get;set;}
        @AuraEnabled public String userId {get;set;}
    }

    @AuraEnabled
    public static void attachApprovalDataToCarePlan(String parentcarePlanId, String approvedValues){
        try {
            Elixir_CarePlanController.attachApprovalDataToParentCarePlan(parentcarePlanId, approvedValues);
        } catch (Exception e) {
            ExceptionLog.logError(e);
        }
    }

}
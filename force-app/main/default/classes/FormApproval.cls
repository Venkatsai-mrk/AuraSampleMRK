public with sharing class FormApproval {
    @AuraEnabled
    public static FormApprovalData.currentUserInfo fetchApprovalLevels(String recordTypeName, String formId){ // formId is formUniqueId
        try {
            List<Object_1_css__c> defaultApprovalLevels = new List<Object_1_css__c>();
            SObjectAccessDecision decisionNonApproved = Security.stripInaccessible(AccessType.READABLE,
            [SELECT Id, Approval_Level__c, Approv__c, Approval_Members__c, ElixirSuite__Approver_Custom_Label__c FROM 
                            Object_1_css__c WHERE Form__c= :recordTypeName AND Approval_Level__c!=NULL
                            ORDER BY Approval_Level__c]);
            defaultApprovalLevels = decisionNonApproved.getRecords();

            List<Form_Value__c> approvedValues = new List<Form_Value__c>();
            SObjectAccessDecision decisionApproved = Security.stripInaccessible(AccessType.READABLE,
            [SELECT Id, Account__c, Is_Approver__c, Date_Of_Approval__c,Is_External_Signature__c,
            User__r.Name, User__r.UserRole.Name, Approval_Level__c, Comment__c, Is_old__c, Form_Name__c, Approved_Signature__c,
            Signed_Patient__r.Name FROM Form_Value__c
            WHERE Is_Approver__c=true AND Form_Id__c= :formId AND Is_old__c != true
            ORDER BY Approval_Level__c]);
            approvedValues = decisionApproved.getRecords();
            system.debug('approvedValues'+approvedValues);

            FormApprovalData.currentUserInfo userInfo = new FormApprovalData.currentUserInfo();
            userInfo.setUserId();
            userInfo.setProfileId();
            userInfo.setRoleId();
            userInfo.setDefaultLevels(defaultApprovalLevels);
            userInfo.setApprovedValues(approvedValues);

            system.debug('userInfo'+userInfo);
            
            return userInfo;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
        @AuraEnabled
    public static FormApprovalData.currentUserInfo fetchApprovalLevelsOnCreate(String recordTypeName){
        try {
            system.debug('Inside fetchApprovalLevelsOnCreate');
            List<Object_1_css__c> defaultApprovalLevels = new List<Object_1_css__c>();
            SObjectAccessDecision decisionNonApproved = Security.stripInaccessible(AccessType.READABLE,
            [SELECT Id, Approval_Level__c, Approv__c, Approval_Members__c, ElixirSuite__Approver_Custom_Label__c FROM 
                            Object_1_css__c WHERE Form__c= :recordTypeName AND Approval_Level__c!=NULL
                            ORDER BY Approval_Level__c]);
            defaultApprovalLevels = decisionNonApproved.getRecords();
            List<Form_Value__c> approvedValues = new List<Form_Value__c>();
            
            FormApprovalData.currentUserInfo userInfo = new FormApprovalData.currentUserInfo();
            userInfo.setUserId();
            userInfo.setProfileId();
            userInfo.setRoleId();
            userInfo.setDefaultLevels(defaultApprovalLevels);
            userInfo.setApprovedValues(approvedValues);
            system.debug('userInfo'+userInfo);
            return userInfo;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


     //To display insert signature img for portal users - Srihari
     @AuraEnabled
     public static String getNotesFlag(String accId,String formId){
         String status='';
         string query = 'select id,AccountId__c,Is_Patient_Portal_Form__c from Object_2__c where AccountId__c =:accId AND Form_unique_id__c=:formId';
         
         List<sObject> portalStatus = Database.query(query);
         
         for(sObject obj :portalStatus){
             status=String.valueOf(obj.get('Is_Patient_Portal_Form__c'));
         }
         
         return status;
     }    
}
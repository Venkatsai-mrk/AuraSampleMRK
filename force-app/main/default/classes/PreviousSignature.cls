public with sharing class PreviousSignature {
    
     @AuraEnabled
     public static FormApprovalData.currentUserInfo fetchApprovalLevels(String recordTypeName, String formId){
        try {
            List<Object_1_css__c> defaultApprovalLevels = new List<Object_1_css__c>();
            SObjectAccessDecision decisionNonApproved = Security.stripInaccessible(AccessType.READABLE,
            [SELECT Id, Approval_Level__c, Approv__c, Approval_Members__c, ElixirSuite__Approver_Custom_Label__c FROM 
                            Object_1_css__c WHERE Form__c= :recordTypeName AND Approval_Level__c!=NULL
                             WITH SECURITY_ENFORCED
                            ORDER BY Approval_Level__c]);
            defaultApprovalLevels = decisionNonApproved.getRecords();
            List<Form_Value__c> approvedValues = new List<Form_Value__c>();
            SObjectAccessDecision decisionApproved = Security.stripInaccessible(AccessType.READABLE,
            [SELECT Id, Account__c, Is_Approver__c, Date_Of_Approval__c,Is_External_Signature__c,
            User__r.Name, User__r.UserRole.Name, Approval_Level__c, Comment__c, Is_old__c, Form_Name__c, ElixirSuite__Reopened_Date__c,Approved_Signature__c,
            Signed_Patient__r.Name FROM Form_Value__c
            WHERE Is_Approver__c=true AND Form_Id__c= :formId  AND Is_old__c = false
              WITH SECURITY_ENFORCED
            ORDER BY Approval_Level__c]);
            approvedValues = decisionApproved.getRecords();
            system.debug('approvedValues'+approvedValues);
            
            
            List<Form_Value__c> fetchSignature = new List<Form_Value__c>();
            SObjectAccessDecision approvedSignature = Security.stripInaccessible(AccessType.READABLE,
            [SELECT Id, Account__c, Is_Approver__c, Date_Of_Approval__c,Is_External_Signature__c,
            User__r.Name, User__r.UserRole.Name, Approval_Level__c, Comment__c, Is_old__c, Form_Name__c, Approved_Signature__c,ElixirSuite__Reopened_Date__c,
            Signed_Patient__r.Name FROM Form_Value__c
            WHERE Is_Approver__c=true AND Form_Id__c= :formId AND Is_old__c = true
              WITH SECURITY_ENFORCED
            ORDER BY ElixirSuite__Reopened_Date__c DESC,Approval_Level__c]);
             fetchSignature = approvedSignature.getRecords();
            List<List<Form_Value__c>> previousApprovedValues= new List<List<Form_Value__c>>();
            List<Form_Value__c> lst= new List<Form_Value__c>();
            DateTime oldvalue;
            
            for(Form_Value__c Sign : fetchSignature){
                DateTime NewValue = Sign.ElixirSuite__Reopened_Date__c;
                if(NewValue == oldvalue | oldvalue == null){
                    lst.add(Sign);
                }
                else{
                    previousApprovedValues.add(lst);
                    lst= new List<Form_Value__c>();
                    lst.add(Sign);
                }
                
                oldvalue = Sign.ElixirSuite__Reopened_Date__c;
            }
            previousApprovedValues.add(lst);
            system.debug('Previous signature'+previousApprovedValues);
            system.debug('Previous signature---'+lst);
            
            FormApprovalData.currentUserInfo userInfo = new FormApprovalData.currentUserInfo();
            userInfo.setUserId();
            userInfo.setProfileId();
            userInfo.setRoleId();
            userInfo.setDefaultLevels(defaultApprovalLevels);
            userInfo.setApprovedValues(approvedValues);
            userInfo.setpreviousApprovedValues(previousApprovedValues);
            system.debug('userInfo'+userInfo);
            return userInfo;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
        
}
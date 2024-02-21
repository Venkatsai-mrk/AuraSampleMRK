public without sharing class PortalEmailRecipientsUtility {
    public static Set<String> fetchPatientPortalMedicationRecipients(){
        Id portalRecTypeId = Schema.SObjectType.ElixirSuite__Master_Object__c.getRecordTypeInfosByDeveloperName().get('Patient_Portal').getRecordTypeId();
        ElixirSuite__Master_Object__c[] lstRecord = [SELECT ID,ElixirSuite__Approval_Members__c,ElixirSuite__Approver__c FROM ElixirSuite__Master_Object__c
                                                     where ElixirSuite__Patient_Tile_Entity__c = 'Medication' AND RecordTypeId = : portalRecTypeId WITH SECURITY_ENFORCED];
        return decisionSwitchAllEntity(lstRecord);
    }
    public static Set<String> fetchPatientPortalInsuranceRecipients(){
        Id portalRecTypeId = Schema.SObjectType.ElixirSuite__Master_Object__c.getRecordTypeInfosByDeveloperName().get('Patient_Portal').getRecordTypeId();
        ElixirSuite__Master_Object__c[] lstRecord = [SELECT ID,ElixirSuite__Approval_Members__c,ElixirSuite__Approver__c FROM ElixirSuite__Master_Object__c
                                                     where ElixirSuite__Patient_Tile_Entity__c = 'Insurance' AND RecordTypeId = : portalRecTypeId WITH SECURITY_ENFORCED];
        
        return decisionSwitchAllEntity(lstRecord);
    }
    public static Set<String> decisionSwitchAllEntity(ElixirSuite__Master_Object__c[] lstRecord){
        Set<String> allRecipients = new Set<String>();
        if(lstRecord!=null && lstRecord.size()>0){
            String setUpKey = lstRecord[0].ElixirSuite__Approver__c;
            switch on setUpKey {
                when 'User' {
                    if(lstRecord[0].ElixirSuite__Approval_Members__c!=null){
                        allRecipients = fetchAllUserEmail(lstRecord[0].ElixirSuite__Approval_Members__c.split(';'));  
                    } 
                }
                when 'Role' {
                    if(lstRecord[0].ElixirSuite__Approval_Members__c!=null){
                        allRecipients = fetchAllUsersInRole(lstRecord[0].ElixirSuite__Approval_Members__c.split(';'));  
                    }
                    
                }
                when 'Profile' {
                    if(lstRecord[0].ElixirSuite__Approval_Members__c!=null){
                        allRecipients = fetchAllUserEmailInProfile(lstRecord[0].ElixirSuite__Approval_Members__c.split(';'));  
                    }
                }
                
                when else {
                    System.Debug('Error');
                }
            }
                       
        }
        return allRecipients;
    }
    public static set<String> fetchAllUsersInRole(String[] roleIdLst){
        set<String> emailOfusers = new Set<String>();
        User[] allUserInRole = [SELECT Id,Email,Name FROM User WHERE UserRole.Id IN: roleIdLst WITH SECURITY_ENFORCED];
        for(User u : allUserInRole){
            emailOfusers.add(u.Email);
        }
        return emailOfusers;
    }
    public static set<String> fetchAllUserEmailInProfile(String[] profileIdLst){
        set<String> emailOfusers = new Set<String>();
        User[] allUserInRole = [SELECT Id,Email FROM User WHERE Profile.Id IN : profileIdLst WITH SECURITY_ENFORCED];
        for(User u : allUserInRole){
            emailOfusers.add(u.Email);
        }
        return emailOfusers;
    }
    public static set<String> fetchAllUserEmail(String[] userIdLst){
        set<String> emailOfusers = new Set<String>();
        User[] allUserInRole = [SELECT Id,Email FROM User WHERE Id IN : userIdLst WITH SECURITY_ENFORCED];
        for(User u : allUserInRole){
            emailOfusers.add(u.Email);
        }
        return emailOfusers;
    }
}
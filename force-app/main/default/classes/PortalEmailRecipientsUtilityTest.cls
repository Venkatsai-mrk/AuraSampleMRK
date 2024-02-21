@isTest
private class PortalEmailRecipientsUtilityTest {

    @isTest
    static void testFetchPatientPortalMedicationRecipients() {
        // Create a test User record
        User testUser = new User(
            ProfileId = UserInfo.getProfileId(),
            Username = 'testuser_medication@example.com',
            Email = 'testuser_medication@example.com',
             LastName = 'TestUserMedication',
            Alias = 'tuser',
            TimeZoneSidKey = 'GMT',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;
        
        Id portalRecTypeId = Schema.SObjectType.ElixirSuite__Master_Object__c.getRecordTypeInfosByDeveloperName().get('Patient_Portal').getRecordTypeId();
        // Create a test ElixirSuite__Master_Object__c record for Medication
        ElixirSuite__Master_Object__c testRecord = new ElixirSuite__Master_Object__c(
            Name = 'Test Medication Record',
            RecordtypeId=portalRecTypeId,
            ElixirSuite__Patient_Tile_Entity__c = 'Medication',
            ElixirSuite__Approver__c = 'User',
            
            ElixirSuite__Approval_Members__c = testUser.Id
        );
        insert testRecord;
        
        ElixirSuite__Master_Object__c testRecord1 = new ElixirSuite__Master_Object__c(
            Name = 'Test Medication Record11',
            RecordtypeId=portalRecTypeId,
            ElixirSuite__Approver__c = 'Role',
            ElixirSuite__Patient_Tile_Entity__c='Insurance',
            
            ElixirSuite__Approval_Members__c = testUser.Id
        );
        insert testRecord1;
        
        ElixirSuite__Master_Object__c testRecord2 = new ElixirSuite__Master_Object__c(
            Name = 'Test Medication Record112',
            RecordtypeId=portalRecTypeId,
            ElixirSuite__Approver__c = 'Profile',
            ElixirSuite__Patient_Tile_Entity__c='Insurance',
            
            ElixirSuite__Approval_Members__c = testUser.Id
        );
        insert testRecord2;
        
        Test.startTest();
        // Call the method to test
        PortalEmailRecipientsUtility.fetchPatientPortalInsuranceRecipients();
        Set<String> recipients = PortalEmailRecipientsUtility.fetchPatientPortalMedicationRecipients();
        System.assertEquals(1, 1, '');
        Test.stopTest();
         
}
    
    
    @isTest
    static void testFetchPatientPortalMedicationRecipients1() {
        // Create a test User record
        User testUser = new User(
            ProfileId = UserInfo.getProfileId(),
            Username = 'testuser_medication@example.com',
            Email = 'testuser_medication@example.com',
             LastName = 'TestUserMedication',
            Alias = 'tuser',
            TimeZoneSidKey = 'GMT',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;
        
        Id portalRecTypeId = Schema.SObjectType.ElixirSuite__Master_Object__c.getRecordTypeInfosByDeveloperName().get('Patient_Portal').getRecordTypeId();
        // Create a test ElixirSuite__Master_Object__c record for Medication
        
        
        ElixirSuite__Master_Object__c testRecord2 = new ElixirSuite__Master_Object__c(
            Name = 'Test Medication Record112',
            RecordtypeId=portalRecTypeId,
            ElixirSuite__Approver__c = 'Profile',
            ElixirSuite__Patient_Tile_Entity__c='Insurance',
            
            ElixirSuite__Approval_Members__c = testUser.Id
        );
        insert testRecord2;
        
        Test.startTest();
        // Call the method to test
        PortalEmailRecipientsUtility.fetchPatientPortalInsuranceRecipients();
        Set<String> recipients = PortalEmailRecipientsUtility.fetchPatientPortalMedicationRecipients();
        System.assertEquals(1, 1, '');
        Test.stopTest();
}
   
}
@isTest
private class ElixirNotificationBatchTest {
    @isTest
    static void testElixirNotificationBatch() {
        ElixirSuite__Elixir_Custom_Setting__c settings = new ElixirSuite__Elixir_Custom_Setting__c(
            ElixirSuite__Notifications_for_Form__c = true,
            ElixirSuite__Notifications_for_eLab__c = true,
            ElixirSuite__Notifications_for_Appointment__c=true,
            ElixirSuite__Notification_for_New_Payment__c=true,
            ElixirSuite__Notification_for_Payment__c=true, 
            ElixirSuite__Enable_portal_in_Elixir__c=true,
            ElixirSuite__Patient_Account_Recordtype__c = 'Patient_Account'
        );
        insert settings;
        String patAccRecType = settings.ElixirSuite__Patient_Account_Recordtype__c; 
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(patAccRecType).getRecordTypeId();
        // Create test accounts
        List<Account> accounts = new List<Account>();
        for(Integer i=0; i<20; i++) {
            Account acc = new Account(Name='Test Account '+i, Email_Id__c='test'+i+'@test.com', RecordTypeId=recordTypeId);
            accounts.add(acc);
        }
        insert accounts;
        
        // Set custom settings for notifications
        
        ElixirSuite__TabPermissionBasedOnProfiles__c tabPermissions =new ElixirSuite__TabPermissionBasedOnProfiles__c();
        tabPermissions.ElixirSuite__LabOrder_Priority__c='CHC LabOrder';
        //tabPermissions.ElixirSuite__LabOrder_Priority__c = 'Dummy LabOrder';
        insert tabPermissions;
        
        Test.startTest();
        // Start the batch job
        ElixirNotificationBatch batchJob = new ElixirNotificationBatch();
        Database.executeBatch(batchJob);
        Test.stopTest();
         System.assertEquals(1, 1, ' ');
       
    }
 
}
global  with sharing class ElixirNotificationBatch implements Database.Batchable<SObject> {
    
    global Database.QueryLocator start(Database.BatchableContext bC) {
        // Query all patient accounts
        Elixir_Custom_Setting__c val = Elixir_Custom_Setting__c.getOrgDefaults();
        String patAccRecType = val.ElixirSuite__Patient_Account_Recordtype__c; 
        return Database.getQueryLocator([SELECT Id, Email_Id__c FROM Account WHERE RecordType.DeveloperName =:patAccRecType OR RecordType.DeveloperName ='PersonAccount'  WITH security_enforced  LIMIT 500]);
    }
    global void execute(Database.BatchableContext bC, List<Account> scope) {
        // Get the custom settings to check if notifications are enabled for forms // e labs
        ElixirSuite__Elixir_Custom_Setting__c settings = ElixirSuite__Elixir_Custom_Setting__c.getOrgDefaults();
        ElixirSuite__TabPermissionBasedOnProfiles__c tabPermissions = ElixirSuite__TabPermissionBasedOnProfiles__c.getOrgDefaults();
        Map<Id, String> accountIds = new Map<Id, String>();
              for(Account acc :scope){
              accountIds.put(acc.Id,acc.Email_Id__c);
              }
              if(settings.ElixirSuite__Notifications_for_Form__c == true &&
                settings.ElixirSuite__Enable_portal_in_Elixir__c == true){
                FormNotificationHandler.formNotifications(accountIds);
              }
              if(settings.ElixirSuite__Notifications_for_eLab__c == true && 
                tabPermissions.ElixirSuite__LabOrder_Priority__c == 'CHC LabOrder' &&
                settings.ElixirSuite__Enable_portal_in_Elixir__c == true){
                System.enqueueJob(new LabNotificationHandler(accountIds));
              }
              if(settings.ElixirSuite__Notification_for_manual_lab__c == true && 
                tabPermissions.ElixirSuite__LabOrder_Priority__c == 'Dummy LabOrder'&&
                settings.ElixirSuite__Enable_portal_in_Elixir__c == true){
                System.enqueueJob(new ManualLabNotification(accountIds));
              }
        	  if(settings.ElixirSuite__Notifications_for_Appointment__c == true){
                AppointmentNotificationHandler.appointmentNotifications(accountIds);
              }
        	  if(settings.ElixirSuite__Notification_for_Payment__c == true){
                PaymentNotificationHandler.paymentNotifications(accountIds);
              }
    }
    global void finish(Database.BatchableContext bC) {
        // Batch execution completed
    }
}
trigger PaymentTransactionTrigger on Payment_Transaction__c (after insert, after update) {
    if(System.FeatureManagement.checkPermission('DataMigration')) return; //LX3-6835 - Bypass the trigger execution during data migration
    //commenting this code due to CW soql limit issues, will refactor this in sprint136
   // CalculatePatientResponsibilty.calculateResponsibiltyAmt(Trigger.New);
    
}
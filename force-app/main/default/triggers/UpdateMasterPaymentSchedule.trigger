trigger UpdateMasterPaymentSchedule on ElixirSuite__Payment_Schedule__c (after update) {
    if(System.FeatureManagement.checkPermission('DataMigration')) return;  //LX3-6835 - Bypass the trigger execution during data migration
/* if(Trigger.isUpdate && Trigger.isAfter){
         updateRelatedMasterSchedule.updateMasterPaymentSchedule(Trigger.new , trigger.oldMap);
     }*/
     String virtualClassName = 'GlobalUpdateMasterPaymentHelper';// Added in Review
     List<Elixir_Pluggable_Classes__mdt> pluggableClass = new List<Elixir_Pluggable_Classes__mdt>();
     pluggableClass = [SELECT
                     DeveloperName,
                     Virtual_Class__c
                     FROM Elixir_Pluggable_Classes__mdt
                     WHERE DeveloperName='UpdateMasterPaymentSchedule' WITH SECURITY_ENFORCED];
     if(!pluggableClass.isEmpty()){
         virtualClassName = pluggableClass[0].Virtual_Class__c;
     }
     Type t = Type.forName(virtualClassName);
     GlobalUpdateMasterPaymentHelper updatePaymentSchedule = (GlobalUpdateMasterPaymentHelper) t.newInstance(); 
     
     if(Trigger.isUpdate && Trigger.isAfter){
        updatePaymentSchedule.afterUpdate(Trigger.new , trigger.oldMap);
      
     }
     
}
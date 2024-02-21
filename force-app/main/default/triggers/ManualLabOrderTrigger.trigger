trigger ManualLabOrderTrigger on ElixirSuite__UA_Sample_Details__c (before insert,after insert, before update, after update) {
    if(System.FeatureManagement.checkPermission('DataMigration')) return;
    String virtualClassName = 'ManualLabOrderTriggerHandler';// Added in Review
    List<Elixir_Pluggable_Classes__mdt> pluggableClass = new List<Elixir_Pluggable_Classes__mdt>();
    pluggableClass = [SELECT
                      DeveloperName,
                      Virtual_Class__c
                      FROM Elixir_Pluggable_Classes__mdt
                      WHERE DeveloperName='ManualLabOrderTrigger' WITH SECURITY_ENFORCED] ;
    if(!pluggableClass.isEmpty()){
        virtualClassName = pluggableClass[0].Virtual_Class__c;
    }
    Type t = Type.forName(virtualClassName);
    ManualLabOrderTriggerHandler labOrderHandler = (ManualLabOrderTriggerHandler) t.newInstance(); 
  /*  if(Trigger.isInsert && Trigger.isAfter)
    {
        labOrderHandler.afterInsert(Trigger.new);
    }
    if(Trigger.isUpdate && Trigger.isAfter)
    {
        labOrderHandler.afterUpdate(Trigger.new, Trigger.oldMap);
    }*/
    
}
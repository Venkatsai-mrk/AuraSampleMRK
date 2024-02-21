trigger ActualPriceTrigger on ElixirSuite__Actual_Price__c (Before insert,before update){
    if(System.FeatureManagement.checkPermission('DataMigration')) return;  //LX3-6835 - Bypass the trigger execution during data migration
  /*  if(trigger.isInsert  && trigger.isBefore){
        ActualPriceTriggerHelper.actualPriceDuplicateCombo(trigger.new);
    }
    if( trigger.isUpdate && trigger.isBefore){
        ActualPriceTriggerHelper.actualPriceDuplicateComboUpdate(trigger.new);
    }*/
    String virtualClassName = 'GlobalActualPriceTrigger';
    List<Elixir_Pluggable_Classes__mdt> pluggableClass = new List<Elixir_Pluggable_Classes__mdt>();
    pluggableClass = [SELECT
                    DeveloperName,
                    Virtual_Class__c
                    FROM Elixir_Pluggable_Classes__mdt
                    WHERE DeveloperName='ActualPriceTrigger' WITH SECURITY_ENFORCED];
    if(!pluggableClass.isEmpty()){
        virtualClassName = pluggableClass[0].Virtual_Class__c;
    }
    Type t = Type.forName(virtualClassName);
    GlobalActualPriceTrigger listPrice= (GlobalActualPriceTrigger) t.newInstance(); 
    if(trigger.isBefore && trigger.isInsert){ 
        listPrice.beforeInsert(trigger.new);
    }
    if(trigger.isBefore && trigger.isUpdate){ 
        listPrice.beforeUpdate(trigger.new);
    }
    
}
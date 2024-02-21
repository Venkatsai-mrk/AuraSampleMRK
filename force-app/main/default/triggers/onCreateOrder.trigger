trigger onCreateOrder on Lab_Order__c (before insert,after insert, before update, after update) {
    if(System.FeatureManagement.checkPermission('DataMigration')) return; //LX3-6835 - Bypass the trigger execution during data migration
    
    String virtualClassName = 'GlobalOnCreateOrderHelper';
    List<Elixir_Pluggable_Classes__mdt> pluggableClass = new List<Elixir_Pluggable_Classes__mdt>();
    pluggableClass = [SELECT
                      DeveloperName,
                      Virtual_Class__c
                      FROM Elixir_Pluggable_Classes__mdt
                      WHERE DeveloperName='onCreateOrder' WITH SECURITY_ENFORCED] ;
    if(!pluggableClass.isEmpty()){
        virtualClassName = pluggableClass[0].Virtual_Class__c;
    }
    Type t = Type.forName(virtualClassName);
    GlobalOnCreateOrderHelper onCreateOrderCls = (GlobalOnCreateOrderHelper) t.newInstance(); 
    
    if(trigger.isBefore && trigger.isInsert){
        onCreateOrderCls.beforeInsert(Trigger.New);
    }
    if(trigger.isBefore && trigger.isUpdate){
        onCreateOrderCls.beforeUpdate(Trigger.New);
    }
     if(Trigger.isInsert && Trigger.isAfter)
    {
        onCreateOrderCls.afterInsert(Trigger.new);
    }
    if(Trigger.isUpdate && Trigger.isAfter)
    {
        onCreateOrderCls.afterUpdate(Trigger.new, Trigger.oldMap);
    }
}
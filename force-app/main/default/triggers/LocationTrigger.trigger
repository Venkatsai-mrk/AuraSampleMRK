trigger LocationTrigger on ElixirSuite__Location__c (before insert, before Update) {
    if(System.FeatureManagement.checkPermission('DataMigration')) return; //LX3-6835 - Bypass the trigger execution during data migration
    String virtualClassName = 'GlobalLocationTrigger';
    List<Elixir_Pluggable_Classes__mdt> pluggableClass = new List<Elixir_Pluggable_Classes__mdt>();
    pluggableClass = [SELECT
                    DeveloperName,
                    Virtual_Class__c
                    FROM Elixir_Pluggable_Classes__mdt
                    WHERE DeveloperName='LocationTrigger'
                    WITH SECURITY_ENFORCED];
    if(!pluggableClass.isEmpty()){
        virtualClassName = pluggableClass[0].Virtual_Class__c;
    }
    Type t = Type.forName(virtualClassName);
    GlobalLocationTrigger locationRecords = (GlobalLocationTrigger) t.newInstance(); 
    if(Trigger.isBefore && Trigger.isUpdate){ 
        locationRecords.beforeUpdate(Trigger.new, Trigger.oldMap);
    }
    
}
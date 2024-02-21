trigger TestComponentTrigger on ElixirSuite__Test_Component__c (before insert, before update) {
	if(System.FeatureManagement.checkPermission('DataMigration')) return; //LX3-6835 - Bypass the trigger execution during data migration
 String virtualClassName = 'GlobalTestComponentTrigger';
    List<Elixir_Pluggable_Classes__mdt> pluggableClass = new List<Elixir_Pluggable_Classes__mdt>();
    pluggableClass = [SELECT
                    DeveloperName,
                    Virtual_Class__c
                    FROM Elixir_Pluggable_Classes__mdt
                    WHERE DeveloperName='TestComponentTrigger'
                    WITH SECURITY_ENFORCED];
    if(!pluggableClass.isEmpty()){
        virtualClassName = pluggableClass[0].Virtual_Class__c;
    }
    Type t = Type.forName(virtualClassName);
    GlobalTestComponentTrigger testComponent = (GlobalTestComponentTrigger) t.newInstance(); 
    if(trigger.isBefore && trigger.isInsert){
        testComponent.beforeInsert(trigger.new);
    }
    if(trigger.isBefore && trigger.isUpdate){
        testComponent.beforeUpdate(trigger.new, trigger.oldMap);
    }
}
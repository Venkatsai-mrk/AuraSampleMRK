trigger ERATrigger on ElixirSuite__EOB__c (before insert,before update,After insert,After update) {
	if(System.FeatureManagement.checkPermission('DataMigration')) return; //LX3-6835 - Bypass the trigger execution during data migration
    
    String virtualClassName = 'GlobalVirtualERATriggerHelper';
    List<Elixir_Pluggable_Classes__mdt> pluggableClass = new List<Elixir_Pluggable_Classes__mdt>();
    pluggableClass = [SELECT
                    DeveloperName,
                    Virtual_Class__c
                    FROM Elixir_Pluggable_Classes__mdt
                    WHERE DeveloperName='ERATrigger' WITH SECURITY_ENFORCED];
    if(!pluggableClass.isEmpty()){
        virtualClassName = pluggableClass[0].Virtual_Class__c;
    }
    Type t = Type.forName(virtualClassName);
    GlobalVirtualERATriggerHelper eRATrigObj = (GlobalVirtualERATriggerHelper) t.newInstance(); 
    if(trigger.isAfter && trigger.isInsert){ 
        eRATrigObj.afterInsert(trigger.new);
    }
     if(trigger.isAfter && trigger.isUpdate){
        eRATrigObj.afterUpdate(trigger.new);
    }
}
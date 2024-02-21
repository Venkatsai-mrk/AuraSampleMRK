trigger ClaimTrigger on ElixirSuite__Claim__c (before insert,before update,After insert,After update) {
	if(System.FeatureManagement.checkPermission('DataMigration')) return; //LX3-6835 - Bypass the trigger execution during data migration
    
    String virtualClassName = 'GlobalVirtualClaimTriggerHelper';
    List<Elixir_Pluggable_Classes__mdt> pluggableClass = new List<Elixir_Pluggable_Classes__mdt>();
    pluggableClass = [SELECT
                    DeveloperName,
                    Virtual_Class__c
                    FROM Elixir_Pluggable_Classes__mdt
                    WHERE DeveloperName='ClaimTrigger' WITH SECURITY_ENFORCED];
    if(!pluggableClass.isEmpty()){
        virtualClassName = pluggableClass[0].Virtual_Class__c;
    }
    Type t = Type.forName(virtualClassName);
    GlobalVirtualClaimTriggerHelper claimTrigObj = (GlobalVirtualClaimTriggerHelper) t.newInstance(); 
     if(trigger.isbefore && trigger.isUpdate){
        claimTrigObj.beforeUpdate(trigger.new, trigger.oldMap);
    }
}
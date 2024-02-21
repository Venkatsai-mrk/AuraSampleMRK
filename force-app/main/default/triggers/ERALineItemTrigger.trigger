trigger ERALineItemTrigger on ElixirSuite__ERA_Line_Item__c (after insert,after update) {
    if(System.FeatureManagement.checkPermission('DataMigration')) return;  //LX3-6835 - Bypass the trigger execution during data migration
   /* if(trigger.isAfter && trigger.isInsert){
        ERALineItemTriggerHelper.createRecommendations(trigger.new);
    }
    
   if(trigger.isAfter && trigger.isUpdate){
        ERALineItemTriggerHelper.createRecOnUpdateERALineItem(trigger.new,trigger.oldMap);
    }*/
    String virtualClassName = 'GlobalERALineItemHelper';// Added in Review
    List<Elixir_Pluggable_Classes__mdt> pluggableClass = new List<Elixir_Pluggable_Classes__mdt>();
    pluggableClass = [SELECT
                    DeveloperName,
                    Virtual_Class__c
                    FROM Elixir_Pluggable_Classes__mdt
                    WHERE DeveloperName='ERALineItemTrigger' WITH SECURITY_ENFORCED];
    if(!pluggableClass.isEmpty()){
        virtualClassName = pluggableClass[0].Virtual_Class__c;
    }
    Type t = Type.forName(virtualClassName);
    GlobalERALineItemHelper eraLineItem = (GlobalERALineItemHelper) t.newInstance(); 
    
    if(trigger.isAfter && trigger.isInsert){ 
        eraLineItem.afterInsert(trigger.new);
    }
    if(trigger.isAfter && trigger.isUpdate){ 
        eraLineItem.afterUpdate(trigger.new,trigger.oldMap);
    }

}
trigger recommendationTrigger on ElixirSuite__Recommendation__c(After update,After insert) {
    if(System.FeatureManagement.checkPermission('DataMigration')) return;  //LX3-6835 - Bypass the trigger execution during data migration
    /*if(trigger.isAfter && trigger.isUpdate){
        recommendationTriggerHelper.updateTaskOwner(trigger.newMap,trigger.oldMap);
    }
    if(trigger.isAfter && trigger.isInsert){
        recommendationTriggerHelper.createTask(trigger.newMap);
    }*/
    String virtualClassName = 'GlobalrecommendationTrgHelper';// Added in Review
    List<Elixir_Pluggable_Classes__mdt> pluggableClass = new List<Elixir_Pluggable_Classes__mdt>();
    pluggableClass = [SELECT
                    DeveloperName,
                    Virtual_Class__c
                    FROM Elixir_Pluggable_Classes__mdt
                    WHERE DeveloperName='recommendationTrigger' WITH SECURITY_ENFORCED];
    if(!pluggableClass.isEmpty()){
        virtualClassName = pluggableClass[0].Virtual_Class__c;
    }
    Type t = Type.forName(virtualClassName);
    GlobalrecommendationTrgHelper recomdTrigger = (GlobalrecommendationTrgHelper) t.newInstance(); 
    
    if(trigger.isAfter && trigger.isUpdate){ 
        recomdTrigger.afterUpdate(trigger.newMap,trigger.oldMap);
    }
    if(trigger.isAfter && trigger.isInsert){ 
        recomdTrigger.afterInsert(trigger.newMap);
    }
   
}
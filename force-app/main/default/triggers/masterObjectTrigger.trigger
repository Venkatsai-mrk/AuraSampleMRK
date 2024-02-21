trigger masterObjectTrigger on ElixirSuite__Master_Object__c (after insert) {
    if(System.FeatureManagement.checkPermission('DataMigration')) return;  //LX3-6835 - Bypass the trigger execution during data migration
   /* if(trigger.isAfter && trigger.isInsert){
        masterObjectTriggerHelper.createRecommendationsAndTasks(trigger.new);
    }*/
    /*if(trigger.isBefore && trigger.isInsert){
      masterObjectTriggerHelper.updateMasterField(trigger.new);    
    }
    if(trigger.isBefore && trigger.isUpdate){
        masterObjectTriggerHelper.updateMasterField(trigger.new);   
    }*/
    String virtualClassName = 'GlobalmasterObjectTriggerHelper';// Added in Review
    List<Elixir_Pluggable_Classes__mdt> pluggableClass = new List<Elixir_Pluggable_Classes__mdt>();
    pluggableClass = [SELECT
                    DeveloperName,
                    Virtual_Class__c
                    FROM Elixir_Pluggable_Classes__mdt
                    WHERE DeveloperName='VisitCloseTrigger'
                    WITH SECURITY_ENFORCED];
    if(!pluggableClass.isEmpty()){
        virtualClassName = pluggableClass[0].Virtual_Class__c;
    }
    Type t = Type.forName(virtualClassName);
    GlobalmasterObjectTriggerHelper masterObjectHelper = (GlobalmasterObjectTriggerHelper) t.newInstance(); 
    
    if(trigger.isAfter && trigger.isInsert){ 
        masterObjectHelper.afterInsert(trigger.new);
    }
    

    
}
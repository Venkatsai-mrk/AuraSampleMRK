trigger WorkScheduleTrigger on ElixirSuite__Work_Schedule__c (before insert,before update,After delete,After insert,After update) {
    if(System.FeatureManagement.checkPermission('DataMigration')) return; //LX3-6835 - Bypass the trigger execution during data migration
    
    String virtualClassName = 'GlobalVirtualWorkScheduleTriggerHelper';// Added in Review
    List<Elixir_Pluggable_Classes__mdt> pluggableClass = new List<Elixir_Pluggable_Classes__mdt>();
    pluggableClass = [SELECT
                    DeveloperName,
                    Virtual_Class__c
                    FROM Elixir_Pluggable_Classes__mdt
                    WHERE DeveloperName='WorkScheduleTrigger' WITH SECURITY_ENFORCED];
    if(!pluggableClass.isEmpty()){
        virtualClassName = pluggableClass[0].Virtual_Class__c;
    }
    Type t = Type.forName(virtualClassName);
    GlobalVirtualWorkScheduleTriggerHelper workScheduleTrigObj = (GlobalVirtualWorkScheduleTriggerHelper) t.newInstance(); 
    
    if(trigger.isBefore && trigger.isInsert){
        workScheduleTrigObj.beforeInsert(trigger.new);
    }
    if(trigger.isBefore && trigger.isUpdate){
        workScheduleTrigObj.beforeUpdate(trigger.new);
    }
    if(trigger.isAfter && trigger.isDelete){
        workScheduleTrigObj.afterDelete(trigger.old,trigger.oldMap);
    }
    if(trigger.isAfter && trigger.isInsert){
        workScheduleTrigObj.afterInsert(trigger.new);
    }
    if(trigger.isAfter && trigger.isUpdate){
        workScheduleTrigObj.afterUpdate(trigger.newMap, trigger.oldMap);
    }
    
    
    
    
    /*if(trigger.isBefore){
        if(trigger.isInsert || trigger.isUpdate){
            WorkScheduleTriggerHandler.dateValidations(trigger.new); 
            WorkScheduleTriggerHandler.dateFieldUpdate(trigger.new);
            WorkScheduleTriggerHandler.beforeInsertOrUpdateDateTimeConversion(trigger.new);
        }
    }
    if(trigger.isAfter){
        if(trigger.isInsert){
            if(CheckRecursive.runOnce()){
                WorkScheduleTriggerHandler.afterInsertWorkSchedule(trigger.new);
            }
        }
        if(trigger.isUpdate){
            if(CheckRecursive.runOnce()){
                WorkScheduleTriggerHandler.afterUpdateWorkSchedule(trigger.newMap,trigger.oldMap);
            }
        }
    }*/
    
}
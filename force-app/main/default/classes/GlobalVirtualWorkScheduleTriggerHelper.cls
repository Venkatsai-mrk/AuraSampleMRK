global virtual class GlobalVirtualWorkScheduleTriggerHelper {
    
    global virtual void beforeInsert(List<ElixirSuite__Work_Schedule__c> workScheduleLst)
    {
        WorkScheduleTriggerHandler.dateValidations(workScheduleLst); 
        //WorkScheduleTriggerHandler.dateFieldUpdate(workScheduleLst);
        WorkScheduleTriggerHandler.workScheduleduplicate(workScheduleLst);
        WorkScheduleTriggerHandler.checkLocation(workScheduleLst);
        //WorkScheduleTriggerHandler.beforeInsertOrUpdateDateTimeConversion(workScheduleLst);
    }

    global virtual void afterDelete(List<ElixirSuite__Work_Schedule__c> workScheduleLst,Map<Id,ElixirSuite__Work_Schedule__c> oldWorkScheduleMap)
    {
        WorkScheduleTriggerHandler.calculateNextAvailSlot(workScheduleLst,oldWorkScheduleMap);
    }
    
    global virtual void beforeUpdate(List<ElixirSuite__Work_Schedule__c> workScheduleLst)
    {
        WorkScheduleTriggerHandler.dateValidations(workScheduleLst);
        WorkScheduleTriggerHandler.workScheduleduplicateupdate(workScheduleLst);
        WorkScheduleTriggerHandler.checkLocation(workScheduleLst);
        //WorkScheduleTriggerHandler.dateFieldUpdate(workScheduleLst);
        //WorkScheduleTriggerHandler.beforeInsertOrUpdateDateTimeConversion(workScheduleLst);
    }
    global virtual void afterInsert(List<ElixirSuite__Work_Schedule__c> workScheduleLst)
    {                  
        Map<Id,Work_Schedule__c> oldWorkScheduleMap = new Map<Id,Work_Schedule__c>();
        WorkScheduleTriggerHandler.calculateNextAvailSlot(workScheduleLst,oldWorkScheduleMap);
        if(CheckRecursive.runOnce()){
            //WorkScheduleTriggerHandler.afterInsertWorkSchedule(workScheduleLst);
        }
    }
    global virtual void afterUpdate(Map<Id,ElixirSuite__Work_Schedule__c> newWorkScheduleMap, Map<Id,ElixirSuite__Work_Schedule__c> oldWorkScheduleMap)
    {
        WorkScheduleTriggerHandler.calculateNextAvailSlot(newWorkScheduleMap.values(),oldWorkScheduleMap);
        if(CheckRecursive.runOnce()){
            //WorkScheduleTriggerHandler.afterUpdateWorkSchedule(newWorkScheduleMap,newWorkScheduleMap);
        }
    }
	
}
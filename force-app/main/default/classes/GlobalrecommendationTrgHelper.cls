global with sharing virtual class GlobalrecommendationTrgHelper {
    global virtual void afterUpdate(Map<id,ElixirSuite__Recommendation__c> newMapRecommendLst,Map<id,ElixirSuite__Recommendation__c> oldMapRecommendLst){
        recommendationTriggerHelper.updateTaskOwner(newMapRecommendLst,oldMapRecommendLst);
    }
    global virtual void afterInsert(Map<id,ElixirSuite__Recommendation__c> newMapRecords){
        recommendationTriggerHelper.createTask(newMapRecords);

    }
}
Global with sharing virtual class GlobalmasterObjectTriggerHelper {
    global virtual void afterInsert(List<ElixirSuite__Master_Object__c> masterRecords){
        masterObjectTriggerHelper.createRecommendationsAndTasks(masterRecords);
    }
}
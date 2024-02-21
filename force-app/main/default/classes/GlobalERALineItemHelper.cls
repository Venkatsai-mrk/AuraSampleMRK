Global with sharing virtual class GlobalERALineItemHelper {
    global virtual void afterInsert(List<ElixirSuite__ERA_Line_Item__c> eraItems){
        ERALineItemTriggerHelper.createRecommendations(eraItems);

    }
    global virtual void afterUpdate(List<ElixirSuite__ERA_Line_Item__c> eraItemRecords,Map<Id,ElixirSuite__ERA_Line_Item__c> oldEraItemRecords){
        ERALineItemTriggerHelper.createRecOnUpdateERALineItem(eraItemRecords,oldEraItemRecords);
    }
}
Global with sharing virtual class GlobalLocationTrigger {
	global virtual void beforeUpdate(List<ElixirSuite__Location__c> locRecords, Map<Id,ElixirSuite__Location__c> oldLocRecords ){
        LocationTriggerHelper.checkOutOfOrder(locRecords, oldLocRecords);
        
    }
}
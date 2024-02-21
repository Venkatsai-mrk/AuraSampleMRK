global virtual class GlobalVirtualERATriggerHelper {
	 global virtual void afterInsert(List<ElixirSuite__EOB__c> newEraLst){
        ERATriggerHandler.updateReconciliationStatus(newEraLst);

    }
    global virtual void afterUpdate(List<ElixirSuite__EOB__c> newEralst)
    { 
        ERATriggerHandler.updateReconciliationStatus(newEralst);
    }
}
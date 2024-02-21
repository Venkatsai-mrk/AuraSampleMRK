global with sharing virtual class GlobalVirtualClaimTriggerHelper {
    
    global virtual void beforeUpdate(List<ElixirSuite__Claim__c> newClaimLst, Map<Id,ElixirSuite__Claim__c> oldClaimMap)
    { 
        ClaimTriggerHandler.updateReconciliationStatus(newClaimLst,oldClaimMap);
        if(StopRecursion.claimUpdate){
            ClaimTriggerHandler.updateAmountStatus(newClaimLst);
        }
        
    }

}
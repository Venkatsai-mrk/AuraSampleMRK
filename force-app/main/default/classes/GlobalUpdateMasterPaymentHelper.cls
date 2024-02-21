Global with sharing virtual class GlobalUpdateMasterPaymentHelper {
    global virtual void afterUpdate(List<ElixirSuite__Payment_Schedule__c> currentPaymentLst , map<id,ElixirSuite__Payment_Schedule__c> oldValueLst){
        updateRelatedMasterSchedule.updateMasterPaymentSchedule(currentPaymentLst , oldValueLst);
    }
}
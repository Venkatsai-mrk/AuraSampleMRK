global with sharing virtual class ManualLabOrderTriggerHandler {
    global virtual void afterInsert(List<ElixirSuite__UA_Sample_Details__c> manualLabOrderList){
       // ManualLabOrderTriggerHelper.createPatientProcedureOnInsert(manualLabOrderList);
    }
    global virtual void afterUpdate(List<ElixirSuite__UA_Sample_Details__c> manualLabOrderList, Map<Id,ElixirSuite__UA_Sample_Details__c> manualLabOrderOldMap){
       // ManualLabOrderTriggerHelper.createPatientProcedureOnUpdate(manualLabOrderList,manualLabOrderOldMap);
    }
    
}
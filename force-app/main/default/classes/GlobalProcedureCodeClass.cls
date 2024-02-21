Global with sharing virtual class GlobalProcedureCodeClass {
    global virtual void afterInsert(List<ElixirSuite__Inventory__c> lstInventoryRecords){
        ProcedureCodeClass.insertProcedureCode(lstInventoryRecords);
    }
}
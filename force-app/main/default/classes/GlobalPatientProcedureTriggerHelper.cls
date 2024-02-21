global virtual class GlobalPatientProcedureTriggerHelper {
    
    global virtual void beforeInsert(List<Procedure__c> procedureLst)
    {
            CreatePaymentTransaction.updateCharges(procedureLst,null,true, false);
    }
    global virtual void beforeUpdate(List<Procedure__c> procedureLst, Map<Id, Procedure__c> oldProcedureMap)
    {
            CreatePaymentTransaction.updateCharges(procedureLst,oldProcedureMap,false, true);
    }
    global virtual void afterInsert(List<Procedure__c> procedureLst)
    {
        CreatePaymentTransaction.afterProcedureInsertCharges(procedureLst);
    }
    global virtual void afterUpdate(List<Procedure__c> procedureLst)
    {
        CreatePaymentTransaction.afterProcedureupdation(procedureLst);
    }
}
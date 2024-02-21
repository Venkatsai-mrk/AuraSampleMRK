Global with sharing virtual class GlobalTestComponentTrigger {
    
    global virtual void beforeInsert(List<ElixirSuite__Test_Component__c> testComponentLst)
    {
        TestComponentTriggerHelper.beforeInsertValidations(testComponentLst);
        }
     global virtual void beforeUpdate(List<ElixirSuite__Test_Component__c> testComponentLst, Map<id,ElixirSuite__Test_Component__c> oldtestComponentMap)
    {
        TestComponentTriggerHelper.beforeInsertValidations(testComponentLst);
    }

}
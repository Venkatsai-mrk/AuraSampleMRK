global  with sharing virtual class GlobalActualPriceTrigger {
   global virtual void beforeInsert(List <ElixirSuite__Actual_Price__c> actualList){
    ActualPriceTriggerHelper.actualPriceDuplicateCombo(actualList);

   }
   global virtual void beforeUpdate(List <ElixirSuite__Actual_Price__c> listActual){
    ActualPriceTriggerHelper.actualPriceDuplicateComboUpdate(listActual);

    
   }
}
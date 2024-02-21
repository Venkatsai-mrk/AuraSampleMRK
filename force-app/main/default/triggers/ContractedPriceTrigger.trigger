trigger ContractedPriceTrigger on Contracted_Price__c (Before insert,before update) {
    if(System.FeatureManagement.checkPermission('DataMigration')) return;  //LX3-6835 - Bypass the trigger execution during data migration
    if(trigger.isInsert  && trigger.isBefore){
        ContractedPriceTriggerHelper.contractedPriceDuplicateCombo(trigger.new);
    }
    if( trigger.isUpdate && trigger.isBefore){
        ContractedPriceTriggerHelper.contractedPriceDuplicateComboUpdate(trigger.new);
    }
    
}
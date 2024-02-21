public with sharing virtual class GlobalPaymentInformationHelper {
    
    public virtual void afterInsert(List<ElixirSuite__Payment_Information__c> newPaymentInfList){
        PaymentInformationTriggerHelper.afterInsert(newPaymentInfList);
    }
    public virtual void afterUpdate(List<ElixirSuite__Payment_Information__c> newPaymentInfList){
        PaymentInformationTriggerHelper.afterUpdate(newPaymentInfList);
    }

}
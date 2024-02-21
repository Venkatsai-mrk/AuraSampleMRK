trigger PaymentInformationTrigger on ElixirSuite__Payment_Information__c (after insert, after update) {
    
    String virtualClassName = 'GlobalPaymentInformationHelper';
    List<Elixir_Pluggable_Classes__mdt> pluggableClass = new List<Elixir_Pluggable_Classes__mdt>();
    if(
        Elixir_Pluggable_Classes__mdt.SObjectType.getDescribe().isAccessible() &&
        Schema.SObjectType.Elixir_Pluggable_Classes__mdt.fields.DeveloperName.isAccessible() &&
        Schema.SObjectType.Elixir_Pluggable_Classes__mdt.fields.Virtual_Class__c.isAccessible()
    ) {
    pluggableClass = [SELECT
                      DeveloperName,
                      Virtual_Class__c
                      FROM Elixir_Pluggable_Classes__mdt
                      WHERE DeveloperName='PaymentInformationTrigger'];
    }
    if(!pluggableClass.isEmpty()){
        virtualClassName = pluggableClass[0].Virtual_Class__c;
    }
    Type t = Type.forName(virtualClassName);
    GlobalPaymentInformationHelper paymentInformationHelper = (GlobalPaymentInformationHelper) t.newInstance();
    
    if(trigger.isAfter && trigger.isInsert){
        paymentInformationHelper.afterInsert(Trigger.new);
    }
    
    
    if(trigger.isAfter && trigger.isUpdate){
        paymentInformationHelper.afterUpdate(Trigger.new);
    }

}
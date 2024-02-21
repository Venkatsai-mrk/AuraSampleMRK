//Prachi
trigger LeadTrigger on Lead (before update, after update) {
    if(System.FeatureManagement.checkPermission('DataMigration')) return; //LX3-6835 - Bypass the trigger execution during data migration
    if(trigger.isAfter && trigger.isUpdate){
        /*new LeadTriggerHelper().OpportunityFromLead(trigger.new);      
        LeadConversionHelper.convertLead(trigger.new);
        LeadConversionHelper.changeAccountName(trigger.new);
        LeadConversionHelper.fieldUpdateAfterLeadConversion(trigger.new);*/
    } 
    String virtualClassName = 'GlobalLeadTrigger';// Added in Review
    List<Elixir_Pluggable_Classes__mdt> pluggableClass = new List<Elixir_Pluggable_Classes__mdt>();
    pluggableClass = [SELECT
                    DeveloperName,
                    Virtual_Class__c
                    FROM Elixir_Pluggable_Classes__mdt
                    WHERE DeveloperName='LeadTrigger'
                    WITH SECURITY_ENFORCED];
    if(!pluggableClass.isEmpty()){
        virtualClassName = pluggableClass[0].Virtual_Class__c;
    }
    Type t = Type.forName(virtualClassName);
    GlobalLeadTrigger leadTrigger = (GlobalLeadTrigger) t.newInstance(); 
    
    
    if(trigger.isAfter && trigger.isUpdate){ 
        leadTrigger.afterUpdate(trigger.new);
    }
}
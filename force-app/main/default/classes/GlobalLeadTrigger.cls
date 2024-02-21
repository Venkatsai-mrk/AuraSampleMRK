Global with sharing virtual class GlobalLeadTrigger {
    global virtual void afterUpdate(List<Lead> leadsRecords){
        new LeadTriggerHelper().OpportunityFromLead(leadsRecords);      
        LeadConversionHelper.convertLead(leadsRecords);
        LeadConversionHelper.changeAccountName(leadsRecords);
        //LeadConversionHelper.fieldUpdateAfterLeadConversion(leadsRecords);
    } 
}
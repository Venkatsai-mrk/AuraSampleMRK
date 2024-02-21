global with sharing virtual class GlobalopportunityRefTrigger {
    Elixir_Custom_Setting__c record = Elixir_Custom_Setting__c.getOrgDefaults();
    global virtual void beforeModification(Opportunity[] oppLstRecords) {
        if(record.ElixirSuite__Patient_Deceased__c){ // WORKFLOW DECEASED
            Boolean wasRun =  OpportunityTriggerHelper.preventEditIfDeceasedCheckedOnAccount(oppLstRecords);
            OpportunityTriggerHelper.stopDeceasedEdit(oppLstRecords,wasRun);

        }
 }
 global virtual void beforeDelete(List<Opportunity> opportunityLst ) {
    if(record.ElixirSuite__Patient_Deceased__c){ // WORKFLOW DECEASED
        OpportunityTriggerHelper.blockDeleteIfDeceased(opportunityLst);

    }
}
global virtual void beforeInsert(List<Opportunity> newOppLst) {
    if(record.ElixirSuite__Patient_Deceased__c){ // WORKFLOW DECEASED
        new OpportunityTriggerHelper().stageDateTime(newOppLst);
    }
    beforeModification(newOppLst);
}
global virtual void beforeUpdate(List<Opportunity> oldOppLstRecords, List<Opportunity> newOppLstRecords) {
    if(record.ElixirSuite__Patient_Deceased__c){ // WORKFLOW DECEASED
        new OpportunityTriggerHelper().stopLocationUpdate(new Map<Id,Opportunity>(oldOppLstRecords), newOppLstRecords);
        new OpportunityTriggerHelper().stageDateTime(new Map<Id,Opportunity>(oldOppLstRecords), newOppLstRecords);
    }
    beforeModification(newOppLstRecords);  
    }
}
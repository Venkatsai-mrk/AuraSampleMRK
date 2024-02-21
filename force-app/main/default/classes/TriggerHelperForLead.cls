public with sharing class TriggerHelperForLead{
    
    public static void updatePhoneOnOpp(List<Opportunity> opps, Map<id, Lead> oppIdLeadMap){
        try{
        for(Opportunity op : opps){
            Lead l = oppIdLeadMap.get(op.id);
            op.phone__c = l.Phone;//set phone number of opportunity from lead
            op.Location__c = l.City;
        }
        DMLManager.updateAsUser(opps);// after updating phone opportunity it will be updated on account
    }
        catch(Exception e){
        ExceptionLog.logError(e);
        }
    }
    
}
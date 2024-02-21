public with sharing class ProviderTriggerHelper {
    public static void evaluateOpportunityLocation(Set<Id> accountIds) {
        List<Account> accounts = [SELECT Id,(SELECT Id, Name FROM Providers__r ORDER BY CreatedDate DESC LIMIT 1) 
                                    FROM Account WHERE Id IN :accountIds WITH SECURITY_ENFORCED];
        Map<Id,Account> providers = new Map<Id,Account>(accounts);
        List<Account> opportunities = [SELECT Id,(SELECT Id,AccountId,StageName,Location__c FROM Opportunities 
                                    WHERE StageName!='Closed Lost' ORDER BY CreatedDate DESC LIMIT 200)
                                    FROM Account WHERE Id IN :accountIds  WITH SECURITY_ENFORCED];
        List<Opportunity> oppToUpdate = new List<Opportunity>();
        try{
        for(Account oppo :opportunities){
            Id accountId = oppo.Id;
            if(providers.containsKey(accountId)){
                Account acc = providers.get(accountId);
                List<Provider__c> relatedProviders = acc.Providers__r;
                if(relatedProviders!=null && relatedProviders.size()>0){
                    String location = relatedProviders[0].Name;
                    for(Opportunity opportunityToUpdate :oppo.Opportunities){
                        opportunityToUpdate.Location__c = location;
                        oppToUpdate.add(opportunityToUpdate);
                        system.debug(opportunityToUpdate.Location__c);
                    }
                }else{
                    for(Opportunity opportunityToUpdate :oppo.Opportunities){
                        opportunityToUpdate.Location__c = '';
                        oppToUpdate.add(opportunityToUpdate);
                        system.debug(opportunityToUpdate.Location__c);
                    }
                }
            }
        }
        if(oppToUpdate!=null && oppToUpdate.size()>0 &&
        Schema.sObjectType.Opportunity.isUpdateable() &&
        Schema.sObjectType.Opportunity.fields.Location__c.isUpdateable()){
            StopRecursion.stopLocationUpdation = false;
            update oppToUpdate;
        }
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
    }
    public static void populateProviders(List<Provider__c> providers){
        Map<String,Id> npiMap = new Map<String,Id>();
        Set<String> npi = new Set<String>();
        try{
        for(Provider__c provider :providers){
            if(provider.Patient_Provider__c && String.isNotBlank(provider.Provider_Code__c)){
                npi.add(provider.Provider_Code__c);
            }
        }
        if(npi!=null && npi.size()>0){
            List<Provider__c> templateProviders = [SELECT Id,Provider_Code__c FROM Provider__c 
                                                WHERE Provider_Code__c IN :npi AND Account__c=NULL WITH SECURITY_ENFORCED LIMIT 999];
            if(templateProviders!=null && templateProviders.size()>0){
                for(Provider__c templateProvider :templateProviders){
                    npiMap.put(templateProvider.Provider_Code__c, templateProvider.Id);
                }
            }
        }
        if(npiMap!=null && npiMap.size()>0){
            for(Provider__c provider :providers){
                    if(provider.Patient_Provider__c && String.isNotBlank(provider.Provider_Code__c)){
                    String billId = provider.Provider_Code__c;
                    if(npiMap.containsKey(billId)){
                        provider.Provider__c = npiMap.get(billId);
                    }
                }
            }
        }
    }
     catch(Exception e){
     ExceptionLog.logError(e);
        }
    }
}
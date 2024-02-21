global virtual class GlobalVirtualProviderTriggerHelper {
    Set<Id> accountIds = new Set<Id>();
    
    global virtual void beforeInsert(List<Provider__c> providerLst){
        ProviderTriggerHelper.populateProviders(providerLst);
    }
    global virtual void beforeUpdate(List<Provider__c> providerLst){
        ProviderTriggerHelper.populateProviders(providerLst);
    }
    global virtual void afterInsert(List<Provider__c> providerLst){
        /* for(Provider__c provider :providerLst){
            accountIds.add(provider.Account__c);
        }
        system.enqueueJob(new ProviderPermissionHelper(providerLst));*/
    }
    global virtual void afterUpdate(List<Provider__c> providerLst){
        /*  for(Provider__c provider :providerLst){
            accountIds.add(provider.Account__c);
        }
        system.enqueueJob(new ProviderPermissionHelper(providerLst));*/
    }
    global virtual void afterDelete(List<Provider__c> oldProviderLst){
        /* for(Provider__c provider :oldProviderLst){
                accountIds.add(provider.Account__c);
            }
        system.enqueueJob(new ProviderPermissionDeletion(oldProviderLst));*/
    }
    
    
}
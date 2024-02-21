public without sharing class SharingRuleBatchableAccountProviders implements Database.Batchable<sObject>, Database.Stateful{
    public Map<Id,List<Id>> userAllLocationsAccess = new Map<Id,List<Id>>();
    public SharingRuleBatchableAccountProviders(Map<Id,List<Id>> userAllLocationsAccess) {
        this.userAllLocationsAccess = userAllLocationsAccess;
    }
    public Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id,(SELECT Id,Provider__c FROM Providers__r) FROM Account';
        return Database.getQueryLocator(query);
    }
   public void execute(Database.BatchableContext BC, List<sObject> scope){
       List<Account> accounts = (List<Account>) scope;
       Map<Id,Account> accountMap = new Map<Id,Account>(accounts);
       Set<Id> accountIds = accountMap.keySet();
       List<AccountShare> sharedAccounts = [SELECT Id,AccountId, UserOrGroupId FROM AccountShare 
                                            WHERE AccountId IN :accountIds AND RowCause='Manual'];
       Set<Id> sharedRecordToDel = new Set<Id>(); 
       for(AccountShare sharedAccount :sharedAccounts){
            Id userId = sharedAccount.UserOrGroupId;
            Id accountId = sharedAccount.AccountId;
            if(userAllLocationsAccess.containsKey(userId)){
            List<Id> userPermittedLocations = userAllLocationsAccess.get(userId);
                if(accountMap.containsKey(accountId)){
                    List<Provider__c> relatedProviders = accountMap.get(accountId).Providers__r;
                    Boolean found = false;
                    for(Provider__c provider :relatedProviders){
                        Id providerId = provider.Provider__c;
                        if(userPermittedLocations.contains(providerId)){
                            found = true;
                        }
                    }
                    if(!found){
                        sharedRecordToDel.add(sharedAccount.Id);
                    }
                }
            }
       }
       if(sharedRecordToDel!=null && sharedRecordToDel.size()>0){
            List<AccountShare> records = [SELECT Id FROM AccountShare WHERE Id IN :sharedRecordToDel 
                                            AND RowCause='Manual'
                                            WITH SECURITY_ENFORCED
                                            LIMIT 10000];
            if(Schema.sObjectType.AccountShare.isDeletable()){                                
            delete records;
            }
       }
    }
    public void finish(Database.BatchableContext BC){
        Database.executeBatch(new SharingRuleBatchableVOBDelete(userAllLocationsAccess),2000);
    }
}
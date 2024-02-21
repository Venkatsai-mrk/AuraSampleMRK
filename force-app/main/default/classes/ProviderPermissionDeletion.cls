public without sharing class ProviderPermissionDeletion implements Queueable{
    public void execute(QueueableContext context) {}
    public static void dummyMethod(){}
   /* List<Provider__c> newAccountsToPermit = new List<Provider__c>();
    public ProviderPermissionDeletion(List<Provider__c> newAccountsToPermit){
        this.newAccountsToPermit = newAccountsToPermit;
    }
    public void execute(QueueableContext context) {
        Set<Id> accountIds = new Set<Id>();
        Set<Id> allProviders = new Set<Id>();
        try{
        for(Provider__c provider :newAccountsToPermit){
            if(String.isNotBlank(provider.Provider__c)){
                allProviders.add(provider.Provider__c);
            }
            accountIds.add(provider.Account__c);
        }
        if(accountIds.size()==0){
            return;
        }
        List<UserLocation__c> userLocations = [SELECT Id, User__c, Provider__c FROM UserLocation__c
                                                WHERE Provider__c IN :allProviders 
                                                WITH SECURITY_ENFORCED LIMIT 10000];
        Set<Id> impactedUsers = new Set<Id>();
        for(UserLocation__c userLocation :userLocations){
            impactedUsers.add(userLocation.User__c);
        }
        Map<Id,List<Id>> userAllLocationsAccess = new Map<Id,List<Id>>();
        List<UserLocation__c> impactedUsersAllLocations = [SELECT Id, User__c,Provider__c FROM UserLocation__c 
                                            WHERE User__c IN :impactedUsers WITH SECURITY_ENFORCED
                                            LIMIT 20000];

        for(UserLocation__c userLocation :impactedUsersAllLocations){
            if(userAllLocationsAccess.containsKey(userLocation.User__c)){
                userAllLocationsAccess.get(userLocation.User__c).add(userLocation.Provider__c);
            }else{
                userAllLocationsAccess.put(userLocation.User__c, new List<Id> {userLocation.Provider__c});
            }
        }

        Set<Id> usersId = new Set<Id>();
        usersId = userAllLocationsAccess.keySet();

        Map<Id,List<Id>> accountProviders = new Map<Id,List<Id>>();
        for(Account acc :[SELECT Id,(SELECT Id,Provider__c FROM Providers__r) FROM Account WHERE Id IN :accountIds]){
         accountProviders.put(acc.Id,new List<Id>{});
             for(Provider__c provider :acc.Providers__r){
                 accountProviders.get(acc.Id).add(provider.provider__c);
             }
        }
        Set<Id> recordsToDel = new Set<Id>();
        for(AccountShare sharedRecord :[SELECT Id,AccountId, UserOrGroupId FROM AccountShare WHERE AccountId IN :accountIds
                                        AND Rowcause='Manual']){
            Id userId = sharedRecord.UserOrGroupId;
            Id accountId = sharedRecord.AccountId;
            if(accountProviders.containsKey(accountId)){
                List<Id> providers = accountProviders.get(accountId);
                List<Id> permittedProviders = userAllLocationsAccess.get(userId);
                Boolean found = false;
                if(permittedProviders==null){
                    found = false;
                }else{
                    for(Id permittedProvider :permittedProviders){
                        if(providers.contains(permittedProvider)){
                            found = true;
                            break;
                        }
                    }
                }
                if(!found){
                    recordsToDel.add(sharedRecord.Id);
                }
            }
        }
        if(recordsToDel!=null && recordsToDel.size()>0){
            DeleteSharedRecord.delRecords(recordsToDel);
        }
    }
    catch(Exception e){
    ExceptionLog.logError(e);
        }
    }*/
 }
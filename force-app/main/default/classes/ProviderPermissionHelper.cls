public without sharing class ProviderPermissionHelper implements Queueable{
    public void execute(QueueableContext context) {}
    public static void dummyMethod(){}
    /*List<Provider__c> newAccountsToPermit = new List<Provider__c>();
    public ProviderPermissionHelper(List<Provider__c> newAccountsToPermit){
        this.newAccountsToPermit = newAccountsToPermit;
    }
    public void execute(QueueableContext context) {
        Set<Id> accountIds = new Set<Id>();
        Set<Id> allProviders = new Set<Id>();
        for(Provider__c provider :newAccountsToPermit){
            if(String.isNotBlank(provider.Provider__c)){
                allProviders.add(provider.Provider__c);
            }
            accountIds.add(provider.Account__c);
        }
        system.debug(allProviders);                                    
        system.debug(accountIds);                                    
        if(accountIds.size()==0){
            return;
        }
        List<UserLocation__c> userLocations = [SELECT Id, User__c, Provider__c FROM UserLocation__c
                                                WHERE Provider__c IN :allProviders 
                                                WITH SECURITY_ENFORCED
                                                LIMIT 10000];
        system.debug(userLocations);                                    
        Set<Id> impactedUsers = new Set<Id>();
        for(UserLocation__c userLocation :userLocations){
            impactedUsers.add(userLocation.User__c);
        }
        Map<Id,List<Id>> userAllLocationsAccess = new Map<Id,List<Id>>();
        List<UserLocation__c> impactedUsersAllLocations = [SELECT Id, User__c,Provider__c FROM UserLocation__c 
                                            WHERE User__c IN :impactedUsers 
                                            WITH SECURITY_ENFORCED
                                            LIMIT 20000];

        for(UserLocation__c userLocation :impactedUsersAllLocations){
            if(userAllLocationsAccess.containsKey(userLocation.User__c)){
                userAllLocationsAccess.get(userLocation.User__c).add(userLocation.Provider__c);
            }else{
                userAllLocationsAccess.put(userLocation.User__c, new List<Id> {userLocation.Provider__c});
            }
        }
        system.debug(userAllLocationsAccess);                                    
        Set<Id> usersId = new Set<Id>();
        usersId = userAllLocationsAccess.keySet();
        List<AccountShare> newRecords = new List<AccountShare>();
        try{
        for(Account acc :[SELECT Id,(SELECT Id,Provider__c FROM Providers__r) FROM Account 
        WHERE Id IN :accountIds WITH SECURITY_ENFORCED]){
            for(Id userId :usersId){
                for(Provider__c provider :acc.Providers__r){
                    Id providerId = provider.Provider__c;
                    List<Id> allowedProviders = userAllLocationsAccess.get(userId);
                    if(allowedProviders.contains(providerId)){
                        AccountShare accountShare = new AccountShare();
                        accountShare.AccountId = acc.Id;
                        accountShare.UserOrGroupId = userId;
                        accountShare.RowCause = Schema.AccountShare.RowCause.Manual;
                        accountShare.AccountAccessLevel = 'Edit';
                        accountShare.OpportunityAccessLevel = 'Edit';
                        newRecords.add(accountShare);
                        system.debug(acc.Id);                                    
                        break;
                    }
                }
            }
        }
        if(newRecords!=null && newRecords.size()>0){
            insert newRecords;
        }
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
    }*/
}
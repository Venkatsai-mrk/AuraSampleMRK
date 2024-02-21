public with sharing class UserProviderInsertBatch implements Queueable{
    public List<UserLocation__c> locations = new List<UserLocation__c>();
    public UserProviderInsertBatch(List<UserLocation__c> locations) {
        this.locations = locations;
    }
    public void execute(QueueableContext context) {
        List<Provider__Share> providerShares = new List<Provider__Share>();
        for(UserLocation__c userLocation :locations) {
            Id userId = userLocation.User__c;
            Id locationId = userLocation.Provider__c;
            system.debug(locationId);
            Provider__Share providerShare = new Provider__Share(
                UserOrGroupId = userId,
                ParentId = locationId,
                RowCause = Schema.AccountShare.RowCause.Manual,
                AccessLevel = 'Edit'
            );
            providerShares.add(providerShare);
        }
        Database.insert(providerShares,false);
    }
}
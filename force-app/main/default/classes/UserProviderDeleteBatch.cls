public with sharing class UserProviderDeleteBatch implements Queueable{
    public List<UserLocation__c> locations = new List<UserLocation__c>();
    public Map<String,List<Id>> userToLocations = new Map<String,List<Id>>();
    public UserProviderDeleteBatch(List<UserLocation__c> locations) {
        this.locations = locations;
    }
    public void execute(QueueableContext context) {
        Set<Id> userIds = new Set<Id>();
        Set<Id> locationIds = new Set<Id>();
        if(locations==null){
            return;
        }
        for(UserLocation__c userLocation :locations) {
            Id userId = userLocation.User__c;
            Id locationId = userLocation.Provider__c;
            if(userToLocations.containsKey(userId)){
                userToLocations.get(userId).add(locationId);
            }else{
                userToLocations.put(userId, new List<String>{locationId});
            }
            userIds.add(userId);
            locationIds.add(locationId);
        }
        List<Provider__Share> recordsToDel = new List<Provider__Share>();
        List<Provider__Share> sharedProviders = [SELECT Id, UserOrGroupId,ParentId FROM Provider__Share
                                                WHERE RowCause='Manual' AND UserOrGroupId IN :userIds AND ParentId IN :locationIds];
        if(sharedProviders!=null && sharedProviders.size()>0){
            for(Provider__Share providerShare :sharedProviders){
                Id userId = providerShare.UserOrGroupId;
                Id locationId = providerShare.ParentId;
                if(userToLocations.containsKey(userId)){
                    List<String> locations = userToLocations.get(userId);
                    if(locations.contains(locationId)){
                        recordsToDel.add(providerShare);
                    }
                }
            }
        }
        if(recordsToDel!=null && recordsToDel.size()>0){
            delete recordsToDel;
        }
    }
}
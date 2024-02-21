public without sharing class UserLocationInsertBatch implements Queueable{
    public List<UserLocation__c> locations = new List<UserLocation__c>();
    public String action;
    public UserLocationInsertBatch(List<UserLocation__c> locations, String action) {
        this.locations = locations;
        this.action = action;
    }
   public void execute(QueueableContext context) {
       if(locations==null){
        return;
       }
       Set<Id> userIds = new Set<Id>();
       Set<Id> locationIds = new Set<Id>();
       Map<Id, List<Id>> userToLocations = new  Map<Id, List<Id>>();
       for(UserLocation__c userLocation :locations) {
           Id userId = userLocation.User__c;
           Id locationId = userLocation.Provider__c;
            userIds.add(userId);
            locationIds.add(locationId);
       }
       system.debug(action);
       system.debug(userIds);
        Map<Id,List<Id>> userAllLocationsAccess = new Map<Id,List<Id>>();
        List<UserLocation__c> userLocations = [SELECT Id, User__c,Provider__c FROM UserLocation__c 
                                            WHERE User__c IN :userIds
                                            WITH SECURITY_ENFORCED
                                            LIMIT 49000];
        //Creating Map of User vs Access to All Locations
        for(UserLocation__c userLocation :userLocations){
            if(userAllLocationsAccess.containsKey(userLocation.User__c)){
                userAllLocationsAccess.get(userLocation.User__c).add(userLocation.Provider__c);
            }else{
                userAllLocationsAccess.put(userLocation.User__c, new List<Id> {userLocation.Provider__c});
            }
        }
        system.debug(action);
        if(action == 'INSERT'){
            Database.executeBatch(new SharingRuleBatchableAccountInsert(userAllLocationsAccess), 2000);
        }else if(action == 'DELETE'){
            Database.executeBatch(new SharingRuleBatchableAccountProviders(userAllLocationsAccess), 2000);
        }
    }
}
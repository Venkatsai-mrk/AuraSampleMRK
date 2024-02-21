public with sharing class UserLocationHelper {
    public static void filterLocationsNew(List<UserLocation__c> locations) {
        System.enqueueJob(new UserLocationInsertBatch(locations,'INSERT'));
    }
    public static void filterLocationsOld(List<UserLocation__c> locations) {
        System.enqueueJob(new UserLocationInsertBatch(locations,'DELETE'));
    }
    public static void filterProviderAccessNew(List<UserLocation__c> locations) {
        System.enqueueJob(new UserProviderInsertBatch(locations));
    }
    public static void filterProviderAccessOld(List<UserLocation__c> locations) {
        System.enqueueJob(new UserProviderDeleteBatch(locations));
    }
}
//Commented
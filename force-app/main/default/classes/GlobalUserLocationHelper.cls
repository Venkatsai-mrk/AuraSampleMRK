Global with sharing virtual class GlobalUserLocationHelper {
    global virtual void afterInsert(List<UserLocation__c> locationLst){
        UserLocationHelper.filterLocationsNew(locationLst);
        UserLocationHelper.filterProviderAccessNew(locationLst);

    }
    global virtual void afterDelete(List<UserLocation__c> locationsLstRecords){
        UserLocationHelper.filterLocationsOld(locationsLstRecords);
        UserLocationHelper.filterProviderAccessOld(locationsLstRecords);

    }
}
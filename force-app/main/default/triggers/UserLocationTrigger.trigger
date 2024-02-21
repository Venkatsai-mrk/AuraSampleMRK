trigger UserLocationTrigger on UserLocation__c (after insert, after delete) {
    if(System.FeatureManagement.checkPermission('DataMigration')) return;  //LX3-6835 - Bypass the trigger execution during data migration
   /* if(trigger.isInsert){
        UserLocationHelper.filterLocationsNew(trigger.new);
        UserLocationHelper.filterProviderAccessNew(trigger.new);
    }
    if(trigger.isDelete){
        UserLocationHelper.filterLocationsOld(trigger.old);
        UserLocationHelper.filterProviderAccessOld(trigger.old);
    }*/
    String virtualClassName = 'GlobalUserLocationHelper';// Added in Review
    List<Elixir_Pluggable_Classes__mdt> pluggableClass = new List<Elixir_Pluggable_Classes__mdt>();
    pluggableClass = [SELECT
                    DeveloperName,
                    Virtual_Class__c
                    FROM Elixir_Pluggable_Classes__mdt
                    WHERE DeveloperName='UserLocationTrigger'
                    WITH SECURITY_ENFORCED];
    if(!pluggableClass.isEmpty()){
        virtualClassName = pluggableClass[0].Virtual_Class__c;
    }
    Type t = Type.forName(virtualClassName);
    GlobalUserLocationHelper userLocation = (GlobalUserLocationHelper) t.newInstance(); 
    
    if(trigger.isAfter && trigger.isInsert){ 
        userLocation.afterInsert(trigger.new);
    }
    if(trigger.isAfter && trigger.isDelete){
        userLocation.afterDelete(trigger.old);
    }
}
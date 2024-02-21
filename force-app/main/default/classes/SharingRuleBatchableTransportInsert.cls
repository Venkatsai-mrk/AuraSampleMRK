public without sharing class SharingRuleBatchableTransportInsert implements Database.Batchable<sObject>, Database.Stateful{
    public Map<Id,List<Id>> userAllLocationsAccess = new Map<Id,List<Id>>();
    public SharingRuleBatchableTransportInsert(Map<Id,List<Id>> userAllLocationsAccess) {
        this.userAllLocationsAccess = userAllLocationsAccess;
    }
    public Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id, Patient_Name__r.Location_Text_Id__c FROM Transport__c WHERE Patient_Name__c!=NULL';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        List<Transport__c> transports = (List<Transport__c>) scope;
        Map<Id,Id> transportToActiveLocation = new Map<Id,Id>();
        for(Transport__c transport :transports){
            transportToActiveLocation.put(transport.Id,transport.Patient_Name__r.Location_Text_Id__c);
        }
        List<Transport__share> newRecords = new List<Transport__share>();
        for(Transport__c transport :transports){
            if(!transportToActiveLocation.containsKey(transport.Id)){
                continue;
            }
            Id transportActiveLocation = transportToActiveLocation.get(transport.Id);
            for(Id userId :userAllLocationsAccess.KeySet()){
                List<Id> userAccessibleLocations = userAllLocationsAccess.get(userId);
                if(userAccessibleLocations.contains(transportActiveLocation)){
                    Transport__share transportShare = new Transport__share();
                    transportShare.ParentId = transport.Id;
                    transportShare.UserOrGroupId = userId;
                    transportShare.RowCause = Schema.Transport__share.RowCause.Manual;
                    transportShare.AccessLevel = 'Edit';
                    system.debug('transportShare '+transportShare);
                    newRecords.add(transportShare);
                }
            }
        }
        if(newRecords.size()>0){
            Database.insert(newRecords,false);
        }
    }
    public void finish(Database.BatchableContext BC){
    }
}
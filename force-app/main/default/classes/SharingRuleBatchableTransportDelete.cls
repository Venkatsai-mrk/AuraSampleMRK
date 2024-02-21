public without sharing class SharingRuleBatchableTransportDelete implements Database.Batchable<sObject>, Database.Stateful{
    public Map<Id,List<Id>> userAllLocationsAccess = new Map<Id,List<Id>>();
    public SharingRuleBatchableTransportDelete(Map<Id,List<Id>> userAllLocationsAccess) {
        this.userAllLocationsAccess = userAllLocationsAccess;
    }
    public Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id, Patient_Name__r.Location_Text_Id__c FROM Transport__c WHERE Patient_Name__c!=NULL';
        return Database.getQueryLocator(query);
    }
   public void execute(Database.BatchableContext BC, List<sObject> scope){
       List<Transport__c> transports = (List<Transport__c>)scope;
       Map<Id,sObject> transportMap = new Map<Id,sObject>(scope);
       Set<Id> transportIds = transportMap.keySet();
       Map<Id,Id> transportToActiveLocation = new Map<Id,Id>();
       for(Transport__c transport :transports){
           transportToActiveLocation.put(transport.Id,transport.Patient_Name__r.Location_Text_Id__c);
       }
       List<Transport__Share> transportSharedRecords = [SELECT Id, ParentId, UserOrGroupId FROM Transport__Share 
        WHERE ParentId IN :transportIds AND RowCause='Manual'];
        List<Transport__Share> recordsToDel = new List<Transport__Share>();
        for(Transport__Share transportSharedRecord :transportSharedRecords){
            Id vobId = transportSharedRecord.ParentId;
            Id userId = transportSharedRecord.UserOrGroupId;
            Id activeLocation = transportToActiveLocation.get(vobId);
            if(userAllLocationsAccess.containsKey(userId)){
                List<Id> allowedLocations = userAllLocationsAccess.get(userId);
                if(!allowedLocations.contains(activeLocation)){
                    recordsToDel.add(transportSharedRecord);
                }
            }
        }
        if(recordsToDel.size()>0){
            delete recordsToDel;
        }
   }
   public void finish(Database.BatchableContext BC){
   }
}
public without sharing class SharingRuleBatchableVOBDelete implements Database.Batchable<sObject>, Database.Stateful{
    public Map<Id,List<Id>> userAllLocationsAccess = new Map<Id,List<Id>>();
    public SharingRuleBatchableVOBDelete(Map<Id,List<Id>> userAllLocationsAccess) {
        this.userAllLocationsAccess = userAllLocationsAccess;
    }
    public Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id, Opportunity__r.Location_Text_Id__c FROM VOB__c WHERE Opportunity__c!=NULL';
        return Database.getQueryLocator(query);
    }
   public void execute(Database.BatchableContext BC, List<sObject> scope){
       List<Vob__c> vobs = (List<Vob__c>)scope;
       Map<Id,sObject> vobMap = new Map<Id,sObject>(scope);
       Set<Id> vobIds = vobMap.keySet();
       Map<Id,Id> vobToActiveLocation = new Map<Id,Id>();
       for(Vob__c vob :vobs){
           vobToActiveLocation.put(vob.Id,vob.Opportunity__r.Location_Text_Id__c);
       }
       List<Vob__Share> vobSharedRecords = [SELECT Id, ParentId, UserOrGroupId FROM Vob__Share 
        WHERE ParentId IN :vobIds AND RowCause='Manual'];
        List<Vob__Share> recordsToDel = new List<Vob__Share>();
        for(Vob__Share vobSharedRecord :vobSharedRecords){
            Id vobId = vobSharedRecord.ParentId;
            Id userId = vobSharedRecord.UserOrGroupId;
            Id activeLocation = vobToActiveLocation.get(vobId);
            if(userAllLocationsAccess.containsKey(userId)){
                List<Id> allowedLocations = userAllLocationsAccess.get(userId);
                if(!allowedLocations.contains(activeLocation)){
                    recordsToDel.add(vobSharedRecord);
                }
            }
        }
        if(recordsToDel.size()>0){
            delete recordsToDel;
        }
   }
   public void finish(Database.BatchableContext BC){
    Database.executeBatch(new SharingRuleBatchablePreAssessmentDelete(userAllLocationsAccess),2000);
   }
}
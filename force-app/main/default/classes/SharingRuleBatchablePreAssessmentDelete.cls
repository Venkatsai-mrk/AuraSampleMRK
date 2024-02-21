public without sharing class SharingRuleBatchablePreAssessmentDelete implements Database.Batchable<sObject>, Database.Stateful{
    public Map<Id,List<Id>> userAllLocationsAccess = new Map<Id,List<Id>>();
    public SharingRuleBatchablePreAssessmentDelete(Map<Id,List<Id>> userAllLocationsAccess) {
        this.userAllLocationsAccess = userAllLocationsAccess;
    }
    public Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id, Opportunity__r.Location_Text_Id__c FROM Pre_Assessment__c WHERE Opportunity__c!=NULL';
        return Database.getQueryLocator(query);
    }
   public void execute(Database.BatchableContext BC, List<sObject> scope){
       List<Pre_Assessment__c> vobs = (List<Pre_Assessment__c>)scope;
       Map<Id,sObject> vobMap = new Map<Id,sObject>(scope);
       Set<Id> vobIds = vobMap.keySet();
       Map<Id,Id> assessToActiveLocation = new Map<Id,Id>();
       for(Pre_Assessment__c vob :vobs){
        assessToActiveLocation.put(vob.Id,vob.Opportunity__r.Location_Text_Id__c);
       }
       List<Pre_Assessment__share> vobSharedRecords = [SELECT Id, ParentId, UserOrGroupId FROM Pre_Assessment__share 
        WHERE ParentId IN :vobIds AND RowCause='Manual'];
        List<Pre_Assessment__share> recordsToDel = new List<Pre_Assessment__share>();
        for(Pre_Assessment__share vobSharedRecord :vobSharedRecords){
            Id vobId = vobSharedRecord.ParentId;
            Id userId = vobSharedRecord.UserOrGroupId;
            Id activeLocation = assessToActiveLocation.get(vobId);
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
    Database.executeBatch(new SharingRuleBatchableTransportDelete(userAllLocationsAccess), 2000);

   }
}
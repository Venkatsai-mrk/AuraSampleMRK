public without sharing class SharingRuleBatchablePreAssessmentInsert implements Database.Batchable<sObject>, Database.Stateful{
    public Map<Id,List<Id>> userAllLocationsAccess = new Map<Id,List<Id>>();
    public SharingRuleBatchablePreAssessmentInsert(Map<Id,List<Id>> userAllLocationsAccess) {
        this.userAllLocationsAccess = userAllLocationsAccess;
    }
    public Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id, Opportunity__r.Location_Text_Id__c FROM Pre_Assessment__c WHERE Opportunity__c!=NULL';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        List<Pre_Assessment__c> vobs = (List<Pre_Assessment__c>) scope;
        Map<Id,Id> assessToActiveLocation = new Map<Id,Id>();
        for(Pre_Assessment__c vob :vobs){
            assessToActiveLocation.put(vob.Id,vob.Opportunity__r.Location_Text_Id__c);
        }
        List<Pre_Assessment__share> newRecords = new List<Pre_Assessment__share>();
        for(Pre_Assessment__c vob :vobs){
            if(!assessToActiveLocation.containsKey(vob.Id)){
                continue;
            }
            Id vobActiveLocation = assessToActiveLocation.get(vob.Id);
            for(Id userId :userAllLocationsAccess.KeySet()){
                List<Id> userAccessibleLocations = userAllLocationsAccess.get(userId);
                if(userAccessibleLocations.contains(vobActiveLocation)){
                    Pre_Assessment__share vobShare = new Pre_Assessment__share();
                    vobShare.ParentId = vob.Id;
                    vobShare.UserOrGroupId = userId;
                    vobShare.RowCause = Schema.Pre_Assessment__share.RowCause.Manual;
                    vobShare.AccessLevel = 'Edit';
                    newRecords.add(vobShare);
                }
            }
        }
        if(newRecords.size()>0){
            Database.insert(newRecords,false);
        }
    }
    public void finish(Database.BatchableContext BC){
        Database.executeBatch(new SharingRuleBatchableTransportInsert(userAllLocationsAccess),2000);
    }
}
public without sharing class SharingRuleBatchableVOBInsert implements Database.Batchable<sObject>, Database.Stateful{
    public Map<Id,List<Id>> userAllLocationsAccess = new Map<Id,List<Id>>();
    public SharingRuleBatchableVOBInsert(Map<Id,List<Id>> userAllLocationsAccess) {
        this.userAllLocationsAccess = userAllLocationsAccess;
    }
    public Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id, Opportunity__r.Location_Text_Id__c FROM VOB__c WHERE Opportunity__c!=NULL';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        List<Vob__c> vobs = (List<Vob__c>) scope;
        Map<Id,Id> vobToActiveLocation = new Map<Id,Id>();
        for(Vob__c vob :vobs){
            vobToActiveLocation.put(vob.Id,vob.Opportunity__r.Location_Text_Id__c);
        }
        List<Vob__share> newRecords = new List<Vob__share>();
        for(Vob__c vob :vobs){
            if(!vobToActiveLocation.containsKey(vob.Id)){
                continue;
            }
            Id vobActiveLocation = vobToActiveLocation.get(vob.Id);
            for(Id userId :userAllLocationsAccess.KeySet()){
                List<Id> userAccessibleLocations = userAllLocationsAccess.get(userId);
                if(userAccessibleLocations.contains(vobActiveLocation)){
                    VOB__share vobShare = new VOB__share();
                    vobShare.ParentId = vob.Id;
                    vobShare.UserOrGroupId = userId;
                    vobShare.RowCause = Schema.Vob__share.RowCause.Manual;
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
        Database.executeBatch(new SharingRuleBatchablePreAssessmentInsert(userAllLocationsAccess),2000);
    }
}
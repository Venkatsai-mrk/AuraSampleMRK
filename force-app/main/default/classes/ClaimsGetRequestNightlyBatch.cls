public without sharing class ClaimsGetRequestNightlyBatch implements Schedulable, Database.Batchable<sObject>, Database.AllowsCallouts{
    public void execute(SchedulableContext sc) {
          }
    public Database.QueryLocator start(Database.BatchableContext bc){
        string query;
        return Database.getQueryLocator(query);
    }    
    public void execute(Database.BatchableContext BC, list<Integration_Data__c> scope){
     
    }    
    public void finish(Database.BatchableContext BC){        
    }
 
}
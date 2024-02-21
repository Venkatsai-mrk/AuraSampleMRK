/* Author name : Rohit Singh Bora
* Purpose : To automatically make first POST callout for all the claims having Status 'Ready to Submit' to bring their Claim Status from Claim MD 
* Scheduling chunks decided so far : 100
* Scheduling frequency : 1 at Night per day
* Mock Test Class : ClaimsPostRequestNightlyMock
* Test Class : ClaimsPostRequestNightlyBatchTest
* LastModified By - Rohit Singh Bora
*/
public with sharing class ClaimsPostRequestNightlyBatch implements Schedulable, Database.Batchable<sObject>, Database.AllowsCallouts{
    public void execute(SchedulableContext sc) {
    }
    public Database.QueryLocator start(Database.BatchableContext bc){
        string query;
        return Database.getQueryLocator(query);
    }    
    public void execute(Database.BatchableContext BC, list<sObject> scope){
       
    }    
    public void finish(Database.BatchableContext BC){        
    }
  
}
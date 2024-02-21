global with sharing class bedAvailabililityBatch implements Schedulable,Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
       
        return null;
     
    }
    
     global void execute(SchedulableContext sc) {
       
       
    }
    global void execute(Database.BatchableContext BC, List<sobject > bedReleasingToday) {
       
        
    }
    global void finish(Database.BatchableContext BC) {
        
    }
    
    
}
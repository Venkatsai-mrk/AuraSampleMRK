global with sharing class GetResultForUnsolicitedBatch extends getHL7 implements Database.Batchable<sObject>{
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        String query = 'SELECT Id, Clinical_Report_ID__c, PlacerOrder__c FROM Clinician_Report__c Where isDownloaded__c=false AND IsUnsolicited__c = true';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Clinician_Report__c> clinicianIds) {
        
        
    }   
    
    global void finish(Database.BatchableContext BC) {
        
    }
}
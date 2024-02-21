global with sharing class GetHL7UnsolicitedBatch extends getHL7 implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query   = 'SELECT Id, Clinical_Report_ID__c,isReportAvailable__c FROM Clinician_Report__c Where isDownloaded__c=false';
        
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Clinician_Report__c> clinicianReportIds){
        
        
    }
    
    
    global void finish(Database.BatchableContext BC) {
        
    }
}
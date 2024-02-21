public with sharing class Elixir_FormLookupClass {

     //Vidish code start 
     @AuraEnabled
    public static List<SObJectResult> getResults(String ObjectName, String fieldName, String value, String lastSelectedRecordID) {
       system.debug('ObjectName '+ObjectName);
       system.debug('lastSelectedRecordID '+lastSelectedRecordID);
        if(lastSelectedRecordID != null){
		 Id recId = Id.valueOf(lastSelectedRecordID);    
         ObjectName  = recId.getSObjectType().getDescribe().getName();
        }
        If(ObjectName.equalsIgnoreCase('Case')){
            fieldName = 'Subject';
        }
        List<SObJectResult> sObjectResultList = new List<SObJectResult>();
//      for(sObject so : Database.Query('Select Id,'+fieldName+' FROM '+ObjectName+' WHERE '+fieldName+' LIKE \'%' + value  + '%\'')) {
        for(sObject so : Database.Query('Select Id,'+String.escapeSingleQuotes(fieldName)+' FROM '+String.escapeSingleQuotes(ObjectName)+' WHERE '+String.escapeSingleQuotes(fieldName)+' LIKE \'%' + String.escapeSingleQuotes(value) + '%\'')) {
            String fieldvalue = (String)so.get(fieldName);
            system.debug('fieldValue '+fieldvalue);
            sObjectResultList.add(new SObjectResult(fieldvalue, so.Id));
        }
        system.debug('sObjectResultList '+sObjectResultList);
        return sObjectResultList;
    }
    
     @AuraEnabled
    public static String getDetails(String RecordID) {
        if(RecordID != null){
        system.debug('Inside getDetails '+RecordID);
        String fieldName = 'Name';
        String ObjectName;
        String recordName;
        Id recId = Id.valueOf(RecordID);
        if(recordID != null){
           ObjectName  = recId.getSObjectType().getDescribe().getName();
        }
        system.debug('Object Case Update '+objectName);
        If(ObjectName != null){
        If(ObjectName.equalsIgnoreCase('Case')){
            fieldName = 'Subject';
        }
       system.debug('RecordID '+RecordID);
        List<SObJectResult> sObjectResultList = new List<SObJectResult>();
     //String Query = 'Select Id,'+fieldName+' FROM '+ObjectName+' WHERE ID =\''+ RecordID+'\'';
       String Query = 'Select Id,'+String.escapeSingleQuotes(fieldName)+' FROM '+String.escapeSingleQuotes(ObjectName)+' WHERE ID =\''+ String.escapeSingleQuotes(RecordID)+'\'';
        system.debug('Query '+Query);
        for(sObject so : Database.Query(Query)) {
           recordName = (String)so.get(fieldName);
            
        }
        system.debug('recordName '+recordName);
    }
        return recordName;
        }
        else{
        return null;
        }
    }
    
    public class SObJectResult {
        @AuraEnabled
        public String recName;
        @AuraEnabled
        public Id recId;
        
        public SObJectResult(String recNameTemp, Id recIdTemp) {
            recName = recNameTemp;
            recId = recIdTemp;
        }
    }
    // Vidish code end
}
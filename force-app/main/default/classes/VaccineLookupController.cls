public with sharing class VaccineLookupController {

    @AuraEnabled
    public static List<sObject> fetchRecords(String searchKeyWord, String ObjectName) {
        
        Id devRecordTypeId = Schema.SObjectType.ElixirSuite__Vaccine__c.getRecordTypeInfosByDeveloperName().get('Template_Vaccine').getRecordTypeId();
        List<RecordsData> recordsDataList = new List<RecordsData>();
        string tempInput = '%' + searchKeyWord + '%';
      //String query = 'SELECT Id,Name,ElixirSuite__CVX_Code__c,ElixirSuite__Next_Dose_in_Series_After__c,ElixirSuite__Vaccine_Route__c,ElixirSuite__Vaccine_Site__c,ElixirSuite__Vaccine_Series__c  FROM '+objectName + ' where Name LIKE: tempInput AND RecordTypeId = : devRecordTypeId  order by createdDate DESC  limit 5';
      String query = 'SELECT Id,Name,ElixirSuite__CVX_Code__c,ElixirSuite__Next_Dose_in_Series_After__c,ElixirSuite__Vaccine_Route__c,ElixirSuite__Vaccine_Site__c,ElixirSuite__Vaccine_Series__c  FROM '+String.escapeSingleQuotes(objectName) + ' where Name LIKE: tempInput AND RecordTypeId = : devRecordTypeId  order by createdDate DESC  limit 5';
        List < sObject > lstOfRecords = Database.query(query);
        List < sObject > returnList = new List<sObject>();
        try{
        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
            
        }
        }
        catch(Exception e){
        ExceptionLog.logError(e);
        }
        return returnList;
       //Commented 
        
    }
    
    public class RecordsData {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        public RecordsData(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }
}
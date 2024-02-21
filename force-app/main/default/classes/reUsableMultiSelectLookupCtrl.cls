public with sharing class reUsableMultiSelectLookupCtrl {
    @AuraEnabled
    public static List < sObject > fetchLookUpValues(String searchKeyWord, String objectName, List<sObject> excludeitemsList) {
        String searchKey = '%' + searchKeyWord + '%';
        List<string> searchKeys = new List<string>(); // added by Jami for SFDX issues
        searchKeys.add(searchKey);
        List < sObject > returnList = new List < sObject > (); 

        List<string> lstExcludeitems = new List<string>();
        try{
            if(excludeitemsList.size() >0 && excludeitemsList!=null){
                for(sObject item : excludeitemsList ){
                    lstExcludeitems.add(item.id);
                }
            }
        
        
        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5 and exclude already selected records 
        String sQuery =  'select id, Name from ' +String.escapeSingleQuotes(ObjectName) + ' where Name LIKE: searchKey AND Id NOT IN : lstExcludeitems order by createdDate DESC limit 5';
       
        if(ObjectName =='Account'){
           // String currentStatus = 'Current Patients'; // commented this hardCode value and given in query by Jami for SFDX issues
           // String recordTypeName = 'Business_Account';// commented by Jami for SFDX issues
           Elixir_Custom_Setting__c val = Elixir_Custom_Setting__c.getOrgDefaults();
        String bussinessAccRecType = val.ElixirSuite__Business_Account_Recordtype__c;
            sQuery =  'select id, Name from ' +String.escapeSingleQuotes(ObjectName) + ' where Name LIKE: searchKey AND Id NOT IN : lstExcludeitems AND ElixirSuite__Current_Status_Of_Patient__c= \'Current Patients\' AND RecordType.developerName!=:'+bussinessAccRecType+ 'order by createdDate DESC limit 5';
        }else if(ObjectName =='ElixirSuite__Provider__c'){
            Id devRecordTypeId = Schema.SObjectType.ElixirSuite__Provider__c.getRecordTypeInfosByDeveloperName().get('Template_Provider').getRecordTypeId();
           set<Id> recordTypeIds = new set<Id>();// added by Jami for SFDX issues
            recordTypeIds.add(devRecordTypeId);
            sQuery =  'select id, Name from ' +String.escapeSingleQuotes(ObjectName) + ' where Name LIKE: searchKey AND RecordTypeId =: recordTypeIds  AND Id NOT IN : lstExcludeitems order by createdDate DESC limit 5';

        }else if(ObjectName =='ElixirSuite__Programs__c'){
            
            sQuery =  'select id,Name,ElixirSuite__Program_Name__c from ' +String.escapeSingleQuotes(ObjectName) + ' where ElixirSuite__Program_Name__c LIKE: searchKeys AND Id NOT IN : lstExcludeitems order by createdDate DESC limit 5';

        }
        List < sObject > lstOfRecords = Database.query(sQuery);
        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
        }
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        return returnList;
    }
}
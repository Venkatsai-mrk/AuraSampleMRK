public with sharing class CustomLookupController {
    @AuraEnabled
    public static List<RecordsData> fetchRecords(String objectName, String filterField, String filterClause, String searchString, String value, string accountId) {
        try {
            if(String.isNotBlank(filterClause)){
                filterClause = ' WHERE ' + filterClause;
            }            
            
            List<RecordsData> recordsDataList = new List<RecordsData>();
            String query = 'SELECT Id, ' + String.escapeSingleQuotes(filterField) + ' FROM '+String.escapeSingleQuotes(objectName) + filterClause;

           
            if(String.isNotBlank(value)) {
                if(String.isNotBlank(filterClause)){
                    if(String.isNotBlank(accountId)){
                     query += ' AND ElixirSuite__Account__c = \''+String.escapeSingleQuotes(accountId) + '\'';   
                    }
                query += ' AND Id = \''+ String.escapeSingleQuotes(value)+ '\' LIMIT 49999';   
                }else{
                query += ' WHERE Id = \''+ String.escapeSingleQuotes(value) + '\' LIMIT 49999';
                }
            
            
            } else {
                if(String.isNotBlank(filterClause)){
                    if(String.isNotBlank(accountId)){
                     query += ' AND ElixirSuite__Account__c = \''+String.escapeSingleQuotes(accountId) + '\'';   
                    }
                query += ' AND '+String.escapeSingleQuotes(filterField)+
                    ' LIKE ' + '\'' + +'%'+ String.escapeSingleQuotes(searchString.trim()) + '%\' LIMIT 49999';  
                }else{
                query += ' WHERE '+String.escapeSingleQuotes(filterField)+
                    ' LIKE ' + '\'' + +'%'+ String.escapeSingleQuotes(searchString.trim()) + '%\' LIMIT 49999';}
            }
            for(SObject s : Database.query(query)) {
                recordsDataList.add( new RecordsData((String)s.get(filterField), (String)s.get('id')) );
            }
            
            return recordsDataList;
           
        } catch (Exception err) {
            if ( String.isNotBlank( err.getMessage() ) && err.getMessage().contains( 'error:' ) ) {
                throw new AuraHandledException(err.getMessage().split('error:')[1].split(':')[0] + '.');
            } else {
                throw new AuraHandledException(err.getMessage());
            }
        }
    }
    
    public class RecordsData {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        public RecordsData(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }


    @AuraEnabled
    public static String getSubstanceCode(String substanceName) {
        Id substanceRecordTypeId = Schema.SObjectType.ElixirSuite__Master_Object__c.getRecordTypeInfosByName().get('Substance').getRecordTypeId();
        
        ElixirSuite__Master_Object__c substanceRecord = [
            SELECT ElixirSuite__Coding_System_Value__c
            FROM ElixirSuite__Master_Object__c
            WHERE Id = :substanceName AND RecordTypeId =: substanceRecordTypeId
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        
        if (substanceRecord != null) {
            return substanceRecord.ElixirSuite__Coding_System_Value__c;
        } else {
            return null;
        }
    }

}
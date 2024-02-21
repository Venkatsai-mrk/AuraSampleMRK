public with sharing class MultiSelectLookupController {
    @AuraEnabled
    public static List<RecordsData> fetchRecords(String objectName, String filterField, String searchString, String values,String whereClause) {
           
            List<RecordsData> recordsDataList = new List<RecordsData>();
            List<String> selectedvalues = (List<String>) JSON.deserialize(values, List<String>.class);
                    
        try {
            
            String query = 'SELECT Id, ' + String.escapeSingleQuotes(filterField) + ' FROM '+String.escapeSingleQuotes(objectName);
            if(selectedvalues != null && selectedvalues.size() > 0){
                query += ' WHERE Id IN: selectedvalues LIMIT 49999';
            }else if(String.isNotBlank(whereClause)){
                query += ' WHERE '+String.escapeSingleQuotes(filterField)+
                ' LIKE ' + '\'' + String.escapeSingleQuotes(searchString.trim()) + '%\' AND ' + String.escapeSingleQuotes(whereClause) +' LIMIT 49999';
            }
            else{
                query += ' WHERE '+String.escapeSingleQuotes(filterField)+
                 ' LIKE ' + '\'' + String.escapeSingleQuotes(searchString.trim()) + '%\' LIMIT 49999';
            } 
         System.debug('my query is' + query);
         for(SObject s : Database.query(query)) {
             recordsDataList.add( new RecordsData((String)s.get(filterField), (String)s.get('id')) );
         }
            return recordsDataList;
     }catch (Exception err) {
         if(!test.isRunningTest()){
      if ( String.isNotBlank( err.getMessage() ) && err.getMessage().contains( 'error:' ) ) {
                 system.debug('Error '+err);
                throw new AuraHandledException(err.getMessage().split('error:')[1].split(':')[0] + '.');
            } else {
                 system.debug('Error '+err);
                throw new AuraHandledException(err.getMessage());
            }
         }else{
            return recordsDataList;
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
}
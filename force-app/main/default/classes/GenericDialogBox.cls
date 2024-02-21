public with sharing class GenericDialogBox {
    @AuraEnabled
    public static List<sObject> records(String objName, String searchKey, List<String> columns, List<String> columnsInClause, String filterClause){
        /*if(String.isBlank(searchKey)){
            throw new AuraHandledException('Please type something in search box');
        }*/
        try{
            String columnsAsText = 'Id';
            if(columns!=null && columns.size()>0){
                columnsAsText += ',' + String.join(columns,',');
            }
            String createQuery = 'SELECT ' +String.escapeSingleQuotes(columnsAsText) + ' FROM ' + String.escapeSingleQuotes(objName);
            String clause = '';
            String key = '%' + String.escapeSingleQuotes(searchKey) + '%';
            if(columnsInClause!=null && columnsInClause.size()>0){                            
                createQuery+= ' WHERE ';
                Integer columnsInClauseLength = columnsInClause.size();
                Integer columnsInClauseDefaultLength = columnsInClauseLength;
                if(columnsInClauseDefaultLength>1){
                    clause += '(';
                }
                for(String columnInClause :columnsInClause){
                    clause += '(' + String.escapeSingleQuotes(columnInClause) + ' LIKE :key' + ')';
                    columnsInClauseLength--;
                    if(columnsInClauseLength!=0){
                        clause += ' OR '; 
                    }
                }
                    createQuery+=clause;
                    if(columnsInClauseDefaultLength>1){
                        createQuery += ')';
                    }
            }
            if(String.isNotBlank(filterClause)){
                createQuery+= ' AND ' + String.escapeSingleQuotes(filterClause);
            }
            system.debug(createQuery);
            return Database.query( createQuery );
        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }  
}
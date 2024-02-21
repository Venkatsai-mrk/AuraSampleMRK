public with sharing class ElixirOEM_CustomLookupForClaimsHelper {
    /*@AuraEnabled 
    public static List<Account> fetchRecords1( String objectName, String filterField, String searchString ) {
        system.debug(objectName+filterField+searchString);
        String query = 'SELECT Id, ' + filterField+
            ' FROM '+objectName+
            ' WHERE '+filterField+' LIKE ' + '\''+searchString+'%'+'\''; 
        system.debug(Database.query(query));
        List<Account> acclist =  Database.query(query);
        return acclist;
    }*/
    @AuraEnabled 
    public static List<Account> fetchRecords1( String objectName, String filterField, String searchString ) {
        system.debug(objectName+filterField+searchString);
        String query = 'SELECT Id, ' +  String.escapeSingleQuotes(filterField)+
            ' FROM '+ String.escapeSingleQuotes(objectName)+
            ' WHERE '+String.escapeSingleQuotes(filterField)+' LIKE ' + '\''+String.escapeSingleQuotes(searchString)+'%'+'\''; 
        system.debug(Database.query(query));
        List<Account> acclist =  Database.query(query);
        return acclist;
    }
    
    
    
    
    
    @AuraEnabled 
    public static list<ElixirSuite__Procedure__c> employerList(String searchKeyWord ){
        String searchKey = '%' + searchKeyWord + '%';     
      
        String recTypeID = Schema.SObjectType.ElixirSuite__Procedure__c.getRecordTypeInfosByDeveloperName().get('Template_Procedure').getRecordTypeId();
        return [SELECT id,Name,ElixirSuite__CPT_HCPCS_Code__c FROM ElixirSuite__Procedure__c 
                where ElixirSuite__CPT_HCPCS_Code__c LIKE: searchKey AND RecordType.Id = :recTypeID 
                WITH SECURITY_ENFORCED
                limit 149];
        
    }
}
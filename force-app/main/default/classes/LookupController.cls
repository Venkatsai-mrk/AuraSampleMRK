/*
Developed By  - Sonal Agarwal
Test Class - LookupControllerTest 
*/
public with sharing class LookupController {
	
	@AuraEnabled 
    public static List<Account> fetchRecords1( String objectName, String filterField, String searchString ) {
        system.debug(objectName+filterField+searchString);
        /*String query = 'SELECT Id, ' + filterField+
                        ' FROM '+objectName+
                        ' WHERE '+filterField+' LIKE ' + '\''+searchString+'%'+'\''; */
        String query = 'SELECT Id, ' + String.escapeSingleQuotes(filterField)+
                        ' FROM '+String.escapeSingleQuotes(objectName)+
                        ' WHERE '+String.escapeSingleQuotes(filterField)+' LIKE ' + '\''+String.escapeSingleQuotes(searchString)+'%'+'\''; 
        system.debug(Database.query(query));
		 List<Account> acclist =  Database.query(query);
        return acclist;
    }
    
    
    
    @AuraEnabled 
    public static list<Account> employerList(String searchKeyWord ){
        String searchKey = '%' + searchKeyWord + '%';
        List <Account> returnList = new List <Account> ();
        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5   
        List <Account> lstOfRecords = [Select id, Name from Account where Name LIKE:searchKey WITH SECURITY_ENFORCED limit 149];
      
        return lstOfRecords;
    }
}
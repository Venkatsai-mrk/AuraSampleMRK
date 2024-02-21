public with sharing class customListViewMsgSubjectController {

    @AuraEnabled
    public static String getAccountName(String accountId){
        List<Account> accList = [SELECT Id , Name FROM Account 
        WHERE Id= : accountId WITH SECURITY_ENFORCED];
        return accList[0].Name;
    }
    
 
    @AuraEnabled
	public static Integer fetchFilterRecCount(String accountId,String filter, string searchKeyword) {
  
        final Map<String, String> actionToClause = new Map<String, String>{
         'All'=>'(Archived__c = NULL OR Archived__c=\'1\')',
           'Archive'=>'(Archived__c = \'2\' OR Archived__c =\'0\')',
        'Bookmark'=>'(Bookmarked__c = \'2\' OR Bookmarked__c = \'0\')',
         'Inbox'=>'IsPortal__c = TRUE AND (Archived__c = NULL OR Archived__c=\'1\')',
         'Outbox'=>'IsPortal__c = FALSE AND (Archived__c = NULL OR Archived__c=\'1\')'
        };
    
    String defaultQuery = 'SELECT count(Id) total'
        + ' FROM Message_Subject__c' 
        + ' WHERE Account__c=:accountId'
        + ' AND (Deleted__c = NULL OR Deleted__c=\'1\')';
    
    if(actionToClause.containsKey(filter)){
        String filterClause = actionToClause.get(filter);
        defaultQuery+= ' AND ' + filterClause;
    }
    
    if (String.isNotBlank(searchKeyword)) {
        String key = '%' + String.escapeSingleQuotes(searchKeyword) + '%';
        defaultQuery += ' And ElixirSuite__Subject__c LIKE :key';
    }
    
    List<AggregateResult> results = Database.query(defaultQuery);
    
    Integer count = 0;
    if (results.size() > 0) {
         count =(Integer) results[0].get('total');
       // count = Integer.valueOf(results[0].get('expr0'));
    }
    
    return count;
}
    
    @AuraEnabled
    public static List<Message_Subject__c> fetchFilterRec(String accountId,String filter, string searchKeyword, Integer limits , Integer offsets){  
        System.debug('limits'+limits);
        System.debug('offsets'+offsets);
        Integer intlimits = integer.valueof(limits);
        Integer intoffsets = integer.valueof(offsets);
       
        final Map<String, String> actionToClause = new Map<String, String>{
         'All'=>'(Archived__c = NULL OR Archived__c=\'1\')',
           'Archive'=>'(Archived__c = \'2\' OR Archived__c =\'0\')',
        'Bookmark'=>'(Bookmarked__c = \'2\' OR Bookmarked__c = \'0\')',
         'Inbox'=>'IsPortal__c = TRUE AND (Archived__c = NULL OR Archived__c=\'1\')',
         'Outbox'=>'IsPortal__c = FALSE AND (Archived__c = NULL OR Archived__c=\'1\')'
       
    };
    System.debug(actionToClause+' actionToClause');
    List<Message_Subject__c> prescRec = new List<Message_Subject__c>();
    String defaultQuery = 'SELECT Id,Name,ElixirSuite__Subject__c,LastModifiedDate, IsPortal__c,Archived__c,Deleted__c,'
    +'Bookmarked__c,Account__c,CreatedBy.name,CreatedDate'
    +' FROM Message_Subject__c' 
    +' WHERE Account__c=:accountId'
    +' AND (Deleted__c = NULL OR Deleted__c=\'1\')';
    System.debug(defaultQuery+' defaultQuery');
    if(actionToClause.containsKey(filter)){
        String filterClause = actionToClause.get(filter);
        System.debug(filterClause+' filterClause');
        defaultQuery+= ' AND ' + filterClause;
        System.debug(defaultQuery+' defaultQuery');
    }
    if ( String.isNotBlank(searchKeyword )) {
            String key = '%' + String.escapeSingleQuotes(searchKeyword) + '%';
            defaultQuery += 'AND (ElixirSuite__Subject__c LIKE :key OR CreatedBy.Name LIKE :key)';
        }
        
    defaultQuery+= ' ORDER BY CreatedDate DESC LIMIT :intlimits OFFSET :intoffsets';
    System.debug(defaultQuery+' defaultQuery');
    return Database.query(defaultQuery);
    }
}
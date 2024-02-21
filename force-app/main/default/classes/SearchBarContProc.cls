public with sharing class SearchBarContProc 
{
    @AuraEnabled
    public static List<ElixirSuite__Procedure__c> searchKeyResult(String searchKey){
       
        List<ElixirSuite__Procedure__c> listOfProcs = new List<ElixirSuite__Procedure__c>();
        try{
        String name =  + searchKey + '%';
        listOfProcs = [SELECT Id, ElixirSuite__Account__c,ElixirSuite__Billable__c,Name,
        ElixirSuite__CPT_HCPCS_Code__c,RecordType.Name
         FROM ElixirSuite__Procedure__c WHERE Name LIKE: name and RecordType.Name = 'Template Procedure'
         WITH SECURITY_ENFORCED];
        }
        catch(Exception e){
        ExceptionLog.logError(e);
        }
        return listOfProcs;
    
    }    
   
}
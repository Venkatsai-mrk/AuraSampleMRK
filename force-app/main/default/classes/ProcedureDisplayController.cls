public with sharing class ProcedureDisplayController 
{
	 @AuraEnabled
    public static  List<ElixirSuite__Procedure__c> searchKeyResult(String searchKey){
       
        List<ElixirSuite__Procedure__c> listOfProcs = new List<ElixirSuite__Procedure__c>();
        String name =  + searchKey + '%';
        try{
        String devRecordTypeId = Schema.SObjectType.ElixirSuite__Procedure__c.getRecordTypeInfosByDeveloperName().get('Template_Procedure').getRecordTypeId();
        listOfProcs = [SELECT Id, ElixirSuite__Account__c,ElixirSuite__Billable__c,Name,CPT_HCPCS_Code__c,RecordType.Name 
        FROM ElixirSuite__Procedure__c 
        WHERE Name LIKE: name and RecordType.Id = :devRecordTypeId 
        WITH SECURITY_ENFORCED];
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        return listOfProcs;
    
    }  
    
     @AuraEnabled
    public static  List<ElixirSuite__Procedure__c> searchKeyProc(String proId){
       
        List<ElixirSuite__Procedure__c> listOfProcs = new List<ElixirSuite__Procedure__c>();
        try{
        String devRecordTypeId = Schema.SObjectType.ElixirSuite__Procedure__c.getRecordTypeInfosByDeveloperName().get('Template_Procedure').getRecordTypeId();
        listOfProcs = [SELECT Id, ElixirSuite__Account__c,ElixirSuite__Billable__c,Name,
        ElixirSuite__CPT_HCPCS_Code__c,RecordType.Name 
        FROM ElixirSuite__Procedure__c where Id =: proId and RecordType.Id = : devRecordTypeId 
        WITH SECURITY_ENFORCED];
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        return listOfProcs;
    }  
    
    @AuraEnabled
    public static List<ListView> getListViews() {
        List<ListView> listviews =
            [SELECT Id, Name FROM ListView WHERE SobjectType = 'ElixirSuite__Procedure__c' WITH SECURITY_ENFORCED];
        
        // Perform isAccessible() check here
        return listviews;
    }
    
    @AuraEnabled
    public static String recTypemed()
    {
        Id recTypeId = [Select Id from RecordType where SObjectType ='ElixirSuite__Procedure__c' AND DeveloperName = 'Patient_Procedure' LIMIT 1 ].Id;
        System.debug('rec '+recTypeId);
        return recTypeId;
    }

}
public with sharing class ProcedureSearchHelper {
    @AuraEnabled 
    public static  ElixirSuite__Procedure__c[] procedureList(String searchKeyWord,String codeCategory){
        String searchKey = '%' + searchKeyWord + '%';
        Id devRecordTypeId = Schema.SObjectType.ElixirSuite__Procedure__c.getRecordTypeInfosByDeveloperName().get('Template_Procedure').getRecordTypeId();       
        ElixirSuite__Procedure__c[] recordLst = [SELECT ID,Name,ElixirSuite__Code_Description__c,ElixirSuite__Reference_CPT_Code__c FROM ElixirSuite__Procedure__c where (Name 
                                                 LIKE: searchKey OR ElixirSuite__Code_Description__c LIKE: searchKey) AND RecordTypeId = : devRecordTypeId AND ElixirSuite__Code_Category__c = : codeCategory 
                                                 AND ElixirSuite__Modifier1__c=null AND ElixirSuite__Modifier2__c=null AND ElixirSuite__Modifier3__c=null AND ElixirSuite__Modifier4__c=null
                                                 AND ElixirSuite__Active__c=true WITH SECURITY_ENFORCED];
        return recordLst;
    }
    
    @AuraEnabled 
    public static ElixirSuite__Procedure__c[] modfierList(string referenceCode,String codeCategory){
        Id devRecordTypeId = Schema.SObjectType.ElixirSuite__Procedure__c.getRecordTypeInfosByDeveloperName().get('Template_Procedure').getRecordTypeId();       
        ElixirSuite__Procedure__c[] recordLst = [SELECT ID,Name,ElixirSuite__Modifier1__r.Name,ElixirSuite__Modifier2__r.Name,ElixirSuite__Modifier3__r.Name,
                                                 ElixirSuite__Modifier4__r.Name FROM ElixirSuite__Procedure__c where  ElixirSuite__Code_Category__c =: codeCategory 
                                                 AND ElixirSuite__Reference_CPT_Code__c =: referenceCode AND RecordTypeId = : devRecordTypeId
                                                 AND (ElixirSuite__Modifier1__r.ElixirSuite__Code_Category__c='Modifier' OR ElixirSuite__Modifier2__r.ElixirSuite__Code_Category__c='Modifier' 
                                                      OR ElixirSuite__Modifier3__r.ElixirSuite__Code_Category__c='Modifier' OR ElixirSuite__Modifier4__r.ElixirSuite__Code_Category__c='Modifier') WITH SECURITY_ENFORCED];
        return recordLst;
    }
    @AuraEnabled 
    public static  ElixirSuite__Procedure__c[] recordSelected(String recordId){        
        ElixirSuite__Procedure__c[] recordLst = [SELECT ID,Name,ElixirSuite__Code_Description__c FROM ElixirSuite__Procedure__c where Id = : recordId WITH SECURITY_ENFORCED
                                                ];
        return recordLst;
    }
}
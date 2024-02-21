public with sharing class ElixirOEM_ProblemGlobalSearch {
    
    @AuraEnabled  
    public static Searchwrapper searchProblemDiagnosis(String searchKeyWord,String param ){
        String searchKey = '%' + searchKeyWord + '%';
        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5   
        List <ElixirSuite__Template_Diagnosis_Code__c> lstOfRecords =  [select id, Name,ElixirSuite__Template_Problem__r.Name,ElixirSuite__Template_Problem__r.ElixirSuite__Note__c,
                                                                        ElixirSuite__Diagnosis_Code__r.ElixirSuite__Code_Description1__c,ElixirSuite__Template_Problem__r.ElixirSuite__Description__c,
                                                                        ElixirSuite__Template_Problem__r.ElixirSuite__SNOMED_CT_Code__c,ElixirSuite__Template_Problem__r.Id,
                                                                        ElixirSuite__Diagnosis_Code__r.Name,ElixirSuite__Diagnosis_Code__r.ElixirSuite__Version__c,
                                                                        ElixirSuite__Diagnosis_Code__r.Id
                                                                        from ElixirSuite__Template_Diagnosis_Code__c
                                                                        where ElixirSuite__Template_Problem__r.Name!=''  AND (ElixirSuite__Diagnosis_Code__r.ElixirSuite__Version__c = : param OR ElixirSuite__Diagnosis_Code__r.ElixirSuite__Version__c ='') AND (ElixirSuite__Template_Problem__r.Name 
                                                                        LIKE: searchKey OR ElixirSuite__Diagnosis_Code__r.Name LIKE: searchKey
                                                                        OR ElixirSuite__Template_Problem__r.ElixirSuite__SNOMED_CT_Code__c 
                                                                        LIKE: searchKey) WITH SECURITY_ENFORCED
                                                                        limit 149];
        Set<Id> problemSet = new Set<Id>();
        for(ElixirSuite__Template_Diagnosis_Code__c sObj : lstOfRecords){
            problemSet.add(sObj.ElixirSuite__Template_Problem__r.Id);
        }
        Id problemRecType = Schema.SObjectType.ElixirSuite__Template_Problem__c.getRecordTypeInfosByDeveloperName().get('Problem').getRecordTypeId();

        List<ElixirSuite__Template_Problem__c> recTemplateProblem = [SELECT ID,Name,ElixirSuite__SNOMED_CT_Code__c,ElixirSuite__Status__c,ElixirSuite__Description__c,
                                                                     ElixirSuite__Note__c
                                                                     from ElixirSuite__Template_Problem__c WHERE RecordTypeId =: problemRecType AND Name LIKE: searchKey
                                                                     AND ID NOT IN : problemSet WITH SECURITY_ENFORCED];
        // ICD NOT REQUIERED FOR TEMPLATE PROBLEM
        Searchwrapper toRet = new Searchwrapper();
        toRet.lstOfRecords = lstOfRecords;
        toRet.recTemplateProblem = recTemplateProblem;
        return toRet;
        
    }
    
    public class Searchwrapper{
        @AuraEnabled    public List <ElixirSuite__Template_Diagnosis_Code__c> lstOfRecords{ get; set; }
        @AuraEnabled    public   List<ElixirSuite__Template_Problem__c> recTemplateProblem{ get; set; }  
        
    }
    @AuraEnabled 
    public static Searchwrapper searchWithParam(String searchKeyWord,String param){
        String searchKey = '%' + searchKeyWord + '%';
        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5   
        List <ElixirSuite__Template_Diagnosis_Code__c> lstOfRecords =  [select id, Name,ElixirSuite__Template_Problem__r.Name,ElixirSuite__Template_Problem__r.ElixirSuite__Note__c,
                                                                        ElixirSuite__Template_Problem__r.ElixirSuite__SNOMED_CT_Code__c,ElixirSuite__Template_Problem__r.Id,
                                                                        ElixirSuite__Diagnosis_Code__r.Name,ElixirSuite__Diagnosis_Code__r.ElixirSuite__Version__c,
                                                                        ElixirSuite__Diagnosis_Code__r.Id,ElixirSuite__Template_Problem__r.ElixirSuite__Description__c,
                                                                         ElixirSuite__Diagnosis_Code__r.ElixirSuite__Code_Description1__c
                                                                        from ElixirSuite__Template_Diagnosis_Code__c
                                                                        where 
                                                                        (ElixirSuite__Template_Problem__r.Name 
                                                                        LIKE: searchKey 
                                                                        // OR ElixirSuite__Diagnosis_Code__r.Name LIKE: searchKey
                                                                        OR ElixirSuite__Template_Problem__r.ElixirSuite__SNOMED_CT_Code__c LIKE: searchKey) 
                                                                        AND (ElixirSuite__Diagnosis_Code__r.ElixirSuite__Version__c = : param OR ElixirSuite__Diagnosis_Code__r.ElixirSuite__Version__c ='') AND ElixirSuite__Template_Problem__r.Name!=''
                                                                      WITH SECURITY_ENFORCED limit 149];
       
         Set<Id> problemSet = new Set<Id>();
        for(ElixirSuite__Template_Diagnosis_Code__c sObj : lstOfRecords){
            problemSet.add(sObj.ElixirSuite__Template_Problem__r.Id);
        }
        Id problemRecType = Schema.SObjectType.ElixirSuite__Template_Problem__c.getRecordTypeInfosByDeveloperName().get('Problem').getRecordTypeId();
        List<ElixirSuite__Template_Problem__c> recTemplateProblem = [SELECT ID,Name,ElixirSuite__SNOMED_CT_Code__c,ElixirSuite__Status__c,ElixirSuite__Description__c,
                                                                     ElixirSuite__Note__c
                                                                     from ElixirSuite__Template_Problem__c WHERE RecordTypeId =: problemRecType AND Name LIKE: searchKey
                                                                     AND ID NOT IN : problemSet WITH SECURITY_ENFORCED];
        // ICD NOT REQUIERED FOR TEMPLATE PROBLEM
        Searchwrapper toRet = new Searchwrapper();
        toRet.lstOfRecords = lstOfRecords;
        toRet.recTemplateProblem = recTemplateProblem;
        return toRet;
    }
      @AuraEnabled 
    public static integer countOfRecords(String searchKeyWord,String param) {
        integer count = [SELECT COUNT() from ElixirSuite__Template_Diagnosis_Code__c  where ElixirSuite__Template_Problem__r.Name!='' AND ElixirSuite__Template_Problem__r.Name 
                                                                        LIKE: searchKeyWord AND (ElixirSuite__Diagnosis_Code__r.ElixirSuite__Version__c = : param OR ElixirSuite__Diagnosis_Code__r.ElixirSuite__Version__c ='')
                                                                         WITH SECURITY_ENFORCED];
        return count;
    }
}
public with sharing class PopulateInfoInPatientProblemHelper {
    
    public static void updateTemplateProblemInfo(List<ElixirSuite__Dataset1__c> patientProblemlst){
        Set<Id> templateProblemIds = new Set<Id>();
        for (Dataset1__c problem : patientProblemlst) {
            templateProblemIds.add(problem.Template_Problem__c);
        }
        if(templateProblemIds != null){
            Map<Id, Template_Problem__c> templateProblemMap = new Map<Id, Template_Problem__c>([
                SELECT Id, SNOMED_CT_Code__c
                FROM Template_Problem__c
                WHERE Id IN :templateProblemIds
            ]);
            
            for (Dataset1__c problem : patientProblemlst) {
                if(String.isNotBlank(problem.Template_Problem__c)){
                    Template_Problem__c tempProblem = templateProblemMap.get(problem.Template_Problem__c);
                    problem.SNOMED_CT_Code__c = tempProblem.SNOMED_CT_Code__c;
                }
            }
        }
    }
}
global with sharing virtual class GlobalPopulateInfoHelper {
    global virtual void beforeInsert(List<ElixirSuite__Dataset1__c> patientProblemlstRecords){
        PopulateInfoInPatientProblemHelper.updateTemplateProblemInfo(patientProblemlstRecords);

    }
}
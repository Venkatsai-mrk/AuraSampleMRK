global with sharing virtual class GlobalTempDiagnosisHelper {
    global virtual void beforeModifications(List<ICD_Codes__c> patientDiagLstRecords){
        PopulateTempDiagnosisHelper.updateTemplateDiagnosisInfo(patientDiagLstRecords);

    }
}
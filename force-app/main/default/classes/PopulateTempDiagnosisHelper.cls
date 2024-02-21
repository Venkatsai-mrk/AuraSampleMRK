public with sharing class PopulateTempDiagnosisHelper {
    
    public static void updateTemplateDiagnosisInfo(List<ICD_Codes__c> patientDiagnosislst){
        /*Id recordTypeId = Schema.SObjectType.ElixirSuite__ICD_Codes__c.getRecordTypeInfosByDeveloperName().get('Template_Diagnosis_Code').getRecordTypeId();
        for(ICD_Codes__c diag : patientDiagnosislst){
            if(diag.recordTypeId == recordTypeId){
                String icdDescription = diag.ICD_Description__c;
                if(icdDescription.length() < 255){
                    diag.Code_Description1__c = icdDescription;
                }
                else{
                    diag.Code_Description1__c = icdDescription.substring(0, 255);
                }
            }
        }*/
        
        Set<Id> templateDiagnosisIds = new Set<Id>();
        for (ICD_Codes__c diagnosis : patientDiagnosislst) {
            if(diagnosis.Template_Diagnosis_Code__c != null){
                templateDiagnosisIds.add(diagnosis.Template_Diagnosis_Code__c);
            }
        }
        if(templateDiagnosisIds.isEmpty()){
            return;
        }
        Map<Id, ICD_Codes__c> templateDiagnosisMap = new Map<Id, ICD_Codes__c>([
            SELECT Id, Code_Description1__c
            FROM ICD_Codes__c
            WHERE Id IN :templateDiagnosisIds
        ]);

        for (ICD_Codes__c diagnosis : patientDiagnosislst) {
            ICD_Codes__c tempDiagnosis;
            if(templateDiagnosisMap.containsKey(diagnosis.Template_Diagnosis_Code__c)){
                tempDiagnosis = templateDiagnosisMap.get(diagnosis.Template_Diagnosis_Code__c);
                if(tempDiagnosis.Code_Description1__c != null && diagnosis.Code_Description1__c == null){
                    diagnosis.Code_Description1__c = tempDiagnosis.Code_Description1__c;
                }    
            }
            
        }
    }
}
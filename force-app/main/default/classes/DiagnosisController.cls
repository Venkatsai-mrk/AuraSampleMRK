public with sharing class DiagnosisController {
   
    @AuraEnabled(cacheable=true)
    public static List<ElixirSuite__Dataset1__c> getPatientProblems(String accId) {
        try {
            
            return [
                SELECT Id, Name, ElixirSuite__Description__c
                FROM ElixirSuite__Dataset1__c
                WHERE  ElixirSuite__Account__c =: accId
                WITH SECURITY_ENFORCED
            ];
         } catch (Exception e) {
           return new List<ElixirSuite__Dataset1__c>();
        }
    }

@AuraEnabled
public static void saveDiagnosisAndProblem(String diagnosisId, List<String> problemIds) {
  try {
    // Retrieve the Diagnosis record
    ElixirSuite__ICD_Codes__c diagnosisCode = [
                SELECT Id
                FROM ElixirSuite__ICD_Codes__c
                WHERE Id = :diagnosisId
                WITH SECURITY_ENFORCED
                LIMIT 1
            ];
            
    if (diagnosisCode == null) {
        return;
    }
        
    List<ElixirSuite__Dataset1__c> lstProblem = [
                        SELECT Id, Name, ElixirSuite__Description__c
                        FROM ElixirSuite__Dataset1__c
                        WHERE Id IN :problemIds
                        WITH SECURITY_ENFORCED
                    ];

 if (lstProblem.isEmpty()) {
        return;
    }

    // Retrieve the existing Diagnosis records for the specified diagnosisId and problemIds
    List<ElixirSuite__Diagnosis_Code__c> existingDiagnosisRecords = [
        SELECT Id, ElixirSuite__Problem__c
        FROM ElixirSuite__Diagnosis_Code__c
        WHERE ElixirSuite__Diagnosis_Code__c = :diagnosisCode.Id
        WITH SECURITY_ENFORCED
    ];

    // Delete existing Diagnosis records
    if (!existingDiagnosisRecords.isEmpty()) {
         DMLManager.deleteAsUser(existingDiagnosisRecords);
           }

    // Create a new Diagnosis record
    List<ElixirSuite__Diagnosis_Code__c> newDiagnosisList = new List<ElixirSuite__Diagnosis_Code__c>();

    // Iterate over the retrieved problems and create association records
    for (ElixirSuite__Dataset1__c problem : lstProblem) {
        ElixirSuite__Diagnosis_Code__c association = new ElixirSuite__Diagnosis_Code__c();
        association.ElixirSuite__Diagnosis_Code__c = diagnosisCode.Id;
        association.ElixirSuite__Problem__c = problem.Id;

        newDiagnosisList.add(association);
    }

    // Insert the new association records
    if (!newDiagnosisList.isEmpty()) {
         DMLManager.insertAsUser(newDiagnosisList);
    }
}

         catch (Exception e) {
            // Handle exception appropriately
        }
}
}
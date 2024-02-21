public with sharing class diagnosisCustomLookupControllerRCM {

@AuraEnabled
public static List<RecordsData> fetchRecords(String objectName, String filterField, String searchString,
                                                String value, String icdVersion, String accountId, 
                                                Boolean filterOnAccountId, String startRecordId) {
    try {
        Elixir_Custom_Setting__c customSetting = Elixir_Custom_Setting__c.getOrgDefaults();
        Boolean patientDiagnosis = customSetting.ElixirSuite__Allow_Patient_Diagnosis_On_RCM_Proceduer__c;
        Id objectRecordTypeIdTemplate = Schema.SObjectType.ElixirSuite__ICD_Codes__c.getRecordTypeInfosByDeveloperName().get('Template_Diagnosis_Code').getRecordTypeId();
        Id objectRecordTypeIdPatient = Schema.SObjectType.ElixirSuite__ICD_Codes__c.getRecordTypeInfosByDeveloperName().get('Patient_Diagnosis_Code').getRecordTypeId();
        List<RecordsData> recordsDataList = new List<RecordsData>();
        String queryIdClause = '';
        system.debug('patientDiagnosis'+patientDiagnosis);
        if (patientDiagnosis) {
            system.debug('Inside true'+patientDiagnosis);
            if (String.isBlank(icdVersion)) {
                icdVersion = MasterProblemListController.fetchDefaultValue();
            }

            String query = 'SELECT Id,ElixirSuite__Code_Description1__c, ' + String.escapeSingleQuotes(filterField) + ' FROM ' + String.escapeSingleQuotes(objectName);

            if (String.isNotBlank(startRecordId)) {
                queryIdClause = ' AND Id > :startRecordId';
            }

            query += ' WHERE (' + String.escapeSingleQuotes(filterField) + ' LIKE \'' + String.escapeSingleQuotes(searchString.trim()) + '%\') AND RecordTypeId = \'' + objectRecordTypeIdTemplate + '\' AND ElixirSuite__Version__c = \'' + String.escapeSingleQuotes(icdVersion) + '\'' + queryIdClause + ' WITH SECURITY_ENFORCED ORDER BY CreatedDate ASC LIMIT 200';

            for (SObject s : Database.query(query)) {
                recordsDataList.add(new RecordsData((String) s.get(filterField), (String) s.get('Id'), (String) s.get('ElixirSuite__Code_Description1__c')));
            }
        } else {
            recordsDataList.addAll(fetchPatientDiagnosis(objectName, filterField, searchString, value, icdVersion,
                    accountId, filterOnAccountId, startRecordId, objectRecordTypeIdPatient, queryIdClause));
            System.debug('@@recordsDataList' + recordsDataList);
        }

        return recordsDataList;
    } catch (Exception err) {
        if (String.isNotBlank(err.getMessage()) && err.getMessage().contains('error:')) {
            throw new AuraHandledException(err.getMessage().split('error:')[1].split(':')[0] + '.');
        } else {
            throw new AuraHandledException(err.getMessage());
        }
    }
}

@AuraEnabled
public static List<RecordsData> fetchPatientDiagnosis(String objectName, String filterField, String searchString,
                                                      String value, String icdVersion, String accountId,
                                                      Boolean filterOnAccountId, String startRecordId,
                                                      Id objectRecordTypeIdPatient, String queryIdClause) {
    List<RecordsData> recordsDataList = new List<RecordsData>();
    String query = 'SELECT Id,ElixirSuite__Code_Description1__c, ' + String.escapeSingleQuotes(filterField)
            + ' FROM ' + String.escapeSingleQuotes(objectName);

    if (String.isNotBlank(startRecordId)) {
        queryIdClause = ' AND Id > :startRecordId';
    }

    query += ' WHERE ElixirSuite__Account__c =:accountId AND (' + String.escapeSingleQuotes(filterField) + ' LIKE \'' + String.escapeSingleQuotes(searchString.trim()) + '%\') AND RecordTypeId = \'' + objectRecordTypeIdPatient + '\' AND ElixirSuite__Version__c = \'' + String.escapeSingleQuotes(icdVersion) + '\'' + queryIdClause + ' ORDER BY CreatedDate ASC LIMIT 200';

    for (SObject s : Database.query(query)) {
        recordsDataList.add(new RecordsData((String) s.get(filterField), (String) s.get('Id'),
                (String) s.get('ElixirSuite__Code_Description1__c')));
    }

    return recordsDataList;
}


@AuraEnabled
public static RecordsData fetchIcdRecords(String icdId){
    RecordsData rd;

    ElixirSuite__ICD_Codes__c icd = [SELECT Id,ElixirSuite__Code_Description1__c, Name FROM ElixirSuite__ICD_Codes__c  WHERE Id =: icdId] ;
    if(icd != null){
        rd = new RecordsData(icd.Name, icd.Id, icd.ElixirSuite__Code_Description1__c);
    }
    return rd;
}

public class RecordsData {
    @AuraEnabled public String label;
    @AuraEnabled public String value;
    @AuraEnabled public String description;

    public RecordsData(String label, String value,String description) {
        this.label = label;
        this.value = value;
        this.description = description;
    }
}
@AuraEnabled 
public static SearchWrapper searchRelatedProblem(String searchKeyWord, String icdVersion , string recordids){
    String searchKey = '%' + searchKeyWord + '%';
    List <ElixirSuite__Template_Diagnosis_Code__c> lstOfRecords =  [select id, Name,ElixirSuite__Template_Problem__r.Name,ElixirSuite__Template_Problem__r.ElixirSuite__Note__c,
                                                                    ElixirSuite__Diagnosis_Code__r.ElixirSuite__Code_Description1__c,ElixirSuite__Template_Problem__r.ElixirSuite__Description__c,
                                                                    ElixirSuite__Template_Problem__r.ElixirSuite__SNOMED_CT_Code__c,ElixirSuite__Template_Problem__r.Id,
                                                                    ElixirSuite__Diagnosis_Code__r.Name,ElixirSuite__Diagnosis_Code__r.ElixirSuite__Version__c,
                                                                    ElixirSuite__Diagnosis_Code__r.Id
                                                                    from ElixirSuite__Template_Diagnosis_Code__c
                                                                    where  ElixirSuite__Diagnosis_Code__r.Name LIKE: searchKey AND ElixirSuite__Diagnosis_Code__r.ElixirSuite__Version__c = :icdVersion WITH SECURITY_ENFORCED 
                                                                    limit 149];
        Id recordTypeId =
        Schema.SObjectType.ElixirSuite__ICD_Codes__c.getRecordTypeInfosByDeveloperName()
        .get('Template_Diagnosis_Code').getRecordTypeId();
        list<ElixirSuite__ICD_Codes__c> lstDiagnosisCode = [select id, Name,ElixirSuite__Version__c,
                                                            ElixirSuite__Code_Description1__c from ElixirSuite__ICD_Codes__c WHERE Id =: recordids and Name LIKE: searchKey AND ElixirSuite__Version__c =:icdVersion WITH SECURITY_ENFORCED];
    
    SearchWrapper toRet = new SearchWrapper();
    toRet.lstOfRecords = lstOfRecords;
    toRet.recTemplateProblem = lstDiagnosisCode;
    return toRet;
    
}
    @AuraEnabled 
public static List<RecordsData> searchProblemRelatedDiagnosis(String searchKeyWord, String icdVersion){
        List<RecordsData> recordsList = new List<RecordsData>();
    String searchKey =  searchKeyWord;
    List <ElixirSuite__Template_Diagnosis_Code__c> lstOfDiagnosisRecords =  [select id, Name,ElixirSuite__Template_Problem__r.Name,ElixirSuite__Template_Problem__r.ElixirSuite__Note__c,
                                                                    ElixirSuite__Diagnosis_Code__r.ElixirSuite__Code_Description1__c,ElixirSuite__Template_Problem__r.ElixirSuite__Description__c,
                                                                    ElixirSuite__Template_Problem__r.ElixirSuite__SNOMED_CT_Code__c,ElixirSuite__Template_Problem__r.Id,
                                                                    ElixirSuite__Diagnosis_Code__r.Name,ElixirSuite__Diagnosis_Code__r.ElixirSuite__Version__c,
                                                                    ElixirSuite__Diagnosis_Code__r.Id
                                                                    from ElixirSuite__Template_Diagnosis_Code__c
                                                                    where  ElixirSuite__Template_Problem__r.Name LIKE: searchKey AND ElixirSuite__Diagnosis_Code__r.Name!='' AND ElixirSuite__Diagnosis_Code__r.ElixirSuite__Version__c = :icdVersion  WITH SECURITY_ENFORCED 
                                                                    limit 149];
        for(ElixirSuite__Template_Diagnosis_Code__c s : lstOfDiagnosisRecords) {
        string diagnosisName = s.ElixirSuite__Diagnosis_Code__r.Name;
        string diagnosisId = s.ElixirSuite__Diagnosis_Code__r.Id;
        string diagnosisDesc = s.ElixirSuite__Diagnosis_Code__r.ElixirSuite__Code_Description1__c;
        recordsList.add( new RecordsData(diagnosisName,diagnosisId, diagnosisDesc));
        }
        return recordsList;

}
public class SearchWrapper{
    @AuraEnabled    public List <ElixirSuite__Template_Diagnosis_Code__c> lstOfRecords{ get; set; }
        @AuraEnabled    public   List<ElixirSuite__ICD_Codes__c> recTemplateProblem{ get; set; } 
} 

@AuraEnabled
public static List<RecordsData> insertDiagnosisCodesApex(String selectedRecords, String accountId) {

    Elixir_Custom_Setting__c customSetting = Elixir_Custom_Setting__c.getOrgDefaults();
    Boolean patientDiagnosis = customSetting.ElixirSuite__Allow_Patient_Diagnosis_On_RCM_Proceduer__c;
    List<RecordsData> recordsDataList = new List<RecordsData>();
    String query='';
    List<Id> insertedRecordIds = new List<Id>();
    List<ElixirSuite__ICD_Codes__c> insertedRecords = new List<ElixirSuite__ICD_Codes__c>();

    if (patientDiagnosis) {
        List<ElixirSuite__ICD_Codes__c> diagnosisCodesToInsert = new List<ElixirSuite__ICD_Codes__c>();

        Id objectRecordTypeIdPatient = Schema.SObjectType.ElixirSuite__ICD_Codes__c
            .getRecordTypeInfosByDeveloperName().get('Patient_Diagnosis_Code').getRecordTypeId();

        Map<String, Object> mainJson = (Map<String, Object>) JSON.deserializeUntyped(selectedRecords);
        List<Object> listOfProblems = (List<Object>) mainJson.get('keysToSave');

        List<String> aId = new List<String>();

        for (Object problemRec : listOfProblems) {
            Map<String, Object> selectedRecord = (Map<String, Object>) problemRec;
            aId.add(String.valueOf(selectedRecord.get('value')));
        }

        List<ElixirSuite__ICD_Codes__c> patientTempDiagnoses = [SELECT Id, Name, RecordType.Name, ElixirSuite__Code_Description1__c,
            ElixirSuite__Template_Diagnosis_Code__c, ElixirSuite__Account__c
            FROM ElixirSuite__ICD_Codes__c
            WHERE Id IN :aId WITH SECURITY_ENFORCED];

        for (ElixirSuite__ICD_Codes__c diagnosis : patientTempDiagnoses) {
            if (diagnosis.RecordType.Name == 'Template Diagnosis Code') {
                ElixirSuite__ICD_Codes__c diagnosisCode = new ElixirSuite__ICD_Codes__c();
                    diagnosisCode.Name = diagnosis.Name;
                    diagnosisCode.ElixirSuite__Code_Description1__c = diagnosis.ElixirSuite__Code_Description1__c;
                    diagnosisCode.ElixirSuite__Template_Diagnosis_Code__c = diagnosis.Id;
                    diagnosisCode.ElixirSuite__Account__c = accountId;
                    diagnosisCode.RecordTypeId = objectRecordTypeIdPatient;
               

                diagnosisCodesToInsert.add(diagnosisCode);
            }
        }

        if (!diagnosisCodesToInsert.isEmpty()) {
           DMLManager.insertAsUser(diagnosisCodesToInsert);
            // if(Schema.sObjectType.ElixirSuite__ICD_Codes__c.isCreateable()){
            /* Database.SaveResult[] srList = Database.insert(diagnosisCodesToInsert);
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    insertedRecordIds.add(sr.getId());
                }
}*/
            for(ElixirSuite__ICD_Codes__c ic:diagnosisCodesToInsert){
                 insertedRecordIds.add( ic.Id);
            }
            // Retrieve the inserted records with additional details if needed
            query = 'SELECT Id, Name, ElixirSuite__Code_Description1__c FROM ElixirSuite__ICD_Codes__c WHERE Id IN :insertedRecordIds WITH SECURITY_ENFORCED';
                
                 for (SObject s : Database.query(query)) {
                recordsDataList.add(new RecordsData((String) s.get('Name'), (String) s.get('Id'), (String) s.get('ElixirSuite__Code_Description1__c')));
            }
        //}
    }

    
}
return recordsDataList;
}
    // Apex method to delete an ICD code by record Id
    @AuraEnabled
    public static void deleteICDCode(String icdCodeId) {
        Elixir_Custom_Setting__c customSetting = Elixir_Custom_Setting__c.getOrgDefaults();
    Boolean patientDiagnosis = customSetting.ElixirSuite__Allow_Patient_Diagnosis_On_RCM_Proceduer__c;
        try {
            // Fetch the ICD Code record
            ElixirSuite__ICD_Codes__c icdCodeToDelete = [SELECT Id FROM ElixirSuite__ICD_Codes__c WHERE Id = :icdCodeId WITH SECURITY_ENFORCED LIMIT 1];

            // Check if the record exists
            if (icdCodeToDelete != null && patientDiagnosis) {
                // Delete the ICD Code record
                DMLManager.deleteAsUser(icdCodeToDelete);
               
            } 
        } catch (Exception e) {
             System.debug('Error deleting ICD Code: ' + e.getMessage());
        }
    }
}
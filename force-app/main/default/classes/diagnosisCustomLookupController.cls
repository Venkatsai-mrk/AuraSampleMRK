public with sharing class diagnosisCustomLookupController {

    @AuraEnabled
    public static List<RecordsData> fetchRecords(String objectName, String filterField, String searchString,
                                                 String value, String icdVersion, String accountId, 
                                                 Boolean filterOnAccountId,String startRecordId) {
        try {
         
        if (String.isBlank(icdVersion)) {
                icdVersion = MasterProblemListController.fetchDefaultValue(); 
            }
            String queryIdClause = '';
            Id objectRecordTypeIdPatient = Schema.SObjectType.ElixirSuite__ICD_Codes__c
                .getRecordTypeInfosByDeveloperName().get('Patient_Diagnosis_Code').getRecordTypeId();

           List<RecordsData> recordsDataList = new List<RecordsData>();

        // Call method to fetch patient diagnoses
            recordsDataList.addAll(fetchPatientDiagnosis(objectName, filterField, searchString, value, icdVersion,
                                    accountId, filterOnAccountId, startRecordId, objectRecordTypeIdPatient, queryIdClause));
      

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

            if (String.isNotBlank(value)) {
                query += ' WHERE Id = \'' + String.escapeSingleQuotes(value) + '\' LIMIT 200';
        } else if (filterOnAccountId) {
                               query += ' WHERE (ElixirSuite__Account__c = \'' + String.escapeSingleQuotes(accountId.trim()) + '\' AND ('
        + 'ElixirSuite__Code_Description1__c LIKE \'' + String.escapeSingleQuotes(searchString.trim()) + '%\' OR '
        + String.escapeSingleQuotes(filterField) + ' LIKE \'' + String.escapeSingleQuotes(searchString.trim()) + '%\')) LIMIT 200';
            } else {
               if (String.isNotBlank(startRecordId)) {
                queryIdClause = ' AND Id > :startRecordId';
            }

            query += ' WHERE ElixirSuite__Account__c =: accountId AND (' 
                    + String.escapeSingleQuotes(filterField) + ' LIKE \'' + String.escapeSingleQuotes(searchString.trim()) + '%\' OR '
                    + 'ElixirSuite__Code_Description1__c LIKE \'' + String.escapeSingleQuotes(searchString.trim()) + '%\') '
                    + 'AND RecordTypeId = \'' + objectRecordTypeIdPatient + '\' '
                    + 'AND ElixirSuite__Version__c = \'' + String.escapeSingleQuotes(icdVersion) + '\' ' 
                    + queryIdClause + ' ORDER BY CreatedDate ASC LIMIT 200';
        }

        for (SObject s : Database.query(query)) {
                            recordsDataList.add(new RecordsData((String) s.get(filterField), (String) s.get('id'),
                        (String) s.get('ElixirSuite__Code_Description1__c')));
                    }

        return recordsDataList;
	            }


    @AuraEnabled
    public static RecordsData fetchIcdRecords(String icdId){
        RecordsData rd;

        ElixirSuite__ICD_Codes__c icd = [SELECT Id,ElixirSuite__Code_Description1__c, Name FROM ElixirSuite__ICD_Codes__c  WHERE Id =: icdId WITH SECURITY_ENFORCED] ;
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
    public static SearchWrapper searchRelatedProblem(String searchKeyWord, String icdVersion ){
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
                                                             ElixirSuite__Code_Description1__c from ElixirSuite__ICD_Codes__c WHERE RecordTypeId=:recordTypeId and Name LIKE: searchKey AND ElixirSuite__Version__c =:icdVersion WITH SECURITY_ENFORCED];
       
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
    public static void insertDiagnosisCodesApex(String selectedRecords, String accountId) {
       
            system.debug('accountId12: ' + accountId +''+ selectedRecords);
             List<ElixirSuite__ICD_Codes__c> diagnosisCodesToInsert = new List<ElixirSuite__ICD_Codes__c>();
             Id objectRecordTypeIdPatient = Schema.SObjectType.ElixirSuite__ICD_Codes__c
                .getRecordTypeInfosByDeveloperName().get('Patient_Diagnosis_Code').getRecordTypeId();
Id objectRecordTypeIdTemplate = Schema.SObjectType.ElixirSuite__ICD_Codes__c
                .getRecordTypeInfosByDeveloperName().get('Template_Diagnosis_Code').getRecordTypeId();
            
             Map<String, Object> mainJson =(Map<String, Object>) JSON.deserializeUntyped(selectedRecords);
            List<string> aId= new List<string>();
              List<Object> listOfProblems = (List<Object>) mainJson.get('keysToSave');

            
              for(Object problemRec : listOfProblems){
                   
                Map<String, Object> selectedRecord = (Map<String, Object>) problemRec;
                   
                  aId.add(String.valueOf(selectedRecord.get('value')));
                   
            
              }

  List<ElixirSuite__ICD_Codes__c> patientDiagnoses = new  List<ElixirSuite__ICD_Codes__c>();
           patientDiagnoses  = [SELECT Id,Name ,RecordType.Name ,ElixirSuite__Code_Description1__c, ElixirSuite__Template_Diagnosis_Code__c, ElixirSuite__Account__c
                                                                FROM ElixirSuite__ICD_Codes__c
                                                                WHERE Id In : aId WITH SECURITY_ENFORCED];
        
for (ElixirSuite__ICD_Codes__c diagnosis : patientDiagnoses) {
    if (diagnosis.RecordType.Name == 'Template Diagnosis Code') {
        ElixirSuite__ICD_Codes__c diagnosisCode = new ElixirSuite__ICD_Codes__c();
        diagnosisCode.Name=diagnosis.Name;
        diagnosisCode.ElixirSuite__Code_Description1__c=diagnosis.ElixirSuite__Code_Description1__c;
        diagnosisCode.ElixirSuite__Template_Diagnosis_Code__c=diagnosis.Id;
        diagnosisCode.ElixirSuite__Account__c=accountId;
        diagnosisCode.RecordTypeId=objectRecordTypeIdPatient;
        
         diagnosisCodesToInsert.add(diagnosisCode);
        
    }
       
      
    }
        if(diagnosisCodesToInsert != null){
            DMLManager.insertAsUser(diagnosisCodesToInsert);}
      
    } 
    }
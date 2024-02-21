public with sharing class AddOnlyDiagnosisController {
public static Boolean checkDateNull(String toCheck){
        if(String.isNotBlank(toCheck)){
            return true;
        }
        else {
            return false;
        }
    }
    @AuraEnabled
    public static WrapperForICDVersion fetchICDVersion(){
        WrapperForICDVersion sObj = new WrapperForICDVersion();
        sObj.mapPickListValues = fetchPickListValue('ElixirSuite__ICD_Codes__c','ElixirSuite__Version__c');
        sObj.defValue = fetchDefaultValue();
        return sObj;
    }
    public class WrapperForICDVersion{
        @AuraEnabled public Map<String, String> mapPickListValues = new Map<String, String>();
        @AuraEnabled public String defValue;
    }
    public static String fetchDefaultValue(){
        String defaultVal;
        try{
            Schema.DescribeFieldResult F = ElixirSuite__ICD_Codes__c.ElixirSuite__Version__c.getDescribe();
            List <Schema.PicklistEntry> pickVals = F.getPicklistValues();        
            for (Schema.PicklistEntry pv: pickVals) {
                if (pv.isDefaultValue()) {
                    defaultVal = pv.getValue();
                }    
            }
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        return defaultVal;
        
    }
    public static  Map<String, String> fetchPickListValue(String strObjectName,String strPicklistField ){
        
        Map<String, String> mapPickListValues = new Map<String, String>();
        Schema.SObjectType objSobjectType = Schema.getGlobalDescribe().get(strObjectName);
        Schema.DescribeSObjectResult objDescribeSobject = objSobjectType.getDescribe();
        Map<String, Schema.SObjectField> mapFields = objDescribeSobject.fields.getMap();
        List<Schema.PicklistEntry> lstPickListValues = mapFields.get(strPicklistField).getDescribe().getPickListValues();
        for (Schema.PicklistEntry objPickList : lstPickListValues) {
            mapPickListValues.put(objPickList.getValue(),objPickList.getLabel());
            
        }
        return mapPickListValues;
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
                                                                        limit 49999];
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
    
    public class SearchWrapper{
        @AuraEnabled    public List <ElixirSuite__Template_Diagnosis_Code__c> lstOfRecords{ get; set; }
        @AuraEnabled    public   List<ElixirSuite__ICD_Codes__c> recTemplateProblem{ get; set; } 
    } 
    
    public static String checkForEncounter(String accountId){
        String encounterId;
        try{
            Elixir_Custom_Setting__c customSetting = Elixir_Custom_Setting__c.getOrgDefaults();
            String careFilter = customSetting.ElixirSuite__Default_Active_Care_Episode_Filter__c;
            if(string.isBlank(careFilter)){
                careFilter = 'createddate desc';
            }
            String careStatus = 'Active';
            
            string querystr = '';
            querystr += 'Select Id,ElixirSuite__Account__c,ElixirSuite__Status__c from ElixirSuite__Visits__c where ElixirSuite__Status__c=:careStatus AND ElixirSuite__Account__c = : accountId WITH SECURITY_ENFORCED order by ';
            querystr += careFilter ;
            ElixirSuite__Visits__c[] lastEncounter = database.query(querystr);
            //end by Anmol for LX3-7236
            
            if(lastEncounter!=null && lastEncounter.size()>0){
                encounterId = lastEncounter[0].Id;
            }
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        return encounterId;
    }
    
    @AuraEnabled
    public static List<String> saveOnlyDiagnosisRec(String payload,String accountId){
        Map<String, Object> lstOfPayload =(Map<String, Object>) JSON.deserializeUntyped(payload);
        List<Object> listOfDiagnosis = (List<Object>) lstOfPayload.get('keysToSave');
        List<ElixirSuite__ICD_Codes__c> icds = new List<ElixirSuite__ICD_Codes__c>();
        List<ElixirSuite__Diagnosis_Code__c> dc = new List<ElixirSuite__Diagnosis_Code__c>();
        List<string> icdIds = new list<string>();
        List<ID> icdIdsAfterSave = new list<ID>();
        Id objectRecordTypeId = Schema.SObjectType.ElixirSuite__ICD_Codes__c.getRecordTypeInfosByDeveloperName().get('Patient_Diagnosis_Code').getRecordTypeId();
        
        String formUniqueId = String.valueOf(lstOfPayload.get('formUniqueId'));
        String formValue;

        if(String.isNotBlank(formUniqueId)){
            formValue = [SELECT ID,ElixirSuite__Form_Id__c FROM ElixirSuite__Form_Value__c WHERE ElixirSuite__Form_Id__c =: formUniqueId AND ElixirSuite__Form_Detail__c = TRUE].ID;
        }

        for(Object diagnosisRec : listOfDiagnosis){
            Map<String, Object> obj_Record = (Map<String, Object>) diagnosisRec;
            icdIds.add(string.valueOf(obj_Record.get('ICDId')));
        }
        List<ElixirSuite__ICD_Codes__c> tempDiagnosisCode = [SELECT Id, Name, RecordTypeId, ElixirSuite__Account__c, 
                                                             ElixirSuite__Version__c, ElixirSuite__Long_Description__c, 
                                                             ElixirSuite__Code_Description1__c, ElixirSuite__Active__c, 
                                                             ElixirSuite__Effective_Date__c, ElixirSuite__Termination_Date__c,
                                                             ElixirSuite__Template_Diagnosis_Code__c,Elixirsuite__care_episode__c,
                                                             Elixirsuite__diagnosed_by__c,Elixirsuite__diagnosis_attestation_on__c,
                                                             Elixirsuite__diagnosis_type__c,Elixirsuite__diagnosis_code_and_name__c 
                                                             FROM ElixirSuite__ICD_Codes__c WHERE id IN : icdIds WITH SECURITY_ENFORCED];
        
        //map of icds
        Map<Id,ElixirSuite__ICD_Codes__c> mapIcds = new Map<Id,ElixirSuite__ICD_Codes__c>(tempDiagnosisCode);
        if(listOfDiagnosis != null && !listOfDiagnosis.isEmpty()){
            for(Object diagnosisRec : listOfDiagnosis){
                Map<String, Object> obj_Record = (Map<String, Object>) diagnosisRec;
                
                ElixirSuite__ICD_Codes__c relatedDiagnosis;
                if(mapIcds.containsKey((Id)obj_Record.get('ICDId'))){
                    relatedDiagnosis = mapIcds.get((Id)obj_Record.get('ICDId')).clone(false, false, false, false);
                }
                
                relatedDiagnosis.ElixirSuite__Account__c = accountId;
                relatedDiagnosis.RecordTypeId = objectRecordTypeId;
                relatedDiagnosis.ElixirSuite__Code_Description1__c = String.valueOf(obj_Record.get('ICDDescription'));
                relatedDiagnosis.ElixirSuite__Diagnosis_Type__c = String.valueOf(obj_Record.get('DiagnosisType'));
                relatedDiagnosis.ElixirSuite__Notes__c= String.valueOf(obj_Record.get('Notes'));
                relatedDiagnosis.ElixirSuite__Is_Patient_Specific__c = true;
                
                if(!Boolean.valueOf(String.valueOf(obj_Record.get('IsPatientDiagnosis')))){
                    relatedDiagnosis.ElixirSuite__Template_Diagnosis_Code__c = String.valueOf(obj_Record.get('ICDId'));
                }
                if(checkDateNull(String.valueOf(obj_Record.get('DateDiagnoses')))){
                    relatedDiagnosis.ElixirSuite__Effective_Date__c = Date.valueOf(String.valueOf(obj_Record.get('DateDiagnoses')));
                }  
                if(String.isNotBlank(checkForEncounter(accountId))){
                    relatedDiagnosis.ElixirSuite__Care_Episode__c = checkForEncounter(accountId);
                }
                if(String.isNotBlank(formValue)){
                    relatedDiagnosis.ElixirSuite__Form_Value__c = formValue;
                }
                icds.add(relatedDiagnosis);  
            }
        }
    
    if(icds != null && !icds.isEmpty()){
        if(Schema.sObjectType.ElixirSuite__ICD_Codes__c.isCreateable()){
            Database.SaveResult[] srList = Database.insert(icds);
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    icdIdsAfterSave.add(sr.getId());
                }
            }
        }
    }
    if(icdIdsAfterSave != null && !icdIdsAfterSave.isEmpty()){
        for(Id icd : icdIdsAfterSave){
            ElixirSuite__Diagnosis_Code__c sObjRecJuntion  = new ElixirSuite__Diagnosis_Code__c();
            sObjRecJuntion.ElixirSuite__Diagnosis_Code__c = icd;
            dc.add(sObjRecJuntion);
        }
    }
    
    if(dc!= null && !dc.isEmpty()){
        if(Schema.sObjectType.ElixirSuite__Diagnosis_Code__c.isCreateable()){
            Database.insert(dc);
        }
    }

    return icdIdsAfterSave;
}
    public class RecordsData {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        @AuraEnabled public String description;
        @AuraEnabled public String version;
        @AuraEnabled public String diagnosisType;
        @AuraEnabled public String notes;
        @AuraEnabled public Date dateOnDiagnoses;

        public RecordsData(String label, String value,String description,String version,String diagnosisType,String notes,Date dateOnDiagnoses) {
            this.label = label;
            this.value = value;
            this.description = description;
            this.version = version;
            this.diagnosisType = diagnosisType;
            this.notes = notes;
            this.dateOnDiagnoses = dateOnDiagnoses;
        }
    }

    @AuraEnabled
    public static List<RecordsData> fetchRecords(String objectName, String filterField, String searchString, String accountId, String startRecordId) {
        try {
            String queryIdClause = '';
            List<RecordsData> recordsDataList = new List<RecordsData>();
            Id objectRecordTypeId = Schema.SObjectType.ElixirSuite__ICD_Codes__c.getRecordTypeInfosByDeveloperName().get('Patient_Diagnosis_Code').getRecordTypeId();
            String query = 'SELECT Id,ElixirSuite__Code_Description1__c,ElixirSuite__Version__c,ElixirSuite__Diagnosis_Type__c,ElixirSuite__Notes__c,ElixirSuite__Effective_Date__c, ' + String.escapeSingleQuotes(filterField) + ' FROM '+ String.escapeSingleQuotes(objectName);
            
            if (String.isNotBlank(startRecordId)) {
                queryIdClause = ' AND Id > :startRecordId';
            }
    
            query += ' WHERE ' 
            + String.escapeSingleQuotes(filterField) + ' LIKE \'' + String.escapeSingleQuotes(searchString.trim()) + '%\''
            + ' AND ElixirSuite__Account__c = \'' + String.escapeSingleQuotes(accountId.trim()) + '\''
            + ' AND RecordTypeId = \'' + objectRecordTypeId + '\''
            + queryIdClause + ' WITH SECURITY_ENFORCED ORDER BY CreatedDate ASC LIMIT 200';
            for(SObject s : Database.query(query)) {
                recordsDataList.add( new RecordsData((String)s.get(filterField), (String)s.get('id'), (String)s.get('ElixirSuite__Code_Description1__c'),(String)s.get('ElixirSuite__Version__c'), (String)s.get('ElixirSuite__Diagnosis_Type__c'), (String)s.get('ElixirSuite__Notes__c'), (Date)s.get('ElixirSuite__Effective_Date__c')));
            }
                return recordsDataList;
	        } 
            catch (Exception err) {
	    	    if ( String.isNotBlank( err.getMessage() ) && err.getMessage().contains( 'error:' ) ) {
                    throw new AuraHandledException(err.getMessage().split('error:')[1].split(':')[0] + '.');
                } else {
                    throw new AuraHandledException(err.getMessage());
                }
	        }
    }

    public class TemplateRecordsData {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        @AuraEnabled public String description;

        public TemplateRecordsData(String label, String value,String description) {
            this.label = label;
            this.value = value;
            this.description = description;
        }
    }

    @AuraEnabled
    public static List<TemplateRecordsData> fetchTemplateRecords(String objectName, String filterField, String searchString,
                                                 String value, String icdVersion, String accountId, 
                                                 Boolean filterOnAccountId,String startRecordId) {
        try {
           
            if(String.isBlank(icdVersion)){
                icdVersion = MasterProblemListController.fetchDefaultValue(); 
            }
            String queryIdClause = '';
            Id objectRecordTypeIdTemplate = Schema.SObjectType.ElixirSuite__ICD_Codes__c.getRecordTypeInfosByDeveloperName().get('Template_Diagnosis_Code').getRecordTypeId();
           
            List<TemplateRecordsData> recordsDataList = new List<TemplateRecordsData>();
            String query = 'SELECT Id,ElixirSuite__Code_Description1__c, ' + String.escapeSingleQuotes(filterField) + ' FROM '+ String.escapeSingleQuotes(objectName);
            if(String.isNotBlank(value)) {
                query += ' WHERE Id = \''+ String.escapeSingleQuotes(value) + '\' WITH SECURITY_ENFORCED LIMIT 200';
            }
            else if (filterOnAccountId) {
                query += ' WHERE (ElixirSuite__Account__c = \'' + String.escapeSingleQuotes(accountId.trim()) + '\' AND ('
                + 'ElixirSuite__Code_Description1__c LIKE \'' + String.escapeSingleQuotes(searchString.trim()) + '%\' OR '
                + String.escapeSingleQuotes(filterField) + ' LIKE \'' + String.escapeSingleQuotes(searchString.trim()) + '%\')) WITH SECURITY_ENFORCED LIMIT 200';
            }
            else {
                if(String.isNotBlank(startRecordId)){                   
                    queryIdClause = ' AND Id > :startRecordId';
                }
                
                query +=  ' WHERE (' 
                + String.escapeSingleQuotes(filterField) + ' LIKE \'' + String.escapeSingleQuotes(searchString.trim()) + '%\' OR '
                + 'ElixirSuite__Code_Description1__c LIKE \'' + String.escapeSingleQuotes(searchString.trim()) + '%\') '
                + 'AND RecordTypeId = \'' + objectRecordTypeIdTemplate + '\' '
                + 'AND ElixirSuite__Version__c = \'' + String.escapeSingleQuotes(icdVersion) + '\' ' 
                + queryIdClause + ' ORDER BY CreatedDate ASC LIMIT 200';}
            
          
                for(SObject s : Database.query(query)) {
                    recordsDataList.add( new TemplateRecordsData((String)s.get(filterField), (String)s.get('id'), (String)s.get('ElixirSuite__Code_Description1__c')));
                }
                return recordsDataList;
	        } 
            catch (Exception err) {
	    	    if ( String.isNotBlank( err.getMessage() ) && err.getMessage().contains( 'error:' ) ) {
                    throw new AuraHandledException(err.getMessage().split('error:')[1].split(':')[0] + '.');
                } else {
                    throw new AuraHandledException(err.getMessage());
                }
	        }
    }
}
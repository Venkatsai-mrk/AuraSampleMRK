public with sharing class AddOnlyProblemController {
    
    public static Boolean checkDateNull(String toCheck){
        if(String.isNotBlank(toCheck)){
            return true;
        }
        else {
            return false;
        }
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
    public static List<String> saveOnlyProblemRec(String payload,String accountId){
        Map<String, Object> lstOfPayload =(Map<String, Object>) JSON.deserializeUntyped(payload);
        List<Object> listOfProblems = (List<Object>) lstOfPayload.get('keysToSave');
        List<ElixirSuite__Dataset1__c> ds1 = new List<ElixirSuite__Dataset1__c>();
        List<ElixirSuite__Diagnosis_Code__c> dc = new List<ElixirSuite__Diagnosis_Code__c>();
        List<ID> datasetIds = new list<ID>();
        List<string> patientProblemIds = new list<string>();
        String formUniqueId = String.valueOf(lstOfPayload.get('formUniqueId'));
        String formValue;
        
        for(Object problemRec : listOfProblems){
            Map<String, Object> obj_Record = (Map<String, Object>) problemRec;
            if(Boolean.valueOf(String.valueOf(obj_Record.get('IsPatientProblem')))){
                patientProblemIds.add(string.valueOf(obj_Record.get('ExistingProblemId')));
            }
            
        }
        List<ElixirSuite__Dataset1__c> patientProblem = [SELECT id, name, ElixirSuite__account__c, 
                                                         ElixirSuite__date_diagonised__c, ElixirSuite__date_onset__c, 
                                                         ElixirSuite__description__c, ElixirSuite__icd_codes__c, 
                                                         ElixirSuite__note__c, ElixirSuite__problem_type__c, 
                                                         ElixirSuite__snomed_ct_code__c, ElixirSuite__status__c, 
                                                         ElixirSuite__template_problem__c, ElixirSuite__diagnosis_type__c, 
                                                         ElixirSuite__icd_description__c, ElixirSuite__end_date__c 
                                                         FROM ElixirSuite__Dataset1__c WHERE id IN : patientProblemIds WITH SECURITY_ENFORCED];
        //map of patient problem
        Map<Id,ElixirSuite__Dataset1__c> mapProblems = new Map<Id,ElixirSuite__Dataset1__c>(patientProblem);

        if(String.isNotBlank(formUniqueId)){
            formValue = [SELECT ID,ElixirSuite__Form_Id__c FROM ElixirSuite__Form_Value__c WHERE ElixirSuite__Form_Id__c =: formUniqueId AND ElixirSuite__Form_Detail__c = TRUE].ID;
        }

        
        if(listOfProblems != null && !listOfProblems.isEmpty()){
            for(Object problemRec : listOfProblems){
                Map<String, Object> obj_Record = (Map<String, Object>) problemRec;
                
                ElixirSuite__Dataset1__c sObj;
                if(String.valueOf(obj_Record.get('ProblemId'))!=null && string.isNotBlank(String.valueOf(obj_Record.get('ProblemId')))){
                    //check if problem is patient problem, then clone the existing record
                    if(Boolean.valueOf(String.valueOf(obj_Record.get('IsPatientProblem'))) && mapProblems.containsKey((Id)obj_Record.get('ExistingProblemId'))){
                        sObj = mapProblems.get((Id)obj_Record.get('ExistingProblemId')).clone(false, false, false, false);
                    }
                    else{
                        //if problem is template problem, then create a new instance of dataset 1
                        sObj = new ElixirSuite__Dataset1__c();
                    }
                    
                    
                    sObj.Name = String.valueOf(obj_Record.get('ProblemName'));
                    sObj.ElixirSuite__Account__c = accountId;
                    sObj.ElixirSuite__Problem_Type__c = String.valueOf(obj_Record.get('ProblemType'));
                    sObj.ElixirSuite__Status__c = String.valueOf(obj_Record.get('Status'));
                    sObj.ElixirSuite__Template_Problem__c =  String.valueOf(obj_Record.get('ProblemId'));
                    sObj.ElixirSuite__SNOMED_CT_Code__c = String.valueOf(obj_Record.get('SNOMEDCTCode'));
                    sObj.ElixirSuite__Description__c = String.valueOf(obj_Record.get('ProblemDescription'));
                    sObj.ElixirSuite__Note__c = String.valueOf(obj_Record.get('Notes'));
                    
                    if(checkDateNull(String.valueOf(obj_Record.get('DateDiagnised')))){
                        sObj.ElixirSuite__Date_Diagonised__c = Date.valueOf(String.valueOf(obj_Record.get('DateDiagnised')));           
                    }
                    if(checkDateNull(String.valueOf(obj_Record.get('DateOnset')))){
                        sObj.ElixirSuite__Date_Onset__c = Date.valueOf(String.valueOf(obj_Record.get('DateOnset')));
                    }
                    if(checkDateNull(String.valueOf(obj_Record.get('EndDate')))){
                        sObj.ElixirSuite__End_Date__c = Date.valueOf(String.valueOf(obj_Record.get('EndDate')));
                    }
                    if(String.isNotBlank(checkForEncounter(accountId))){
                        sObj.ElixirSuite__Care_Episode__c = checkForEncounter(accountId);
                    }
                    if(String.isNotBlank(formValue)){
                        sObj.ElixirSuite__Form_Value__c = formValue;
                    }
                    // insert sObj;
                    ds1.add(sObj);  
                }
            }
        }
        if(ds1 != null && !ds1.isEmpty()){
            if(Schema.sObjectType.ElixirSuite__Dataset1__c.isCreateable()){
                Database.SaveResult[] srList = Database.insert(ds1);
                for (Database.SaveResult sr : srList) {
                    if (sr.isSuccess()) {
                        datasetIds.add(sr.getId());
                    }
                }
            }
        }
        if(datasetIds != null && !datasetIds.isEmpty()){
            for(Id dsIds : datasetIds){
                ElixirSuite__Diagnosis_Code__c sObjRecJuntion  = new ElixirSuite__Diagnosis_Code__c();
                sObjRecJuntion.ElixirSuite__Problem__c = dsIds;
                dc.add(sObjRecJuntion);
            }
        }
        
        if(dc!= null && !dc.isEmpty()){
            if(Schema.sObjectType.ElixirSuite__Diagnosis_Code__c.isCreateable()){
                Database.insert(dc);
            }
        }
        
        return datasetIds;
    }
    
    public class Searchwrapper{
        @AuraEnabled    public List <ElixirSuite__Template_Diagnosis_Code__c> lstOfRecords{ get; set; }
        @AuraEnabled    public   List<ElixirSuite__Template_Problem__c> recTemplateProblem{ get; set; }  
        
    }
    
    @AuraEnabled 
    public static Searchwrapper searchOnlyProblem(String searchKeyWord){
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
                                                                        OR ElixirSuite__Template_Problem__r.ElixirSuite__SNOMED_CT_Code__c LIKE: searchKey) 
                                                                        AND ElixirSuite__Template_Problem__r.Name!=''
                                                                      WITH SECURITY_ENFORCED limit 49999];
       
         Set<Id> problemSet = new Set<Id>();
        for(ElixirSuite__Template_Diagnosis_Code__c sObj : lstOfRecords){
            problemSet.add(sObj.ElixirSuite__Template_Problem__r.Id);
        }
        Id problemRecType = Schema.SObjectType.ElixirSuite__Template_Problem__c.getRecordTypeInfosByDeveloperName().get('Problem').getRecordTypeId();
        List<ElixirSuite__Template_Problem__c> recTemplateProblem = [SELECT ID,Name,ElixirSuite__SNOMED_CT_Code__c,ElixirSuite__Status__c,ElixirSuite__Description__c,
                                                                     ElixirSuite__Note__c
                                                                     from ElixirSuite__Template_Problem__c WHERE RecordTypeId =: problemRecType AND Name LIKE: searchKey
                                                                     AND ID NOT IN : problemSet WITH SECURITY_ENFORCED limit 49999];
        Searchwrapper toRet = new Searchwrapper();
        toRet.lstOfRecords = lstOfRecords;
        toRet.recTemplateProblem = recTemplateProblem;
        return toRet;
    }

    public class RecordsData {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        @AuraEnabled public String description;
        @AuraEnabled public String problemType;
        @AuraEnabled public String status;
        @AuraEnabled public String tempProbId;
        @AuraEnabled public String snowmed;
        @AuraEnabled public String notes;
        @AuraEnabled public Date dateOnset;
        @AuraEnabled public Date endDate;

        public RecordsData(String label, String value,String description,String problemType,String status,String tempProbId,String snowmed,String notes,Date dateOnset, Date endDate) {
            this.label = label;
            this.value = value;
            this.description = description;
            this.problemType = problemType;
            this.status = status;
            this.tempProbId = tempProbId;
            this.snowmed = snowmed;
            this.notes = notes;
            this.dateOnset = dateOnset;
            this.endDate = endDate;
        }
    }

    @AuraEnabled
    public static List<RecordsData> fetchRecords(String objectName, String filterField, String searchString, String accountId, String startRecordId) {
        try {
            String queryIdClause = '';
            List<RecordsData> recordsDataList = new List<RecordsData>();
            String query = 'SELECT Id,ElixirSuite__Description__c,ElixirSuite__Problem_Type__c,ElixirSuite__Status__c,ElixirSuite__Template_Problem__c,ElixirSuite__SNOMED_CT_Code__c,ElixirSuite__Note__c,ElixirSuite__Date_Onset__c,ElixirSuite__End_Date__c, ' + String.escapeSingleQuotes(filterField) + ' FROM '+ String.escapeSingleQuotes(objectName);
            
            if (String.isNotBlank(startRecordId)) {
                queryIdClause = ' AND Id > :startRecordId';
            }
    
            query += ' WHERE ' 
            + String.escapeSingleQuotes(filterField) + ' LIKE \'' + String.escapeSingleQuotes(searchString.trim()) + '%\''
            + ' AND ElixirSuite__Account__c = \'' + String.escapeSingleQuotes(accountId.trim()) + '\''
            + queryIdClause + ' ORDER BY CreatedDate ASC LIMIT 200';
            for(SObject s : Database.query(query)) {
                recordsDataList.add( new RecordsData((String)s.get(filterField), (String)s.get('id'), (String)s.get('ElixirSuite__Description__c'),(String)s.get('ElixirSuite__Problem_Type__c'), (String)s.get('ElixirSuite__Status__c'), (String)s.get('ElixirSuite__Template_Problem__c'), (String)s.get('ElixirSuite__SNOMED_CT_Code__c'), (String)s.get('ElixirSuite__Note__c'), (Date)s.get('ElixirSuite__Date_Onset__c'), (Date)s.get('ElixirSuite__End_Date__c')));
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
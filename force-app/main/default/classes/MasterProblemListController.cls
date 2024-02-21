public with sharing class MasterProblemListController {
    //Added by Ashwini//
    @AuraEnabled
    public static string fetchAccountName(string accountId){
        List<Account> acc=[SELECT Id, name FROM Account WHERE Id= :accountId WITH SECURITY_ENFORCED];
        string accName = acc[0].name;
        return accName;
    }
    //End
   
    @AuraEnabled
    public static wrapper problemListDup(String accountId ){
        // String query ;
        //query = 'SELECT Id, Name, ElixirSuite__Account__c,CreatedDate,CreatedBy.Name,LastModifiedDate , ElixirSuite__Problem_Type__c, ElixirSuite__Description__c, ElixirSuite__Date_Diagonised__c, ElixirSuite__Note__c, ElixirSuite__Date_Onset__c, ElixirSuite__SNOMED_CT_Code__c, ElixirSuite__Template_Problem__c, ElixirSuite__Status__c,ElixirSuite__Diagnosis_Type__c FROM ElixirSuite__Dataset1__c'+ 
          //  'where ElixirSuite__Account__c=:accountId order by createddate desc';
        String encId = '';
       /* if(String.isNotBlank(checkForEncounter(accountId))){
            encId = checkForEncounter(accountId);
            query = 'SELECT Id, Name, ElixirSuite__Account__c, ElixirSuite__Problem_Type__c, ElixirSuite__Description__c, ElixirSuite__Date_Diagonised__c,'+
                'ElixirSuite__Note__c, ElixirSuite__Date_Onset__c, ElixirSuite__SNOMED_CT_Code__c, ElixirSuite__Template_Problem__c, '+
                'ElixirSuite__Status__c,CreatedDate,CreatedBy.Name,LastModifiedDate FROM ElixirSuite__Dataset1__c WHERE ElixirSuite__Account__c=:accountId AND ElixirSuite__Care_Episode__c = : encId order by CreatedDate desc';
        }
        else{*/
            List<ElixirSuite__Dataset1__c> listOfencounter = [SELECT Id, Name,CreatedDate,CreatedBy.Name,LastModifiedDate, ElixirSuite__Account__c, ElixirSuite__Problem_Type__c, ElixirSuite__Description__c, ElixirSuite__Date_Diagonised__c, ElixirSuite__Note__c, ElixirSuite__Date_Onset__c, ElixirSuite__SNOMED_CT_Code__c, ElixirSuite__Template_Problem__c, ElixirSuite__Status__c,ElixirSuite__Diagnosis_Type__c FROM ElixirSuite__Dataset1__c WHERE ElixirSuite__Account__c=:accountId WITH SECURITY_ENFORCED order by CreatedDate desc];
      //  }
        
       //(pawanchanges) List<ElixirSuite__Dataset1__c> listOfencounter = Database.query(query);
        String namespace = Elixir_utility.getNameSpace();
        Wrapper wrpr = new Wrapper();
        wrpr.lstOfAllProblemPerAccountdup = listOfencounter;
        wrpr.columns = ProblemColumnConfiguration.getProblemColumns();
        return wrpr;
        
    }
    
     @AuraEnabled
    public static wrapper problemList(String accountId ){
        accountId = String.escapeSingleQuotes(accountId);
        Elixir_Custom_Setting__c customSetting = Elixir_Custom_Setting__c.getOrgDefaults();
        Boolean careEpisodeBasedFilter=customSetting.ElixirSuite__Care_Episode_based_filtering_for_Notes__c;
        String query ;
       // query = 'select id, name ,LastModifiedDate, ElixirSuite__Problem__r.ElixirSuite__Template_Problem__c,   ElixirSuite__Account__c,ElixirSuite__Description__c,Problem_Name__c from ElixirSuite__Diagnosis_Code__c'+ 
         //   'where ElixirSuite__Problem__r.Id=:accountId WITH SECURITY_ENFORCED order by createddate desc ';
        String encId = '';
       if(String.isNotBlank(checkForEncounter(accountId))  && careEpisodeBasedFilter == true){
            encId = checkForEncounter(accountId);
            encId = String.escapeSingleQuotes(encId);
            query = 'SELECT ID,Name,ElixirSuite__Problem__r.Id,ElixirSuite__Problem__r.Name, ElixirSuite__Problem__r.ElixirSuite__Date_Diagonised__c, ElixirSuite__Problem__r.ElixirSuite__Template_Problem__c,'+
                'ElixirSuite__Problem__r.ElixirSuite__Date_Onset__c, ElixirSuite__Problem__r.ElixirSuite__Problem_Type__c, ElixirSuite__Problem__r.ElixirSuite__Status__c, '+
                'ElixirSuite__Problem__r.ElixirSuite__Note__c,ElixirSuite__Problem__r.ElixirSuite__SNOMED_CT_Code__c, ElixirSuite__Diagnosis_Code__r.Id,ElixirSuite__Diagnosis_Code__r.ElixirSuite__Diagnosis_Type__c,ElixirSuite__Diagnosis_Code__r.ElixirSuite__Code_Description1__c,ElixirSuite__Diagnosis_Code__r.Name,'+
                'ElixirSuite__Diagnosis_Code__r.ElixirSuite__Version__c,CreatedDate,CreatedBy.Name,LastModifiedDate FROM ElixirSuite__Diagnosis_Code__c WHERE (ElixirSuite__Problem__r.ElixirSuite__Account__c =:accountId OR ElixirSuite__Diagnosis_Code__r.ElixirSuite__Account__c =:accountId) AND (ElixirSuite__Problem__r.ElixirSuite__Care_Episode__c = : encId OR ElixirSuite__Diagnosis_Code__r.ElixirSuite__Care_Episode__c = : encId)  WITH SECURITY_ENFORCED order by CreatedDate desc';
        }
        else{
            query = 'SELECT ID,Name,ElixirSuite__Problem__r.Id,ElixirSuite__Problem__r.Name, ElixirSuite__Problem__r.ElixirSuite__Template_Problem__c,CreatedBy.Name,ElixirSuite__Problem__r.ElixirSuite__Date_Diagonised__c,'+
                'ElixirSuite__Problem__r.ElixirSuite__Date_Onset__c, ElixirSuite__Problem__r.ElixirSuite__Problem_Type__c, ElixirSuite__Problem__r.ElixirSuite__Status__c,ElixirSuite__Diagnosis_Code__r.ElixirSuite__Diagnosis_Type__c,ElixirSuite__Diagnosis_Code__r.ElixirSuite__Code_Description1__c,'+
                ' ElixirSuite__Problem__r.ElixirSuite__Note__c,ElixirSuite__Problem__r.ElixirSuite__SNOMED_CT_Code__c, ElixirSuite__Diagnosis_Code__r.Id,ElixirSuite__Diagnosis_Code__r.Name, ElixirSuite__Diagnosis_Code__r.ElixirSuite__Version__c,CreatedDate,LastModifiedDate FROM ElixirSuite__Diagnosis_Code__c '+
                ' WHERE  ElixirSuite__Problem__r.ElixirSuite__Account__c =:accountId OR ElixirSuite__Diagnosis_Code__r.ElixirSuite__Account__c =:accountId WITH SECURITY_ENFORCED order by CreatedDate desc ';
        }
        List<ElixirSuite__Diagnosis_Code__c> listOfencounter = Database.query(query);
        String namespace = Elixir_utility.getNameSpace();
        Wrapper wrpr = new Wrapper();
        wrpr.lstOfAllProblemPerAccount = listOfencounter;
        wrpr.columns = ProblemColumnConfiguration.getProblemColumns();
        return wrpr;
        
    }
    
    public class Wrapper{
        @AuraEnabled public ProblemColumnConfiguration.newWrapper columns;
        @AuraEnabled public String namespace;
        @AuraEnabled public List<ElixirSuite__Diagnosis_Code__c> lstOfAllProblemPerAccount;
        @AuraEnabled public List<ElixirSuite__Dataset1__c> lstOfAllProblemPerAccountdup;
    }
    
    @AuraEnabled
    public static WrapperForNewScreen newScreenProblemDomain(){
        WrapperForNewScreen sObj = new WrapperForNewScreen();
        sObj.mapPickListValues = fetchPickListValue('ElixirSuite__ICD_Codes__c','ElixirSuite__Version__c');
        sObj.defValue = fetchDefaultValue();
        return sObj;
    }
    public class WrapperForNewScreen{
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
    public static  Map<String, String> fetchClaimTypePickListValue(String strObjectName,String strPicklistField ){

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
    public static  Map<String, String> fetchDefaultPickListValue(String strObjectName,String strPicklistField ){
        
        Map<String, String> mapPickListValues = new Map<String, String>();
        Schema.SObjectType objSobjectType = Schema.getGlobalDescribe().get(strObjectName);
        Schema.DescribeSObjectResult objDescribeSobject = objSobjectType.getDescribe();
        Map<String, Schema.SObjectField> mapFields = objDescribeSobject.fields.getMap();
        List<Schema.PicklistEntry> lstPickListValues = mapFields.get(strPicklistField).getDescribe().getPickListValues();
        for (Schema.PicklistEntry objPickList : lstPickListValues) {
           if (objPickList.isDefaultValue()){
            mapPickListValues.put(objPickList.getValue(),objPickList.getLabel());
         }
        }
        return mapPickListValues;
    }
   
   /* @AuraEnabled
    public static Dataset1__c deleteRecords(String encounterId ){
        if(String.isNotBlank(encounterId)){
            Dataset1__c c = new Dataset1__c();
            c=[select id from Dataset1__c where id=:encounterId];
            if(Dataset1__c.sObjectType.getDescribe().isUpdateable()){
                if(Schema.sObjectType.Dataset1__c.isDeletable()){
                //delete c;
       DMLManager.deleteAsUser(c);
                }
            }
            return c;
        }
        else {
            return null;
        }
    }*/
    
    @AuraEnabled    
    public static List < String > deleteAllEncounter(List < String > lstRecordId) {
        
        // for store Error Messages 
        
        List < String > oErrorMsg = new List < String > ();                
        // Query Records for delete where id in lstRecordId [which is pass from client side controller]
        try{
        List < Dataset1__c > lstDeleteRec = [select Id from Dataset1__c where id IN: lstRecordId WITH SECURITY_ENFORCED];
        if(!Dataset1__c.sObjectType.getDescribe().isDeletable()){
            return new List<String>{};
                }
        
      //  Database.DeleteResult[] DR_Dels = Database.delete(lstDeleteRec, false);
        Database.DeleteResult[] DR_Dels =DMLManagerV2.deleteAsUser(lstDeleteRec, false); 
        // Iterate through each returned result
        
        for (Database.DeleteResult dr: DR_Dels) {
            
            if (dr.isSuccess()) {
                
                                       
            } else {
                oErrorMsg.add('');
                
                for (Database.Error err: dr.getErrors()) {                            
                    oErrorMsg.add(err.getStatusCode() + ': ' + err.getMessage());     
                }
                
            }
        }

        }
            catch(Exception e){
            ExceptionLog.logError(e);
        }
        
        return oErrorMsg;
    }
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
        
                //added by Anmol for LX3-7236
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
   
   /* @AuraEnabled
   public static void saveProblemsIfCancel(String payload){
        Map<String, Object> lstOfPayload =(Map<String, Object>) JSON.deserializeUntyped(payload);
        List<Object> problemDelLst = (List<Object>) lstOfPayload.get('delRecords');   
        for(Object sObjRec : problemDelLst){
            Map<String, Object> mapOfRec = (Map<String, Object>) sObjRec;
            ElixirSuite__Dataset1__c problemsObj = (ElixirSuite__Dataset1__c) mapOfRec.get('problem');
            if(Schema.sObjectType.ElixirSuite__Dataset1__c.isCreateable()){
           // insert problemsObj;
            DMLManager.insertAsUser(problemsObj);
            }
            ElixirSuite__ICD_Codes__c relatedDiagnosis = (ElixirSuite__ICD_Codes__c) mapOfRec.get('icd');
            if(Schema.sObjectType.ElixirSuite__ICD_Codes__c.isCreateable()){
           // insert relatedDiagnosis;
                        DMLManager.insertAsUser(relatedDiagnosis);
            }
            ElixirSuite__Diagnosis_Code__c sObjRecJuntion = (ElixirSuite__Diagnosis_Code__c) mapOfRec.get('junction');
            sObjRecJuntion.ElixirSuite__Problem__c = problemsObj.Id;
            sObjRecJuntion.ElixirSuite__Diagnosis_Code__c = relatedDiagnosis.Id;
            if(Schema.sObjectType.ElixirSuite__Diagnosis_Code__c.isCreateable()){
          //  insert sObjRecJuntion; 
              DMLManager.insertAsUser(sObjRecJuntion);
            }
        }
    }*/
    
    public static void problemInsertFromForm(String toUpdateProblem,String accountId){
        List<Object> lstOfPayload = ( List<Object> ) JSON.deserializeUntyped(toUpdateProblem);
         for(Object sObj_loop : lstOfPayload){
            Map<String, Object> obj_Record_Parent = ( Map<String, Object>) sObj_loop; 
            Map<String, Object> obj_Record = ( Map<String, Object>) obj_Record_Parent.get('keysToSave'); 
            ElixirSuite__Dataset1__c sObj;
          
        if(String.valueOf(obj_Record.get('problemId'))!=null && string.isNotBlank(String.valueOf(obj_Record.get('problemId')))){
         sObj = new ElixirSuite__Dataset1__c(
                Name = String.valueOf(obj_Record.get('problemName')),
                ElixirSuite__Account__c = accountId,
                ElixirSuite__Problem_Type__c = String.valueOf(obj_Record.get('ProblemType')),
                ElixirSuite__Status__c = String.valueOf(obj_Record.get('Status')),
                ElixirSuite__Template_Problem__c =  String.valueOf(obj_Record.get('problemId')),
                ElixirSuite__Note__c = String.valueOf(obj_Record.get('notes')),
                ElixirSuite__SNOMED_CT_Code__c = String.valueOf(obj_Record.get('SnomedCode'))
            );
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
          //  insert sObj;
            DMLManager.insertAsUser(sObj);
        }
            ElixirSuite__ICD_Codes__c relatedDiagnosis;
            String diagnosisId =  String.valueOf(obj_Record.get('diagnosisId'));
            String diagnosisToAttach  = '';
            if(String.isNotBlank(diagnosisId)){ 
                diagnosisToAttach = diagnosisId;           
            }
            else {
                relatedDiagnosis = new ElixirSuite__ICD_Codes__c(
                    Name = String.valueOf(obj_Record.get('ICDCodeLabel')),
                    ElixirSuite__Code_Description1__c = String.valueOf(obj_Record.get('description')),
                    ElixirSuite__Diagnosis_Type__c = String.valueOf(obj_Record.get('diagnosisType')),
                    ElixirSuite__Care_Episode__c = checkForEncounter(accountId),
                    ElixirSuite__Is_Patient_Specific__c = true
                );
               // insert relatedDiagnosis;
                DMLManager.insertAsUser(relatedDiagnosis);
                diagnosisToAttach = relatedDiagnosis.Id;
            }
            ElixirSuite__Diagnosis_Code__c sObjRecJuntion  = new ElixirSuite__Diagnosis_Code__c();
            sObjRecJuntion.ElixirSuite__Care_Episode__c = checkForEncounter(accountId);
          if(String.valueOf(obj_Record.get('problemId'))!=null && string.isNotBlank(String.valueOf(obj_Record.get('problemId')))){
            sObjRecJuntion.ElixirSuite__Problem__c = sObj.Id;
          }
            sObjRecJuntion.ElixirSuite__Diagnosis_Code__c = diagnosisToAttach;
           // insert sObjRecJuntion;
            DMLManager.insertAsUser(sObjRecJuntion);
        }
    }
    
    @AuraEnabled
    public static String saveProblemRec(String payload,String accountId){
        Map<String, Object> lstOfPayload =(Map<String, Object>) JSON.deserializeUntyped(payload);
        Map<String, Object> obj_Record = ( Map<String, Object>) lstOfPayload.get('keysToSave');    
        ElixirSuite__Dataset1__c sObj;
        if(String.valueOf(obj_Record.get('problemId'))!=null && string.isNotBlank(String.valueOf(obj_Record.get('problemId')))){
         sObj = new ElixirSuite__Dataset1__c(
            Name = String.valueOf(obj_Record.get('problemName')),
            ElixirSuite__Account__c = accountId,
            ElixirSuite__Problem_Type__c = String.valueOf(obj_Record.get('ProblemType')),
            ElixirSuite__Status__c = String.valueOf(obj_Record.get('Status')),
            ElixirSuite__Template_Problem__c =  String.valueOf(obj_Record.get('problemId')),
            ElixirSuite__SNOMED_CT_Code__c = String.valueOf(obj_Record.get('SnomedCode')),
              ElixirSuite__Description__c = String.valueOf(obj_Record.get('problemDescription'))
        );
        if(checkDateNull(String.valueOf(obj_Record.get('DateDiagnised')))){
            sObj.ElixirSuite__Date_Diagonised__c = Date.valueOf(String.valueOf(obj_Record.get('DateDiagnised')));           
        }
        if(checkDateNull(String.valueOf(obj_Record.get('DateOnset')))){
            sObj.ElixirSuite__Date_Onset__c = Date.valueOf(String.valueOf(obj_Record.get('DateOnset')));
        }
        if(String.isNotBlank(checkForEncounter(accountId))){
            sObj.ElixirSuite__Care_Episode__c = checkForEncounter(accountId);
        }
       // insert sObj;
        DMLManager.insertAsUser(sObj);
        }
        ElixirSuite__ICD_Codes__c relatedDiagnosis;
        Id objectRecordTypeId = Schema.SObjectType.ElixirSuite__ICD_Codes__c.getRecordTypeInfosByDeveloperName().get('Patient_Diagnosis_Code').getRecordTypeId();
        String diagnosisId =  String.valueOf(obj_Record.get('diagnosisId'));
        String diagnosisToAttach  = '';
        List<ElixirSuite__ICD_Codes__c> tempDiagnosisCode = new List<ElixirSuite__ICD_Codes__c>();
        if(String.isNotBlank(diagnosisId)){ 
             tempDiagnosisCode = [SELECT Id, Name, RecordTypeId, CreatedDate, ElixirSuite__Account__c, ElixirSuite__Version__c, ElixirSuite__Long_Description__c, 
                                                            ElixirSuite__Code_Description1__c, ElixirSuite__Active__c, ElixirSuite__Effective_Date__c, ElixirSuite__Termination_Date__c 
                                                            FROM ElixirSuite__ICD_Codes__c WHERE id=: diagnosisId WITH SECURITY_ENFORCED LIMIT 1];
           
        }
        if(tempDiagnosisCode != NULL && tempDiagnosisCode.size() > 0){
        relatedDiagnosis = tempDiagnosisCode[0].clone(false, false, false, false);
        }
            
            relatedDiagnosis.ElixirSuite__Account__c = accountId;
            relatedDiagnosis.RecordTypeId = objectRecordTypeId;
            relatedDiagnosis.ElixirSuite__Code_Description1__c = String.valueOf(obj_Record.get('description'));
             relatedDiagnosis.ElixirSuite__Diagnosis_Type__c = String.valueOf(obj_Record.get('diagnosisType'));
        if (String.isNotBlank(String.valueOf(obj_Record.get('diagnoseValue')))) {
            relatedDiagnosis.ElixirSuite__Diagnosed_By__c = String.valueOf(obj_Record.get('diagnoseValue'));
        }
        if (String.isNotBlank(String.valueOf(obj_Record.get('diagnosisAttestationOn')))) {
            String formatDateTime = String.valueOf(obj_Record.get('diagnosisAttestationOn'));
            formatDateTime = formatDateTime.replace('T', ' ');
            Datetime dt = DateTime.valueOf(formatDateTime);
            Integer offset = UserInfo.getTimezone().getOffset(dt);
            Datetime local = dt.addSeconds(offset/1000);
            relatedDiagnosis.ElixirSuite__Diagnosis_Attestation_on__c = local; 
        }
        if(String.isNotBlank(checkForEncounter(accountId))){
        relatedDiagnosis.ElixirSuite__Care_Episode__c = checkForEncounter(accountId);
        }
           // insert relatedDiagnosis;
            DMLManager.insertAsUser(relatedDiagnosis);
            diagnosisToAttach = relatedDiagnosis.Id;
        
       /* else {
            relatedDiagnosis = new ElixirSuite__ICD_Codes__c(
                Name = String.valueOf(obj_Record.get('ICDCodeLabel')),
                ElixirSuite__Is_Patient_Specific__c = true
            );
           // insert relatedDiagnosis;
             DMLManager.insertAsUser(relatedDiagnosis);
            diagnosisToAttach = relatedDiagnosis.Id;
        }*/
        
        ElixirSuite__Diagnosis_Code__c sObjRecJuntion  = new ElixirSuite__Diagnosis_Code__c();
       
          if(String.valueOf(obj_Record.get('problemId'))!=null && string.isNotBlank(String.valueOf(obj_Record.get('problemId')))){
        sObjRecJuntion.ElixirSuite__Problem__c = sObj.Id;
          }
        sObjRecJuntion.ElixirSuite__Diagnosis_Code__c = diagnosisToAttach;
      //  insert sObjRecJuntion;
        DMLManager.insertAsUser(sObjRecJuntion); 
        return sObjRecJuntion.Id;
        
    } 
    @AuraEnabled
    public static ElixirSuite__Diagnosis_Code__c fetchEntityRecord(String junctionRecId){
        return [SELECT ID,CreatedDate,LastModifiedDate,CreatedBy.Name FROM ElixirSuite__Diagnosis_Code__c
               where id = :junctionRecId WITH SECURITY_ENFORCED ];
    }
    @AuraEnabled
    public static void updateProblemRec(String payload,String accountId,String recordInViewId){
        saveProblemRec(payload,accountId);
        deleteRecord(recordInViewId);
        
    }
    @AuraEnabled
    public static viewRecordWrapper fetchViewRecord(String recId){
        viewRecordWrapper sObj = new viewRecordWrapper();
        try{
        ElixirSuite__Diagnosis_Code__c[] recordLst = [SELECT ID,Name,ElixirSuite__Problem__r.Id,ElixirSuite__Problem__r.Name,ElixirSuite__Diagnosis_Code__r.ElixirSuite__Code_Description1__c,
                                                      ElixirSuite__Problem__r.ElixirSuite__Template_Problem__c,ElixirSuite__Diagnosis_Code__r.ElixirSuite__Diagnosis_Type__c,
                                                      ElixirSuite__Problem__r.ElixirSuite__Date_Diagonised__c,ElixirSuite__Problem__r.ElixirSuite__Date_Onset__c,
                                                      ElixirSuite__Problem__r.ElixirSuite__Problem_Type__c, ElixirSuite__Problem__r.ElixirSuite__Status__c,
                                                      ElixirSuite__Problem__r.ElixirSuite__Note__c,ElixirSuite__Problem__r.ElixirSuite__SNOMED_CT_Code__c,
                                                      ElixirSuite__Diagnosis_Code__r.Id,ElixirSuite__Diagnosis_Code__r.Name,ElixirSuite__Diagnosis_Code__r.ElixirSuite__Version__c,ElixirSuite__Diagnosis_Code__r.ElixirSuite__Diagnosed_By__c,
                                                      ElixirSuite__Diagnosis_Code__r.ElixirSuite__Diagnosis_Attestation_on__c 
                                                      FROM ElixirSuite__Diagnosis_Code__c WHERE ID = : recId WITH SECURITY_ENFORCED  ];
        if(recordLst!=null && recordLst.size()>0){
            sObj.viewRecord =   recordLst[0];
        }
        if(String.isNotBlank(recordLst[0].ElixirSuite__Diagnosis_Code__r.ElixirSuite__Diagnosed_By__c)){
            String conId = recordLst[0].ElixirSuite__Diagnosis_Code__r.ElixirSuite__Diagnosed_By__c;
            List<Contact> conList = [Select Id,Name FROM Contact Where Id=:conId WITH SECURITY_ENFORCED LIMIT 1];
            if (!conList.isEmpty()) {
                Contact con = conList[0];
                Map<String, String> contactInfo = new Map<String, String>();
                contactInfo.put('label', con.Name);
                contactInfo.put('value', con.Id);
                sObj.conIdName = contactInfo;
            }
        }
        }
            catch(Exception e){
            ExceptionLog.logError(e);
        }
       
        return sObj;        
    }
    @AuraEnabled
    public static void deleteRecord(String recId){
         if(String.isNotBlank(recId)){
            ElixirSuite__Diagnosis_Code__c[] arr = [SELECT ID, ElixirSuite__Problem__c, ElixirSuite__Diagnosis_Code__c FROM ElixirSuite__Diagnosis_Code__c WHERE ID =: recId
                                                   WITH SECURITY_ENFORCED ];
            String[] problemIdArr = new List<String>();
            String[] diagnosisIdArr = new List<String>();
            for(ElixirSuite__Diagnosis_Code__c problemRec : arr){
                problemIdArr.add(problemRec.ElixirSuite__Problem__c);
                diagnosisIdArr.add(problemRec.ElixirSuite__Diagnosis_Code__c);
            }
           // delete [SELECT ID FROM ElixirSuite__Dataset1__c WHERE ID IN : problemIdArr WITH SECURITY_ENFORCED ];
            DMLManager.deleteAsUser([SELECT ID FROM ElixirSuite__Dataset1__c WHERE ID IN : problemIdArr WITH SECURITY_ENFORCED ]);
            DMLManager.deleteAsUser([SELECT Id  from ElixirSuite__ICD_Codes__c WHERE Id =: diagnosisIdArr WITH SECURITY_ENFORCED]);
          //  delete [SELECT ID FROM ElixirSuite__Diagnosis_Code__c WHERE ID =: recId WITH SECURITY_ENFORCED ];
          DMLManager.deleteAsUser([SELECT ID FROM ElixirSuite__Diagnosis_Code__c WHERE ID =: recId WITH SECURITY_ENFORCED ]);
        }
        
    }
    public class deleteWrapper{
        @AuraEnabled public ElixirSuite__ICD_Codes__c icd;
        @AuraEnabled public ElixirSuite__Dataset1__c problem;
        @AuraEnabled public ElixirSuite__Diagnosis_Code__c junction;
    }
    @AuraEnabled
    public static void deleteAllProbelm(List<String> lstRecordId){
        if(lstRecordId!=null && lstRecordId.size()>0){
            ElixirSuite__Diagnosis_Code__c[] arr = [SELECT ID,ElixirSuite__Problem__c FROM ElixirSuite__Diagnosis_Code__c 
                                                    WHERE ID IN : lstRecordId WITH SECURITY_ENFORCED ];
            String[] problemIdArr = new List<String>();
            for(ElixirSuite__Diagnosis_Code__c problemRec : arr){
                problemIdArr.add(problemRec.ElixirSuite__Problem__c);
            }
          //  delete [SELECT ID FROM ElixirSuite__Dataset1__c WHERE ID IN : problemIdArr WITH SECURITY_ENFORCED ];
            DMLManager.deleteAsUser([SELECT ID FROM ElixirSuite__Dataset1__c WHERE ID IN : problemIdArr WITH SECURITY_ENFORCED ]);
           // delete [SELECT ID FROM ElixirSuite__Diagnosis_Code__c WHERE ID IN : lstRecordId WITH SECURITY_ENFORCED ];
           DMLManager.deleteAsUser([SELECT ID FROM ElixirSuite__Diagnosis_Code__c WHERE ID IN : lstRecordId WITH SECURITY_ENFORCED ]);
        }
    }
    public class viewRecordWrapper{
        @AuraEnabled public ElixirSuite__Diagnosis_Code__c viewRecord;  
        @AuraEnabled public Object conIdName;
    } 
    
    @AuraEnabled
    public static ElixirSuite__ICD_Codes__c[] fetchDiagnosisDetails(String lstRecordId){
        ElixirSuite__Diagnosis_Code__c[] lstRecord = [SELECT ID,ElixirSuite__Diagnosis_Code__c FROM ElixirSuite__Diagnosis_Code__c 
                                                      WHERE ID=:lstRecordId WITH SECURITY_ENFORCED];
        String[] diagnosisIdArr = new List<String>();
            for(ElixirSuite__Diagnosis_Code__c diagnosisRec : lstRecord){
                diagnosisIdArr.add(diagnosisRec.ElixirSuite__Diagnosis_Code__c);
            }
        return [SELECT ID,Name,ElixirSuite__Code_Description1__c FROM ElixirSuite__ICD_Codes__c WHERE ID IN : diagnosisIdArr  WITH SECURITY_ENFORCED];
    }
    
    @AuraEnabled //Nikhil ---
    public static boolean checkCareEpisode(string patientId){              
       
         //added by Anmol for LX3-7236
         Boolean result = Elixir_Utility.checkCareEpisodeUtility(patientId);
         return result;
         //end by Anmol for LX3-7236
       
    }
    @AuraEnabled
    public static List<FieldSetHelper.WrapperOption> getFieldSet(String ObjectName, String fieldSetName){
        List<FieldSetHelper.WrapperOption> options = FieldSetHelper.getFieldSetLabelValues(ObjectName,fieldSetName);
        if(options != NULL && options.size() > 0){
            return options;
        }else{
            return NULL;
        }
        
    }
}
public with sharing class ElixirOEM_ExternalComponentsHelper {
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
    public static List<String> saveAllergies(String accountId,List<Medical_Examination__c> allergieTosave,String formUniqueId){
        Id allergyMedicalexamination = Schema.SObjectType.Medical_Examination__c.getRecordTypeInfosByDeveloperName().get('Allergy').getRecordTypeId();  
        List<Medical_Examination__c> allergyRecordsToInsert = new List<Medical_Examination__c>();
        List<ID> allergyIds = new list<ID>();
        String formValue;

        if(String.isNotBlank(formUniqueId)){
            formValue = [SELECT ID,ElixirSuite__Form_Id__c FROM ElixirSuite__Form_Value__c WHERE ElixirSuite__Form_Id__c =: formUniqueId AND ElixirSuite__Form_Detail__c = TRUE].ID;
        }
        
        try{ 
            
        for(Medical_Examination__c rec : allergieTosave){
            rec.Account__c = accountId;
            rec.RecordTypeId = allergyMedicalexamination;
            rec.ElixirSuite__End_Time__c = System.today();
            if(String.isNotBlank(checkForEncounter(accountId))){
                        rec.ElixirSuite__Care_Episode__c = checkForEncounter(accountId);
                    }
            if(String.isNotBlank(formValue)){
                rec.ElixirSuite__Form_Value__c = formValue;
            }
            allergyRecordsToInsert.add(rec);
        }

        if (Schema.sObjectType.Medical_Examination__c.isCreateable()) {
            //DMLManager.insertAsUser(allergyRecordsToInsert);
            Database.SaveResult[] srList = Database.insert(allergyRecordsToInsert);
                for (Database.SaveResult sr : srList) {
                    if (sr.isSuccess()) {
                        allergyIds.add(sr.getId());
                    }
                }
         }

        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        return allergyIds;
           }
    @AuraEnabled
    public static void saveAllGlucose(String formID, String accountId,List<Medical_Examination__c> glucoseList){
        Id glucoseMedicalexamination = Schema.SObjectType.Medical_Examination__c.getRecordTypeInfosByDeveloperName().get('Glucose').getRecordTypeId();  
        List<Medical_Examination__c> glucoseRecordsToInsert = new List<Medical_Examination__c>();
        try{
        for(Medical_Examination__c rec : glucoseList){
            rec.Form_Unique_ID__c = formID;
            rec.Account__c = accountId;
            rec.RecordTypeId = glucoseMedicalexamination;
             rec.ElixirSuite__End_Time__c = System.today();
            glucoseRecordsToInsert.add(rec);
        }
        if (Schema.sObjectType.Medical_Examination__c.isCreateable()) {
            DMLManager.insertAsUser(glucoseRecordsToInsert); 
         }
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        
     
    }
    @AuraEnabled
    public static void saveAllVitalSigns(String formID, String accountId,List<Medical_Examination__c> vitalList){
        Id vitalMedicalexamination = Schema.SObjectType.Medical_Examination__c.getRecordTypeInfosByDeveloperName().get('Vital_Sign').getRecordTypeId();  
        List<Medical_Examination__c> glucoseRecordsToInsert = new List<Medical_Examination__c>();
        for(Medical_Examination__c rec : vitalList){
            rec.Form_Unique_ID__c = formID;
            rec.Account__c = accountId;
            rec.RecordTypeId = vitalMedicalexamination;
            glucoseRecordsToInsert.add(rec);
        }
  if( Schema.sObjectType.Medical_Examination__c.fields.Form_Unique_ID__c.isCreateable() &&
           Schema.sObjectType.Medical_Examination__c.fields.Account__c.isCreateable() &&
           Schema.sObjectType.Medical_Examination__c.fields.RecordTypeId.isCreateable() 
          ){
            if( Schema.sObjectType.Medical_Examination__c.isCreateable()){
        DMLManager.insertAsUser(glucoseRecordsToInsert);
            }
          }
    }
    @AuraEnabled
    public static Map<String,List<String>> getAllPicklistValues() {
        Map<String,List<String>> allPickListValues = new  Map<String,List<String>>();
        List<string> options = new List<string>();
        Schema.DescribeFieldResult allTests =  Medical_Examination__c.Type_of_check__c.getDescribe();
        
        List<Schema.PicklistEntry> testVal = allTests.getPicklistValues();
        for( Schema.PicklistEntry sch : testVal)
        {
            options.add( sch.getValue());
            
        }    
        allPickListValues.put('typeCheck', options);
        
        List<string> freqVal = new List<string>();
        Schema.DescribeFieldResult allFrequencies =  Medical_Examination__c.Intervention__c.getDescribe();
        List<Schema.PicklistEntry> fVal = allFrequencies.getPicklistValues();
        for( Schema.PicklistEntry f : fVal)
        {
            freqVal.add( f.getValue());
            
        }    
        allPickListValues.put('InterventionValues', freqVal);
        return allPickListValues;
        
    }
  /*  public static void saveProblemDiagnosis(String formId , String dataSelected , String accountId , String inputDataSelected , String inputDateTimeselectedValues ,
                                            String inputTextAreaSelected, String inputDateSelectedValues, List<Medical_Examination__c> allergyDataToInsert,
                                            String jsonList, String selectedUser,String selectedVia,List<Medical_Examination__c> glucoseDataToSave,
                                            List<Medical_Examination__c>  vitalSignsDataToSave,String problemDaignosesDataToSave , String attachId ,
                                            String commentSign ,String starttimeProcedure,String endtimeProcedure,String sendEmailRequest,String toUpdateProblemRecordsOnForm,List<String> toDeleteproblemRecordsOnForm,
                                            list<Notes__c> toUpdateNotes,List<String> diagnoseToDel,List<String> problemToDel,List<sObject> toUpdateProblemsOnForm,String allNotes
                                           ){
                                               if(!String.isEmpty(problemDaignosesDataToSave)) {
                                                   
                                                   //Map<Id , HealthCloudGA__CarePlanGoal__c> mapOfGoalIdToNewGoal = new Map<Id , HealthCloudGA__CarePlanGoal__c>();//For task null else
                                                   fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
                                                       new Schema.SObjectType[] {
                                                           Dataset1__c.SObjectType,
                                                               ICD_Codes__c.SObjectType,
                                                               Notes__c.SObjectType
                                                               
                                                               }
                                                   );
                                                   Map<String, Object> mainJson =(Map<String, Object>) JSON.deserializeUntyped(problemDaignosesDataToSave);
                                                   List<Object> listOfProblems = (List<Object>) mainJson.get('keysToSave');
                                                   System.debug('parent 007 -->'+listOfProblems );
                                                   Id problemNonTempatizedRecTypeId = Schema.SObjectType.Dataset1__c.getRecordTypeInfosByName().get('Non-Templatized').getRecordTypeId();
                                                   Id problemNonTempatizedRecTypeIdForICD = Schema.SObjectType.ICD_Codes__c.getRecordTypeInfosByName().get('Non-Templatized').getRecordTypeId();
                                                   for(Object problemRec : listOfProblems){
                                                       Map<String, Object> mapOfProblem = (Map<String, Object>) problemRec;
                                                       // defaultRecordInsertFlag = true;
                                                       // Problem Insertion start
                                                       if(!String.isEmpty(String.valueOf(mapOfProblem.get('isDelete'))) && Boolean.valueOf(mapOfProblem.get('isDelete'))){
                                                           // toDelProblemRecords.add(String.valueOf(mapOfProblem.get('Id')));
                                                       }
                                                       if(!String.isEmpty(String.valueOf(mapOfProblem.get('isrelatedDiagnosesUpdated'))) && Boolean.valueOf(mapOfProblem.get('isrelatedDiagnosesUpdated'))){
                                                       }
                                                       
                                                       if(!String.isEmpty(String.valueOf(mapOfProblem.get('isProblemToInsert'))) && Boolean.valueOf(mapOfProblem.get('isProblemToInsert'))){
                                                           Dataset1__c newProblem = new Dataset1__c();              
                                                           newProblem.Name = String.valueOf(mapOfProblem.get('Name'));
                                                           newProblem.Account__c = accountId;
                                                           newProblem.Description__c = String.valueOf(mapOfProblem.get('Description__c'));
                                                           newProblem.Dataset1__c = String.valueOf(mapOfProblem.get('Id'));                                                           
                                                           newProblem.RecordTypeId = problemNonTempatizedRecTypeId;
                                                           // insert newProblem;
                                                           // System.debug('Parent problem '+newProblem);
                                                           // System.debug('Parent problem id '+newProblem.Id);
                                                           uow.registerNew(newProblem);
                                                           // Problem Insertion end
                                                           
                                                           System.debug('problkemrec map--> '+mapOfProblem);
                                                           if(!String.isEmpty( String.valueOf(mapOfProblem.get('relatedDiagnoses')))) {
                                                               
                                                               List<Object> listOfRelatedDaignoses = (List<Object>) mapOfProblem.get('relatedDiagnoses');
                                                               System.debug('list of rel daig '+listOfRelatedDaignoses);
                                                               for(Object goalRec : listOfRelatedDaignoses){                                                    
                                                                   Map<String, Object> mapOfDiagnoses = (Map<String, Object>) goalRec;
                                                                   if(!String.isEmpty(String.valueOf(mapOfDiagnoses.get('diagnosesIsChecked'))) && Boolean.valueOf(mapOfDiagnoses.get('diagnosesIsChecked'))){                                                                                                                  
                                                                       ICD_Codes__c newDiagnoses = new ICD_Codes__c();
                                                                       newDiagnoses.Code_Label__c  =  String.valueOf(mapOfDiagnoses.get('Code_Label__c'));
                                                                       newDiagnoses.Code__c  =  String.valueOf(mapOfDiagnoses.get('Code'));
                                                                       newDiagnoses.Code_Type__c  =  String.valueOf(mapOfDiagnoses.get('CodeType'));
                                                                       newDiagnoses.RecordTypeId =  problemNonTempatizedRecTypeIdForICD;
                                                                       String truncatedName = '';
                                                                       if(String.valueOf(mapOfDiagnoses.get('Diagnosis_Code_and_Name__c')).length() > 80 ){
                                                                           truncatedName = String.valueOf(mapOfDiagnoses.get('Diagnosis_Code_and_Name__c')).substring(0, 80);
                                                                       }
                                                                       else {
                                                                           truncatedName = String.valueOf(mapOfDiagnoses.get('Diagnosis_Code_and_Name__c'));                                                      
                                                                       }
                                                                       newDiagnoses.Name =String.valueOf(mapOfDiagnoses.get('Name'));
                                                                       newDiagnoses.ICD_Codes__c=String.valueOf(mapOfDiagnoses.get('Id'));
                                                                       System.debug('createed diagnoses 67 '+newDiagnoses);
                                                                       uow.registerRelationship(newDiagnoses, ICD_Codes__c.Related_Problem__c , newProblem);                          
                                                                       System.debug('child diagnoses '+newDiagnoses);
                                                                       System.debug('c-d id '+newDiagnoses.Id);
                                                                       uow.registerNew(newDiagnoses);
                                                                       //Diagnoses Insertion end
                                                                   }
                                                               }}
                                                           
                                                           
                                                           
                                                           
                                                           if(!String.isEmpty( String.valueOf(mapOfProblem.get('relatedNotes')))) {
                                                               
                                                               List<Object> listOfRelatedNotes = (List<Object>) mapOfProblem.get('relatedNotes');
                                                               System.debug('list of related notes '+listOfRelatedNotes);
                                                               for(Object note : listOfRelatedNotes){
                                                                   Map<String, Object> mapOfNotes = (Map<String, Object>) note;
                                                                   Notes__c newNote = new Notes__c();
                                                                   System.debug('map of notes '+mapOfNotes);
                                                                   System.debug('notes value '+String.valueOf(mapOfNotes.get('Notes__c')));
                                                                   newNote.Notes__c  =  String.valueOf(mapOfNotes.get('Notes__c'));                                                      
                                                                   newNote.ElixirSuite__Account__c =accountId;                                            
                                                                   uow.registerRelationship(newNote, Notes__c.Related_Problem__c , newProblem);
                                                                   uow.registerNew(newNote);
                                                                   System.debug('notes record  '+newNote);
                                                                   System.debug('new-note id '+newNote.Id);
                                                                   
                                                                   
                                                                   //Note Insertion end
                                                                   
                                                               }}
                                                       }
                                                   }
                                                   uow.commitWork();
                                               }
                                               //  toDelProblemRecords.addAll(problemToDel);
                                           }*/
}
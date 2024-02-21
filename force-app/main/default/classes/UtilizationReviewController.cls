public with sharing class UtilizationReviewController {
    @AuraEnabled
    public static string fetchAccountName(string accountId){
        List<Account> acc=[SELECT Id, name FROM Account WHERE Id= :accountId  WITH SECURITY_ENFORCED];
        string accName = acc[0].name;
        return accName;
    }
    @AuraEnabled
    public static List<Utilization_Review__c> fetchAllRelatedUtlizationRecordsForAccount(String accountId) {
        List<Utilization_Review__c> recordsLstUR = [SELECT CreatedById,CreatedDate,Approved_LOC__c,Approved_Number_of_Days__c,Name,
                                                    Authorization_Number__c,Status__c,Type__c,Id,Discharge__c
                                                    FROM Utilization_Review__c WHERE Account__c= :accountId      
                                                    WITH SECURITY_ENFORCED
                                                    ORDER BY CreatedDate DESC];
        return recordsLstUR;
    }

    //added by Anmol for LX3-5961
    @AuraEnabled 
    public static Decimal fetchEvent(String accountId,Datetime reviewDate){
       List<Event> evRec = new List<Event>();
       evRec = [Select id,Description,ElixirSuite__Status__c,StartDateTime,EndDateTime from Event where WhatId=:accountId 
                    and ElixirSuite__Status__c='Completed'  WITH SECURITY_ENFORCED];
       List<Event> compEvRec = new List<Event>();
       for(Event e : evRec){
        System.debug('reviewDate**'+reviewDate);
        System.debug('EndDateTime**'+e.StartDateTime);
        if(reviewDate<e.StartDateTime){
            compEvRec.add(e);
        }
       }
       Decimal evLen = compEvRec.size();
        return evLen;
    }
    //end by Anmol for LX3-5961

    @AuraEnabled
    public static getAllDataForUtilizationReviewWrapper getAllDataForUtilizationReview(String accountId,String currentlyViewedRecord) {
        
        Integer age ;
        Date birthdate1 ;
        
        Account acctRec = [select id,name,ElixirSuite__DOB__c,Age__c,dischargeDateNew__c,Discharge_Date__c,BillingStreet, BillingCity, BillingState, BillingPostalCode,
                           BillingCountry, BillingLatitude, BillingLongitude,ElixirSuite__Admit_Date__c
                           from Account where id=:accountId 
                           WITH SECURITY_ENFORCED
                           limit 1];
        Contact con = new Contact();
        Contact [] conArr =[select Id,name,birthdate from contact where AccountId=:accountId 
        WITH SECURITY_ENFORCED
        LIMIT 1];
        if(conArr!=null && conArr.size()>0){
            con =  conArr[0];
        }
        if(!String.isBlank(String.valueOf(con))){
            if(con.birthdate!=null){
                birthdate1=con.birthdate;
            }
        }
        /*List<Programs__c> allProgramsInOrg  = [select id,Program_Name__c from Programs__c 
        WITH SECURITY_ENFORCED
        LIMIT 49999];*/
        List<Form__c> preliminaryForm  = new List<Form__c>();
       // System.debug('programs '+allProgramsInOrg);
       //added by Anmol for LX3-5961
       List<Utilization_Review__c> lastCreatedReview = [SELECT CreatedById,CreatedDate,Approved_LOC__c,Approved_Number_of_Days__c,Name,Discharge__c,
       Authorization_Number__c,Next_Review_Date__c,Status__c,Type__c,Id,ElixirSuite__Date_Time_of_Review__c,
       ElixirSuite__Approved_Number_of_Sessions__c,ElixirSuite__Sessions_Completed__c,ElixirSuite__Sessions_Available__c
       FROM Utilization_Review__c WHERE Account__c= :accountId 
       WITH SECURITY_ENFORCED
       order by CreatedDate asc];
List<Utilization_Review__c> lastURRecordForNewRecord = [SELECT CreatedById,CreatedDate,Approved_LOC__c,Approved_Number_of_Days__c,Name,Discharge__c,
              Authorization_Number__c,Next_Review_Date__c,Status__c,Type__c,Id,ElixirSuite__Date_Time_of_Review__c,
              ElixirSuite__Approved_Number_of_Sessions__c,ElixirSuite__Sessions_Completed__c,ElixirSuite__Sessions_Available__c
              FROM Utilization_Review__c WHERE Account__c= :accountId 
              WITH SECURITY_ENFORCED
              order by CreatedDate desc];
              //end by Anmol for LX3-5961
        Integer getIndex;
        for(Utilization_Review__c findPrevious : lastCreatedReview){
            if(findPrevious.id == currentlyViewedRecord){
                System.debug('inside if ');
                getIndex = lastCreatedReview.indexOf(findPrevious);
            }
        }
        List<Utilization_Review__c> isPreviousRecord = new List<Utilization_Review__c>();
        System.debug('last index '+ getIndex);
        if(!String.isEmpty(String.valueOf(getIndex))){
            if(getIndex-1 >= 0){
                isPreviousRecord.add(lastCreatedReview[getIndex-1]) ;
            }
        }
        List<Form_Data__c> preAssesmentData = [SELECT CreatedById,CreatedDate,Approval_Level_s__c,Approval_Values__c,
                                               Checkbox__c,Date_Time__c,Date__c,Form_Field__c,Form__c,
                                               TextArea__c,Text__c,Value__c,Id,Name 
                                               FROM Form_Data__c where Account__c=:accountId
                                               WITH SECURITY_ENFORCED];
        //FOLLOWING IS USED TO GET THE DATA RELATED TO THE NUURSING FORM FOR WHICH DATA IS SAVED IN "FORM DATA" AND QUESTIONS IN "FORM FIELDS"
        //ALSO, THE ANSWERS REPRESENTS THE RECORDS IN "FORM DATA" WHICH IS THE CHILD OF A RECORD IN "FORM FIELDS"
        //ALSO,ANSWERS ARE NOT THE CHILD OF PARENT RECORDS WHICH REPRESENTS "QUESTION" [WHICH IS A RECORD IN "FOIRM FIELDS"] BUT ARE CHILD OF THE RECORD IN "FORM FIELDS" WHICH HAS SAME SECTION AS OF QUESTION RECORD IN "FORM FIELDS"
        //THEREFOR QUESRIES AND MAPS ARE USED TO 1ST GET THE FORM : THEN THE ASSOSIATED FORM : THEN THE FORM FIELDS RECORD (WHICH IS QUESTION : THEN NEXT RECORD IN "FORM FIELDS" WHICH HAS SAME SECTION :
        //THEN CHILD RECORD FROM "FORM DATA"
        //ALSO MAP FOR QUESTIONS AND IT'S RELATED ANSWERS
        List<Form__c> preliminaryFormAssosiatedToAccount  = [SELECT id,name,Form__c from Form__c where Name='Nursing Screen & Assessment (1 and 2)'and  Account__c=:accountId WITH SECURITY_ENFORCED ORDER BY LastModifiedDate DESC];
        if(preliminaryFormAssosiatedToAccount.size()>0 && preliminaryFormAssosiatedToAccount!=null) {
            preliminaryForm = [SELECT id,name from Form__c where Name='Nursing Screen & Assessment (1 and 2)' and  Account__c=null and Id=:preliminaryFormAssosiatedToAccount[0].Form__c
            WITH SECURITY_ENFORCED];
            if(test.isRunningTest()){
                  preliminaryForm = [SELECT id,name from Form__c where Name='Nursing Screen & Assessment (1 and 2)' WITH SECURITY_ENFORCED];

            }
        }
        System.debug('PRE FORM ID '+preliminaryForm);
        List<Form_Field__c> formField = new  List<Form_Field__c>();
        List<Form_Field__c> formFieldInputParent = new  List<Form_Field__c>();
        List<Decimal> section = new  List<Decimal>();
        Map<String,String> preAssesmentDataArranged  = new Map<String,String>();
        Map<Decimal,String> sectionQuestionsAnswersArranged  = new Map<Decimal,String>();
        Map<String,String> finalQNAmap  = new Map<String,String>();
        if(preliminaryForm.size()>0 && preliminaryForm!=null  ){
            formField  = [SELECT id,Section__c,Field_Name__c from Form_Field__c where Form__c=:preliminaryForm[0].Id WITH SECURITY_ENFORCED];
            System.debug('form field '+formField);
        }
        Set<Id> questionIds = new Set<Id>();
        for(Form_Field__c questions : formField){
            //System.debug('question  '+questions);
            if(!String.isBlank(questions.Field_Name__c)) {
                if(questions.Field_Name__c.contains('Signs and Symptoms of Withdrawal')){
                    section.add(questions.Section__c);
                    sectionQuestionsAnswersArranged.put(questions.Section__c,questions.Field_Name__c);
                }
                if(questions.Field_Name__c.contains('PAWS Symptoms')){
                    section.add(questions.Section__c);
                    sectionQuestionsAnswersArranged.put(questions.Section__c,questions.Field_Name__c);
                }
                
                if(questions.Field_Name__c.contains('What supports systems does the patient have?')){
                    section.add(questions.Section__c);
                    sectionQuestionsAnswersArranged.put(questions.Section__c,questions.Field_Name__c);
                }
            }
            
        } 
        System.debug('section values '+section);
        formFieldInputParent  = [SELECT id,Section__c,Field_Name__c,Data_Entry_Type__c 
        from Form_Field__c where Section__c in :section and Data_Entry_Type__c='input:Text(Only)'
        WITH SECURITY_ENFORCED];
        System.debug('ff input parent '+formFieldInputParent);
        if(formFieldInputParent.size()>0 && formFieldInputParent!=null){
            for(Form_Field__c addRec : formFieldInputParent){
                preAssesmentDataArranged.put(addRec.Id,sectionQuestionsAnswersArranged.get(addRec.Section__c));
                questionIds.add(addRec.Id);
            }
        }
        System.debug('PRE-ASES DATA ARRANGED  '+preAssesmentDataArranged);
        System.debug('IDs '+questionIds);
        List<Form_Data__c> myQuestionsAnswers = [select id,Text__c,Name,Form_Field__r.Field_Name__c,Form_Field__c from Form_Data__c where Form_Field__c in :preAssesmentDataArranged.keySet()
        WITH SECURITY_ENFORCED];
        System.debug('Q/A'+myQuestionsAnswers);
        for(Form_Data__c answerRecords : myQuestionsAnswers){            
            // finalQNAmap.put(preAssesmentDataArranged.get(answerRecords.Form_Field__c),answerRecords.Text__c); 
            finalQNAmap.put(answerRecords.Id,preAssesmentDataArranged.get(answerRecords.Form_Field__c)); 
            // questionIds.add(addRec.Id);            
        } 
        System.debug('Final MAP  '+finalQNAmap);
      //  Id probelmAccSpecific = Schema.SObjectType.Dataset1__c.getRecordTypeInfosByDeveloperName().get('Non_Templatized').getRecordTypeId();
        ElixirSuite__Dataset1__c[] problems = [SELECT name,Id,ElixirSuite__Account__c,ElixirSuite__SNOMED_CT_Code__c,ElixirSuite__Problem_Type__c,ElixirSuite__Date_Onset__c 
                                               from ElixirSuite__Dataset1__c where ElixirSuite__Account__c =:accountId
                                               WITH SECURITY_ENFORCED];
                                               
        List<ElixirSuite__Procedure__c> Procedurevar = [SELECT ElixirSuite__Days_Units__c,ElixirSuite__Code_Category__c,ElixirSuite__Code_Description__c,
                                                         ElixirSuite__Place_Of_Service_Picklist__c
                                                        FROM ElixirSuite__Procedure__c WHERE ElixirSuite__Account__c=:accountId  and ElixirSuite__Code_Category__c!=null    
                                                        WITH SECURITY_ENFORCED];

        /*List<ElixirSuite__Diagnosis_Code__c> DiagonsisVar  = [SELECT Id,ElixirSuite__Diagnosis_Code__r.Name,ElixirSuite__Diagnosis_Code__r.ElixirSuite__Diagnosis_Type__c,CreatedDate, 
                                                           ElixirSuite__Problem__r.ElixirSuite__Account__c   FROM ElixirSuite__Diagnosis_Code__c WHERE ElixirSuite__Problem__r.ElixirSuite__Account__c=:accountId 
                                                      WITH SECURITY_ENFORCED];*/

        List<ElixirSuite__ICD_Codes__c> DiagonsisVar  = [SELECT id,Name, ElixirSuite__Diagnosis_Type__c, ElixirSuite__Code_Description1__c,ElixirSuite__Effective_Date__c, 
                                                              ElixirSuite__Account__c FROM ElixirSuite__ICD_Codes__c 
                                                              WHERE ElixirSuite__Account__c =:accountId 
                                                              WITH SECURITY_ENFORCED];

        // FORM DATA FETCH ENDS ABOVE.
        List<ElixirSuite__VOB__c> relatedVOB = [SELECT Id,Client_Status__c,Effective_From__c,Effective_To__c,Insurance_Group_Number_Sec__c,
                                   Insurance_ID_Number__c,Insurance_Provider_Sec__c,
                                   Insurance_Type__c,LastModifiedDate,Member_Number__c,Member_Plan_Name__c,Name,OwnerId,
                                   Patient_s_Gender__c,Plan_Benefit_Name__c,Plan_Number__c,Policy_Holder_DOB_Sec__c,Policy_Holder_DOB__c,
                                   Policy_Holder_Name_Sec__c,Policy_Holder_Name__c,Plan_Type__c,PreAuth_Identifier__c,PreAuth_Name__c,
                                   Purchase_Plan_Name__c,Status__c,Effective_From_PreAuth__c,SystemModstamp,
                                   Effective_To_PreAuth__c,ElixirSuite__Service_Type__c,
                                   ElixirSuite__InsPhone__c,ElixirSuite__Insurance_Type_Sec__c,ElixirSuite__Member_Id__c,ElixirSuite__Group_Number__c,
                                   ElixirSuite__VOB_Verification_Status__c,ElixirSuite__Insurance_Provider__c
                                   FROM ElixirSuite__VOB__c
                                   WHERE ElixirSuite__Account__c = : accountId
                                   WITH SECURITY_ENFORCED]; 
        getAllDataForUtilizationReviewWrapper wrpr  = new getAllDataForUtilizationReviewWrapper();
        wrpr.acctRecord=acctRec;
        //wrpr.lstOfProgramsOffered= allProgramsInOrg;
        wrpr.preliminaryAssesmentData = preAssesmentData;
        wrpr.allProblemsForPatient = problems;
        wrpr.lastCreatedReview=isPreviousRecord;
        wrpr.allVOBDetails = relatedVOB;
        wrpr.allProcedure = Procedurevar;
        wrpr.allDiagonsis = DiagonsisVar;
        wrpr.formAnswers = myQuestionsAnswers;
        wrpr.finalQNAmapLst = finalQNAmap;
        wrpr.myQuestionsAnswersLst = myQuestionsAnswers;
        wrpr.preAssesmentDataArranged = preAssesmentDataArranged; 
        wrpr.patBirthDate = birthdate1 ;
        wrpr.lastCreatedReviewForNewUR = lastURRecordForNewRecord;
        return wrpr;
    }
    public class getAllDataForUtilizationReviewWrapper{
        @AuraEnabled    public Account acctRecord{ get; set; }
        //@AuraEnabled    public List<Programs__c> lstOfProgramsOffered{ get; set; }
        @AuraEnabled    public List<Form_Data__c> preliminaryAssesmentData{ get; set; }
        @AuraEnabled    public List<Form_Data__c> formAnswers{ get; set; }
        @AuraEnabled     public List<ElixirSuite__Dataset1__c> allProblemsForPatient{ get; set; }
        @AuraEnabled    public Map<String,String> finalQNAmapLst  = new Map<String,String>();
        @AuraEnabled    public  List<Utilization_Review__c> lastCreatedReview{ get; set; } 
        @AuraEnabled    public  List<Utilization_Review__c> lastCreatedReviewForNewUR{ get; set; } 
        @AuraEnabled    public  List<ElixirSuite__Procedure__c> allProcedure{ get; set; } 
        @AuraEnabled    public List<Form_Data__c> myQuestionsAnswersLst {get;set;}
        @AuraEnabled    public Map<String,String> preAssesmentDataArranged  = new Map<String,String>();
        @AuraEnabled    public Date patBirthDate{ get; set; } 
        @AuraEnabled    public List<Vob__c> allVOBDetails { get; set; } 
        @AuraEnabled    public List<ElixirSuite__ICD_Codes__c> allDiagonsis { get; set; }

    }
    @AuraEnabled
    public static void saveDataForUtilizationReview(List<Utilization_Review__c> recordToSave,String accountId,String starttimeProcedure , String endtimeProcedure) {
        Id devRecordTypeId = Schema.SObjectType.Procedure__c.getRecordTypeInfosByName().get('Patient Procedure').getRecordTypeId();    
        
         //added by Anmol for LX3-7236
         Elixir_Custom_Setting__c customSetting = Elixir_Custom_Setting__c.getOrgDefaults();
         String careFilter = customSetting.ElixirSuite__Default_Active_Care_Episode_Filter__c;
         if(string.isBlank(careFilter)){
            careFilter = 'createddate desc';
        }
         String careStatus = 'Active';
 
         string querystr = '';
         querystr += 'Select Id,ElixirSuite__Account__c,ElixirSuite__Status__c from ElixirSuite__Visits__c where ElixirSuite__Status__c=:careStatus AND ElixirSuite__Account__c =: accountId WITH SECURITY_ENFORCED order by ';
         querystr += careFilter ;
         List<ElixirSuite__Visits__c> lst_visits = database.query(querystr);
         //end by Anmol for LX3-7236
        
        System.debug('starttimeProcedure ' +starttimeProcedure);
        if(Elixir_Utility.fetchCreateProcedureReturnValue()==true){
        Procedure__c newProcedure = new Procedure__c();
        try{
        newProcedure.ElixirSuite__Account__c= accountId; 
        newProcedure.RecordTypeId = devRecordTypeId;
        newProcedure.From_Date__c = date.valueOf(starttimeProcedure) ;
        newProcedure.Start_Time__c = date.valueOf(starttimeProcedure) ;
        newProcedure.To_Date__c = date.valueOf(endtimeProcedure) ;
        newProcedure.End_Time__c = date.valueOf(endtimeProcedure) ;
        if(!lst_visits.isEmpty())
        {
            newProcedure.ElixirSuite__Visits__c =lst_visits[0].Id;
        }
        if(Elixir_utility.dateTimeConversion(endtimeProcedure) <= Elixir_utility.dateTimeConversion(starttimeProcedure))
        {
            newProcedure.put('ElixirSuite__End_Time__c' , Elixir_utility.dateTimeConversion(starttimeProcedure).addMinutes(1));
        }
        else
        {
            newProcedure.put('ElixirSuite__End_Time__c' , Elixir_utility.dateTimeConversion(endtimeProcedure));
        }
         
        newProcedure.put('ElixirSuite__Start_Time__c' , Elixir_utility.dateTimeConversion(starttimeProcedure));
        
        newProcedure.Name = 'Utilization Review';
        if(Schema.sObjectType.Procedure__c.fields.Account__c.isCreateable() &&
        Schema.sObjectType.Procedure__c.fields.RecordTypeId.isCreateable() &&
        Schema.sObjectType.Procedure__c.fields.From_Date__c.isCreateable() &&
        Schema.sObjectType.Procedure__c.fields.Start_Time__c.isCreateable() &&
        Schema.sObjectType.Procedure__c.fields.To_Date__c.isCreateable() &&
        Schema.sObjectType.Procedure__c.fields.End_Time__c.isCreateable()){
            insert newProcedure;
        }
        }
        catch(Exception e){
        ExceptionLog.logError(e);
        }
        }
        
        if(recordToSave!=null && recordToSave.size()>0){
            List<Utilization_Review__c> ifAnyRecordExists = [SELECT id
                                                             FROM Utilization_Review__c WHERE Account__c= :accountId 
                                                             WITH SECURITY_ENFORCED];
            if(ifAnyRecordExists.isEmpty()){
                recordToSave[0].Type__c='Initial Review';
            }
            else {
                recordToSave[0].Type__c='Concurrent Review';
            }
            recordToSave[0].Account__c=accountId;
            recordToSave[0].Status__c='Open'; 
            if(!lst_visits.isEmpty()){
                recordToSave[0].ElixirSuite__Care_Episode__c = lst_visits[0].Id;       
             }
            if(Schema.sObjectType.Utilization_Review__c.isCreateable() &&
            Schema.sObjectType.Utilization_Review__c.isUpdateable() &&
            Schema.sObjectType.Utilization_Review__c.fields.ElixirSuite__Care_Episode__c.isCreateable() &&
            Schema.sObjectType.Utilization_Review__c.fields.ElixirSuite__Care_Episode__c.isUpdateable() &&
            Schema.sObjectType.Utilization_Review__c.fields.Type__c.isCreateable() &&
            Schema.sObjectType.Utilization_Review__c.fields.Type__c.isUpdateable() &&
            Schema.sObjectType.Utilization_Review__c.fields.Account__c.isCreateable() &&
            Schema.sObjectType.Utilization_Review__c.fields.Account__c.isUpdateable() &&
            Schema.sObjectType.Utilization_Review__c.fields.Status__c.isCreateable() &&
            Schema.sObjectType.Utilization_Review__c.fields.Status__c.isUpdateable()){
                upsert recordToSave[0];   
            }
        }
        
    }
    
    @AuraEnabled
    public static List < String > deleteAllUtilizationRecords(List<String> lstRecordId) {
        // for store Error Messages  
        List < String > oErrorMsg = new List < String > ();
        try{
        // Query Records for delete where id in lstRecordId [which is pass from client side controller] 
        List <Utilization_Review__c> lstDeleteRec = [select Id from Utilization_Review__c where id IN: lstRecordId WITH SECURITY_ENFORCED];
        
        Database.DeleteResult[] DR_Dels = Database.delete(lstDeleteRec, false);
        // Iterate through each returned result
        for (Database.DeleteResult dr: DR_Dels) {
            if (dr.isSuccess()) {
                system.debug('successful delete contact');
                // Operation was successful
            } else {
                // Operation failed, so get all errors   
                oErrorMsg.add('');
                for (Database.Error err: dr.getErrors()) {
                    // add Error message to oErrorMsg list and return the list
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
    @AuraEnabled
    public static  Utilization_Review__c getURRecordForEdit(String record) {
        //added some fields in the below query by Anmol
        List<Utilization_Review__c> recordURForEdit = [SELECT CreatedById,CreatedDate,Approved_LOC__c,Approved_Number_of_Days__c,Name,
                                                       Authorization_Number__c,Created_Date_Date_Only__c,Status__c,Type__c,Id,Discharge__c,Next_Review_Date__c,ElixirSuite__Date_Time_of_Review__c,
                                                       ElixirSuite__Approved_Number_of_Sessions__c,ElixirSuite__Sessions_Completed__c,ElixirSuite__Sessions_Available__c
                                                       FROM Utilization_Review__c WHERE Id= :record 
                                                       WITH SECURITY_ENFORCED];
                    //end by Anmol
        return recordURForEdit[0];
        
    }
    @AuraEnabled
    public static Utilization_Review__c updtRecordAfterEdit (List<Utilization_Review__c> recordToUpdate,String recID){
        if(recordToUpdate!=null && recordToUpdate.size()>0) {                                                                                                                                                   
            Utilization_Review__c rec = [SELECT CreatedById,CreatedDate,Approved_LOC__c,Approved_Number_of_Days__c,Name,
                                         Authorization_Number__c,Status__c,Type__c,Id
                                         FROM Utilization_Review__c WHERE Id= :recID
                                         WITH SECURITY_ENFORCED];
            rec=recordToUpdate[0];
            if(rec!=null) {      
                if(Utilization_Review__c.sObjectType.getDescribe().isCreateable()){
                    update rec;
                }                                                                   
            }
            recordToUpdate[0] = rec;
             return recordToUpdate[0];
        }
        else {
            return null;
        }
    }
    
    @AuraEnabled
    public static boolean checkCareEpisode(string patientId){      
        
        //added by Anmol for LX3-7236
        Boolean result = Elixir_Utility.checkCareEpisodeUtility(patientId);
        return result;
        //end by Anmol for LX3-7236
       
    }
       /*@AuraEnabled
        public static List<ElixirSuite__Procedure__c> getAllDataForUtilizationReviewWrapper (String accountId) {
           // if(ProcedureId!=null && ProcedureId.size()>0){
            List<ElixirSuite__Procedure__c> Procedurevar = [SELECT ElixirSuite__Days_Units__c,ElixirSuite__CPT_HCPCS_Code__c,ElixirSuite__Code_Description__c,
                                                         ElixirSuite__Place_of_Service_Code__c,CreatedDate
                                                        FROM ElixirSuite__Procedure__c WHERE Account__c= :accountId      
                                                        WITH SECURITY_ENFORCED];
                                                       
            return Procedurevar;
        }*/
    }
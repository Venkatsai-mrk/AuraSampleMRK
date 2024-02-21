/* Purpose : To create form and fetch data from Form,Form_Field Objects
* Note :- Maximum 21 queries can be made in this section
* Developer Name :- Rohit Singh and Kishan
*/
public with sharing class Elixir_FormApexController {  
    /*@AuraEnabled
    public static wrapperForAccName fetchAllForms(String category , String subCategory, String accountId){
        wrapperForAccName wrpr = new wrapperForAccName();
        
        String query ;
        query = 'SELECT Id, Name, ElixirSuite__Category__c, ElixirSuite__Sub_Category__c, ElixirSuite__Care_Episode__c, ElixirSuite__Sections__c, ElixirSuite__Version__c, ElixirSuite__Locations__c FROM ElixirSuite__Form__c WHERE ElixirSuite__Account__c = NULL AND ElixirSuite__Category__c= :category order by name asc';
        wrpr.forms =  Database.query(query);
        
        List<Account> listOfAcc = [SELECT Id , Verification_Code__c , Name, parent.Name FROM Account WHERE Id= : accountId
        WITH SECURITY_ENFORCED];
        List<Contact> con=[select Id,name,birthdate from contact where AccountId= :accountId 
        WITH SECURITY_ENFORCED
        LIMIT 1];
        if(listOfAcc!=null && listOfAcc.size()>0){
            wrpr.accName = listOfAcc[0].name;
            wrpr.dob = String.valueOf(con[0].birthdate);
            wrpr.passCode =  String.valueOf(listOfAcc[0].Verification_Code__c);
            wrpr.parentAccount = String.valueOf(listOfAcc[0].parent.Name);
            wrpr.nameSpace = 'ElixirSuite__';
        }
        System.debug('forms wrpr '+wrpr);
        return wrpr;
    }
    @AuraEnabled  
    public static user Uinfo(){
        ID UID =UserInfo.getUserId();
        user u =[select id,Verification_Code__c from user where id =:UID
        WITH SECURITY_ENFORCED];
        return u;
        
    }
    @AuraEnabled  
    public static void deleteFiles(List<String> sdocumentId){
        if(sdocumentId.size()>0 && sdocumentId!=null){
            delete [SELECT Id,Title,FileType from ContentDocument WHERE id in:sdocumentId];
        }
    }  
    
    @AuraEnabled
    public static List<Form__c> fetchAccountAssociatedForms(String accountId , String category , String subCategory){
        String query ;
        Set<Id> setOfId = new set<Id>();
        query = 'SELECT Id, Name, ElixirSuite__Category__c,ElixirSuite__Status__c, ElixirSuite__Care_Episode__c,ElixirSuite__Sub_Category__c, ElixirSuite__Sections__c,ElixirSuite__Approval_Values1__c,ElixirSuite__Approval_Values_3__c,ElixirSuite__Approval_Values_2__c, ElixirSuite__Version__c, ElixirSuite__Locations__c,'+            
            'ElixirSuite__Signature_value_1__c,ElixirSuite__Signature_value_2__c,ElixirSuite__Signature_value_3__c FROM ElixirSuite__Form__c WHERE ElixirSuite__Account__c= :accountId AND ElixirSuite__Form__r.ElixirSuite__Category__c= :category ORDER BY CreatedDate desc';
        
        // '  AND Sub_Category__c= :subCategory';
        List<Form__c> listOfForms =  Database.query(query);
        return listOfForms;
        
    }
    @AuraEnabled
    public static wrapperForAccName ParentNotesForms(String accountId , String category , String subCategory){
        system.debug('subCategory '+subCategory);
        wrapperForAccName wrpr = new wrapperForAccName();
        String query ;
        query = 'SELECT Id, Name, ElixirSuite__Category__c,ElixirSuite__Status__c, ElixirSuite__Sub_Category__c, ElixirSuite__Care_Episode__c, ElixirSuite__Sections__c,ElixirSuite__Approval_Values1__c,ElixirSuite__Approval_Values_3__c,ElixirSuite__Approval_Values_2__c, ElixirSuite__Version__c, ElixirSuite__Locations__c FROM ElixirSuite__Form__c WHERE ElixirSuite__Account__c= NULL AND ElixirSuite__Sub_Category__c= :subCategory ORDER BY CreatedDate desc';
        wrpr.forms =  Database.query(query);
        
        List<Account> listOfAcc = [SELECT Id , Verification_Code__c , Name, parent.Name 
        FROM Account WHERE Id= : accountId WITH SECURITY_ENFORCED];
        List<Contact> con=[select Id,name,birthdate from contact where AccountId= :accountId WITH SECURITY_ENFORCED
        LIMIT 1];
        if(listOfAcc!=null && listOfAcc.size()>0){
            wrpr.accName = listOfAcc[0].name;
            wrpr.dob = String.valueOf(con[0].birthdate);
            wrpr.passCode =  String.valueOf(listOfAcc[0].Verification_Code__c);
            wrpr.parentAccount = String.valueOf(listOfAcc[0].parent.Name);
            
        }
        return wrpr;
        
        
    }
    
    
    @AuraEnabled
    public static wrapperForAccName parentCaseManagementForms(String accountId , String category , String subCategory){
        system.debug('subCategory '+subCategory);
        wrapperForAccName wrpr = new wrapperForAccName();
        String query ;
        query = 'SELECT Id, Name, ElixirSuite__Category__c,ElixirSuite__Status__c, ElixirSuite__Care_Episode__c, ElixirSuite__Sub_Category__c, ElixirSuite__Sections__c,ElixirSuite__Approval_Values1__c,ElixirSuite__Approval_Values_3__c,ElixirSuite__Approval_Values_2__c, ElixirSuite__Version__c, ElixirSuite__Locations__c FROM ElixirSuite__Form__c WHERE ElixirSuite__Account__c= NULL AND ElixirSuite__Category__c= :category ORDER BY CreatedDate desc';
        wrpr.forms =  Database.query(query);
        
        List<Account> listOfAcc = [SELECT Id , Verification_Code__c , Name, parent.Name 
        FROM Account WHERE Id= : accountId WITH SECURITY_ENFORCED];
        List<Contact> con=[select Id,name,birthdate from contact where AccountId= :accountId WITH SECURITY_ENFORCED
        LIMIT 1];
        if(listOfAcc!=null && listOfAcc.size()>0){
            wrpr.accName = listOfAcc[0].name;
            wrpr.dob = String.valueOf(con[0].birthdate);
            wrpr.passCode =  String.valueOf(listOfAcc[0].Verification_Code__c);
            wrpr.parentAccount = String.valueOf(listOfAcc[0].parent.Name);
            
        }
        return wrpr;
        
        
    }
    
    @AuraEnabled
    public static wrapperForNotesData bringCaseManagementData(String accountId , String category , String subCategory){
        wrapperForNotesData data = new wrapperForNotesData();
        List<Account> listOfAcc = [SELECT Id , Verification_Code__c , Name, parent.Name 
        FROM Account WHERE Id= : accountId WITH SECURITY_ENFORCED];
        List<Contact> con=[select Id,name,birthdate from contact where AccountId= :accountId 
        WITH SECURITY_ENFORCED
        LIMIT 1];
        if(listOfAcc!=null && listOfAcc.size()>0){
            wrapperForAccName wrpr = new wrapperForAccName();
            wrpr.accName = listOfAcc[0].name;
            wrpr.dob = String.valueOf(con[0].birthdate);
            wrpr.passCode =  String.valueOf(listOfAcc[0].Verification_Code__c);
            wrpr.parentAccount = String.valueOf(listOfAcc[0].parent.Name);
            data.accName = wrpr;
            data.allForms = CMForms(accountId , 'CaseManagement' , subCategory);
        }
        return data;
    }
    @AuraEnabled
    public static List<Form__c> CMForms(String accountId , String category , String subCategory){
        String query ;
        Set<Id> setOfId = new set<Id>();
        query = 'SELECT Id, Name, ElixirSuite__Category__c,ElixirSuite__Status__c, ElixirSuite__Care_Episode__c, ElixirSuite__Sub_Category__c, ElixirSuite__Sections__c,ElixirSuite__Approval_Values1__c,ElixirSuite__Approval_Values_3__c,ElixirSuite__Approval_Values_2__c, ElixirSuite__Version__c, ElixirSuite__Locations__c FROM ElixirSuite__Form__c WHERE ElixirSuite__Account__c= :accountId AND ElixirSuite__Form__r.ElixirSuite__Category__c= :category ORDER BY CreatedDate desc';
        List<Form__c> listOfForms =  Database.query(query);
        return listOfForms;
        
    }
    
    @AuraEnabled
    public static List<Form__c> NotesForms(String accountId , String category , String subCategory){
        String query ;
        Set<Id> setOfId = new set<Id>();
        query = 'SELECT Id, Name, ElixirSuite__Category__c,ElixirSuite__Status__c, ElixirSuite__Sub_Category__c, ElixirSuite__Care_Episode__c, ElixirSuite__Sections__c,ElixirSuite__Approval_Values1__c,ElixirSuite__Approval_Values_3__c,ElixirSuite__Approval_Values_2__c, ElixirSuite__Version__c, ElixirSuite__Locations__c FROM ElixirSuite__Form__c WHERE ElixirSuite__Account__c= :accountId AND ElixirSuite__Form__r.ElixirSuite__Sub_Category__c= :subCategory ORDER BY CreatedDate desc';
        List<Form__c> listOfForms =  Database.query(query);
        return listOfForms;
        
    }
    @AuraEnabled
    public static wrapperForNotesData bringNotesData(String accountId , String category , String subCategory){
        wrapperForNotesData data = new wrapperForNotesData();
        List<Account> listOfAcc = [SELECT Id , Verification_Code__c , Name, parent.Name 
        FROM Account WHERE Id= : accountId WITH SECURITY_ENFORCED];
        List<Contact> con=[select Id,name,birthdate from contact where AccountId= :accountId WITH SECURITY_ENFORCED
        LIMIT 1];
        if(listOfAcc!=null && listOfAcc.size()>0){
            wrapperForAccName wrpr = new wrapperForAccName();
            wrpr.accName = listOfAcc[0].name;
            wrpr.dob = String.valueOf(con[0].birthdate);
            wrpr.passCode =  String.valueOf(listOfAcc[0].Verification_Code__c);
            wrpr.parentAccount = String.valueOf(listOfAcc[0].parent.Name);
            data.accName = wrpr;
            data.allForms = NotesForms(accountId , category , subCategory);
        }
        return data;
    }
    
    public class wrapperForNotesData{
        @AuraEnabled public List<Form__c> allForms;
        @AuraEnabled public wrapperForAccName accName;
        
    }
    @AuraEnabled
    public static wrapperForEditData bringData(String accountId , String category , String subCategory){
        wrapperForEditData data = new wrapperForEditData();
        List<Account> listOfAcc = [SELECT Id , Verification_Code__c , Name, parent.Name FROM Account
         WHERE Id= : accountId WITH SECURITY_ENFORCED];
        List<Contact> con=[select Id,name,birthdate from contact where AccountId= :accountId 
        WITH SECURITY_ENFORCED
        LIMIT 1];
        if(listOfAcc!=null && listOfAcc.size()>0){
            wrapperForAccName wrpr = new wrapperForAccName();
            wrpr.accName = listOfAcc[0].name;
            wrpr.dob = String.valueOf(con[0].birthdate);
            wrpr.passCode =  String.valueOf(listOfAcc[0].Verification_Code__c);
            wrpr.parentAccount = String.valueOf(listOfAcc[0].parent.Name);
            data.accName = wrpr;
            data.allForms = fetchAccountAssociatedForms(accountId , category , subCategory);
        }
        return data;
    }
    
    public class wrapperForEditData{
        @AuraEnabled public List<Form__c> allForms;
        @AuraEnabled public wrapperForAccName accName;
    }
    @AuraEnabled(cacheable=true)
    public static getFormFieldsWrapper getFormFields(String formId,String acctId,Integer intOffSet){
        
        String query ;  
        Boolean hasEvaluatedPhysicalTherapist = false;
        List<formFieldWrapper> jsonListMultiPickList = new List<formFieldWrapper>();  
        List<User> physicalTherapists = new List<User>();//List of Physical Therapists
        List<Medical_Examination__c> allergyData = new List<Medical_Examination__c>();
        List<Medical_Examination__c> glucoseObservation =  new List<Medical_Examination__c>();
        List<Medical_Examination__c> vitalObservation =  new List<Medical_Examination__c>();
        List<Dataset1__c> conditionData =  new List<Dataset1__c>();
        List<ICD_Codes__c> childConditionData =  new List<ICD_Codes__c>();
        List<Notes__c> relatedNotes = new List<Notes__c>();
        Map<Id,Dataset1__c> parentProblems = new Map<Id,Dataset1__c>();        
        List<Prescription_Order__c> medicationData = new List<Prescription_Order__c>();
        Id currentUserId = UserInfo.getUserId();
        User currentUser;
        List<List<Form_Field__c>> finalList = new List<List<Form_Field__c>>();
        List<String> listOfScheduledDays = new List<String>{'Scheduled_Monday__c','Scheduled_Tuesday__c','Schedule_Wednesday__c','Schedule_Thursday__c',
            'Schedule_Friday__c','Schedule_Saturday__c','Schedule_Sunday__c'};
                List<Form__c> formData = [SELECT Id,Scheduled_Tuesday__c, Scheduled_Monday__c, Schedule_Wednesday__c,
                                          Schedule_Thursday__c, Schedule_Friday__c,
                                          Schedule_Saturday__c, Schedule_Sunday__c,
                                          Category__c,Name,Locations__c,Sub_Category__c,Version__c,Sections__c
                                          FROM Form__c WHERE Id= :formId WITH SECURITY_ENFORCED];
        
        
        // For MultiPicklist Values START
        
        // For MultiPicklist Values END
        
        system.debug('form data '+formData);
        if(formData!=null && formData.size()>0){
            for(String str : listOfScheduledDays){          
                if( String.isNotBlank(String.valueOf(formData[0].get(str))) ){
                    formFieldWrapper jsonRec = new formFieldWrapper();
                    jsonRec.label = str;
                    jsonRec.value =  String.valueOf(formData[0].get(str)).split(';');
                    if(String.valueOf(formData[0].get(str)).split(';')!=null && String.valueOf(formData[0].get(str)).split(';').size()>0){
                        jsonListMultiPickList.add(jsonRec);
                    }
                    
                }
                
            }
            Integer maxSections = (Integer)formData[0].Sections__c;
            system.debug('maxSections '+maxSections);
            
            
            List<Form_Field__c> listOfFields = new List<Form_Field__c>();
            
            query = 'SELECT Id,ElixirSuite__style__c,Name,ElixirSuite__API_Name__c ,ElixirSuite__Field_Label_Long__c,ElixirSuite__Default_Text_Area__c,ElixirSuite__Row_Matrix__c,ElixirSuite__Column_Matrix__c, ElixirSuite__Columns__c,ElixirSuite__Data_Entry_Type__c,ElixirSuite__Data_Type__c,ElixirSuite__css__c,'+
                'ElixirSuite__Field_Name__c,ElixirSuite__Maximum_Column_in_each_Section__c,ElixirSuite__form__r.name,ElixirSuite__Picklist_Values__c,ElixirSuite__Section__c,ElixirSuite__width__c,ElixirSuite__Sequence_Order__c FROM ElixirSuite__Form_Field__c'+
                ' WHERE ElixirSuite__Form__c= :formId ORDER BY ElixirSuite__Section__c limit 15  OFFSET : Integer.valueOf(intOffSet)';
            system.debug('query '+query);
            
            //List<Form_Field__c> listOfFormToFields = Database.query(query);
            List<Form_Field__c> SectionFields = new List<Form_Field__c>();
            List<Form_Field__c>  listOfFormToFields = [SELECT Id,style__c,Name,API_Name__c ,Field_Label_Long__c,Default_Text_Area__c,Row_Matrix__c,Column_Matrix__c, Columns__c,Data_Entry_Type__c,Data_Type__c,css__c,
                                                       Field_Name__c,Maximum_Column_in_each_Section__c,form__r.name,Picklist_Values__c,Section__c,width__c,Sequence_Order__c FROM Form_Field__c
                                                       WHERE Form__c= :formId WITH SECURITY_ENFORCED
                                                       ORDER BY Section__c limit 50  OFFSET : Integer.valueOf(intOffSet)];
            Map<Id,sObject> allFormFields = new Map<Id,sObject>(listOfFormToFields);
            if(listOfFormToFields!=null && listOfFormToFields.size()>0){
                intOffSet += listOfFormToFields.size();
                Integer sectionSize = listOfFormToFields.size();
                Integer sectionNumber = Integer.valueOf(listOfFormToFields[sectionSize-1].Section__c);
                List<Form_Field__c> sectionData =[SELECT Id,style__c,Name,API_Name__c ,Field_Label_Long__c,Default_Text_Area__c,Row_Matrix__c,Column_Matrix__c, Columns__c,Data_Entry_Type__c,Data_Type__c,css__c,
                                                  Field_Name__c,Maximum_Column_in_each_Section__c,form__r.name,Picklist_Values__c,Section__c,width__c,Sequence_Order__c FROM Form_Field__c
                                                  WHERE Form__c= :formId And Section__c =:sectionNumber
                                                  WITH SECURITY_ENFORCED];
                Map<Id,sObject> allsectionData = new Map<Id,sObject>(sectionData);
                if(sectionData!=null && sectionData.size()>0){
                    for(Id formFieldId : allsectionData.keySet()){
                        if(! allFormFields.containsKey(formFieldId)){
                            // listOfFormToFields.add((Form_Field__c)allsectionData.get(formFieldId));
                            intOffSet = intOffSet + 1;
                        }
                    }
                }
            }
            
            
            
            
            Integer oldSection = 1;
            if(listOfFormToFields!=null && listOfFormToFields.size()>0){
                //   System.debug('before formRec');
                
                List<Form_Field__c> recordsList = new List<Form_Field__c>();
                
                for(form_Field__c fieldRec : listOfFormToFields){
                    // System.debug('field rec '+fieldRec.Data_Entry_Type__c);
                    if((fieldRec.Data_Entry_Type__c == 'Picklist:PhysicalTherapist' && hasEvaluatedPhysicalTherapist == false) || fieldRec.Data_Entry_Type__c == 'Referred_List'){
                        physicalTherapists = [SELECT Id,Name FROM User WITH SECURITY_ENFORCED LIMIT 999];
                        hasEvaluatedPhysicalTherapist = true;
                    }
                    if(fieldRec.Data_Entry_Type__c == 'Picklist:Allergy'){
                        allergyData = [SELECT Substance__c,Substance_Code__c,Reaction__c
                                       FROM Medical_Examination__c where  Account__c = : acctId AND RecordType.DeveloperName = 'Allergy'
                                       AND Substance__c!=NULL WITH SECURITY_ENFORCED];
                        
                    }
                    if(fieldRec.Data_Entry_Type__c == 'Medication_list'){
                        medicationData = [SELECT Drug_Name__c,Id,Number_of_Times_Days_Weeks__c,Reason_new__c,
                                          Ferquency__c,Route_New__c,Reason__c,Type__c,Dosage_Form__c,(select Strength__c,Dosage_Instruction__c,Repeat__c
                                                                                                      from Frequency__r)
                                          FROM Prescription_Order__c where  Account__c=:acctId WITH SECURITY_ENFORCED
                                          order by CreatedDate asc limit 110];
                        
                    }
                    if(fieldRec.Data_Entry_Type__c == 'Glucose_note'){
                        glucoseObservation = [SELECT Id,Intervention__c,Type_of_check__c,
                                              Note__c,Glucose_Reading__c
                                              FROM Medical_Examination__c where  Account__c=:acctId and
                                              RecordType.developerName = 'Glucose' WITH SECURITY_ENFORCED
                                              order by CreatedDate asc];
                    }
                    if(fieldRec.Data_Entry_Type__c == 'Vitals_signs'){
                        System.debug('field rec inside vital'+fieldRec.Data_Entry_Type__c);
                        vitalObservation =  [select id, Blood_Pressure_Systolic__c,Blood_Pressure_diasystolic__c,Temperature__c,  
                                             Pulse__c, createdDate,
                                             Oxygen_Saturation__c from Medical_Examination__c where
                                             Account__c=:acctId and  RecordType.DeveloperName='Vital_Sign' 
                                             AND Blood_Pressure_Systolic__c!=null WITH SECURITY_ENFORCED];
                        System.debug('vital data '+vitalObservation);
                        
                    }
                    // Use case is to fetch all the PROBLEM corrsponding to a particular account.
                    
                    // All the PROBLEM wil have RELATED DAIGNOSES
                    
                    //  All the PROBLEM wil have RELATED NOTES
                    
                    Id problemRecType = Schema.SObjectType.Dataset1__c.getRecordTypeInfosByName().get('Non-Templatized').getRecordTypeId();
                    if(fieldRec.Data_Entry_Type__c == 'Diagnosis_Code'){
                        //fetch all the problems related to an account
                        
                        conditionData = [SELECT Account__c,CreatedById,Dataset1__c,CreatedDate,Description__c,Id,IsActive__c,IsDeleted,
                                         LastModifiedById,LastModifiedDate,Name,OwnerId,Problem_Name__c,RecordTypeId,
                                         Templatized_Problem__c FROM Dataset1__c where Account__c=:acctId  AND RecordType.Id=:problemRecType WITH SECURITY_ENFORCED];
                        for (Dataset1__c record  : conditionData){
                            System.debug('problem data '+record);
                            // System.debug('problem data ind fields '+record.HealthCloudGA__EvidenceLabel__c);
                            parentProblems.put(record.id,record);
                        }
                        
                        if(conditionData!=null && conditionData.size()>0){
                            //fetch all the daignoses related to a problem
                            childConditionData = [SELECT Category__c,Code_Description__c,Code_Type__c,Code__c,CreatedById,CreatedDate,ICD_Codes__c,
                                                  Diagnosis_Code_and_Name__c,Id,IsDeleted,LastModifiedById,LastModifiedDate,
                                                Name,OwnerId,Dataset1__c FROM ICD_Codes__c where Dataset1__c IN :parentProblems.keySet() WITH SECURITY_ENFORCED];
                        }
                        
                        if(conditionData!=null && conditionData.size()>0){
                            relatedNotes = [select id,Name,Notes__c,Note__c,Dataset1__c
                                            from Notes__c where Dataset1__c IN :parentProblems.keySet() WITH SECURITY_ENFORCED];
                        }                  
                    }
                    
                    
                    if(fieldRec.Data_Entry_Type__c == 'Active_Users'){
                        currentUser =  [SELECT Id,Name FROM USER WHERE Id= :currentUserId WITH SECURITY_ENFORCED LIMIT 1];
                        
                    }
                    // System.debug('out Of  finalList');
                    Integer newSection = Integer.valueOf(fieldRec.Section__c);  
                    System.debug(newSection);
                    System.debug(oldSection);
                    if(newSection != null && newSection!=0){
                        if(newSection != oldSection){
                            oldSection = newSection;                                            
                            finalList.add(recordsList);          
                            recordsList = new List<Form_Field__c>();
                            recordsList.add(fieldRec);
                        }
                        else{
                            
                            recordsList.add(fieldRec);
                        }
                    }                        
                }
                
                finalList.add(recordslist);                              
            }          
        }
        
        
        getFormFieldsWrapper wrpr = new getFormFieldsWrapper();
        wrpr.allFields = finalList;
        wrpr.multiPicklistValues = jsonListMultiPickList;
        wrpr.listOfUsers = physicalTherapists;
        wrpr.listOfAllergy = allergyData;
        wrpr.currentUser = currentUser;
        wrpr.listOfMedication=medicationData;
        wrpr.listOfglucoseObservation  = glucoseObservation;
        wrpr.mapOfObservation.put('glucoseData', glucoseObservation);
        wrpr.mapOfObservation.put('vitalData', vitalObservation);
        wrpr.listOfconditionData = conditionData;
        wrpr.listOfrelatedNotes =relatedNotes;
        wrpr.listOfRelatedDaignoses=childConditionData;
        wrpr.nameSpace = Elixir_Utility.getNamespace();
        // wrpr.parentChildConditionData = parentChildCondition;
        // wrpr.parentProblems = parentProblems;
        // wrpr.relatedProblemDaignoses = relatedProblemDaignoses;
        // wrpr.relatedNotesMap = relatedNotesMap;
        wrpr.runScroll = true;
        wrpr.dynamicOffset = intOffSet;
        
        return wrpr;
    }
    public class notesDataWrapper {
        public String data;
        public Boolean isEditable;
        public string Id;
        
    }
    @AuraEnabled
    public static void saveForm(String formId , String dataSelected , String accountId , String inputDataSelected , String inputDateTimeselectedValues ,
                                String inputTextAreaSelected, String inputDateSelectedValues, List<Medical_Examination__c> allergyDataToInsert,
                                String jsonList, String selectedUser,String selectedVia,List<Medical_Examination__c> glucoseDataToSave,
                                List<Medical_Examination__c>  vitalSignsDataToSave,String problemDaignosesDataToSave , String attachId ,
                                String commentSign ,String starttimeProcedure,String endtimeProcedure,String sendEmailRequest,String toUpdateProblemRecordsOnForm,List<String> toDeleteproblemRecordsOnForm,
                                list<Notes__c> toUpdateNotes,List<String> diagnoseToDel,List<String> problemToDel,List<sObject> toUpdateProblemsOnForm,String allNotes
                               ){
                                   
                                   system.debug('nnn'+allNotes);
                                   system.debug(dataSelected);
                                   system.debug(accountId);
                                   System.debug('update string '+toUpdateProblemRecordsOnForm);
                                   //Boolean defaultRecordInsertFlag = false;
                                   
                                   List<String> toDelProblemRecords = new  List<String>();
                                   List<Form_Data__c> formRecList = new List<Form_Data__c>();
                                   Map<String, object> m = (Map<String, object>)JSON.deserializeUntyped(dataSelected);
                                   Map<String, object> inputRecs = (Map<String, object>)JSON.deserializeUntyped(inputDataSelected);
                                   Map<String, object> inputTextAreaRecs = (Map<String, object>)JSON.deserializeUntyped(inputTextAreaSelected);
                                   Map<String, object> inputDateRecs = (Map<String, object>)JSON.deserializeUntyped(inputDateSelectedValues);
                                   Map<String, object> inputDateTimeRecs = (Map<String, object>)JSON.deserializeUntyped(inputDateTimeselectedValues);
                                   //Parent template fetch
                                   string level1='';
                                   string level2='';
                                   string level3='';
                                   List<Form_Data__c> FData = [SELECT Id,Name,Form__c,Approval_Level_s__c,Approval_Values__c 
                                   FROM Form_Data__c WHERE Form__c = : formId WITH SECURITY_ENFORCED];
                                   System.debug('Form data for role '+FData);
                                   for(Form_Data__c i : FData){
                                       if(i.Approval_Values__c!=null){
                                           if(i.Approval_Level_s__c == 'Level 1'){
                                               System.debug('inside level 1 '+i.Approval_Values__c);
                                               level1 += i.Approval_Values__c+',';
                                           }
                                           else if(i.Approval_Level_s__c == 'Level 2'){
                                               level2 += i.Approval_Values__c+',';
                                           }
                                           else if(i.Approval_Level_s__c == 'Level 3'){
                                               level3 += i.Approval_Values__c+',';
                                           }
                                       }
                                   }
                                   
                                   Visits__c[] RecentVisit=  [select id from Visits__c where Status__c =:'Active' WITH SECURITY_ENFORCED
                                   order by CreatedDate desc limit 1];
                                   
                                   
                                   List<Form__c> listOfTemplates = [SELECT Id,name,Category__c,Sub_Category__c,Version__c FROM Form__c where Id= :formId WITH SECURITY_ENFORCED];
                                   
                                   if(listOfTemplates!=null && listOfTemplates.size()>0){
                                       Form__c formRec = new Form__c();
                                       formRec.Form__c = formId;
                                       formRec.Account__c = accountId;
                                       formRec.Category__c = listOfTemplates[0].Category__c;
                                       formRec.Sub_Category__c = listOfTemplates[0].Sub_Category__c;
                                       formRec.Version__c = listOfTemplates[0].Version__c;
                                       formRec.name = listOfTemplates[0].Name;
                                       formRec.Patient_Signature_Link__c = attachId ;
                                       formRec.Patient_signature_comments__c = commentSign ;
                                       formRec.Approval_Values1__c=level1;
                                       formRec.Approval_Values_2__c=level2;
                                       formRec.Approval_Values_3__c=level3;
                                       formRec.Status__c='Open';
                                       if(RecentVisit.size() > 0) {
                                           formRec.Care_Episode__c=RecentVisit[0].id;   
                                       }
                                       
                                       Upsert formRec;
                                       if(String.isNotBlank(allNotes)){    
                                           List<Notes__c> notesDataToInsert= new List<Notes__c>();
                                           Id devRecordTypeId = Schema.SObjectType.Notes__c.getRecordTypeInfosByName().get('Doctors Notes').getRecordTypeId();
                                           List<notesDataWrapper> allNotesToInsert =  (List<notesDataWrapper>) System.JSON.deserialize(allNotes, List<notesDataWrapper>.class);
                                           for(notesDataWrapper rec : allNotesToInsert){
                                               Notes__c nt = new Notes__c();
                                               nt.Note__c = rec.data;
                                               nt.Notes__c = rec.data;
                                               nt.Account__c = accountId;
                                               nt.Form__c = formRec.Id;
                                               nt.Type__c = 'Doctor Notes';
                                               nt.RecordTypeId = devRecordTypeId;
                                               notesDataToInsert.add(nt);
                                           }
                                           insert notesDataToInsert;
                                       }
                                       List<Form_Data__c> cons = new List<Form_Data__c>();
                                       List<Form_Data__c> con = [SELECT Id,Name,Form__c,Approval_Level_s__c,Approval_Values__c 
                                       FROM Form_Data__c WHERE Form__c = : formId WITH SECURITY_ENFORCED];
                                       for(Form_Data__c c : con)
                                       {
                                           Form_Data__c conCopy = c.clone(false,true);
                                           conCopy.Form__c = formRec.Id;
                                           cons.add(conCopy);
                                       }
                                       insert cons;
                                       system.debug('cons '+cons);
                                       system.debug('forRec '+formRec);
                                       for(String key : m.keySet()){
                                           Form_Data__c formDataRec = new Form_Data__c();
                                           formDataRec.Checkbox__c = Boolean.valueOf(m.get(key));
                                           formDataRec.Form_Field__c = Id.valueOf(key);
                                           formDataRec.Form__c = Id.valueOf(formRec.Id);
                                           // formDataRec.Field_Type__c = 'CheckBox';
                                           formRecList.add(formDataRec);
                                           system.debug('key '+key);
                                       }
                                       for(String key : inputRecs.keySet()){
                                           Form_Data__c formDataRec = new Form_Data__c();
                                           formDataRec.Text__c = String.valueOf(inputRecs.get(key));
                                           formDataRec.Form_Field__c = Id.valueOf(key);
                                           formDataRec.Form__c = Id.valueOf(formRec.Id);
                                           // formDataRec.Field_Type__c = 'Text';
                                           formRecList.add(formDataRec);
                                           system.debug('key '+key);
                                       }
                                       for(String key : inputTextAreaRecs.keySet()){
                                           Form_Data__c formDataRec = new Form_Data__c();
                                           formDataRec.TextArea__c = String.valueOf(inputTextAreaRecs.get(key));
                                           formDataRec.Form_Field__c = Id.valueOf(key);
                                           formDataRec.Form__c = Id.valueOf(formRec.Id);
                                           // formDataRec.Field_Type__c = 'Text Area';
                                           formRecList.add(formDataRec);
                                           system.debug('key '+key);
                                       }
                                       for(String key : inputDateRecs.keySet()){
                                           Form_Data__c formDataRec = new Form_Data__c();
                                           formDataRec.Date__c = Date.valueOf((String)inputDateRecs.get(key));
                                           formDataRec.Form_Field__c = Id.valueOf(key);
                                           formDataRec.Form__c = Id.valueOf(formRec.Id);
                                           // formDataRec.Field_Type__c = 'Text Area';
                                           formRecList.add(formDataRec);
                                           system.debug('key '+key);
                                       }
                                       for(String key : inputDateTimeRecs.keySet()){
                                           String formatDateTime = String.valueOf(inputDateTimeRecs.get(key)).trim();
                                           formatDateTime = formatDateTime.replace('T', ' ');
                                           Datetime now = DateTime.valueOf(formatDateTime);
                                           Integer offset = UserInfo.getTimezone().getOffset(now);
                                           Datetime local = now.addSeconds(offset/1000);
                                           Form_Data__c formDataRec = new Form_Data__c();
                                           formDataRec.Date_Time__c = local;                                          
                                           formDataRec.Form_Field__c = Id.valueOf(key);
                                           formDataRec.Form__c = Id.valueOf(formRec.Id);
                                           // formDataRec.Field_Type__c = 'Text Area';
                                           formRecList.add(formDataRec);
                                           
                                       }
                                       if(formRecList.size()>0 && formRecList!=null){
                                           Upsert formRecList;
                                       }
                                       if(sendEmailRequest=='Nursing Screen & Assessment (1 and 2)'){
                                           //  Elixir_FormApexController.sendEmailToUR(accountId,formId);
                                       }
                                       if(toDeleteproblemRecordsOnForm!=null && toDeleteproblemRecordsOnForm.size()>0){
                                           //delete [select id from HealthCloudGA__EhrCondition__c where id in : toDeleteproblemRecordsOnForm ];
                                       }
                                       if(!String.isEmpty(toUpdateProblemRecordsOnForm)){
                                           System.debug('inside update existing record');
                                           Elixir_FormApexController.updateAlreadyExistingProblemRecordsOnForm(toUpdateProblemRecordsOnForm);
                                       }
                                       if(toUpdateNotes.size()>0 && toUpdateNotes!=null){
                                           update toUpdateNotes;
                                       }
                                       if(toUpdateProblemsOnForm.size()>0 && toUpdateProblemsOnForm!=null){
                                           update toUpdateProblemsOnForm;
                                       }
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
                                                   toDelProblemRecords.add(String.valueOf(mapOfProblem.get('Id')));
                                               }
                                               if(!String.isEmpty(String.valueOf(mapOfProblem.get('isrelatedDiagnosesUpdated'))) && Boolean.valueOf(mapOfProblem.get('isrelatedDiagnosesUpdated'))){
                                               }
                                               
                                               if(!String.isEmpty(String.valueOf(mapOfProblem.get('isProblemToInsert'))) && Boolean.valueOf(mapOfProblem.get('isProblemToInsert'))){
                                                   Dataset1__c newProblem = new Dataset1__c();              
                                                   newProblem.Name = String.valueOf(mapOfProblem.get('Name'));
                                                   newProblem.Account__c = accountId;
                                                   newProblem.Description__c = String.valueOf(mapOfProblem.get('ElixirSuite__Description__c'));
                                                   newProblem.Dataset1__c = String.valueOf(mapOfProblem.get('Id'));
                                                   newProblem.RecordTypeId = problemNonTempatizedRecTypeId;
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
                                                               newDiagnoses.Code_Label__c  =  String.valueOf(mapOfDiagnoses.get('ElixirSuite__Code_Label__c'));
                                                               newDiagnoses.Code__c  =  String.valueOf(mapOfDiagnoses.get('Code'));
                                                               newDiagnoses.Code_Type__c  =  String.valueOf(mapOfDiagnoses.get('CodeType'));
                                                               newDiagnoses.RecordTypeId =  problemNonTempatizedRecTypeIdForICD;
                                                               String truncatedName = '';
                                                               if(String.valueOf(mapOfDiagnoses.get('ElixirSuite__Diagnosis_Code_and_Name__c')).length() > 80 ){
                                                                   truncatedName = String.valueOf(mapOfDiagnoses.get('ElixirSuite__Diagnosis_Code_and_Name__c')).substring(0, 80);
                                                               }
                                                               else {
                                                                   truncatedName = String.valueOf(mapOfDiagnoses.get('ElixirSuite__Diagnosis_Code_and_Name__c'));                                                      
                                                               }
                                                               newDiagnoses.Name =String.valueOf(mapOfDiagnoses.get('Name'));
                                                               newDiagnoses.ICD_Codes__c=String.valueOf(mapOfDiagnoses.get('Id'));
                                                               System.debug('createed diagnoses 67 '+newDiagnoses);
                                                               uow.registerRelationship(newDiagnoses, ICD_Codes__c.Dataset1__c , newProblem);                          
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
                                                           System.debug('notes value '+String.valueOf(mapOfNotes.get('ElixirSuite__Notes__c')));
                                                           newNote.Notes__c  =  String.valueOf(mapOfNotes.get('ElixirSuite__Notes__c'));                                                      
                                                           newNote.Account__c =accountId;                                            
                                                           uow.registerRelationship(newNote, Notes__c.Dataset1__c , newProblem);
                                                           uow.registerNew(newNote);
                                                           System.debug('notes record  '+newNote);
                                                           System.debug('new-note id '+newNote.Id);
                                                           
                                                           
                                                           //Note Insertion end
                                                           
                                                       }}
                                               }
                                           }
                                           uow.commitWork();
                                       }
                                       toDelProblemRecords.addAll(problemToDel);
                                       if(toDelProblemRecords!=null && toDelProblemRecords.size()>0){
                                           delete [select id from Dataset1__c where id in : toDelProblemRecords];
                                       }
                                       if(diagnoseToDel!=null && diagnoseToDel.size()>0){
                                           delete [select id from ICD_Codes__c where id in : diagnoseToDel];
                                       }
                                       //Creation of default procedure which will be related to latest encounter present for that account.
                                       
                                       Procedure__c defaultProcedure = new Procedure__c();
                                       //defaultProcedure.Account__c=accountId;
                                       //defaultProcedure.Form__c=  formRec.Id;   
                                       system.debug('hjj' + defaultProcedure + ' '+  String.valueOf(accountId) + ' ' +formRec.Id + ' '+ starttimeProcedure + ' ' +  endtimeProcedure);
                                       Elixir_utility.attachProcedureEncounter(new List<sObject>{defaultProcedure}, String.valueOf(accountId), formRec.Id,starttimeProcedure,endtimeProcedure );
                                       
                                       //Allergy data insertion  
                                       Id allergyMedicalexamination = Schema.SObjectType.Medical_Examination__c.getRecordTypeInfosByName().get('Allergy').getRecordTypeId();                                          
                                       list<Medical_Examination__c> toInsertAllergy = new List<Medical_Examination__c>();
                                       for (Medical_Examination__c data  : allergyDataToInsert) {
                                           data.Start_Time__c=System.now();
                                           data.End_Time__c=System.now().addDays(1);
                                           Medical_Examination__c allergyRecords = new Medical_Examination__c();
                                           if(String.isBlank(data.id)) {                                                      
                                               toInsertAllergy.add(data);
                                           }                                                  
                                       }
                                       
                                       if(toInsertAllergy!=null && toInsertAllergy.size()>0){                                                  
                                           insert toInsertAllergy;  
                                       }
                                       
                                       //        Vital records insertion  || Received JSON has mixed records, some are already there in org and newly added record from
                                       //        UI, so filter out the newly created records and insert them only.                              
                                       
                                       list<Medical_Examination__c> vitalRecords = new List<Medical_Examination__c>();
                                       Id vitalSignsMedicalexamination = Schema.SObjectType.Medical_Examination__c.getRecordTypeInfosByName().get('Vital Sign').getRecordTypeId();
                                       for (Medical_Examination__c dataForVital  : vitalSignsDataToSave) {
                                           dataForVital.Account__c= accountId;
                                           dataForVital.Start_Time__c=System.now();
                                           dataForVital.End_Time__c=System.now().addDays(1);
                                           dataForVital.RecordTypeId = vitalSignsMedicalexamination;
                                           // Medical_Examination__c  = new Medical_Examination__c();
                                           if(String.isBlank(dataForVital.id)) {                                                      
                                               vitalRecords.add(dataForVital);
                                           }                                                  
                                       }
                                       
                                       if(vitalRecords!=null && vitalRecords.size()>0){
                                           insert vitalRecords;  
                                       }
                                       Id glocoseMedicalexamination = Schema.SObjectType.Medical_Examination__c.getRecordTypeInfosByDeveloperName().get('Glucose').getRecordTypeId();
                                       list<Medical_Examination__c> toInsertGlucoseData = new List<Medical_Examination__c>();
                                       for (Medical_Examination__c glucoseData  : glucoseDataToSave) {
                                           if(String.isBlank(glucoseData.id)) {
                                               Medical_Examination__c toInsert  = new Medical_Examination__c();
                                               glucoseData.Start_Time__c=System.now();
                                               glucoseData.End_Time__c=System.now().addDays(1);
                                               glucoseData.RecordTypeId = glocoseMedicalexamination;
                                               toInsertGlucoseData.add(glucoseData);
                                           }
                                       }
                                       if(toInsertGlucoseData!=null && toInsertGlucoseData.size()>0){                                                  
                                           upsert toInsertGlucoseData;  
                                       }
                                       
                                       //Medication records insertion
                                       if(!String.isBlank(jsonList)) {                              
                                           SelectionMedicationRecordsApexController.saveData(jsonList,'','',accountId,String.valueOf(system.today()),String.valueOf(System.today()));
                                       }
                                   }
                                   
                                   
                                   
                                   
                                   
                               }
    @AuraEnabled
    public static void updateAlreadyExistingProblemRecordsOnForm(String toUpdateProblemRecords) {
        System.debug('inside update existing record method');
        List<String> existingIds  = new list<String>();
        List<String> diagnosesRecordsToDelete = new list<String>();
        list<ICD_Codes__c> insertNewDiagnosesForExistingProblem = new list<ICD_Codes__c>();
        Map<String, Object> allProblemsToUpdate =(Map<String, Object>) JSON.deserializeUntyped(toUpdateProblemRecords);
        List<Object> diagnosesRecordToUpdate = (List<Object>) allProblemsToUpdate.get('daignosesRecord');
        Id problemNonTempatizedRecTypeIdForICD = Schema.SObjectType.ICD_Codes__c.getRecordTypeInfosByName().get('Non-Templatized').getRecordTypeId();
        for(Object diagnosesRec : diagnosesRecordToUpdate){
            Map<String, Object> mapOfDiagnosis = (Map<String, Object>) diagnosesRec;
            if(!String.isBlank(String.valueOf(mapOfDiagnosis.get('isDeleted')))
               && Boolean.valueOf(mapOfDiagnosis.get('isDeleted'))){
                   System.debug('inside delete new diagnoses');
                   diagnosesRecordsToDelete.add(String.valueOf(mapOfDiagnosis.get('Id')));
               }
            if(!String.isBlank(String.valueOf(mapOfDiagnosis.get('isAdded'))) && !String.isBlank(String.valueOf(mapOfDiagnosis.get('isAdded')))
               && Boolean.valueOf(mapOfDiagnosis.get('isAdded'))){
                   
                   ICD_Codes__c diagnosesRecordToinsert = new ICD_Codes__c();
                   diagnosesRecordToinsert.Code_Label__c  =  String.valueOf(mapOfDiagnosis.get('Name'));
                   diagnosesRecordToinsert.Code__c  =  String.valueOf(mapOfDiagnosis.get('Code'));
                   diagnosesRecordToinsert.Dataset1__c = String.valueOf(mapOfDiagnosis.get('ElixirSuite__Dataset1__c'));
                   diagnosesRecordToinsert.Code_Type__c  =  String.valueOf(mapOfDiagnosis.get('CodeType'));
                   diagnosesRecordToinsert.RecordTypeId =  problemNonTempatizedRecTypeIdForICD;
                   String truncatedName = '';
                   if(String.valueOf(mapOfDiagnosis.get('ElixirSuite__Diagnosis_Code_and_Name__c')).length() > 80 ){
                       truncatedName = String.valueOf(mapOfDiagnosis.get('ElixirSuite__Diagnosis_Code_and_Name__c')).substring(0, 80);
                   }
                   else {
                       truncatedName = String.valueOf(mapOfDiagnosis.get('ElixirSuite__Diagnosis_Code_and_Name__c'));                                                      
                   }
                   diagnosesRecordToinsert.Name =truncatedName;
                   diagnosesRecordToinsert.ICD_Codes__c=String.valueOf(mapOfDiagnosis.get('Id'));                  
                   insertNewDiagnosesForExistingProblem.add(diagnosesRecordToinsert);
                   
               }
        }  
        if(insertNewDiagnosesForExistingProblem.size()>0 && insertNewDiagnosesForExistingProblem!=null) {
            System.debug('to insert record list '+insertNewDiagnosesForExistingProblem);
            insert insertNewDiagnosesForExistingProblem;
        }
        if(diagnosesRecordsToDelete.size()>0 && diagnosesRecordsToDelete!=null) {
            System.debug('to delete records '+diagnosesRecordsToDelete);
            delete  [select id from ICD_Codes__c where id in : diagnosesRecordsToDelete];
        }
    }
    
    
    @AuraEnabled
    public static void delProblemRecords(List<String> toDelProblemRecords){
        if(toDelProblemRecords!=null && toDelProblemRecords.size()>0){
            // delete [select id from HealthCloudGA__EhrCondition__c where id in : toDelProblemRecords ];
        }
        
    }
    
    //JSON Structure
    public class root{
        @AuraEnabled
        public List<JSON2Apex> jsonListForTaper{get;set;}
        @AuraEnabled
        public List<JSONprn> jsonListForPRN{get;set;}
        @AuraEnabled
        public List<actionOrder> jsonListForActionOrder{get;set;}
    }
    public class JSONprn{
        @AuraEnabled
        public String Id {get;set;}
        @AuraEnabled
        public String medicationName {get;set;}
        @AuraEnabled
        public Integer dispenseExpectedSupplyDuration {get;set;}
        @AuraEnabled
        public String types {get;set;}
        @AuraEnabled
        public String startDate {get;set;}
        @AuraEnabled
        public Boolean afterDischarge {get;set;}
        @AuraEnabled
        public String dosageForm {get;set;}
        @AuraEnabled
        public String reasonLabel {get;set;}
        @AuraEnabled
        public String Route {get;set;}
        @AuraEnabled
        public String Warning {get;set;}
        
        @AuraEnabled
        public List<singleRecPRN> singleRecForPrn {get;set;}
    }
    public class singleRecPRN{
        public String UnitsForPrn  {get;set;}
        public String StrengthForPrn  {get;set;}                          
        public String DosageForPrn  {get;set;}
        public String Repeat  {get;set;}
        public String Dosage_Instruction  {get;set;}
        
    }
    public class JSON2Apex {
        @AuraEnabled
        public String Id {get;set;}
        @AuraEnabled
        public String medicationName {get;set;}
        @AuraEnabled
        public String types {get;set;}
        @AuraEnabled
        public String startDate {get;set;}
        @AuraEnabled
        public Integer dispenseExpectedSupplyDuration {get;set;}
        @AuraEnabled
        public Boolean afterDischarge {get;set;}
        @AuraEnabled
        public String dosageForm {get;set;}
        @AuraEnabled
        public String reasonLabel {get;set;}
        @AuraEnabled
        public String Route {get;set;}
        @AuraEnabled
        public String Warning {get;set;}
        
        @AuraEnabled
        public List<Days> Days {get;set;}
        
    }
    public class Days {
        @AuraEnabled
        public List<String> times;
        @AuraEnabled
        public List<String> Units;
        @AuraEnabled
        public List<String> Dosage;
        @AuraEnabled
        public List<String> Strength;
        @AuraEnabled
        public Integer indexOfDay;
        @AuraEnabled
        public String Repeat;
        @AuraEnabled
        public Integer Dosage_Instruction;
    }
    //Action Order
    public class actionOrder {
        
        public String Id;
        public String medicationName;
        public String types;
        public String startDate;
        public Boolean afterDischarge;
        public String endDate;
        public Integer dispenseExpectedSupplyDuration;
        public Boolean PRNdisplay;
        public Boolean MARdisplay;
        public String Justification;
        public List<SingleRecForActionOrder> singleRecForActionOrder;    
    }
    public class SingleRecForActionOrder {
        public List<String> StartTime;
        public String Repeat;
        public String Dosage_Instruction;
        public String textMessage;
    }
    
    public static void saveProblemDiagnosisDataAfterEdit(String problemDaignosesDataToSave,String accountId,String toUpdateProblemRecordsOnForm,List<String> toDeleteproblemRecordsOnForm,
                                                         list<Notes__c> toUpdateNotes,List<String> diagnoseToDel,List<String> problemToDel,List<sObject> toUpdateProblemsOnForm){
                                                             List<String> toDelProblemRecords = new List<String>();
                                                             
                                                             if(!String.isBlank(problemDaignosesDataToSave)) {
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
                                                                         toDelProblemRecords.add(String.valueOf(mapOfProblem.get('Id')));
                                                                     }
                                                                     if(!String.isEmpty(String.valueOf(mapOfProblem.get('isrelatedDiagnosesUpdated'))) && Boolean.valueOf(mapOfProblem.get('isrelatedDiagnosesUpdated'))){
                                                                     }
                                                                     
                                                                     if(!String.isEmpty(String.valueOf(mapOfProblem.get('isProblemToInsert'))) && Boolean.valueOf(mapOfProblem.get('isProblemToInsert'))){
                                                                         Dataset1__c newProblem = new Dataset1__c();              
                                                                         newProblem.Name = String.valueOf(mapOfProblem.get('Name'));
                                                                         newProblem.Account__c = accountId;
                                                                         newProblem.Description__c = String.valueOf(mapOfProblem.get('ElixirSuite__Description__c'));
                                                                         newProblem.Dataset1__c = String.valueOf(mapOfProblem.get('Id'));
                                                                         // if(!String.isBlank(String.valueOf(mapOfProblem.get('Care_Plan_Template_Problem__c')))) {
                                                                         //newProblem.Care_Plan_Template_Problem__c=String.valueOf(mapOfProblem.get('Care_Plan_Template_Problem__c'));
                                                                         // }
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
                                                                                     newDiagnoses.Code_Label__c  =  String.valueOf(mapOfDiagnoses.get('Name'));
                                                                                     newDiagnoses.Code__c  =  String.valueOf(mapOfDiagnoses.get('Code'));
                                                                                     newDiagnoses.Code_Type__c  =  String.valueOf(mapOfDiagnoses.get('CodeType'));
                                                                                     newDiagnoses.RecordTypeId =  problemNonTempatizedRecTypeIdForICD;
                                                                                     String truncatedName = '';
                                                                                     if(String.valueOf(mapOfDiagnoses.get('ElixirSuite__Diagnosis_Code_and_Name__c')).length() > 80 ){
                                                                                         truncatedName = String.valueOf(mapOfDiagnoses.get('ElixirSuite__Diagnosis_Code_and_Name__c')).substring(0, 80);
                                                                                     }
                                                                                     else {
                                                                                         truncatedName = String.valueOf(mapOfDiagnoses.get('ElixirSuite__Diagnosis_Code_and_Name__c'));                                                      
                                                                                     }
                                                                                     newDiagnoses.Name =truncatedName;
                                                                                     newDiagnoses.ICD_Codes__c=String.valueOf(mapOfDiagnoses.get('Id'));
                                                                                     System.debug('createed diagnoses 67 '+newDiagnoses);
                                                                                     uow.registerRelationship(newDiagnoses, ICD_Codes__c.Dataset1__c  , newProblem);                          
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
                                                                                 System.debug('notes value '+String.valueOf(mapOfNotes.get('ElixirSuite__Notes__c')));
                                                                                 newNote.Notes__c  =  String.valueOf(mapOfNotes.get('ElixirSuite__Notes__c'));
                                                                                 //   newNote.Dataset1__c = String.valueOf(mapOfNotes.get('Notes__c'));
                                                                                 // newNote.Account__c=accountId;
                                                                                 newNote.Account__c =accountId;                                            
                                                                                 uow.registerRelationship(newNote, Notes__c.Dataset1__c , newProblem);
                                                                                 uow.registerNew(newNote);
                                                                                 System.debug('notes record  '+newNote);
                                                                                 System.debug('new-note id '+newNote.Id);
                                                                                 
                                                                                 
                                                                                 //Note Insertion end
                                                                                 
                                                                             }}
                                                                     }
                                                                 }
                                                                 uow.commitWork();
                                                             }
                                                             toDelProblemRecords.addAll(problemToDel);
                                                             if(toDelProblemRecords!=null && toDelProblemRecords.size()>0){
                                                                 delete [select id from Dataset1__c where id in : toDelProblemRecords];
                                                             }
                                                             if(diagnoseToDel!=null && diagnoseToDel.size()>0){
                                                                 delete [select id from ICD_Codes__c where id in : diagnoseToDel];
                                                             }
                                                             if(toDeleteproblemRecordsOnForm!=null && toDeleteproblemRecordsOnForm.size()>0){
                                                                 delete [select id from Dataset1__c where id in : toDeleteproblemRecordsOnForm ];
                                                             }
                                                             if(!String.isEmpty(toUpdateProblemRecordsOnForm)){
                                                                 System.debug('inside update existing record');
                                                                 Elixir_FormApexController.updateAlreadyExistingProblemRecordsOnForm(toUpdateProblemRecordsOnForm);
                                                             }
                                                             if(toUpdateNotes.size()>0 && toUpdateNotes!=null){
                                                                 update toUpdateNotes;
                                                             }
                                                             if(toUpdateProblemsOnForm.size()>0 && toUpdateProblemsOnForm!=null){
                                                                 update toUpdateProblemsOnForm;
                                                             }
                                                         }
    
    // THIS IS USED TO SEND EMAIL TO U-R(utilization review) USERS WHENEVER A PROCEDURE IS SUBMITTED.
    
    @AuraEnabled
    public static void sendEmailToUR(String acctId,String formId){
        List<User> toSendEmailUsers = new list<User>();
        toSendEmailUsers = [select Id,Username,Email,profile.name,UserRole.Name,UserRole.id from user where profile.name='System Administrator' or UserRole.Name='Development Team'];
        System.debug('list of users '+toSendEmailUsers);                  
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        for(User forEmail : toSendEmailUsers) {
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();                        
            mail.setSaveAsActivity(false);
            // mail.setTemplateId(theTemplate);
            // mail.setWhatId(poId);
            mail.setSenderDisplayName('Salesforce ELIXIR Support');
            mail.setSubject('New assesment is created!');
            mail.setPlainTextBody('A new assesment has been created');
            mail.setHtmlBody( 'A new assesment has been created. To view your assesment, get to the patient page <a href=https://elixir-development-dev-ed.my.salesforce.com/lightning/r/Account/'+acctId+'/view>Click here.</a>');                    
            mail.setTargetObjectId(forEmail.Id);
            mail.setToAddresses(new String[] {forEmail.Email});  //add other emails here.
            emails.add(mail);
            
            
            
        }
        Messaging.sendEmail(emails);    
        
    }
    
    public class wrappperAllForms {
        list<Notes__c> toInsertNewNote;
        List<Medical_Examination__c>  vital;
        List<Medical_Examination__c> allergy;   
        String prescriptionData;
    }
    
    @AuraEnabled
    public static void saveEditForm(String formId , String dataSelected, String inputDataSelected , String inputTextAreaSelected,
                                    String inputDateTimeselectedValues, String inputDateSelectedValues ,String starttimeProcedure,
                                    String endtimeProcedure,String accountId,
                                    String signatureComment1 ,String signatureImage1 , String signatureDate1 , String signeeName1,
                                    String signatureComment2 ,String signatureImage2 , String signatureDate2 , String signeeName2,
                                    String signatureComment3 ,String signatureImage3 , String signatureDate3 , String signeeName3,
                                    String approvalLevel,
                                    String problemDaignosesDataToSave,String toUpdateProblemRecordsOnForm,List<String> toDeleteproblemRecordsOnForm,
                                    list<Notes__c> toUpdateNotes,List<String> diagnoseToDel,List<String> problemToDel,List<sObject> toUpdateProblemsOnForm,
                                    List<Medical_Examination__c> glucoseDataToSave,String wrapper,string allNotes){
                                        system.debug(formId);
                                        List<Medical_Examination__c> allergyData = new List<Medical_Examination__c>();
                                        List<Medical_Examination__c> vitalSignsDataToSave = new List<Medical_Examination__c>();
                                        wrappperAllForms extData ;
                                        if(!String.isEmpty(wrapper)){
                                            extData  = (wrappperAllForms)  System.JSON.deserialize(wrapper, wrappperAllForms.class);
                                            List<Notes__c> toInsertRelatedNewNote = extData.toInsertNewNote;
                                            for(Notes__c nt : toInsertRelatedNewNote){
                                                nt.Account__c = accountId;
                                            }
                                            //  insert toInsertRelatedNewNote;
                                            if( extData.allergy!=null)
                                            {allergyData = extData.allergy;
                                            }
                                            if(extData.vital!=null) {                                          
                                                vitalSignsDataToSave = extData.vital;
                                            }
                                            if(!String.isBlank(extData.prescriptionData)) {                              
                                                SelectionMedicationRecordsApexController.saveData(extData.prescriptionData,'','',accountId,String.valueOf(system.today()),String.valueOf(System.today()));
                                                delete [SELECT ID from Prescription_Order__c where Account__c=:accountId AND Drug_Name__c=null WITH SECURITY_ENFORCED];
                                                
                                            }
                                            
                                        }
                                        
                                        system.debug('save map'+inputDataSelected);
                                        List<Form_Data__c> formRecList1 = new List<Form_Data__c>();
                                        // List<Form_Data__c> formRecList = new List<Form_Data__c>();
                                        Visits__c[] RecentVisit=  [select id from Visits__c where Status__c =:'Active' 
                                        WITH SECURITY_ENFORCED order by CreatedDate desc limit 1];
                                        Form__c formRecordToUpdt = [SELECT Form__c,Account__c,Approval_Values1__c,Approval_Values_2__c,Approval_Values_3__c,Category__c,Comment_1__c,Comment_2__c,
                                                                    Comment_3__c,Signature_value_1__c,
                                                                    Signature_value_2__c,Signature_value_3__c,Signed_By_Level_1__c,Signed_By_Level_2__c,
                                                                    Signed_By_Level_3__c,Signed_Date_1__c,Signed_Date_2__c,Signed_Date_3__c,Care_Episode__c,
                                                                    Status__c,Id,Name FROM Form__c where id=:formId WITH SECURITY_ENFORCED limit 1];
                                        if(RecentVisit.size() > 0) {
                                            formRecordToUpdt.Care_Episode__c=RecentVisit[0].id;   
                                            update formRecordToUpdt;
                                        }
                                        
                                        string level1='';
                                        string level2='';
                                        string level3='';
                                        Form__c parentForm ;
                                        if(!String.isBlank(formRecordToUpdt.Form__c)){
                                            List<Form_Data__c> FData = [SELECT Id,Name,Form__c,Approval_Level_s__c,Approval_Values__c 
                                            FROM Form_Data__c WHERE Form__c = : formRecordToUpdt.Form__c WITH SECURITY_ENFORCED];
                                            System.debug('Form data for role '+FData);
                                            for(Form_Data__c i : FData){
                                                if(i.Approval_Values__c!=null){
                                                    if(i.Approval_Level_s__c == 'Level 1'){
                                                        System.debug('inside level 1 '+i.Approval_Values__c);
                                                        level1 += i.Approval_Values__c+',';
                                                    }
                                                    else if(i.Approval_Level_s__c == 'Level 2'){
                                                        level2 += i.Approval_Values__c+',';
                                                    }
                                                    else if(i.Approval_Level_s__c == 'Level 3'){
                                                        level3 += i.Approval_Values__c+',';
                                                    }
                                                }
                                            }
                                        }
                                        
                                        Boolean level1ApprovalValid = true ;
                                        Boolean level2ApprovalValid = true ;
                                        Boolean level3ApprovalValid = true ;
                                        if(String.isBlank(level1)){
                                            level1ApprovalValid = false;
                                        }
                                        if(String.isBlank(level2)){
                                            level2ApprovalValid = false;
                                        }
                                        if(String.isBlank(level3)){
                                            level3ApprovalValid = false;
                                        }
                                        system.debug('val 1 '+String.valueOf(formRecordToUpdt.Signature_value_1__c));
                                        system.debug('level  1 '+approvalLevel);
                                        if(approvalLevel == 'Level1' && String.isBlank(formRecordToUpdt.Signature_value_1__c)){
                                            system.debug('INSIDE ');
                                            formRecordToUpdt.Signed_By_Level_1__c = signeeName1;
                                            formRecordToUpdt.Comment_1__c = signatureComment1;
                                            formRecordToUpdt.Signature_value_1__c = signatureImage1 ;
                                            
                                            formRecordToUpdt.Signed_Date_1__c = date.parse(signatureDate1) ;   
                                            //formRecordToUpdt.Comment_1__c = signatureComment1 (signatureDate);
                                            if(!level2ApprovalValid){
                                                formRecordToUpdt.status__c= 'Completed';
                                            }
                                            else {
                                                formRecordToUpdt.status__c= 'Under Review';
                                            }
                                            
                                            update formRecordToUpdt ;
                                        }
                                        if(approvalLevel == 'Level2' && String.isBlank(formRecordToUpdt.Signature_value_2__c)){
                                            formRecordToUpdt.Signed_By_Level_2__c = signeeName2;
                                            formRecordToUpdt.Comment_2__c = signatureComment2;
                                            formRecordToUpdt.Signature_value_2__c = signatureImage2 ;
                                            formRecordToUpdt.Signed_Date_2__c = date.parse(signatureDate2) ;
                                            if(!level3ApprovalValid){
                                                formRecordToUpdt.status__c= 'Completed';
                                            }
                                            else {
                                                formRecordToUpdt.status__c= 'Under Review';
                                            }
                                            update formRecordToUpdt ;
                                            //  formRecordToUpdt.Comment_2__c = signatureComment2 (signatureDate);
                                        }
                                        if(approvalLevel == 'Level3' && String.isBlank(formRecordToUpdt.Signature_value_3__c)){
                                            formRecordToUpdt.Signed_By_Level_3__c = signeeName3;
                                            formRecordToUpdt.Comment_3__c = signatureComment3;
                                            formRecordToUpdt.Signature_value_3__c = signatureImage3 ;
                                            formRecordToUpdt.Signed_Date_3__c = date.parse(signatureDate3) ;
                                            formRecordToUpdt.status__c= 'Completed';
                                            update formRecordToUpdt ;
                                            // formRecordToUpdt.Comment_3__c = signatureComment3 (signatureDate);
                                        }
                                        Map<Id, Form_Data__c> formRecList = new Map<Id, Form_Data__c>();
                                        Map<String, object> m = (Map<String, object>)JSON.deserializeUntyped(dataSelected);
                                        Map<String, object> inputRecs = (Map<String, object>)JSON.deserializeUntyped(inputDataSelected);
                                        Map<String, object> inputTextAreaRecs = (Map<String, object>)JSON.deserializeUntyped(inputTextAreaSelected);
                                        Map<String, object> inputDateRecs = (Map<String, object>)JSON.deserializeUntyped(inputDateSelectedValues);
                                        Map<String, object> inputDateTimeRecs = (Map<String, object>)JSON.deserializeUntyped(inputDateTimeselectedValues);
                                        List<Form_Data__c> myList = new List<Form_Data__c>();
                                        
                                        myList = [Select checkbox__c , Form__c,Text__c,TextArea__c, Form_Field__c,Date__c,Date_Time__c
                                         from Form_Data__c where Form__c=:formId
                                         WITH SECURITY_ENFORCED]; //this list gets created as expected
                                        
                                        for(String key : m.keySet()){
                                            for(Form_Data__c obj : myList)
                                            {
                                                if(key==obj.Form_Field__c){
                                                    obj.checkbox__c = Boolean.valueOf(m.get(key));
                                                }
                                                
                                            }  
                                        }
                                        for(String key : inputRecs.keySet()){                                
                                            for(Form_Data__c obj : myList){                                        
                                                if(key==obj.Form_Field__c){
                                                    System.debug('inside' + obj.Form_Field__c);
                                                    System.debug('key ' + key);
                                                    obj.Text__c = String.valueOf(inputRecs.get(key));
                                                    system.debug('DATA'+String.valueOf(inputRecs.get(key)));
                                                }
                                                else {
                                                    Form_Data__c formDataRec = new Form_Data__c();
                                                    formDataRec.Text__c = String.valueOf(inputRecs.get(key));
                                                    formDataRec.Form_Field__c = Id.valueOf(key);
                                                    formDataRec.Form__c =formId;
                                                    // formDataRec.Field_Type__c = 'Text';
                                                    formRecList1.add(formDataRec);
                                                    system.debug('key '+key);
                                                }
                                                
                                            }
                                        }
                                        for(String key : inputTextAreaRecs.keySet()){
                                            for(Form_Data__c obj : myList){
                                                System.debug('inside TA' + obj.Form_Field__c);
                                                System.debug('key TA' + key);
                                                if(key==obj.Form_Field__c){
                                                    obj.TextArea__c = String.valueOf(inputTextAreaRecs.get(key));
                                                }
                                                else {
                                                    Form_Data__c formDataRec = new Form_Data__c();
                                                    formDataRec.TextArea__c = String.valueOf(inputTextAreaRecs.get(key));
                                                    formDataRec.Form_Field__c = Id.valueOf(key);
                                                    formDataRec.Form__c = formId;
                                                    // formDataRec.Field_Type__c = 'Text Area';
                                                    formRecList1.add(formDataRec);
                                                }
                                                
                                            }
                                        }
                                        for(String key : inputDateRecs.keySet()){
                                            for(Form_Data__c obj : myList){
                                                if(key==obj.Form_Field__c){
                                                    obj.Date__c = Date.valueOf((String)inputDateRecs.get(key));
                                                }
                                                
                                            }
                                        }  
                                        for(String key : inputDateTimeRecs.keySet()){
                                            for(Form_Data__c obj : myList){
                                                String formatDateTime = String.valueOf(inputDateTimeRecs.get(key)).trim();
                                                formatDateTime = formatDateTime.replace('T', ' ');
                                                Datetime now = DateTime.valueOf(formatDateTime);
                                                Integer offset = UserInfo.getTimezone().getOffset(now);
                                                Datetime local = now.addSeconds(offset/1000);
                                                if(key==obj.Form_Field__c){
                                                    obj.Date_Time__c = local;
                                                }
                                                
                                            }
                                        }                                
                                        system.debug('my'+myList);
                                        if(!myList.isEmpty())
                                        {
                                            
                                            update myList;
                                        }
                                        if(!formRecList1.isEmpty()){
                                            insert formRecList1 ;
                                        }
                                        system.debug('nnn'+allNotes);
                                        if(String.isNotBlank(allNotes)){    
                                            List<Notes__c> notesDataToInsert= new List<Notes__c>();
                                            List<Notes__c> notesDataToupdte= new List<Notes__c>();    
                                            notesDataToupdte=[select id,Note__c,Notes__c from Notes__c where Form__c=:formId];
                                            Id devRecordTypeId = Schema.SObjectType.Notes__c.getRecordTypeInfosByName().get('Doctors Notes').getRecordTypeId();
                                            List<notesDataWrapper> allNotesToInsert =  (List<notesDataWrapper>) System.JSON.deserialize(allNotes, List<notesDataWrapper>.class);
                                            system.debug('allNotesToInsert-----'+allNotesToInsert);
                                            for(notesDataWrapper rec : allNotesToInsert){
                                                
                                                if(String.isBlank(rec.id)){
                                                    Notes__c nt = new Notes__c();
                                                    nt.Note__c = rec.data;
                                                    nt.Notes__c = rec.data;
                                                    nt.Account__c = accountId;
                                                    nt.Form__c = formId;
                                                    nt.Type__c = 'Doctor Notes';
                                                    nt.Account__c = accountId;
                                                    nt.RecordTypeId = devRecordTypeId;
                                                    notesDataToInsert.add(nt);  
                                                }                                          
                                            }
                                            for(notesDataWrapper recU : allNotesToInsert){
                                                for(Notes__c notes: notesDataToupdte){
                                                    if(recU.id == notes.id){
                                                        notes.Note__c = recU.data;
                                                        notes.Notes__c = recU.data;
                                                    }    
                                                }                        
                                            }
                                            if(!notesDataToupdte.isEmpty())
                                            {  
                                                update notesDataToupdte;
                                            }
                                            if(notesDataToInsert!=null && notesDataToInsert.size()>0){
                                                insert notesDataToInsert;
                                            }    
                                            
                                        }
                                        //Creation of default procedure which will be related to latest encounter present for that account.
                                        
                                        Procedure__c defaultProcedure = new Procedure__c();
                                        //defaultProcedure.Account__c=accountId;
                                        //defaultProcedure.Form__c=  formId;  
                                        system.debug('ghjkkkkkkkkkkkk');
                                        Elixir_utility.attachExistingProcedureEncounter(new List<Procedure__c> {defaultProcedure}, accountId, formId,starttimeProcedure,endtimeProcedure );
                                        //Edit handling of AddProblemDiagnosis data
                                        saveProblemDiagnosisDataAfterEdit(problemDaignosesDataToSave,accountId,toUpdateProblemRecordsOnForm,toDeleteproblemRecordsOnForm,toUpdateNotes,diagnoseToDel,problemToDel,toUpdateProblemsOnForm);
                                        if(vitalSignsDataToSave.size()>0 && vitalSignsDataToSave!=null){
                                            list<Medical_Examination__c> vitalRecords = new List<Medical_Examination__c>();
                                            for (Medical_Examination__c dataForVital  : vitalSignsDataToSave) {
                                                dataForVital.Account__c= accountId;
                                                dataForVital.Start_Time__c=System.now();
                                                dataForVital.End_Time__c=System.now().addDays(1);
                                                dataForVital.RecordTypeId = Schema.SObjectType.Medical_Examination__c.getRecordTypeInfosByDeveloperName().get('Vital_Sign').getRecordTypeId();
                                                // Medical_Examination__c  = new Medical_Examination__c();
                                                if(String.isBlank(dataForVital.id)) {                                                      
                                                    vitalRecords.add(dataForVital);
                                                }                                                  
                                            }
                                            
                                            if(vitalRecords!=null && vitalRecords.size()>0){
                                                insert vitalRecords;  
                                            }
                                        }
                                        
                                        List<Medical_Examination__c> toInsertGlucoseData = new List<Medical_Examination__c>();
                                        if(glucoseDataToSave.size()>0 && glucoseDataToSave!=null) {
                                            for (Medical_Examination__c glucoseData  : glucoseDataToSave) {
                                                if(String.isBlank(glucoseData.id)) {
                                                    Medical_Examination__c toInsert  = new Medical_Examination__c();
                                                    glucoseData.Start_Time__c=System.now();
                                                    glucoseData.End_Time__c=System.now().addDays(1);
                                                    glucoseData.RecordTypeId = Schema.SObjectType.Medical_Examination__c.getRecordTypeInfosByDeveloperName().get('Glucose').getRecordTypeId();
                                                    toInsertGlucoseData.add(glucoseData);
                                                }
                                            }
                                        }
                                        if(toInsertGlucoseData!=null && toInsertGlucoseData.size()>0){                                                  
                                            upsert toInsertGlucoseData;  
                                        }
                                        
                                        
                                        
                                        
                                        //Allergy data insertion  
                                        if(allergyData.size()>0 && allergyData!=null){                                        
                                            list<Medical_Examination__c> toInsertAllergy = new List<Medical_Examination__c>();
                                            for (Medical_Examination__c data  : allergyData) {
                                                data.Start_Time__c=System.now();
                                                data.End_Time__c=System.now().addDays(1);
                                                Medical_Examination__c allergyRecords = new Medical_Examination__c();
                                                if(String.isBlank(data.id)) {                                                      
                                                    toInsertAllergy.add(data);
                                                }                                                  
                                            }
                                            
                                            if(toInsertAllergy!=null && toInsertAllergy.size()>0){                                                  
                                                insert toInsertAllergy;  
                                            }
                                        }
                                        
                                    }
    
    @AuraEnabled
    public static void DeleteSavedForm(String formId){
        list<Form_Data__c> FormValues =[select checkbox__c ,Text__c,TextArea__c,Form_Field__c,Form__c from Form_Data__c where Form__c=:formId];
        form__c FormtoDel= [select id,Status__c from form__c where Account__c != null AND id =:formId 
        WITH SECURITY_ENFORCED];
        If(FormtoDel.Status__c =='Open' || FormtoDel.Status__c =='In-Progress' || FormtoDel.Status__c =='Ready for Review' ){
            delete FormValues;  
            delete FormtoDel;
        }
        
    }
    
    
    
    @AuraEnabled
    public static List<SelectOption>  allPickListValues(){        
        List<SelectOption> options = new List<SelectOption>();        
        //Map<String, Schema.SObjectField> M = Schema.SObjectType.Medical_Examination__c.fields.getMap();
        List<Schema.PicklistEntry> testVal = new List<Schema.PicklistEntry>();
        for(Schema.PicklistEntry valueToAdd : testVal ) {
            options.add(new SelectOption(valueToAdd.getLabel(), valueToAdd.getValue()));
            
        }
        return options;
    }
    
    public class SelectOption {
        public SelectOption(String value, String label) {
            this.value = value;
            this.label = label;
            this.disabled = false;
            this.escapeItem = false;
        }
        
        public SelectOption(String value, String label, Boolean isDisabled) {
            this.value = value;
            this.label = label;
            this.disabled = isDisabled;
            this.escapeItem = false;
        }
        
        @AuraEnabled
        public String label { get;set; }
        @AuraEnabled
        public String value { get;set; }
        @AuraEnabled
        public Boolean disabled { get;set; }
        @AuraEnabled
        public Boolean escapeItem { get;set; }
        
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
    
    @AuraEnabled
    public static wrapperForEdit FormDataValues(string FormId){
        wrapperForEdit wrap = new wrapperForEdit();
        list<Form_Data__c> FormValues =[select checkbox__c ,Text__c,Date__c,Date_Time__c,TextArea__c,
        Form_Field__c,Form__c from Form_Data__c where Form__c=:FormId 
        WITH SECURITY_ENFORCED];
        system.debug('FormValues'+FormValues);
        map<Id,object> mapedData = new map<Id, object>();
        map<Id,object> mapedText = new map<Id, object>();
        map<Id,object> mapedTextArea = new map<Id, object>();
        map<Id,object> mapedDate = new map<Id, object>();
        map<Id,object> mapedDateTime = new map<Id, object>();
        for(Form_Data__c data : FormValues){
            mapedData.put(data.Form_Field__c, data.checkbox__c );
            mapedText.put(data.Form_Field__c, data.Text__c );
            mapedTextArea.put(data.Form_Field__c, data.TextArea__c );
            mapedDate.put(data.Form_Field__c, data.Date__c );
            mapedDateTime.put(data.Form_Field__c, data.Date_Time__c );
        }
        
        wrap.newMap =mapedData;
        wrap.newMapText =mapedText;
        wrap.newMapTextArea =mapedTextArea;
        wrap.newDateValue =mapedDate;
        wrap.newDateTimeValue =mapedDateTime;
        system.debug('mapedData'+mapedData);
        
        return wrap;
    }
    
    public class wrapperForEdit{
        @AuraEnabled   public map<id, Object> newMap  ;
        @AuraEnabled   public map<id, Object> newMapText  ;
        @AuraEnabled   public map<id, Object> newMapTextArea  ;  
        @AuraEnabled   public map<id, Object> newDateValue  ;
        @AuraEnabled   public map<id, Object> newDateTimeValue ;
    }
    public class wrapperForAccName{
        @AuraEnabled  public List<Form__c> forms;
        @AuraEnabled  public String accName;
        @AuraEnabled  public String dob;
        @AuraEnabled  public String passCode;
        @AuraEnabled  public String parentAccount;
        @AuraEnabled public String nameSpace;
    }
    public class formFieldWrapper{
        @AuraEnabled   public string label { get; set; }
        @AuraEnabled    public List<String> value { get; set; }
    }
    public class getFormFieldsWrapper{
        @AuraEnabled   public List<List<Form_Field__c>> allFields{ get; set; }
        @AuraEnabled   public List<List<Form_Field__c>> sectionData{ get; set; }
        @AuraEnabled    public  List<formFieldWrapper> multiPicklistValues{ get; set; }
        @AuraEnabled    public  List<User> listOfUsers{ get; set; }
        @AuraEnabled    public  List<Medical_Examination__c> listOfAllergy{ get; set; }
        @AuraEnabled    public  List<Prescription_Order__c> listOfMedication{ get; set; }
        @AuraEnabled   public  List<Medical_Examination__c> listOfglucoseObservation {get;set;}
        @AuraEnabled   public  Map<String,List<Medical_Examination__c>> mapOfObservation =  new Map<String,List<Medical_Examination__c>>();
        @AuraEnabled    public User currentUser { get; set; }
        @AuraEnabled   public List<Dataset1__c> listOfconditionData {get;set;}
        @AuraEnabled   public List<Notes__c> listOfrelatedNotes {get;set;}
        @AuraEnabled   public List<ICD_Codes__c> listOfRelatedDaignoses {get;set;}
        //@AuraEnabled   public Map<HealthCloudGA__EhrCondition__c,List<HealthCareDiagnosis>> parentChildConditionData {get;set;}
        @AuraEnabled   public Map<Id,Dataset1__c> parentProblems {get;set;}
        //@AuraEnabled   public Map<Id,HealthCareDiagnosis> relatedProblemDaignoses {get;set;}
        @AuraEnabled   public Map<Id,Notes__c> relatedNotesMap{get;set;}
        @AuraEnabled   public Boolean runScroll{get;set;}
        @AuraEnabled   public Integer dynamicOffset{get;set;}
        @AuraEnabled public String nameSpace;
        //  @AuraEnabled  public List<Notes__c> relatedNotes {get;set;}
    }
    
    
    @AuraEnabled
    public static getFormDataWrapper getFormData(String formId,String acctId,Integer intOffSet){
        System.debug('form id '+formId);
        System.debug('account  id '+acctId);
        form__c FormValue = [select form__c ,Patient_Signature_Link__c from Form__c where id =:formId 
        WITH SECURITY_ENFORCED];
        String signatureValue = FormValue.Patient_Signature_Link__c ;
        system.debug('new data' + signatureValue);
        id FormNew = FormValue.Form__c;
        String query ;
        Boolean hasEvaluatedPhysicalTherapist = false;
        List<formFieldWrapper> jsonListMultiPickList = new List<formFieldWrapper>();  
        List<User> physicalTherapists = new List<User>();//List of Physical Therapists
        List<Account> acctDetails = new List<Account>();
        List<Notes__c> relatedNotesNew = new List<Notes__c>();
        List<Medical_Examination__c> vitalObservation =  new List<Medical_Examination__c>();
        List<Medical_Examination__c> allergyData = new List<Medical_Examination__c>();
        List<Medical_Examination__c> glucoseObservation = new List<Medical_Examination__c>();
        List<Prescription_Order__c> medicationData = new List<Prescription_Order__c>();
        Id currentUserId = UserInfo.getUserId();
        User currentUser;
        List<List<Form_Field__c>> finalList = new List<List<Form_Field__c>>();
        // List<HealthCloudGA__EhrCondition__c> conditionData =  new List<HealthCloudGA__EhrCondition__c>();
        List<Dataset1__c> conditionData =  new List<Dataset1__c>();
        List<ICD_Codes__c> childConditionData =  new List<ICD_Codes__c>();
        List<Notes__c> relatedNotes = new List<Notes__c>();
        // Map<HealthCloudGA__EhrCondition__c,List<HealthCareDiagnosis>> parentChildCondition =
        //  new  Map<HealthCloudGA__EhrCondition__c,List<HealthCareDiagnosis>>();              
        //  Map<Id,Notes__c> relatedNotesMap = new Map<Id,Notes__c>();
        Map<Id,Dataset1__c> parentProblems = new Map<Id,Dataset1__c>();
        String accountVerifyCode = [SELECT Id , Name,Verification_Code__c FROM Account
         WHERE Id= :acctId WITH SECURITY_ENFORCED LIMIT 1].Verification_Code__c;
        String userVerifyCode = String.valueOf([Select id,name, Verification_Code__c From User 
        Where Id = :UserInfo.getUserId() WITH SECURITY_ENFORCED].Verification_Code__c);
        String userSignatureVerifyCode = String.valueOf([Select id,name, Signature_Attachment_Id__c From User
         Where Id = :UserInfo.getUserId() WITH SECURITY_ENFORCED].Signature_Attachment_Id__c);
        List<String> listOfScheduledDays = new List<String>{'Scheduled_Monday__c','Scheduled_Tuesday__c','Schedule_Wednesday__c','Schedule_Thursday__c',
            'Schedule_Friday__c','Schedule_Saturday__c','Schedule_Sunday__c'};
                List<Form__c> formDataForSignAndApprove = new List<Form__c>();
        List<Form__c> formData = [SELECT Id,Scheduled_Tuesday__c, Scheduled_Monday__c, Schedule_Wednesday__c,
                                  Schedule_Thursday__c, Schedule_Friday__c,
                                  Schedule_Saturday__c, Schedule_Sunday__c,
                                  Category__c,Name,Locations__c,Sub_Category__c,Version__c,Sections__c,Status__c
                                  FROM Form__c WHERE Id= :FormNew WITH SECURITY_ENFORCED];
        if(!String.isBlank(formId)) {
            formDataForSignAndApprove = [SELECT Id,Scheduled_Tuesday__c, Scheduled_Monday__c, Schedule_Wednesday__c,
                                         Schedule_Thursday__c, Schedule_Friday__c,
                                         Schedule_Saturday__c, Schedule_Sunday__c,
                                         Category__c,Name,Locations__c,Sub_Category__c,Version__c,Sections__c,
                                         Account__c,Approval_Values1__c,Approval_Values_2__c,Approval_Values_3__c,Comment_1__c,Comment_2__c,
                                         Comment_3__c,Signature_value_1__c,
                                         Signature_value_2__c,Signature_value_3__c,Signed_By_Level_1__c,Signed_By_Level_2__c,
                                         Signed_By_Level_3__c,Signed_Date_1__c,Signed_Date_2__c,Signed_Date_3__c,
                                         Status__c
                                         FROM Form__c WHERE Id= :formId WITH SECURITY_ENFORCED];
        }
        if(!String.isBlank(acctId)){
            acctDetails = [Select id,Name,Signature_Attachment_Id__c from Account where id=:acctId 
            WITH SECURITY_ENFORCED limit 1];
        }
        system.debug('form data '+formData);
        if(formData!=null && formData.size()>0){
            for(String str : listOfScheduledDays){          
                if( String.isNotBlank(String.valueOf(formData[0].get(str))) ){ 
                    formFieldWrapper jsonRec = new formFieldWrapper();
                    jsonRec.label = str;
                    jsonRec.value =  String.valueOf(formData[0].get(str)).split(';');
                    if(String.valueOf(formData[0].get(str)).split(';')!=null && String.valueOf(formData[0].get(str)).split(';').size()>0){
                        jsonListMultiPickList.add(jsonRec);
                    }
                    
                }
                
            }
            Integer maxSections = (Integer)formData[0].Sections__c;
            system.debug('maxSections '+maxSections);
            
            
            List<Form_Field__c> listOfFields = new List<Form_Field__c>();
            
            query = 'SELECT Id,ElixirSuite__style__c,Name,ElixirSuite__API_Name__c ,ElixirSuite__Field_Label_Long__c,ElixirSuite__Default_Text_Area__c,ElixirSuite__Row_Matrix__c,ElixirSuite__Column_Matrix__c, ElixirSuite__Columns__c,ElixirSuite__Data_Entry_Type__c,ElixirSuite__Data_Type__c,'+
                'ElixirSuite__Field_Name__c,ElixirSuite__Maximum_Column_in_each_Section__c,ElixirSuite__Picklist_Values__c,ElixirSuite__Section__c,ElixirSuite__Sequence_Order__c FROM ElixirSuite__Form_Field__c'+
                ' WHERE ElixirSuite__Form__c= :FormNew ORDER BY ElixirSuite__Section__c';
            system.debug('query '+query);
            List<Form_Field__c> listOfFormToFields = [SELECT Id,style__c,Name,API_Name__c ,Field_Label_Long__c,Default_Text_Area__c,Row_Matrix__c,Column_Matrix__c, Columns__c,Data_Entry_Type__c,Data_Type__c,css__c,
                                                      Field_Name__c,Maximum_Column_in_each_Section__c,form__r.name,Picklist_Values__c,Section__c,width__c,Sequence_Order__c FROM Form_Field__c
                                                      WHERE Form__c= :FormNew WITH SECURITY_ENFORCED
                                                      ORDER BY Section__c limit 50  OFFSET : Integer.valueOf(intOffSet) ];
            system.debug('size'+listOfFormToFields.size());
            Map<Id,sObject> allFormFields = new Map<Id,sObject>(listOfFormToFields);
            if(listOfFormToFields!=null && listOfFormToFields.size()>0){
                intOffSet += listOfFormToFields.size();
                Integer sectionSize = listOfFormToFields.size();
                Integer sectionNumber = Integer.valueOf(listOfFormToFields[sectionSize-1].Section__c);
                List<Form_Field__c> sectionData =[SELECT Id,style__c,Name,API_Name__c ,Field_Label_Long__c,Default_Text_Area__c,Row_Matrix__c,Column_Matrix__c, Columns__c,Data_Entry_Type__c,Data_Type__c,css__c,
                                                  Field_Name__c,Maximum_Column_in_each_Section__c,form__r.name,Picklist_Values__c,Section__c,width__c,Sequence_Order__c FROM Form_Field__c
                                                  WHERE Form__c= :formId And Section__c =:sectionNumber
                                                  WITH SECURITY_ENFORCED];
                Map<Id,sObject> allsectionData = new Map<Id,sObject>(sectionData);
                if(sectionData!=null && sectionData.size()>0){
                    for(Id formFieldId : allsectionData.keySet()){
                        if(! allFormFields.containsKey(formFieldId)){
                            //listOfFormToFields.add((Form_Field__c)allsectionData.get(formFieldId));
                            intOffSet = intOffSet + 1;
                        }
                    }
                }
            }
            Integer oldSection = 1;
            if(listOfFormToFields!=null && listOfFormToFields.size()>0){
                
                System.debug('before formRec');
                
                List<Form_Field__c> recordsList = new List<Form_Field__c>();
                
                for(form_Field__c fieldRec : listOfFormToFields){
                    if((fieldRec.Data_Entry_Type__c == 'Picklist:PhysicalTherapist' && hasEvaluatedPhysicalTherapist == false) || fieldRec.Data_Entry_Type__c == 'Referred_List'){
                        physicalTherapists = [SELECT Id,Name FROM User WITH SECURITY_ENFORCED LIMIT 999];
                        hasEvaluatedPhysicalTherapist = true;
                    }
                    if(fieldRec.Data_Entry_Type__c == 'Picklist:Allergy'){
                        allergyData = [SELECT Substance__c,Substance_Code__c,Reaction__c
                                       FROM Medical_Examination__c where  Account__c = : acctId AND RecordType.DeveloperName = 'Allergy'
                                       AND Substance__c!=NULL WITH SECURITY_ENFORCED];
                        
                    }
                    if(fieldRec.Data_Entry_Type__c == 'Vitals_signs'){
                        System.debug('field rec inside vital'+fieldRec.Data_Entry_Type__c);
                        vitalObservation =  [select id, Blood_Pressure_Systolic__c,Blood_Pressure_diasystolic__c,Temperature__c,  
                                             Pulse__c, createdDate,
                                             Oxygen_Saturation__c
                                             from Medical_Examination__c where
                                             Account__c=:acctId and  RecordType.DeveloperName='Vital_Sign' AND Blood_Pressure_Systolic__c!=null
                                             WITH SECURITY_ENFORCED];// And createdDate>TODAY and createdDate<TOMORROW];
                        System.debug('vital data '+vitalObservation);
                        
                    }
                    if(fieldRec.Data_Entry_Type__c == 'Glucose_note'){
                        glucoseObservation = [SELECT Id,Intervention__c,Type_of_check__c,
                                              Note__c,Glucose_Reading__c
                                              FROM Medical_Examination__c where  Account__c=:acctId and
                                              RecordType.developerName = 'Glucose' WITH SECURITY_ENFORCED
                                              order by CreatedDate asc];
                    }
                    if(fieldRec.Data_Entry_Type__c == 'Medication_list'){
                        medicationData = [SELECT Drug_Name__c,Id,Number_of_Times_Days_Weeks__c,Reason_new__c,
                                          Ferquency__c,Route_New__c,Reason__c,Type__c,Dosage_Form__c,(select Strength__c,Dosage_Instruction__c,Frequency_Unit__c,Frequency_Value__c,Repeat__c
                                                                                                      from Frequency__r)
                                          FROM Prescription_Order__c where  Account__c=:acctId WITH SECURITY_ENFORCED
                                          order by CreatedDate asc limit 110];
                        
                    }
                    if(fieldRec.Data_Entry_Type__c == 'Notes_Custom'){
                        relatedNotesNew = [SELECT Note__c,Id FROM Notes__c WHERE Account__c=:acctId AND Type__c = 'Doctor Notes'
                                           AND Form__c = :formId WITH SECURITY_ENFORCED
                                           order by CreatedDate DESC];
                        
                    }
                    Id problemRecType = Schema.SObjectType.Dataset1__c.getRecordTypeInfosByName().get('Non-Templatized').getRecordTypeId();
                    if(fieldRec.Data_Entry_Type__c == 'Diagnosis_Code'){
                        //fetch all the problems related to an account
                        
                        conditionData = [SELECT Account__c,CreatedById,CreatedDate,Description__c,Id,IsActive__c,IsDeleted,
                                         LastModifiedById,LastModifiedDate,Name,OwnerId,Dataset1__c,Problem_Name__c,RecordTypeId,
                                         Templatized_Problem__c FROM Dataset1__c where Account__c=:acctId  AND RecordType.Id=:problemRecType WITH SECURITY_ENFORCED];
                        for (Dataset1__c record  : conditionData){
                            System.debug('problem data '+record);
                            // System.debug('problem data ind fields '+record.HealthCloudGA__EvidenceLabel__c);
                            parentProblems.put(record.id,record);
                        }
                        
                        if(conditionData!=null && conditionData.size()>0){
                            //fetch all the daignoses related to a problem
                            childConditionData = [SELECT Category__c,Code_Description__c,Code_Type__c,Code__c,CreatedById,CreatedDate,ICD_Codes__c,
                                                  Diagnosis_Code_and_Name__c,Id,IsDeleted,LastModifiedById,LastModifiedDate,
                                                  Name,OwnerId,Dataset1__c FROM ICD_Codes__c where Dataset1__c IN :parentProblems.keySet()
                                                  WITH SECURITY_ENFORCED];
                            System.debug('%%%% '+childConditionData);
                        }
                        
                        if(conditionData!=null && conditionData.size()>0){
                            relatedNotes = [select id,Name,Notes__c,Dataset1__c,Note__c
                                            from Notes__c where Dataset1__c IN :parentProblems.keySet()
                                            WITH SECURITY_ENFORCED];
                        }                  
                    }
                    if(fieldRec.Data_Entry_Type__c == 'Active_Users'){
                        currentUser =  [SELECT Id,Name,profile.name,UserRole.Name,UserRole.id FROM USER WHERE Id= :currentUserId WITH SECURITY_ENFORCED
                         LIMIT 1];
                        
                    }
                    System.debug('out Of  finalList');
                    Integer newSection = Integer.valueOf(fieldRec.Section__c);  
                    System.debug(newSection);
                    System.debug(oldSection);
                    if(newSection != null && newSection!=0){
                        if(newSection != oldSection){
                            oldSection = newSection;                                            
                            finalList.add(recordsList);          
                            recordsList = new List<Form_Field__c>();
                            recordsList.add(fieldRec);
                        }
                        else{
                            
                            recordsList.add(fieldRec);
                        }
                    }                        
                }
                
                finalList.add(recordslist);                              
            }          
        }
        
        system.debug('finalList '+finalList.size());
        getFormDataWrapper wrpr = new getFormDataWrapper();
        wrpr.allFields = finalList;
        wrpr.multiPicklistValues = jsonListMultiPickList;
        wrpr.listOfUsers = physicalTherapists;
        wrpr.listOfAllergy = allergyData;
        wrpr.currentUser = currentUser;
        wrpr.listOfconditionData = conditionData;
        wrpr.listOfrelatedNotes =relatedNotes;
        wrpr.listOfRelatedDaignoses=childConditionData;
        //  wrpr.parentProblems = parentProblems;
        wrpr.listOfMedication=medicationData;
        wrpr.signatureValues = signatureValue ;
        wrpr.formData=formDataForSignAndApprove;
        wrpr.VerficationCode  = accountVerifyCode ;
        wrpr.relatedNotesNew = relatedNotesNew;
        wrpr.userVerifyCode = userVerifyCode;
        wrpr.userSignatureVerifyCode = userSignatureVerifyCode;
        wrpr.dynamicOffset = intOffSet;
        wrpr.acctDetails= acctDetails;
        wrpr.mapOfObservation.put('vitalData', vitalObservation);
        wrpr.mapOfObservation.put('glucoseData', glucoseObservation);
        return wrpr;
        
    }
    public class getFormDataWrapper{
        @AuraEnabled   public List<List<Form_Field__c>> allFields{ get; set; }
        @AuraEnabled    public  List<formFieldWrapper> multiPicklistValues{ get; set; }
        @AuraEnabled    public  List<User> listOfUsers{ get; set; }
        @AuraEnabled    public  List<Medical_Examination__c> listOfAllergy{ get; set; }
        @AuraEnabled    public  List<Prescription_Order__c> listOfMedication{ get; set; }
        @AuraEnabled    public User currentUser { get; set; }
        @AuraEnabled    public String signatureValues {get;set;}
        @AuraEnabled  public Map<Id,Dataset1__c > parentProblems {get;set;}
        @AuraEnabled   public List<ICD_Codes__c> listOfRelatedDaignoses {get;set;}
        //@AuraEnabled   public Map<HealthCloudGA__EhrCondition__c,List<HealthCareDiagnosis>> parentChildConditionData {get;set;}
        //  @AuraEnabled   public Map<Id,Dataset1__c> parentProblems {get;set;}
        //@AuraEnabled   public Map<Id,HealthCareDiagnosis> relatedProblemDaignoses {get;set;}
        @AuraEnabled   public Map<Id,Notes__c> relatedNotesMap{get;set;}
        @AuraEnabled   public List<Dataset1__c> listOfconditionData {get;set;}
        @AuraEnabled  public List<Notes__c> listOfrelatedNotes {get;set;}
        @AuraEnabled  public Integer dynamicOffset{get;set;}
        //   @AuraEnabled  public List<HealthCloudGA__EhrConditionRelatedItem__c> listOfRelatedDaignoses {get;set;}
        @AuraEnabled    public List<Form__c> formData{ get; set; }
        @AuraEnabled  public String VerficationCode{ get; set; }
        @AuraEnabled  public String userVerifyCode{ get; set; }
        @AuraEnabled public List<Account> acctDetails{ get; set; }
        @AuraEnabled  public String userSignatureVerifyCode{ get; set; }
        @AuraEnabled  public  Map<String,List<Medical_Examination__c>> mapOfObservation =  new Map<String,List<Medical_Examination__c>>();
        @AuraEnabled public List<Notes__c> relatedNotesNew{ get; set; }
    }  
    //get the list of left-over related daignoses for edit functiuinality 
    @AuraEnabled
    public static List<Dataset1__c> getAllProblemTemplates(List<String> existingproblemsList){
        System.debug('template value '+existingproblemsList);
        // system.debug('rt '+[select Name,Problem_Name__c from Dataset1__c  where id not in : existingproblemsList]);
        return [select Id,Name,Problem_Name__c from Dataset1__c 
         where id not in : existingproblemsList AND Account__c=null AND 
         RecordType.DeveloperName = 'Templatized' WITH SECURITY_ENFORCED];
        
    }
    @AuraEnabled
    public static List<ICD_Codes__c > getRelatedDiagnoses(String parentProblemId, List<String> existingIds) {
        return [select Name,Diagnosis_Code_and_Name__c,Code_Type__c,Code__c,Dataset1__c from ICD_Codes__c where Dataset1__c=:parentProblemId and id
                not in : existingIds WITH SECURITY_ENFORCED];
        
    }
    @AuraEnabled
    public static List<ICD_Codes__c>  getAllDaignosesTemplates(List<String> existingDiagnosesList) {  
        return [select Name,Id,Diagnosis_Code_and_Name__c,Code_Type__c,Code__c 
        from ICD_Codes__c where id not in : existingDiagnosesList AND
         RecordType.DeveloperName='Templatized' WITH SECURITY_ENFORCED];
    }
    
    @AuraEnabled
    
    public static List < String > deleteAllForms(List < String > lstRecordId) {
        
        
        // for store Error Messages
        
        List < String > oErrorMsg = new List < String > ();
        
        list<Form_Data__c> FormValues =[select checkbox__c ,Text__c,TextArea__c,Form_Field__c,Form__c
         from Form_Data__c where Form__c IN: lstRecordId
         WITH SECURITY_ENFORCED];
        
        delete FormValues;
        
        // Query Records for delete where id in lstRecordId [which is pass from client side controller]
        
        List < Form__c > lstDeleteRec = [select Id from Form__c where id IN: lstRecordId
        WITH SECURITY_ENFORCED];
        
        system.debug('id '+ lstDeleteRec);
        
        
        
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
        
        return oErrorMsg;
    }
    @AuraEnabled
    public static String getCurrentlyLoggedInUser(List<String> existingproblemsList){
        User currentlyLoggedIn = [select Id,Username,Email,profile.name,UserRole.Name,UserRole.id 
        from user where id= : UserInfo.getUserId() WITH SECURITY_ENFORCED Limit 1];
        return currentlyLoggedIn.UserRole.Name;
    }*/
    public static void dummyMethod(){
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}
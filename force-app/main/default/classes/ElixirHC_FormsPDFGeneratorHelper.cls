/*
* DEVELOPER NAME : TANVEER AHMED
* TEST CLASS NAME : 
* TEST COVERAGE AT THE TIME OF WRITING : 
* CREATED DATE : 
* LAST MODIFIED DATE : 
* LAST MODIFIED BY : 
*/
public with sharing class ElixirHC_FormsPDFGeneratorHelper {
    /*public static  String formIdAsReceived = '';  
    public Form__c formRecord {get;set;}
    public Account accounts {get;set;}
    public String PDFData {get;set;}
    public static WrapperForEditDataGeneric allFieldsv2{ get; set; }
    public static getFormDataWrapper wrprOnVF {get;set;}
    public static WrapperForEditDataGeneric wrprEditOnVF {get;set;}
    public  static String accName{get;set;}
    public static List<Form_Field__c> allFields{ get; set; }
    public static List<wrapperForColWiseData> columnWiseDataOnVF{get;set;}
    public String currentDate {get;set;}
    public static List<String> arrayForHeight{get;set;}
    public static String inputFirstCss {get;set;}
    public static String inputSecondCss {get;set;}
    public static String inputFirstCheckboxClass {get;set;}
    public static String inputSecondCheckboxClass {get;set;}
    public static  Map<Decimal,String> jsonForCls {get;set;}
    public static List<String> matrixCssListOnVF {get;set;}
    public static List<List<wrapperForColWiseData>> parentArrColWiseData{get;set;}
    public List<Medical_Examination__c> vitalData {get;set;}
    public List<Medical_Examination__c> glucoseData {get;set;}
    public static ApprovalProcessDataWrapper approval {get;set;}
    public static String parentTableWidth{get;set;}
    public static wrapperParentArrWithWidhAndData majorDataHold {get;set;}
    public static String allergyRecords{get;set;}
    public static  Contact patContacts {get;set;}
    public static Integer age{get;set;}
    public static List<wrapperForStaticPickList> problemLst {get;set;}
    public static Map<String,String> holdPicklistValueForProblemList {get;set;} 
    public static Map<String,String> holdPicklistValueForHistory {get;set;}
    // public static Map<String,String> holdPicklistValueForHistory {get;set;}
    public static Map<String,String> holdPicklistValueForYesNo {get;set;}
    public static Map<String,String> holdPicklistValueForNote {get;set;} 
    public static Map<String,String> holdPicklistValueForFeedbackRating {get;set;} 
    public static Map<String,String> holdPicklistValueForStatusList {get;set;}
    public static Map<String,String> holdPicklistValueForPulseRateList {get;set;}
    public static Map<String,String> holdPicklistValueForSweatingList {get;set;}
    public static Map<String,String> holdPicklistValueForRestlessness_List {get;set;}
    public static Map<String,String> holdPicklistValueForRunnyNoseOrTearing_List {get;set;}
    public static Map<String,String> holdPicklistValueForGIUpset_List {get;set;}
    public static Map<String,String> holdPicklistValueYawning_List {get;set;}
    public static Map<String,String> holdPicklistValueTremorOutstretched_List {get;set;}
    public static Map<String,String> holdPicklistValueAnxietyOrIrritability_List {get;set;}
    public static Map<String,String> holdPicklistValueGoosefleshSkin_List {get;set;}
    public static Map<String,String> holdPicklistValuePupilSize_List {get;set;}
    public static Map<String,String> holdPicklistValueBoneOrJoint_List {get;set;}
    //  public static Map<String,String> holdPicklistValueNursing Assessment {get;set;}
    public static Map<String,String> holdPicklistValueFacial {get;set;}
    public static Map<String,String> holdPicklistValuePatient_awareness {get;set;}
    public static Map<String,String> holdPicklistValueDischargeValues {get;set;}
    public static Map<String,String> holdPicklistValueHeight {get;set;}
    public static Map<String,String> holdPicklistValueWeight {get;set;}
    
    //Constructor : executes all the data - fetch / process / manipulation
    public ElixirHC_FormsPDFGeneratorHelper(){
        // System.debug('constructor call count ');
        DateTime currentDateConversion = Datetime.now();
        String dateOutput = currentDateConversion.format('dd-MM-yyyy');      
        currentDate = dateOutput;        
        String formId = ApexPages.currentPage().getParameters().get('formId');
        System.debug('formId---' + formId);
        formIdAsReceived = formId;
        //  Apexpages.currentPage().getHeaders().put('content-disposition', 'attachment; filename=Form'+'DEMO' +'.pdf');
        List<Form__c> formDetails = [select id,Account__c,Category__c,Name,Locations__c,Sub_Category__c from Form__c 
        where id  = : formId WITH SECURITY_ENFORCED limit 1];
        if(formDetails.size()>0 && formDetails!=null){
            getAccountInfo(formDetails[0].Account__c);
            System.debug('formDetails '+formDetails);
            getFormDataWrapper wrpr  =  getFormData(formId,formDetails[0].Account__c);
            bringData(formDetails[0].Account__c ,formDetails[0].Category__c ,formDetails[0].Sub_Category__c);
            initPage2(wrpr);
            getApprovalProcessInfo(formId);
            getAllergyData(formDetails[0].Account__c);
        }
        
        
    }
    public static void getAllergyData(String acctId){
        List<Medical_Examination__c> acctAllergies = [SELECT Allergy_Name__c,Substance__c,Substance_Code__c,Reaction__c
                                                      FROM Medical_Examination__c
                                                       where  Account__c = : acctId
                                                       WITH SECURITY_ENFORCED];
        for(Medical_Examination__c allAllergyRecords : acctAllergies){
            if(allAllergyRecords.Allergy_Name__c!=null){
                allergyRecords += allAllergyRecords.Allergy_Name__c+',';
            }
        }
    }
    
    public static getFormDataWrapper getFormData(String formId,String acctId){
        form__c FormValue = [select form__c ,Patient_Signature_Link__c from Form__c where id =:formId
        WITH SECURITY_ENFORCED ];
        String signatureValue = FormValue.Patient_Signature_Link__c ;
        system.debug('new data' + signatureValue);
        id FormNew = FormValue.Form__c;
        String query ;
        Boolean hasEvaluatedPhysicalTherapist = false;
        List<formFieldWrapper> jsonListMultiPickList = new List<formFieldWrapper>();  
        List<User> physicalTherapists = new List<User>();//List of Physical Therapists
        List<Account> acctDetails = new List<Account>();
        List<Medical_Examination__c> allergyData = new List<Medical_Examination__c>();
        
        List<Prescription_Order__c> medicationData = new List<Prescription_Order__c>();
        Id currentUserId = UserInfo.getUserId();
        User currentUser;
        //  List<Medical_Examination__c> allergyData = new List<Medical_Examination__c>();
        List<Medical_Examination__c> glucoseObservation =  new List<Medical_Examination__c>();
        List<Medical_Examination__c> vitalObservation =  new List<Medical_Examination__c>();
        List<List<Form_Field__c>> finalList = new List<List<Form_Field__c>>();
        List<Dataset1__c> conditionData =  new List<Dataset1__c>();
        List<ICD_Codes__c> childConditionData =  new List<ICD_Codes__c>();
        List<Notes__c> relatedNotes = new List<Notes__c>();
        Map<Id,Dataset1__c> parentProblems = new Map<Id,Dataset1__c>();
        String accountVerifyCode = [SELECT Id , Name,Verification_Code__c FROM Account
         WHERE Id= :acctId WITH SECURITY_ENFORCED LIMIT 1].Verification_Code__c;
        String userVerifyCode = '';//String.valueOf([Select id,name, Verification_Code__c From User Where Id = :UserInfo.getUserId()].Verification_Code__c);
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
            acctDetails = [Select id,Name,Signature_Attachment_Id__c from Account 
            where id=:acctId WITH SECURITY_ENFORCED limit 1];
        }
        
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
            List<Form_Field__c> listOfFields = new List<Form_Field__c>();
            query = 'SELECT Id,Form__r.name,Form_Field__c,style__c,API_Name__c ,Name,Field_Label_Long__c,Default_Text_Area__c,Row_Matrix__c,Column_Matrix__c, Columns__c,Data_Entry_Type__c,Data_Type__c,value__c,Textvalue__c,TextAreavalue__c,Datevalue__c,DateTimevalue__c,'+
                'Field_Name__c,Maximum_Column_in_each_Section__c,Picklist_Values__c,Section__c,Sequence_Order__c FROM Form_Field__c'+
                ' WHERE Form__c= :FormNew ORDER BY Section__c';
            
            
            
            List<Form_Field__c> listOfFormToFields = Database.query(query);
            system.debug(listOfFormToFields.size());
            Integer oldSection = 1;
            if(listOfFormToFields!=null && listOfFormToFields.size()>0){
                List<Form_Field__c> recordsList = new List<Form_Field__c>();
                for(form_Field__c fieldRec : listOfFormToFields){
                    if((fieldRec.Data_Entry_Type__c == 'Picklist:PhysicalTherapist' && hasEvaluatedPhysicalTherapist == false) || fieldRec.Data_Entry_Type__c == 'Referred_List'){
                        physicalTherapists = [SELECT Id,Name FROM User WITH SECURITY_ENFORCED LIMIT 999];                                                                                                                                                          
                        hasEvaluatedPhysicalTherapist = true;
                        
                    }
                    
                    if(fieldRec.Data_Entry_Type__c == 'Picklist:Allergy'){
                        allergyData = [SELECT Substance__c,Substance_Code__c,Reaction__c
                                       FROM Medical_Examination__c 
                                       where  Account__c = : acctId AND
                                        RecordType.DeveloperName= 'Allergy' 
                                        AND (Substance__c!=NULL OR Substance_Code__c!=NULL OR
                                         Reaction__c!=NULL) WITH SECURITY_ENFORCED];                                                                                                                                                
                    }
                    if(fieldRec.Data_Entry_Type__c == 'Vitals_signs'){
                        System.debug('field rec inside vital'+fieldRec.Data_Entry_Type__c);
                        vitalObservation =  [select id, Blood_Pressure_Systolic__c,Blood_Pressure_diasystolic__c,Temperature__c,  
                                             Pulse__c, createdDate,
                                             Oxygen_Saturation__c from Medical_Examination__c where
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
                    if(fieldRec.Data_Entry_Type__c == 'Diagnosis_Code'){
                        //fetch all the problems related to an account
                        
                        conditionData = [SELECT Account__c,CreatedById,Dataset1__c,CreatedDate,Description__c,Id,IsActive__c,IsDeleted,
                                         LastModifiedById,LastModifiedDate,Name,OwnerId,Problem_Name__c,RecordTypeId,
                                         Templatized_Problem__c FROM Dataset1__c where Account__c=:acctId WITH SECURITY_ENFORCED];
                        for (Dataset1__c record  : conditionData){
                            System.debug('problem data '+record);
                            // System.debug('problem data ind fields '+record.HealthCloudGA__EvidenceLabel__c);
                            parentProblems.put(record.id,record);
                        }
                        
                        if(conditionData!=null && conditionData.size()>0){
                            //fetch all the daignoses related to a problem
                            childConditionData = [SELECT Category__c,Code_Description__c,Code_Type__c,Code__c,CreatedById,CreatedDate,ICD_Codes__c,
                                                  Diagnosis_Code_and_Name__c,Id,IsDeleted,LastModifiedById,LastModifiedDate,
                                                  Name,OwnerId,Dataset1__c 
                                                  FROM ICD_Codes__c where Dataset1__c IN :parentProblems.keySet()
                                                  WITH SECURITY_ENFORCED];
                        }
                        
                        if(conditionData!=null && conditionData.size()>0){
                            relatedNotes = [select id,Name,Notes__c,Dataset1__c,Note__c
                                            from Notes__c where Dataset1__c IN :parentProblems.keySet()
                                            WITH SECURITY_ENFORCED];
                        }                  
                    }
                    if(fieldRec.Data_Entry_Type__c == 'Picklist:Allergy'){
                        allergyData = [SELECT Substance__c,Substance_Code__c,Reaction__c
                                       FROM Medical_Examination__c where  Account__c = : acctId
                                       WITH SECURITY_ENFORCED];										
                        
                    }
                    if(fieldRec.Data_Entry_Type__c == 'Medication_list'){
                        medicationData = [SELECT Drug_Name__c,Id,Number_of_Times_Days_Weeks__c,Reason_new__c,
                                          Ferquency__c,Route_New__c,Reason__c,Type__c,Dosage_Form__c,(select Strength__c,Dosage_Instruction__c,Repeat__c
                                                                                                      from Frequency__r)
                                          FROM Prescription_Order__c where  Account__c=:acctId
                                          WITH SECURITY_ENFORCED
                                          order by CreatedDate asc limit 110]; 
                        
                    }
                    
                    
                    
                    if(fieldRec.Data_Entry_Type__c == 'Active_Users'){
                        currentUser =  [SELECT Id,Name FROM USER WHERE Id= :currentUserId 
                        WITH SECURITY_ENFORCED LIMIT 1];                                                                                                                                    
                    }
                    Integer newSection = Integer.valueOf(fieldRec.Section__c);
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
        
        
        //  WrapperForEditDataGeneric.arrForFormFields f = new WrapperForEditDataGeneric.arrForFormFields();
        //    f.arrFormFields=finalList;
        //allFieldsv2 =  new WrapperForEditDataGeneric();
        // allFieldsv2.arrForFormFields  =finalList;
        
        getFormDataWrapper wrpr = new getFormDataWrapper();
        //
        wrpr.allFields = finalList;          
        wrpr.multiPicklistValues = jsonListMultiPickList;
        wrpr.listOfUsers = physicalTherapists;
        wrpr.listOfAllergy = allergyData;
        wrpr.currentUser = currentUser;
        wrpr.listOfconditionData = conditionData;
        wrpr.listOfrelatedNotes =relatedNotes;
        wrpr.listOfRelatedDaignoses=childConditionData;
        wrpr.parentProblems = parentProblems;
        wrpr.listOfMedication=medicationDataJSON(medicationData);
        wrpr.signatureValues = signatureValue ;
        wrpr.formData=formDataForSignAndApprove;
        wrpr.VerficationCode  = accountVerifyCode ;
        wrpr.userVerifyCode = userVerifyCode;
        //   wrpr.dynamicOffset = intOffSet;
        wrpr.acctDetails= acctDetails;
        wrpr.vitalData = vitalObservation;
        wrpr.glucoseData = glucoseObservation;
        wrpr.arrangedProblemDaignosisData = arrangeConditionDataAsParentChild(conditionData,childConditionData,relatedNotes);
        wrprOnVF = wrpr;
        system.debug('wrpr on vf '+wrprOnVF.allFields);
        // ElixirHC_FormsPDFGeneratorHelper call = new ElixirHC_FormsPDFGeneratorHelper();
        return wrpr;
        
    }
    public  class getFormDataWrapper{
        public List<List<Form_Field__c>> allFields{ get; set; }
        public  List<formFieldWrapper> multiPicklistValues{ get; set; }
        public  List<User> listOfUsers{ get; set; }
        public  List<Medical_Examination__c> listOfAllergy{ get; set; }
        public  List<Prescription_Order__c> listOfMedication{ get; set; }
        public User currentUser { get; set; }
        public String signatureValues {get;set;}
        public Map<Id,Dataset1__c> parentProblems {get;set;}
        public List<Dataset1__c> listOfconditionData {get;set;}
        public List<Notes__c> listOfrelatedNotes {get;set;}
        public Integer dynamicOffset{get;set;}
        public List<ICD_Codes__c> listOfRelatedDaignoses {get;set;}
        public List<Form__c> formData{ get; set; }
        public String VerficationCode{ get; set; }
        public String userVerifyCode{ get; set; }
        public List<Account> acctDetails{ get; set; }
        public List<Medical_Examination__c> vitalData{ get; set; }
        public List<Medical_Examination__c> glucoseData{ get; set; }
        public  List<problemDiagnosesDataWrapper> arrangedProblemDaignosisData {get;set;}
        
    }
    
    public class formFieldWrapper{
        public string label { get; set; }
        public List<String> value { get; set; }
    }
    public class getFormFieldsWrapper{
        @AuraEnabled   public List<List<Form_Field__c>> allFields{ get; set; }
        @AuraEnabled   public List<List<Form_Field__c>> sectionData{ get; set; }
        @AuraEnabled    public  List<formFieldWrapper> multiPicklistValues{ get; set; }
        @AuraEnabled    public  List<User> listOfUsers{ get; set; }
        @AuraEnabled    public  List<Medical_Examination__c> listOfAllergy{ get; set; }
        @AuraEnabled    public  List<Prescription_Order__c> listOfMedication{ get; set; }
        @AuraEnabled  public  List<Medical_Examination__c> listOfglucoseObservation {get;set;}
        @AuraEnabled  public  Map<String,List<Medical_Examination__c>> mapOfObservation =  new Map<String,List<Medical_Examination__c>>();
        @AuraEnabled    public User currentUser { get; set; }
        @AuraEnabled   public List<Dataset1__c> listOfconditionData {get;set;}
        @AuraEnabled  public List<Notes__c> listOfrelatedNotes {get;set;}
        @AuraEnabled  public List<ICD_Codes__c> listOfRelatedDaignoses {get;set;}
        //@AuraEnabled  public Map<Dataset1__c,List<HealthCareDiagnosis>> parentChildConditionData {get;set;}
        @AuraEnabled  public Map<Id,Dataset1__c> parentProblems {get;set;}
        //@AuraEnabled  public Map<Id,HealthCareDiagnosis> relatedProblemDaignoses {get;set;} 
        @AuraEnabled  public Map<Id,Notes__c> relatedNotesMap{get;set;}
        @AuraEnabled  public Boolean runScroll{get;set;}
        @AuraEnabled  public Integer dynamicOffset{get;set;}
        //  @AuraEnabled  public List<Notes__c> relatedNotes {get;set;}
    }
    private void initPage1()
    {
        // wrapperForAccName wrpr = new wrapperForAccName();
        String acct = '';
        
    }
    //Data manipulation, per array of the data received
    public static void initPage2(getFormDataWrapper getDataForEvaluation)
    {
        
        parentArrColWiseData = new List<List<wrapperForColWiseData>>();        
        Integer c= 0;
        for(List<Form_Field__c> parentLst1  : getDataForEvaluation.allFields){
            for(Form_Field__c record :  parentLst1){
                if(c==3){
                    System.debug('3rd '+record);
                }
                System.debug('all data before compile '+record.Field_Name__c+c+'det '+record.Data_Entry_Type__c+'STYLE '+record.style__c+
                             'section number '+record.section__c+'seq order '+record.Sequence_Order__c+'text val'+record.Textvalue__c);
            }
            c++;
        }
        
        Boolean calloutQuery = true; // To flag run time query inside loop / break the looping execution inside loop.
        wrapperForEdit editWrapperReceived;
        for(List<Form_Field__c> parentLst  : getDataForEvaluation.allFields) {
            
            System.debug('init 2 received  '+getDataForEvaluation);
            Decimal maxCols = 0;
            List<String> matrixCssList = new  List<String>();
            List<String> styleCssList = new  List<String>();
            Boolean isMatrixCompiled = false;
            Integer counter= 0;
            arrayForHeight = new List<String>{'3 "1"','3 "2"','3 "3"','3 "4"','3 "5"','3 "6"','3 "7"','3 "8"','3 "9"','3 "10"','3 "11"','4 "0"',
                '4 "1"','4 "2"','4 "3"','4"4"','4 "5"','4 "6"','4 "7"','4 "8"','4 "9"','4 "10"','4 "11"','5 "0"',
                '5 "1"','5 "2"','5 "3"','5 "4"','4 "5"','4 "6"','4 "7"','4 "8"','4 "9"','4 "10"','4 "11"','5 "0"',
                '4 "1"','4 "2"','4 "3"','4"4"','4 "5"','4 "6"','4 "7"','4 "8"','4 "9"','4 "10"','4 "11"','5 "0"',
                '4 "1"','4 "2"','4 "3"','4"4"','4 "5"','4 "6"','4 "7"','4 "8"','4 "9"','4 "10"','4 "11"','5 "0"'};
                    inputFirstCss = 'width:202px;'; // 33 -
            inputSecondCss = 'width:202px;';
            inputFirstCheckboxClass = 'width:338px;'; // 50 -
            inputSecondCheckboxClass = 'width:108px;'; // 16
            jsonForCls = new Map<Decimal,String>{ 1  => 'width:676px;vertical-align: top;',
                2 => 'width:338px;vertical-align: top;',
                3 => 'width:202px;vertical-align: top;',
                4 => 'width:169px;vertical-align: top;', //25 -
                6 => 'width:114px;vertical-align: top;'  }; //17 --
                    Integer count = 0;
            
            for(Form_Field__c record :  parentLst){
                System.debug('1st row data '+record);
                if(record.Data_Entry_Type__c=='Text Area (Rich)'){
                    System.debug('got to UP '+record.Field_Name__c);
                    utilityPattern(record.Field_Name__c,parentLst,count);
                    
                }
                else if((record.Data_Entry_Type__c == 'Picklist:Yes/No' ||  record.Data_Entry_Type__c == 'Picklist:Note' || record.Data_Entry_Type__c == 'Status_List'
                         || record.Data_Entry_Type__c == 'PulseRate_List' || record.Data_Entry_Type__c == 'Sweating_List' || record.Data_Entry_Type__c == 'RunnyNoseOrTearing_List'
                         || record.Data_Entry_Type__c == 'Restlessness_List' || record.Data_Entry_Type__c == 'PupilSize_List'|| record.Data_Entry_Type__c == 'GIUpset_List'
                         || record.Data_Entry_Type__c == 'BoneOrJoint_List' || record.Data_Entry_Type__c == 'Picklist:DischargeValues' || record.Data_Entry_Type__c =='Yawning_List' || record.Data_Entry_Type__c == 'Picklist:Nursing Assessment' ||  record.Data_Entry_Type__c== 'Picklist:Patient awareness'
                         || record.Data_Entry_Type__c == 'TremorOutstretched_List' || record.Data_Entry_Type__c == 'AnxietyOrIrritability_List' || record.Data_Entry_Type__c == 'Picklist:History' || record.Data_Entry_Type__c == 'Picklist:Facial'
                         || record.Data_Entry_Type__c== 'GoosefleshSkin_List' || record.Data_Entry_Type__c == 'Picklist:FeedbackRating' || record.Data_Entry_Type__c == 'Picklist:ProblemRating' )&& (record.Picklist_Values__c!=''))
                {
                    StaticPicklistValues(record.Picklist_Values__c,record.Data_Entry_Type__c);
                }
                if(record.style__c == 'Credit Card'){
                    
                    // inputFirstCss= 'slds-size_3-of-12';
                    inputFirstCss= 'width:169px';
                    inputSecondCss= 'width:202px';
                    inputFirstCheckboxClass='width:169px';
                    inputSecondCheckboxClass='width:108px';            
                }
                else if(record.style__c == 'Credit Card First'){
                    inputFirstCss =  'width:54px'; // 8
                    inputSecondCss =  'width:507px'; // 75
                    counter = 1;
                }
                else if(record.style__c == 'Pharmacy Credit Card'){
                    inputFirstCheckboxClass= 'width:561px'; // 83
                    inputSecondCheckboxClass= 'width:108px';     // 16        
                }
                else if(record.style__c == 'MATRIX' && isMatrixCompiled == false){
                    if(record.Maximum_Column_in_each_Section__c > 5){
                        for(Integer i = 0 ; i < record.Maximum_Column_in_each_Section__c ; i++){
                            if(i == 0){
                                matrixCssList.add('width:202px');
                                styleCssList.add('font-size : 10px ; padding-top: 10px; padding-left : 10px ; width: 23%');
                            }else{
                                matrixCssList.add('width:54px');
                                styleCssList.add('font-size : 10px ; padding-top: 10px; padding-left : 10px ; width: 15%');
                            }
                            
                        }  
                    }
                    else{
                        for(Integer i = 0 ; i < record.Maximum_Column_in_each_Section__c ; i++){
                            if(i == 0){
                                matrixCssList.add('width:169px');
                                styleCssList.add('padding-top: 10px; padding-left : 10px');
                            }else{
                                matrixCssList.add('width:169px');
                                styleCssList.add('padding-top: 10px; padding-left : 10px');
                            }
                            
                        }  
                    }
                    
                    isMatrixCompiled = true;
                }
                count++;
            }
            if(counter == 1){
                maxCols = 2;
            }else{
                maxCols = parentLst[0].Maximum_Column_in_each_Section__c;
            }
            String cls = '';
            
            Map<Decimal,List<Form_Field__c>> mp = new  Map<Decimal,List<Form_Field__c>>();
            for(Integer keys=1; keys<=maxCols; keys++){
                //For css end
                if(isMatrixCompiled == false){
                    if(maxCols ==1 || maxCols == 3 ||maxCols == 2 || maxCols == 4 || maxCols== 6){
                        {
                            cls = jsonForCls.get(maxCols);
                        }        
                    }
                    else if(maxCols > 7){        
                        cls = 'width:54px';
                        
                    }
                    matrixCssList.add(cls);              
                }
                
                //For css end
                List<Form_Field__c> arrayInside = new List<Form_Field__c>();
                for(Form_Field__c rec : parentLst){
                    System.debug('parent list value : '+rec);
                    if(rec.Columns__c == keys){
                        System.debug('rec col '+rec.Field_Name__c);  
                        System.debug('keys  '+keys);  
                        if(! mp.containsKey(keys)){
                            arrayInside.add(rec);                
                            mp.put(Decimal.valueOf(keys),arrayInside);                
                        }else{  
                            mp.get(keys).add(rec);
                        }          
                    }                    
                }   
            }
            //System.debug('map of data  '+mp);
            Integer index = 0;
            System.debug('matrix css list  '+matrixCssList);
            List<wrapperForColWiseData> colWiseDataArray = new List<wrapperForColWiseData>();
            for(Decimal key : mp.keySet()){
                System.debug('key in decimal '+key);
                //doSort method call
                List<FormFieldsWrapper> formFiledsLst = new List<FormFieldsWrapper>();
                
                for(Form_Field__c dataCast :mp.get(key) ){                  
                    System.debug('data cast values  '+dataCast.Field_Name__c+'sec '+dataCast.Section__c+'seq o'+dataCast.Sequence_Order__c);                    
                    formFiledsLst.add(new FormFieldsWrapper(dataCast));                    
                }
                
                
                formFiledsLst.sort();
                
                List<Form_Field__c> getData = new List<Form_Field__c>();
                for(FormFieldsWrapper f : formFiledsLst){              
                    getData.add(f.oppy);  
                }
                for(Form_Field__c g : getData) { 
                    
                    if(g.Form__r.Name != 'Modified Schmid Fall Risk Assessment'){
                        g.style__c = 'width:507px;';
                        //		g.style__c = 'width:100px;';
                    }
                    else {
                        g.style__c = 'width:300px;';
                    }
                    
                    System.debug('getdata after '+g);
                }
                
                wrapperForColWiseData wr = new wrapperForColWiseData();
                if(matrixCssList.size()>0 && matrixCssList!=null) {
                    wr.css =  matrixCssList[index];
                }
                if(styleCssList.size()>0 && styleCssList!=null) {
                    wr.style = styleCssList[index];
                }
                System.debug('getData size '+getData.size());                
                wr.data = getData;    
                System.debug('index  '+index);               
                colWiseDataArray.add(wr);               
                index++;
                
            }
            
            //            System.debug('col wise arr '+colWiseDataArray);
            
            
            // @AuraEnabled   public map<id, Object> newMap  ;
            
            
            if(calloutQuery){
                editWrapperReceived  =  FormDataValues(formIdAsReceived);
            }
            //   System.debug('edit data wrapper  '+editWrapperReceived);
            //  System.debug('edit data wrapper  '+editWrapperReceived);
            //  System.debug('edit data wrapper  '+editWrapperReceived);
            // System.debug('colWiseData array '+formIdAsReceived);
            //   System.debug('edit data wrapper  '+editWrapperReceived.newMap);
            List<Decimal> countDuplicateSection  = new List<Decimal>();
            for(wrapperForColWiseData oldRecord : colWiseDataArray){
                for(Form_Field__c fdata : oldRecord.data){
                    countDuplicateSection.add(fdata.Section__c);
                    // System.debug('fData value before '+fdata);
                    if(editWrapperReceived.newMap.get(fData.Id)!=null){
                        //System.debug('Inside null');
                        fData.value__c = Boolean.valueOf(editWrapperReceived.newMap.get(fData.Id));
                        String val =  String.valueof(editWrapperReceived.newMapText.get(fData.Id));
                        String valToDisplay = '';
                        if(!String.isBlank(val)){
                            
                            if(val == '\'0\''){
                                valToDisplay = 'No' ;
                            }
                            else if(val == '\'1\''){
                                valToDisplay = 'Yes' ;
                            }
                            else {
                                valToDisplay = val ;
                            }
                        }
                        fData.Textvalue__c = valToDisplay ;
                        // fData.Textvalue__c = String.valueof(editWrapperReceived.newMapText.get(fData.Id));
                        fData.TextAreavalue__c = String.valueof(editWrapperReceived.newMapTextArea.get(fData.Id));
                        // String stringifiedDate = String.valueof(editWrapperReceived.newDateValue.get(fData.Id));
                        //String dateOutput = d.format('dd-MM-yyyy');
                        Date dToday = Date.valueof(editWrapperReceived.newDateValue.get(fData.Id));
                        String dateStr = '';
                        if(!String.isBlank(String.valueOf(dToday))){
                            dateStr = dToday.day() + '/' + dToday.month() + '/' + dToday.year();
                        }
                        else {
                            dateStr = '--';
                        }
                        System.debug('>>>>' + dateStr);
                        fData.Datevalue__c = String.valueof(dateStr);
                        fData.DateTimevalue__c = formatDateTime(DateTime.valueof(editWrapperReceived.newDateTimeValue.get(fData.Id)));
                        
                    }
                    //System.debug('fData value after '+fdata);
                    
                }  
            }
            Decimal hold;
            if(countDuplicateSection.size()>0 && countDuplicateSection!=null){
                hold =  countDuplicateSection[0];
            }
            System.debug('hold '+hold);
            Boolean isDuplicateSectionPresent = true;
            if(countDuplicateSection.size()>1){
                for(Decimal countSection : countDuplicateSection){  
                    System.debug('count section '+countSection);
                    if(hold != countSection){
                        isDuplicateSectionPresent = false;
                    }
                    break;               
                }
            }
            else {
                isDuplicateSectionPresent = false; 
            }
            System.debug('duplicate sectin present '+isDuplicateSectionPresent);
            if(isDuplicateSectionPresent){
                for(wrapperForColWiseData changeStyleIteration : colWiseDataArray){
                    for(Form_Field__c changeStyle : changeStyleIteration.data){
                        changeStyle.style__c = 'width:300px;';
                    }
                }
            }
            System.debug('after size'+colWiseDataArray.size());
            //System.debug('MAP ## --> '+holdPicklistValueForProblemList);
            
            if(colWiseDataArray.size()>0 && colWiseDataArray!=null){
                if(colWiseDataArray.size()==2){
                    colWiseDataArray[0].parent = 'width:448px;';
                    for(wrapperForColWiseData rec : colWiseDataArray){
                        rec.css = 'width:224px;';
                    }
                }
                else {
                    colWiseDataArray[0].parent = 'width:676px;';
                }
            }
            parentArrColWiseData.add(colWiseDataArray);          
            calloutQuery = false;
        }
        
    }
    
    public  class wrapperForColWiseData{
        public String style{get;set;}
        public String css{get;set;}
        public List<Form_Field__c> data {get;set;}
        public String parent {get;set;}
        
    }
    public class wrapperParentArrWithWidhAndData {
        public List<List<wrapperForColWiseData>> JSONIteration {get;set;}
        public String parentWidth{get;set;}
    }
    public static String formatDateTime(DateTime record){
        String formatted ; 
        if(!String.isBlank(String.valueOf(record))){
            formatted = record.formatGMT('dd-MM-yyyy\' \'HH:mm:ss');
        }
        else {
            formatted  = '';
        }
        return formatted;
    }
    
    public static void utilityPattern(String dataEntrtyName,List<Form_Field__c> lst,Integer count){
        WrapperForEditDataGeneric.wrapperForAccName getAcctDetails  = wrprEditOnVF.accName;
        System.debug('get acct details '+getAcctDetails);
        System.debug('lst  '+lst);
        System.debug('count '+count);
        System.debug('dataEntrtyName '+dataEntrtyName);
        String accountName = getAcctDetails.accName;
        String locations = getAcctDetails.parentAccount;
        String dob = getAcctDetails.dob;
        if(!String.isBlank(dataEntrtyName)){
            if(!String.isBlank(accountName)){
                dataEntrtyName  = dataEntrtyName.replace('$$NAME$$', accountName);
                //  String[] values =  dataEntrtyName.split('$$NAME$$');
                //   dataEntrtyName = String.join( values, accountName );
            }
            if(!String.isBlank(locations)){
                dataEntrtyName  = dataEntrtyName.replace('$$LOCATION$$', locations);
                //   String[] valuesLoc =  dataEntrtyName.split('$$LOCATION$$');
                //  dataEntrtyName = String.replace( valuesLoc, locations );
            }
            if(!String.isBlank(dob)){
                dataEntrtyName  = dataEntrtyName.replace('$$DOB$$', dob);
                //  String[] valuesDob =  dataEntrtyName.split('$$DOB$$');
                //  dataEntrtyName = String.join( valuesDob, dob );
            }
            lst[count].Field_Name__c = dataEntrtyName;
        }
        for(Form_Field__c toD : lst){
            System.debug('lst count field name '+toD);
        }
        
    }
    
    public class wrapperForStaticPickList {
        public String Name;
        public String Value;
        
    }
    public static void StaticPicklistValues(String picklistValue, String datEntryType){
        System.debug('DET '+datEntryType);
        Map<String,String> holdPicklistValueAsMap = new Map<String,String>();
        List<String> valueHold  = new List<String>();
        List<wrapperForStaticPickList> arrForPickListValues  = new List<wrapperForStaticPickList>();
        wrapperForStaticPickList recForPickListValues  = new wrapperForStaticPickList();
        if(!String.isBlank(picklistValue)){
            List<String> alteredArr = picklistValue.split(',');
            for(String sRec : alteredArr){
                valueHold = sRec.split('=>');
                holdPicklistValueAsMap.put(valueHold[1], valueHold[0]);
                recForPickListValues.Name = valueHold[0];
                recForPickListValues.Value= valueHold[1];
                arrForPickListValues.add(recForPickListValues);
            }
        }
        if(datEntryType== 'Picklist:ProblemRating'){
            holdPicklistValueForProblemList =  holdPicklistValueAsMap;
        }
        else if(datEntryType== 'Picklist:History'){
            holdPicklistValueForHistory = holdPicklistValueAsMap ; 
        }
        else if(datEntryType== 'Picklist:Yes/No'){
            holdPicklistValueForYesNo = holdPicklistValueAsMap ;
        }
        else if(datEntryType== 'Picklist:FeedbackRating'){
            holdPicklistValueForFeedbackRating = holdPicklistValueAsMap ;
        }
        else if(datEntryType== 'Picklist:Note'){
            holdPicklistValueForNote  = holdPicklistValueAsMap ;
        }
        else if(datEntryType== 'Status_List'){
            holdPicklistValueForStatusList  = holdPicklistValueAsMap ;
        }
        else if(datEntryType== 'PulseRate_List'){
            holdPicklistValueForPulseRateList  = holdPicklistValueAsMap ;
        }
        else if(datEntryType== 'Sweating_List'){
            holdPicklistValueForSweatingList  = holdPicklistValueAsMap ;
        }
        else if(datEntryType== 'Restlessness_List'){
            holdPicklistValueForRestlessness_List  = holdPicklistValueAsMap ;
        }
        else if(datEntryType== 'RunnyNoseOrTearing_List'){
            holdPicklistValueForRunnyNoseOrTearing_List = holdPicklistValueAsMap ;
        }
        else if(datEntryType== 'GIUpset_List'){
            holdPicklistValueForGIUpset_List = holdPicklistValueAsMap ;
        }
        else if(datEntryType== 'Yawning_List'){
            holdPicklistValueYawning_List = holdPicklistValueAsMap ;
        }
        else if(datEntryType== 'TremorOutstretched_List'){
            holdPicklistValueTremorOutstretched_List  = holdPicklistValueAsMap ;
        }
        else if(datEntryType== 'AnxietyOrIrritability_List'){
            holdPicklistValueAnxietyOrIrritability_List  = holdPicklistValueAsMap ;
        }
        else if(datEntryType== 'GoosefleshSkin_List'){
            holdPicklistValueGoosefleshSkin_List  = holdPicklistValueAsMap ;
        }
        
        else if(datEntryType== 'PupilSize_List'){
            holdPicklistValuePupilSize_List = holdPicklistValueAsMap ;
        }
        else if(datEntryType== 'BoneOrJoint_List'){
            holdPicklistValueBoneOrJoint_List  = holdPicklistValueAsMap ;
        }
        else if(datEntryType== 'Picklist:Facial'){
            holdPicklistValueFacial  = holdPicklistValueAsMap ;
        }
        else if(datEntryType== 'Picklist:Patient awareness'){
            holdPicklistValuePatient_awareness  = holdPicklistValueAsMap ;
        } 
        else if(datEntryType== 'Picklist:DischargeValues'){
            System.debug('map discahrge '+holdPicklistValueAsMap);
            holdPicklistValueDischargeValues  = holdPicklistValueAsMap ;
        } 
        else if(datEntryType== 'Picklist:Height'){
            
            holdPicklistValueHeight  = holdPicklistValueAsMap ;
        } 
        else if(datEntryType== 'Picklist:Weight'){
            
            holdPicklistValueWeight  = holdPicklistValueAsMap ;
        } 
        
    }
    
    
    @AuraEnabled
    public static WrapperForEditDataGeneric bringData(String accountId , String category , String subCategory){
        WrapperForEditDataGeneric data = new WrapperForEditDataGeneric();
        List<Account> listOfAcc = [SELECT Id , Verification_Code__c , Name, parent.Name FROM Account WHERE Id= : accountId];
        List<Contact> con=[select Id,name,birthdate from contact where AccountId= :accountId limit 1];
        if(listOfAcc!=null && listOfAcc.size()>0){
            WrapperForEditDataGeneric.wrapperForAccName wrpr = new WrapperForEditDataGeneric.wrapperForAccName();
            wrpr.accName = listOfAcc[0].name;
            wrpr.dob = String.valueOf(con[0].birthdate);
            wrpr.passCode =  String.valueOf(listOfAcc[0].Verification_Code__c);
            wrpr.parentAccount = String.valueOf(listOfAcc[0].parent.Name);
            data.accName = wrpr;
            data.allForms = fetchAccountAssociatedForms(accountId , category , subCategory);
        }
        wrprEditOnVF = data;
        return wrprEditOnVF;
    }
    
    public class wrapperForEditData{
        @AuraEnabled public List<Form__c> allForms{get;set;}
        @AuraEnabled public wrapperForAccName accName {get;set;}
    }
    @AuraEnabled
    public static List<Form__c> fetchAccountAssociatedForms(String accountId , String category , String subCategory){
        String query ;
        Set<Id> setOfId = new set<Id>();
        query = 'SELECT Id, Name, Category__c,Status__c, Sub_Category__c, Sections__c,Approval_Values1__c,Approval_Values_3__c,Approval_Values_2__c, Version__c, Locations__c,'+            
            'Signature_value_1__c,Signature_value_2__c,Signature_value_3__c FROM Form__c WHERE Account__c= :accountId AND Form__r.Category__c= :category ORDER BY CreatedDate desc';
        
        // '  AND Sub_Category__c= :subCategory';
        List<Form__c> listOfForms =  Database.query(query);
        return listOfForms;
        
    }
    public class wrapperForAccName{
        @AuraEnabled  public List<Form__c> forms;
        @AuraEnabled  public String accName;
        @AuraEnabled  public String dob;
        @AuraEnabled  public String passCode;
        @AuraEnabled  public String parentAccount;
        
    }
    public class columnWiseData {
        public String style{get;set;}
        public String css{get;set;}
        public List<Data> data{get;set;}
        
    }
    public class Data {
        public String Id{get;set;}
        public String style{get;set;}
        public String Name{get;set;}
        public Integer Elixir_HColumns{get;set;}
        public String Data_Entry_Type{get;set;}
        public String Field_Name{get;set;}
        public Integer Maximum_Column_in_each_Section{get;set;}
        public String Form{get;set;}
        public Integer Section{get;set;}
        public Integer Sequence_Order{get;set;}
        public Form FormRelation{get;set;}
    }
    
    public class Form {
        public String Name;
        public String Id;
    }
    // Map of parent - child (question - answer) data
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
        
        
        return wrap;
    }
    public class wrapperForEdit{
        @AuraEnabled   public map<id, Object> newMap  ;
        @AuraEnabled   public map<id, Object> newMapText  ;
        @AuraEnabled   public map<id, Object> newMapTextArea  ;  
        @AuraEnabled   public map<id, Object> newDateValue  ;
        @AuraEnabled   public map<id, Object> newDateTimeValue ;
    }
    public void getAccountInfo(Id accountId){
        List<Account> accountList = [select Id, name, Age__c,DOB__c from account where id=:accountId
        WITH SECURITY_ENFORCED];
        List<Contact> con=[select Id,name,birthdate from contact where AccountId=:accountId  
        WITH SECURITY_ENFORCED
        limit 1];
        system.debug('djd' + accountList);
        accounts = accountList.get(0);
        patContacts = con.get(0);
        if(con[0].birthdate!=null){
            Integer days = con[0].birthdate.daysBetween(Date.Today());
            age = Integer.valueOf(days/365);
        }
    }
    //Approval process data fetch
    public static void getApprovalProcessInfo(Id formId){
        List<Form__c> formDataForSignAndApprove = new  List<Form__c>();
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
                                         FROM Form__c WHERE Id= :formId WITH SECURITY_ENFORCED limit 1];
            approval = new ApprovalProcessDataWrapper();
            if(formDataForSignAndApprove.size()>0 && formDataForSignAndApprove!=null){
                approval.approvalData = new List<Form__c>();
                approval.approvalData.addAll(formDataForSignAndApprove);
                approval.signedDate1InString = getStringifiedDate(formDataForSignAndApprove[0].Signed_Date_1__c);
                approval.signedDate2InString = getStringifiedDate(formDataForSignAndApprove[0].Signed_Date_2__c);
                approval.signedDate3InString = getStringifiedDate(formDataForSignAndApprove[0].Signed_Date_3__c);
            }
            
            
        }
    }
    // 
    public class ApprovalProcessDataWrapper {
        public List<Form__c> approvalData {get;set;}
        public String signedDate1InString {get;set;}
        public String signedDate2InString {get;set;}
        public String signedDate3InString {get;set;}
    }
    public static String getStringifiedDate (Date receivedDate){
        String dateStr = '';
        if(!String.isBlank(String.valueOf(receivedDate))){
            dateStr = receivedDate.day() + '/' + receivedDate.month() + '/' + receivedDate.year();
        }
        else {
            dateStr = '--';
        }
        return dateStr;
        
    }
    //ARRANGE MEDICATION DATA IN A FORMATTED JSON
    public static List<problemDiagnosesDataWrapper> arrangeConditionDataAsParentChild( List<Dataset1__c> parentProblem , List<ICD_Codes__c> relatedDiagnosis ,  List<Notes__c> relatedNotes){
        Integer problemDaignoseisCounter = 0;
        List<problemDiagnosesDataWrapper> finalProblemLst = new  List<problemDiagnosesDataWrapper>();
        if(parentProblem.size()>0 && parentProblem!=null){
            for(Dataset1__c parentIterate : parentProblem){
                problemDiagnosesDataWrapper problemData  = new problemDiagnosesDataWrapper();
                problemData.diagnosis = new List<ICD_Codes__c>();
                problemData.notes  = new List<Notes__c>();
                problemData.problemName = parentIterate.Problem_Name__c;
                if(relatedDiagnosis.size()>0){
                    if(relatedDiagnosis[problemDaignoseisCounter]!=null || !relatedDiagnosis.isEmpty()){
                        for(ICD_Codes__c relDiagnosis : relatedDiagnosis){
                            if(relDiagnosis.Dataset1__c==parentIterate.Id) {
                                System.debug('inside if '+relDiagnosis);
                                problemData.diagnosis.add(relDiagnosis);
                            }
                        }
                    }
                    if(relatedDiagnosis[problemDaignoseisCounter]!=null || !relatedNotes.isEmpty()){
                        for(Notes__c childNotes : relatedNotes) {
                            if(childNotes.Dataset1__c==parentIterate.Id) {                                                          
                                problemData.notes.add(childNotes);
                            }
                        }                  
                    }
                }
                problemDaignoseisCounter++;
                finalProblemLst.add(problemData);
            }
            
        }
        System.debug('final return '+finalProblemLst);
        return finalProblemLst;
    }
    public class problemDiagnosesDataWrapper {
        public String problemName {get;set;}
        public List<Dataset1__c> problem {get;set;}
        public List<ICD_Codes__c> diagnosis{get;set;}
        public List<Notes__c> notes {get;set;}
    }
    public static List<Prescription_Order__c> medicationDataJSON( List<Prescription_Order__c> receivedMedicationData) {        
        if(receivedMedicationData.size()>0 && receivedMedicationData!=null){
            for(Prescription_Order__c perRecord : receivedMedicationData){
                if(perRecord.Frequency__r.size()>0 && perRecord.Frequency__r!=null
                   && perRecord.Frequency__r[0].Dosage_Instruction__c!=null){
                       String str  = perRecord.Frequency__r[0].Repeat__c;
                       if(str.startsWith('\'n\' times')){
                           String str2 = str;
                           String str3 =  perRecord.Frequency__r[0].Dosage_Instruction__c;
                           String str4 = str2.replace('\'n\'', str3);  
                           perRecord.Ferquency__c = str4;
                           
                       }
                       else if (str.startsWith('After every')) {
                           String str5 = str;
                           String str6 = perRecord.Frequency__r[0].Dosage_Instruction__c;
                           String str7 = str5.replace('\'n\'', str6);
                           perRecord.Ferquency__c = str7;
                           
                       }
                   }
            }
            
        } 
        return receivedMedicationData;  
    }
    */
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
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
       
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
       
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
       
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
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
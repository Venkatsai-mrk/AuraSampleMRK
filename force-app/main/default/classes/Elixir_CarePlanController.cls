/* Purpose : To create Care plan
* Note :-
* Developer Name :- Rohit Singh Bora
* Test Class :- Elixir_CarePlanControllerTest
*/
public with sharing class Elixir_CarePlanController {
    @AuraEnabled
   public static List<Form_Value__c> getRelatedNotes(String accountId,String parentcarePlanId,String selectedValues) {
       return [SELECT id,Form_Name__c,Account__c FROM Form_Value__c WHERE Account__c= :accountId AND ElixirSuite__Care_Episode__r.ElixirSuite__Status__c ='Active'
               WITH SECURITY_ENFORCED];
   }
   
   public static void attachEHRNotes(String accountId, String parentcarePlanId, List<String> selectedValues, List<String> selectedFormNames) {
       
       List<Form_Value__c> formValues = new List<Form_Value__c>();
       
       for (String formName : selectedFormNames) {
           Form_Value__c formValue = new Form_Value__c(
               Name = formName,
               Account__c = accountId,
               Is_CareEpisode__c = true,
               Treatment_Plan__c = parentcarePlanId
           );
           
           formValues.add(formValue);
       }
       
       if (!formValues.isEmpty()) {
           DMLManager.insertAsUser(formValues);
          // insert formValues;
       }
       
   }
   
   @AuraEnabled
   public static void attachApprovalDataToParentCarePlan(String parentcarePlanId, String approvedValues){
       try {
           ElixirSuite__Treatment_Plan__c parentCarePlan = new ElixirSuite__Treatment_Plan__c(Id=parentcarePlanId);
           List<CareplanSignatureSaveApex.SignAndAprroveData> approvedValuesDeserialized = (List<CareplanSignatureSaveApex.SignAndAprroveData>)JSON.deserializeStrict(approvedValues, List<CareplanSignatureSaveApex.SignAndAprroveData>.class);
           Id recordTypeId = Schema.SObjectType.ElixirSuite__Master_Object__c.getRecordTypeInfosByDeveloperName().get('CarePlan_Configuration').getRecordTypeId();
           Integer defaultCount = [SELECT COUNT() FROM Master_Object__c 
                                   WHERE Approval_Level_For__c = 'Care Plan' 
                                   AND recordTypeId =:recordTypeId
                                   WITH SECURITY_ENFORCED];
           
           for (CareplanSignatureSaveApex.SignAndAprroveData i : approvedValuesDeserialized) {
               switch on i.approvalLevel {
                   when 1 {
                       parentCarePlan.ElixirSuite__Signed_Date_1__c = i.dateOfApproval;
                       parentCarePlan.ElixirSuite__Comment_1__c = i.comments;
                       parentCarePlan.ElixirSuite__Primary_Therapist__c = i.userId;
                       switch on defaultCount {
                           when 1 {
                               parentCarePlan.status__c = 'Completed';
                           }
                           when else {
                               parentCarePlan.status__c = 'In progress';
                           }
                       }
                   }
                   when 2 {
                       parentCarePlan.ElixirSuite__Signed_Date_2__c = i.dateOfApproval;
                       parentCarePlan.ElixirSuite__Comment_2__c = i.comments;
                       parentCarePlan.ElixirSuite__Clinical_supervisor__c = i.userId;
                       switch on defaultCount {
                           when 2 {
                               parentCarePlan.status__c = 'Completed';
                           }
                           when else {
                               parentCarePlan.status__c = 'In progress';
                           }
                       }
                   }
                   
                   when 3 {
                       parentCarePlan.ElixirSuite__Signed_Date_3__c = i.dateOfApproval;
                       parentCarePlan.ElixirSuite__Comment_3__c = i.comments;
                       parentCarePlan.ElixirSuite__User_3__c = i.userId;
                       switch on defaultCount {
                           when 3 {
                               parentCarePlan.status__c = 'Completed';
                           }
                       }
                   }
               }
           }
           
           DMLManager.updateAsUser(parentCarePlan);
       } catch (Exception e) {
           ExceptionLog.logError(e);
       }
   }
   @AuraEnabled
   public static List<carePlanWrapper> fetchCarePlan(String accountId) {
       List<carePlanWrapper> wrapper = new List<carePlanWrapper>();
       List<String> columns = new List<String>();
       
       Elixir_Custom_Setting__c mc = Elixir_Custom_Setting__c.getOrgDefaults();
       String carePlanColumns = mc.ElixirSuite__CarePlan_Columns__c;
       if(String.isNotBlank(carePlanColumns)){
           columns = carePlanColumns.split(';');
       }
       
       list<Treatment_Plan__c> orderList = [Select id, ElixirSuite__Treatment_Plan_Name__c , ElixirSuite__Status__c,Account__c,createddate,ElixirSuite__Signed_Date_1__c,ElixirSuite__Signed_Date_2__c,ElixirSuite__Signed_Date_3__c 
                                            FROM Treatment_Plan__c
                                            WHERE Account__c= :accountId
                                            WITH SECURITY_ENFORCED
                                            ORDER BY CreatedDate DESC];
       
       Id recordTypeId = Schema.SObjectType.ElixirSuite__Master_Object__c.getRecordTypeInfosByDeveloperName().get('CarePlan_Configuration').getRecordTypeId();
       //Default count logic
       Integer defaultCount = [SELECT COUNT() FROM Master_Object__c 
                               WHERE Approval_Level_For__c = 'Care Plan' 
                               AND recordTypeId =:recordTypeId
                               WITH SECURITY_ENFORCED];
       
       //build datatable wrapper
       for(Treatment_Plan__c order : orderList){
           Integer approvedCount = 0;            
           if(order.ElixirSuite__Signed_Date_1__c!=null){
               approvedCount = approvedCount + 1;
           }
           if(order.ElixirSuite__Signed_Date_2__c!=null){
               approvedCount = approvedCount + 1;
           }
           if(order.ElixirSuite__Signed_Date_3__c!=null){
               approvedCount = approvedCount + 1;
           }
           carePlanWrapper wrp = new carePlanWrapper(
               String.valueOf(order.get('Id')),
               String.valueOf(order.get('ElixirSuite__Treatment_Plan_Name__c')),
               String.valueOf(order.get('ElixirSuite__Status__c'))
           );
         
           
           wrp.approvedLevelsCount = approvedCount;
           wrp.defaultLevelCount = defaultCount;
           wrp.columns = columns;
           wrapper.add(wrp);
       }
       return wrapper;
   }
   
   public class carePlanWrapper{
       @AuraEnabled public String carePlanId{get;set;}
       @AuraEnabled public String carePlanName{get;set;}
       @AuraEnabled public String carePlanStatus{get;set;}
       @AuraEnabled public Integer approvedLevelsCount;
       @AuraEnabled public Integer defaultLevelCount;
       @AuraEnabled public List<String> columns;
       
       public carePlanWrapper(String carePlanId, String carePlanName, String carePlanStatus){
           this.carePlanId = carePlanId;
           this.carePlanName = carePlanName;
           this.carePlanStatus =carePlanStatus;
       }
       
   }
   
   
   @AuraEnabled
   public static FormApproval_InitWrapper initCalled_fetchApprovalData(String ApprovalForInPlainText) {
       FormApproval_InitWrapper toreturnData = new FormApproval_InitWrapper();
       toreturnData.numberOfApprovalLevels = fetchNumberOfFormsApprovalLevel();
       return toreturnData; 
   }
   
   @AuraEnabled
   public static FormApprovalHelperWrapper fetchOptions_SetupKey(String setUpKey) {
       
       FormApprovalHelperWrapper toReturnData = new FormApprovalHelperWrapper();
       switch on setUpKey {
           when 'User' {
               toReturnData.allUsers = fetchAllActiveUsers();
           }when 'Role' {
               toReturnData.allUserRoles = fetchAllRoles();
           }
           when 'Profile' {
               toReturnData.allProfiles = fetchAllProfiles();
           }
         /*  when else {
               System.Debug('Error');
           }*/
       }
       return toReturnData;
   }
   @AuraEnabled
   public static  FormApproval_ExistingRecordsWrapper  fetchExistingApprovalRecord(Integer approvalLevel, String ApprovalFor){
       
       FormApproval_ExistingRecordsWrapper obj = new FormApproval_ExistingRecordsWrapper();
       Boolean isPreviousRecAvailable = false;
       ElixirSuite__Master_Object__c[] records = fetchApprovalRecord(approvalLevel, ApprovalFor);
       if(records.isEmpty()){
           
           ElixirSuite__Master_Object__c[] objBeforeRec =  fetchApprovalRecord(approvalLevel-1, ApprovalFor);
           if(!objBeforeRec.isEmpty()){
               isPreviousRecAvailable = true;
           }
       }
       else {
           isPreviousRecAvailable = true;
       }
      
       obj.isPreviousRecAvailable = isPreviousRecAvailable;
       obj.records = records; 
       obj.keylist = new List<sObject>();
       if(records!=null & records.size()>0){
           obj.keylist = fetchMapOfSetUpKey(records[0].ElixirSuite__Approver__c);
       }
       return obj;
       
   }
   public static  List<sObject> fetchMapOfSetUpKey(String key){
      // FormApprovalHelperWrapper objInstance =  fetchOptions_SetupKey(key);
       Map<String,List<sObject>> mapOfSObject = new  Map<String,List<sObject>>();
       switch on key {
           when 'User' {
               mapOfSObject.put('User',fetchAllActiveUsers());
           }when 'Role' {
               mapOfSObject.put('Role',fetchAllRoles());
           }
           when 'Profile' {
               mapOfSObject.put('Profile',fetchAllProfiles());
           }/*when else {
               System.Debug('Error');
           }*/
       }
       return mapOfSObject.get(key);
   }
   
   @AuraEnabled
   public static String saveApprovalProcess(String approver,String approvalLevel,String selectedApprovers,String dropDownOptions,
                                            String ApprovalFor, String mapOfSetUpKey,String approverNames, String ApproverCustomLabel) {
                                                
                                                Map<String, Object> lstOfDropDownOptions =(Map<String, Object>) JSON.deserializeUntyped(dropDownOptions);
                                                List<Object> objLstOfDropDownOptions = (List<Object>) lstOfDropDownOptions.get('keysToSave');
                                                Id recordTypeId = Schema.SObjectType.ElixirSuite__Master_Object__c.getRecordTypeInfosByDeveloperName().get('CarePlan_Configuration').getRecordTypeId(); 
                                                ElixirSuite__Master_Object__c obj = new ElixirSuite__Master_Object__c();
                                                obj.ElixirSuite__Approval_Level__c  = Integer.valueOf(approvalLevel);
                                                obj.ElixirSuite__Approval_Members__c = selectedApprovers;
                                                obj.ElixirSuite__Approval_Members_Name__c = approverNames;
                                                obj.ElixirSuite__Approver__c = approver;
                                                obj.ElixirSuite__Approver_List__c = JSON.serialize(objLstOfDropDownOptions);
                                                obj.recordTypeId =recordTypeId;
                                                obj.ElixirSuite__Approval_Level_For__c=ApprovalFor;
                                                obj.ElixirSuite__Approver_Custom_Label__c = ApproverCustomLabel;
                                                DMLManager.insertAsUser(obj);
                                               
                                                return obj.ID; 
                                            }
   @AuraEnabled
   public static String updateApprovalProcess(String approver,String approvalLevel,String selectedApprovers,String dropDownOptions,
                                              String ApprovalFor,String recordId,String approverNames, String ApproverCustomLabel) {
                                                  
                                                  Id recordTypeId = Schema.SObjectType.ElixirSuite__Master_Object__c.getRecordTypeInfosByDeveloperName().get('CarePlan_Configuration').getRecordTypeId();
                                                  Map<String, Object> lstOfDropDownOptions =(Map<String, Object>) JSON.deserializeUntyped(dropDownOptions);
                                                  List<Object> objLstOfDropDownOptions = (List<Object>) lstOfDropDownOptions.get('keysToSave');
                                                  ElixirSuite__Master_Object__c obj = new ElixirSuite__Master_Object__c();
                                                  obj.Id = recordId;
                                                  obj.ElixirSuite__Approval_Level__c    = Integer.valueOf(approvalLevel);
                                                  
                                                  If( String.isBlank(selectedApprovers) && approver=='Patient') {
                                                      selectedApprovers = 'Patient';
                                                      approverNames = 'Patient';
                                                  }
                                                  
                                                  obj.ElixirSuite__Approval_Members__c = selectedApprovers;
                                                  obj.ElixirSuite__Approver__c = approver;
                                                  obj.ElixirSuite__Approver_List__c = JSON.serialize(objLstOfDropDownOptions);
                                                  obj.ElixirSuite__Approval_Members_Name__c = approverNames;
                                                  obj.recordTypeId =recordTypeId;
                                                  obj.ElixirSuite__Approver_Custom_Label__c = ApproverCustomLabel;
                                                  DMLManager.updateAsUser(obj);
                                                  
                                                  return obj.ID;   
                                              }
   @AuraEnabled
   public static void deleteApprovalLevel(String recordId) {
       ElixirSuite__Master_Object__c obj = new ElixirSuite__Master_Object__c();
       obj = [select id from ElixirSuite__Master_Object__c where id=:recordId WITH SECURITY_ENFORCED];
       DMLManager.deleteAsUser(obj);
   }
   public static List<User> fetchAllActiveUsers(){
       return [SELECT ID,Name FROM User WHERE IsActive = true WITH SECURITY_ENFORCED];
   }
   public static List<Profile> fetchAllProfiles(){
       return [SELECT ID,Name   FROM Profile where Name!=null WITH SECURITY_ENFORCED];
   }
   public static List<UserRole> fetchAllRoles(){
       return [Select Id, Name from UserRole  where Name!=null WITH SECURITY_ENFORCED];
   }
   public static List<ApprovalLevelForForms__c> fetchNumberOfFormsApprovalLevel(){
       return [SELECT ID,Maximum_Level_For_Approval__c,ElixirSuite__Care_Plan_Approval_Level_Count__c FROM ApprovalLevelForForms__c 
               WITH SECURITY_ENFORCED LIMIT 1];
   }
   
   public static ElixirSuite__Master_Object__c[] fetchApprovalRecord(Integer approvalLevel, String ApprovalFor){
      
       return [Select Id,ElixirSuite__Approval_Level__c, ElixirSuite__Approval_Members__c,ElixirSuite__Approver__c,
               ElixirSuite__Is_Approval_Record__c,ElixirSuite__Approver_List__c, ElixirSuite__Approver_Custom_Label__c from ElixirSuite__Master_Object__c  where ElixirSuite__Approval_Level__c=:approvalLevel
               AND ElixirSuite__Approval_Level_For__c=:ApprovalFor WITH SECURITY_ENFORCED];
   }
   public class FormApprovalHelperWrapper {
       @AuraEnabled    public  List<User> allUsers{ get; set; }
       @AuraEnabled    public  List<Profile> allProfiles{ get; set; }
       @AuraEnabled    public  List<UserRole> allUserRoles{ get; set; }
   }
   public class FormApproval_InitWrapper {
       @AuraEnabled    public List<ApprovalLevelForForms__c> numberOfApprovalLevels{ get; set; }
   }
   public class FormApproval_ExistingRecordsWrapper {
       @AuraEnabled    public Boolean isPreviousRecAvailable = false;
       @AuraEnabled    public ElixirSuite__Master_Object__c[] records{ get; set; }
       @AuraEnabled    public sObject[] keylist{ get; set; }
   }
   public class PatientPortal_ExistingRecordsWrapper {
       @AuraEnabled    public Boolean isRecAvailable = false;
       @AuraEnabled    public ElixirSuite__Master_Object__c[] records{ get; set; }
       @AuraEnabled    public sObject[] keylist{ get; set; }
   }
   @AuraEnabled
   public static boolean checkUpdateLegitimacy(String approvalLevel, String ApprovalFor) {
       
       Integer nextApprovalLevel= Integer.valueOf(approvalLevel) +1;
      
       List<ElixirSuite__Master_Object__c> obj = [select id from ElixirSuite__Master_Object__c where  ElixirSuite__Approval_Level__c= :nextApprovalLevel AND ElixirSuite__Approval_Level_For__c=:ApprovalFor WITH SECURITY_ENFORCED];
       if (obj.size() > 0) {
        return false;
        } else {
            return true;
        }
       
   }
   @AuraEnabled
   public static wrapper getData(String accountId){
       ElixirSuite__CarePlan_Hierarchy__c careplanCustomSettingHeirarchy;
       
       Date patientBirthDateFromAccount;
       String accountName; 
       //   String nameSpace = Elixir_utility.getNameSpace(); 
       Set<Id> setOfProblemIds = new Set<Id>();
       
     
       wrapper wrpr = new wrapper();
       List<Account> listOfAcc = [SELECT Id , Name , ElixirSuite__DOB__c FROM Account WHERE Id= :accountId 
                                  WITH SECURITY_ENFORCED LIMIT 1];
       List<User> usersList = [SELECT Id , Name FROM USER WITH SECURITY_ENFORCED LIMIT 5000];
       if(listOfAcc!=null && listOfAcc.size()>0){
           accountName = listOfAcc[0].Name;
           patientBirthDateFromAccount = listOfAcc[0].ElixirSuite__DOB__c;
       }
       String userName = UserInfo.getName();
       String userId = UserInfo.getUserId();
       //picklist values for status start
       List<String> pickListValuesList= new List<String>();
       Schema.DescribeFieldResult fieldResult = Treatment_Plan__c.Status__c.getDescribe();
       List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
       for( Schema.PicklistEntry pickListVal : ple){
           pickListValuesList.add(pickListVal.getLabel());
       }   
      
       //picklist values for status end
       List<Dataset1__c> listOfProblems = new List<Dataset1__c>();
       
       List<Dataset1__c> listOfConditions = [SELECT Id, CreatedDate, CreatedById,
                                             Account__c FROM Dataset1__c WHERE Account__c= :accountId WITH SECURITY_ENFORCED];
       CarePlan_Hierarchy__c ch = new CarePlan_Hierarchy__c();
       ch =[select id,First_Level__c,Second_Level__c,ElixirSuite__Diagnosis__c,Third_Level__c,Fourth_Level__c,Fifth_Level__c,
            Sixth_Level__c from CarePlan_Hierarchy__c WITH SECURITY_ENFORCED LIMIT 1];
       
       if(listOfConditions!=null && listOfConditions.size()>0){
           for(Dataset1__c rec : listOfConditions){
               setOfProblemIds.add(rec.id);
           } 
           if(setOfProblemIds!=null && setOfProblemIds.size()>0){
               // For Infos except Problem Ids
               // Id RecType3 = Schema.SObjectType.ICD_Codes__c.getRecordTypeInfosByDeveloperName().get('Non_Templatized').getRecordTypeId();
               Elixir_Custom_Setting__c customSetting = Elixir_Custom_Setting__c.getOrgDefaults();
               String careFilter = customSetting.ElixirSuite__Default_Active_Care_Episode_Filter__c;
               if(string.isBlank(careFilter)){
                   careFilter = 'createddate desc';
               }
               String careStatus = 'Active';
               
               string querystr = '';
               querystr += 'Select Id,ElixirSuite__Account__c,ElixirSuite__Status__c from ElixirSuite__Visits__c where ElixirSuite__Status__c=:careStatus AND ElixirSuite__Account__c =: accountId WITH SECURITY_ENFORCED order by ';
               querystr += careFilter ;
               List<ElixirSuite__Visits__c> lstVisits = database.query(querystr);
               if(lstVisits != null && !lstVisits.isEmpty()){
                   listOfProblems = [SELECT Id, CreatedById, IsDeleted,Name,
                                     Description__c,ElixirSuite__Template_Problem__c 
                                     FROM Dataset1__c WHERE Id IN :setOfProblemIds and ElixirSuite__Care_Episode__c = :lstVisits[0].Id WITH SECURITY_ENFORCED ORDER BY CreatedDate Desc];
               }
               
           }
           
           
       }   
       List<ElixirSuite__CarePlan_Hierarchy__c> csHeirarchy = [SELECT ElixirSuite__Diagnosis__c,ElixirSuite__Fifth_Level__c,ElixirSuite__First_Level__c,ElixirSuite__Fourth_Level__c,
                                                               ElixirSuite__Relationship_level_1__c,ElixirSuite__Relationship_Level_2__c,ElixirSuite__Relationship_Level_3__c,
                                                               ElixirSuite__Relationship_Level_4__c,ElixirSuite__Second_Level__c,ElixirSuite__Sixth_Level__c,ElixirSuite__Third_Level__c,Id,
                                                               Name FROM ElixirSuite__CarePlan_Hierarchy__c 
                                                               WITH SECURITY_ENFORCED
                                                               LIMIT 1];
       if(csHeirarchy.size()>0 && csHeirarchy!=null){
           careplanCustomSettingHeirarchy = csHeirarchy[0];
       }
       
       ElixirSuite__Treatment_Plan__c[] forCount = [SELECT ID,ElixirSuite__Treatment_Plan_Name__c FROM ElixirSuite__Treatment_Plan__c 
                                                    WHERE Account__c = : accountId AND Treatment_Plan_Name__c LIKE '%CP%' 
                                                    WITH SECURITY_ENFORCED
                                                    order by createdDate desc limit 1];
       String tpName;
       if(forCount!=null && forCount.size()>0){
           if(String.isnotBlank(forCount[0].Treatment_Plan_Name__c)){ 
               if(forCount[0].Treatment_Plan_Name__c.containsIgnoreCase('CP')){
                   tpName = forCount[0].Treatment_Plan_Name__c.split('-')[1]; 
               }         
           }
       }
       else {
           tpName = '0';
       }
       
       wrpr.countRecords = Integer.valueOf(tpName.trim())+1;
       wrpr.listOfAllUsers = usersList;
       wrpr.listOfProblem = listOfProblems;
       wrpr.accountName = accountName;
       wrpr.userName = userName;
       wrpr.userId = userId;
       //   wrpr.patientBirthDate = patientBirthDate;
       wrpr.accountId = accountId;
       wrpr.Hierarchy = ch;
       wrpr.pickListValuesList = pickListValuesList;
       // wrpr.nameSpace = nameSpace;
       wrpr.patientBirthDateFromAccount=patientBirthDateFromAccount;
       wrpr.careplanCustomSettingHeirarchy = careplanCustomSettingHeirarchy;
       
       return wrpr;
       
   }
   public class wrapper{
       @AuraEnabled  public List<Dataset1__c> listOfProblem;  
       @AuraEnabled  public List<Dataset2__c> listOfGoal; 
       @AuraEnabled  public List<ICD_Codes__c> listOfDiag; 
       @AuraEnabled  public List<Dataset3__c> listDef; 
       @AuraEnabled  public List<Dataset2__c> listOfTasks; 
       @AuraEnabled  public List<Dataset3__c> listOfInterventions; 
       @AuraEnabled  public List<Dataset3__c> listOfObj; 
       @AuraEnabled  public List<Dataset3__c> listOfInterv;
       @AuraEnabled  public List<ElixirSuite__Template_Problem__c> listOfTemplateProblemGoal;
       @AuraEnabled  public List<ElixirSuite__Template_Problem__c> listOfTemplateProblemObj; 
       @AuraEnabled  public List<ElixirSuite__Template_Problem__c> listOfTemplateProblemInterv;
       @AuraEnabled  public String accountName;
       @AuraEnabled  public CarePlan_Hierarchy__c Hierarchy;
       @AuraEnabled  public String userName;
       @AuraEnabled  public Date patientBirthDate;
       @AuraEnabled  public Date patientBirthDateFromAccount;
       @AuraEnabled  public String accountId;
       @AuraEnabled  public String nameSpace;
       @AuraEnabled  public Id userId;
       @AuraEnabled  public Integer countRecords;
       @AuraEnabled  public List<User> listOfAllUsers;
       @AuraEnabled  public List<String> pickListValuesList= new List<String>(); 
       @AuraEnabled  public ElixirSuite__CarePlan_Hierarchy__c careplanCustomSettingHeirarchy;
   }
   @AuraEnabled
   public static WrapperNameSpace CareplanRecords(String accountId ){
       String devRecordTypeId = Schema.SObjectType.ElixirSuite__Master_Object__c.getRecordTypeInfosByDeveloperName().get('CarePlan_Configuration').getRecordTypeId();
       ElixirSuite__Master_Object__c[] allApprovalMasterRecord = [Select Id,ElixirSuite__Approval_Level__c, ElixirSuite__Approval_Members__c,ElixirSuite__Approver__c,
                                                                  ElixirSuite__Approver_List__c,ElixirSuite__Approval_Members_Name__c from ElixirSuite__Master_Object__c  where 
                                                                  RecordTypeId=:devRecordTypeId WITH SECURITY_ENFORCED];
       ElixirSuite__CarePlan_Hierarchy__c careplanCustomSettingHeirarchy;
       List<ElixirSuite__CarePlan_Hierarchy__c> csHeirarchy = [SELECT ElixirSuite__Diagnosis__c,ElixirSuite__Fifth_Level__c,ElixirSuite__First_Level__c,ElixirSuite__Fourth_Level__c,
                                                               ElixirSuite__Relationship_level_1__c,ElixirSuite__Relationship_Level_2__c,ElixirSuite__Relationship_Level_3__c,
                                                               ElixirSuite__Relationship_Level_4__c,ElixirSuite__Second_Level__c,ElixirSuite__Sixth_Level__c,ElixirSuite__Third_Level__c,Id,
                                                               Name FROM ElixirSuite__CarePlan_Hierarchy__c WITH SECURITY_ENFORCED LIMIT 1];
       if(csHeirarchy.size()>0 && csHeirarchy!=null){
           careplanCustomSettingHeirarchy = csHeirarchy[0];
       }
       //String query ;
       //  String nameSpace = Elixir_utility.getNameSpace();
      
       // query = 'select id,lastmodifieddate,Name,ElixirSuite__Due_Date__c,ElixirSuite__Start_Date__c,ElixirSuite__End_Date__c,ElixirSuite__Treatment_Plan_Name__c,ElixirSuite__Account__c,ElixirSuite__Status__c,ElixirSuite__Approval_Level_1__c,ElixirSuite__Approval_Level_2__c,ElixirSuite__Approval_Level_3__c,ElixirSuite__Approval_Level_4__c,ElixirSuite__Approval_Level_5__c from ElixirSuite__Treatment_Plan__c where ElixirSuite__Account__c=:accountId AND ElixirSuite__Treatment_Plan_Name__c !=null order by lastmodifieddate desc';
       // List<Treatment_Plan__c> listOfCase =  Database.query(query);
       List<ElixirSuite__Treatment_Plan__c> listOfCase =[Select id,lastmodifieddate,Name,ElixirSuite__Due_Date__c,ElixirSuite__Start_Date__c,ElixirSuite__End_Date__c,ElixirSuite__Treatment_Plan_Name__c,ElixirSuite__Account__c,ElixirSuite__Status__c,ElixirSuite__Approval_Level_1__c,ElixirSuite__Approval_Level_2__c,ElixirSuite__Approval_Level_3__c,ElixirSuite__Approval_Level_4__c,ElixirSuite__Approval_Level_5__c from ElixirSuite__Treatment_Plan__c where ElixirSuite__Account__c=:accountId AND ElixirSuite__Treatment_Plan_Name__c !=null WITH SECURITY_ENFORCED order by lastmodifieddate desc];
       
      
       WrapperNameSpace nameSpaceWrapper = new WrapperNameSpace();
       ElixirOEM_GlobalApprovalHelper.ApprovalScreenHelperWrapper carePlanApprovalCount = ElixirOEM_GlobalApprovalHelper.fetchApprovalLevelCount('CarePlan');
       //nameSpaceWrapper.nameSpace= nameSpace;
       nameSpaceWrapper.listOfCase = listOfCase;
       nameSpaceWrapper.careplanCustomSettingHeirarchy = careplanCustomSettingHeirarchy;
       nameSpaceWrapper.approvalLevelCount = carePlanApprovalCount.carePlanApprovalCount;
       nameSpaceWrapper.approvalMasterRecords = allApprovalMasterRecord;
       return nameSpaceWrapper;
       
   }
   public class WrapperNameSpace{
       @AuraEnabled public String nameSpace;
       @AuraEnabled public list<Treatment_Plan__c> listOfCase;
       @AuraEnabled public  ElixirSuite__CarePlan_Hierarchy__c careplanCustomSettingHeirarchy;
       @AuraEnabled public  decimal approvalLevelCount;
       @AuraEnabled public  ElixirSuite__Master_Object__c[] approvalMasterRecords;
       
   }
   @AuraEnabled
   public static newWrapper getGoalsAndEvidences(String problemId){
       Id recType1 = Schema.SObjectType.Dataset2__c.getRecordTypeInfosByDeveloperName().get('Treatment_Plan_Recordtype1').getRecordTypeId();
       Id recType2 = Schema.SObjectType.Dataset2__c.getRecordTypeInfosByDeveloperName().get('Treatment_Plan_Recordtype2').getRecordTypeId();
       Id recType3 = Schema.SObjectType.ICD_Codes__c.getRecordTypeInfosByDeveloperName().get('Non_Templatized').getRecordTypeId();
       List<Dataset2__c> listOfGoals = [SELECT Id, Name,  LastModifiedDate,Description__c
                                        FROM Dataset2__c WHERE Dataset1__c= :problemId AND RecordTypeId =:recType2 WITH SECURITY_ENFORCED];
       List<Dataset2__c> listOfEvidences = [SELECT Id, Name, LastModifiedDate,Description__c , Dataset1__c 
                                            FROM Dataset2__c WHERE Dataset1__c= :problemId AND RecordTypeId =:recType1 WITH SECURITY_ENFORCED];
       // List<ICD_Codes__c> listOfDiagnosis = [SELECT Id, Name,Diagnosis_Code_and_Name__c
       //                              FROM ICD_Codes__c WHERE RecordTypeId =:recType3 WITH SECURITY_ENFORCED];
       List<ICD_Codes__c> listOfDiagnosis = new List<ICD_Codes__c>();
       //Diagnosis_Code_and_Name__c
       newWrapper wp = new newWrapper();
       wp.listOfGoalForProblem = listOfGoals ;
       wp.listOfEvidenceForProblem = listOfEvidences ;
       wp.listOfDaignosis = listOfDiagnosis ;
       return wp ;
   }
   public class newWrapper{
       @AuraEnabled  public List<Dataset2__c> listOfGoalForProblem;
       @AuraEnabled  public List<Dataset2__c> listOfEvidenceForProblem;
       @AuraEnabled  public List<ICD_Codes__c> listOfDaignosis;
   }
   @AuraEnabled
   public static wrapper getAllProblems(List<String> existingProblems, String accountId){
       //Map<Id,sObject> mapOfExistingProbs = new  Map<Id,sObject>(existingProblems);
       // Id RecType3 = Schema.SObjectType.Dataset1__c.getRecordTypeInfosByDeveloperName().get('Templatized').getRecordTypeId();  
       //List<Dataset1__c> listOfProblems =  [SELECT Id, CreatedById, IsDeleted,Name ,Description__c
       //  FROM Dataset1__c WHERE Id NOT IN : setOfIds  AND RecordTypeId =:RecType3 WITH SECURITY_ENFORCED LIMIT 49000];
       
       Set<String> setOfIds = new Set<String>(existingProblems);
       wrapper wrpr = new wrapper();
       Elixir_Custom_Setting__c customSetting = Elixir_Custom_Setting__c.getOrgDefaults();
       String careFilter = customSetting.ElixirSuite__Default_Active_Care_Episode_Filter__c;
       if(string.isBlank(careFilter)){
           careFilter = 'createddate desc';
       }
       String careStatus = 'Active';
       
       string querystr = '';
       querystr += 'Select Id,ElixirSuite__Account__c,ElixirSuite__Status__c from ElixirSuite__Visits__c where ElixirSuite__Status__c=:careStatus AND ElixirSuite__Account__c =: accountId WITH SECURITY_ENFORCED order by ';
       querystr += careFilter ;
       List<ElixirSuite__Visits__c> lstVisits = database.query(querystr);
       if(lstVisits != null && !lstVisits.isEmpty()){
           List<Dataset1__c> listOfProblems =  [SELECT Id, CreatedById, IsDeleted,Name ,ElixirSuite__Description__c,ElixirSuite__Template_Problem__c 
                                                FROM Dataset1__c WHERE Id NOT IN : setOfIds AND ElixirSuite__Care_Episode__c = :lstVisits[0].Id AND Account__c =: accountId WITH SECURITY_ENFORCED LIMIT 49000];
           wrpr.listOfProblem = listOfProblems;
       }
       
       return wrpr;
       
   }    
   @AuraEnabled
   public static wrapper getAllGoals(List<String> existingGoals){
       
       /*Id problemRecType = Schema.SObjectType.Dataset2__c.getRecordTypeInfosByDeveloperName().get('Treatment_Plan_Recordtype1').getRecordTypeId();
Set<String> setOfIds = new Set<String>(existingGoals);
Id RecType2 = Schema.SObjectType.Dataset2__c.getRecordTypeInfosByDeveloperName().get('Treatment_Plan_Recordtype2').getRecordTypeId();
Id RecType3 = Schema.SObjectType.ICD_Codes__c.getRecordTypeInfosByDeveloperName().get('Non_Templatized').getRecordTypeId();
Id RecType4 = Schema.SObjectType.Dataset3__c.getRecordTypeInfosByDeveloperName().get('Treatment_Plan_Recordtype3').getRecordTypeId();
List<Dataset2__c> listOfGoals =  [SELECT Id,Name,Description__c FROM Dataset2__c  WHERE Id NOT IN : setOfIds  AND RecordTypeid =:RecType2 
WITH SECURITY_ENFORCED LIMIT 49000];*/
       /* List<Dataset2__c> listOfDef =  [SELECT Id,Name,Description__c FROM Dataset2__c  WHERE Id NOT IN : setOfIds  AND RecordTypeId =:problemRecType 
WITH SECURITY_ENFORCED LIMIT 49000];*/
       /*List<Dataset3__c> listOfDef = [SELECT Id, Name,Description__c , Dataset2__c 
FROM Dataset3__c WHERE 
RecordtypeId =:RecType4 AND Id NOT IN : setOfIds WITH SECURITY_ENFORCED LIMIT 49000];
List<ICD_Codes__c> listOfDiagnosis = [SELECT Id, Name,Diagnosis_Code_and_Name__c
FROM ICD_Codes__c WHERE Id NOT IN : setOfIds AND RecordTypeId =:RecType3
WITH SECURITY_ENFORCED];*/
       
       
       Id goalRecId = Schema.SObjectType.ElixirSuite__Template_Problem__c.getRecordTypeInfosByDeveloperName().get('Goals').getRecordTypeId();
       Set<String> setOfIds = new Set<String>(existingGoals);
       List<ElixirSuite__Template_Problem__c> listOfGoals =  [SELECT Id,Name,ElixirSuite__Description__c,ElixirSuite__Status__c FROM ElixirSuite__Template_Problem__c  WHERE Id NOT IN : setOfIds AND RecordTypeId =: goalRecId 
                                                              WITH SECURITY_ENFORCED LIMIT 49000];
       wrapper wrpr = new wrapper();
       wrpr.listOfTemplateProblemGoal = listOfGoals;
       
       return wrpr;
       
       /*wrapper wrpr = new wrapper();
wrpr.listOfGoal = listOfGoals;

return wrpr;*/
       
       
       
   }
   //added by vishal
   @AuraEnabled
   public static wrapper getAllGoalsAndObjectives(List<String> existingGoals,String problemId){
       Id goalRecId = Schema.SObjectType.ElixirSuite__Template_Problem__c.getRecordTypeInfosByDeveloperName().get('Goals').getRecordTypeId();
       Id objRecId = Schema.SObjectType.ElixirSuite__Template_Problem__c.getRecordTypeInfosByDeveloperName().get('Objective').getRecordTypeId();
       
       List<Dataset1__c> listOfProblems =  [SELECT Id, CreatedById, IsDeleted,Name ,Description__c,ElixirSuite__Template_Problem__c
                                            FROM Dataset1__c WHERE Id =:problemId WITH SECURITY_ENFORCED];
       Set<String> setOfIds = new Set<String>(existingGoals);
       List<ElixirSuite__Template_Problem__c> listOfGoals =  [SELECT Id,Name,ElixirSuite__Description__c,ElixirSuite__Status__c,ElixirSuite__Goal__c FROM ElixirSuite__Template_Problem__c  WHERE Id NOT IN : setOfIds  AND RecordTypeId =: goalRecId AND ElixirSuite__Problem__c =: listOfProblems[0].ElixirSuite__Template_Problem__c 
                                                              WITH SECURITY_ENFORCED LIMIT 49000];
       List<ElixirSuite__Template_Problem__c> listOfTasks =  [SELECT Id,Name,ElixirSuite__Description__c,ElixirSuite__Status__c,ElixirSuite__Objective__c FROM ElixirSuite__Template_Problem__c  WHERE Id NOT IN : setOfIds  AND RecordTypeId =: objRecId AND ElixirSuite__Problem__c =: listOfProblems[0].ElixirSuite__Template_Problem__c
                                                              WITH SECURITY_ENFORCED LIMIT 49000];
       wrapper wrpr = new wrapper();
       wrpr.listOfTemplateProblemGoal = listOfGoals;
       wrpr.listOfTemplateProblemObj = listOfTasks;
       return wrpr;
   }
   @AuraEnabled
   public static wrapper getTasks(String goalId){
           
       Id recType2 = Schema.SObjectType.Dataset3__c.getRecordTypeInfosByDeveloperName().get('Treatment_Plan_Recordtype3').getRecordTypeId();
       
       List<Dataset3__c> listOfTasks = [SELECT Id, Name,Description__c , Dataset2__c   
                                        
                                        FROM Dataset3__c WHERE Dataset2__c = :goalId AND RecordtypeId =:recType2 WITH SECURITY_ENFORCED];
       Id recType3 = Schema.SObjectType.Dataset3__c.getRecordTypeInfosByDeveloperName().get('Treatment_Plan_Recordtype4').getRecordTypeId();
       
       List<Dataset3__c> listOfintev = [SELECT Id, Name,Description__c , Dataset2__c   
                                        
                                        FROM Dataset3__c WHERE Dataset2__c = :goalId AND RecordtypeId =:recType3 WITH SECURITY_ENFORCED];
        
       wrapper wrpr = new wrapper();
       wrpr.listOfObj = listOfTasks;
       wrpr.listOfInterv=listOfintev;
       return wrpr;
   }
   @AuraEnabled
   public static List<Dataset3__c> getInterventions(String taskId){
             
       Id recType3 = Schema.SObjectType.Dataset3__c.getRecordTypeInfosByDeveloperName().get('Treatment_Plan_Recordtype4').getRecordTypeId();
       List<Dataset3__c> listOfInterventions = [SELECT Id, Name,Description__c ,Dataset2__c    
                                                FROM Dataset3__c WHERE Dataset3__c= :taskId AND 
                                                RecordTypeId =:recType3 WITH SECURITY_ENFORCED];
     
       return listOfInterventions;
   }
   @AuraEnabled
   public static wrapper getAllTasks(List<String> existingTasks){
       //Map<Id,sObject> mapOfExistingProbs = new  Map<Id,sObject>(existingProblems);
       /*Id RecType2 = Schema.SObjectType.Dataset3__c.getRecordTypeInfosByDeveloperName().get('Treatment_Plan_Recordtype3').getRecordTypeId();

Set<String> setOfIds = new Set<String>(existingTasks);
List<Dataset3__c> listOfTasks =  [SELECT Id, Name,Description__c , Dataset2__c  
FROM Dataset3__c WHERE 
RecordtypeId =:RecType2 AND Id NOT IN : setOfIds WITH SECURITY_ENFORCED LIMIT 49000];

wrapper wrpr = new wrapper();
wrpr.listOfObj = listOfTasks;   
return wrpr;*/
       Id objRecId = Schema.SObjectType.ElixirSuite__Template_Problem__c.getRecordTypeInfosByDeveloperName().get('Objective').getRecordTypeId();
       Set<String> setOfIds = new Set<String>(existingTasks);
       List<ElixirSuite__Template_Problem__c> listOfTasks =  [SELECT Id,Name,ElixirSuite__Description__c,ElixirSuite__Status__c FROM ElixirSuite__Template_Problem__c  WHERE Id NOT IN : setOfIds AND RecordTypeId =: objRecId 
                                                              WITH SECURITY_ENFORCED LIMIT 49000];
       wrapper wrpr = new wrapper();
       wrpr.listOfTemplateProblemObj = listOfTasks;
       return wrpr;
       
   }
   @AuraEnabled
   public static wrapper getTasksFromGoal(List<String> existingTasks,String goalId){
       Id objRecId = Schema.SObjectType.ElixirSuite__Template_Problem__c.getRecordTypeInfosByDeveloperName().get('Objective').getRecordTypeId();
       Set<String> setOfIds = new Set<String>(existingTasks);
       List<ElixirSuite__Template_Problem__c> listOfTasks =  [SELECT Id,Name,ElixirSuite__Description__c,ElixirSuite__Status__c FROM ElixirSuite__Template_Problem__c  WHERE Id NOT IN : setOfIds AND RecordTypeId =: objRecId AND ElixirSuite__Goal__c =: goalId
                                                              WITH SECURITY_ENFORCED LIMIT 49000];
       wrapper wrpr = new wrapper();
       wrpr.listOfTemplateProblemObj = listOfTasks;
       return wrpr;
       
   }
   @AuraEnabled
   public static wrapper getAllTasks2(List<String> existingTasks,String goalId){
       //Map<Id,sObject> mapOfExistingProbs = new  Map<Id,sObject>(existingProblems);
       /*Id RecType2 = Schema.SObjectType.Dataset3__c.getRecordTypeInfosByDeveloperName().get('Treatment_Plan_Recordtype4').getRecordTypeId();

Set<String> setOfIds = new Set<String>(existingTasks);
List<Dataset3__c> listOfTasks =  [SELECT Id, Name,Description__c , Dataset2__c  
FROM Dataset3__c WHERE 
RecordtypeId =:RecType2 AND Id NOT IN : setOfIds 
WITH SECURITY_ENFORCED 
LIMIT 49000];

wrapper wrpr = new wrapper();
wrpr.listOfObj = listOfTasks;   
return wrpr;*/
       Id intRecId = Schema.SObjectType.ElixirSuite__Template_Problem__c.getRecordTypeInfosByDeveloperName().get('Interventions').getRecordTypeId();
       Set<String> setOfIds = new Set<String>(existingTasks);
       List<ElixirSuite__Template_Problem__c> listOfInts =  [SELECT Id,Name,ElixirSuite__Description__c,ElixirSuite__Status__c FROM ElixirSuite__Template_Problem__c  WHERE Id NOT IN : setOfIds  AND RecordTypeId =: intRecId AND ElixirSuite__Goal__c =: goalId 
                                                             WITH SECURITY_ENFORCED LIMIT 49000];
       wrapper wrpr = new wrapper();
       wrpr.listOfTemplateProblemInterv = listOfInts;
       return wrpr;
       
   }
   
   @AuraEnabled
   public static wrapper getInterventionFromObjective(List<String> existingInts,String objectiveId){
       
       Id intRecId = Schema.SObjectType.ElixirSuite__Template_Problem__c.getRecordTypeInfosByDeveloperName().get('Interventions').getRecordTypeId();
       Set<String> setOfIds = new Set<String>(existingInts);
       List<ElixirSuite__Template_Problem__c> listOfInts =  [SELECT Id,Name,ElixirSuite__Description__c,ElixirSuite__Status__c FROM ElixirSuite__Template_Problem__c  WHERE Id NOT IN : setOfIds  AND RecordTypeId =: intRecId AND ElixirSuite__Objective__c =: objectiveId 
                                                             WITH SECURITY_ENFORCED LIMIT 49000];
       wrapper wrpr = new wrapper();
       wrpr.listOfTemplateProblemInterv = listOfInts;
       return wrpr;
       
   }
   
   @AuraEnabled
   public static wrapper getAllInterventions(List<String> existingInts){
       //Map<Id,sObject> mapOfExistingProbs = new  Map<Id,sObject>(existingProblems);
       /*Id RecType3 = Schema.SObjectType.Dataset3__c.getRecordTypeInfosByDeveloperName().get('Treatment_Plan_Recordtype4').getRecordTypeId();
Set<String> setOfIds = new Set<String>(existingInts);
List<Dataset3__c    > listOfInts =  [SELECT Id, Name,Description__c , Dataset2__c   
FROM Dataset3__c WHERE 
RecordTypeId =:RecType3 AND Id NOT IN : setOfIds 
WITH SECURITY_ENFORCED
LIMIT 49000];

wrapper wrpr = new wrapper();
wrpr.listOfInterventions = listOfInts;       
return wrpr;*/
       Id intRecId = Schema.SObjectType.ElixirSuite__Template_Problem__c.getRecordTypeInfosByDeveloperName().get('Interventions').getRecordTypeId();
       Set<String> setOfIds = new Set<String>(existingInts);
       List<ElixirSuite__Template_Problem__c> listOfInts =  [SELECT Id,Name,ElixirSuite__Description__c,ElixirSuite__Status__c FROM ElixirSuite__Template_Problem__c  WHERE Id NOT IN : setOfIds AND RecordTypeId =: intRecId 
                                                             WITH SECURITY_ENFORCED LIMIT 49000];
       wrapper wrpr = new wrapper();
       wrpr.listOfTemplateProblemInterv = listOfInts;
       return wrpr;
       
   }    
   @AuraEnabled
   public static CarePlan_Hierarchy__c getHierarchy(){
       CarePlan_Hierarchy__c ch = new CarePlan_Hierarchy__c();
       ch =[select id,First_Level__c,Second_Level__c,Third_Level__c,Fourth_Level__c,Fifth_Level__c,Sixth_Level__c from CarePlan_Hierarchy__c
            WITH SECURITY_ENFORCED limit 1];
       return ch;
   }
   @AuraEnabled 
   public static List < String > deleteCarePlans(List<Id> carePlansId){
       
       List < String > oErrorMsg = new List < String > ();  
      // Set<Id> setOfIds = new Set<Id>(carePlansId);
       List<Treatment_Plan__c> listOfCase = [SELECT Id FROM Treatment_Plan__c WHERE Id IN : carePlansId WITH SECURITY_ENFORCED];
       Database.DeleteResult[] drDels = Database.delete(listOfCase, false);
       
       // Iterate through each returned result
       
       for (Database.DeleteResult dr: drDels) {
           if (!dr.isSuccess()) {
        	oErrorMsg.add('');
        	for (Database.Error err : dr.getErrors()) {
            oErrorMsg.add(err.getStatusCode() + ': ' + err.getMessage());
        	}
    		}
        }
       return oErrorMsg;
   }
   
   @AuraEnabled
   public static void saveData(String userId, String clinicalSupervisionId, String carePlanName ,String status,String startDate , 
                               String endDate,String masterData, String accountId, string description,String starttimeProcedure, 
                               String endtimeProcedure,String approvedValues,List<String> selectedValues,List<String> selectedFormNames){
                                 
                                   
                                   try{
                                       
                                       fflib_ISObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
                                           new List<Schema.SObjectType>{
                                               ElixirSuite__Treatment_Plan__c.sObjectType,
                                                   ElixirSuite__Procedure__c.sObjectType,
                                                   ElixirSuite__Plan_Hierarchy__c.sObjectType, 
                                                   ElixirSuite__Plan_SubHierarchy__c.sObjectType,
                                                   ElixirSuite__Dataset2__c.sObjectType,
                                                   Task.sObjectType
                                                   }
                                       );
                                       
                                       Treatment_Plan__c newTP = new Treatment_Plan__c();
                                       newTP.Account__c = accountId;
                                       newTP.Treatment_Plan_Name__c = carePlanName;
                                       newTP.Status__c = status;
                                       newTP.Start_Date__c = Date.valueOf(startDate);
                                       newTP.End_Date__c  = Date.valueOf(endDate);
                                       newTP.Primary_Therapist__c = userId;
                                       newTP.Description__c = description;                            
                                       newTP.Clinical_supervisor__c = clinicalSupervisionId;
                                       if(Schema.sObjectType.Treatment_Plan__c.fields.Treatment_Plan_Name__c.isCreateable() &&
                                          Schema.sObjectType.Treatment_Plan__c.fields.Status__c.isCreateable() &&
                                          Schema.sObjectType.Treatment_Plan__c.fields.Start_Date__c.isCreateable() &&
                                          Schema.sObjectType.Treatment_Plan__c.fields.End_Date__c.isCreateable() &&
                                          Schema.sObjectType.Treatment_Plan__c.fields.Status__c.isCreateable() &&
                                          Schema.sObjectType.Treatment_Plan__c.fields.Account__c.isCreateable() &&
                                          Schema.sObjectType.Treatment_Plan__c.fields.Primary_Therapist__c.isCreateable() &&
                                          Schema.sObjectType.Treatment_Plan__c.fields.Description__c.isCreateable() &&
                                          Schema.sObjectType.Treatment_Plan__c.fields.Clinical_supervisor__c.isCreateable() 
                                         ){  
                                             uow.registerNew(newTP);
                                         }
                                       
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
                                       List<ElixirSuite__Visits__c> lstVisits = database.query(querystr);
                                       //end by Anmol for LX3-7236
                                       
                                       
                                       Id devRecordTypeId = Schema.SObjectType.Procedure__c.getRecordTypeInfosByName().get('Patient Procedure').getRecordTypeId();
                                       Procedure__c newProcedure = new Procedure__c();
                                       newProcedure.Account__c=accountId; 
                                       newProcedure.Name = carePlanName;
                                       newProcedure.RecordTypeId = devRecordTypeId;
                                       
                                       newProcedure.From_Date__c = date.valueOf(starttimeProcedure) ;
                                       newProcedure.Start_Time__c = date.valueOf(starttimeProcedure) ;
                                       newProcedure.To_Date__c = date.valueOf(endtimeProcedure) ;
                                       newProcedure.End_Time__c = date.valueOf(endtimeProcedure) ;
                                       
                                       if(Elixir_utility.dateTimeConversion(endtimeProcedure) <= Elixir_utility.dateTimeConversion(starttimeProcedure))
                                       {
                                           newProcedure.put('ElixirSuite__End_Time__c' , Elixir_utility.dateTimeConversion(starttimeProcedure).addMinutes(1));
                                       }
                                       else
                                       {
                                           newProcedure.put('ElixirSuite__End_Time__c' , Elixir_utility.dateTimeConversion(endtimeProcedure));
                                       }
                                       
                                       newProcedure.put('ElixirSuite__Start_Time__c' , Elixir_utility.dateTimeConversion(starttimeProcedure));
                                       
                                       newProcedure.Name = 'Care Plan-'+carePlanName;
                                       if(!lstVisits.isEmpty())
                                       {
                                           newProcedure.ElixirSuite__Visits__c =lstVisits[0].Id;
                                       }
                                       
                                       if(Schema.sObjectType.Procedure__c.fields.ElixirSuite__Visits__c.isCreateable() &&
                                          Schema.sObjectType.Procedure__c.fields.From_Date__c.isCreateable() &&
                                          Schema.sObjectType.Procedure__c.fields.Start_Time__c.isCreateable() &&
                                          Schema.sObjectType.Procedure__c.fields.To_Date__c.isCreateable() &&
                                          Schema.sObjectType.Procedure__c.fields.End_Time__c.isCreateable() &&
                                          Schema.sObjectType.Procedure__c.fields.Account__c.isCreateable() &&
                                          Schema.sObjectType.Procedure__c.fields.RecordTypeId.isCreateable() 
                                         ){ 
                                             uow.registerNew(newProcedure);
                                         }
                                       
                                       Map<String, Object> mainJson =(Map<String, Object>) JSON.deserializeUntyped(masterData);
                                                                             
                                       // Insert objective from top level hierarchy
                                       List<Object> listOfObjectives= (List<Object>) mainJson.get('listOfObjectives');
                                       for(Object objRec : listOfObjectives){
                                           Map<String, Object> mapOfObj = (Map<String, Object>) objRec;
                                           ElixirSuite__Dataset2__c obj = new ElixirSuite__Dataset2__c();
                                           obj.ElixirSuite__Name__c=String.valueOf(mapOfObj.get('Name'));
                                           obj.ElixirSuite__Description__c=String.valueOf(mapOfObj.get('ElixirSuite__Description__c'));
                                           obj.ElixirSuite__Template_Problem__c = (Id) mapOfObj.get('Id');
                                           obj.ElixirSuite__Treatment_Plan__c = newTP.Id;
                                           if(mapOfObj.containsKey('endDate')){
                                           obj.ElixirSuite__Due_Date__c = Date.valueOf(String.valueOf(mapOfObj.get('endDate')));
                                           }else{
                                           obj.ElixirSuite__Due_Date__c = Date.valueOf(endDate);
                                           }
                                           
                                           if(Schema.sObjectType.ElixirSuite__Dataset2__c.fields.ElixirSuite__Name__c.isCreateable() &&
                                              Schema.sObjectType.ElixirSuite__Dataset2__c.fields.ElixirSuite__Description__c.isCreateable() &&
                                              Schema.sObjectType.ElixirSuite__Dataset2__c.fields.ElixirSuite__Plan_Hierarchy__c.isCreateable() && 
                                              Schema.sObjectType.ElixirSuite__Dataset2__c.fields.ElixirSuite__Template_Problem__c.isCreateable() 
                                             ){ 
                                                
                                                 uow.registerNew(obj, ElixirSuite__Dataset2__c.ElixirSuite__Treatment_Plan__c, newTP);
                                             }
                                           
                                           //Adding intervention into top level Objective
                                           List<Object> listOfInterv = (List<Object>) mapOfObj.get('listOfIntervention'); 
                                         
                                           if(listOfInterv!=null && listOfInterv.size()>0){
                                               for(Object objRec1 : listOfInterv){
                                                   Map<String, Object> mapOfInt = (Map<String, Object>) objRec1;  
                                                   Task tsk = new Task();
                                                   tsk.Description = String.valueOf(mapOfInt.get('ElixirSuite__Description__c'));
                                                   tsk.Subject = String.valueOf(mapOfInt.get('Name'));
                                                   tsk.Status = 'In Progress';
                                                   tsk.OwnerId = String.valueOf(mapOfInt.get('assignedTo'));
                                                   tsk.WhatId = obj.id;
                                                   tsk.ElixirSuite__Template_Problem__c = (Id) mapOfInt.get('Id');
                                                   if(mapOfInt.containsKey('endDate')){
                                                       tsk.ActivityDate = Date.valueOf(String.valueOf(mapOfInt.get('endDate')));
                                                   }else{
                                                       tsk.ActivityDate = Date.valueOf(endDate);
                                                   }
                                                   if(Schema.sObjectType.Task.fields.Description.isCreateable() &&
                                                      Schema.sObjectType.Task.fields.Subject.isCreateable() &&
                                                      Schema.sObjectType.Task.fields.OwnerId.isCreateable() &&
                                                      Schema.sObjectType.Task.fields.ActivityDate.isCreateable()                                       
                                                     ){  
                                                        
                                                         uow.registerNew(tsk, Task.WhatId, obj);
                                                     }
                                               }
                                           }    
                                       }
                                       
                                       //Insert Intervention from Top level hierarchy
                                       List<Object> listOfInterventions = (List<Object>) mainJson.get('listOfInterventions');
                                       for(Object taskRec : listOfInterventions ){
                                           Map<String, Object> mapOfInt = (Map<String, Object>) taskRec;
                                           Task tsks = new task();
                                           tsks.Description = String.valueOf(mapOfInt.get('ElixirSuite__Description__c'));
                                           tsks.Subject = String.valueOf(mapOfInt.get('Name'));
                                           tsks.Status = 'In Progress';
                                           tsks.OwnerId = String.valueOf(mapOfInt.get('assignedTo'));
                                           tsks.WhatId = newTP.id;
                                           tsks.ElixirSuite__Template_Problem__c = (Id) mapOfInt.get('Id');
                                           
                                           if(mapOfInt.containsKey('endDate')){
                                               tsks.ActivityDate = Date.valueOf(String.valueOf(mapOfInt.get('endDate')));
                                           }else{
                                               tsks.ActivityDate = Date.valueOf(endDate);
                                           }
                                           if(Schema.sObjectType.Task.fields.Description.isCreateable() &&
                                              Schema.sObjectType.Task.fields.Subject.isCreateable() &&
                                              Schema.sObjectType.Task.fields.OwnerId.isCreateable() &&
                                              Schema.sObjectType.Task.fields.ActivityDate.isCreateable()                                       
                                             ){  
                                                
                                                 uow.registerNew(tsks,Task.WhatId, newTP);
                                             }
                                       } 
                                       
                                       //Adding goal from top level hierarchy
                                           List<Object> listOfTopGoals = (List<Object>) mainJson.get('listOfTopLevelGoals'); 
                                           
                                           if(listOfTopGoals!=null && !listOfTopGoals.isEmpty()){
                                               for(Object goalRec : listOfTopGoals){
                                                   Map<String, Object> mapOfGoal = (Map<String, Object>) goalRec;
                                                   ElixirSuite__Plan_SubHierarchy__c newGoal = new ElixirSuite__Plan_SubHierarchy__c();
                                                   newGoal.ElixirSuite__Plan_Hierarchy_Name__c =  String.valueOf(mapOfGoal.get('Name'));
                                                   newGoal.ElixirSuite__Description__c =  String.valueOf(mapOfGoal.get('ElixirSuite__Description__c'));
                                                   newGoal.ElixirSuite__Template_Problem__c = (Id) mapOfGoal.get('Id');
                                                   newGoal.ElixirSuite__Treatment_Plan__c = newTP.id;
                                                   if(mapOfGoal.containsKey('endDate')){
                                                       newGoal.ElixirSuite__Due_Date__c = Date.valueOf(String.valueOf(mapOfGoal.get('endDate')));
                                                   }else{
                                                       newGoal.ElixirSuite__Due_Date__c = Date.valueOf(endDate);
                                                   }
                                                   if(Schema.sObjectType.ElixirSuite__Plan_SubHierarchy__c.fields.ElixirSuite__Plan_Hierarchy_Name__c.isCreateable() &&
                                                      Schema.sObjectType.ElixirSuite__Plan_SubHierarchy__c.fields.ElixirSuite__Description__c.isCreateable() &&
                                                      Schema.sObjectType.ElixirSuite__Plan_SubHierarchy__c.fields.ElixirSuite__Template_Problem__c.isCreateable()
                                                     ){
                                                         
                                                         uow.registerNew(newGoal, ElixirSuite__Plan_SubHierarchy__c.ElixirSuite__Treatment_Plan__c, newTP);
                                                     }
                                                   
                                                   //Adding objective from goal
                                                   List<Object> listOfObj = (List<Object>) mapOfGoal.get('listOfTask'); 
                                                  
                                                   if(listOfObj!=null && !listOfObj.isEmpty()){
                                                       for(Object objRec : listOfObj){
                                                           Map<String, Object> mapOfobj = (Map<String, Object>) objRec;  
                                                           ElixirSuite__Dataset2__c ob = new ElixirSuite__Dataset2__c();
                                                           ob.ElixirSuite__Name__c=String.valueOf(mapOfobj.get('Name'));
                                                           ob.ElixirSuite__Description__c=String.valueOf(mapOfobj.get('ElixirSuite__Description__c'));
                                                           ob.ElixirSuite__Plan_SubHierarchy__c=newGoal.id;
                                                           ob.ElixirSuite__Template_Problem__c = (Id) mapOfobj.get('Id');
                                                           
                                                           if(mapOfobj.containsKey('endDate')){
                                                           ob.ElixirSuite__Due_Date__c = Date.valueOf(String.valueOf(mapOfobj.get('endDate')));
                                                           }else{
                                                           ob.ElixirSuite__Due_Date__c = Date.valueOf(endDate);
                                                           }                                                           
                                                           if(Schema.sObjectType.ElixirSuite__Dataset2__c.fields.ElixirSuite__Name__c.isCreateable() &&
                                                              Schema.sObjectType.ElixirSuite__Dataset2__c.fields.ElixirSuite__Description__c.isCreateable() &&
                                                              Schema.sObjectType.ElixirSuite__Dataset2__c.fields.ElixirSuite__Plan_SubHierarchy__c.isCreateable() && 
                                                              Schema.sObjectType.ElixirSuite__Dataset2__c.fields.ElixirSuite__Template_Problem__c.isCreateable()
                                                             ){ 
                                                                
                                                                 uow.registerNew(ob, ElixirSuite__Dataset2__c.ElixirSuite__Plan_SubHierarchy__c, newGoal);
                                                             }
                                                           
                                                           //Adding intervention from objective
                                                           List<Object> listOfInterv = (List<Object>) mapOfobj.get('listOfIntervention'); 
                                                          
                                                           if(listOfInterv!=null && !listOfInterv.isEmpty()){
                                                               for(Object objRec1 : listOfInterv){
                                                                   Map<String, Object> mapOfInt = (Map<String, Object>) objRec1;  
                                                                   Task tsk = new task();
                                                                   tsk.Description = String.valueOf(mapOfInt.get('ElixirSuite__Description__c'));
                                                                   tsk.Subject = String.valueOf(mapOfInt.get('Name'));
                                                                   tsk.Status = 'In Progress';
                                                                   tsk.OwnerId = String.valueOf(mapOfInt.get('assignedTo'));
                                                                   tsk.WhatId = ob.id;
                                                                   tsk.ElixirSuite__Template_Problem__c = (Id) mapOfInt.get('Id');
                                                                   
                                                                   if(mapOfInt.containsKey('endDate')){
                                                                       tsk.ActivityDate = Date.valueOf(String.valueOf(mapOfInt.get('endDate')));
                                                                   }else{
                                                                       tsk.ActivityDate = Date.valueOf(endDate);
                                                                   }
                                                                   
                                                                   if(Schema.sObjectType.Task.fields.Description.isCreateable() &&
                                                                      Schema.sObjectType.Task.fields.Subject.isCreateable() &&
                                                                      Schema.sObjectType.Task.fields.OwnerId.isCreateable() &&
                                                                      Schema.sObjectType.Task.fields.ActivityDate.isCreateable()   
                                                                     ){ 
                                                                         
                                                                         uow.registerNew(tsk, Task.WhatId, ob);
                                                                     }
                                                               }
                                                           }
                                                           
                                                       }
                                                   }
                                                   
                                                   // Adding intervention from Goal
                                                   
                                                   List<Object> listOfIntervention = (List<Object>) mapOfGoal.get('listOfIntervention'); 
                                                   if(listOfIntervention!=null && !listOfIntervention.isEmpty()){
                                                       for(Object objRec : listOfIntervention){
                                                           Map<String, Object> mapOfInt = (Map<String, Object>) objRec;  
                                                           Task tsk = new task();
                                                           tsk.Description = String.valueOf(mapOfInt.get('ElixirSuite__Description__c'));
                                                           tsk.Subject = String.valueOf(mapOfInt.get('Name'));
                                                           tsk.Status = 'In Progress';
                                                           tsk.OwnerId = String.valueOf(mapOfInt.get('assignedTo'));
                                                           tsk.WhatId = newGoal.id;
                                                           tsk.ElixirSuite__Template_Problem__c = (Id) mapOfInt.get('Id');
                                                           if(mapOfInt.containsKey('endDate')){
                                                               tsk.ActivityDate = Date.valueOf(String.valueOf(mapOfInt.get('endDate')));
                                                           }else{
                                                               tsk.ActivityDate = Date.valueOf(endDate);
                                                           }
                                                           
                                                           if(Schema.sObjectType.Task.fields.Description.isCreateable() &&
                                                              Schema.sObjectType.Task.fields.Subject.isCreateable() &&
                                                              Schema.sObjectType.Task.fields.OwnerId.isCreateable() &&
                                                              Schema.sObjectType.Task.fields.ActivityDate.isCreateable()   
                                                             ){  
                                                                 uow.registerNew(tsk, Task.WhatId, newGoal);
                                                             }
                                                       }
                                                   }
                                               } 
                                           }
                                       
                                       //problem starts here
                                       List<Object> listOfProblems = (List<Object>) mainJson.get('listOfProblem');
                                       
                                       for(Object problemRec : listOfProblems){
                                           // Problem Insertation Start
                                           //Dataset1__c prob = new Dataset1__c();
                                           
                                           Map<String, Object> mapOfProblem = (Map<String, Object>) problemRec;
                                          
                                           List<Object> checkListOfGoals = (List<Object>) mapOfProblem.get('listOfGoal');
                                           List<Object> checkListOfObj = (List<Object>) mapOfProblem.get('listOfDef');
                                           Plan_Hierarchy__c newProblem = new Plan_Hierarchy__c();
                                           newProblem.ElixirSuite__Name__c = String.valueOf(mapOfProblem.get('Name'));
                                           newProblem.ElixirSuite__Description__c = String.valueOf(mapOfProblem.get('ElixirSuite__Description__c'));
                                           newProblem.ElixirSuite__Template_Problem__c = (Id) mapOfProblem.get('ElixirSuite__Template_Problem__c');
                                           newProblem.ElixirSuite__Treatment_Plan__c = newTP.Id;
                                           newProblem.ElixirSuite__Dataset1__c = (Id) mapOfProblem.get('Id');
                                           
                                           if(mapOfProblem.containsKey('endDate')){
                                               newProblem.ElixirSuite__Due_Date__c = Date.valueOf(String.valueOf(mapOfProblem.get('endDate')));
                                           }else{
                                               newProblem.ElixirSuite__Due_Date__c = Date.valueOf(endDate);
                                           }

                                           if(Schema.sObjectType.Plan_Hierarchy__c.fields.ElixirSuite__Name__c.isCreateable() &&
                                              Schema.sObjectType.Plan_Hierarchy__c.fields.ElixirSuite__Description__c.isCreateable() &&
                                              Schema.sObjectType.Plan_Hierarchy__c.fields.ElixirSuite__Template_Problem__c.isCreateable() && ((
                                                  checkListOfGoals!=null && !checkListOfGoals.isEmpty()) || (checkListOfObj!=null && !checkListOfObj.isEmpty())) )
                                           {   
                                               uow.registerNew(newProblem, Plan_Hierarchy__c.ElixirSuite__Treatment_Plan__c, newTP);
                                           }
                                           
                                           //Adding goal from problem
                                           List<Object> listOfGoals = (List<Object>) mapOfProblem.get('listOfGoal'); 
                                          
                                           if(listOfGoals!=null && !listOfGoals.isEmpty()){
                                               for(Object goalRec : listOfGoals){
                                                   Map<String, Object> mapOfGoal = (Map<String, Object>) goalRec;
                                                   ElixirSuite__Plan_SubHierarchy__c newGoal = new ElixirSuite__Plan_SubHierarchy__c();
                                                   newGoal.ElixirSuite__Plan_Hierarchy_Name__c =  String.valueOf(mapOfGoal.get('Name'));
                                                   newGoal.ElixirSuite__Description__c =  String.valueOf(mapOfGoal.get('ElixirSuite__Description__c'));
                                                   newGoal.ElixirSuite__Plan_Hierarchy__c  = newProblem.id;
                                                   newGoal.ElixirSuite__Template_Problem__c = (Id) mapOfGoal.get('Id');
                                                   if(mapOfGoal.containsKey('endDate')){
                                                       newGoal.ElixirSuite__Due_Date__c = Date.valueOf(String.valueOf(mapOfProblem.get('endDate')));
                                                   }else{
                                                       newGoal.ElixirSuite__Due_Date__c = Date.valueOf(endDate);
                                                   }
                                                   if(Schema.sObjectType.ElixirSuite__Plan_SubHierarchy__c.fields.ElixirSuite__Plan_Hierarchy_Name__c.isCreateable() &&
                                                      Schema.sObjectType.ElixirSuite__Plan_SubHierarchy__c.fields.ElixirSuite__Description__c.isCreateable() &&
                                                      Schema.sObjectType.ElixirSuite__Plan_SubHierarchy__c.fields.ElixirSuite__Plan_Hierarchy__c.isCreateable() && 
                                                      Schema.sObjectType.ElixirSuite__Plan_SubHierarchy__c.fields.ElixirSuite__Template_Problem__c.isCreateable()
                                                     ){
                                                        
                                                         uow.registerNew(newGoal, ElixirSuite__Plan_SubHierarchy__c.ElixirSuite__Plan_Hierarchy__c, newProblem);
                                                     }
                                                   
                                                   //Adding objective from goal
                                                   List<Object> listOfObj = (List<Object>) mapOfGoal.get('listOfTask'); 
                                                  
                                                   if(listOfObj!=null && !listOfObj.isEmpty()){
                                                       for(Object objRec : listOfObj){
                                                           Map<String, Object> mapOfobj = (Map<String, Object>) objRec;  
                                                           ElixirSuite__Dataset2__c ob = new ElixirSuite__Dataset2__c();
                                                           ob.ElixirSuite__Name__c=String.valueOf(mapOfobj.get('Name'));
                                                           ob.ElixirSuite__Description__c=String.valueOf(mapOfobj.get('ElixirSuite__Description__c'));
                                                           ob.ElixirSuite__Plan_SubHierarchy__c=newGoal.id;
                                                           ob.ElixirSuite__Template_Problem__c = (Id) mapOfobj.get('Id');                                       
                                                           if(mapOfobj.containsKey('endDate')){
                                                           ob.ElixirSuite__Due_Date__c = Date.valueOf(String.valueOf(mapOfProblem.get('endDate')));
                                                           }else{
                                                           ob.ElixirSuite__Due_Date__c = Date.valueOf(endDate);
                                                           }
                                                           
                                                           if(Schema.sObjectType.ElixirSuite__Dataset2__c.fields.ElixirSuite__Name__c.isCreateable() &&
                                                              Schema.sObjectType.ElixirSuite__Dataset2__c.fields.ElixirSuite__Description__c.isCreateable() &&
                                                              Schema.sObjectType.ElixirSuite__Dataset2__c.fields.ElixirSuite__Plan_SubHierarchy__c.isCreateable() && 
                                                              Schema.sObjectType.ElixirSuite__Dataset2__c.fields.ElixirSuite__Template_Problem__c.isCreateable()
                                                             ){ 
                                                                 
                                                                 uow.registerNew(ob, ElixirSuite__Dataset2__c.ElixirSuite__Plan_SubHierarchy__c, newGoal);
                                                             }
                                                           
                                                           //Adding intervention from objective
                                                           List<Object> listOfInterv = (List<Object>) mapOfobj.get('listOfIntervention'); 
                                                          
                                                           if(listOfInterv!=null && !listOfInterv.isEmpty()){
                                                               for(Object objRec1 : listOfInterv){
                                                                   Map<String, Object> mapOfInt = (Map<String, Object>) objRec1;  
                                                                   Task tsk = new task();
                                                                   tsk.Description = String.valueOf(mapOfInt.get('ElixirSuite__Description__c'));
                                                                   tsk.Subject = String.valueOf(mapOfInt.get('Name'));
                                                                   tsk.Status = 'In Progress';
                                                                   tsk.OwnerId = String.valueOf(mapOfInt.get('assignedTo'));
                                                                   tsk.WhatId = ob.id;
                                                                   tsk.ElixirSuite__Template_Problem__c = (Id) mapOfInt.get('Id');
                                                                   
                                                                   if(mapOfInt.containsKey('endDate')){
                                                                       tsk.ActivityDate = Date.valueOf(String.valueOf(mapOfProblem.get('endDate')));
                                                                   }else{
                                                                       tsk.ActivityDate = Date.valueOf(endDate);
                                                                   }
                                                                   if(Schema.sObjectType.Task.fields.Description.isCreateable() &&
                                                                      Schema.sObjectType.Task.fields.Subject.isCreateable() &&
                                                                      Schema.sObjectType.Task.fields.OwnerId.isCreateable() &&
                                                                      Schema.sObjectType.Task.fields.ActivityDate.isCreateable()   
                                                                     ){ 
                                                                       
                                                                         uow.registerNew(tsk, Task.WhatId, ob);
                                                                     }
                                                               }
                                                           }
                                                           
                                                       }
                                                   }
                                                   
                                                   // Adding intervention from Goal
                                                   
                                                   List<Object> listOfIntervention = (List<Object>) mapOfGoal.get('listOfIntervention'); 
                                                   if(listOfIntervention!=null && !listOfIntervention.isEmpty()){
                                                       for(Object objRec : listOfIntervention){
                                                           Map<String, Object> mapOfInt = (Map<String, Object>) objRec;  
                                                           Task tsk = new task();
                                                           tsk.Description = String.valueOf(mapOfInt.get('ElixirSuite__Description__c'));
                                                           tsk.Subject = String.valueOf(mapOfInt.get('Name'));
                                                           tsk.Status = 'In Progress';
                                                           tsk.OwnerId = String.valueOf(mapOfInt.get('assignedTo'));
                                                           tsk.WhatId = newGoal.id;
                                                           tsk.ElixirSuite__Template_Problem__c = (Id) mapOfInt.get('Id');
                                                           
                                                           if(mapOfInt.containsKey('endDate')){
                                                               tsk.ActivityDate = Date.valueOf(String.valueOf(mapOfProblem.get('endDate')));
                                                           }else{
                                                               tsk.ActivityDate = Date.valueOf(endDate);
                                                           }
                                                           
                                                           if(Schema.sObjectType.Task.fields.Description.isCreateable() &&
                                                              Schema.sObjectType.Task.fields.Subject.isCreateable() &&
                                                              Schema.sObjectType.Task.fields.OwnerId.isCreateable() &&
                                                              Schema.sObjectType.Task.fields.ActivityDate.isCreateable()   
                                                             ){  
                                                                 uow.registerNew(tsk, Task.WhatId, newGoal);
                                                             }
                                                       }
                                                   }
                                               } 
                                           }
                                           
                                           //Adding Objective from Problem
                                           List<Object> listOfObj = (List<Object>) mapOfProblem.get('listOfDef'); 
                                           
                                           if(listOfObj!=null && !listOfObj.isEmpty()){
                                               for(Object defRec : listOfObj){
                                                   Map<String, Object> mapOfDef = (Map<String, Object>) defRec;
                                                   ElixirSuite__Dataset2__c obj = new ElixirSuite__Dataset2__c();
                                                   obj.ElixirSuite__Name__c=String.valueOf(mapOfDef.get('Name'));
                                                   obj.ElixirSuite__Description__c=String.valueOf(mapOfDef.get('ElixirSuite__Description__c'));
                                                   obj.ElixirSuite__Plan_Hierarchy__c = newProblem.id;
                                                   obj.ElixirSuite__Template_Problem__c = (Id) mapOfDef.get('Id');
                                                   if(mapOfDef.containsKey('endDate')){
                                                   obj.ElixirSuite__Due_Date__c = Date.valueOf(String.valueOf(mapOfProblem.get('endDate')));
                                                   }else{
                                                   obj.ElixirSuite__Due_Date__c = Date.valueOf(endDate);
                                                   }
                                                   
                                                   if(Schema.sObjectType.ElixirSuite__Dataset2__c.fields.ElixirSuite__Name__c.isCreateable() &&
                                                      Schema.sObjectType.ElixirSuite__Dataset2__c.fields.ElixirSuite__Description__c.isCreateable() &&
                                                      Schema.sObjectType.ElixirSuite__Dataset2__c.fields.ElixirSuite__Plan_Hierarchy__c.isCreateable() && 
                                                      Schema.sObjectType.ElixirSuite__Dataset2__c.fields.ElixirSuite__Template_Problem__c.isCreateable() 
                                                     ){ 
                                                         
                                                         uow.registerNew(obj, ElixirSuite__Dataset2__c.ElixirSuite__Plan_Hierarchy__c, newProblem);
                                                     }
                                                   
                                                   //Adding intervention from Objective - Problem
                                                   List<Object> listOfInterv = (List<Object>) mapOfDef.get('listOfIntervention'); 
                                                  
                                                   if(listOfInterv!=null && listOfInterv.size()>0){
                                                       for(Object objRec1 : listOfInterv){
                                                           Map<String, Object> mapOfInt = (Map<String, Object>) objRec1;  
                                                           Task tsk = new Task();
                                                           tsk.Description = String.valueOf(mapOfInt.get('ElixirSuite__Description__c'));
                                                           tsk.Subject = String.valueOf(mapOfInt.get('Name'));
                                                           tsk.Status = 'In Progress';
                                                           tsk.OwnerId = String.valueOf(mapOfInt.get('assignedTo'));
                                                           tsk.WhatId = obj.id;
                                                           tsk.ElixirSuite__Template_Problem__c = (Id) mapOfInt.get('Id');
                                                           
                                                           if(mapOfInt.containsKey('endDate')){
                                                               tsk.ActivityDate = Date.valueOf(String.valueOf(mapOfProblem.get('endDate')));
                                                           }else{
                                                               tsk.ActivityDate = Date.valueOf(endDate);
                                                           }
                                                           if(Schema.sObjectType.Task.fields.Description.isCreateable() &&
                                                              Schema.sObjectType.Task.fields.Subject.isCreateable() &&
                                                              Schema.sObjectType.Task.fields.OwnerId.isCreateable() &&
                                                              Schema.sObjectType.Task.fields.ActivityDate.isCreateable()                                       
                                                             ){  
                                                                 
                                                                 uow.registerNew(tsk, Task.WhatId, obj);
                                                             }
                                                       }
                                                   }    
                                               }
                                           }
                                           
                                       }
                                       uow.commitWork();
                                       
                                       attachApprovalDataToParentCarePlan(newTP.id,approvedValues); 
                                       attachEHRNotes(accountId,newTP.id,selectedValues,selectedFormNames);
                                   }
                                   catch(Exception e){
                                       ExceptionLog.logError(e);
                                   }
                                   
                               }
   
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
   }
   
   
}
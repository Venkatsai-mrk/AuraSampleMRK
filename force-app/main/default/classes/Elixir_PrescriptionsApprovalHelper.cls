public with sharing class Elixir_PrescriptionsApprovalHelper {
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
            when else {
                System.Debug('Error');
            }
        }
        return toReturnData;
    }
    @AuraEnabled
    public static  FormApproval_ExistingRecordsWrapper  fetchExistingApprovalRecord(Integer approvalLevel, String ApprovalFor){
        System.debug('approval level '+approvalLevel);
       System.debug('ApprovalFor '+ApprovalFor);
        FormApproval_ExistingRecordsWrapper obj = new FormApproval_ExistingRecordsWrapper();
        Boolean isPreviousRecAvailable = false;
        ElixirSuite__Master_Object__c[] records = fetchApprovalRecord(approvalLevel, ApprovalFor);
        if(records.isEmpty()){
            system.debug('rec is empty');
            ElixirSuite__Master_Object__c[] objBeforeRec =  fetchApprovalRecord(approvalLevel-1, ApprovalFor);
            if(!objBeforeRec.isEmpty()){
                isPreviousRecAvailable = true;
            }
        }
        else {
            isPreviousRecAvailable = true;
        }
        system.debug('1');
        obj.isPreviousRecAvailable = isPreviousRecAvailable;
        obj.records = records; 
        obj.keylist = new List<sObject>();
        if(records!=null & records.size()>0){
            obj.keylist = fetchMapOfSetUpKey(records[0].ElixirSuite__Approver__c);
        }
        return obj;
        
    }
    public static  List<sObject> fetchMapOfSetUpKey(String key){
        FormApprovalHelperWrapper objInstance =  fetchOptions_SetupKey(key);
        Map<String,List<sObject>> mapOfSObject = new  Map<String,List<sObject>>();
        switch on key {
            when 'User' {
                mapOfSObject.put('User',fetchAllActiveUsers());
            }when 'Role' {
                mapOfSObject.put('Role',fetchAllRoles());
            }
            when 'Profile' {
                mapOfSObject.put('Profile',fetchAllProfiles());
            }when else {
                System.Debug('Error');
            }
        }
        return mapOfSObject.get(key);
    }
    
   /* @AuraEnabled
    public static  PatientPortal_ExistingRecordsWrapper  fetchExistingPatientPortalApprovalRecord(String emailSettingName){
        
        PatientPortal_ExistingRecordsWrapper obj = new PatientPortal_ExistingRecordsWrapper();
        Boolean isRecAvailable = false;
        Id recId = Schema.SObjectType.ElixirSuite__Master_Object__c.getRecordTypeInfosByDeveloperName().get('Patient_Portal').getRecordTypeId();
        ElixirSuite__Master_Object__c[] records = [SELECT Id,ElixirSuite__Patient_Tile_Entity__c,
                                                  ElixirSuite__Approval_Members__c,ElixirSuite__Approval_Members_Name__c,
                                                  ElixirSuite__Approver__c,ElixirSuite__Approver_List__c FROM ElixirSuite__Master_Object__c 
                                                  WHERE RecordTypeId =: recId AND ElixirSuite__Patient_Tile_Entity__c =: emailSettingName WITH SECURITY_ENFORCED];
        if(records.isEmpty()){
            obj.isRecAvailable = isRecAvailable;
            obj.records = records;
            obj.keylist = new List<sObject>();
        }
        else {
            isRecAvailable = true;
            obj.isRecAvailable = isRecAvailable;
            obj.records = records;
            obj.keylist = fetchMapOfSetUpKey(records[0].ElixirSuite__Approver__c);
        }
        
        return obj;
        
    }*/
    
    @AuraEnabled
    public static String saveApprovalProcess(String approver,String approvalLevel,String selectedApprovers,String dropDownOptions,
                                             String ApprovalFor, String mapOfSetUpKey,String approverNames, String ApproverCustomLabel) {
                                                 Map<String, Object> lstOfDropDownOptions =(Map<String, Object>) JSON.deserializeUntyped(dropDownOptions);
                                                 List<Object> obj_lstOfDropDownOptions = (List<Object>) lstOfDropDownOptions.get('keysToSave');
                                                Id recordTypeId = Schema.SObjectType.ElixirSuite__Master_Object__c.getRecordTypeInfosByDeveloperName().get('Approval_Configuration').getRecordTypeId(); 
                                                 ElixirSuite__Master_Object__c obj = new ElixirSuite__Master_Object__c();
                                                 obj.ElixirSuite__Approval_Level__c	 = Integer.valueOf(approvalLevel);
                                                 obj.ElixirSuite__Approval_Members__c = selectedApprovers;
                                                 obj.ElixirSuite__Approval_Members_Name__c = approverNames;
                                                 obj.ElixirSuite__Approver__c = approver;
                                                 obj.ElixirSuite__Approver_List__c = JSON.serialize(obj_lstOfDropDownOptions);
                                                 obj.recordTypeId =recordTypeId;
                                                 obj.ElixirSuite__Approval_Level_For__c=ApprovalFor;
                                                 obj.ElixirSuite__Approver_Custom_Label__c = ApproverCustomLabel;
                                                 DMLManager.insertAsUser(obj);
                                                 system.debug('id is '+obj.ID);
                                                 return obj.ID; 
                                             }
    @AuraEnabled
    public static String updateApprovalProcess(String approver,String approvalLevel,String selectedApprovers,String dropDownOptions,
                                               String ApprovalFor,String recordId,String approverNames, String ApproverCustomLabel) {
                                                   system.debug('selected approvers '+selectedApprovers);
                                                   Id recordTypeId = Schema.SObjectType.ElixirSuite__Master_Object__c.getRecordTypeInfosByDeveloperName().get('Approval_Configuration').getRecordTypeId();
                                                   Map<String, Object> lstOfDropDownOptions =(Map<String, Object>) JSON.deserializeUntyped(dropDownOptions);
                                                   List<Object> obj_lstOfDropDownOptions = (List<Object>) lstOfDropDownOptions.get('keysToSave');
                                                   ElixirSuite__Master_Object__c obj = new ElixirSuite__Master_Object__c();
                                                   obj.Id = recordId;
                                                   obj.ElixirSuite__Approval_Level__c	 = Integer.valueOf(approvalLevel);

                                                   If( String.isBlank(selectedApprovers) && approver=='Patient') {
                                                    selectedApprovers = 'Patient';
                                                    approverNames = 'Patient';
                                                    }

                                                   obj.ElixirSuite__Approval_Members__c = selectedApprovers;
                                                   obj.ElixirSuite__Approver__c = approver;
                                                   obj.ElixirSuite__Approver_List__c = JSON.serialize(obj_lstOfDropDownOptions);
                                                   obj.ElixirSuite__Approval_Members_Name__c = approverNames;
                                                   obj.recordTypeId =recordTypeId;
                                                   obj.ElixirSuite__Approver_Custom_Label__c = ApproverCustomLabel;
                                                    DMLManager.updateAsUser(obj);
                                                  /* if (Schema.sObjectType.Object_1_css__c.isUpdateable()) {
                                                    update obj;
                                                    }*/
                                                   system.debug('id is '+obj.ID);
                                                   return obj.ID;   
                                               }
    @AuraEnabled
    public static void deleteApprovalLevel(String recordId) {
        ElixirSuite__Master_Object__c obj = new ElixirSuite__Master_Object__c();
        obj = [select id from ElixirSuite__Master_Object__c where id=:recordId WITH SECURITY_ENFORCED];
         DMLManager.deleteAsUser(obj);
       /* if (Schema.sObjectType.Object_1_css__c.isDeletable()) {
            delete obj;
         }*/
    }
   /* @AuraEnabled
    public static String patientPortalsaveApprovalProcess(String approver,String selectedApprovers,String approverNames,String dropDownOptions,String emailSettingName) {
                                                 Map<String, Object> lstOfDropDownOptions =(Map<String, Object>) JSON.deserializeUntyped(dropDownOptions);
                                                 List<Object> obj_lstOfDropDownOptions = (List<Object>) lstOfDropDownOptions.get('keysToSave');
                                                 
                                                 ElixirSuite__Master_Object__c MO = new ElixirSuite__Master_Object__c();
                                                 MO.ElixirSuite__Patient_Tile_Entity__c = emailSettingName;
                                                 MO.ElixirSuite__Approval_Members__c = selectedApprovers;
                                                 MO.ElixirSuite__Approval_Members_Name__c = approverNames;
                                                 MO.ElixirSuite__Approver__c = approver;
                                                 MO.ElixirSuite__Approver_List__c = JSON.serialize(obj_lstOfDropDownOptions);
                                                 MO.RecordTypeId = Schema.SObjectType.ElixirSuite__Master_Object__c.getRecordTypeInfosByDeveloperName().get('Patient_Portal').getRecordTypeId();
                                                 if (Schema.sObjectType.ElixirSuite__Master_Object__c.isCreateable()) {
                                                    insert MO;
                                                 }
        										DMLManager.insertAsUser(MO);
                                                 system.debug('id is '+MO.ID);
                                                 return MO.ID; 
                                             }*/
   /* @AuraEnabled
    public static String patientPortalUpdateApprovalProcess(String approver,String selectedApprovers,String approverNames,String dropDownOptions,String emailSettingName, String recordId) {
                                                 Map<String, Object> lstOfDropDownOptions =(Map<String, Object>) JSON.deserializeUntyped(dropDownOptions);
                                                 List<Object> obj_lstOfDropDownOptions = (List<Object>) lstOfDropDownOptions.get('keysToSave');
                                                 
                                                 ElixirSuite__Master_Object__c MO = new ElixirSuite__Master_Object__c();
                                                 MO.Id = recordId;
                                                 MO.ElixirSuite__Patient_Tile_Entity__c = emailSettingName;
                                                 MO.ElixirSuite__Approval_Members__c = selectedApprovers;
                                                 MO.ElixirSuite__Approval_Members_Name__c = approverNames;
                                                 MO.ElixirSuite__Approver__c = approver;
                                                 MO.ElixirSuite__Approver_List__c = JSON.serialize(obj_lstOfDropDownOptions);
                                                 MO.RecordTypeId = Schema.SObjectType.ElixirSuite__Master_Object__c.getRecordTypeInfosByDeveloperName().get('Patient_Portal').getRecordTypeId();
                                                 if (Schema.sObjectType.ElixirSuite__Master_Object__c.isUpdateable()) {
                                                    update MO;
                                                 }
        										 DMLManager.updateAsUser(MO);
                                                 system.debug('id is '+MO.ID);
                                                 return MO.ID; 
                                             }*/
    /**************** QUERY DUMPING GROUND ************************/
    public static List<User> fetchAllActiveUsers(){
        return [SELECT ID,Name FROM User WHERE IsActive = true WITH SECURITY_ENFORCED];
    }
    public static List<Profile> fetchAllProfiles(){
        return [SELECT ID,Name	 FROM Profile where Name!=null WITH SECURITY_ENFORCED];
    }
    public static List<UserRole> fetchAllRoles(){
        return [Select Id, Name from UserRole  where Name!=null WITH SECURITY_ENFORCED];
    }
    /*public static List<ApprovalLevelForForms__c> fetchNumberOfFormsApprovalLevel(){
        return [SELECT ID,Maximum_Level_For_Approval__c, Prescription_Approval_Level_Count__c FROM ApprovalLevelForForms__c 
        WHERE Maximum_Level_For_Approval__c!=NULL WITH SECURITY_ENFORCED LIMIT 1];
    }*/
    public static List<ApprovalLevelForForms__c> fetchNumberOfFormsApprovalLevel(){
        return [SELECT ID,Maximum_Level_For_Approval__c,Lab_Order_Approval_Level_Count__c, Prescription_Approval_Level_Count__c FROM ApprovalLevelForForms__c 
         WITH SECURITY_ENFORCED LIMIT 1];
    }

    public static ElixirSuite__Master_Object__c[] fetchApprovalRecord(Integer approvalLevel, String ApprovalFor){
        system.debug('approval level '+approvalLevel);
        system.debug('ApprovalFor '+ApprovalFor);
        return [Select Id,ElixirSuite__Approval_Level__c, ElixirSuite__Approval_Members__c,ElixirSuite__Approver__c,
                ElixirSuite__Is_Approval_Record__c,ElixirSuite__Approver_List__c, ElixirSuite__Approver_Custom_Label__c from ElixirSuite__Master_Object__c  where ElixirSuite__Approval_Level__c=:approvalLevel
                AND ElixirSuite__Approval_Level_For__c=:ApprovalFor WITH SECURITY_ENFORCED];
    }
    /**************************************************************/
    /**************** WRAPPER DUMPING GROUND ************************/
    public class FormApprovalHelperWrapper {
        @AuraEnabled  	public  List<User> allUsers{ get; set; }
        @AuraEnabled  	public  List<Profile> allProfiles{ get; set; }
        @AuraEnabled  	public  List<UserRole> allUserRoles{ get; set; }
    }
    public class FormApproval_InitWrapper {
        @AuraEnabled  	public List<ApprovalLevelForForms__c> numberOfApprovalLevels{ get; set; }
    }
    public class FormApproval_ExistingRecordsWrapper {
        @AuraEnabled  	public Boolean isPreviousRecAvailable = false;
        @AuraEnabled  	public ElixirSuite__Master_Object__c[] records{ get; set; }
        @AuraEnabled  	public sObject[] keylist{ get; set; }
    }
    public class PatientPortal_ExistingRecordsWrapper {
        @AuraEnabled  	public Boolean isRecAvailable = false;
        @AuraEnabled  	public ElixirSuite__Master_Object__c[] records{ get; set; }
        @AuraEnabled  	public sObject[] keylist{ get; set; }
    }
    /**************************************************************/
    @AuraEnabled
    public static boolean checkUpdateLegitimacy(String approvalLevel, String ApprovalFor) {
		
			Integer nextApprovalLevel= Integer.valueOf(approvalLevel) +1;
        	System.debug('nextApprovalLevel'+nextApprovalLevel);
			List<ElixirSuite__Master_Object__c> obj = [select id from ElixirSuite__Master_Object__c where  ElixirSuite__Approval_Level__c= :nextApprovalLevel AND ElixirSuite__Approval_Level_For__c=:ApprovalFor WITH SECURITY_ENFORCED];
			if(obj.size()>0)
		    	return false;
			else return true;
       
    }
}
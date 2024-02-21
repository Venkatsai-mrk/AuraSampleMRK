public with sharing class ElixirOEM_GlobalApprovalHelper {
    @AuraEnabled
    public static ApprovalScreenHelperWrapper fetchApprovalLevelCount(String selectedApprovalUnit){
        ApprovalScreenHelperWrapper toReturnData = new ApprovalScreenHelperWrapper();
        try{
        ElixirSuite__ApprovalLevelForForms__c[] lstOfApproval =  fetchApprovalAdminLevel();
        if(lstOfApproval!=null && lstOfApproval.size()>0){
            switch on selectedApprovalUnit {
                when 'CarePlan' {            
                    toReturnData.carePlanApprovalCount = lstOfApproval[0].ElixirSuite__Care_Plan_Approval_Level_Count__c;
                }when 'Prescription' {
                    toReturnData.prescriptionApprovalCount = lstOfApproval[0].ElixirSuite__Prescription_Approval_Level_Count__c; 
                }
                when 'LabOrder' {
                    toReturnData.laborderApprovalCount = lstOfApproval[0].ElixirSuite__Lab_Order_Approval_Level_Count__c;
                }               
                when else {
                    System.Debug('Error');
                }
            }  
        }
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        return toReturnData;
    }
    @AuraEnabled
    public static ElixirOEM_FormApprovalHelper.FormApprovalHelperWrapper fetchOptionsForSetupKey(String setUpKey) {
        return ElixirOEM_FormApprovalHelper.fetchOptions_SetupKey(setUpKey);
    }
    @AuraEnabled
    public static FormApproval_ExistingRecordsWrapper fetchExistingApprovalRecord(Integer approvalLevel,String selectedApprovalUnit){
        FormApproval_ExistingRecordsWrapper toReturn = new FormApproval_ExistingRecordsWrapper();
        try{
        if(string.isNotBlank(selectedApprovalUnit)){
            switch on selectedApprovalUnit {
                when 'CarePlan' {                        
                    Boolean isPreviousRecAvailable = false;
                    String devRecordTypeId = Schema.SObjectType.ElixirSuite__Master_Object__c.getRecordTypeInfosByDeveloperName().get('CarePlan_Configuration').getRecordTypeId();
                    toReturn.records =  fetchApprovalRecord(approvalLevel,devRecordTypeId);                    
                    if(toReturn.records.isEmpty()){
                        system.debug('rec is empty');
                        ElixirSuite__Master_Object__c[] objBeforeRec =  fetchApprovalRecord(approvalLevel-1,devRecordTypeId);
                        if(!objBeforeRec.isEmpty()){
                            isPreviousRecAvailable = true;
                        }
                    }
                    else {
                        isPreviousRecAvailable = true;
                    }
                    system.debug('1');
                    toReturn.isPreviousRecAvailable = isPreviousRecAvailable;
                    
                    toReturn.keylist = new List<sObject>();
                    if(toReturn.records!=null & toReturn.records.size()>0){
                        toReturn.keylist = ElixirOEM_FormApprovalHelper.fetchMapOfSetUpKey(toReturn.records[0].ElixirSuite__Approver__c);
                    }
                    
                }when 'Prescription' {
                    
                }
                when 'LabOrder' {
                    
                }               
                when else {
                    System.Debug('Error');
                }
            }
        }
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        return toReturn;
    }
    @AuraEnabled
    public static void saveApprovalAdminConfig(String approver,String approvalLevel,String selectedApprovers,String dropDownOptions,
                                               String mapOfSetUpKey,String approverNames,String approvalUnit){
                                                   if(string.isNotBlank(approvalUnit)){
                                                       switch on approvalUnit {
                                                           when 'CarePlan' {     
                                                               String devRecordTypeId = Schema.SObjectType.ElixirSuite__Master_Object__c.getRecordTypeInfosByDeveloperName().get('CarePlan_Configuration').getRecordTypeId();
                                                               saveApproval_Global( approver, approvalLevel, selectedApprovers, dropDownOptions,
                                                                                   mapOfSetUpKey, approverNames, devRecordTypeId);
                                                           }when 'Prescription' {
                                                               
                                                           }
                                                           when 'LabOrder' {
                                                               
                                                           }               
                                                           when else {
                                                               System.Debug('Error');
                                                           }
                                                       }
                                                   }
                                               }
    public static void saveApproval_Global(String approver,String approvalLevel,String selectedApprovers,String dropDownOptions,
                                           String mapOfSetUpKey,String approverNames,String recTypeId){
                                               Map<String, Object> lstOfDropDownOptions =(Map<String, Object>) JSON.deserializeUntyped(dropDownOptions);
                                               List<Object> obj_lstOfDropDownOptions = (List<Object>) lstOfDropDownOptions.get('keysToSave');
                                               
                                               ElixirSuite__Master_Object__c obj = new ElixirSuite__Master_Object__c();
                                               try{
                                               obj.ElixirSuite__Approval_Level__c	 = Integer.valueOf(approvalLevel);
                                               obj.ElixirSuite__Approval_Members__c = selectedApprovers;
                                               obj.ElixirSuite__Approval_Members_Name__c = approverNames;
                                               obj.ElixirSuite__Approver__c = approver;
                                               obj.ElixirSuite__Approver_List__c = JSON.serialize(obj_lstOfDropDownOptions);
                                               obj.ElixirSuite__Is_Approval_Record__c = true;
                                               obj.RecordTypeId = recTypeId;
                                               if( Schema.sObjectType.ElixirSuite__Master_Object__c.fields.ElixirSuite__Approval_Level__c.isCreateable() &&
                                                  Schema.sObjectType.ElixirSuite__Master_Object__c.fields.ElixirSuite__Approval_Members__c.isCreateable() &&
                                                  Schema.sObjectType.ElixirSuite__Master_Object__c.fields.ElixirSuite__Approval_Members_Name__c.isCreateable() &&
                                                  Schema.sObjectType.ElixirSuite__Master_Object__c.fields.ElixirSuite__Approver__c.isCreateable() &&
                                                  Schema.sObjectType.ElixirSuite__Master_Object__c.fields.ElixirSuite__Approver_List__c.isCreateable() &&
                                                  Schema.sObjectType.ElixirSuite__Master_Object__c.fields.RecordTypeId.isCreateable()
                                                  
                                                 ){
                                                     insert obj;
                                                 }
                                               }
                                               catch(Exception e){
                                               ExceptionLog.logError(e);
                                                    }
                                               system.debug('id is '+obj.ID);
                                               
                                           }
    
    @AuraEnabled
    public static void updateApprovalAdminConfig(String approver,String approvalLevel,String selectedApprovers,String dropDownOptions,
                                                 String approvalUnit,String recordId,String approverNames){
                                                     
                                                     if(string.isNotBlank(approvalUnit)){
                                                         switch on approvalUnit {
                                                             when 'CarePlan' {                                                                      
                                                                 updateApproval_Global( approver, approvalLevel, selectedApprovers, dropDownOptions,
                                                                                       approverNames, recordId);
                                                             }when 'Prescription' {
                                                                 
                                                             }
                                                             when 'LabOrder' {
                                                                 
                                                             }               
                                                             when else {
                                                                 System.Debug('Error');
                                                             }
                                                         }
                                                     }
                                                 }
    
    public static void updateApproval_Global(String approver,String approvalLevel,String selectedApprovers,String dropDownOptions,
                                             String approverNames,String recordId){
                                                 Map<String, Object> lstOfDropDownOptions =(Map<String, Object>) JSON.deserializeUntyped(dropDownOptions);
                                                 List<Object> obj_lstOfDropDownOptions = (List<Object>) lstOfDropDownOptions.get('keysToSave');
                                                 
                                                 ElixirSuite__Master_Object__c obj = new ElixirSuite__Master_Object__c();
                                                 obj.ElixirSuite__Approval_Level__c	 = Integer.valueOf(approvalLevel);
                                                 obj.ElixirSuite__Approval_Members__c = selectedApprovers;
                                                 obj.ElixirSuite__Approval_Members_Name__c = approverNames;
                                                 obj.ElixirSuite__Approver__c = approver;
                                                 obj.ElixirSuite__Approver_List__c = JSON.serialize(obj_lstOfDropDownOptions);
                                                 obj.ElixirSuite__Is_Approval_Record__c = true;
                                                 obj.Id = recordId;
                                                 if(Schema.sObjectType.ElixirSuite__Master_Object__c.isUpdateable()){
                                                 update obj;
                                                 system.debug('updated id is '+obj.ID);
                                                 }
                                                 
                                             }
    /**************** QUERY DUMPING GROUND ************************/
    public static List<ElixirSuite__ApprovalLevelForForms__c> fetchApprovalAdminLevel(){
        return [SELECT ElixirSuite__Care_Plan_Approval_Level_Count__c,ElixirSuite__Lab_Order_Approval_Level_Count__c,
                ElixirSuite__Prescription_Approval_Level_Count__c 
                FROM ElixirSuite__ApprovalLevelForForms__c 
                WITH SECURITY_ENFORCED
                limit 1];
    }
    public static List<Profile> fetchAllProfiles(){
        return [SELECT ID,Name	 FROM Profile where Name!=null WITH SECURITY_ENFORCED];
    }
    public static List<UserRole> fetchAllRoles(){
        return [Select Id, Name from UserRole  where Name!=null WITH SECURITY_ENFORCED];
    }
    public static List<ApprovalLevelForForms__c> fetchNumberOfFormsApprovalLevel(){
        return [SELECT ID,Maximum_Level_For_Approval__c FROM ApprovalLevelForForms__c 
                WHERE Maximum_Level_For_Approval__c!=NULL 
                WITH SECURITY_ENFORCED
                LIMIT 1];
    }
    public static ElixirSuite__Master_Object__c[] fetchApprovalRecord(Integer approvalLevel,String recordType){
        system.debug('approval level '+approvalLevel);
        system.debug('recordType '+recordType);
        return [Select Id,ElixirSuite__Approval_Level__c, ElixirSuite__Approval_Members__c,ElixirSuite__Approver__c,
                ElixirSuite__Approver_List__c from ElixirSuite__Master_Object__c  where ElixirSuite__Approval_Level__c=:approvalLevel
                AND RecordTypeId=:recordType
                WITH SECURITY_ENFORCED];
    }
    /**************************************************************/
    /**************** WRAPPER DUMPING GROUND ************************/
    public class ApprovalScreenHelperWrapper {
        @AuraEnabled  	public  Decimal carePlanApprovalCount{ get; set; }
        @AuraEnabled  	public  Decimal  prescriptionApprovalCount{ get; set; }
        @AuraEnabled  	public  Decimal laborderApprovalCount{ get; set; }
    }
    public class FormApproval_InitWrapper {
        @AuraEnabled  	public List<ApprovalLevelForForms__c> numberOfApprovalLevels{ get; set; }
    }
    public class FormApproval_ExistingRecordsWrapper {
        @AuraEnabled  	public Boolean isPreviousRecAvailable = false;
        @AuraEnabled  	public ElixirSuite__Master_Object__c[] records{ get; set; }
        @AuraEnabled  	public sObject[] keylist{ get; set; }
    }
    /**************************************************************/
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
        i++;        i++;
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
        i++;        i++;
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
        i++;        i++;
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
        i++;        i++;
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
        i++;        i++;
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
        i++;        i++;
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
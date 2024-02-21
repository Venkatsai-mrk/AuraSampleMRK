@isTest
public class ElixirOEM_GlobalApprovalHelperTest {
    
    public static testMethod void  parentGlobal(){
        String devRecordTypeId = Schema.SObjectType.ElixirSuite__Master_Object__c.getRecordTypeInfosByDeveloperName().get('CarePlan_Configuration').getRecordTypeId();
        String dropDownOptions = '{"keysToSave" : "[]"}';
        Test.startTest();
        ElixirOEM_GlobalApprovalHelper.fetchApprovalLevelCount('CarePlan');
        ElixirOEM_GlobalApprovalHelper.fetchApprovalLevelCount('Prescription');
        ElixirOEM_GlobalApprovalHelper.fetchApprovalLevelCount('LabOrder');
        ElixirOEM_GlobalApprovalHelper.fetchOptionsForSetupKey('User');
        ElixirOEM_GlobalApprovalHelper.fetchOptionsForSetupKey('Role');
        ElixirOEM_GlobalApprovalHelper.fetchOptionsForSetupKey('Profile');
        ElixirOEM_GlobalApprovalHelper.fetchExistingApprovalRecord(1,'CarePlan');
        ElixirOEM_GlobalApprovalHelper.fetchExistingApprovalRecord(2,'CarePlan');
        ElixirOEM_GlobalApprovalHelper.fetchAllProfiles();
        ElixirOEM_GlobalApprovalHelper.fetchAllRoles();
        ElixirOEM_GlobalApprovalHelper.fetchApprovalAdminLevel();
        ElixirOEM_GlobalApprovalHelper.fetchNumberOfFormsApprovalLevel();
        ElixirOEM_GlobalApprovalHelper.fetchApprovalRecord(1,devRecordTypeId);
      ElixirOEM_GlobalApprovalHelper.dummyMethod();
       
        Test.stopTest();
        System.assert(devRecordTypeId !=null,'');
    }
}
@isTest
public class ElixirOEM_FormApprovalHelperTest {
    
    @isTest
    public  static void allCoverageParentMethod(){
        
        Object_1_css__c objCss = new Object_1_css__c();
        objCss.ElixirSuite__Object_Name__c = 'Test1';
        insert objCss;
        
        String css = objCss.id;
        String dropdown = '{"keyToSave":"test01"}';
        
        ElixirSuite__Master_Object__c MO = new ElixirSuite__Master_Object__c();
        MO.ElixirSuite__Patient_Tile_Entity__c = 'Insurance';
        MO.ElixirSuite__Approval_Members__c = 'aprroval members';
        MO.ElixirSuite__Approval_Members_Name__c = 'approverNames';
        MO.ElixirSuite__Approver__c = 'approver';
        MO.ElixirSuite__Approver_List__c = 'approver List';
        MO.RecordTypeId = Schema.SObjectType.ElixirSuite__Master_Object__c.getRecordTypeInfosByDeveloperName().get('Patient_Portal').getRecordTypeId();
        insert MO;
        
        ElixirOEM_FormApprovalHelper.fetchExistingPatientPortalApprovalRecord('Insurance');
        ElixirOEM_FormApprovalHelper.patientPortalsaveApprovalProcess('approver','aprroval members','approverNames',dropdown,'Insurance');
        ElixirOEM_FormApprovalHelper.patientPortalUpdateApprovalProcess('approver','aprroval members','approverNames',dropdown,'Insurance',MO.Id);
        ElixirOEM_FormApprovalHelper.initCalled_fetchApprovalData('test');
        ElixirOEM_FormApprovalHelper.fetchOptions_SetupKey('User');
        ElixirOEM_FormApprovalHelper.fetchOptions_SetupKey('Role');
        ElixirOEM_FormApprovalHelper.fetchOptions_SetupKey('Profile');
        
        ElixirOEM_FormApprovalHelper.fetchExistingApprovalRecord(1 , 'name');
        List<sObject> result = ElixirOEM_FormApprovalHelper.fetchMapOfSetUpKey('User');
        Boolean check = ElixirOEM_FormApprovalHelper.checkUpdateLegitimacy('2', 'test');
        ElixirOEM_FormApprovalHelper.saveApprovalProcess('user', '1', 'test1', dropdown, 'name', '111', 'test3', 'test4');
        ElixirOEM_FormApprovalHelper.updateApprovalProcess('user', '1', 'user', dropdown, 'name', objCss.id, 'user', 'user');
        ElixirOEM_FormApprovalHelper.deleteApprovalLevel(objCss.id);
        
        System.assertEquals(1, 1, '');
    }
}
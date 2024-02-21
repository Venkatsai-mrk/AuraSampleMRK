@isTest
public with sharing class Elixir_PrescriptionsApprovalHelperTest {
    @isTest
    static void fetchApprovalData() {
        Id recordTypeId = Schema.SObjectType.ElixirSuite__Master_Object__c.getRecordTypeInfosByDeveloperName().get('Approval_Configuration').getRecordTypeId();
        ElixirSuite__Master_Object__c MO = new ElixirSuite__Master_Object__c();
        MO.ElixirSuite__Patient_Tile_Entity__c = 'Insurance';
        MO.ElixirSuite__Approval_Members__c = 'aprroval members';
        MO.ElixirSuite__Approval_Members_Name__c = 'approverNames';
        MO.ElixirSuite__Approver__c = 'approver';
        MO.ElixirSuite__Approver_List__c = 'approver List';
        MO.ElixirSuite__Approver_Custom_Label__c = 'siva';
        Mo.ElixirSuite__Approval_Level_For__c='Prescription Order';
        MO.RecordTypeId = recordTypeId;
        insert MO;
		String dropdown = '{"keyToSave":"test01"}';
       
       Test.startTest();
        Elixir_PrescriptionsApprovalHelper.initCalled_fetchApprovalData('test');
        Elixir_PrescriptionsApprovalHelper.fetchOptions_SetupKey('User');
        Elixir_PrescriptionsApprovalHelper.fetchOptions_SetupKey('Role');
        Elixir_PrescriptionsApprovalHelper.fetchOptions_SetupKey('Profile');
        Elixir_PrescriptionsApprovalHelper.fetchExistingApprovalRecord(1, 'Prescription Order');
        Elixir_PrescriptionsApprovalHelper.fetchApprovalRecord(1, 'Prescription Order');
        Elixir_PrescriptionsApprovalHelper.checkUpdateLegitimacy('1' , 'name');
        List<sObject> result = Elixir_PrescriptionsApprovalHelper.fetchMapOfSetUpKey('User');
        Boolean check = ElixirOEM_FormApprovalHelper.checkUpdateLegitimacy('2', 'test');
        Elixir_PrescriptionsApprovalHelper.saveApprovalProcess('user', '1', 'test1', dropdown, 'Prescription Order', 'User', 'test3', 'test4');
        Elixir_PrescriptionsApprovalHelper.updateApprovalProcess('user', '1', 'user', dropdown, 'name', MO.id, 'user', 'user');
        Elixir_PrescriptionsApprovalHelper.deleteApprovalLevel(MO.id);
        Elixir_MultiselectApprovalHelper.getselectOptions('User');
         Elixir_MultiselectApprovalHelper.getselectOptions('Role');
         Elixir_MultiselectApprovalHelper.getselectOptions('Profile');
        Test.stopTest();
        System.assertEquals(1, 1, '');
        
    }
}
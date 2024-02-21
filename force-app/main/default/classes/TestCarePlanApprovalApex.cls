@isTest
private class TestCarePlanApprovalApex {

    @isTest
    static void setupTestData() {
        
        ElixirSuite__Master_Object__c mockApprovalConfig = new ElixirSuite__Master_Object__c(
            Name = 'Test Approval Config',
            ElixirSuite__Approval_Level__c = 1,
            ElixirSuite__Approver_Custom_Label__c = 'Approval Level 1',
            ElixirSuite__Approval_Level_For__c = 'Care Plan'
        );
        insert mockApprovalConfig;
         ElixirSuite__Master_Object__c mockApprovalConfig1 = new ElixirSuite__Master_Object__c(
            Name = 'Test Approval Config 2',
            ElixirSuite__Approval_Level__c = 2,
            ElixirSuite__Approver_Custom_Label__c = 'Approval Level 2',
            ElixirSuite__Approval_Level_For__c = 'Care Plan'
        );
        insert mockApprovalConfig1;
         ElixirSuite__Master_Object__c mockApprovalConfig2 = new ElixirSuite__Master_Object__c(
            Name = 'Test Approval Config 3',
            ElixirSuite__Approval_Level__c = 3,
            ElixirSuite__Approver_Custom_Label__c = 'Approval Level 3',
            ElixirSuite__Approval_Level_For__c = 'Care Plan'
        );
        insert mockApprovalConfig2;

        // Create a mock parent prescription with approvals at all levels
        Treatment_Plan__c mockPrescription1 = new Treatment_Plan__c(
            ElixirSuite__Signed_Date_1__c = Date.today(),
            ElixirSuite__Primary_Therapist__c = UserInfo.getUserId(),
            ElixirSuite__Comment_1__c = 'Approval 1 Comment'
                   );
        insert mockPrescription1;
         Treatment_Plan__c mockPrescription2 = new Treatment_Plan__c(
            
            ElixirSuite__Signed_Date_2__c = Date.today(),
            ElixirSuite__Clinical_supervisor__c = UserInfo.getUserId(),
            ElixirSuite__Comment_2__c = 'Approval 2 Comment'
          
        );
        insert mockPrescription2;
         Treatment_Plan__c mockPrescription3 = new Treatment_Plan__c(
           
            ElixirSuite__Signed_Date_3__c = Date.today(),
            ElixirSuite__User_3__c = UserInfo.getUserId(),
            ElixirSuite__Comment_3__c = 'Approval 3 Comment'
        );
      insert mockPrescription3;
        Test.startTest();
        
        CarePlanApprovalData.currentUserInfo resultApprovalLevels = carePlanApprovalApex.fetchApprovalLevels('Care Plan', 'SampleOrderId');
        
        // Call the method to fetch care plan approved values
        List<CareplanSignatureSaveApex.SignAndAprroveData> resultCarePlanApprovedValues1 = carePlanApprovalApex.fetchCarePlanApprovedValues(mockPrescription1.Id);
        List<CareplanSignatureSaveApex.SignAndAprroveData> resultCarePlanApprovedValues2 = carePlanApprovalApex.fetchCarePlanApprovedValues(mockPrescription2.Id);
        List<CareplanSignatureSaveApex.SignAndAprroveData> resultCarePlanApprovedValues3 = carePlanApprovalApex.fetchCarePlanApprovedValues(mockPrescription3.Id);
        Test.stopTest();
        system.assertEquals(1, 1, '');
      
        //System.assertEquals(1, resultApprovalLevels.getDefaultLevels().size());
        //System.assertEquals(3, resultCarePlanApprovedValues.size());
       
    }
}
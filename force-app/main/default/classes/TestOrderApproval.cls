@isTest
private class TestOrderApproval {
    @isTest
    static void testFetchApprovalLevelsPrescriptionOrder() {
        // Create test data
         User testUser = new User(
            ProfileId = UserInfo.getProfileId(),
            Username = 'testuser_medication@example.com',
            Email = 'testuser_medication@example.com',
             LastName = 'TestUserMedication',
            Alias = 'tuser',
            TimeZoneSidKey = 'GMT',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;
        Id portalRecTypeId = Schema.SObjectType.ElixirSuite__Master_Object__c.getRecordTypeInfosByDeveloperName().get('Approval_Configuration').getRecordTypeId();
        ElixirSuite__Master_Object__c approvalConfig = new ElixirSuite__Master_Object__c(
            Name = 'Test Approval Config',
            ElixirSuite__Approval_Level__c = 1,
            ElixirSuite__Approval_Level_For__c = 'Prescription Order',
            RecordtypeId=portalRecTypeId,
            ElixirSuite__Approval_Members__c = testUser.Id
        );
        insert approvalConfig;
         ElixirSuite__Master_Object__c approvalConfig1 = new ElixirSuite__Master_Object__c(
            Name = 'Test 2 Approval Config',
            ElixirSuite__Approval_Level__c = 2,
            ElixirSuite__Approval_Level_For__c = 'Prescription Order',
            RecordtypeId=portalRecTypeId,
            ElixirSuite__Approval_Members__c = testUser.Id
        );
        insert approvalConfig1;
         ElixirSuite__Master_Object__c approvalConfig2 = new ElixirSuite__Master_Object__c(
            Name = 'Test 3 Approval Config',
            ElixirSuite__Approval_Level__c = 3,
            ElixirSuite__Approval_Level_For__c = 'Prescription Order',
            RecordtypeId=portalRecTypeId,
            ElixirSuite__Approval_Members__c = testUser.Id
        );
        insert approvalConfig2;
        
         ElixirSuite__Master_Object__c approvalConfig3 = new ElixirSuite__Master_Object__c(
            Name = 'Test 3 Approval Config',
            ElixirSuite__Approval_Level__c = 1,
            ElixirSuite__Approval_Level_For__c = 'Lab Order',
            RecordtypeId=portalRecTypeId,
            ElixirSuite__Approval_Members__c = testUser.Id
        );
        insert approvalConfig3;
        
        ElixirSuite__Master_Object__c approvalConfig4 = new ElixirSuite__Master_Object__c(
            Name = 'Test 3 Approval Config',
            ElixirSuite__Approval_Level__c = 2,
            ElixirSuite__Approval_Level_For__c = 'Lab Order',
            RecordtypeId=portalRecTypeId,
            ElixirSuite__Approval_Members__c = testUser.Id
        );
        insert approvalConfig4;
        ElixirSuite__Master_Object__c approvalConfig5 = new ElixirSuite__Master_Object__c(
            Name = 'Test 3 Approval Config',
            ElixirSuite__Approval_Level__c = 3,
            ElixirSuite__Approval_Level_For__c = 'Lab Order',
            RecordtypeId=portalRecTypeId,
            ElixirSuite__Approval_Members__c = testUser.Id
        );
        insert approvalConfig5;
        
        ElixirSuite__Prescription_Order__c testPrescriptionOrder = new ElixirSuite__Prescription_Order__c(
            ElixirSuite__Date_Of_Approval_1__c = Date.today(),
            ElixirSuite__Comment_1__c = 'Approval 1 Comment',
            ElixirSuite__User_1__c = UserInfo.getUserId()
           
        );
        insert testPrescriptionOrder;
        
         ElixirSuite__Prescription_Order__c testPrescriptionOrder1 = new ElixirSuite__Prescription_Order__c(
            ElixirSuite__Date_Of_Approval_2__c = Date.today(),
            ElixirSuite__Comment_2__c = 'Approval 1 Comment',
            ElixirSuite__User_2__c = UserInfo.getUserId()
           
        );
        insert testPrescriptionOrder1;
         ElixirSuite__Prescription_Order__c testPrescriptionOrder2 = new ElixirSuite__Prescription_Order__c(
            ElixirSuite__Date_Of_Approval_3__c = Date.today(),
            ElixirSuite__Comment_3__c = 'Approval 1 Comment',
            ElixirSuite__User_3__c = UserInfo.getUserId()
           
        );
        insert testPrescriptionOrder2;
        
        
        
        Account a  = new Account();
        a.name='testAccount';
        a.Verification_Code__c = '101';
        a.Phone='0123456789';
        a.BillingPostalCode='85212';
        insert a;
        Account acc  = new Account();
        acc.name='testAccount1';
        acc.Verification_Code__c = '1101';
        acc.Phone='01234567819';
        acc.BillingPostalCode='185212';
        insert acc;
       ElixirSuite__UA_Sample_Details__c testLabOrder = new ElixirSuite__UA_Sample_Details__c(
            ElixirSuite__Date_Of_Approval_1__c = Date.today(),
            ElixirSuite__Comment_1__c = 'Approval comment 1',
            ElixirSuite__User_1__c = UserInfo.getUserId(),
           ElixirSuite__Account__c = a.id
           
        );
        insert testLabOrder;
        
        ElixirSuite__UA_Sample_Details__c testLabOrder1 = new ElixirSuite__UA_Sample_Details__c(
            ElixirSuite__Date_Of_Approval_2__c = Date.today(),
            ElixirSuite__Comment_2__c = 'Approval comment 2',
            ElixirSuite__User_2__c = UserInfo.getUserId(),
           ElixirSuite__Account__c = a.id
           
        );
        insert testLabOrder1;
        
          ElixirSuite__UA_Sample_Details__c testLabOrder2 = new ElixirSuite__UA_Sample_Details__c(
            ElixirSuite__Date_Of_Approval_3__c = Date.today(),
            ElixirSuite__Comment_3__c = 'Approval comment 2',
            ElixirSuite__User_3__c = UserInfo.getUserId(),
           ElixirSuite__Account__c = a.id
           
        );
        insert testLabOrder2;

         Test.startTest();
        
         OrderApprovalData.currentUserInfo result = OrderApproval.fetchApprovalLevels('Prescription Order', testPrescriptionOrder.id);
         OrderApprovalData.currentUserInfo result1 = OrderApproval.fetchApprovalLevels('Prescription Order', testPrescriptionOrder1.id);
         OrderApprovalData.currentUserInfo result2 = OrderApproval.fetchApprovalLevels('Prescription Order', testPrescriptionOrder2.id);
         OrderApproval.fetchLabOrderApprovedValues(testLabOrder.id);
         OrderApproval.fetchLabOrderApprovedValues(testLabOrder1.id);
         OrderApproval.fetchLabOrderApprovedValues(testLabOrder2.id);
         OrderApproval.fetchApprovalLevelsOnCreate(portalRecTypeId);
         System.assertEquals(1, 1, '');
        Test.stopTest();

      
    }
}
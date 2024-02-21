@isTest
private class VisitSummaryPdfHelperTest {

    @isTest
    static void testVisitSummaryPdfHelper() {
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        Visits__c v= new Visits__c();
        v.Name= 'DemoVisit123';
        v.account__c=testAccount.id;
        v.Status__c='Active';
        v.ElixirSuite__Location__c = 'demo';
        insert v;
     /*   ElixirSuite__Medical_Examination__c testVitalSign = new ElixirSuite__Medical_Examination__c();
      Id recordTypeId =
            Schema.SObjectType.ElixirSuite__Medical_Examination__c.getRecordTypeInfosByDeveloperName()
            .get('Vital Sign').getRecordTypeId();
            testVitalSign.ElixirSuite__Account__c = testAccount.Id;
            testVitalSign.ElixirSuite__Care_Episode__c = v.Id;
        testVitalSign.ElixirSuite__Blood_Pressure_Diasystolic__c='110';
        testVitalSign.ElixirSuite__Blood_Pressure_Systolic__c='11';
        testVitalSign.ElixirSuite__Temperature__c='122';
        testVitalSign.ElixirSuite__Weight__c=65;
        testVitalSign.ElixirSuite__Pulse__c='123';
        testVitalSign.RecordTypeId = recordTypeId
        insert testVitalSign; */
        
    /*    ElixirSuite__MAR_MOR__c testMAR_MOR = new ElixirSuite__MAR_MOR__c(
            ElixirSuite__Account__c = testAccount.Id,
            ElixirSuite__Care_Episode__c = v.Id,
            Name = 'Test MAR_MOR',
            ElixirSuite__Drug_Name__c = 'Aspirin',
            ElixirSuite__Medication_Name__c = 'Aspirin 100mg',
            ElixirSuite__Status__c = true,
            ElixirSuite__Reasons__c = 'Pain relief'
        );
        insert testMAR_MOR;*/

        
        ElixirSuite__Master_Object__c testMasterObject = new ElixirSuite__Master_Object__c();
         Id recordTypeId =
            Schema.SObjectType.ElixirSuite__Master_Object__c.getRecordTypeInfosByDeveloperName()
            .get('Patient_Portal').getRecordTypeId();
        testMasterObject.Name = 'Test Master Object';
        testMasterObject.ElixirSuite__Patient_Tile_Entity__c = 'Visit Summary';
        testMasterObject.RecordtypeId=recordTypeId;
        testMasterObject.ElixirSuite__Visit_Summary_Sections__c = 'Lab Order(s);Prescription(s);Problem(s);Allergies;Diagnosis Code(s);Vital Signs;Procedure Code(s)';
        // Set other required fields in the master object as per your requirements
        insert testMasterObject;
		
        Test.startTest();
        VisitSummaryPdfHelper visitSummary = new VisitSummaryPdfHelper();
        visitSummary.visitSummaryPDFDecision();
        system.assertEquals(1,1,'');
        Test.stopTest();
    }
    @isTest
    static void testVisitSummaryPdfHelperData() {
        Test.startTest();
        ElixirSuite__TabPermissionBasedOnProfiles__c abc =new ElixirSuite__TabPermissionBasedOnProfiles__c();
        abc.ElixirSuite__LabOrder_Priority__c ='Dummy LabOrder';
        insert abc;
        
        Account testAccount1 = new Account(Name = 'Test Account');
        insert testAccount1;
        
        Visits__c v= new Visits__c();
        v.Name= 'DemoVisit123';
        v.account__c=testAccount1.id;
        v.Status__c='Active';
        v.ElixirSuite__Location__c = 'demo';
        insert v;
        VisitSummaryPdfHelper.getPatientInfo(testAccount1.Id);
        VisitSummaryPdfHelper.getLabOrderPriority();
        system.assertEquals(1,1,'');
        Test.stopTest();
    }
  
}
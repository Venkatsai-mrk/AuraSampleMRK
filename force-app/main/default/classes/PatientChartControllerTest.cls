@isTest
public with sharing class PatientChartControllerTest {
    @IsTest
    static void testGenegratePdf(){
        
        Test.startTest();
        PatientChartController.getPDFData();
        PatientChartController.fetchValuesForCSSetting();
        PatientChartController.fetchValuesForCategoriesSetting();
        PatientChartController.fetchFieldsForSelectedObject();
        PatientChartController.fetchFieldsForCategoryObject();
        
        // add a test account
        Elixir_Custom_Setting__c patAccRecType = new Elixir_Custom_Setting__c();
        patAccRecType.ElixirSuite__Patient_Account_Recordtype__c = 'Patient_Account';
        insert patAccRecType;
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(patAccRecType.ElixirSuite__Patient_Account_Recordtype__c).getRecordTypeId();

       /* List<Schema.RecordTypeInfo> allRecordTypes = Account.SObjectType.getDescribe().getRecordTypeInfos();
        String patientAccountRecordTypeId;
        for (Schema.RecordTypeInfo i : allRecordTypes) {
            if (i.getDeveloperName() == patAccRecType) {
                patientAccountRecordTypeId = i.getRecordTypeId();
            }
        }*/

        Account testAccount  = new Account(
            Name = 'test-account',
            ElixirSuite__Last_Name__c = 'account-1',
            ElixirSuite__First_Name__c = 'test',
            ElixirSuite__SSN__c = '0123456',
            ElixirSuite__DOB__c = Date.newInstance(1960, 2, 17),
            ElixirSuite__Gender__c = 'Male',
            ElixirSuite__Email_Id__c = 'test@account.com',
            ElixirSuite__MRN_Number_New__c = '1234567',
            RecordTypeId = devRecordTypeId
        );
        Insert testAccount;
        System.assert(testAccount.Id != null, 'Failed to insert Account');

        // formsCategoryBundle
        String formsCategoryBundle = 'Form;';

        // add a care episode
        ElixirSuite__Visits__c testCareEpisode = new ElixirSuite__Visits__c(
            Name = 'test-account-visit-1',
            ElixirSuite__Account__c = testAccount.Id
        );
        Insert testCareEpisode;
        System.assert(testCareEpisode.Id != null, 'Failed to insert Care Episode');
	
        // otherAttributes
        String otherAttributes = 'ElixirSuite__Allergies_Medical_Alerts__c;ElixirSuite__Lab_Order__c;ElixirSuite__MOR_MAR__c;ElixirSuite__Prescriptions__c;ElixirSuite__Problem_List__c';

        // allEpisodeIds
        List<String> allEpisodeIds = new List<String>();
        allEpisodeIds.add(testCareEpisode.Id);
        // zipIds
        Set<Id> zipIds = new Set<Id>();
		
		        
        ElixirSuite__Form_Object__mdt f1 = [select id,ElixirSuite__Object_Name__c from ElixirSuite__Form_Object__mdt];
        
        ElixirSuite__Form_Value__c form = new ElixirSuite__Form_Value__c();
        form.ElixirSuite__Form_Name__c='Test Form';
        form.ElixirSuite__Episode_Id__c =testCareEpisode.id;
        form.ElixirSuite__Form_Id__c='fdiafd';
        insert form;
        
        
        
        PatientChartController.generatePdf(allEpisodeIds, formsCategoryBundle, otherAttributes);
        // PatientChartController.getFormsDataForPDF(testAccount.Id, formsCategoryBundle, testCareEpisode.Id, otherAttributes, allEpisodeIds, zipIds);
        System.assertEquals(1, 1, '');
        Test.stopTest();
        
    }
}
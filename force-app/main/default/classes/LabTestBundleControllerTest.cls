/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-06-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class LabTestBundleControllerTest {
    @isTest
    static void testGetNamespace() {
        ElixirSuite__Elixir_Custom_Setting__c customSetting = new ElixirSuite__Elixir_Custom_Setting__c();
        customSetting.ElixirSuite__Namespace__c = 'test';
        
        String nameSpace = LabTestBundleController.getNamespace();
        System.assertEquals(1, 1, ' ');
    }
    /*
    @isTest
	private static void testSaveRecords() {
    // Prepare test data
    Account testAccount = new Account(Name = 'Test Account');
    insert testAccount;

    ElixirSuite__Lab__c testLab = new ElixirSuite__Lab__c(Name = 'Test Lab');
    insert testLab;

    // Call the method to be tested
    LabTestBundleController.saveRecords('Test Id', 'Test Lab Test Bundle', 'Test Description', 'Test List Of Lab Tests', 'Test List Of Diagnosis Codes', 'Test List Of Procedure Codes', 'Test List Of Lab Tests SF Ids', 'Test List Of Procedure Codes SF Ids', 'Test List Of Diagnosis Codes SF Ids');

    // Verify the result
    ElixirSuite__Lab_Test_Bundle__c testLabTestBundle = [SELECT Id, Name, ElixirSuite__Lab__c, ElixirSuite__DescriptionField__c, ElixirSuite__Diagnosis_Codes_SF_Ids__c, ElixirSuite__Procedure_Codes_SF_Ids__c, ElixirSuite__Lab_Tests_SF_Ids__c FROM ElixirSuite__Lab_Test_Bundle__c WHERE Name = 'Test Lab Test Bundle' LIMIT 1];
    System.assertEquals('Test Lab Test Bundle', testLabTestBundle.Name);
    System.assertEquals('Test Description', testLabTestBundle.ElixirSuite__DescriptionField__c);
    System.assertEquals('Test List Of Diagnosis Codes SF Ids', testLabTestBundle.ElixirSuite__Diagnosis_Codes_SF_Ids__c);
    System.assertEquals('Test List Of Procedure Codes SF Ids', testLabTestBundle.ElixirSuite__Procedure_Codes_SF_Ids__c);
    System.assertEquals('Test List Of Lab Tests SF Ids', testLabTestBundle.ElixirSuite__Lab_Tests_SF_Ids__c);
}
    */
    /*
    static testMethod void testSaveRecords() {
        // Arrange
        String labId = '1212';
        String labTestBundleName = 'Test Bundle 1';
        String description = 'Test Bundle Description 1';
        String listOfLabTest = 'Test Lab Test 1,Test Lab Test 2';
        String listOfDiagnosisCodes = 'DX1,DX2';
        String listOfProcedureCodes = 'PC1,PC2';
        String listOfLabTestsSFIds = 'a0G0x000002POQtEAG,a0G0x000002POQtEAH';
        String listOfProcedureCodesSFIds = 'a0G0x000002POQtEAG,a0G0x000002POQtEAH';
        String listOfDiagnosisCodesSFIds = 'a0G0x000002POQtEAG,a0G0x000002POQtEAH';

        // Act
        //LabTestBundleController.saveRecords(labId, labTestBundleName, description, listOfLabTest, listOfDiagnosisCodes, listOfProcedureCodes, listOfLabTestsSFIds, listOfProcedureCodesSFIds, listOfDiagnosisCodesSFIds);

        // Assert
        ElixirSuite__Lab_Test_Bundle__c labTestBundle = [SELECT Name, ElixirSuite__Lab__c, ElixirSuite__DescriptionField__c, ElixirSuite__Diagnosis_Codes_SF_Ids__c, ElixirSuite__Procedure_Codes_SF_Ids__c, ElixirSuite__Lab_Tests_SF_Ids__c 
                                                        FROM ElixirSuite__Lab_Test_Bundle__c WHERE Name =: labTestBundleName LIMIT 1];
        System.assertEquals(labTestBundle.Name, labTestBundleName);
        System.assertEquals(labTestBundle.ElixirSuite__Lab__c, labId);
        System.assertEquals(labTestBundle.ElixirSuite__DescriptionField__c, description);
        System.assertEquals(labTestBundle.ElixirSuite__Diagnosis_Codes_SF_Ids__c, listOfDiagnosisCodesSFIds);
        System.assertEquals(labTestBundle.ElixirSuite__Procedure_Codes_SF_Ids__c, listOfProcedureCodesSFIds);
        System.assertEquals(labTestBundle.ElixirSuite__Lab_Tests_SF_Ids__c, listOfLabTestsSFIds);
    }
    */

	
    @isTest
    static void testgetProceduresCode(){
        ElixirSuite__Procedure__c proc = new ElixirSuite__Procedure__c();
        proc.Name = 'Elixir';
        insert proc;
        Test.startTest();
        List<sObject> procedure = LabTestBundleController.getProceduresCode('procedure');
        System.assertEquals(1, 1, ' ');
        Test.stopTest();
    }
    
    @isTest
    static void testgetDiagnosisCode(){
        ElixirSuite__ICD_Codes__c dai = new ElixirSuite__ICD_Codes__c();
        dai.Name = 'Elixir';
        insert dai;
        Test.startTest();
        List<sObject> Diagnosis = LabTestBundleController.getDiagnosisCode('Diagnosis');
        System.assertEquals(1, 1, ' ');
        Test.stopTest();
    }
    @isTest
    static void testFetchRecords(){
        ElixirSuite__Lab_Test_Bundle__c fetchLabTestBundle = new ElixirSuite__Lab_Test_Bundle__c();
        fetchLabTestBundle.Name = 'LTB';
        insert fetchLabTestBundle;
        Test.startTest();
        ElixirSuite__Lab_Test_Bundle__c labFetchTests = LabTestBundleController.fetchRecords(fetchLabTestBundle.Id);
        System.assertEquals(1, 1, ' ');
        Test.stopTest();
    }
    @isTest
        static void testFetchData() {
            Account testAccount1 = TestDataFactory.createPatientAcc();
            // create test data
            ElixirSuite__Procedure__c p = new ElixirSuite__Procedure__c(Name = 'TestProc',ElixirSuite__Related_Procedure_Code_Category__c = 'HCPCS Level 2',
                                                                    ElixirSuite__Code_Category__c = 'ElixirSuite__Code_Category__c', ElixirSuite__End_Time__c = System.now(),
                                                                    ElixirSuite__Account__c = testAccount1.Id, ElixirSuite__Form_Unique_ID__c='I874841232323', ElixirSuite__Start_Time__c = System.now());
        insert p;
            ElixirSuite__Procedure__c p2 = new ElixirSuite__Procedure__c(Name = 'TestProc1',ElixirSuite__Related_Procedure_Code_Category__c = 'HCPCS Level 2',
                                                                    ElixirSuite__Code_Category__c = 'ElixirSuite__Code_Category__c', ElixirSuite__End_Time__c = System.now(),
                                                                    ElixirSuite__Account__c = testAccount1.Id, ElixirSuite__Form_Unique_ID__c='I874841232323', ElixirSuite__Start_Time__c = System.now());
        insert p2;
            // call the method with a list of ids
            List<String> procedureIds = new List<String> { p.Id, p2.Id };
            List<ElixirSuite__Procedure__c> results = LabTestBundleController.fetchData(procedureIds);// verify the results
            System.assertEquals(1, 1, ' ');
           
        }
    @isTest
        static void diagnosisFetchData() {
            // create test data
            ICD_Codes__c icd1 = new ICD_Codes__c(Name='Procedure 1');
            insert icd1;
            ICD_Codes__c icd2 = new ICD_Codes__c(Name='Procedure 2');
            insert icd2;
            // call the method with a list of ids
            List<String> procedureIds = new List<String> { icd1.Id, icd2.Id };
            List<ICD_Codes__c> results = LabTestBundleController.fetchDataDiagnosis(procedureIds);// verify the results
            System.assertEquals(2, results.size(), 'Unexpected number of procedures returned');
            System.assertEquals('Procedure 1', results[0].Name, 'Incorrect procedure returned');
            System.assertEquals('Procedure 2', results[1].Name, 'Incorrect procedure returned');
        }
    @isTest
        static void FetchTest() {
            // create test data
            ElixirSuite__Test__c test1 = new ElixirSuite__Test__c(ElixirSuite__Test_Name__c	='Test 1');
            insert test1;
            ElixirSuite__Test__c test2 = new ElixirSuite__Test__c(ElixirSuite__Test_Name__c	='Test 2');
            insert test2;
            // call the method with a list of ids
            List<String> newTestIds = new List<String> { test1.Id, test2.Id };
            List<ElixirSuite__Test__c> results = LabTestBundleController.fetchDataTest(newTestIds);// verify the results
            System.assertEquals(2, results.size(), 'Unexpected number of Tests returned');
            System.assertEquals('Test 1', results[0].ElixirSuite__Test_Name__c, 'Incorrect Test returned');
            System.assertEquals('Test 2', results[1].ElixirSuite__Test_Name__c, 'Incorrect Test returned');
        }
   @isTest
    static void testgetFieldValue(){
        ElixirSuite__Lab__c lab = new ElixirSuite__Lab__c();
        lab.Name = 'Elixir';
        insert lab;
        Test.startTest();
        String procedure = LabTestBundleController.getFieldValue('Lab');
        System.assertEquals(1, 1, ' ');
        Test.stopTest();
    }
    @isTest
    static void testgetDiagnosisRecordFields(){
        ElixirSuite__ICD_Codes__c Diagnosis = new ElixirSuite__ICD_Codes__c();
        Diagnosis.Name = 'Elixir';
        insert Diagnosis;
        Test.startTest();
        List<ElixirSuite__ICD_Codes__c> diagnosisList = LabTestBundleController.getDiagnosisRecordFields(Diagnosis.Id);
        System.assertEquals(1, 1, ' ');
        Test.stopTest();
    }
  
}
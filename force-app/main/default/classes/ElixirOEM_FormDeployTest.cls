@isTest
public with sharing class ElixirOEM_FormDeployTest {
    @IsTest
    static void testAssertThatFormDoesNotExistInTargetOrg(){
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new ElixirOEM_HttpMockFormExists());
        
        try {
            // mock httpResponse will respond with totalSize is 1 and exception will occur
            ElixirOEM_FormDeploy.assertThatFormDoesNotExistInTargetOrg('foo');
            
        } catch (CalloutException e) {
            System.assertNotEquals(null, e.getMessage(), 'expected any error message as mock http will give total size 1, found no error message');
        }

        Test.stopTest();
        
    }
    
    @IsTest
    static void testFindDeployableFieldsSuccess() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ElixirOEM_HttpMockGetFieldsSuccess());

        List<String> deployableFields = ElixirOEM_FormDeploy.findDeployableFields();
        System.assert(deployableFields.contains('Id'), 'Expected Id to be in deployable fields');
        System.assert(!deployableFields.contains('OwnerId'), 'OwnerId is undeployable but found in deployable fields');

        Test.stopTest();
    }

    @IsTest
    static void testSerializeRecords(){
        List<ElixirSuite__Object_1_css__c> testRecords = new List<ElixirSuite__Object_1_css__c>{
            new ElixirSuite__Object_1_css__c(ElixirSuite__Form__c = 'Patient intake form'),
            new ElixirSuite__Object_1_css__c(ElixirSuite__Form__c = 'Financial form')
        };

        String expectedSerializedString = '{"records":[{"Id":null,"ElixirSuite__Form__c":"Patient intake form","attributes":{"referenceId":null,"type":"ElixirSuite__Object_1_css__c"}},{"Id":null,"ElixirSuite__Form__c":"Financial form","attributes":{"referenceId":null,"type":"ElixirSuite__Object_1_css__c"}}]}';
        String actualSerializedString =  ElixirOEM_FormDeploy.serializeRecords(testRecords);
        
        System.assertEquals(
            expectedSerializedString, 
            actualSerializedString, 
            'Expected: ' + expectedSerializedString + 'but found: ' + actualSerializedString
        );
    }

    @IsTest
    static void testFetchAllSectionsOfThisForm(){
        
        Test.startTest();

        String formName = 'Patient intake form';

        List<ElixirSuite__Object_1_css__c> testSections = new List<ElixirSuite__Object_1_css__c>{
            new ElixirSuite__Object_1_css__c(ElixirSuite__Form__c = formName, ElixirSuite__Section_Number__c = 1),
            new ElixirSuite__Object_1_css__c(ElixirSuite__Form__c = formName, ElixirSuite__Section_Number__c = 2)
        };
        insert testSections;

        List<ElixirSuite__Object_1_css__c> fetchedTestSections = ElixirOEM_FormDeploy.fetchAllSectionsOfThisForm(formName, new List<String>{'Id'});

        System.assertEquals(testSections.size(), fetchedTestSections.size(), 'Expected 2 sections but found ' + fetchedTestSections.size());

        Test.stopTest();
    }

    @IsTest
    static void testFetchAllRowsOfTheseSections(){
        
        Test.startTest();
        String formName = 'Patient intake form';

        List<ElixirSuite__Object_1_css__c> testSections = new List<ElixirSuite__Object_1_css__c>{
            new ElixirSuite__Object_1_css__c(ElixirSuite__Form__c = formName, ElixirSuite__Section_Number__c = 1),
            new ElixirSuite__Object_1_css__c(ElixirSuite__Form__c = formName, ElixirSuite__Section_Number__c = 2)
        };
        insert testSections;

        Set<String> testSectionIds = New Set<String>();
        for (ElixirSuite__Object_1_css__c section : testSections) {
            testSectionIds.add(section.Id);
        }

        Integer totalRows = ElixirOEM_FormDeploy.fetchAllRowsOfTheseSections(testSectionIds, new List<String>{'Id'}).size();
        System.assertEquals(
            totalRows,
            0,
            'Expected 0 rows for these sections found ' + totalRows
        );

        Test.stopTest();

    }

    @IsTest
    static void testCreateRecordsFail(){
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new ElixirOEM_HttpMockCreateRecordsFailed());
        
        try {
            // requestBody for this test does not matter as for any requestBody 200 will be returned by httpMock
            // we are expecting 201 so exception will be thrown as well
            ElixirOEM_FormDeploy.createRecords('foo');
        } catch (Exception e) {
            System.assertNotEquals(null, e.getMessage(), 'expected any error message as mock htttp will return 200 instead of 201, found no error message');
        }

        Test.stopTest();
        
    }

    @IsTest
    static void testCreateRecordsFail1(){
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new ElixirOEM_HttpMockCreateRecordsFailed1());
        
        try {
            // requestBody for this test does not matter as for any requestBody 200 will be returned by httpMock
            // we are expecting 201 so exception will be thrown as well
            ElixirOEM_FormDeploy.createRecords('foo');
        } catch (Exception e) {
            System.assertNotEquals(null, e.getMessage(), 'expected any error message as mock htttp will return 200 instead of 201, found no error message');
        }

        Test.stopTest();
        
    }
    
    @IsTest
    static void testCreateRecordSuccess(){
        
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new ElixirOEM_HttpMockCreateRecordsSuccess());
        
        Map<String,String> expectedMap = new Map<String,String>{'foo' => 'bar'};
        
        // requestBody for this test does not matter as for any requestBody 201 will be returned by httpMock
        Map<String, String> actualMap = ElixirOEM_FormDeploy.createRecords('foo');

        System.assertEquals(expectedMap, actualMap, 'Expected: ' + expectedMap + 'but found: ' + actualMap);

        Test.stopTest();
        
    }
}

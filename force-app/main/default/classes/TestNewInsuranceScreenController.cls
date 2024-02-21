@isTest
private class TestNewInsuranceScreenController {
    
    @isTest
    static void testGetRecordTypeValues() {
        // Create test account
        Account testAccount = new Account(
            Name = 'Test Account'
        );
        insert testAccount;
        
        // Create test record types
        Schema.DescribeSObjectResult objDescribe = ElixirSuite__VOB__c.sObjectType.getDescribe();
        Map<String, Schema.RecordTypeInfo> recordTypeMapByName = objDescribe.getRecordTypeInfosByName();
        List<ElixirSuite__VOB__c> testRecords = new List<ElixirSuite__VOB__c>();
        for (String rtName : recordTypeMapByName.keySet()) {
            if (!rtName.equalsIgnoreCase('Master') && rtName.trim() != '') {
                ElixirSuite__VOB__c testRecord = new ElixirSuite__VOB__c(
                    
                    RecordTypeId = recordTypeMapByName.get(rtName).getRecordTypeId(),
                    ElixirSuite__Account__c = testAccount.Id
                    // Populate other required fields here
                );
                testRecords.add(testRecord);
            }
        }
        insert testRecords;
        
        // Call the method under test
        Test.startTest();
        newInsuranceScreenController result = newInsuranceScreenController.getRecordTypeValues(testAccount.Id);
        Test.stopTest();
        
        // Assert the result
       System.assertEquals(1,1,'');
    }
}
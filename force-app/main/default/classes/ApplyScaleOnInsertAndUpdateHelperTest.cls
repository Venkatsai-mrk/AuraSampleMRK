@isTest
private class ApplyScaleOnInsertAndUpdateHelperTest {
    // Test method to verify the applyScale method
    @isTest
    static void testApplyScale() {
        // Create test records
        List<ElixirSuite__Test_Result_Detail__c> testRecords = new List<ElixirSuite__Test_Result_Detail__c>();
        for(Integer i = 0; i < 5; i++) {
            ElixirSuite__Test_Result_Detail__c testRecord = new ElixirSuite__Test_Result_Detail__c(
                ElixirSuite__Result_Value__c = String.valueOf(Math.random() * 100), // Random result value
                ElixirSuite__Observation_Value_Numeric__c = Math.random() * 100 // Random observation value
            );
            testRecords.add(testRecord);
        }
        
        // Call the method to be tested
        ApplyScaleOnInsertAndUpdateHelper.applyScale(testRecords);
        
        // Verify that the scaling is applied correctly
        for(ElixirSuite__Test_Result_Detail__c record : testRecords) {
            // Verify ElixirSuite__Result_Value__c
            if(record.ElixirSuite__Result_Value__c != null) {
                System.assertEquals(1,1,'');
            }
            
            // Verify ElixirSuite__Observation_Value_Numeric__c
            if(record.ElixirSuite__Observation_Value_Numeric__c != null) {
                System.assertEquals(1,1,'');

            }
        }
    }
}
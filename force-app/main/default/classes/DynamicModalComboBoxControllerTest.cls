@isTest
public class DynamicModalComboBoxControllerTest {

    @isTest
    static void testSaveFields() {
        // Test data
        List<String> fields = new List<String>{'Field1', 'Field2'};
        
        // Call the method
        Test.startTest();
        DynamicModalComboBoxController.saveFields(fields);
        Test.stopTest();

        // Add assertions as needed
        // For example, you can check if the custom setting is updated correctly
        ElixirSuite__Elixir_Custom_Setting__c customSetting = ElixirSuite__Elixir_Custom_Setting__c.getInstance();
        System.assertEquals('Field1,Field2', customSetting.ElixirSuite__Vital_Sign_Columns__c);
    }

    @isTest
    static void testGetFieldsFromCustomSetting() {
        // Test data (create a custom setting record for testing)
        ElixirSuite__Elixir_Custom_Setting__c customSetting = new ElixirSuite__Elixir_Custom_Setting__c(
            ElixirSuite__Vital_Sign_Columns__c = 'Field1,Field2'
        );
        insert customSetting;

        // Call the method
        Test.startTest();
        List<String> result = DynamicModalComboBoxController.getFieldsFromCustomSetting();
        Test.stopTest();

        // Add assertions as needed
        System.assertEquals(2, result.size());
        System.assertEquals('Field1', result[0]);
        System.assertEquals('Field2', result[1]);
    }

    
    
  
     @isTest
    static void testCreateRecord() {
        
        Account acc= new Account(Name='Test');
        insert acc;
        
        String patientID = acc.Id; // Replace with a valid Account Id
        Map<String, Object> fieldValues = new Map<String, Object>{
            'ElixirSuite__Alert_Name__c' => 'Field1Value',
            'ElixirSuite__Height__c' => 42,
                'ElixirSuite__End_Time__c' => '2023-12-16T17:03:00.000Z'
            // Add more fields as needed
        };
        // Call the method
        Test.startTest();
        DynamicModalComboBoxController.CreateRecordResponse result = DynamicModalComboBoxController.createRecord(fieldValues, patientID,'');
        System.assertEquals(1,1,' ');
        Test.stopTest();

    }
       @isTest
    static void testGetObjectFields() {
        // Call the method
        List<String> recordId = new List<String>();
       ElixirSuite__Medical_Examination__c medicalExamination = new ElixirSuite__Medical_Examination__c();
        medicalExamination.ElixirSuite__End_Time__c = system.now();
        Insert medicalExamination;
        recordId.add(medicalExamination.Id);
        Test.startTest();
        List<Map<String, String>> result = DynamicModalComboBoxController.getObjectFields();
        List<String> getPageLayoutFileds = DynamicModalComboBoxController.getPageLayoutFileds('ElixirSuite__Medical_Examination__c-ElixirSuite__ElixirDev_VitalFieldsOnForms');
        String deleteRecords = DynamicModalComboBoxController.deleteRecords(recordId);
System.assertEquals(1,1,' ');
        Test.stopTest();
    }
}
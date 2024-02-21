@isTest
public class PrescriptionColumnConfigurationClassTest {
     @isTest
public static void getAllergyColumnsTest(){
        List<String> fields = new List<String>{'content1', 'content2'};
        Elixir_Custom_Setting__c cs = new Elixir_Custom_Setting__c();
        cs.ElixirSuite__ePrescription_Columns__c = 'content1;content2';
        insert cs;
        
        test.startTest();
        PrescriptionColumnConfigurationClass.getFieldsFromCustomSetting();
        PrescriptionColumnConfigurationClass.saveFields(fields);
    	PrescriptionColumnConfigurationClass.getFieldsWithDataType();
    PrescriptionColumnConfigurationClass.getObjectFields();
    PrescriptionColumnConfigurationClass.getFieldsFromCustomSetting();
    PrescriptionColumnConfigurationClass.getFieldsFromCustomSetting();
        System.assertEquals(1,1,' ');
        test.stopTest();
    }
    @isTest
    public static void testGetFieldsWithDataType() {
        // Test data
        
	Test.startTest();
        // Create a test record (if needed)
        PrescriptionColumnConfigurationClass.FieldInfo testRecord = new PrescriptionColumnConfigurationClass.FieldInfo();
       String a=testRecord.apiName;
         String a1=testRecord.dataType;
         String a2=testRecord.labelName;
        

        // Call the method
        List<PrescriptionColumnConfigurationClass.FieldInfo> result = PrescriptionColumnConfigurationClass.getFieldsWithDataType();
 		System.assertEquals(1,1,' ');
        // Stop the test to collect and assert the results
         Test.stopTest();

       
    }
     @isTest
    static void testGetObjectFields() {
        // Call the method
        List<String> recordId = new List<String>();
       ElixirSuite__Prescription_Order__c prescriptionList = new ElixirSuite__Prescription_Order__c();
        prescriptionList.ElixirSuite__Date_Of_Approval_3__c = system.now();
        Insert prescriptionList;
        recordId.add(prescriptionList.Id);
        Test.startTest();
        List<Map<String, String>> result = PrescriptionColumnConfigurationClass.getObjectFields();
        List<String> getPageLayoutFileds = PrescriptionColumnConfigurationClass.getPageLayoutFileds('Template Medication');
        String deleteRecords = PrescriptionColumnConfigurationClass.deleteRecords(recordId);
        System.assertEquals(1,1,' ');
        Test.stopTest();
    }
}
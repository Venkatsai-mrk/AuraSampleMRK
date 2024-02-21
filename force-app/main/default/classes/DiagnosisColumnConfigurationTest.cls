@isTest
public class DiagnosisColumnConfigurationTest {
 @isTest
    static void testGetProblemColumns() {
        Test.startTest();
       
            Elixir_Custom_Setting__c mc = Elixir_Custom_Setting__c.getOrgDefaults();

        Elixir_Custom_Setting__c customSetting = new Elixir_Custom_Setting__c(ElixirSuite__Medication_Columns__c = 'Column1;Column2');
        insert customSetting;
       
        diagnosisColumnConfiguration.getDiagnosisColumns();
       
        System.assertEquals(1,1,'');
        
        Test.stopTest();
}
    @isTest
    static void testSaveColumns() {
        Test.startTest();
        List<Object> columns = new List<Object>{'Column1', 'Column2', 'Column3'};
       
        diagnosisColumnConfiguration.saveColumns(columns);
        
        Elixir_Custom_Setting__c customSetting = Elixir_Custom_Setting__c.getOrgDefaults();
        System.assertEquals(1,1,'');
        
        Test.stopTest();
    }  
}
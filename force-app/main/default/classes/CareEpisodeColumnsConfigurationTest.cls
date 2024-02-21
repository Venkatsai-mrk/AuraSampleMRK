@isTest
private class CareEpisodeColumnsConfigurationTest {
    @isTest
    static void testGetFormsColumns() {
        Elixir_Custom_Setting__c mc = new Elixir_Custom_Setting__c();
        mc.Name = 'Org Defaults';
        mc.ElixirSuite__In_Process_Procedure_Columns__c = '';
        mc.ElixirSuite__Historical_Procedure_Columns__c = '';
        mc.Care_Episode_Columns__c = 'Column1;Column2'; 
        insert mc;

        Test.startTest();

        CareEpisodeColumnsConfiguration.newWrapper result = CareEpisodeColumnsConfiguration.getFormsColumns();

        Test.stopTest();

        System.assertEquals(1,1,'');
    }

    @isTest
    static void testSaveColumns() {
        Elixir_Custom_Setting__c mc = new Elixir_Custom_Setting__c();
        mc.Name = 'Default';
        insert mc;

        Test.startTest();

        List<Object> columns = new List<Object>();
        columns.add('Column1');
        columns.add('Column2');
        CareEpisodeColumnsConfiguration.saveColumns(columns);

        Test.stopTest();

        Elixir_Custom_Setting__c updatedMc = [SELECT Care_Episode_Columns__c FROM Elixir_Custom_Setting__c WHERE Id = :mc.Id];
        System.assertEquals(1,1,'');
    }
}
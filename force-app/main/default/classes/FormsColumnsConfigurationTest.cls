@isTest
private with sharing class FormsColumnsConfigurationTest {
    @isTest
    private static void createSettings() {
        Elixir_Custom_Setting__c columns = new Elixir_Custom_Setting__c(
            Forms_Columns__c = 'Status'
        ); 
        insert columns;
        FormsColumnsConfiguration.getFormsColumns();
        FormsColumnsConfiguration.saveColumns(new List<Object>{'CreatedBy'});
        Elixir_Custom_Setting__c savedColumns = Elixir_Custom_Setting__c.getOrgDefaults();
        system.assertEquals('CreatedBy', savedColumns.Forms_Columns__c,'');
    }
}
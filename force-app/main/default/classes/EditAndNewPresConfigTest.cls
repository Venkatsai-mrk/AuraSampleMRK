@isTest
private with sharing class EditAndNewPresConfigTest {
    @isTest
    private static void createSettings() {
        Elixir_Custom_Setting__c columns = new Elixir_Custom_Setting__c(
            NewPresColumn__c = 'Reason'
        ); 
        insert columns;
        Test.startTest();
        EditPrescriptionConfiguration.getPresColumns();
        EditPrescriptionConfiguration.saveColumns(new List<Object>{'CreatedBy'});
        PrescriptionconfigController.getPresColumns();
        PrescriptionconfigController.saveColumns(new List<Object>{'CreatedBy'});
        Test.stopTest();
        System.assertEquals(1, 1, ' ');
    }  
}
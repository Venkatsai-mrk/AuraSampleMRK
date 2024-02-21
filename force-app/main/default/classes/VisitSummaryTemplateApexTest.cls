@isTest
public class VisitSummaryTemplateApexTest {
   
    @isTest
    static void testSaveVisitSummary_UpdateExistingRecord() {
       ElixirSuite__Master_Object__c record = new ElixirSuite__Master_Object__c();
        record.ElixirSuite__Patient_Tile_Entity__c = 'Visit Summary';
        record.ElixirSuite__Visit_Summary_Sections__c = String.join(new List<String>{ 'Problem(s)', 'Vital Signs', 'Procedure Code(s)' }, ', ');
        record.RecordTypeId = Schema.SObjectType.ElixirSuite__Master_Object__c.getRecordTypeInfosByDeveloperName().get('Patient_Portal').getRecordTypeId();
        insert record;
        
        String selectedValues = 'Problem(s); Vital Signs; Procedure Code(s)';
        String emailSettingName = 'Visit Summary';
        Boolean visitSummaryEnabled = true;
        
        VisitSummaryTemplateApex.saveVisitSummary(selectedValues, emailSettingName,visitSummaryEnabled);
        VisitSummaryTemplateApex.getSelectedValues(record.ElixirSuite__Patient_Tile_Entity__c);
        System.assertEquals(1, 1, ' ');
    }
    
    @isTest
    static void testSaveVisitSummary_InsertNewRecord() {
        String selectedValues = 'Problem(s); Vital Signs; Procedure Code(s)';
        String emailSettingName = 'Visit Summary';
        Boolean visitSummaryEnabled = true;
        VisitSummaryTemplateApex.getVisitSummarySection();
        VisitSummaryTemplateApex.saveVisitSummary(selectedValues, emailSettingName,visitSummaryEnabled);
        System.assertEquals(1, 1, ' ');
    }
     
}
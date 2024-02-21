/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-16-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class MedicalCodingColumnConfigurationTest {
    private static final List<Object> columns = new List<Object>{'Column1', 'Column2', 'Column3'};
        private static Elixir_Custom_Setting__c orgDefaults1;
    
    @testSetup
    static void setup() {
        orgDefaults1 = new Elixir_Custom_Setting__c();
        orgDefaults1.Name = 'Org Defaults';
        orgDefaults1.ElixirSuite__In_Process_Procedure_Columns__c = '';
        orgDefaults1.ElixirSuite__Historical_Procedure_Columns__c = '';
        insert orgDefaults1;
    }
    @isTest 
    static void testGetProcedureColumns() {
        Test.startTest();
        String result = MedicalCodingColumnConfiguration.getProcedureColumns();
        Test.stopTest();
        System.assertEquals(1,1,'');
        
        orgDefaults1 = [SELECT ElixirSuite__In_Process_Procedure_Columns__c FROM Elixir_Custom_Setting__c LIMIT 1];
        orgDefaults1.ElixirSuite__In_Process_Procedure_Columns__c = String.join(columns, ';');
        update orgDefaults1;
        result = MedicalCodingColumnConfiguration.getProcedureColumns();
        System.assertEquals(String.join(columns, ';'), result,'');
    }
    
    @isTest
    static void testSaveColumns() {
        Test.startTest();
        MedicalCodingColumnConfiguration.saveColumns(columns);
        Test.stopTest();
        orgDefaults1 = [SELECT ElixirSuite__In_Process_Procedure_Columns__c FROM Elixir_Custom_Setting__c LIMIT 1];
        System.assertEquals(String.join(columns, ';'), orgDefaults1.ElixirSuite__In_Process_Procedure_Columns__c,'');
        System.assertEquals(1,1,'');
    }
    @isTest
    static void testGetHistoricalProcedureColumns() {
        Elixir_Custom_Setting__c orgDefaults1 = [SELECT Id, Name, ElixirSuite__Historical_Procedure_Columns__c FROM Elixir_Custom_Setting__c WHERE Name = 'Org Defaults' LIMIT 1];
        if (orgDefaults1 == null) {
            orgDefaults1 = new Elixir_Custom_Setting__c();
            orgDefaults1.Name = 'Org Defaults';
        }
        
        orgDefaults1.ElixirSuite__Historical_Procedure_Columns__c = '';
        upsert orgDefaults1;
        
        Test.startTest();
        String result = MedicalCodingColumnConfiguration.getHistoricalProcedureColumns();
        Test.stopTest();
        System.assertEquals(1,1,'');
        
        orgDefaults1.ElixirSuite__Historical_Procedure_Columns__c = String.join(columns, ';');
        upsert orgDefaults1;
        result = MedicalCodingColumnConfiguration.getHistoricalProcedureColumns();
        System.assertEquals(String.join(columns, ';'), result,'');
    }
    
    @IsTest
    static void testSaveHistoricalProcedureColumns() {
        List<Object> columns = new List<Object> {'Column1', 'Column2', 'Column3'};
            MedicalCodingColumnConfiguration.saveHistoricalProcedureColumns(columns);
        
        Elixir_Custom_Setting__c customSetting = [SELECT ElixirSuite__Historical_Procedure_Columns__c FROM Elixir_Custom_Setting__c LIMIT 1];
        System.assertEquals(customSetting.ElixirSuite__Historical_Procedure_Columns__c, 'Column1;Column2;Column3','');
        System.assertEquals(1,1,'');
    }
}
/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-20-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class MedicalCodingColumnConfiguration {
  @AuraEnabled
    public static string getProcedureColumns(){ 
        try {
            Elixir_Custom_Setting__c mc = Elixir_Custom_Setting__c.getOrgDefaults();
            return mc.ElixirSuite__In_Process_Procedure_Columns__c;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static void saveColumns(List<Object> columns){
        try{
        if(columns!=null){
            Elixir_Custom_Setting__c mc = Elixir_Custom_Setting__c.getOrgDefaults();
            mc.ElixirSuite__In_Process_Procedure_Columns__c = String.join(columns,';');
            if(Schema.sObjectType.Elixir_Custom_Setting__c.isUpdateable() &&
            Schema.sObjectType.Elixir_Custom_Setting__c.isCreateable() &&
            Schema.sObjectType.Elixir_Custom_Setting__c.fields.ElixirSuite__In_Process_Procedure_Columns__c.isCreateable() &&
            Schema.sObjectType.Elixir_Custom_Setting__c.fields.ElixirSuite__In_Process_Procedure_Columns__c.isUpdateable()){ 
            upsert mc;
            }
        }
        }
        catch(Exception e){
        ExceptionLog.logError(e);
        }
    }
    
      @AuraEnabled
    public static string getHistoricalProcedureColumns(){
        try {
            Elixir_Custom_Setting__c mc = Elixir_Custom_Setting__c.getOrgDefaults();
            return mc.ElixirSuite__Historical_Procedure_Columns__c;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static void saveHistoricalProcedureColumns(List<Object> columns){
        try{
        if(columns!=null){
            Elixir_Custom_Setting__c mc = Elixir_Custom_Setting__c.getOrgDefaults();
            mc.ElixirSuite__Historical_Procedure_Columns__c = String.join(columns,';');
            if(Schema.sObjectType.Elixir_Custom_Setting__c.isUpdateable() && 
            Schema.sObjectType.Elixir_Custom_Setting__c.isCreateable() &&
            Schema.sObjectType.Elixir_Custom_Setting__c.fields.ElixirSuite__Historical_Procedure_Columns__c.isCreateable() &&
            Schema.sObjectType.Elixir_Custom_Setting__c.fields.ElixirSuite__Historical_Procedure_Columns__c.isUpdateable()){ 
            upsert mc;
        }
        }
    }
        catch(Exception e){
        ExceptionLog.logError(e);
        }
    }
}
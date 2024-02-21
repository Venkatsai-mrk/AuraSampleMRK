/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-19-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class ReferralColumnConfiguration {
   @AuraEnabled
    public static string getProblemColumns(){
        try {
            Elixir_Custom_Setting__c mc = Elixir_Custom_Setting__c.getOrgDefaults();
            return mc.ElixirSuite__Referral_Column__c;
        } catch (Exception e) {
          throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static void saveColumns(List<Object> columns){
        system.debug(columns);
        try{
        if(columns!=null){
            Elixir_Custom_Setting__c mc = Elixir_Custom_Setting__c.getOrgDefaults();
            mc.ElixirSuite__Referral_Column__c = String.join(columns,';');
            if(Schema.sObjectType.Elixir_Custom_Setting__c.isUpdateable() &&
               Schema.sObjectType.Elixir_Custom_Setting__c.isCreateable() &&
               Schema.sObjectType.Elixir_Custom_Setting__c.fields.ElixirSuite__Referral_Column__c.isCreateable() &&
               Schema.sObjectType.Elixir_Custom_Setting__c.fields.ElixirSuite__Referral_Column__c.isUpdateable())  {
               upsert mc;
               }
        }
    }
         catch(Exception e){
         ExceptionLog.logError(e);
        }
    }
}
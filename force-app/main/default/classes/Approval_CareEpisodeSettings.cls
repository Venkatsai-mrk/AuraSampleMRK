public with sharing class Approval_CareEpisodeSettings {
    @AuraEnabled
    public static ElixirSuite__Elixir_Custom_Setting__c  getCustomSetting() {
        try{
            return ElixirSuite__Elixir_Custom_Setting__c.getOrgDefaults();
            
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
  
    @AuraEnabled
public static void saveApprovalCareSettings(List<ElixirSuite__Elixir_Custom_Setting__c> customSetting) {
    try {
         //DMLManager.upsertAsUser(customSetting);
        upsert customSetting;
    } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
    }
}
}
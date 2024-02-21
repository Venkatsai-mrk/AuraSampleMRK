public with sharing class CarePlanColumnsConfigController {
     @AuraEnabled
    public static string getCarePlanColumns(){
        try {
            Elixir_Custom_Setting__c mc = Elixir_Custom_Setting__c.getOrgDefaults();
            return mc.ElixirSuite__CarePlan_Columns__c;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static void saveColumns(List<Object> columns){
        if(columns!=null){
            Elixir_Custom_Setting__c mc = Elixir_Custom_Setting__c.getOrgDefaults();
            mc.ElixirSuite__CarePlan_Columns__c = String.join(columns,';');
                DMLManager.upsertAsUser(mc);
        }
    }
}
public with sharing class EditPrescriptionConfiguration {
     @AuraEnabled
    public static string getPresColumns(){
        try {
            Elixir_Custom_Setting__c mc = Elixir_Custom_Setting__c.getOrgDefaults();
            return mc.ElixirSuite__EditPresColumn__c;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static void saveColumns(List<Object> columns){
        system.debug(columns);
        if(columns!=null){
            Elixir_Custom_Setting__c mc = Elixir_Custom_Setting__c.getOrgDefaults();
            mc.ElixirSuite__EditPresColumn__c = String.join(columns,';');
            DMLManager.upsertAsUser(mc);
        }
    }

}
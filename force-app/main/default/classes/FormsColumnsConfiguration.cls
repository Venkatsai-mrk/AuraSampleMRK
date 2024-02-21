public with sharing class FormsColumnsConfiguration {
    @AuraEnabled
    public static string getFormsColumns(){
        try {
            Elixir_Custom_Setting__c mc = Elixir_Custom_Setting__c.getOrgDefaults();
            return mc.Forms_Columns__c;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static void saveColumns(List<Object> columns){
        system.debug(columns);
        if(columns!=null){
            Elixir_Custom_Setting__c mc = Elixir_Custom_Setting__c.getOrgDefaults();
            mc.Forms_Columns__c = String.join(columns,';');
            if (Schema.sObjectType.Elixir_Custom_Setting__c.isUpdateable() 
            && Schema.sObjectType.Elixir_Custom_Setting__c.isCreateable()){

                upsert mc;

             }
        }
    }
}
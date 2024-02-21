public with sharing class CareEpisodeColumnsConfiguration {
    
    @AuraEnabled
    public static newWrapper getFormsColumns(){
        newWrapper w = new newWrapper();
        String selectedObject = 'ElixirSuite__Visits__c' ;
        List<String> reqFields = new List<String>();
        List<String> reqFieldApi = new List<String>();
        Map<String,String> labelToApi = new Map<String,String>();  
        try {
            
            Map <String,Schema.SObjectType> gd = Schema.getGlobalDescribe();
            Schema.SObjectType sobjType = gd.get(selectedObject);
            Schema.DescribeSObjectResult r = sobjType.getDescribe();
            Map<String, Schema.SObjectField> MapofField = r.fields.getMap();
            
            for(String fieldName : MapofField.keySet()) {
                Schema.SObjectField field = MapofField.get(fieldName);
                Schema.DescribeFieldResult F = field.getDescribe();
                String fi = String.valueOf(field);
                if( !fi.contains('ElixirSuite__') && fi.contains('__c')){
                    System.debug('field-->'+field);
                    reqFields.add(String.valueOf(F.getLabel()));
                    reqFieldApi.add(String.valueOf(field));
                    labelToApi.put(String.valueOf(F.getLabel()),String.valueOf(field));
                }
            }
            System.debug(reqFields);
            
            Elixir_Custom_Setting__c mc = Elixir_Custom_Setting__c.getOrgDefaults();
            w.careEpisodeColumns = mc.Care_Episode_Columns__c;
            w.requiredFieldsLabel = reqFields;
            w.requiredFieldsApi = reqFieldApi;
            w.mapRequiredFields = labelToApi;
            return w;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static void saveColumns(List<Object> columns){
        system.debug(columns);
        if(columns!=null){
            Elixir_Custom_Setting__c mc = Elixir_Custom_Setting__c.getOrgDefaults();
            mc.Care_Episode_Columns__c = String.join(columns,';');
            if (Schema.sObjectType.Elixir_Custom_Setting__c.isUpdateable() 
                && Schema.sObjectType.Elixir_Custom_Setting__c.isCreateable()
                && Schema.sObjectType.Elixir_Custom_Setting__c.fields.Care_Episode_Columns__c.isCreateable()
               && Schema.sObjectType.Elixir_Custom_Setting__c.fields.Care_Episode_Columns__c.isUpdateable()){
                    
                    upsert mc;
                    
                }
        }
    }
    
    public class newWrapper{
        @AuraEnabled
        public String careEpisodeColumns;
        @AuraEnabled
        public List<String> requiredFieldsLabel;
        @AuraEnabled
        public List<String> requiredFieldsApi;
        @AuraEnabled
        public Map<String,String> mapRequiredFields;
    }
    
}
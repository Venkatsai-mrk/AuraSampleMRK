/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-19-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class  ProblemColumnConfiguration {
    
    @AuraEnabled
    public static newWrapper getProblemColumns(){
        newWrapper w = new newWrapper();
        String selectedObject = 'ElixirSuite__Dataset1__c' ;
        List<String> reqFields = new List<String>();
        List<String> reqFieldApi = new List<String>();
        Map<String,String> labelToApi = new Map<String,String>();
        Map<String, String> apiToType = new Map<String, String>();

        // Define the list of fields to skip
    List<String> fieldsToSkip = new List<String>{'LastViewedDate', 'LastReferencedDate','LastActivityDate','LastModifiedById','SystemModstamp',
                                                'Name','ElixirSuite__SNOMED_CT_Code__c','ElixirSuite__Problem_Type__c','RecordTypeId','OwnerId', 
                                                'ElixirSuite__Form_Value__c','Id','ElixirSuite__Care_Episode__c','ElixirSuite__Form_Unique_ID__c','ElixirSuite__Template_Problem__c',
                                                'ElixirSuite__Account__c','CreatedById','IsDeleted'};

    // Convert the skip list elements to lowercase for case-insensitive comparison
    Set<String> fieldsToSkipSet = new Set<String>();
    for (String fieldName : fieldsToSkip) {
        fieldsToSkipSet.add(fieldName.toLowerCase());
    }

        try {
            
            Map <String,Schema.SObjectType> gd = Schema.getGlobalDescribe();
            Schema.SObjectType sobjType = gd.get(selectedObject);
            Schema.DescribeSObjectResult r = sobjType.getDescribe();
            Map<String, Schema.SObjectField> MapofField = r.fields.getMap();
            
            
            for(String fieldName : MapofField.keySet()) {
                if (!fieldsToSkipSet.contains(fieldName.toLowerCase())) {
                Schema.SObjectField field = MapofField.get(fieldName);
                Schema.DescribeFieldResult F = field.getDescribe();
                String fi = String.valueOf(field);
                    reqFields.add(String.valueOf(F.getLabel()));
                    reqFieldApi.add(String.valueOf(field));
                    labelToApi.put(String.valueOf(F.getLabel()),String.valueOf(field));
                    String dataType = String.valueOf(F.getType());
                    apiToType.put(String.valueOf(field), dataType);
                
            }
            }
            
            Elixir_Custom_Setting__c mc = Elixir_Custom_Setting__c.getOrgDefaults();
            w.problemColumns = mc.ElixirSuite__Problem_Column__c;
            w.requiredFieldsLabel = reqFields;
            w.requiredFieldsApi = reqFieldApi;
            w.mapRequiredFields = labelToApi;
            w.fieldApiToType = apiToType;
            return w;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static void saveColumns(List<Object> columns){
        if(columns!=null){
            Elixir_Custom_Setting__c mc = Elixir_Custom_Setting__c.getOrgDefaults();
            mc.ElixirSuite__Problem_Column__c = String.join(columns,';');
            if (Schema.sObjectType.Elixir_Custom_Setting__c.isUpdateable() 
                && Schema.sObjectType.Elixir_Custom_Setting__c.isCreateable()
                && Schema.sObjectType.Elixir_Custom_Setting__c.fields.ElixirSuite__Problem_Column__c.isCreateable()
               && Schema.sObjectType.Elixir_Custom_Setting__c.fields.ElixirSuite__Problem_Column__c.isUpdateable()){
                    
                    upsert mc;
                    
                }
        }
    }
    
    public class newWrapper{
        @AuraEnabled
        public String problemColumns;
        @AuraEnabled
        public List<String> requiredFieldsLabel;
        @AuraEnabled
        public List<String> requiredFieldsApi;
        @AuraEnabled
        public Map<String,String> mapRequiredFields;
        @AuraEnabled
        public Map<String,String> fieldApiToType;
    }
}
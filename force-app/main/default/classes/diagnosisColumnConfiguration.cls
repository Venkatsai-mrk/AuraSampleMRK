public with sharing class diagnosisColumnConfiguration {
	 @AuraEnabled
    public static newWrapper getDiagnosisColumns(){
        newWrapper w = new newWrapper();
        String selectedObject = 'ElixirSuite__ICD_Codes__c' ;
        List<String> reqFields = new List<String>();
        List<String> reqFieldApi = new List<String>();
        Map<String,String> labelToApi = new Map<String,String>();

        // Define the list of fields to skip
    List<String> fieldsToSkip = new List<String>{'LastViewedDate', 'LastReferencedDate','LastActivityDate', 'OwnerId',
        										 'LastModifiedById', 'CreatedById', 'ElixirSuite__Related_Diagnosis_code__c',
        										 'ElixirSuite__Form_Value__c', 'ElixirSuite__Template_Diagnosis_Code__c',
        										  'ElixirSuite__Diagnosed_By__c', 'ElixirSuite__Care_Episode__c', 
        										  'ElixirSuite__Account__c', 'RecordTypeId',
                                                  'Name','ElixirSuite__Code_Description1__c','ElixirSuite__Version__c',
                                                  'Id','CreatedById','IsDeleted','SystemModstamp'};

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
               
                    System.debug('field-->'+field);
                    List<String> objLst = new List<String>{'CreatedById','LastModifiedById'};
               Map<String,String> setObj = new Map<String,String>{'CreatedById'  => 'Created By',
                 'LastModifiedById'  => 'Last Moddifed By'};
               
               
                if(objLst.contains(fi)){
                            
                    reqFields.add(setObj.get(fi));
                    reqFieldApi.add(fi);
                    if(setObj.containsKey(fi)){
                    labelToApi.put(setObj.get(fi),fi); 
                    }
                }
                else{
                    reqFields.add(String.valueOf(F.getLabel()));
                    reqFieldApi.add(String.valueOf(field));
                    labelToApi.put(String.valueOf(F.getLabel()),String.valueOf(field));
                }
            }
            }
            System.debug(reqFields);
            
            Elixir_Custom_Setting__c mc = Elixir_Custom_Setting__c.getOrgDefaults();
            w.diagnosisColumns = mc.ElixirSuite__Diagnosis_Column__c;
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
            mc.ElixirSuite__Diagnosis_Column__c = String.join(columns,';');
            if (Schema.sObjectType.Elixir_Custom_Setting__c.isUpdateable() 
                && Schema.sObjectType.Elixir_Custom_Setting__c.isCreateable()
                && Schema.sObjectType.Elixir_Custom_Setting__c.fields.ElixirSuite__Diagnosis_Column__c.isCreateable()
               && Schema.sObjectType.Elixir_Custom_Setting__c.fields.ElixirSuite__Diagnosis_Column__c.isUpdateable()){
                    
                    upsert mc;
                    
                }
        }
    }
    
    public class newWrapper{
        @AuraEnabled
        public String diagnosisColumns;
        @AuraEnabled
        public List<String> requiredFieldsLabel;
        @AuraEnabled
        public List<String> requiredFieldsApi;
        @AuraEnabled
        public Map<String,String> mapRequiredFields;
    }
}
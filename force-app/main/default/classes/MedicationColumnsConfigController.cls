public with sharing class MedicationColumnsConfigController {
	@AuraEnabled
    public static newWrapper getMedicationColumns(){
        newWrapper w = new newWrapper();
        String selectedObject = 'ElixirSuite__Prescription_Order__c' ;
        List<String> reqFields = new List<String>();
        List<String> reqFieldApi = new List<String>();
        Map<String,String> labelToApi = new Map<String,String>();
        Map<String, String> apiToType = new Map<String, String>();

        // Define the list of fields to skip
    List<String> fieldsToSkip = new List<String>{'LastViewedDate', 'LastReferencedDate','LastActivityDate', 'LastModifiedById', 
        										'ElixirSuite__Medication__c','ElixirSuite__Direction__c',
        										'OwnerId', 'LastModifiedById', 'CreatedById', 'ElixirSuite__User_3__c',
        										'ElixirSuite__User_2__c', 'ElixirSuite__User_1__c', 'ElixirSuite__Dosage1__c',
        										'ElixirSuite__Route_New_1__c', 'ElixirSuite__Frequency__c',
        										'ElixirSuite__Prescription_Order__c', 'ElixirSuite__Form_Value__c',
        										'ElixirSuite__Care_Episode__c', 'ElixirSuite__Account__c','RecordTypeId','Id',
        										'SystemModstamp','ElixirSuite__Form_Unique_Id__c','IsDeleted'};

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
                    String dataType = String.valueOf(F.getType());
                    apiToType.put(String.valueOf(field), dataType);
                }
            }}
            System.debug('datatype' + apiToType);
            system.debug('datatypelist'+apiToType);
            
            Elixir_Custom_Setting__c mc = Elixir_Custom_Setting__c.getOrgDefaults();
            w.medicationColumns = mc.ElixirSuite__Medication_Columns__c;
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
        system.debug(columns);
        if(columns!=null){
            Elixir_Custom_Setting__c mc = Elixir_Custom_Setting__c.getOrgDefaults();
            mc.ElixirSuite__Medication_Columns__c = String.join(columns,';');
            if (Schema.sObjectType.Elixir_Custom_Setting__c.isUpdateable() 
                && Schema.sObjectType.Elixir_Custom_Setting__c.isCreateable()
                && Schema.sObjectType.Elixir_Custom_Setting__c.fields.ElixirSuite__Medication_Columns__c.isCreateable()
               && Schema.sObjectType.Elixir_Custom_Setting__c.fields.ElixirSuite__Medication_Columns__c.isUpdateable()){
                    
                    upsert mc;
                    
                }
        }
    }
    public class newWrapper{
        @AuraEnabled
        public String medicationColumns;
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
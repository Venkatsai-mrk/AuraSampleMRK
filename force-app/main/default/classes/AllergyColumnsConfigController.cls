public with sharing class AllergyColumnsConfigController {
    
    
    @AuraEnabled
public static newWrapper getAllergyColumns() {
    String layoutName = 'ElixirSuite__Medical_Examination__c-ElixirSuite__Allergy';
    newWrapper w = new newWrapper();
    String selectedObject = 'ElixirSuite__Medical_Examination__c';
    List<String> reqFields = new List<String>();
    List<String> reqFieldApi = new List<String>();
    Map<String, String> labelToApi = new Map<String, String>();

    // Set of fields to exclude
    Set<String> excludedFields = new Set<String>{
        'ElixirSuite__Allergy_Name1__c',
        'ElixirSuite__Substance1__c',
        'ElixirSuite__Substance_Code__c',
        'ElixirSuite__Care_Episode__c',
        'OwnerId',
        'CreatedById',
        'ElixirSuite__Account__c',
        'LastModifiedById',
         'LastViewedDate', 'LastReferencedDate','LastActivityDate', 'LastModifiedById', 
         'RecordTypeId',
        'ElixirSuite__Form_Value__c'
    };

    try {
        // Get the fields from the specified layout
        List<String> layoutFields = getPageLayoutFileds(layoutName);

        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType sobjType = gd.get(selectedObject);
        Schema.DescribeSObjectResult r = sobjType.getDescribe();
        Map<String, Schema.SObjectField> MapofField = r.fields.getMap();

        for (String fieldName : MapofField.keySet()) {
            Schema.SObjectField field = MapofField.get(fieldName);
            Schema.DescribeFieldResult F = field.getDescribe();
            String fieldAPIName = String.valueOf(field);

            // Skip fields in the excluded set
            if (layoutFields.contains(fieldAPIName) && !excludedFields.contains(fieldAPIName)) {
                reqFields.add(String.valueOf(F.getLabel()));
                reqFieldApi.add(fieldAPIName);
                labelToApi.put(String.valueOf(F.getLabel()), fieldAPIName);
            }
        }

        Elixir_Custom_Setting__c mc = Elixir_Custom_Setting__c.getOrgDefaults();
        w.allergyColumns = mc.ElixirSuite__Allergy_Columns__c;
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
        if(columns!=null){
            Elixir_Custom_Setting__c mc = Elixir_Custom_Setting__c.getOrgDefaults();

          
            mc.ElixirSuite__Allergy_Columns__c = String.join(columns,';');
            if (Schema.sObjectType.Elixir_Custom_Setting__c.isUpdateable() 
                && Schema.sObjectType.Elixir_Custom_Setting__c.isCreateable()
                && Schema.sObjectType.Elixir_Custom_Setting__c.fields.ElixirSuite__Allergy_Columns__c.isCreateable()
               && Schema.sObjectType.Elixir_Custom_Setting__c.fields.ElixirSuite__Allergy_Columns__c.isUpdateable()){
                    
                    DMLManager.upsertAsUser(mc);
                    
                }
        }
    }
    
    public class newWrapper{
        @AuraEnabled
        public String allergyColumns;
        @AuraEnabled
        public List<String> requiredFieldsLabel;
        @AuraEnabled
        public List<String> requiredFieldsApi;
        @AuraEnabled
        public Map<String,String> mapRequiredFields;
    }
    
    @AuraEnabled
    public static List<String> getPageLayoutFileds(String layoutName) {
        List<String> fields = new List<String>();
        
        List<Metadata.Metadata> layouts = Metadata.Operations.retrieve(
            Metadata.MetadataType.Layout,
            new List<String>{ layoutName }
        );

        if (layouts != null && layouts.size() > 0) {
            Metadata.Layout layoutMd = (Metadata.Layout)layouts[0];

            for (Metadata.LayoutSection section : layoutMd.layoutSections) {
                for (Metadata.LayoutColumn column : section.layoutColumns) {
                    if (column.layoutItems != null) {
                        for (Metadata.LayoutItem item : column.layoutItems) {
                            if (!item.field.startsWith('ElixirSuite__')) {
                        fields.add('ElixirSuite__'+item.field);
                            }
                        else{
                            fields.add(item.field);
                        }
                    }
                           
                        }
                    }
                }
            
           
        } else {
             fields.add('No layouts found.');
        }

        return fields;
    }

    
    
    
    // To configure the vital sign column
     @AuraEnabled
    public static string getVitalSignColumns(){
        try {
            Elixir_Custom_Setting__c mc = Elixir_Custom_Setting__c.getOrgDefaults();
            return mc.ElixirSuite__Vital_Sign_Columns__c;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static void saveVitalSignColumns(List<Object> vitalsColumns){
        if(vitalsColumns!=null){
            Elixir_Custom_Setting__c mc = Elixir_Custom_Setting__c.getOrgDefaults();
            mc.ElixirSuite__Vital_Sign_Columns__c = String.join(vitalsColumns,';');
            DMLManager.upsertAsUser(mc);
        }
    }
}
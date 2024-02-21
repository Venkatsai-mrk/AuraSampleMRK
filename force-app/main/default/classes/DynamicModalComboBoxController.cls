public with sharing class DynamicModalComboBoxController {

   @AuraEnabled
public static void saveFields(List<String> fields) {
    // Replace the "ElixirSuite__" prefix with "ES#"
    List<String> modifiedFields = new List<String>();
    for (String field : fields) {
        if (field.startsWith('ElixirSuite__')) {
            modifiedFields.add('ES#' + field.substring(13));
        } else {
            modifiedFields.add(field);
        }
    }

    String fieldsAsString = String.join(modifiedFields, ',');

    ElixirSuite__Elixir_Custom_Setting__c customSettingInstance = ElixirSuite__Elixir_Custom_Setting__c.getOrgDefaults();

    if (customSettingInstance == null) {
        customSettingInstance = new ElixirSuite__Elixir_Custom_Setting__c();
    }

    customSettingInstance.ElixirSuite__Vital_Sign_Columns__c = fieldsAsString;
    DMLManager.upsertAsUser(customSettingInstance);
}



@AuraEnabled
public static List<String> getFieldsFromCustomSetting() {
    ElixirSuite__Elixir_Custom_Setting__c customSetting = ElixirSuite__Elixir_Custom_Setting__c.getOrgDefaults();
    String apiFields = customSetting != null ? customSetting.ElixirSuite__Vital_Sign_Columns__c : '';

    // Convert "ES#" to "ElixirSuite__" and leave other fields unchanged
    List<String> originalFields = new List<String>();
    for (String modifiedField : apiFields.split(',')) {
        if (modifiedField.startsWith('ES#')) {
            originalFields.add('ElixirSuite__' + modifiedField.substring(3));
        } else {
            originalFields.add(modifiedField);
}
    }

    return originalFields;
}



    @AuraEnabled
    public static CreateRecordResponse createRecord(Map<String, Object> fieldValues, String patientID ,String formUniqueId) {
        try {
            List<ID> vitalsIds = new list<ID>();
            List<ElixirSuite__Medical_Examination__c> lstMe = new List<ElixirSuite__Medical_Examination__c>();
            ElixirSuite__Medical_Examination__c obj = new ElixirSuite__Medical_Examination__c();
            List<Account> acc = [SELECT Id FROM Account WHERE Id = :patientID WITH SECURITY_ENFORCED];
            String formValue;

            if (!acc.isEmpty()) {
                obj.ElixirSuite__Account__c = acc[0].Id;
            }

            if(String.isNotBlank(formUniqueId)){
                formValue = [SELECT ID,ElixirSuite__Form_Id__c FROM ElixirSuite__Form_Value__c WHERE ElixirSuite__Form_Id__c =: formUniqueId AND ElixirSuite__Form_Detail__c = TRUE].ID;
            }
            
            Id vitalRecordType = Schema.SObjectType.ElixirSuite__Medical_Examination__c.getRecordTypeInfosByDeveloperName().get('Vital_Sign').getRecordTypeId();
            obj.RecordTypeId = vitalRecordType;
            
            obj.ElixirSuite__BypassValidation__c=true;

            if(String.isNotBlank(formValue)){
                obj.ElixirSuite__Form_Value__c = formValue;
            }
            //obj.ElixirSuite__Form_Specific_Vital__c=true;
            for (String fieldName : fieldValues.keySet()) {
                // Fetch field data type from schema
                Schema.DescribeFieldResult fieldDescribe = ElixirSuite__Medical_Examination__c.SObjectType.getDescribe().fields.getMap().get(fieldName).getDescribe();
                String fieldType = fieldDescribe.getType().name();

                // Handle data type conversion dynamically
                Object fieldValue = fieldValues.get(fieldName);

                if (fieldValue != null) {
                    switch on fieldType {
                        when 'DATETIME' {
                            if (String.isNotBlank(String.valueOf(fieldValue))) {
                                String dateTimeString = String.valueOf(fieldValue);
                                Datetime dt = DateTime.newInstanceGmt(
                                        Integer.valueOf(dateTimeString.substring(0, 4)), // Year
                                        Integer.valueOf(dateTimeString.substring(5, 7)), // Month
                                        Integer.valueOf(dateTimeString.substring(8, 10)), // Day
                                        Integer.valueOf(dateTimeString.substring(11, 13)), // Hour
                                        Integer.valueOf(dateTimeString.substring(14, 16)), // Minute
                                        Integer.valueOf(dateTimeString.substring(17, 19)) // Second
                                );

                                Integer offset = UserInfo.getTimezone().getOffset(dt);
                                Datetime local = dt.addSeconds(offset / 1000);

                                obj.put(fieldName, local);
                            }
                        }
                        when 'DATE' {
                            obj.put(fieldName, Date.valueOf(String.valueOf(fieldValue)));
                        }
                        when 'PERCENT', 'CURRENCY', 'INTEGER' {
                            obj.put(fieldName, Integer.valueOf(String.valueOf(fieldValue)));
                        }
                        when 'DOUBLE' {
                            obj.put(fieldName, Double.valueOf(String.valueOf(fieldValue)));
                        }
                        when 'BOOLEAN' {
                            obj.put(fieldName, Boolean.valueOf(String.valueOf(fieldValue)));
                        }
                        when else {
                            // Handle unsupported data types
                            obj.put(fieldName, String.valueOf(fieldValue));
                            System.debug('In else part' + fieldName + ': ' + fieldType);
                        }
                    }
                }
            }
            lstMe.add(obj);
            //DMLManager.insertAsUser(obj);

            if(lstMe != null && !lstMe.isEmpty()){
                Database.SaveResult[] srList = Database.insert(lstMe);
                for (Database.SaveResult sr : srList) {
                    if (sr.isSuccess()) {
                        vitalsIds.add(sr.getId());
                    }
                }
            }
            return new CreateRecordResponse(true, null,vitalsIds); // Success
        } catch (Exception e) {
            String errorMessage = 'An error occurred while creating the record: ' + e.getMessage();
            return new CreateRecordResponse(false, errorMessage,new List<String>()); // Failure with error message
        }
    }

    

    public class CreateRecordResponse {
        @AuraEnabled public Boolean isSuccess;
        @AuraEnabled public String errorMessage;
        @AuraEnabled public List<String> lstVitalIds;

        public CreateRecordResponse(Boolean isSuccess, String errorMessage, List<String> lstVitalIds) {
            this.isSuccess = isSuccess;
            this.errorMessage = errorMessage;
            this.lstVitalIds = lstVitalIds;
        }
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


@AuraEnabled
    public static String deleteRecords(List<String> recordIds) {
        try {
            // Query records for additional checks or perform any pre-deletion logic if needed
            List<ElixirSuite__Medical_Examination__c> recordsToDelete = [SELECT Id FROM ElixirSuite__Medical_Examination__c WHERE Id IN :recordIds WITH SECURITY_ENFORCED];

             if (!recordsToDelete.isEmpty()) {
            DMLManager.deleteAsUser(recordsToDelete);
             }

            return 'Records deleted successfully';
        } catch (Exception e) {
            // Handle exceptions and return an error message
            return 'Error deleting records: ' + e.getMessage();
        }
    }
   

   @AuraEnabled
    public static List<Map<String, String>> getObjectFields() {
        List<Map<String, String>> fieldsInfo = new List<Map<String, String>>();

        // Get the SObject describe result for the custom object
        Schema.DescribeSObjectResult describeResult = ElixirSuite__Medical_Examination__c.sObjectType.getDescribe();

        // Iterate through the fields and add their label and API name to the list
        for (Schema.SObjectField field : describeResult.fields.getMap().values()) {
            Map<String, String> fieldInfo = new Map<String, String>();
            fieldInfo.put('label', field.getDescribe().getLabel());
            fieldInfo.put('apiName', field.getDescribe().getName());
            fieldsInfo.add(fieldInfo);
        }

        return fieldsInfo;
    }

}
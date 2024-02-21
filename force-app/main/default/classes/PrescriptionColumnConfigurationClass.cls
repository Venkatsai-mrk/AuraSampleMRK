public with sharing class PrescriptionColumnConfigurationClass {
    @AuraEnabled
    public static void saveFields(List<String> fields) {
        // Remove the "ElixirSuite__" prefix before storing the fields
        List<String> modifiedFields = new List<String>();
        for (String field : fields) {
            modifiedFields.add(field);
        }
    
        ExceptionLog.logDebugString('fields: ' + modifiedFields);
        String fieldsAsString = String.join(modifiedFields, ',');
    
        ElixirSuite__Elixir_Custom_Setting__c customSettingInstance = ElixirSuite__Elixir_Custom_Setting__c.getOrgDefaults();
    
        if (customSettingInstance == null) {
            customSettingInstance = new ElixirSuite__Elixir_Custom_Setting__c();
        }
    
        customSettingInstance.ElixirSuite__ePrescription_Columns__c = fieldsAsString;
        DMLManager.upsertAsUser(customSettingInstance);
    }
    
    @AuraEnabled
    public static List<String> getFieldsFromCustomSetting() {
        ElixirSuite__Elixir_Custom_Setting__c customSetting = ElixirSuite__Elixir_Custom_Setting__c.getOrgDefaults();
        String apiFields = customSetting != null ? customSetting.ElixirSuite__ePrescription_Columns__c : '';
    
        // Add back the "ElixirSuite__" prefix when retrieving fields
        List<String> originalFields = new List<String>();
        for (String modifiedField : apiFields.split(',')) {
            originalFields.add(modifiedField);
        }
    
        return originalFields;
    }
    
    
        @AuraEnabled(cacheable=true)
        public static List<FieldInfo> getFieldsWithDataType() {
            List<FieldInfo> fieldInfos = new List<FieldInfo>();
            Schema.SObjectType objectType = ElixirSuite__Prescription_Order__c.SObjectType;
    
            for (Schema.SObjectField objectField : objectType.getDescribe().fields.getMap().values()) {
                Schema.DescribeFieldResult fieldDescribe = objectField.getDescribe();
    
                FieldInfo fieldInfo = new FieldInfo();
                fieldInfo.labelName = fieldDescribe.getLabel();
                fieldInfo.apiName = fieldDescribe.getName();
                fieldInfo.dataType = String.valueOf(fieldDescribe.getType());
                fieldInfos.add(fieldInfo);
            }
    
            return fieldInfos;
        }
    
        @AuraEnabled
        public static CreateRecordResponse createRecord(Map<String, Object> fieldValues, String recordTypeDeveloperName, String patientID) {
            try {
                // Fetch Record Type ID
                Id recordTypeId = getRecordTypeId('ElixirSuite__Prescription_Order__c', recordTypeDeveloperName);
    
                ElixirSuite__Prescription_Order__c obj = new ElixirSuite__Prescription_Order__c();
                List<Account> acc = [SELECT Id FROM Account WHERE Id = :patientID WITH SECURITY_ENFORCED];
    
                if (!acc.isEmpty()) {
                    obj.ElixirSuite__Account__c = acc[0].Id;
                }
    
                // Set record type ID
                if (recordTypeId != null) {
                    obj.RecordTypeId = recordTypeId;
                }
    
                for (String fieldName : fieldValues.keySet()) {
                    // Fetch field data type from schema
                    Schema.DescribeFieldResult fieldDescribe = ElixirSuite__Prescription_Order__c.SObjectType.getDescribe().fields.getMap().get(fieldName).getDescribe();
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
    
                DMLManager.insertAsUser(obj);
    
                return new CreateRecordResponse(true, null); // Success
            } catch (Exception e) {
                String errorMessage = 'An error occurred while creating the record: ' + e.getMessage();
                return new CreateRecordResponse(false, errorMessage); // Failure with error message
            }
        }
    
        @AuraEnabled
        public static List<Map<String, String>> getObjectFields() {
            List<Map<String, String>> fieldsInfo = new List<Map<String, String>>();
    
            // Get the SObject describe result for the custom object
            Schema.DescribeSObjectResult describeResult = ElixirSuite__Prescription_Order__c.sObjectType.getDescribe();
    
            // Iterate through the fields and add their label and API name to the list
            for (Schema.SObjectField field : describeResult.fields.getMap().values()) {
                Map<String, String> fieldInfo = new Map<String, String>();
                fieldInfo.put('label', field.getDescribe().getLabel());
                fieldInfo.put('apiName', field.getDescribe().getName());
                fieldsInfo.add(fieldInfo);
            }
    
            return fieldsInfo;
        }
    
        public class CreateRecordResponse {
            @AuraEnabled public Boolean isSuccess;
            @AuraEnabled public String errorMessage;
    
            public CreateRecordResponse(Boolean isSuccess, String errorMessage) {
                this.isSuccess = isSuccess;
                this.errorMessage = errorMessage;
            }
        }
    
        public class FieldInfo {
            @AuraEnabled public String apiName { get; set; }
            @AuraEnabled public String dataType { get; set; }
            @AuraEnabled public String labelName { get; set; }
        }
    
        @AuraEnabled(cacheable=true)
        public static String getRecordTypeId(String objectApiName, String recordTypeDeveloperName) {
            String recordTypeId;
    
            try {
                Schema.SObjectType objectType = Schema.getGlobalDescribe().get(objectApiName);
    
                if (objectType != null) {
                    Schema.RecordTypeInfo recordTypeInfo = objectType.getDescribe().getRecordTypeInfosByDeveloperName().get(recordTypeDeveloperName);
    
                    if (recordTypeInfo != null) {
                        recordTypeId = recordTypeInfo.getRecordTypeId();
                    }
                }
            } catch (Exception e) {
                // Handle exceptions as needed
                System.debug('Exception: ' + e.getMessage());
            }
    
            return recordTypeId;
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
                                if (!item.field.startsWith('ElixirSuite__') && item.field.endsWith('__c') ) {
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
                List<ElixirSuite__Prescription_Order__c> recordsToDelete = [SELECT Id FROM ElixirSuite__Prescription_Order__c WHERE Id IN :recordIds WITH SECURITY_ENFORCED];
    
                 if (!recordsToDelete.isEmpty()) {
                DMLManager.deleteAsUser(recordsToDelete);
                 }
    
                return 'Records deleted successfully';
            } catch (Exception e) {
                // Handle exceptions and return an error message
                return 'Error deleting records: ' + e.getMessage();
            }
        }
}
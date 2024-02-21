public with sharing class VisitSummaryTemplateApex {
    @AuraEnabled
    public static Map<String, Object> getVisitSummarySection() {
        Map<String, Object> result = new Map<String, Object>();
        List<String> picklistValues = new List<String>();

        Schema.DescribeFieldResult fieldResult = ElixirSuite__Master_Object__c.ElixirSuite__Visit_Summary_Sections__c.getDescribe();
        List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();

        for (Schema.PicklistEntry entry : picklistEntries) {
            picklistValues.add(entry.getValue());
        }

        result.put('picklistValues', picklistValues);
        return result;
    }

    @AuraEnabled
    public static Map<String, Object> getSelectedValues(String emailSettingName) {
        Map<String, Object> result = new Map<String, Object>();

        ElixirSuite__Master_Object__c record = [
            SELECT ElixirSuite__Visit_Summary_Sections__c, ElixirSuite__Enable_Visit_Summary__c
            FROM ElixirSuite__Master_Object__c
            WHERE ElixirSuite__Patient_Tile_Entity__c = :emailSettingName
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];

        if (record != null) {
            result.put('selectedValues', record.ElixirSuite__Visit_Summary_Sections__c != null ?
                                        record.ElixirSuite__Visit_Summary_Sections__c.split(';') :
                                        new List<String>());
            result.put('visitSummaryEnabled', record.ElixirSuite__Enable_Visit_Summary__c != null && record.ElixirSuite__Enable_Visit_Summary__c);
        } else {
            result.put('selectedValues', new List<String>());
            result.put('visitSummaryEnabled', false);
        }

        return result;
    }

    @AuraEnabled
    public static Boolean saveVisitSummary(String selectedValues, String emailSettingName, Boolean visitSummaryEnabled) {
        ElixirSuite__Master_Object__c existingRecord;

        try {
            existingRecord = [
                SELECT Id, ElixirSuite__Visit_Summary_Sections__c, ElixirSuite__Enable_Visit_Summary__c
                FROM ElixirSuite__Master_Object__c
                WHERE ElixirSuite__Patient_Tile_Entity__c = :emailSettingName
                WITH SECURITY_ENFORCED
                LIMIT 1
            ];
        } catch (Exception e) {
            existingRecord = null;
        }

        if (existingRecord != null) {
            existingRecord.ElixirSuite__Visit_Summary_Sections__c = selectedValues;
            existingRecord.ElixirSuite__Enable_Visit_Summary__c = visitSummaryEnabled;
            DMLManager.updateAsUser(existingRecord);
        } else {
            ElixirSuite__Master_Object__c newRecord = new ElixirSuite__Master_Object__c();
            newRecord.ElixirSuite__Patient_Tile_Entity__c = emailSettingName;
            newRecord.ElixirSuite__Visit_Summary_Sections__c = selectedValues;
            newRecord.ElixirSuite__Enable_Visit_Summary__c = visitSummaryEnabled;
            newRecord.RecordTypeId = Schema.SObjectType.ElixirSuite__Master_Object__c.getRecordTypeInfosByDeveloperName().get('Patient_Portal').getRecordTypeId();
            DMLManager.insertAsUser(newRecord);
        }

        return visitSummaryEnabled;
    }
}
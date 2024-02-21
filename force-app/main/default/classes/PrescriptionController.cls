public with sharing class PrescriptionController {
    @AuraEnabled
    public static string getCurrentCareEpisode(String accountId){
        
            List<Visits__c> careEpisodes = new List<Visits__c>();
            careEpisodes = [
                SELECT 
                    Id
                FROM
                    Visits__c
                WHERE
                    ElixirSuite__Account__c = :accountId
                AND
                    ElixirSuite__Status__c = 'Active'
                WITH 
                    SECURITY_ENFORCED
                ORDER BY
                    CreatedDate DESC
                LIMIT 
                    1 ];

            if (careEpisodes.size() > 0) { return careEpisodes[0].Id; }
            return '';
    }
    @AuraEnabled
    public static Boolean getCustomSettingBooleanValue() {
    try {
        ElixirSuite__Elixir_Custom_Setting__c customSetting = ElixirSuite__Elixir_Custom_Setting__c.getOrgDefaults();
        
        if (customSetting.ElixirSuite__Care_Episode_based_filtering_for_Notes__c) {
            return customSetting.ElixirSuite__Care_Episode_based_filtering_for_Notes__c;
        } else {
            return false; // Default value if custom setting instance is not found
        }
    } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
    }
    }
    @AuraEnabled
    public static List<ElixirSuite__Prescription_Order__c> getPrescriptionOrders(String accountId){
        try {
            String currentCareEpisode = getCurrentCareEpisode(accountId);
            Boolean careEpisodeBasedFilter=getCustomSettingBooleanValue();
            String medicationRecordTypeId = Schema.SObjectType.ElixirSuite__Prescription_Order__c.getRecordTypeInfosByName().get('Medication').getRecordTypeId();
            String currentPrescriptionType = ElixirSuite__TabPermissionBasedOnProfiles__c.getInstance(UserInfo.getProfileId()).ElixirSuite__Prescription_Priority__c;
            
            String query = 'SELECT Id, ElixirSuite__Drug_Name__c, ElixirSuite__Reason_new__c, ElixirSuite__Number_of_Times_Days_Weeks__c, ElixirSuite__Route_New__c, ElixirSuite__Dosage_Form__c, CreatedDate, CreatedBy.Name, LastModifiedDate FROM ElixirSuite__Prescription_Order__c WHERE ElixirSuite__Account__c = :accountId ';
            
            switch on currentPrescriptionType {
                when 'NewCrop Prescription' {
                    query += ' AND ElixirSuite__Prescription_Guid__c != null ';
                }
                when 'Dummy Prescription' {
                    query += ' AND ElixirSuite__Prescription_Guid__c = null AND RecordTypeId = :medicationRecordTypeId ';
                }
            }

            if (String.isNotBlank(currentCareEpisode) && careEpisodeBasedFilter == true) {
                query += ' AND ElixirSuite__Care_Episode__c = :currentCareEpisode';
            }

            query += ' WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC';

            return Database.query(query);
            
        } catch (Exception e) {
            ExceptionLog.logError(e);
            throw new AuraHandledException(e.getMessage());
        }
    }
}
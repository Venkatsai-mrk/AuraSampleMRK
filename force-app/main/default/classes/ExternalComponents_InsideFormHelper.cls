public with sharing class ExternalComponents_InsideFormHelper {
    @AuraEnabled
    public static ExternalComponentsObjectData fetchAllergyData_AccountSpecific(String accountId,String notesSpecificData){
         ExternalComponentsObjectData ref;
        Medical_Examination__c [] allergyData=fetchAccountAllergyLst(accountId,notesSpecificData);
        Medical_Examination__c[] vitalObservation =  [select id, Blood_Pressure_Systolic__c,Blood_Pressure_diasystolic__c,Temperature__c,  
                                                      Pulse__c, createdDate,ElixirSuite__Respiration__c,
                                                      Oxygen_Saturation__c,CreatedBy.Name
                                                      from Medical_Examination__c where
                                                      Account__c=:accountId and  RecordType.DeveloperName='Vital_Sign' AND Blood_Pressure_Systolic__c!=null
                                                      WITH SECURITY_ENFORCED
                                                      order by CreatedDate ASC];
        Medical_Examination__c [] glucoseObservation = [SELECT Id,Intervention__c,Type_of_check__c,
                                                        Note__c,Glucose_Reading__c
                                                        FROM Medical_Examination__c where  Account__c=:accountId AND
                                                        RecordType.developerName = 'Glucose'
                                                        WITH SECURITY_ENFORCED
                                                        order by CreatedDate asc];
    //    Id problemRecType = Schema.SObjectType.Dataset1__c.getRecordTypeInfosByName().get('Non-Templatized').getRecordTypeId();
        Map<Id,Dataset1__c> parentProblems = new Map<Id,Dataset1__c>();
        //fetch all the problems related to an account
        ICD_Codes__c[]   childConditionData;
        Notes__c[] relatedNotes;
        Dataset1__c[] conditionData;
       
        Prescription_Order__c[]  medicationData = [SELECT Drug_Name__c,Id,Number_of_Times_Days_Weeks__c,Reason_new__c,
                                                   Ferquency__c,Route_New__c,Reason__c,Type__c,Dosage_Form__c,(select Strength__c,Dosage_Instruction__c,Repeat__c
                                                                                                               from Frequency__r)
                                                   FROM Prescription_Order__c where  Account__c=:accountId and Drug_Name__c!=''
                                                   WITH SECURITY_ENFORCED
                                                   order by CreatedDate asc limit 110];
        
        ref = new ExternalComponentsObjectData();
        ref.allergyData =allergyData;
        ref.vital_Signs_Data = vitalObservation;
        ref.glucoseData = glucoseObservation;
       // ref.conditionData = conditionData;
        ref.childConditionData = childConditionData;
        ref.relatedNotes = relatedNotes;
        ref.medicationData = medicationData;
        ref.vitalsColumn=AllergyColumnsConfigController.getVitalSignColumns();
        
        return ref;
        
    }
    
    @AuraEnabled
    public static ExternalComponentsObjectData fetchAllergyData_AccountSpecificEditMode(String accountId,String formUniqueId){
         ExternalComponentsObjectData ref;
        Medical_Examination__c [] allergyData = fetchAccountAllergyLstEditMode(accountId,formUniqueId);
        Medical_Examination__c[] vitalObservation =  [select id, Blood_Pressure_Systolic__c,Blood_Pressure_diasystolic__c,Temperature__c,  
                                                      Pulse__c, createdDate,ElixirSuite__Respiration__c,
                                                      Oxygen_Saturation__c,CreatedBy.Name
                                                      from Medical_Examination__c where
                                                      Account__c=:accountId and  RecordType.DeveloperName='Vital_Sign' AND Blood_Pressure_Systolic__c!=null
                                                      WITH SECURITY_ENFORCED
                                                      order by CreatedDate ASC];
        Medical_Examination__c [] glucoseObservation = [SELECT Id,Intervention__c,Type_of_check__c,
                                                        Note__c,Glucose_Reading__c
                                                        FROM Medical_Examination__c where  Account__c=:accountId AND
                                                        RecordType.developerName = 'Glucose'
                                                        WITH SECURITY_ENFORCED
                                                        order by CreatedDate asc];
    //    Id problemRecType = Schema.SObjectType.Dataset1__c.getRecordTypeInfosByName().get('Non-Templatized').getRecordTypeId();
        Map<Id,Dataset1__c> parentProblems = new Map<Id,Dataset1__c>();
        //fetch all the problems related to an account
        ICD_Codes__c[]   childConditionData;
        Notes__c[] relatedNotes;
        Dataset1__c[] conditionData;
       
        Prescription_Order__c[]  medicationData = [SELECT Drug_Name__c,Id,Number_of_Times_Days_Weeks__c,Reason_new__c,
                                                   Ferquency__c,Route_New__c,Reason__c,Type__c,Dosage_Form__c,(select Strength__c,Dosage_Instruction__c,Repeat__c
                                                                                                               from Frequency__r)
                                                   FROM Prescription_Order__c where  Account__c=:accountId and Drug_Name__c!=''
                                                   WITH SECURITY_ENFORCED
                                                   order by CreatedDate asc limit 110];
        
        ref = new ExternalComponentsObjectData();
        ref.allergyData =allergyData;
        ref.vital_Signs_Data = vitalObservation;
        ref.glucoseData = glucoseObservation;
       // ref.conditionData = conditionData;
        ref.childConditionData = childConditionData;
        ref.relatedNotes = relatedNotes;
        ref.medicationData = medicationData;
        ref.vitalsColumn=AllergyColumnsConfigController.getVitalSignColumns();
        
        return ref;
        
    }
    
    // External wrapper for external components data 
    public class ExternalComponentsObjectData {
        @AuraEnabled public List<Medical_Examination__c> allergyData;
        @AuraEnabled public List<Medical_Examination__c> vital_Signs_Data;
        @AuraEnabled public List<Medical_Examination__c> glucoseData;
        @AuraEnabled public Dataset1__c[] conditionData;
        @AuraEnabled public ICD_Codes__c[]   childConditionData;
        @AuraEnabled public Notes__c[] relatedNotes; 
        @AuraEnabled public Prescription_Order__c[] medicationData;
       @AuraEnabled public String vitalsColumn;
       
        // End
    }
    @AuraEnabled
    public static EditScreen_ExternalComponentsObjectData allExtCompDataForEditScreen(String accountId,String formUniqueID){
        EditScreen_ExternalComponentsObjectData ref;
        System.debug('accountId '+accountId);
        ExternalComponentsObjectData accSpeific_Rec =  fetchAllergyData_AccountSpecificEditMode(accountId,formUniqueID);
        Medical_Examination__c [] allergyData_FormSpecific  = [SELECT ElixirSuite__Allergy_Name1__r.Name , 
                                                               ElixirSuite__Substance1__r.Name,ElixirSuite__Substance_Code__c,ElixirSuite__Reaction1__r.Name,ElixirSuite__Severity1__r.Name 
                                                               FROM ElixirSuite__Medical_Examination__c where  Account__c = : accountId AND RecordType.DeveloperName = 'Allergy'
                                                               AND Substance__c!='' AND Form_Unique_ID__c=:formUniqueID 
                                                               WITH SECURITY_ENFORCED
                                                               order by CreatedDate asc];
        
        Medical_Examination__c[] vitalObservation_FormSpecific =  [select id, Blood_Pressure_Systolic__c,Blood_Pressure_diasystolic__c,Temperature__c,  
                                                      Pulse__c, createdDate,ElixirSuite__Respiration__c,
                                                      Oxygen_Saturation__c,CreatedBy.Name
                                                      from Medical_Examination__c where
                                                                   Account__c=:accountId and  RecordType.DeveloperName='Vital_Sign' AND Blood_Pressure_Systolic__c!=null
                                                                   AND  Form_Unique_ID__c=:formUniqueID 
                                                                   WITH SECURITY_ENFORCED
                                                                   order by CreatedDate asc];
        Medical_Examination__c [] glucoseObservation_FormSpecific = [SELECT Id,Intervention__c,Type_of_check__c,
                                                                     Note__c,Glucose_Reading__c
                                                                     FROM Medical_Examination__c where  Account__c=:accountId AND
                                                                     RecordType.developerName = 'Glucose'  AND Form_Unique_ID__c=:formUniqueID
                                                                     WITH SECURITY_ENFORCED
                                                                     order by CreatedDate asc ]; 
      //  Id problemRecType = Schema.SObjectType.Dataset1__c.getRecordTypeInfosByName().get('Non-Templatized').getRecordTypeId();
        Map<Id,Dataset1__c> parentProblems = new Map<Id,Dataset1__c>();
        //fetch all the problems related to an account
        ICD_Codes__c[]   childConditionData_FormSpecific;
        Notes__c[] relatedNotes_FormSpecific;
      
        Prescription_Order__c[]  medicationData = [SELECT Drug_Name__c,Id,Number_of_Times_Days_Weeks__c,Reason_new__c,
                                                   Ferquency__c,Route_New__c,Reason__c,Type__c,Dosage_Form__c,(select Strength__c,Dosage_Instruction__c,Repeat__c
                                                                                                               from Frequency__r)
                                                   FROM Prescription_Order__c where  Account__c=:accountId  and Drug_Name__c!=''
                                                   WITH SECURITY_ENFORCED
                                                   order by CreatedDate asc limit 110];
        
        
        ref = new EditScreen_ExternalComponentsObjectData();
        ref.allergyData = accSpeific_Rec.allergyData;
        ref.allergyData_FormSpecific = allergyData_FormSpecific;
        
        ref.vital_Signs_Data = accSpeific_Rec.vital_Signs_Data;
        ref.vital_Signs_Data_FormSpecific = vitalObservation_FormSpecific;
        
        ref.glucoseData = accSpeific_Rec.glucoseData;
        ref.glucoseData_FormSpecific = glucoseObservation_FormSpecific;
        
     //   ref.conditionData_FormSpecific = conditionData_FormSpecific;
        ref.childConditionData_FormSpecific = childConditionData_FormSpecific;
        ref.relatedNotes_FormSpecific = relatedNotes_FormSpecific;
        ref.conditionData  = accSpeific_Rec.conditionData;
        ref.childConditionData = accSpeific_Rec.childConditionData;
        ref.relatedNotes = accSpeific_Rec.relatedNotes;
        ref.medicationData = medicationData;
        ref.vitalsColumn=AllergyColumnsConfigController.getVitalSignColumns();
        return ref;
    }
    public class EditScreen_ExternalComponentsObjectData {
        @AuraEnabled public List<Medical_Examination__c> allergyData;
        @AuraEnabled public List<Medical_Examination__c> allergyData_FormSpecific;
        @AuraEnabled public List<Medical_Examination__c> vital_Signs_Data;
        @AuraEnabled public List<Medical_Examination__c> vital_Signs_Data_FormSpecific;
        @AuraEnabled public List<Medical_Examination__c> glucoseData;
        @AuraEnabled public List<Medical_Examination__c> glucoseData_FormSpecific;
        @AuraEnabled public Dataset1__c[] conditionData;
        @AuraEnabled public ICD_Codes__c[]   childConditionData;
        @AuraEnabled public Notes__c[] relatedNotes;
        @AuraEnabled public Dataset1__c[] conditionData_FormSpecific;
        @AuraEnabled public ICD_Codes__c[]   childConditionData_FormSpecific;
        @AuraEnabled public Notes__c[] relatedNotes_FormSpecific;
        @AuraEnabled public Prescription_Order__c[] medicationData;
       @AuraEnabled public String vitalsColumn;
        // End
    }
    public static List<ElixirSuite__Medical_Examination__c> fetchAccountAllergyLst(String acctId,String notesSpecificData) {
         String activeCareEpisodeId =getActiveCareEpisodeId(acctId);
            Boolean careEpisodeBasedFilter =getCustomSettingBooleanValue();
            Id recordTypeId = Schema.SObjectType.ElixirSuite__Medical_Examination__c.getRecordTypeInfosByDeveloperName().get('Allergy').getRecordTypeId();
            List<ElixirSuite__Medical_Examination__c> queryResults = new List<ElixirSuite__Medical_Examination__c>();

            //process allergyData for notes specific
            List<String> objAsStrings = new List<String>(); 
            Map<String, Object> lstOfPayload =(Map<String, Object>) JSON.deserializeUntyped(notesSpecificData);
            List<Object> listOfAllergy = (List<Object>) lstOfPayload.get('allergyData');

            if(listOfAllergy != null && !listOfAllergy.isEmpty()){
                objAsStrings = (List<String>) JSON.deserialize(JSON.serialize(listOfAllergy), List<String>.class);
            }
            //process allergyData for notes specific end here

            String objectName = 'ElixirSuite__Medical_Examination__c';
            String conditionField = 'ElixirSuite__Account__c';
        
            // If this custom setting is turned on in the customer org, the user will be able to view filtered data
            if (String.isNotBlank(activeCareEpisodeId) && careEpisodeBasedFilter) {
                queryResults = executeQuery(objectName, conditionField, acctId, activeCareEpisodeId, recordTypeId,objAsStrings);
            } else {
                // If this custom setting is turned off, the user will be able to view all data
                queryResults = executeQuery(objectName, conditionField, acctId, null, recordTypeId,objAsStrings);
            }
        
            System.debug('queryResults: ' + queryResults);
            return queryResults;
        }

        public static List<ElixirSuite__Medical_Examination__c> executeQuery(String objectName, String conditionField, String acctId, String activeCareEpisodeId, Id recordTypeId, List<String> allergyIds) {
            Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
        
            String query = 'SELECT ';
            for (String fieldName : fieldMap.keySet()) {
                query += fieldName + ', ';
            }
            query += 'ElixirSuite__Allergy_Name1__r.Name, ElixirSuite__Substance1__r.Name, ElixirSuite__Severity1__r.Name, ElixirSuite__Reaction1__r.Name, ElixirSuite__Account__r.Name ';
            query = query.removeEnd(', ');
            query += ' FROM ' + objectName + ' WHERE ' + conditionField + ' = \'' + String.escapeSingleQuotes(acctId) + '\' AND ElixirSuite__Allergy_Name1__c != null';
            query += ' AND ID IN : allergyIds';

            if (activeCareEpisodeId != null) {
                query += ' AND ElixirSuite__Care_Episode__c = \'' + String.escapeSingleQuotes(activeCareEpisodeId) + '\'';
            }
        
            if (recordTypeId != null) {
                query += ' AND RecordTypeId = \'' + String.escapeSingleQuotes(recordTypeId) + '\'';
            }
        
            query += ' ORDER BY CreatedDate DESC ';
        
            return Database.query(query);
        }
        public static List<ElixirSuite__Medical_Examination__c> fetchAccountAllergyLstEditMode(String acctId,String formUniqueId) {
         String activeCareEpisodeId =getActiveCareEpisodeId(acctId);
            Boolean careEpisodeBasedFilter =getCustomSettingBooleanValue();
            Id recordTypeId = Schema.SObjectType.ElixirSuite__Medical_Examination__c.getRecordTypeInfosByDeveloperName().get('Allergy').getRecordTypeId();
            List<ElixirSuite__Medical_Examination__c> queryResults = new List<ElixirSuite__Medical_Examination__c>();

            String objectName = 'ElixirSuite__Medical_Examination__c';
            String conditionField = 'ElixirSuite__Form_Value__r.ElixirSuite__Form_Id__c';
        
            // If this custom setting is turned on in the customer org, the user will be able to view filtered data
            if (String.isNotBlank(activeCareEpisodeId) && careEpisodeBasedFilter) {
                queryResults = executeQueryEditMode(objectName, conditionField, acctId, activeCareEpisodeId, recordTypeId,formUniqueId);
            } else {
                // If this custom setting is turned off, the user will be able to view all data
                queryResults = executeQueryEditMode(objectName, conditionField, acctId, null, recordTypeId,formUniqueId);
            }
        
            System.debug('queryResults: ' + queryResults);
            return queryResults;
        }

        public static List<ElixirSuite__Medical_Examination__c> executeQueryEditMode(String objectName, String conditionField, String acctId, String activeCareEpisodeId, Id recordTypeId, String formUniqueId) {
            Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
        
            String query = 'SELECT ';
            for (String fieldName : fieldMap.keySet()) {
                query += fieldName + ', ';
            }
            query += 'ElixirSuite__Allergy_Name1__r.Name, ElixirSuite__Substance1__r.Name, ElixirSuite__Severity1__r.Name, ElixirSuite__Reaction1__r.Name, ElixirSuite__Account__r.Name ';
            query = query.removeEnd(', ');
            query += ' FROM ' + objectName + ' WHERE ' + conditionField + ' = \'' + String.escapeSingleQuotes(formUniqueId) + '\' AND ElixirSuite__Allergy_Name1__c != null';

            if (activeCareEpisodeId != null) {
                query += ' AND ElixirSuite__Care_Episode__c = \'' + String.escapeSingleQuotes(activeCareEpisodeId) + '\'';
            }
        
            if (recordTypeId != null) {
                query += ' AND RecordTypeId = \'' + String.escapeSingleQuotes(recordTypeId) + '\'';
            }
        
            query += ' ORDER BY CreatedDate DESC ';
        
            return Database.query(query);
        }
    @AuraEnabled
    public static String getActiveCareEpisodeId(String accountId) {
        try {
            List<ElixirSuite__Visits__c> allCareEpisodes = [
                SELECT
                    Id
                FROM
                    ElixirSuite__Visits__c
                WHERE
                    ElixirSuite__Account__c = :accountId
                AND
                    ElixirSuite__Status__c = 'Active'
                WITH 
                    SECURITY_ENFORCED
                ORDER BY
                    CreatedDate DESC];
        
            if (allCareEpisodes != null && allCareEpisodes.size() > 0) {
                return allCareEpisodes[0].Id;
            }

            return '';   
        } catch (Exception e) {
            ExceptionLog.logError(e);
            throw new AuraHandledException(e.getMessage());
        }
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
    
}
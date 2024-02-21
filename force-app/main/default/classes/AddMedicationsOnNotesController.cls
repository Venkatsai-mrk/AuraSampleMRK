public with sharing class AddMedicationsOnNotesController {
    
    @AuraEnabled
    public static User getCurrentlyLoggedInUser(){
        return [SELECT ID,Name from User where id=: UserInfo.getUserId() WITH SECURITY_ENFORCED];
    }
    
    @AuraEnabled
    public static List<String> saveMedications(String accountId, List<Map<String, Object>> medicationsToSave,String formUniqueId) {
        
        List<Prescription_Order__c> prescriptionRecords = new List<Prescription_Order__c>();
           Id recordTypeIdForOrder = Schema.SObjectType.Prescription_Order__c.getRecordTypeInfosByName().get('Order').getRecordTypeId();
            Prescription_Order__c prescriptionLst = new Prescription_Order__c();
            prescriptionLst.Account__c = accountId;
            prescriptionLst.RecordTypeId=recordTypeIdForOrder;
            prescriptionRecords.add(prescriptionLst);
            //insert prescriptionRecords;
            DMLManager.insertAsUser(prescriptionRecords);
        
        List<ElixirSuite__Prescription_Order__c> medicationRecords = new List<ElixirSuite__Prescription_Order__c>();
        List<ElixirSuite__Frequency__c> frequencyRecords = new List<ElixirSuite__Frequency__c>();
        List<ID> medicationIds = new list<ID>();
        String formValue;

        if(String.isNotBlank(formUniqueId)){
            formValue = [SELECT ID,ElixirSuite__Form_Id__c FROM ElixirSuite__Form_Value__c WHERE ElixirSuite__Form_Id__c =: formUniqueId AND ElixirSuite__Form_Detail__c = TRUE].ID;
        }

        Id medicationRecordType = Schema.SObjectType.ElixirSuite__Prescription_Order__c.getRecordTypeInfosByDeveloperName().get('Medication').getRecordTypeId();
        
       // Create a set to hold unique medication IDs
        Set<String> medicationIdValues = new Set<String>();
        
        // Populate the set with medication IDs from medicationsToSave
        for (Map<String, Object> medicationData : medicationsToSave) {
            String medicationId = (String)medicationData.get('MedicationName');
            medicationIdValues.add(medicationId);
        }
        
        // Query the ElixirSuite__Master_Object__c records outside the loop
        Map<String, ElixirSuite__Master_Object__c> medicationMap = new Map<String, ElixirSuite__Master_Object__c>();
        for (ElixirSuite__Master_Object__c medRec : [SELECT Id, Name
                                                     FROM ElixirSuite__Master_Object__c 
                                                     WHERE Id IN :medicationIdValues WITH SECURITY_ENFORCED]) {
            medicationMap.put(medRec.Id, medRec);
        }
        
        // Iterate through medicationsToSave and create ElixirSuite__Prescription_Order__c records
        for (Map<String, Object> medicationData : medicationsToSave) {
            ElixirSuite__Prescription_Order__c medication = new ElixirSuite__Prescription_Order__c();
            String medicationId = (String)medicationData.get('MedicationName');
        
            medication.ElixirSuite__Medication__c = medicationId;
            medication.ElixirSuite__Status__c = (String)medicationData.get('Status');
            medication.RecordTypeId = medicationRecordType;
            medication.ElixirSuite__Direction__c = (String)medicationData.get('Direction');
            medication.ElixirSuite__Start_Date__c = Date.valueOf((String)medicationData.get('StartDate'));
            medication.ElixirSuite__End_Date__c = Date.valueOf((String)medicationData.get('EndDate'));
            medication.ElixirSuite__Notes__c = (String)medicationData.get('Notes');
            medication.ElixirSuite__Reason_new__c= (String)medicationData.get('Notes');
            medication.ElixirSuite__Account__c = accountId;
            medication.ElixirSuite__Prescription_Order__c=prescriptionRecords[0].Id;
        
            // Set the Drug_Name__c field using the queried medication record from the map
            if (medicationMap.containsKey(medicationId)) {
                ElixirSuite__Master_Object__c medRecord = medicationMap.get(medicationId);
                medication.Drug_Name__c = medRecord.Name;
            }
        
            if (String.isNotBlank(formValue)) {
                medication.ElixirSuite__Form_Value__c = formValue;
            }
        
            medicationRecords.add(medication);
        }

        
        if (!medicationRecords.isEmpty()) {
            //DMLManager.insertAsUser(medicationRecords);
            Database.SaveResult[] srList = Database.insert(medicationRecords);
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    medicationIds.add(sr.getId());
                }
            }
        }
        
        for (Integer i = 0; i < medicationsToSave.size(); i++) {
            Map<String, Object> medicationData = medicationsToSave[i];
            
            ElixirSuite__Frequency__c frequencyRecord = new ElixirSuite__Frequency__c();
            frequencyRecord.ElixirSuite__Strength__c = (String) medicationData.get('Strength');
            frequencyRecord.ElixirSuite__Prescription_Order__c = medicationRecords[i].Id;
            frequencyRecords.add(frequencyRecord);
        }
        
        if (!frequencyRecords.isEmpty()) {
            DMLManager.insertAsUser(frequencyRecords);
        }

        return medicationIds;
    }

    public static  Map<String, String> fetchPickListValue(String strObjectName,String strPicklistField ){
        
        Map<String, String> mapPickListValues = new Map<String, String>();
        Schema.SObjectType objSobjectType = Schema.getGlobalDescribe().get(strObjectName);
        Schema.DescribeSObjectResult objDescribeSobject = objSobjectType.getDescribe();
        Map<String, Schema.SObjectField> mapFields = objDescribeSobject.fields.getMap();
        List<Schema.PicklistEntry> lstPickListValues = mapFields.get(strPicklistField).getDescribe().getPickListValues();
        for (Schema.PicklistEntry objPickList : lstPickListValues) {
            mapPickListValues.put(objPickList.getValue(),objPickList.getLabel());
            
            }
        return mapPickListValues;
    }

    @AuraEnabled
    public static WrapperForPicklist picklistValues(){
        WrapperForPicklist sObj = new WrapperForPicklist();
        sObj.statusPickListValues = fetchPickListValue('ElixirSuite__Prescription_Order__c','ElixirSuite__Status__c');
        sObj.directionPickListValues = fetchPickListValue('ElixirSuite__Prescription_Order__c','ElixirSuite__Ferquency__c');
        return sObj;
    }
    public class WrapperForPicklist{
        @AuraEnabled public Map<String, String> statusPickListValues = new Map<String, String>();
        @AuraEnabled public Map<String, String> directionPickListValues = new Map<String, String>();
    }
}
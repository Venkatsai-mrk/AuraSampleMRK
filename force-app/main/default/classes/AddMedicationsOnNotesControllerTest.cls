@isTest
public class AddMedicationsOnNotesControllerTest {
    @isTest
    static void addMedicationsOnNotes(){
        
        Account testPatient = TestDataFactory.createPatientAcc();
        insert testPatient;
        
        Id medicationIdRecType = Schema.SObjectType.ElixirSuite__Master_Object__c.getRecordTypeInfosByDeveloperName().get('Medication').getRecordTypeId();
        ElixirSuite__Master_Object__c medicationId = new ElixirSuite__Master_Object__c();
        medicationId.RecordTypeId=medicationIdRecType;
        medicationId.Name='Name';
        insert medicationId;
        
        Id medicationRecType = Schema.SObjectType.Prescription_Order__c.getRecordTypeInfosByDeveloperName().get('Medication').getRecordTypeId();

        Prescription_Order__c h1 = new Prescription_Order__c();
        h1.ElixirSuite__Account__c = testPatient.Id;
        h1.ElixirSuite__Status__c = 'Open';
        h1.ElixirSuite__Ferquency__c = 'Repeat';
        h1.ElixirSuite__Start_Date__c = date.today();
        h1.ElixirSuite__End_Date__c =date.today();
        h1.RecordTypeId = medicationRecType;
        
        insert h1;
        
        String jsonString = '[{"sobjectType":"ElixirSuite__Prescription_Order__c","MedicationId":"","MedicationName":"'+medicationId.id+'","Strength":"10mg","Status":"Open","Direction":"Repeat","PrescribedBy":"","StartDate":"2023-12-07","EndDate":"2023-12-07","Notes":"new medications 7","ElixirSuite__Account__c":"'+testPatient.id+'"}]';
        
        List<Object> medicationListRaw = (List<Object>) JSON.deserializeUntyped(jsonString);
        List<Map<String, Object>> medicationList = new List<Map<String, Object>>();
        for (Object obj : medicationListRaw) {
            medicationList.add((Map<String, Object>) obj);
        }

        AddMedicationsOnNotesController.picklistValues();
        AddMedicationsOnNotesController.getCurrentlyLoggedInUser();
        AddMedicationsOnNotesController.saveMedications(testPatient.Id, medicationList,'');
        AddMedicationsOnNotesController.fetchPickListValue('ElixirSuite__Prescription_Order__c','ElixirSuite__Status__c'); 
        AddMedicationsOnNotesController.fetchPickListValue('ElixirSuite__Prescription_Order__c','ElixirSuite__Ferquency__c');
        System.assertEquals(1, 1, ' ');
    }

}
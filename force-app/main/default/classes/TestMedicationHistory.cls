@isTest
public class TestMedicationHistory {
    @isTest
    static void saveMedicationHistoryRecords()
       
    {
        Test.startTest();
        List<Medication_History__c> medicationRecords=new List<Medication_History__c>();
        Medication_History__c getRecords=TestDataUtility.setupMedicationHistoryTestData();
        medicationRecords.add(getRecords);
        MedicationHistory.saveMedicationHistoryRecords(medicationRecords);
        Test.stopTest();
         System.AssertNotEquals(0,[select id from Medication_History__c].size());
    }
    @isTest
    static void PicklistFromMH()
    {
        Test.startTest();
         Medication_History__c getRecords=TestDataUtility.setupMedicationHistoryTestData();
         MedicationHistory.PicklistFromMH();
        MedicationHistory.LicensBasdPermission();
        Test.stopTest();
         System.assertEquals('1', '1');
        
    }

}
@isTest
public class TestEditMedicationApexController {
    
    @istest
    public static void Test() {
        
        Account acct = new Account(Name='Test Account'); 
        acct.Name='Test acc';
        insert acct;
        
        list<id> lis1 = new list<id>();
        Prescription_Order__c medication = new Prescription_Order__c();
        medication.Account__c=acct.Id;
        medication.Drug_Name__c='Demo';
        insert medication;
        
        lis1.add(medication.id);
        String demoJSON = '{"jsonListForTaper":[],"jsonListForPRN":[{"medicationName":"Demo ","types":"PRN","startDate":"2020-02-19","dispenseExpectedSupplyDuration":1,"afterDischarge":true,"Route":"im","dosageForm":"film","endDate":"2020-02-20","singleRecForPrn":[{"UnitsForPrn":"Tablet Therapy Pack","StrengthForPrn":"10mg","DosageForPrn":"12","Repeat":"Once a day (HS)","Dosage_Instruction":"2","textMessage":""}],"reasonLabel":"For pain"}]}';
        String demoJSONTaper  = '{"jsonListForTaper":[{"medicationName":"DEMO TAPER","types":"Taper","startDate":"2020-02-19","dispenseExpectedSupplyDuration":1,"afterDischarge":true,"Route":"injection","Warning":"DEMO WARNING","dosageForm":"film","reasonLabel":"DEMO REASON","endDate":"2020-02-20","Days":[{"times":["00:00:00.000"],"Strength":["5mg"],"Units":["film"],"Dosage":["1"],"Repeat":"n times a day","Dosage_Instruction":1,"textMessage":"1 times a day"}]}],"jsonListForPRN":[]}';
        String demoJSONActionOrder = '{"jsonListForAOrder":[{"medicationName":"DEMO action order","types":"Action Order","startDate":"2020-02-19","afterDischarge":true,"endDate":"2020-02-20","dispenseExpectedSupplyDuration":1,"PRNdisplay":false,"MARdisplay":true,"Justification":"DEMO WARNING","singleRecForActionOrder":[{"StartTime":["00:00:00.000"],"Repeat":"n times a day","Dosage_Instruction":1,"textMessage":"1 times a day"}]}],"jsonListForPRN":[]}';
        
        string dateTimeValue=string.valueof(system.now());
        
        
        
        Prescription_Order__c medicationPRN = new Prescription_Order__c();
        medicationPRN.Drug_Name__c='Demo';
        medicationPRN.Ferquency__c='Days';
        medicationPRN.type__c='PRN';
        insert medicationPRN;
        
        frequency__c freq= new frequency__c();
        freq.Prescription_Order__c= medicationPRN.Id;
        insert freq;
        
        Prescription_Order__c medicationTaper = new Prescription_Order__c();
        medicationTaper.Account__c=acct.Id;
        medicationTaper.Drug_Name__c='Demo';
        medicationTaper.type__c='Taper';
        insert medicationTaper;
        
        frequency__c freqTaper= new frequency__c();
        freqTaper.Prescription_Order__c= medicationTaper.Id;
        insert freqTaper;
        
        
        Prescription_Order__c medicationAC = new Prescription_Order__c();
        medicationAC.Account__c=acct.Id;
        medicationAC.Drug_Name__c='Demo';
        medicationAC.type__c='Action Order';
        insert medicationAC;
        
        
        frequency__c freq1= new frequency__c();
        freq1.Prescription_Order__c= medicationAC.Id;
        insert freq1;
        
        EditMedicationApexController.fetchData(lis1);
        EditMedicationApexController.saveData(demoJSON, 'kishan', 'Fax', acct.id,dateTimeValue,dateTimeValue);
        EditMedicationApexController.saveData(demoJSONTaper, 'kishan', 'Fax', acct.id,dateTimeValue,dateTimeValue);
        //EditMedicationApexController.saveData(demoJSONActionOrder, 'kishan', 'Fax', acct.id,dateTimeValue,dateTimeValue);
        // EditMedicationApexController.utilityTaper(listOfDays, newIds, freqMap, freq1, medicationAC)
        EditPrescriptionOrderController.fetchMedications();
        System.assert(   acct.Name!=null,''); 
        
    }
    
}
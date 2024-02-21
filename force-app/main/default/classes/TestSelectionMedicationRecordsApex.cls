@isTest
public class TestSelectionMedicationRecordsApex {

     @istest
    public static void Test() {
        
        Account acct = new Account(Name='Test Account'); 
        acct.Name='Test acc';
      //  insert acct;
        DMLManager.insertAsUser(acct);//added by Anmol for LX3-6500
        
        Account acct1 = new Account(Name='Test Account1'); 
        acct.Name='Test acc1';
      //  insert acct;
        DMLManager.insertAsUser(acct1);//added by Anmol for LX3-6500
        
        list<id> lis1 = new list<id>();
        Prescription_Order__c medication = new Prescription_Order__c();
        medication.Account__c=acct.Id;
        medication.Drug_Name__c='Demo';
        
      //  insert medication;
        DMLManager.insertAsUser(medication);//added by Anmol for LX3-6500
        lis1.add(medication.id);
        String demoJSON = '{"jsonListForTaper":[],"jsonListForPRN":[{"medicationName":"Demo ","types":"PRN","startDate":"2020-02-19","dispenseExpectedSupplyDuration":1,"afterDischarge":true,"Route":"im","dosageForm":"film","endDate":"2020-02-20","singleRecForPrn":[{"UnitsForPrn":"Tablet Therapy Pack","StrengthForPrn":"10mg","DosageForPrn":"12","Repeat":"Once a day (HS)","Dosage_Instruction":"2","textMessage":""}],"reasonLabel":"For pain"}]}';
        String demoJSONTaper  = '{"jsonListForTaper":[{"medicationName":"DEMO TAPER","types":"Taper","startDate":"2020-02-19","dispenseExpectedSupplyDuration":1,"afterDischarge":true,"Route":"injection","Warning":"DEMO WARNING","dosageForm":"film","reasonLabel":"DEMO REASON","endDate":"2020-02-20","Days":[{"times":["00:00:00.000"],"Strength":["5mg"],"Units":["film"],"Dosage":["1"],"Repeat":"n times a day","Dosage_Instruction":1,"textMessage":"1 times a day"}]}],"jsonListForPRN":[]}';
        //   String demoJSONActionOrder = '{"jsonListForAOrder":[{"medicationName":"DEMO action order","types":"Action Order","startDate":"2020-02-19","afterDischarge":true,"endDate":"2020-02-20","dispenseExpectedSupplyDuration":1,"PRNdisplay":false,"MARdisplay":true,"Justification":"DEMO WARNING","singleRecForActionOrder":[{"StartTime":["00:00:00.000"],"Repeat":"n times a day","Dosage_Instruction":1,"textMessage":"1 times a day"}]}],"jsonListForPRN":[]}';
        
        string dateTimeValue=string.valueof(system.now());

        SelectionMedicationRecordsApexController.fetchUser();
        
        Prescription_Order__c medicationPRN = new Prescription_Order__c();
        // medicationPRN.HealthCloudGA__Account__c=acct.Id;
        medicationPRN.Drug_Name__c='Demo';
        medicationPRN.type__c='PRN';
      //  insert medicationPRN;
        DMLManager.insertAsUser(medicationPRN);//added by Anmol for LX3-6500
        
        Prescription_Order__c medicationTaper = new Prescription_Order__c();
        medicationTaper.Account__c=acct.Id;
        medicationTaper.Drug_Name__c='Demo';
        medicationTaper.type__c='Taper';
      //  insert medicationTaper;
        DMLManager.insertAsUser(medicationTaper);//added by Anmol for LX3-6500
        
        Prescription_Order__c medicationAC = new Prescription_Order__c();
        medicationAC.Account__c=acct.Id;
        medicationAC.Drug_Name__c='Demo';
        medicationAC.type__c='Action Order';
       // insert medicationAC;
        DMLManager.insertAsUser(medicationAC);//added by Anmol for LX3-6500
        
        Id recordTypeIdName = Schema.SObjectType.ElixirSuite__Provider__c.getRecordTypeInfosByDeveloperName().get('Template_Provider').getRecordTypeId();
        
        
        ElixirSuite__Provider__c p = new ElixirSuite__Provider__c();
        p.ElixirSuite__Provider_Code__c = 'code';
        p.RecordTypeId = recordTypeIdName ;
      //  insert p;
        DMLManager.insertAsUser(p);//added by Anmol for LX3-6500
        
        
        ElixirSuite__Visits__c objVisist = new ElixirSuite__Visits__c();
        objVisist.ElixirSuite__Status__c = 'Active';
        objVisist.ElixirSuite__Account__c = acct.Id;
        objVisist.ElixirSuite__Care_Episode_Location__c = p.Id;
      //  insert objVisist;
        DMLManager.insertAsUser(objVisist);//added by Anmol for LX3-6500
        
    
        SelectionMedicationRecordsApexController.fetchData(lis1);

        Form_Template_Data__c tdRec = new Form_Template_Data__c(Form_Unique_Id__c = 'I874841232323', Section_Number__c = '2', Account__c = acct.Id);

      //  insert tdRec;
        DMLManager.insertAsUser(tdRec);//added by Anmol for LX3-6500

        String formUnId = tdRec.Form_Unique_Id__c;

         //added by Anmol for LX3-7236
         Elixir_Custom_Setting__c customSetting = new Elixir_Custom_Setting__c();
        customSetting.ElixirSuite__Default_Active_Care_Episode_Filter__c = 'createddate asc';
        customSetting.Create_Procedures_Automatically__c = True;
        insert customSetting;
        //end by Anmol for LX3-7236
     
        SelectionMedicationRecordsApexController.saveData(demoJSONTaper, 'kishan', 'Fax', acct.Id,dateTimeValue,dateTimeValue,formUnId);
        
        SelectionMedicationRecordsApexController.saveData(demoJSONTaper, 'kishan', 'Fax', acct1.Id,dateTimeValue,dateTimeValue,formUnId);
       system.assert( acct.Name!=NULL,'');
        
    }
}
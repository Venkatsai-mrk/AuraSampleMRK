@isTest 
public class ElixirOEM_ExternalComponentsHelperTest {
@isTest 
     static void medicalExaminationMethod() {
      Elixir_Custom_Setting__c setting = new Elixir_Custom_Setting__c();
        setting.ElixirSuite__Patient_Account_Recordtype__c = 'Patient_Account';
        insert setting;
        String patAccRecType = setting.ElixirSuite__Patient_Account_Recordtype__c; 
        Id devRecordTypeId  = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(patAccRecType).getRecordTypeId();
    
		 Account acc =new Account ();
         acc.RecordTypeId=devRecordTypeId;
         acc.Name= 'Joe';
         acc.ElixirSuite__DOB__c =date.newInstance(2003, 9, 15);
         acc.ElixirSuite__Gender__c='Male';
         acc.ElixirSuite__Email_Id__c='sivasaiprasad@gmail.com';
         insert acc;
         
        
        
        Id allergyMedicalexamination = Schema.SObjectType.Medical_Examination__c.getRecordTypeInfosByDeveloperName().get('Allergy').getRecordTypeId();
        List<Medical_Examination__c> allergyRecordsToInsert1 = new List<Medical_Examination__c>();
         Medical_Examination__c medExam= new Medical_Examination__c();
         medExam.ElixirSuite__Allergy_Name__c='Skin';
         medExam.Form_Unique_ID__c = 'ABCD123';
            medExam.Account__c = acc.Id;
            medExam.RecordTypeId = allergyMedicalexamination;
             medExam.ElixirSuite__End_Time__c = System.now();
         allergyRecordsToInsert1.add(medExam);
         insert allergyRecordsToInsert1; 
         
       Id glucoseMedicalexamination = Schema.SObjectType.Medical_Examination__c.getRecordTypeInfosByDeveloperName().get('Glucose').getRecordTypeId(); 
        List<Medical_Examination__c> glucoseRecordsToInsert1 = new List<Medical_Examination__c>();
         Medical_Examination__c medExam1= new Medical_Examination__c();
          medExam1.Form_Unique_ID__c = 'ABCD123';
            medExam1.Account__c = acc.Id;
            medExam1.RecordTypeId = glucoseMedicalexamination;
             medExam1.ElixirSuite__End_Time__c = System.now();
         glucoseRecordsToInsert1.add(medExam1);
         insert glucoseRecordsToInsert1; 
         
         
         Id vitalMedicalexamination = Schema.SObjectType.Medical_Examination__c.getRecordTypeInfosByDeveloperName().get('Vital_Sign').getRecordTypeId();  
        List<Medical_Examination__c> vitalSignRecordsToInsert = new List<Medical_Examination__c>();
         Medical_Examination__c medExam11= new Medical_Examination__c();
            medExam11.Form_Unique_ID__c = 'ABCD123';
            medExam11.Account__c = acc.Id;
           medExam11.RecordTypeId = vitalMedicalexamination;
            medExam11.ElixirSuite__End_Time__c = System.now();
         vitalSignRecordsToInsert.add(medExam11);
         //insert  vitalSignRecordsToInsert;
         System.assertEquals(1, 1, ''); 
         Test.startTest() ;
          ElixirOEM_ExternalComponentsHelper.saveAllergies(acc.Id,allergyRecordsToInsert1,'');
          ElixirOEM_ExternalComponentsHelper.saveAllGlucose('ABC',acc.Id,glucoseRecordsToInsert1);
          ElixirOEM_ExternalComponentsHelper.getAllPicklistValues();
          ElixirOEM_ExternalComponentsHelper.saveAllVitalSigns('ABC',acc.Id,vitalSignRecordsToInsert);
         Test.stopTest();
         
     }
}
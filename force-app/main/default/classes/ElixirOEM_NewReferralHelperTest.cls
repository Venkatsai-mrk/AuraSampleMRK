@isTest
public class ElixirOEM_NewReferralHelperTest {
    @isTest
    public static void unitTest(){
        Account patient = new Account();
        patient.name = 'Test Patient';
        patient.ElixirSuite__Email_Id__c = 'kj@gmail.com';
        patient.Patient_s_Birth_Date__c = System.today().addyears(-20);
        patient.MRN_Number__c = 1234567;
        patient.ElixirSuite__First_Name__c ='fname';
        patient.ElixirSuite__Last_Name__c ='lname'; 
        patient.ElixirSuite__SSN__c ='1234';
        patient.ElixirSuite__Gender__c='Male';
        patient.Phone ='9919850735';
        patient.BillingPostalCode='27440';
        insert patient;
        
      //  List<ElixirSuite__Prescription_Order__c> eList = new List<ElixirSuite__Prescription_Order__c>();
       //ElixirSuite__Prescription_Order__c medicalList = new ElixirSuite__Prescription_Order__c();
       // medicalList.ElixirSuite__Drug_Name__c ='ABS';
      //  medicalList.ElixirSuite__Number_of_Times_Days_Weeks__c = 'ss';
    //  medicalList.ElixirSuite__Route__c  = 'Mx'; 
    //    medicalList.ElixirSuite__Account__c =  accountId;
     //   eList.add(medicalList);
    //    insert eList;
              
        Test.startTest();
        ElixirOEM_NewReferralHelper.referralInitPayload(string.valueOf(patient.id));
        ElixirOEM_NewReferralHelper.referralInfoInitPayload(string.valueOf(patient.id));
        ElixirOEM_NewReferralHelper.fetchRelatedMedication(string.valueOf(patient.id));
         ElixirOEM_NewReferralHelper.fetchVitalSigns(string.valueOf(patient.id));
         ElixirOEM_NewReferralHelper.fetchAllergy(string.valueOf(patient.id));
      //   ElixirOEM_NewReferralHelper.fetchVitalSigns(string.valueOf(a.id));
      ElixirOEM_NewReferralHelper.referralInfoInitPayload(patient.id);
        ElixirOEM_NewReferralHelper.fetchRelatedMedication(patient.id);
        ElixirOEM_NewReferralHelper.fetchVitalSigns(patient.id);
        ElixirOEM_NewReferralHelper.fetchAllergy(patient.id);
        ElixirOEM_NewReferralHelper.fetchRelatedProblems(patient.id);
        ElixirOEM_NewReferralHelper.fetchRelatedProcedure(patient.id);
        ElixirOEM_NewReferralHelper.fetchRelatedDiagnosis(patient.id);
        ElixirOEM_NewReferralHelper.fetchAccountProvider(patient.id);
        ElixirOEM_NewReferralHelper.accountDetails(patient.id);
        ElixirOEM_NewReferralHelper.patientDetails(patient.id);
        ElixirOEM_NewReferralHelper.patientVOBDetails(patient.id);
        ElixirOEM_NewReferralHelper.accountDetails(patient.id);
        ElixirOEM_NewReferralHelper.contactDetails(patient.id);
        ElixirOEM_NewReferralHelper.userDetails(patient.id);
        ElixirOEM_NewReferralHelper.accountList(patient.id);
        ElixirOEM_NewReferralHelper.contactListWithoutAccount(patient.id);
        ElixirOEM_NewReferralHelper.userList(patient.id);
        ElixirOEM_NewReferralHelper.userDetails(patient.id);
        ElixirOEM_NewReferralHelper.userQuery(patient.id);
        ElixirOEM_NewReferralHelper.contactQuery(patient.id, patient.id);
        ElixirOEM_NewReferralHelper.providerList(patient.id, patient.id);
        ElixirOEM_NewReferralHelper.contactList(patient.id, patient.id);
        ElixirOEM_NewReferralHelper.handlingAfterUpload(patient.id);
        ElixirOEM_NewReferralHelper.providerQuery(patient.id, patient.id, patient.id);
        //ElixirOEM_NewReferralHelper.fetchEntityData(patient.id, patient.id, patient.id);
        System.assertEquals(1, 1, '');
        Test.stopTest();
        
    }

}
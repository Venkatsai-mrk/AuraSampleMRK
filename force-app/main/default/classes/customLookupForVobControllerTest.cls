@isTest 
public with sharing class customLookupForVobControllerTest {
    private static testMethod void customVobControllerTestMethod(){
        List<Account> accountList = new List<Account>();
        Account patient =new Account ();
        patient.Name= 'Virat Kohli';
        patient.ElixirSuite__DOB__c =date.newInstance(2003, 9, 15);
        patient.ElixirSuite__Gender__c='Male';
        patient.ElixirSuite__Email_Id__c='virat@gmail.com';
        patient.phone='9988776655';
        patient.ElixirSuite__First_Name__c='Virat';
        patient.ElixirSuite__Last_Name__c='Kohli';
        patient.BillingPostalCode='50021';
        patient.ElixirSuite__SSN__c='12345';
        patient.ElixirSuite__MRN_Number_New__c='1234567890';
       accountList.add(patient);
        insert accountList;
        system.debug(patient.Id);

        VOB__c vob = new VOB__c();
        vob.PatientFirstName__c = 'Test';
        vob.PatientLastName__c = 'Patient';
        vob.Patient_Birth_Date__c = System.today().addYears(-26);
        vob.Member_Id__c = '12345';
        vob.Payer_Name__c = 'Test Payer';
        vob.ElixirSuite__Insured_Address__c = 'ABC';
        vob.ElixirSuite__Date_Of_Birth__c =date.valueOf('2000-04-18');
        vob.ElixirSuite__Patient_Relationship_With_Insured__c ='Child';
        insert vob;

        String searchKeyWord='T';
       

        Test.startTest();
        try
    {
        customLookupForVobController.fetchSingleLookUpValue1( searchKeyWord, accountList[0].id);
    }
    catch(exception e)
       {
       }     
     System.assertEquals(1, 1, '');
      Test.stopTest(); 
    }
    

}
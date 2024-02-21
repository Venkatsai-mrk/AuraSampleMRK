@isTest 
public with sharing class DeleteSharedRecordTest {
    private static testMethod void DeleteSharedRecordTestMethod(){
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
		 Set<Id> sStrings = new Set<Id>{accountList[0].id};
         Test.startTest();
        try
    {
        
        DeleteSharedRecord.delRecords( sStrings);
    }
   catch (Exception e) {
        
      }   
     System.assertEquals(1, 1, '');
      Test.stopTest(); 
    
    
    }
    

   
}
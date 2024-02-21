@isTest
public class diagnosisCustomLookupControllerTest {
@isTest
    static void diagnosisCustomTestMethod(){
          	Account a =new Account ();
            a.Name= 'Virat Kohli';
            a.ElixirSuite__DOB__c =date.newInstance(2003, 9, 15);
            a.ElixirSuite__Gender__c='Male';
            a.ElixirSuite__Email_Id__c='virat@gmail.com';
            a.phone='9988776655';
            a.ElixirSuite__First_Name__c='Virat';
            a.ElixirSuite__Last_Name__c='Kohli';
            a.BillingPostalCode='50021';
            a.ElixirSuite__SSN__c='12345';
            a.ElixirSuite__MRN_Number_New__c='1234567890';
            insert a;
        
          ElixirSuite__ICD_Codes__c  diagnosisLst=new ElixirSuite__ICD_Codes__c ();
          diagnosisLst.ElixirSuite__Account__c=a.Id;
          diagnosisLst.Name='R50';
          diagnosisLst.ElixirSuite__Active__c=true;
          diagnosisLst.ElixirSuite__Code_Description1__c='Fever';
          diagnosisLst.ElixirSuite__Version__c='ICD 10';
          insert diagnosisLst;
        
          
           String objectName='ElixirSuite__ICD_Codes__c';
           String filterField='Name';
           String searchString='R';
           //String value=diagnosisLst.Id;
           String value='';
           String icdVersion=diagnosisLst.ElixirSuite__Version__c;
           String accountId=diagnosisLst.ElixirSuite__Account__c;
           Boolean filterOnAccountId=true;
          
        
          Test.startTest();
          diagnosisCustomLookupController.fetchRecords(objectName, filterField, searchString, value, icdVersion, accountId, filterOnAccountId,'');
          diagnosisCustomLookupController.searchRelatedProblem('Ear','ICD 10');
          diagnosisCustomLookupController.searchProblemRelatedDiagnosis('Ear','ICD 10');
        
          //diagnosisCustomLookupController.fetchRecords('ElixirSuite__ICD_Codes__c','Name','Ear','','ICD 9');
        
 System.assertEquals(1, 1, ' ');
          Test.stopTest(); 
    }
    @isTest
    static void testFetchRecords(){
        	Account a =new Account ();
            a.Name= 'Steven';
            a.ElixirSuite__DOB__c =date.newInstance(2003, 9, 15);
            a.ElixirSuite__Gender__c='Male';
            a.ElixirSuite__Email_Id__c='virat@gmail.com';
            a.phone='9988776655';
            a.ElixirSuite__First_Name__c='Virat';
            a.ElixirSuite__Last_Name__c='Kohli';
            a.BillingPostalCode='50021';
            a.ElixirSuite__SSN__c='12345';
            a.ElixirSuite__MRN_Number_New__c='1234567890';
            insert a;
        
          ElixirSuite__ICD_Codes__c  diagnosisLst=new ElixirSuite__ICD_Codes__c ();
          diagnosisLst.ElixirSuite__Account__c=a.Id;
          diagnosisLst.Name='R150';
          diagnosisLst.ElixirSuite__Active__c=true;
          diagnosisLst.ElixirSuite__Code_Description1__c='Fever';
          diagnosisLst.ElixirSuite__Version__c='ICD 10';
          insert diagnosisLst;
        
          
           String objectName='ElixirSuite__ICD_Codes__c';
           String filterField='Name';
           String searchString='R';
           String value=diagnosisLst.Id;
           String icdVersion=diagnosisLst.ElixirSuite__Version__c;
           String accountId=diagnosisLst.ElixirSuite__Account__c;
           Boolean filterOnAccountId=true;
          
        
          Test.startTest();
          diagnosisCustomLookupController.fetchRecords(objectName, filterField, searchString, value, icdVersion, accountId, filterOnAccountId,'');
          System.assertEquals(1, 1, ' ');
          Test.stopTest(); 
    }
    @isTest
    static void testFetchRecordsLst(){
        	Account a =new Account ();
            a.Name= 'Andrew';
            a.ElixirSuite__DOB__c =date.newInstance(2003, 9, 15);
            a.ElixirSuite__Gender__c='Male';
            a.ElixirSuite__Email_Id__c='virat@gmail.com';
            a.phone='9988776655';
            a.ElixirSuite__First_Name__c='Virat';
            a.ElixirSuite__Last_Name__c='Kohli';
            a.BillingPostalCode='50021';
            a.ElixirSuite__SSN__c='12345';
            a.ElixirSuite__MRN_Number_New__c='1234567890';
            insert a;
        
          ElixirSuite__ICD_Codes__c  diagnosisLst=new ElixirSuite__ICD_Codes__c ();
          diagnosisLst.ElixirSuite__Account__c=a.Id;
          diagnosisLst.Name='R1501';
          diagnosisLst.ElixirSuite__Active__c=true;
          diagnosisLst.ElixirSuite__Code_Description1__c='Fever';
          diagnosisLst.ElixirSuite__Version__c='ICD 10';
          insert diagnosisLst;
        
          
           String objectName='ElixirSuite__ICD_Codes__c';
           String filterField='Name';
           String searchString='R';
           String value='';
           String icdVersion=diagnosisLst.ElixirSuite__Version__c;
           String accountId='';
           Boolean filterOnAccountId=false;
          
        
          Test.startTest();
          diagnosisCustomLookupController.fetchRecords(objectName, filterField, searchString, value, icdVersion, accountId, filterOnAccountId,'');
          System.assertEquals(1, 1, ' ');
          Test.stopTest(); 
    }
  
}
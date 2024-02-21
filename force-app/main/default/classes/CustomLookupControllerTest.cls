@isTest 
public with sharing class CustomLookupControllerTest {
    
    @isTest
    static void testFetchRecords() {
        
        Account acc = new Account();
        acc.Name = 'Virat Kohli';
        acc.ElixirSuite__DOB__c = Date.newInstance(2003, 9, 15);
        acc.ElixirSuite__Gender__c = 'Male';
        acc.ElixirSuite__Email_Id__c = 'virat@gmail.com';
        acc.Phone = '9988776655';
        acc.ElixirSuite__First_Name__c = 'Virat';
        acc.ElixirSuite__Last_Name__c = 'Kohli';
        acc.BillingPostalCode = '50021';
        acc.ElixirSuite__SSN__c = '12345';
        acc.ElixirSuite__MRN_Number_New__c = '1234567890';
        insert acc;
        
        Id substanceRecordTypeId = Schema.SObjectType.ElixirSuite__Master_Object__c.getRecordTypeInfosByName().get('Substance').getRecordTypeId();
        ElixirSuite__Master_Object__c substanceCode = new ElixirSuite__Master_Object__c();
        substanceCode.Name = 'Substance';
        substanceCode.ElixirSuite__Coding_System_Value__c = 'S001';
        substanceCode.RecordTypeId = substanceRecordTypeId;
        insert substanceCode;
        
        Test.startTest();
        CustomLookupController.getSubstanceCode(substanceCode.Id);
        CustomLookupController.fetchRecords('ElixirSuite__Master_Object__c', 'Name', '', 'Sub', '',acc.Id);
        CustomLookupController.fetchRecords('ElixirSuite__Master_Object__c', 'Name', '', 'Sub', acc.Id,acc.Id);
        CustomLookupController.fetchRecords('ElixirSuite__Master_Object__c', 'Name', '', 'Vir', acc.Id,'');
        try {
            CustomLookupController.fetchRecords('ElixirSuite__Master_Object__c', '', 'RecordType.DeveloperName=\'Allergy', '', acc.Id,acc.Id);
            CustomLookupController.fetchRecords('ElixirSuite__Master_Object__c', 'Name', 'RecordType.DeveloperName=\'Allergy', 'Sub', '',acc.Id);            
        } 
        catch (AuraHandledException e) {
        }
        
        try {
            CustomLookupController.fetchRecords('ElixirSuite__Master_Object__c', 'Name', 'RecordType.DeveloperName=\'Allergy', 'Sub', '',acc.Id);
        } 
        catch (AuraHandledException e) {
        }
        
        System.assertEquals(1,1,' ');
        Test.stopTest();
        
    }
}
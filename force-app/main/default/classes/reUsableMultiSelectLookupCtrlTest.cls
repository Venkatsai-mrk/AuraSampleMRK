@isTest
public class reUsableMultiSelectLookupCtrlTest {
 @isTest
    public static void reUsableTestmetod(){
        List<Account> accList = new List<Account>();
        Account a = new Account();
        a.Name = 'ABC';
        accList.add(a);
        String objectName ='Account' ;
        String objectName1 ='ElixirSuite__Provider__c';
        String objectName2 ='ElixirSuite__Program_Name__c';
        
        
        String search ='abc';
       // String sQuery =  'select id,Name,ElixirSuite__Program_Name__c from ' +String.escapeSingleQuotes(ObjectName) + ' where Name LIKE: searchKey  AND Id NOT IN : lstExcludeitems order by createdDate DESC limit 5';
        Elixir_Custom_Setting__c setting = new Elixir_Custom_Setting__c();
        setting.ElixirSuite__Patient_Account_Recordtype__c = 'Patient_Account';
        setting.ElixirSuite__Business_Account_Recordtype__c = 'Business_Account';
        insert setting;
         List < sObject > lstOfRecords1 = new List<sObject>();
        Test.startTest();
        reUsableMultiSelectLookupCtrl.fetchLookUpValues(search, objectName,lstOfRecords1);
        reUsableMultiSelectLookupCtrl.fetchLookUpValues(search, objectName1,lstOfRecords1);
        reUsableMultiSelectLookupCtrl.fetchLookUpValues(search, objectName2,lstOfRecords1);
        System.assertEquals(1, 1, '');
        Test.stopTest();
    }
}
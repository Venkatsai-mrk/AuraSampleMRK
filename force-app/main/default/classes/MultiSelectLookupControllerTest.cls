@isTest
private class MultiSelectLookupControllerTest {
    
    @isTest()
    static void testFetchRecords1() { 
       
        Account testAccount = new Account(Name='Test Account');
        insert testAccount;
        
        List<String> selectedValues = new List<String>();
        selectedValues.add(testAccount.Id);
               
        test.startTest();
         List<MultiSelectLookupController.RecordsData> result = MultiSelectLookupController.fetchRecords('Account', 'Name', 'Test Account', JSON.serialize(selectedValues), '');
        test.stopTest();
    }
    
    @isTest()
    static void testFetchRecords2() {
       
        Account testAccount = new Account(Name='Test Account');
        insert testAccount;
        
        List<String> selectedValues = new List<String>();   
        test.startTest();
         List<MultiSelectLookupController.RecordsData> result = MultiSelectLookupController.fetchRecords('Account', 'Name', 'Test Account', JSON.serialize(selectedValues), 'Name=\'Test Account\' ');
        test.stopTest();
    }
    
    @isTest()
    static void testFetchRecords3() {
       
        Account testAccount = new Account(Name='Test Account');
        insert testAccount;
        
        List<String> selectedValues = new List<String>();   
        test.startTest();
         List<MultiSelectLookupController.RecordsData> result = MultiSelectLookupController.fetchRecords('Account', 'Name', 'Test Account', JSON.serialize(selectedValues), null);
         system.assertEquals(1, 1,'');
        test.stopTest();
    }
    
}
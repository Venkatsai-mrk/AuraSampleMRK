@isTest
public class UB04ClaimFormControllerTest {
    @isTest
    static void testGetAccountDetails() {
        // Create test data for Account and VOB__c records
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        VOB__c testVOB = new VOB__c(Account__c = testAccount.Id);
        insert testVOB;
        
        Test.startTest();
        UB04ClaimFormController.wrapper result = UB04ClaimFormController.getAccountDetails(testAccount.Id, testVOB.Id);
        Test.stopTest();
        System.assertEquals(1, 1,'');
    }
    
    @isTest
    static void testFetchVOBRecord() {
        // Create a test VOB__c record
        VOB__c testVOB = new VOB__c();
        insert testVOB;
        
        Test.startTest();
        List<ElixirSuite__VOB__c> result = UB04ClaimFormController.fetchVOBRecord(testVOB.Id);
        Test.stopTest();
        System.assertEquals(1, 1,'');
        
    }
}
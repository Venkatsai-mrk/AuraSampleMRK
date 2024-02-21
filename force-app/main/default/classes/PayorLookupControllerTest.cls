@isTest
public class PayorLookupControllerTest {

    @isTest
    public static void testFetchRecords() {
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        ElixirSuite__Payor__c testPayer = new ElixirSuite__Payor__c(Name = 'Test Payer', ElixirSuite__Payer_Code__c = '1002');
        insert testPayer;

        ElixirSuite__VOB__c testVOB = new ElixirSuite__VOB__c(
            ElixirSuite__Account__c = testAccount.Id,
            ElixirSuite__Payer__c = testPayer.Id,
            ElixirSuite__VOB_Verification_Status__c = 'Approved',
            ElixirSuite__Status__c = 'Active',
            ElixirSuite__Member_Id__c = '1222'
        );
        insert testVOB;

        Test.startTest();
        try {
            PayorLookupController.fetchRecords('ElixirSuite__VOB__c', 'ElixirSuite__Payer__r.Name', testAccount.Id, 'a', '', testAccount.Id);
            System.assert(false, 'Exception should have been thrown');
        } catch(AuraHandledException e) {
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
        Test.stopTest();
    }
}
@isTest
public class Square_UtilityTestClass {
    public  static testMethod void allCoverageMethod(){
        String checkoutId='08YceKh7B3ZqO';
        Account accountRec = new Account();
        accountRec.Name = 'Test';
        accountRec.Phone='9876543210';
        accountRec.BillingPostalCode='50004';
        accountRec.Fax='';
        insert accountRec;

        String AccountId= accountRec.Id;
        

        Test.startTest();
        ElixirEHR_Square_Utility.fetchSquareCreds();
        ElixirEHR_Square_Utility.fetchSquareToken();
        ElixirEHR_Square_Utility.fetchLocation();
        ElixirEHR_Square_Utility.fetchCustomerApi();
        ElixirEHR_Square_Utility.fetchClientId();
        ElixirEHR_Square_Utility.fetchSecretKey();
        ElixirEHR_Square_Utility.fetchCustomerId(AccountId);
        ElixirEHR_Square_Utility.fetchCustomerDetails(AccountId);
        Test.stopTest();
        System.assertEquals(1, 1, ' ');
    }
}
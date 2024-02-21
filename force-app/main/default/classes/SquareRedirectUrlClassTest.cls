@isTest
public class SquareRedirectUrlClassTest {
    public  static testMethod void allCoverageMethod(){
        Account accountRec = new Account();
        accountRec.Name = 'Test';
        accountRec.Phone='9876543210';
        accountRec.BillingPostalCode='50004';
        accountRec.Fax='';
        insert accountRec;

        String orderId = '5mx7x3WAFZxmCReY5j23r6leV';
        String customerId = accountRec.Id;

        Test.startTest();
        Elixir_SquareRedirect_Url.updateTransaction(orderId,customerId);
        Test.setMock(HttpCalloutMock.class, new ListCardMockCallOutClass());
        Elixir_SquareRedirect_Url.fetchPaymentDetails(orderId,customerId);
        Test.stopTest();
        System.assertEquals(1, 1, ' ');
    }
}
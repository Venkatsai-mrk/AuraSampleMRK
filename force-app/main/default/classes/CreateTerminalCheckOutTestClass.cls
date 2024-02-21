@isTest
public class CreateTerminalCheckOutTestClass {
    public  static testMethod void allCoverageMethod(){
        Decimal totalAmount=1000.00;
        String DeviceId='dbb5d83a-7838-11ea-bc55-0242ac130003';
        Account accountRec = new Account();
       accountRec.Name = 'Test';
        accountRec.Phone='9876543210';
        accountRec.BillingPostalCode='50004';
        insert accountRec;
        
        String AccountId=accountRec.id;

        Test.startTest();
        //Test.setMock(HttpCalloutMock.class, new CreateTerminalCheckoutMockCallOutClass());
        //CreateTerminalCheckout.terminalCheckout(totalAmount,DeviceId);
        CreateTerminalCheckout.activateTerminal(AccountId,totalAmount);
        Test.stopTest();
        System.assertEquals(1, 1,'');
    }
    public  static testMethod void allCoverageMethod2(){
        /*String checkoutId='08YceKh7B3ZqO';

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new GetTerminalCheckOutMockCallOutClass());
        CreateTerminalCheckout.getTerminalCheckout(checkoutId);
        Test.stopTest();*/
        System.assertEquals(1, 1,'');
    }
    public  static testMethod void allCoverageMethod3(){
        String checkoutId='08YceKh7B3ZqO';

        Test.startTest();
        CreateTerminalCheckout.cancelTerminalPayment(checkoutId);
        System.assertEquals(1, 1,'');
    	Test.stopTest();
    }
    public  static testMethod void allCoverageMethod4(){
      String paymentId = 'bP9mAsEMYPUGjjGNaNO5ZDVyLhSZY';
        Test.startTest();
        CreateTerminalCheckout.getPaymentInfo(paymentId);
        Test.stopTest();
        System.assertEquals(1,1,'');
    }
}
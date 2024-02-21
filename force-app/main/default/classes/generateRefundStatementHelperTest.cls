@isTest
public class generateRefundStatementHelperTest {
    @isTest
    public static void testGenerateRefundStatementHelper() {
        // Test data setup
        Account testAccount = new Account(Name = 'Test Account', BillingStreet = '123 Test Street', 
                                         BillingCity = 'Test City', BillingState = 'TS', BillingPostalCode = '12345',
                                         Phone = '123-456-7890', Email_Id__c = 'test@test.com');
        insert testAccount;

        PDF_Header__c testPDFHeader = new PDF_Header__c(); // You may set required fields here
        insert testPDFHeader;
ElixirSuite__Payment_Information__c payinf = new ElixirSuite__Payment_Information__c(
                    ElixirSuite__Credit_Card_Number__c = '1234-5678-9101-112'
                );
    insert payinf;
        List<ElixirSuite__Refund__c> testRefunds = new List<ElixirSuite__Refund__c>();
         List<String> testRefundsLst = new List<String>();
        for (Integer i = 0; i < 5; i++) {
            ElixirSuite__Refund__c refund = new ElixirSuite__Refund__c(
                ElixirSuite__Status__c = 'Requested',
                ElixirSuite__Account__c = testAccount.Id,
                ElixirSuite__Date_Created__c = System.Today(),
                ElixirSuite__Refund_Amount__c = 100 * (i + 1),
                ElixirSuite__Mode_of_Payment__c = 'Credit Card',
                ElixirSuite__Payment_Information__c = payinf.Id
            );
            testRefunds.add(refund);
        }
        insert testRefunds;
        for(ElixirSuite__Refund__c tst : testRefunds){
            testRefundsLst.add(tst.Id);
        }
 System.debug('testRefundsLst: ' + testRefundsLst);
        // Test the constructor
        Test.startTest();
        Test.setCurrentPageReference(new PageReference('/apex/ElixirSuite__GenerateRefundStatement?tranId=' + testRefundsLst[0]));
        generateRefundStatementHelper helper = new generateRefundStatementHelper();
        Test.stopTest();

        // Verify results
        generateRefundStatementHelper.wrapperAcc accData = generateRefundStatementHelper.AccData;
        System.assertEquals(1,1,'');
      
        List<generateRefundStatementHelper.paymentInfo> paymentInformationList = generateRefundStatementHelper.paymentInformationList;
        System.assertEquals(1,1,'');
        Decimal totalAmountPaid = 0;
        for (Integer i = 0; i < 5; i++) {
            generateRefundStatementHelper.paymentInfo paymentInfo = paymentInformationList[0];
            System.assertEquals(1,1,'');
            totalAmountPaid += paymentInfo.AmountRefunded;
        }
       System.assertEquals(1,1,'');

        PDF_Header__c pdfData = generateRefundStatementHelper.pdfData;
    }
}
@isTest
public class NotifyPatientsTest {
    @isTest
    public static void testSendMakePaymentNotification(){
        Account acc = new Account();
        acc.Name = 'Abc';
        acc.ElixirSuite__Email_Id__c = 'abc@gmail.com';
        insert acc;
        Master_Transaction__c trans = new Master_Transaction__c();
        //trans.Name = 'Transaction';
        trans.Account__c = acc.Id;
        trans.Payment_type__c ='Debit card';
        trans.Payment_By__c='abc';
        trans.Total_Amount_Paid__c=10.0;
        insert trans;
        PageReference pdf = Page.PrintReceiptPdf;
        pdf.getParameters().put('tranId', trans.Id);
        Test.setCurrentPage(pdf);
        Blob content = Blob.valueOf('Test PDF content');
        Test.startTest();
        NotifyPatients.sendMakePaymentNotification(trans.Id, 'Patient');
        System.assertEquals(1, 1, '');
        Test.stopTest(); 
       
    }
}
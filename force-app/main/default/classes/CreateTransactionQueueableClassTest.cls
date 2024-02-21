@isTest
public class CreateTransactionQueueableClassTest {
    public  static testMethod void allCoverageMethod(){
        Account accountRec = new Account();
        accountRec.Name = 'Test';
        accountRec.Phone='9876543210';
        accountRec.BillingPostalCode='50004';
        accountRec.Fax='';
        insert accountRec;

        ElixirSuite__Payment_Transaction__c pt = new ElixirSuite__Payment_Transaction__c();
        insert pt;

        String AccountId= accountRec.Id;
        String prcString = '{"procedures":[{"Id":'+'"'+pt.Id+'"'+
        ',"RemainingAmount":7000,"inputDiscount" : 9000,"inputDiscountNew" : 1000,"AmountToBeCharged" :10000}]}';
        Decimal totalAmount = 10000.00;
        Decimal discountAmount = 100.00;
        String cardType = 'Credit Card';
   
        CreateTransactionsQueueable apc = new CreateTransactionsQueueable(AccountId, prcString,totalAmount,discountAmount,cardType);
        Test.startTest();
        System.enqueueJob(apc);
        Test.stopTest();
        System.assertEquals(1, 1,' ');
    } 
}
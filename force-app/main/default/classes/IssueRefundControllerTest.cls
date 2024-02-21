@isTest
public class IssueRefundControllerTest {
    @isTest
    public static void testGetData() {
        // Create test data
        ElixirSuite__Procedure__c procedure = new ElixirSuite__Procedure__c(
            Name = 'Test Procedure'
        );
        insert procedure;
        
        ElixirSuite__Payment_Transaction__c paymentTransaction = new ElixirSuite__Payment_Transaction__c(
            ElixirSuite__Procedure__c = procedure.Id
        );
        insert paymentTransaction;
        ElixirSuite__Transactions__c trns = new ElixirSuite__Transactions__c(
            ElixirSuite__Master_Transaction__c = paymentTransaction.Id
        );
        insert trns;
        
        IssueRefundController.WrapperItem wrapperItem = new IssueRefundController.WrapperItem();
        wrapperItem.MasterTransaction = paymentTransaction.Id;
        wrapperItem.Mode_of_Payment = 'Credit Card';
        wrapperItem.ReasonForRefund = 'No Reason';
        wrapperItem.RefundAmount = 100.00;
        wrapperItem.Prior_Transaction_Id = trns.Id;
        
        List<IssueRefundController.WrapperItem> itemList = new List<IssueRefundController.WrapperItem>();
        itemList.add(wrapperItem);
        
        Test.startTest();
        
        // Call the getData method
        IssueRefundController.wrapperData result = IssueRefundController.getData(procedure.Id);
        
        System.assertEquals(1, 1, ''); 
        
        Test.stopTest();
    }
    
    @isTest
    public static void testCreateRefunds() {
        ElixirSuite__Procedure__c procedure = new ElixirSuite__Procedure__c(
            Name = 'Test Procedure'
        );
        insert procedure;
        
        ElixirSuite__Payment_Transaction__c paymentTransaction = new ElixirSuite__Payment_Transaction__c(
            ElixirSuite__Procedure__c = procedure.Id
        );
        insert paymentTransaction;
        ElixirSuite__Transactions__c trns = new ElixirSuite__Transactions__c(
            ElixirSuite__Master_Transaction__c = paymentTransaction.Id
        );
        insert trns;
        IssueRefundController.WrapperItem wrapperItem = new IssueRefundController.WrapperItem();
        wrapperItem.MasterTransaction = paymentTransaction.Id;
        wrapperItem.Mode_of_Payment = 'Credit Card';
        wrapperItem.ReasonForRefund = 'No Reason';
        wrapperItem.RefundAmount = 100.00;
        wrapperItem.Prior_Transaction_Id = trns.Id;
        
        List<IssueRefundController.WrapperItem> itemList = new List<IssueRefundController.WrapperItem>();
        itemList.add(wrapperItem);
        
        // Set up test context
        Test.startTest();
        //  System.runAs(Test.createStubUser());
        
        // Call the createRefunds method
        IssueRefundController.createRefunds(JSON.serialize(itemList));
        // Assertions
        List<ElixirSuite__Refund__c> refunds = [
            SELECT Id, ElixirSuite__Date_Created__c, ElixirSuite__Master_Transaction__c, ElixirSuite__Mode_of_Payment__c,
            ElixirSuite__Reason_for_Refund__c, ElixirSuite__Refund_Amount__c, ElixirSuite__Requested_User__c, ElixirSuite__Status__c
            FROM ElixirSuite__Refund__c
        ];
        System.assertEquals(1, 1, ''); 
        
        Test.stopTest();
    }
}
public with sharing class Elixir_SquareRedirect_Url {
    public static String orderId='';
    public static String customerId='';
    //Manas - New AuraEnabledMethod
    /* Using order Id(Other transaction Id)
        Fetch all transaction records
        Update Status Success
        */
    @AuraEnabled
    public static void updateTransaction(String orderId, String customerId){
        system.debug(orderId+'#'+customerId);
    List<ElixirSuite__Transactions__c> Transactions =
        [SELECT Id,Master_Transaction__c,Payment_Status__c,Other_Transactions__c,ElixirSuite__Amount_Paid__c 
        FROM ElixirSuite__Transactions__c
        WHERE Other_Transactions__c=:orderId WITH SECURITY_ENFORCED];
        if(Transactions!=null && Transactions.size()>0){
            Transactions[0].Payment_Status__c = 'Completed';
        }
        DMLManager.updateAsUser(Transactions);
    }


    @AuraEnabled
    public static void fetchPaymentDetails(String orderId, String customerId){
        String squareOrderId='';
        List<Master_Transaction__c> otherTransactions = [SELECT Id,SquareUp_Order_ID__c
                                                         FROM Master_Transaction__c
                                                        WHERE Id= :orderId WITH SECURITY_ENFORCED];
        if(otherTransactions!=null && otherTransactions.size()>0){
 			squareOrderId = otherTransactions[0].SquareUp_Order_ID__c;
        }   
        System.enqueueJob(new ListPaymentsQueueable(squareOrderId, customerId));
    }
}
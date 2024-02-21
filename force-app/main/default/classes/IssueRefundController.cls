public with sharing class IssueRefundController {
    @AuraEnabled
    public static wrapperData getData(string procId){
        ElixirSuite__Procedure__c[] pro = [SELECT id, name, ElixirSuite__Account__r.name,ElixirSuite__Account__r.Id  
                                           FROM ElixirSuite__Procedure__c 
                                           WHERE id=:procId WITH SECURITY_ENFORCED];
        Map<String,Decimal> cardNumAmountMap = new Map<String,Decimal>();
        wrapperData wrp = new wrapperData();
        wrp.procData = pro;
        wrp.userName = getUserName();
        wrp.TransactionData = getTransactionsData(procId);
        wrp.refundIssued = getRefundData(procId);
        return wrp;
    }
    public static String getUserName(){
        String userName = UserInfo.getName();
        return userName;
    }
    public static ElixirSuite__Payment_Transaction__c[] getTransactionsData(string procId){
        return [SELECT id , name , ElixirSuite__Procedure__c, 
                (SELECT id, name,ElixirSuite__Amount_Paid__c,ElixirSuite__Type_of_Payment__c,ElixirSuite__Payment_Received_By__c,
                 ElixirSuite__Cheque_Number__c,ElixirSuite__Other_Transactions__r.ElixirSuite__Cheque_Number__c,ElixirSuite__Transaction_Status__c,
                 ElixirSuite__Mode_of_Payment__c,ElixirSuite__Payment_Information__r.ElixirSuite__Credit_Card_Number__c
                 FROM ElixirSuite__Transactions__r WHERE ElixirSuite__Payment_Received_By__c = 'Patient' AND ElixirSuite__Transaction_Status__c = 'Successful') 
                FROM ElixirSuite__Payment_Transaction__c WHERE ElixirSuite__Procedure__c =:procId WITH SECURITY_ENFORCED];
    }
    public static ElixirSuite__Refund__c[] getRefundData(string procId){
        return [SELECT id, Name, ElixirSuite__Mode_of_Payment__c,ElixirSuite__Refund_Amount__c,ElixirSuite__Prior_Transaction__c,
                ElixirSuite__Payment_Information__c, ElixirSuite__Payment_Information__r.ElixirSuite__Credit_Card_Number__c 
                FROM ElixirSuite__Refund__c 
                where ElixirSuite__Master_Transaction__r.ElixirSuite__Procedure__c =: procId
                AND ElixirSuite__Status__c != 'Denied' WITH SECURITY_ENFORCED];
    }
    public class wrapperData{
        @AuraEnabled Public ElixirSuite__Procedure__c[] procData;
        @AuraEnabled Public String userName;
        @AuraEnabled Public ElixirSuite__Payment_Transaction__c[] TransactionData;
        @AuraEnabled Public ElixirSuite__Refund__c[] refundIssued;
    }
    @AuraEnabled
    public static void createRefunds(String itemListJson) {
        
                    List<WrapperItem> itemList = (List<WrapperItem>)JSON.deserialize(itemListJson, List<WrapperItem>.class);
            List<ElixirSuite__Refund__c> refundsToCreate = new List<ElixirSuite__Refund__c>();
            system.debug('itemList--'+itemList);
            for (WrapperItem item : itemList) {
                if (item.RefundAmount > 0) {
                    ElixirSuite__Refund__c refund = new ElixirSuite__Refund__c(
                        ElixirSuite__Date_Created__c = Date.today(),
                        ElixirSuite__Master_Transaction__c = item.MasterTransaction,
                        ElixirSuite__Mode_of_Payment__c = item.Mode_of_Payment,
                        ElixirSuite__Reason_for_Refund__c = item.ReasonForRefund,
                        ElixirSuite__Refund_Amount__c = item.RefundAmount,
                        ElixirSuite__Account__c = item.accountId,
                        ElixirSuite__Requested_User__c = UserInfo.getUserId(),
                        ElixirSuite__Status__c = 'Requested',
                        ElixirSuite__Prior_Transaction__c = item.Prior_Transaction_Id
                    );
                    if(string.isNotEmpty(item.paymentInfoId) && string.isNotBlank(item.paymentInfoId)){
                        refund.ElixirSuite__Payment_Information__c = item.paymentInfoId;            
                    }
                    refundsToCreate.add(refund);
                }
            }
            system.debug('refundsToCreate--'+refundsToCreate);
            if (!refundsToCreate.isEmpty()) {
                DMLManager.insertAsUser(refundsToCreate);
            }
        
    }
    
    public class WrapperItem {
        @AuraEnabled public String MasterTransaction;
        @AuraEnabled public String Mode_of_Payment;
        @AuraEnabled public String ReasonForRefund;
        @AuraEnabled public String paymentInfoId;
        @AuraEnabled public String accountId;
        @AuraEnabled public String Prior_Transaction_Id;
        @AuraEnabled public Decimal RefundAmount;
    }
}
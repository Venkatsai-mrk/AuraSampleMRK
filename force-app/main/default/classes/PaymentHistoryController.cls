public with sharing class PaymentHistoryController {
	@AuraEnabled
    public static transactionsWrapper BringData(String ids){
        Integer totalCount = 0;
        list<Master_Transaction__c> ClaimToPost = new list<Master_Transaction__c>();
        //Added 'ElixirSuite__Interest_Late_Filling_Charges__c' to query by Anusha -03/10/22
        ClaimToPost=[select id,Name,ElixirSuite__Payment_Received_By__c,ElixirSuite__Interest_Late_Filling_Charges__c,ElixirSuite__Reason_Of_Payment__c,Transaction_Date__c,Account__c,Payment_Type__c,Payment_By__c,Total_Amount_Paid__c,CreatedDate
                    ,(select ElixirSuite__Payment_Received_By__c from ElixirSuite__Transactions__r) from Master_Transaction__c where Transaction_Date__c!=null and Account__c =:ids and ElixirSuite__Reason_Of_Payment__c!='Discounted Payment'
                     WITH SECURITY_ENFORCED
                     ORDER BY CreatedDate DESC LIMIT 5]; //Added ElixirSuite__Reason_Of_Payment__c!='Discounted Payment' by Anusha - 06/10/22
       List<AggregateResult> claimsCount = [SELECT count(Id) c from Master_Transaction__c where Account__c= :Ids WITH SECURITY_ENFORCED];
        if(claimsCount!=null && claimsCount.size()>0){
            totalCount = Integer.valueOf(claimsCount[0].get('c'));
        }
        transactionsWrapper claimsToReturn = new transactionsWrapper(ClaimToPost, totalCount);
        return claimsToReturn;
         
    }
     public class transactionsWrapper{
        @AuraEnabled public Integer totalCount ;
        @AuraEnabled public List<Master_Transaction__c> transactions;
        transactionsWrapper(List<Master_Transaction__c> transactions, Integer totalCount){
            this.transactions = transactions;
            this.totalCount = totalCount;
        }
    }

    @AuraEnabled
    public static transactionsWrapper BringDataViewAll(String ids){
        Integer totalCount = 0;
        list<Master_Transaction__c> ClaimToPost = new list<Master_Transaction__c>();
        //Added 'ElixirSuite__Interest_Late_Filling_Charges__c' to query by Anusha -03/10/22
        ClaimToPost=[select id,Name,ElixirSuite__Payment_Received_By__c,ElixirSuite__Reason_Of_Payment__c,Transaction_Date__c,Account__c,Payment_Type__c,Payment_By__c,Total_Amount_Paid__c,CreatedDate,ElixirSuite__Interest_Late_Filling_Charges__c 
                      ,(select ElixirSuite__Payment_Received_By__c from ElixirSuite__Transactions__r) from Master_Transaction__c where Transaction_Date__c!=null and Account__c =:ids and ElixirSuite__Reason_Of_Payment__c!='Discounted Payment'
                     WITH SECURITY_ENFORCED
                     ORDER BY CreatedDate DESC LIMIT 40000]; //Added ElixirSuite__Reason_Of_Payment__c!='Discounted Payment' by Anusha  -06/10/22
        List<AggregateResult> claimsCount = [SELECT count(Id) c from Master_Transaction__c where Account__c =:ids WITH SECURITY_ENFORCED];
        if(claimsCount!=null && claimsCount.size()>0){
            totalCount = Integer.valueOf(claimsCount[0].get('c'));
        }
        transactionsWrapper claimsToReturn = new transactionsWrapper(ClaimToPost, totalCount);
        return claimsToReturn;          
    }
    @AuraEnabled
    public static transactionsWrapper BringFilterData(string fromDate , string toDate ,String ids){
        Integer totalCount = 0;
        System.debug('fromDate '+fromDate);
        System.debug('toDate '+toDate);
        
        list<Master_Transaction__c> ClaimToPost = new list<Master_Transaction__c>();
        ClaimToPost=[select id,Name,ElixirSuite__Payment_Received_By__c,Transaction_Date__c,Account__c,Payment_Type__c,Payment_By__c,Total_Amount_Paid__c,CreatedDate 
                     ,(select ElixirSuite__Payment_Received_By__c from ElixirSuite__Transactions__r) from Master_Transaction__c where Transaction_Date__c!=null and Account__c =:ids  and ElixirSuite__Reason_Of_Payment__c!='Discounted Payment' And DAY_ONLY(createddate)>=:Date.valueOf(fromDate) And DAY_ONLY(createddate)<=:Date.valueOf(toDate) 
                     WITH SECURITY_ENFORCED
                     ORDER BY CreatedDate DESC LIMIT 5]; //Added ElixirSuite__Reason_Of_Payment__c!='Discounted Payment' by Anusha  -06/10/22
        List<AggregateResult> claimsCount = [SELECT count(Id) c from Master_Transaction__c where Account__c =:ids And DAY_ONLY(createddate)>=:Date.valueOf(fromDate) And DAY_ONLY(createddate)<=:Date.valueOf(toDate) WITH SECURITY_ENFORCED];
        if(claimsCount!=null && claimsCount.size()>0){
            totalCount = Integer.valueOf(claimsCount[0].get('c'));
        }
        transactionsWrapper claimsToReturn = new transactionsWrapper(ClaimToPost, totalCount);
        return claimsToReturn;        
    }
    @AuraEnabled
    public static transactionsWrapper BringFilterDataViewAll(string fromDate , string toDate ,String ids){
        Integer totalCount = 0;
        list<Master_Transaction__c> ClaimToPost = new list<Master_Transaction__c>();
        if(String.isNotBlank(fromDate) && String.isNotBlank(toDate)){
        //Added 'ElixirSuite__Interest_Late_Filling_Charges__c' to query by Anusha -04/10/22
        ClaimToPost=[select id,Name,ElixirSuite__Payment_Received_By__c,Transaction_Date__c,Account__c,Payment_Type__c,Payment_By__c,Total_Amount_Paid__c,CreatedDate,ElixirSuite__Interest_Late_Filling_Charges__c 
                     ,(select ElixirSuite__Payment_Received_By__c from ElixirSuite__Transactions__r) from Master_Transaction__c where Transaction_Date__c!=null and Account__c =:ids  and ElixirSuite__Reason_Of_Payment__c!='Discounted Payment' And DAY_ONLY(createddate)>=:Date.valueOf(fromDate) And DAY_ONLY(createddate)<=:Date.valueOf(toDate) 
                     WITH SECURITY_ENFORCED
                     ORDER BY CreatedDate DESC LIMIT 40000]; //Added ElixirSuite__Reason_Of_Payment__c!='Discounted Payment' by Anusha  -06/10/22
        List<AggregateResult> claimsCount = [SELECT count(Id) c from Master_Transaction__c where Account__c =:ids And DAY_ONLY(createddate)>=:Date.valueOf(fromDate) And DAY_ONLY(createddate)<=:Date.valueOf(toDate) WITH SECURITY_ENFORCED];
            if(claimsCount!=null && claimsCount.size()>0){
                totalCount = Integer.valueOf(claimsCount[0].get('c'));
            }
            transactionsWrapper claimsToReturn = new transactionsWrapper(ClaimToPost, totalCount);
            return claimsToReturn;
        }else{
            transactionsWrapper claimsToReturn = BringDataViewAll(ids);
            return claimsToReturn;
        }
    }
}
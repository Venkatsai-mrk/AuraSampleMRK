public with sharing class PaymentHistoryController_for_Ehr {
    //Ashwini Dolli
    @AuraEnabled
    public static string fetchAccountName(string accountId){
        List<Account> acc=[SELECT Id, name FROM Account WHERE Id= :accountId WITH SECURITY_ENFORCED];
        string accName = acc[0].name;
        return accName;
    }
    @AuraEnabled
    public static transactionsWrapper BringData(String ids){
        Integer totalCount = 0;
        list<Master_Transaction__c> ClaimToPost = new list<Master_Transaction__c>();
        ClaimToPost=[select id,Name,Transaction_Date__c,Account__c,Payment_Type__c,Mode_of_Payment__c,Payment_By__c,Total_Amount_Paid__c,CreatedDate,ElixirSuite__Payment_Received_By__c
                     from Master_Transaction__c where Account__c =:ids 
                     WITH SECURITY_ENFORCED
                     ORDER BY CreatedDate DESC LIMIT 5];
       List<AggregateResult> claimsCount = [SELECT count(Id) c from Master_Transaction__c where Account__c =:ids WITH SECURITY_ENFORCED];
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
        ClaimToPost=[select id,Name,Transaction_Date__c,Account__c,Payment_Type__c,Payment_By__c,Total_Amount_Paid__c,CreatedDate,Mode_of_Payment__c, Payment_Received_By__c
                     from Master_Transaction__c where Account__c =:ids 
                     WITH SECURITY_ENFORCED
                     ORDER BY CreatedDate DESC LIMIT 40000];
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
        list<Master_Transaction__c> ClaimToPost = new list<Master_Transaction__c>();
        ClaimToPost=[select id,Name,Transaction_Date__c,Account__c,Payment_Type__c,Payment_By__c,Total_Amount_Paid__c,CreatedDate 
                     from Master_Transaction__c where Account__c =:ids And ElixirSuite__Transaction_Date__c>=:Date.valueOf(fromDate) And ElixirSuite__Transaction_Date__c<=:Date.valueOf(toDate)
                     WITH SECURITY_ENFORCED
                     ORDER BY CreatedDate DESC LIMIT 5]; // changed filter from createdDate to transaction date as per LX3-6291 -- Jami venkat
        List<AggregateResult> claimsCount = [SELECT count(Id) c from Master_Transaction__c where Account__c =:ids And ElixirSuite__Transaction_Date__c>=:Date.valueOf(fromDate) And ElixirSuite__Transaction_Date__c<=:Date.valueOf(toDate) WITH SECURITY_ENFORCED];
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
        ClaimToPost=[select id,Name,Transaction_Date__c,Account__c,Payment_Type__c,Payment_By__c,Total_Amount_Paid__c,CreatedDate 
                     from Master_Transaction__c 
                     where Account__c =:ids And ElixirSuite__Transaction_Date__c>=:Date.valueOf(fromDate) And ElixirSuite__Transaction_Date__c<=:Date.valueOf(toDate) 
                     WITH SECURITY_ENFORCED
                     ORDER BY CreatedDate DESC LIMIT 40000];  // changed filter from createdDate to transaction date as per LX3-6291 -- Jami venkat
        List<AggregateResult> claimsCount = [SELECT count(Id) c from Master_Transaction__c where Account__c =:ids And ElixirSuite__Transaction_Date__c>=:Date.valueOf(fromDate) And ElixirSuite__Transaction_Date__c<=:Date.valueOf(toDate) WITH SECURITY_ENFORCED];
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
      @AuraEnabled
    public static ElixirSuite__Elixir_Custom_Setting__c getPaymentSetting(){
        return ElixirSuite__Elixir_Custom_Setting__c.getInstance();
    }
}
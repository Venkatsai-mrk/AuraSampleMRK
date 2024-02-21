public with sharing class PaymentSchedule {
    @AuraEnabled
    public static  paymentsWrapper BringData(String ids){
        Integer totalCount = 0;
        list<Payment_Schedule__c> ClaimToPost = new list<Payment_Schedule__c>();
        ClaimToPost=[select id,Name,Status__c,Installment_Amount__c,Account__c,Net_Balance__c,Pay_Frequency__c,Payment_Schedule__c ,ElixirSuite__Due_Date__c,CreatedDate 
                     from Payment_Schedule__c where Account__c =:ids And Payment_Schedule__c = null 
                     WITH SECURITY_ENFORCED
                     ORDER BY CreatedDate DESC LIMIT 5];
        List<AggregateResult> claimsCount = [SELECT count(Id) c FROM Payment_Schedule__c WHERE Account__c=: ids AND Payment_Schedule__c = null WITH SECURITY_ENFORCED];
        if(claimsCount!=null && claimsCount.size()>0){
            totalCount = Integer.valueOf(claimsCount[0].get('c'));
        }
        paymentsWrapper claimsToReturn = new  paymentsWrapper(ClaimToPost, totalCount);
        return claimsToReturn;
    }
    public class paymentsWrapper{
        @AuraEnabled public Integer totalCount ;
        @AuraEnabled public List<Payment_Schedule__c> payments;
        paymentsWrapper(List<Payment_Schedule__c> ClaimToPost, Integer totalCount){
            this.payments = ClaimToPost;
            this.totalCount = totalCount;
        }
    }
    @AuraEnabled
    public static paymentsWrapper BringDataViewAll(String ids){
        Integer totalCount = 0;
        list<Payment_Schedule__c> ClaimToPost = new list<Payment_Schedule__c>();
        ClaimToPost=[select id,Name,Status__c,Installment_Amount__c,Account__c,Net_Balance__c,Pay_Frequency__c,Payment_Schedule__c ,ElixirSuite__Due_Date__c,CreatedDate 
                     from Payment_Schedule__c where Account__c =:ids And Payment_Schedule__c = null WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC LIMIT 40000];
        List<AggregateResult> claimsCount = [SELECT count(Id) c FROM Payment_Schedule__c WHERE Account__c=: ids AND Payment_Schedule__c = null WITH SECURITY_ENFORCED];
        if(claimsCount!=null && claimsCount.size()>0){
            totalCount = Integer.valueOf(claimsCount[0].get('c'));
        }
        paymentsWrapper claimsToReturn = new  paymentsWrapper(ClaimToPost, totalCount);
        return claimsToReturn;
    }
    
    @AuraEnabled
    public static paymentsWrapper BringFilterData(string fromDate , string toDate ,String ids){
        Integer totalCount = 0;
        list<Payment_Schedule__c> ClaimToPost = new list<Payment_Schedule__c>();
        ClaimToPost=[select id,Name,Status__c,Installment_Amount__c,Account__c,Net_Balance__c,Pay_Frequency__c,Payment_Schedule__c ,ElixirSuite__Due_Date__c,CreatedDate 
                     from Payment_Schedule__c where Account__c =:ids And Payment_Schedule__c = null And CreatedDate>=:Date.valueOf(fromDate) And CreatedDate<=:Date.valueOf(toDate).addDays(1) 
                     WITH SECURITY_ENFORCED
                     ORDER BY CreatedDate DESC LIMIT 5];
        List<AggregateResult> claimsCount = [SELECT count(Id) c FROM Payment_Schedule__c WHERE Account__c=: ids AND Payment_Schedule__c = null And CreatedDate>=:Date.valueOf(fromDate) AND CreatedDate<=:Date.valueOf(toDate)
        WITH SECURITY_ENFORCED];
        if(claimsCount!=null && claimsCount.size()>0){
            totalCount = Integer.valueOf(claimsCount[0].get('c'));
        }
        paymentsWrapper claimsToReturn = new  paymentsWrapper(ClaimToPost, totalCount);
        return claimsToReturn;
    }
    
    @AuraEnabled
    public static paymentsWrapper BringFilterDataViewAll(string fromDate , string toDate ,String ids){
        Integer totalCount = 0;
        list<Payment_Schedule__c> ClaimToPost = new list<Payment_Schedule__c>();
        if(String.isNotBlank(fromDate) && String.isNotBlank(toDate)){
            ClaimToPost=[select id,Name,Status__c,Installment_Amount__c,Account__c,Net_Balance__c,Pay_Frequency__c,Payment_Schedule__c ,ElixirSuite__Due_Date__c,CreatedDate 
                         from Payment_Schedule__c where Account__c =:ids And Payment_Schedule__c = null And CreatedDate>=:Date.valueOf(fromDate) And CreatedDate<=:Date.valueOf(toDate)
                         WITH SECURITY_ENFORCED
                         ORDER BY CreatedDate DESC LIMIT 40000];
            List<AggregateResult> claimsCount = [SELECT count(Id) c FROM Payment_Schedule__c WHERE Account__c=: ids AND Payment_Schedule__c = null And CreatedDate>=:Date.valueOf(fromDate) AND CreatedDate<=:Date.valueOf(toDate) WITH SECURITY_ENFORCED];
            if(claimsCount!=null && claimsCount.size()>0){
                totalCount = Integer.valueOf(claimsCount[0].get('c'));
            }
            paymentsWrapper claimsToReturn = new paymentsWrapper(ClaimToPost, totalCount);
            return claimsToReturn;
        }else{
            paymentsWrapper claimsToReturn = BringDataViewAll(ids);
            return claimsToReturn;
        } 
    }
    
     @AuraEnabled
    public static License_Class LicensBasdPermission()
    {
        Id currentUid = UserInfo.getUserId();
        String AvailLicense = [Select Id,ElixirSuite__License_Type__c,Username,Name from User where Id =:currentUid].ElixirSuite__License_Type__c;
        List<String> lst_availLicense = new List<String>();
        lst_availLicense = AvailLicense.split(';');
        License_Class lCls = new License_Class();
        try{
        for(String str : lst_availLicense)
        {
            if(str == 'Elixir EHR')
            {
                lCls.isEhr = True;
                continue;
            }
           
            if(str == 'Elixir Contact Center')
            {
                lCls.isContactCenter = True;
                continue;
            }
            
            if(str == 'Elixir RCM')
            {
                lCls.isRcm = True;
                continue;
            }
        }
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        return lCls;
    }
    public class License_Class
    {
        @AuraEnabled public Boolean isEhr;
        @AuraEnabled public Boolean isRcm;
        @AuraEnabled public Boolean isContactCenter;
    }
    
}
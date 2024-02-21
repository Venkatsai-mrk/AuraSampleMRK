public with sharing class BillingSearchGlobalHelper {
    @AuraEnabled 
    public static  Account[] acctLst(String searchKeyWord){
        String searchKey = '%' + searchKeyWord + '%';               
        Account[] recordLst = [SELECT ID,Name FROM Account where Name 
                               LIKE: searchKey with security_enforced];
        return recordLst;
    }
    @AuraEnabled 
    public static  ElixirSuite__Claim__c[] claimLst(String searchKeyWord){
        String searchKey = '%' + searchKeyWord + '%';               
        ElixirSuite__Claim__c[] recordLst = [SELECT ID,Name FROM ElixirSuite__Claim__c where Name 
                                             LIKE: searchKey with security_enforced];
        return recordLst;
    }
    @AuraEnabled 
    public static  ElixirSuite__Claim__c[] claimLstWithFilter(String searchKeyWord,String patientId){
        String searchKey = '%' + searchKeyWord + '%';               
        ElixirSuite__Claim__c[] recordLst = [SELECT ID,Name FROM ElixirSuite__Claim__c where Name 
                                             LIKE: searchKey AND ElixirSuite__Account__c = :patientId  with security_enforced];
        return recordLst;
    }
}
//
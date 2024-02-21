public with sharing class PatientlistViewcontroller {
    @AuraEnabled
    public static List<Account> fetchPatientlist() {
        list<Account> AccountList = [Select id, name, AccountNumber,AnnualRevenue from Account WHERE ID!=NULL
        WITH SECURITY_ENFORCED];
        return AccountList;
    }
    @AuraEnabled
    public static List<Claim__c> fetchClaims(string pid) {
        list<Claim__c> ClaimList = [Select id, Batch_Id__c, Bill_Phone__c,Claimid__c,Account__c from Claim__c where 
                                    Account__c =: pid WITH SECURITY_ENFORCED];
        return ClaimList;
    }
    /*@AuraEnabled
public static List<Payment> fetchPayment() {
list<Payment> PaymentList = [Select id,Amount,Email,Balance from Payment limit 10];
return PaymentList;
}
*/
}
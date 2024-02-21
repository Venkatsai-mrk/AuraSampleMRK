/*Created by Avani Jain*/
public with sharing class BillingSummaryApex {
    @AuraEnabled
    public static string billSum(string accountid)
    {
        list<ElixirSuite__VOB__c> vob = new list<ElixirSuite__VOB__c>();
        if (Schema.sObjectType.ElixirSuite__VOB__c.fields.Account__c.isAccessible()) {
            vob=[select Id,Account__c from ElixirSuite__VOB__c where Account__c=:accountid WITH SECURITY_ENFORCED LIMIT 1];
            }
        if(vob!=NULL && vob.size()>0)
        {
            return vob[0].id; 
        }
        else
        {
            return NULL;
        } 
    }
   
}
/* created Test class-- BillingSummaryApexTest*/
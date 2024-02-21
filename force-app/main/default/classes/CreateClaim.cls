public with sharing class CreateClaim {
    
    public static Map<String,String> recordTypeMap = new Map<String,String>{'Primary' =>'VOB_record_type','Secondary'=>'Secondary_VOB',
        'Workers Comp' =>'Worker_s_Comp','Auto-accident' =>'Auto_accident','Durable Medical Equipment' =>'Durable_Medical_Equipment'};
            
    @AuraEnabled
    public static PayerWrapper getVob(String recordtypeLabel,String accountId,String recName){
        system.debug('recordtypeLabel '+recordtypeLabel);
        String recordtypeName = recordTypeMap.get(recordtypeLabel);
        system.debug('recordtypeName '+recordtypeName);
        Id devRecordTypeId = Schema.SObjectType.ElixirSuite__VOB__c.getRecordTypeInfosByDeveloperName().get(recordtypeName).getRecordTypeId();
        List<ElixirSuite__VOB__c> vobLst  = [Select id,ElixirSuite__Payer__c,ElixirSuite__Payer__r.Name,CreatedDate,ElixirSuite__Insured_First_Name__c,ElixirSuite__Insured_Last_Name__c,ElixirSuite__Member_Id__c,ElixirSuite__Patient_Relationship_With_Insured__c,
                                             ElixirSuite__Status__c,ElixirSuite__VOB_Verification_Status__c,ElixirSuite__Insurance_Plan_Name__c,ElixirSuite__Last_Verified_Date__c from ElixirSuite__VOB__c
                                             where RecordTypeId =:devRecordTypeId AND ElixirSuite__Account__c=: accountId AND ElixirSuite__Status__c ='Active' WITH SECURITY_ENFORCED order by CreatedDate desc];
        
        PayerWrapper payerWrap = new PayerWrapper();
        payerWrap.vobList = vobLst;
        payerWrap.recTypeid = Schema.SObjectType.Claim__c.getRecordTypeInfosByDeveloperName().get(recName).getRecordTypeId();
        return payerWrap;
    }
    
    public class PayerWrapper{
         @AuraEnabled public List<ElixirSuite__VOB__c> vobList;
         @auraEnabled public Id  recTypeid;
    }

}
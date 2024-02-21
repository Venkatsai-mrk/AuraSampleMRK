public with sharing class SelectPayerController {

    public static Map<String,String> recordTypeMap = new Map<String,String>{'Primary' =>'VOB_record_type','Secondary'=>'Secondary_VOB',
        'Workers Comp' =>'Worker_s_Comp','Auto-accident' =>'Auto_accident','Durable Medical Equipment' =>'Durable_Medical_Equipment'};
        
    @AuraEnabled
    public static PayerWrapper fetchRecords(String accountId,String recordtypeLabel) {
        
        String recordtypeName = recordTypeMap.get(recordtypeLabel);
        system.debug('recordtypeLabel'+recordtypeLabel);
        system.debug('recordtypeName'+recordtypeName);
        Id devRecordTypeId = Schema.SObjectType.ElixirSuite__VOB__c.getRecordTypeInfosByDeveloperName().get(recordtypeName).getRecordTypeId();
        Set<String> setOfPayerId = new Set<String>();
        List<ElixirSuite__VOB__c> vobList = [Select id,Name,ElixirSuite__Payer__c,ElixirSuite__Account__c from ElixirSuite__VOB__c where ElixirSuite__Account__c =: accountId AND RecordTypeId =: devRecordTypeId 
                                            WITH SECURITY_ENFORCED order by CreatedDate desc];
        system.debug('vobList'+vobList);
        if(vobList.size() >0){
            for(ElixirSuite__VOB__c vob: vobList){
                if(!String.isBlank(vob.ElixirSuite__Payer__c)){
                    setOfPayerId.add(vob.ElixirSuite__Payer__c);
                }
            }
        }
      system.debug('setOfPayerId'+setOfPayerId);
       
      //  String query = 'SELECT Id,Name FROM ElixirSuite__Payor__c where Id IN:setOfPayerId order by createdDate DESC  limit 5';
      // List < sObject > lstOfRecords = Database.query(query);
        List < ElixirSuite__Payor__c > lstOfRecords = [SELECT Id,Name FROM ElixirSuite__Payor__c where Id IN:setOfPayerId WITH SECURITY_ENFORCED order by createdDate DESC  limit 5];
        
        List < sObject > returnList = new List<sObject>();
         setOfPayerId.clear();
        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
            setOfPayerId.add((String)obj.get('Id'));
            
        }
        
        
        
        PayerWrapper payerWrap = new PayerWrapper();
        payerWrap.payerList = returnList;
        payerWrap.vobList = getchildVob(setOfPayerId,recordtypeLabel,accountId);
        system.debug('returnList'+returnList);
        return payerWrap;
        
        
    }
    
   public static List<ElixirSuite__VOB__c> getchildVob(Set<String> setOfPayerId,String recordtypeLabel,String accountId){
        String recordtypeName = recordTypeMap.get(recordtypeLabel);
        Id devRecordTypeId = Schema.SObjectType.ElixirSuite__VOB__c.getRecordTypeInfosByDeveloperName().get(recordtypeName).getRecordTypeId();
        List<ElixirSuite__VOB__c> vobLst  = [Select id,CreatedDate,ElixirSuite__Insured_First_Name__c,ElixirSuite__Insured_Last_Name__c,ElixirSuite__Patient_Relationship_With_Insured__c,
                                             ElixirSuite__Status__c,ElixirSuite__VOB_Verification_Status__c,ElixirSuite__Insurance_Plan_Name__c,ElixirSuite__Last_Verified_Date__c from ElixirSuite__VOB__c
                                             where ElixirSuite__Payer__c IN: setOfPayerId AND RecordTypeId =:devRecordTypeId AND ElixirSuite__Status__c='Active' AND ElixirSuite__Account__c=: accountId WITH SECURITY_ENFORCED order by CreatedDate desc];
        
        return vobLst;
    }
    public class PayerWrapper{
        @auraEnabled public List<Sobject> payerList;
        @AuraEnabled public List<ElixirSuite__VOB__c> vobList;
    }
}
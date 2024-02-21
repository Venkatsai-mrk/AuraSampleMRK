public with sharing class PayerLookupController {

    public static Map<String,String> recordTypeMap = new Map<String,String>{'Primary' =>'VOB_record_type','Secondary'=>'Secondary_VOB',
        'Workers Comp' =>'Worker_s_Comp','Auto-accident' =>'Auto_accident','Durable Medical Equipment' =>'Durable_Medical_Equipment'};
        
    @AuraEnabled
    public static List<sObject> fetchRecords(String searchKeyWord, String objectName,String accountId,String recordtypeLabel) {
        String recordtypeName = recordTypeMap.get(recordtypeLabel);
        Id devRecordTypeId = Schema.SObjectType.ElixirSuite__VOB__c.getRecordTypeInfosByDeveloperName().get(recordtypeName).getRecordTypeId();
        Set<String> setOfPayerId = new Set<String>();
        List<ElixirSuite__VOB__c> vobList = [Select id,Name,ElixirSuite__Payer__c,ElixirSuite__Set_Default_VOB__c,ElixirSuite__Account__c from ElixirSuite__VOB__c where ElixirSuite__Account__c =: accountId  AND RecordTypeId =: devRecordTypeId
                                            WITH SECURITY_ENFORCED order by CreatedDate desc];
        if(vobList.size() >0){
            for(ElixirSuite__VOB__c vob: vobList){
                if(!String.isBlank(vob.ElixirSuite__Payer__c)){
                    setOfPayerId.add(vob.ElixirSuite__Payer__c);
                }
            }
        }
        String tempInput = '';
        tempInput+='%' + String.escapeSingleQuotes(searchKeyWord) + '%';
        String query = 'SELECT Id, Name FROM ' + String.escapeSingleQuotes(objectName) + ' WHERE Name LIKE :tempInput AND Id IN :setOfPayerId ORDER BY CreatedDate DESC LIMIT 5';
        List<sObject> lstOfRecords = Database.query(query);
        List < sObject > returnList = new List<sObject>();
        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
            
        }
        return returnList;
        
        
    }
    
    @AuraEnabled
    public static List<ElixirSuite__VOB__c> fetchChildVOBs(String selectedPayer,String recordtypeLabel,String accountId) {
        
        String recordtypeName = recordTypeMap.get(recordtypeLabel);
        Id devRecordTypeId = Schema.SObjectType.ElixirSuite__VOB__c.getRecordTypeInfosByDeveloperName().get(recordtypeName).getRecordTypeId();
        List<ElixirSuite__VOB__c> vobLst  = [Select id,CreatedDate,ElixirSuite__Insured_First_Name__c,ElixirSuite__Insured_Last_Name__c,ElixirSuite__Member_Id__c,ElixirSuite__Patient_Relationship_With_Insured__c,
                                             ElixirSuite__Status__c,ElixirSuite__Set_Default_VOB__c,ElixirSuite__VOB_Verification_Status__c,ElixirSuite__Insurance_Plan_Name__c,ElixirSuite__Last_Verified_Date__c from ElixirSuite__VOB__c
                                             where ElixirSuite__Payer__c =: selectedPayer  AND RecordTypeId=: devRecordTypeId AND ElixirSuite__Status__c='Active' 
                                             AND ElixirSuite__Account__c=: accountId WITH SECURITY_ENFORCED order by CreatedDate desc];

        return vobLst; 
    }
    
    public class RecordsData {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        public RecordsData(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }
}
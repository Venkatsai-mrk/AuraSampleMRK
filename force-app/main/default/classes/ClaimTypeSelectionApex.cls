public with sharing class ClaimTypeSelectionApex {
    
    
    public static Map<String,String> recordTypeMap = new Map<String,String>{'Primary' =>'VOB_record_type','Secondary'=>'Secondary_VOB',
        'Workers Comp' =>'Worker_s_Comp','Auto-accident	' =>'Auto_accident','Durable Medical Equipment' =>'Durable_Medical_Equipment'};
        
    @AuraEnabled
    public static PayerWrapper fetchRecords(String accountId,String recordtypeLabel,String recName) {
        
        String recordtypeName = recordTypeMap.get(recordtypeLabel);
        
        Id devRecordTypeId = Schema.SObjectType.ElixirSuite__VOB__c.getRecordTypeInfosByDeveloperName().get(recordtypeName).getRecordTypeId();
        Set<String> setOfPayerId = new Set<String>();
        List<ElixirSuite__VOB__c> vobList = [Select id,Name,ElixirSuite__Payer__c,ElixirSuite__Set_Default_VOB__c,ElixirSuite__Account__c from ElixirSuite__VOB__c 
                                             where ElixirSuite__Account__c =: accountId 
                                             WITH SECURITY_ENFORCED order by CreatedDate desc];
        system.debug('vobList'+vobList);
        
        try{
        if(vobList.size() >0){
            for(ElixirSuite__VOB__c vob: vobList){
                if(!String.isBlank(vob.ElixirSuite__Payer__c)){
                    setOfPayerId.add(vob.ElixirSuite__Payer__c);
                }
            }
        }
            }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        
        
       
        String query = 'SELECT Id,Name FROM ElixirSuite__Payor__c where Id IN:setOfPayerId order by createdDate DESC  limit 5';
        List < sObject > lstOfRecords = Database.query(query);
        List < sObject > returnList = new List<sObject>();
         setOfPayerId.clear();
        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
            setOfPayerId.add((String)obj.get('Id'));
            
        }
        
        
        PayerWrapper payerWrap = new PayerWrapper();
        payerWrap.payerList = returnList;
        payerWrap.vobList = getchildVob(setOfPayerId,recordtypeLabel,accountId);
        payerWrap.recTypeid = Schema.SObjectType.Claim__c.getRecordTypeInfosByDeveloperName().get(recName).getRecordTypeId();
        system.debug('returnList'+returnList);
        
        return payerWrap;
        
        
    }
    public static List<ElixirSuite__VOB__c> getchildVob(Set<String> setOfPayerId,String recordtypeLabel,String accountId){
        String recordtypeName = recordTypeMap.get(recordtypeLabel);
        Id devRecordTypeId = Schema.SObjectType.ElixirSuite__VOB__c.getRecordTypeInfosByDeveloperName().get(recordtypeName).getRecordTypeId();
        List<ElixirSuite__VOB__c> vobLst  = [Select id,CreatedDate,ElixirSuite__Set_Default_VOB__c,ElixirSuite__Insured_First_Name__c,ElixirSuite__Insured_Last_Name__c,ElixirSuite__Member_Id__c,ElixirSuite__Patient_Relationship_With_Insured__c,
                                             ElixirSuite__Status__c,ElixirSuite__Payer__c,ElixirSuite__Payer__r.Name,ElixirSuite__VOB_Verification_Status__c,ElixirSuite__Insurance_Plan_Name__c,ElixirSuite__Last_Verified_Date__c from ElixirSuite__VOB__c
                                             where ElixirSuite__Payer__c IN: setOfPayerId AND RecordTypeId =:devRecordTypeId AND ElixirSuite__Status__c='Active' AND ElixirSuite__Account__c=: accountId WITH SECURITY_ENFORCED order by CreatedDate desc];
        
        return vobLst;
    }
    
    @AuraEnabled //Anusha - start 28/10/22
    public static String fetchDisplaySettings()
    {
        String acitveOne='';
        ElixirSuite__Elixir_Custom_Setting__c customSetting = ElixirSuite__Elixir_Custom_Setting__c.getOrgDefaults();
        
        if(customSetting.ElixirSuite__Include_CMS1500_Form__c && !customSetting.ElixirSuite__Include_UB04_Form__c){ //true false
            acitveOne='CMS1500';
        }else if(!customSetting.ElixirSuite__Include_CMS1500_Form__c && customSetting.ElixirSuite__Include_UB04_Form__c){//false true
            acitveOne='UB04';
        }else if(!customSetting.ElixirSuite__Include_CMS1500_Form__c && !customSetting.ElixirSuite__Include_UB04_Form__c){ //false false
            acitveOne='disableButton';
        }
        
        system.debug('test' + acitveOne);
        return acitveOne;
    } //Anusha - End 28/10/22
    
    public class PayerWrapper{
        @auraEnabled public List<Sobject> payerList;
        @AuraEnabled public List<ElixirSuite__VOB__c> vobList;
        @auraEnabled public Id  recTypeid;
    }
}
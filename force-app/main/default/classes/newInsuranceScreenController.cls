public with sharing class newInsuranceScreenController {
    
    @AuraEnabled
    public string defaultRecordTypeId {get; set;}
    @AuraEnabled
    public Account accountRec {get; set;}
    @AuraEnabled
    public Map<Id, String> insuranceRecordTypes {get; set;}
    
    @AuraEnabled       
    public static newInsuranceScreenController getRecordTypeValues(String accId){
        newInsuranceScreenController obj = new newInsuranceScreenController();
        System.debug('accId****'+accId);
        Map<Id, String> recordtypeMap = new Map<Id, String>();
        try{
            if(!string.isBlank(accId)){
                System.debug('line 17');
            Account accRec = [SELECT Id,
                              Phone,
                              ElixirSuite__DOB__c,
                              ElixirSuite__SSN__c,
                              ElixirSuite__First_Name__c,
                              ElixirSuite__Last_Name__c,
                              BillingCity,
                              BillingState,
                              BillingCountry,
                              BillingPostalCode,
                              BillingStreet
                              FROM Account
                              WHERE Id=:accId
                              WITH SECURITY_ENFORCED];
            
            obj.accountRec = accRec;
        }
            
            //Get all record types of Insurance object
            List<Schema.RecordTypeInfo> recordTypeInfoList = ElixirSuite__VOB__c.SObjectType.getDescribe().getRecordTypeInfos();
            for(RecordTypeInfo info: recordTypeInfoList) {
                //Check record type is available for current user profile
                if(info.isAvailable()) {
                    //Check master record type
                    if(info.getName() != 'Master' && info.getName().trim() != ''){
                        recordtypeMap.put(info.getRecordTypeId(), info.getName());
                    }
                    //Get the default record type for current user profile
                    if(info.isDefaultRecordTypeMapping()){
                        obj.defaultRecordTypeId = info.getRecordTypeId();
                    }
                }
            }    
            obj.insuranceRecordTypes = recordtypeMap;
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        return obj;
    }
    
}
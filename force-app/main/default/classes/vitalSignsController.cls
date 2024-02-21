public with sharing class vitalSignsController {
    
    @AuraEnabled
    public static List<Medical_Examination__c> getVitalSignsRecords(String AccID){
        system.debug('AccountId'+ AccID);
        Id devRecordTypeId = Schema.SObjectType.Medical_Examination__c.getRecordTypeInfosByName().get('Vital Sign').getRecordTypeId();
        List<Medical_Examination__c> vitalSigns = [select id,Respiration__c,Oxygen_Saturation__c, Blood_Pressure_Systolic__c,Blood_Pressure_diasystolic__c,
                                                   Temperature__c, Pulse__c, createdDate  ,CreatedBy.Name  from Medical_Examination__c 
                                                   where Account__c=:AccID AND RecordTypeId=:devRecordTypeId  
                                                   WITH SECURITY_ENFORCED
                                                   order by createdDate desc ];// And createdDate>TODAY and createdDate<TOMORROW];HealthCloudGA__ValueSampledDataOriginCodeLabel__cHealthCloudGA__ValueSampledDataOriginValue__cHealthCloudGA__ValueSampledDataOriginValue__c
        //system.debug('Account'+vitalSigns[0].createdDate.time());
        return vitalSigns;
    }
    @AuraEnabled
    public static User getCurrentlyLoggedInUser(){
        return [SELECT ID,Name from User where id=: UserInfo.getUserId() WITH SECURITY_ENFORCED];
    }
    
    @AuraEnabled
    public static List<Medical_Examination__c> saveVitalSignRecord(Medical_Examination__c ObservationRec, String AccID){
        system.debug('the obser are'+ ObservationRec);
 		system.debug('time' + system.now() + ' END ' + System.now().AddDays(-1)); 
        Id devRecordTypeId = Schema.SObjectType.Medical_Examination__c.getRecordTypeInfosByName().get('Vital Sign').getRecordTypeId();
        ObservationRec.Account__c=AccID;
        ObservationRec.RecordTypeId=devRecordTypeId;
        ObservationRec.Source__c = 'ASSESSMENT';
        ObservationRec.Start_Time__c = system.now();
        ObservationRec.End_Time__c = System.now().AddDays(-1);
        try{
        if(Schema.sObjectType.Medical_Examination__c.isAccessible() && Schema.sObjectType.Medical_Examination__c.isCreateable()
            && Schema.sObjectType.Medical_Examination__c.fields.Account__c.isCreateable()
            && Schema.sObjectType.Medical_Examination__c.fields.RecordTypeId.isCreateable()
            && Schema.sObjectType.Medical_Examination__c.fields.Source__c.isCreateable()
            && Schema.sObjectType.Medical_Examination__c.fields.Start_Time__c.isCreateable()
            && Schema.sObjectType.Medical_Examination__c.fields.End_Time__c.isCreateable()){
                insert ObservationRec;
            }
            }
            catch(Exception e){
            ExceptionLog.logError(e);
        
            }
       
       
        system.debug('ObservationRec--'+ObservationRec.Id);
        List<Medical_Examination__c> vitalSigns = [select id,Respiration__c,Oxygen_Saturation__c, Blood_Pressure_Systolic__c,Blood_Pressure_diasystolic__c,
                                                   Temperature__c, Pulse__c, createdDate,CreatedBy.Name from Medical_Examination__c where 
                                                   Account__c=:AccID AND RecordTypeId=:devRecordTypeId 
                                                   WITH SECURITY_ENFORCED
                                                   order by createdDate desc ];// And createdDate>TODAY and createdDate<TOMORROW];
        
        return vitalSigns ;
    }
    
    @AuraEnabled
    public static List<Medical_Examination__c> deleteVital(String vitalId , String AccID)
    {
        Medical_Examination__c delAccount=[Select Id , Account__c from Medical_Examination__c 
        where id=:vitalId WITH SECURITY_ENFORCED];
        if (Schema.sObjectType.Medical_Examination__c.isDeletable()) {
            delete delAccount;
        }
        return getVitalSignsRecords(AccID);
    }
    @AuraEnabled
    public static List<Medical_Examination__c> saveVitalSignRecord_AddedFromForm(Medical_Examination__c ObservationRec, String AccID,String formUniqueID){
        system.debug('the obser are'+ ObservationRec);
        Id devRecordTypeId = Schema.SObjectType.Medical_Examination__c.getRecordTypeInfosByName().get('Vital Sign').getRecordTypeId();
        ObservationRec.Account__c=AccID;
        ObservationRec.RecordTypeId=devRecordTypeId;
        ObservationRec.Source__c = 'ASSESSMENT';
        ObservationRec.Form_Unique_ID__c = formUniqueID;
        ObservationRec.Start_Time__c = system.now().adddays(1);
        ObservationRec.End_Time__c = system.now().adddays(2) ;
        system.debug('time' + ObservationRec.End_Time__c + ' ' + ObservationRec.Start_Time__c);
        try{
        if(Schema.sObjectType.Medical_Examination__c.isAccessible() &&
         Schema.sObjectType.Medical_Examination__c.isCreateable() &&
         Schema.sObjectType.Medical_Examination__c.fields.Account__c.isCreateable() &&
         Schema.sObjectType.Medical_Examination__c.fields.RecordTypeId.isCreateable() &&
         Schema.sObjectType.Medical_Examination__c.fields.Source__c.isCreateable() &&
         Schema.sObjectType.Medical_Examination__c.fields.Form_Unique_ID__c.isCreateable() &&
         Schema.sObjectType.Medical_Examination__c.fields.Start_Time__c.isCreateable() &&
         Schema.sObjectType.Medical_Examination__c.fields.End_Time__c.isCreateable()
         ){
            insert ObservationRec;
        }
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        
        system.debug('ObservationRec--'+ObservationRec.Id);
        List<Medical_Examination__c> vitalSigns = [select id,Respiration__c,Oxygen_Saturation__c, Blood_Pressure_Systolic__c,Blood_Pressure_diasystolic__c,
        Temperature__c, Pulse__c, createdDate,CreatedBy.Name from Medical_Examination__c 
        WHERE Account__c=:AccID AND RecordTypeId=:devRecordTypeId
        WITH SECURITY_ENFORCED
        ORDER BY CreatedDate DESC ];// And createdDate>TODAY and createdDate<TOMORROW]; 
        return vitalSigns ;
    }
}
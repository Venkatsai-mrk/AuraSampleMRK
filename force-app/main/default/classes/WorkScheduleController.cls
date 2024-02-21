public with sharing class WorkScheduleController {
    
    @AuraEnabled
    public static List<ElixirSuite__Work_Schedule__c> getPractitionerAvailability(String practitionerId){
        System.debug('WorkScheduleController getPractitionerAvailability() - practitionerId '+practitionerId);
        ExceptionLog.logDebugString('practitionerId '+practitionerId);
        List<ElixirSuite__Work_Schedule__c> lstWorkSchedule = [Select Id,Name,ElixirSuite__Work_Schedule__c,
                                                               ElixirSuite__Practitioner_Name__c,ElixirSuite__End_Date_Time__c,
                                                               ElixirSuite__Start_Date_Time__c FROM ElixirSuite__Work_Schedule__c 
                                                               WHERE ElixirSuite__Work_Schedule__c!= null 
                                                               AND Practitioner_Name__c=:practitionerId WITH SECURITY_ENFORCED];
        System.debug('WorkScheduleController getPractitionerAvailability() - lstWorkSchedule '+lstWorkSchedule);
        
        return lstWorkSchedule;
    }
    
    @AuraEnabled
    public static List<Contact> getPractitionerList(String searchText){
        Elixir_Custom_Setting__c val = Elixir_Custom_Setting__c.getOrgDefaults();
        String contactRecType = val.ElixirSuite__Practitioner_Contact_Recordtype__c;
        Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(contactRecType).getRecordTypeId();
        String searchKey = '%' + searchText + '%';
        return [Select Id,Name,RecordTypeId FROM Contact 
                WHERE RecordTypeId=:recordTypeId 
                AND Is_Active__c=true AND Name LIKE: searchKey WITH SECURITY_ENFORCED];
    }
}
public with sharing class GroupPatientsCustomWidgetCtrl {

    @AuraEnabled
    public static  List<ElixirSuite__Group_Patient__c> getGroupPatients(String accountId){
        
        List<ElixirSuite__Group_Patient__c> groupPatientList = [Select Id,Name,ElixirSuite__Group_Name__r.Name,ElixirSuite__Criteria_Based_Addition__c from 
                                                                ElixirSuite__Group_Patient__c where ElixirSuite__Current_Patient_Name__c =: accountId AND ElixirSuite__Group_Name__r.ElixirSuite__Is_Active__c=true 
                                                                WITH SECURITY_ENFORCED limit 50000];
        
        return groupPatientList;
        
    }
    
    @AuraEnabled
    public static void deleteGroupPatients(ElixirSuite__Group_Patient__c groupPatientRrecord){
        if (Schema.sObjectType.ElixirSuite__Group_Patient__c.isDeletable()) {
          delete groupPatientRrecord;
        }
    }
}
public with sharing class PatientDeviceHandler {
    
    public static void afterInsert(List<ElixirSuite__Patient_Device__c> patientDevices,Map<id,ElixirSuite__Patient_Device__c> newPatientDevice,Map<id,ElixirSuite__Patient_Device__c> oldPatientDevice){
        
        List<Elixir_Pluggable_Classes__mdt> pluggableClass = new List<Elixir_Pluggable_Classes__mdt>();
        Map<String, Object> args = new Map<String, Object>{
            'patientDevices'=>patientDevices
                };
        String virtualClassName;
        pluggableClass = [SELECT DeveloperName,Virtual_Class__c 
                          FROM Elixir_Pluggable_Classes__mdt 
                          WHERE DeveloperName='DeviceVerificationIntegration' WITH SECURITY_ENFORCED];
        if(pluggableClass != null && !pluggableClass.isEmpty()){
            virtualClassName = pluggableClass[0].Virtual_Class__c;
        }
        if(virtualClassName != '' && virtualClassName!=null){

            List<ElixirSuite__Audit_fields_new__mdt> auditClass = new List<ElixirSuite__Audit_fields_new__mdt>();
        String virtualFieldName;
        auditClass = [SELECT DeveloperName,ElixirSuite__Audit_fields__c,ElixirSuite__Audit_Object__c FROM ElixirSuite__Audit_fields_new__mdt WHERE ElixirSuite__Audit_Object__c='ElixirSuite__Patient_Device__c' WITH SECURITY_ENFORCED];
        if(auditClass != null && !auditClass.isEmpty()){
            
            virtualFieldName = auditClass[0].ElixirSuite__Audit_fields__c;
            
        }
            
            if(virtualFieldName != '' && virtualFieldName !=null){
             String objName = 'ElixirSuite__Patient_Device__c';
             AuditTrailUtility updateJob = new AuditTrailUtility(newPatientDevice, oldPatientDevice,objName);
             ID jobID = System.enqueueJob(updateJob);
}
            Callable cls = (Callable) Type.forName(virtualClassName).newInstance();
            cls.call('verifyDevices',args);
        }
    }
    public static void afterUpdate(List<ElixirSuite__Patient_Device__c> patientDevices,Map<id,ElixirSuite__Patient_Device__c> newPatientDevice,Map<id,ElixirSuite__Patient_Device__c> oldPatientDevice){
        List<ElixirSuite__Patient_Device__c> patientDevicesList = new List<ElixirSuite__Patient_Device__c>();
        for(ElixirSuite__Patient_Device__c dev:patientDevices){
            if(dev.Name != (oldPatientDevice.get(dev.Id)).Name || ((oldPatientDevice.get(dev.Id)).ElixirSuite__Verified__c == true )){
             patientDevicesList.add(dev);  
            }
        }
        if(patientDevicesList != null && patientDevicesList.size() > 0){
          List<Elixir_Pluggable_Classes__mdt> pluggableClass = new List<Elixir_Pluggable_Classes__mdt>();
        Map<String, Object> args = new Map<String, Object>{
            'patientDevices'=>patientDevicesList
                };
        String virtualClassName;
        pluggableClass = [SELECT DeveloperName,Virtual_Class__c 
                          FROM Elixir_Pluggable_Classes__mdt 
                          WHERE DeveloperName='DeviceVerificationIntegration' WITH SECURITY_ENFORCED];
        if(pluggableClass != null && !pluggableClass.isEmpty()){
            virtualClassName = pluggableClass[0].Virtual_Class__c;
        }
        if(virtualClassName != '' && virtualClassName!=null){

               List<ElixirSuite__Audit_fields_new__mdt> auditClass = new List<ElixirSuite__Audit_fields_new__mdt>();
        String virtualFieldName;
        auditClass = [SELECT DeveloperName,ElixirSuite__Audit_fields__c,ElixirSuite__Audit_Object__c FROM ElixirSuite__Audit_fields_new__mdt WHERE ElixirSuite__Audit_Object__c='ElixirSuite__Patient_Device__c' WITH SECURITY_ENFORCED];
        if(auditClass != null && !auditClass.isEmpty()){
            
            virtualFieldName = auditClass[0].ElixirSuite__Audit_fields__c;
            
        }
            if(virtualFieldName != '' && virtualFieldName !=null){
             String objName = 'ElixirSuite__Patient_Device__c';
             AuditTrailUtility updateJob = new AuditTrailUtility(newPatientDevice,oldPatientDevice,objName);
             ID jobID = System.enqueueJob(updateJob);
}
            Callable cls = (Callable) Type.forName(virtualClassName).newInstance();
            cls.call('verifyDevices',args);
        }  
        }
    }
}
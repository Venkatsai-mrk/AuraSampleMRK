trigger GroupPatientTrigger on ElixirSuite__Group_Patient__c (before delete,after insert) {
    if(System.FeatureManagement.checkPermission('DataMigration')) return;  //LX3-6835 - Bypass the trigger execution during data migration
   /* if(trigger.isAfter && trigger.isInsert){
        system.debug('inenter'+trigger.new);
        AppointmentHandlingForPatients.eventHandlingForInsertedGroupPatients(trigger.new);
    }
    if(trigger.isBefore && trigger.isDelete){
         system.debug('inenter'+trigger.old);
        AppointmentHandlingForPatients.eventHandlingForDeletedGroupPatients(trigger.old);
    }*/
    String virtualClassName = 'GlobalAppointmentForPatients';// Added in Review
    List<Elixir_Pluggable_Classes__mdt> pluggableClass = new List<Elixir_Pluggable_Classes__mdt>();
    pluggableClass = [SELECT
                    DeveloperName,
                    Virtual_Class__c
                    FROM Elixir_Pluggable_Classes__mdt
                    WHERE DeveloperName='GroupPatientTrigger'
                    WITH SECURITY_ENFORCED];
    if(!pluggableClass.isEmpty()){
        virtualClassName = pluggableClass[0].Virtual_Class__c;
    }
    Type t = Type.forName(virtualClassName);
    GlobalAppointmentForPatients appointmentHandling = (GlobalAppointmentForPatients) t.newInstance(); 
    
    if(trigger.isAfter && trigger.isInsert){ 
        appointmentHandling.afterInsert(trigger.new);
    }
    if(trigger.isBefore && trigger.isDelete){ 
        appointmentHandling.beforeDelete(trigger.old);
    }
}
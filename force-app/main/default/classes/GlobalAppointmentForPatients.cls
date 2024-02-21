global with sharing virtual class GlobalAppointmentForPatients {
    global virtual void afterInsert(List<ElixirSuite__Group_Patient__c> groupPatientInsertRecords){
        AppointmentHandlingForPatients.eventHandlingForInsertedGroupPatients(groupPatientInsertRecords);
    }
    global virtual void beforeDelete(List<ElixirSuite__Group_Patient__c> groupPatientoldRecords){
        AppointmentHandlingForPatients.eventHandlingForDeletedGroupPatients(groupPatientoldRecords);
    }
}
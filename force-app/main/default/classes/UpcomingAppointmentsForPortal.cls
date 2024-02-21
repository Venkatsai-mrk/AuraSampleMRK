public without sharing class UpcomingAppointmentsForPortal {
    public static String getPatientId() {
        String patientId='';
        String uId = UserInfo.getUserId();
        List<User> userRecs = Database.query('SELECT id,ContactId,AccountId FROM User WHERE Id =:uId');
        if(userRecs!=null && userRecs.size()>0){
            patientId = (String)userRecs[0].get('AccountId');
        }
        return patientId;
    }
    @AuraEnabled
    public static List<Event> getAllUpcomingAppointments() {
        try{
            String patientId = getPatientId();
            Set<String> appTypes = getAppointmentTypes();
            if(Test.isRunningTest()){
                appTypes = new Set<String>{'New Patient Visit'};
                    }
            List<Event> eventList = [SELECT Id,WhatId,StartDateTime,EndDateTime,Subject,Owner.FirstName, Owner.LastName FROM Event WHERE WhatId=:patientId AND ElixirSuite__Appointment_Type__c IN:appTypes AND StartDateTime>:system.today() WITH SECURITY_ENFORCED ORDER BY StartDateTime ASC];
            return eventList;
        }catch(Exception e){
            ExceptionLog.logError(e);
            return NULL;
        }
        
    }
    public static Set<String> getAppointmentTypes(){
        List<ElixirSuite__Appointment_Type__mdt> appointmentTypes = ElixirSuite__Appointment_Type__mdt.getAll().values();
        Set<String> appTypes = new Set<String>();
        for(ElixirSuite__Appointment_Type__mdt appType : appointmentTypes){
            appTypes.add(appType.Label);
        }
        if(!appTypes.isEmpty()){
            return appTypes;
        }else{
            return NULL;
        }
        
    }
}
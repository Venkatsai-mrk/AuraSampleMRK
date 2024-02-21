public without sharing class AppointmentsForPortal {
    
    @AuraEnabled
    public static Map<String, String> PayAppointment(String EventId) {
        String appId = '';
        Map<String, String> payNowResponseStringified = new Map<String, String>();
        String virtualClassName = 'PayNowCalloutHelper';
        List<Elixir_Pluggable_Classes__mdt> pluggableClass = new List<Elixir_Pluggable_Classes__mdt>();
        pluggableClass = [SELECT
                          DeveloperName,
                          Virtual_Class__c
                          FROM Elixir_Pluggable_Classes__mdt
                          WHERE DeveloperName = 'AppointmentsForPortal' WITH SECURITY_ENFORCED];
        if (!pluggableClass.isEmpty()) {
            virtualClassName = pluggableClass[0].Virtual_Class__c;
        }
        
        if (virtualClassName != '' && virtualClassName != null) {
            Callable cls = (Callable) Type.forName(virtualClassName).newInstance();
            String jsonResponse = (String) cls.call('PayAppointment', new Map<String, Object>{
                'EventId' => EventId
                    });
            Map<String, Object> payNowResponse = (Map<String, Object>) JSON.deserializeUntyped(jsonResponse);
            if (payNowResponse != null) {
                for (String key : payNowResponse.keySet()) {
                    if (payNowResponse.containsKey(key)) {
                        String value = String.valueOf(payNowResponse.get(key)); 
                        payNowResponseStringified.put(key, value);
                    }
                }
            } else {
                return null;
            }
        }
        return payNowResponseStringified;
    
    }
    
    @AuraEnabled
    public static Boolean isEnablePayNow() {
        List<ElixirSuite__Master_Object__c> masterRecord = new List<ElixirSuite__Master_Object__c>();
        masterRecord =[select name,ElixirSuite__Patient_Tile_Entity__c, ElixirSuite__Enable_Pay_Now__c, recordtype.name from ElixirSuite__Master_Object__c where RecordType.name='Patient Portal' and ElixirSuite__Patient_Tile_Entity__c='Portal Definition' WITH SECURITY_ENFORCED limit 1];
        if(masterRecord.size()>0)
        {
            return masterRecord[0].ElixirSuite__Enable_Pay_Now__c;
        }
        else{
            return true;
        }
    }

    public class AppointmentColumnWrapper {
    @AuraEnabled
    public String appointmentColumns;
    @AuraEnabled
    public List<String> requiredFieldsLabel;
    @AuraEnabled
    public List<String> requiredFieldsApi;
    @AuraEnabled
    public Map<String, String> mapRequiredFields;
    @AuraEnabled
    public Map<String, String> mapDataTypeToApi; // New map for data types
}

 @AuraEnabled
public static AppointmentColumnWrapper getAppointmentColumns() {
    AppointmentColumnWrapper w = new AppointmentColumnWrapper();
    String selectedObject = 'Event';
    List<String> reqFields = new List<String>();
    List<String> reqFieldApi = new List<String>();
    Map<String, String> labelToApi = new Map<String, String>();
    Map<String, String> dataTypeToApi = new Map<String, String>();

    // Define the list of fields to skip (using API names)
    List<String> fieldsToSkip = new List<String>{
        'ElixirSuite__Actions__c', 'ElixirSuite__Appointment_Interval_In_Days__c', 'ElixirSuite__Attendance__c', 'ElixirSuite__By_Pass_Check__c', 'Subject',
        'ElixirSuite__Cancel__c', 'ElixirSuite__Co_Facilitator1__c', 'ElixirSuite__Co_Facilitator__c', 'ElixirSuite__Comments__c', 'ElixirSuite__Event_Data_Object__c',
        'ElixirSuite__Facilitator__c', 'ElixirSuite__Form_Unique_Id__c', 'ElixirSuite__Is_custom_screen__c', 'ElixirSuite__Notification_Interval__c', 'ElixirSuite__Parent_Event_Id__c', 
        'ElixirSuite__Patient_End_Time__c', 'ElixirSuite__Patient_Notified__c','ElixirSuite__Patient_Start_TIme__c', 'ElixirSuite__Patient_s_Time_Zone__c', 'ElixirSuite__Plan_Hierarchy__c',
        'ElixirSuite__Plan_SubHierarchy__c','ElixirSuite__Practitioner_End_Time__c', 'ElixirSuite__Practitioner_Start_Time__c', 'ElixirSuite__Practitioner_s_Time_Zone__c', 'ElixirSuite__Reason__c',
        'ElixirSuite__Schedule_Zoom_Meeting__c', 'ElixirSuite__TechTracking_ID__c', 'ElixirSuite__Template_Problem__c', 'ElixirSuite__Week_Days__c','ElixirSuite__Work_Schedule_Id__c',
        'WhoCount','WhatCount','IsAllDayEvent','ActivityDateTime','ActivityDate','Id','DurationInMinutes','EndDate','AccountId','Type','IsPrivate','ShowAs','IsDeleted','IsChild','IsGroupEvent',
        'GroupEventType','SystemModstamp','IsArchived','IsVisibleInSelfService','RecurrenceActivityId','IsRecurrence','RecurrenceStartDateTime','RecurrenceEndDateOnly','RecurrenceTimeZoneSidKey',
        'RecurrenceType','RecurrenceInterval','RecurrenceDayOfWeekMask','RecurrenceDayOfMonth','RecurrenceInstance','RecurrenceMonthOfYear','ReminderDateTime','IsReminderSet','EventSubtype','IsRecurrence2Exclusion',
        'Recurrence2PatternText','Recurrence2PatternVersion','ActivityRecurrence2Id','ActivityRecurrence2ExceptionId','IsRecurrence2','IsRecurrence2Exception','Recurrence2PatternStartDate','Recurrence2PatternTimeZone',
        'ElixirSuite__Appointment_Interval__c','ElixirSuite__Rooms__c','WhatId','OwnerId'
    };

    // Convert the skip list elements to lowercase for case-insensitive comparison
    Set<String> fieldsToSkipSet = new Set<String>();
    for (String fieldName : fieldsToSkip) {
        fieldsToSkipSet.add(fieldName.toLowerCase());
    }

    try {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType sobjType = gd.get(selectedObject);
        Schema.DescribeSObjectResult r = sobjType.getDescribe();
        Map<String, Schema.SObjectField> MapofField = r.fields.getMap();

        for (String fieldName : MapofField.keySet()) {
            Schema.SObjectField field = MapofField.get(fieldName);
            Schema.DescribeFieldResult F = field.getDescribe();

            // Check if the field should be skipped
            if (!fieldsToSkipSet.contains(field.getDescribe().getName().toLowerCase())) {
                reqFields.add(String.valueOf(F.getLabel()));
                reqFieldApi.add(String.valueOf(field));
                labelToApi.put(String.valueOf(F.getLabel()), String.valueOf(field));

                // Get data type of the field
                String fieldType = String.valueOf(F.getType());
                // Get API name of the field
                String fieldApiName = String.valueOf(field);
                // Map data type to API name
                dataTypeToApi.put(fieldApiName, fieldType);
            }
        }

        List<ElixirSuite__Master_Object__c> records = [SELECT Id, ElixirSuite__Columns_for_Portal_Appointment__c FROM ElixirSuite__Master_Object__c WHERE RecordType.Name='Patient Portal' AND ElixirSuite__Patient_Tile_Entity__c='Portal Definition' WITH SECURITY_ENFORCED LIMIT 1];

        if (records.size() > 0) {
            w.appointmentColumns = (String) records[0].get('ElixirSuite__Columns_for_Portal_Appointment__c');
        }

        w.requiredFieldsLabel = reqFields;
        w.requiredFieldsApi = reqFieldApi;
        w.mapRequiredFields = labelToApi;
        w.mapDataTypeToApi = dataTypeToApi;

        return w;
    } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
    }
}

    public static String getPatientId() {
        
        
        String patientId='';
        String uId = UserInfo.getUserId();
        List<User> userRecs = Database.query('SELECT id,ContactId,AccountId FROM User WHERE Id =:uId');
        if(userRecs!=null && userRecs.size()>0){
            patientId = (String)userRecs[0].get('AccountId');
        }
        return patientId;
    }
    
    public class EventWrapper {
        @AuraEnabled
        public String eventId { get; set; }
        @AuraEnabled
        public String whatId { get; set; }
        @AuraEnabled
        public String appointmentType { get; set; }
        @AuraEnabled
        public String virtualMeetingLink { get; set; }
        @AuraEnabled
        public String practitionerId { get; set; }
        @AuraEnabled
        public String practitionerName { get; set; }
        @AuraEnabled
        public String startDateTime { get; set; }
        @AuraEnabled
        public String endDateTime { get; set; }
        @AuraEnabled
        public String subject { get; set; }
        @AuraEnabled
        public String practitionerSpecialty { get; set; }
    }
    @AuraEnabled
    public static EventWrapper getEvent(String appointmentId) {
        EventWrapper eventWrapper = new EventWrapper();
        
        try {
            Event event = [SELECT Id, WhatId, ElixirSuite__Appointment_Type__c, ElixirSuite__Virtual_Meeting_Link__c, ElixirSuite__Practitioner__c, StartDateTime, EndDateTime, Subject FROM Event WHERE Id = :appointmentId WITH SECURITY_ENFORCED LIMIT 1];
            
            eventWrapper.eventId = event.Id;
            eventWrapper.whatId = event.WhatId;
            //eventWrapper.appointmentType = event.ElixirSuite__Appointment_Type__c;
            eventWrapper.virtualMeetingLink = event.ElixirSuite__Virtual_Meeting_Link__c;
            eventWrapper.practitionerId = event.ElixirSuite__Practitioner__c;
            eventWrapper.startDateTime = event.StartDateTime.format('dd/MM/yyyy, h:mm a');
            eventWrapper.endDateTime = event.EndDateTime.format('dd/MM/yyyy, h:mm a');
            eventWrapper.subject = event.Subject;
            
            String appointmentTypeLabel = getAppointmentTypeLabel(event.ElixirSuite__Appointment_Type__c);
            eventWrapper.appointmentType = appointmentTypeLabel;
            ElixirSuite__UserLocation__c practitionerSpecialty = new ElixirSuite__UserLocation__c();
            
            if (eventWrapper.practitionerId != null) {
                practitionerSpecialty = [SELECT Id, Specialty__r.Specialty_Name__c, ElixirSuite__Practitioner__r.Name FROM ElixirSuite__UserLocation__c WHERE ElixirSuite__Practitioner__c = :eventWrapper.practitionerId WITH SECURITY_ENFORCED LIMIT 1];
                
                if (practitionerSpecialty != null) {
                    eventWrapper.practitionerName = practitionerSpecialty.ElixirSuite__Practitioner__r.Name;
                    eventWrapper.practitionerSpecialty = practitionerSpecialty.Specialty__r.Specialty_Name__c;
                }
            }
        }
        catch(Exception e){
            ExceptionLog.logError(e);
            return NULL;
        }
        return eventWrapper;
    }
    
    public static String getAppointmentTypeLabel(String appointmentTypeValue) {
        String appointmentTypeLabel = appointmentTypeValue;
        
        Schema.DescribeSObjectResult objectDescribe = Schema.getGlobalDescribe().get('ElixirSuite__Work_Schedule__c').getDescribe();
        Map<String, Schema.SObjectField> fieldsMap = objectDescribe.fields.getMap();
        
        if (fieldsMap.containsKey('ElixirSuite__Appointment_Types__c')) {
            Schema.SObjectField picklistField = fieldsMap.get('ElixirSuite__Appointment_Types__c');
            Schema.DescribeFieldResult fieldDescribe = picklistField.getDescribe();
            List<Schema.PicklistEntry> picklistValues = fieldDescribe.getPicklistValues();
            
            for (Schema.PicklistEntry picklistValue : picklistValues) {
                if (picklistValue.getValue() == appointmentTypeValue) {
                    appointmentTypeLabel = picklistValue.getLabel();
                    break;
                }
            }
        }
        
        return appointmentTypeLabel;
    }


    @AuraEnabled
    public static Boolean isEnableVisitNotes() {
        Id patientPortalId =Schema.SObjectType.ElixirSuite__Master_Object__c.getRecordTypeInfosByDeveloperName().get('Patient_Portal').getRecordTypeId();
            
        List<ElixirSuite__Master_Object__c> masterRecord = new List<ElixirSuite__Master_Object__c>();
        masterRecord = [select name,ElixirSuite__Patient_Tile_Entity__c, ElixirSuite__Enable_Visit_Notes__c, recordtype.name from ElixirSuite__Master_Object__c where RecordTypeId=:patientPortalId and ElixirSuite__Patient_Tile_Entity__c='Visit Notes' WITH SECURITY_ENFORCED limit 1];
        if(masterRecord.size()>0)
        {
            return masterRecord[0].ElixirSuite__Enable_Visit_Notes__c;
        }
        else{
            return true;
        }
    }
    public class Wrapper{
        @AuraEnabled public String documentId{get;set;}
        @AuraEnabled public String oragnizationBaseURl{get;set;}     
    }
    
    public class PortalAppointListWrapper{
        @AuraEnabled public Boolean enableAppointment{get;set;}   
        @AuraEnabled public String currentUserTimezone{get;set;}
        @AuraEnabled public Boolean enablePayNow { get; set; }

    }
    
    @AuraEnabled
    public static PortalAppointListWrapper isEnableAppointment() {
        PortalAppointListWrapper obj = new PortalAppointListWrapper();
        List<ElixirSuite__Master_Object__c> masterRecord = new List<ElixirSuite__Master_Object__c>();
        masterRecord =[select name,ElixirSuite__Patient_Tile_Entity__c, ElixirSuite__Enable_Appointment_Booking__c, recordtype.name from ElixirSuite__Master_Object__c where RecordType.name='Patient Portal' and ElixirSuite__Patient_Tile_Entity__c='Portal Definition' WITH SECURITY_ENFORCED limit 1];
        if(masterRecord.size()>0)
        {
            obj.enableAppointment = masterRecord[0].ElixirSuite__Enable_Appointment_Booking__c;
        }
        else{
            obj.enableAppointment =  true;
        }
        obj.currentUserTimezone = UserInfo.getTimeZone().getID();
        
        List<ElixirSuite__Master_Object__c> payNowMasterRecord = [select name, ElixirSuite__Patient_Tile_Entity__c, ElixirSuite__Enable_Pay_Now__c, recordtype.name from ElixirSuite__Master_Object__c where RecordType.name='Patient Portal' and ElixirSuite__Patient_Tile_Entity__c='Portal Definition' WITH SECURITY_ENFORCED limit 1 ];
        if (payNowMasterRecord.size() > 0) {
            obj.enablePayNow = payNowMasterRecord[0].ElixirSuite__Enable_Pay_Now__c;
        } else {
            obj.enablePayNow = true;
        }
        return obj;
    }
    
    @AuraEnabled
    public static Wrapper getVisitSummaryPdf(String recordId) {
        
        List<ContentDocumentLink> files = [
            select id,LinkedEntityId,ContentDocumentId,ContentDocument.CreatedDate,ContentDocument.Title from 
            ContentDocumentLink where LinkedEntityId =:recordId order by ContentDocument.CreatedDate desc
        ];
        Wrapper wrpr = new Wrapper();
        if(!files.isEmpty()){
            ElixirSuite__Elixir_Custom_Setting__c setting = ElixirSuite__Elixir_Custom_Setting__c.getOrgDefaults();
            
            wrpr.documentId = files[0].ContentDocumentId;
            wrpr.oragnizationBaseURl = setting.ElixirSuite__Organization_base_URL__c;
        }
        
        
        
        
        return wrpr;
    }
    @AuraEnabled
    public static List<ContentDocumentLink> getDocumentsForAppointments(List<String> recordIds) {
       
        return [
            SELECT Id, LinkedEntityId, ContentDocumentId
            FROM ContentDocumentLink
            WHERE LinkedEntityId IN :recordIds
        ];
    }
    
    /*@AuraEnabled
    public static List<Event> getAllUpcomingAppointments() {
        try{
            Set<String> appTypesSet = new Set<String>();
            String patientId = getPatientId();
            List<Event> eventList = [SELECT Id,WhatId,ElixirSuite__Appointment_Type__c,ElixirSuite__Virtual_Meeting_Link__c,ElixirSuite__Practitioner__r.Name,StartDateTime,EndDateTime,Subject,Owner.FirstName, Owner.LastName FROM Event 
                                     WHERE WhatId=:patientId AND 
                                     StartDateTime>:system.now() AND 
                                     Status__c != 'Cancelled' 
                                     WITH SECURITY_ENFORCED ORDER BY StartDateTime ASC ];
           
             
        
            return eventList;
        }catch(Exception e){
            ExceptionLog.logError(e);
            return NULL;
        }
        
    }*/

    @AuraEnabled
    public static List<Event> getAllUpcomingAppointments() {
        try{
            List<Event> eventList = new List<Event>();
       String patientId =  getPatientId();
        String objectName = 'Event';
        Datetime startDate = Datetime.now();
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
        
        String query = 'SELECT ';
        for (String fieldName : fieldMap.keySet()) {
            query += fieldName + ', ';
        }
        query += 'ElixirSuite__Practitioner__r.Name, ';
        query += 'ElixirSuite__Care_Episode__r.Name, ';
        query += 'ElixirSuite__Location__r.Name, ';
        query += 'ElixirSuite__Room__r.Name, ';
        query += 'CreatedBy.Name, ';
        query += 'LastModifiedBy.Name, ';
        query += 'Who.Name, ';
        query = query.removeEnd(', ');
        query += ' FROM ' + objectName + ' WHERE WhatId = :patientId AND StartDateTime > :startDate AND Status__c != \'Cancelled\'';

        

        query += ' ORDER BY StartDateTime ASC';
        eventList = Database.query(query);
            return eventList;
        }catch(Exception e){
            ExceptionLog.logError(e);
            return NULL;
        }
        
    }
    @AuraEnabled
    public static List<Event> getAllPastAppointments() {

    try{
            List<Event> eventList = new List<Event>();
       String patientId = getPatientId();
        String objectName = 'Event';
        Datetime startDate = Datetime.now();
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
        
        String query = 'SELECT ';
        for (String fieldName : fieldMap.keySet()) {
            query += fieldName + ', ';
        }
        query += 'ElixirSuite__Practitioner__r.Name, ';
        query += 'ElixirSuite__Care_Episode__r.Name, ';
        query += 'ElixirSuite__Location__r.Name, ';
        query += 'ElixirSuite__Room__r.Name, ';
        query += 'CreatedBy.Name, ';
        query += 'LastModifiedBy.Name, ';
        query += 'Who.Name, ';
        query = query.removeEnd(', ');
        query += ' FROM ' + objectName + ' WHERE WhatId = :patientId AND StartDateTime < :startDate ';
        query += ' ORDER BY StartDateTime DESC';
        eventList = Database.query(query);
            return eventList;
        }catch(Exception e){
            ExceptionLog.logError(e);
            return NULL;
        }
    }
    
    @AuraEnabled
    public static void cancelAppointment(String selectedAppointmentId) {
        List<Event> eventList = [SELECT Id,Status__c FROM Event WHERE Id=:selectedAppointmentId WITH SECURITY_ENFORCED];
        for(Event e : eventList){
            e.Status__c = 'Cancelled';
        }
        if(eventList != NULL && eventList.size() > 0){
            Update eventList;
        }
    }
    @AuraEnabled
    public static List<ElixirSuite__Form_Value__c> getVisitNotes(String recordId) {
        List<ElixirSuite__Form_Value__c> getFormId = new List<ElixirSuite__Form_Value__c>(); 
        
        List<Event> getCareEpisodeId = [SELECT Id, ElixirSuite__Care_Episode__c, ElixirSuite__Care_Episode__r.ElixirSuite__Status__c FROM Event WHERE Id = :recordId AND ElixirSuite__Care_Episode__r.ElixirSuite__Status__c = 'Closed'
                                        WITH SECURITY_ENFORCED];
        
        if (!getCareEpisodeId.isEmpty()) {
            Event eventRecord = getCareEpisodeId[0];
            Id careEpisodeId = eventRecord.ElixirSuite__Care_Episode__c;
            getFormId = getFormId(careEpisodeId);
            
        }
        
        return getFormId;
    }
    public static List<ElixirSuite__Form_Value__c> getFormId(Id careEpisodeId){
        List<ElixirSuite__Form_Value__c> getFormId = new List<ElixirSuite__Form_Value__c>(); 
        if (careEpisodeId != null) {
            // Retrieve ElixirSuite__Form_Value__c records based on conditions
            getFormId = [SELECT Id, Name, ElixirSuite__Account__c,ElixirSuite__Status__c,ElixirSuite__Is_Approver__c,ElixirSuite__Form_Id__c,ElixirSuite__Form_Name__c, ElixirSuite__Enable_As__c, ElixirSuite__Care_Episode__c 
                         FROM ElixirSuite__Form_Value__c 
                         WHERE ElixirSuite__Care_Episode__c = :careEpisodeId AND ElixirSuite__Enable_As__c='VisitNote'
                         WITH SECURITY_ENFORCED];
        }
        return getFormId;
    }
    @AuraEnabled
    public static Visitwrapper getAllVisitNotes() {
        Boolean isEnableVisit=isEnableVisitNotes();
        List<String> eventIdList =  new List<String>();
        Boolean isDisabled;
        isDisabled = false;
        Visitwrapper vw = new Visitwrapper();
        vw.eventList = getAllPastAppointments();
        for(Event ev: vw.eventList){
            eventIdList.add(ev.Id);
        }
        vw.getDocuments = getDocumentsForAppointments(eventIdList);
        
        if(isEnableVisit){
            vw.formList = getFormValue(eventIdList); 
        
        Map<String,Boolean> careEpisodeIdAndFormApprovalBoolean = new  Map<String,Boolean>();
        for(ElixirSuite__Form_Value__c formValue : vw.formList){
            Map<String, String> formData = new Map<String, String>();
           List<Map<String,String>> formsDataList = new  List<Map<String,String>>();
            formData.put('formId', formValue.ElixirSuite__Form_Id__c);
            formData.put('formName', formValue.ElixirSuite__Form_Name__c);
            formsDataList.add(formData);
         	Boolean approvalValue = FormApprovalDecision.getApprovalAndSignatureData(formsDataList);
            
            careEpisodeIdAndFormApprovalBoolean.put(formValue.ElixirSuite__Care_Episode__c, !approvalValue);
        }
            vw.careEpisodeIdAndFormApprovalBoolean = new Map<String, Boolean>(careEpisodeIdAndFormApprovalBoolean);
           
        }
        return vw;
        
    }
   
    public class Visitwrapper{
        @AuraEnabled public  List<Event> eventList;
        @AuraEnabled public  List<ElixirSuite__Form_Value__c> formList; 
        @AuraEnabled public List<ContentDocumentLink> getDocuments;
        @AuraEnabled public Boolean isDisabled;
        @AuraEnabled public  Map<String,Boolean> careEpisodeIdAndFormApprovalBoolean = new  Map<String,Boolean>();
    }
    
    @AuraEnabled
    public static List<ElixirSuite__Form_Value__c> getFormValue(List<String> recordIds){
         Set<String> careEpisodeIds = new Set<String>();
        
         List<Event> getCareEpisodeId = [SELECT Id, ElixirSuite__Care_Episode__c, ElixirSuite__Care_Episode__r.ElixirSuite__Status__c 
                                         FROM Event WHERE Id IN: recordIds AND ElixirSuite__Care_Episode__r.ElixirSuite__Status__c = 'Closed'
                                         WITH SECURITY_ENFORCED];
        for( Event ev: getCareEpisodeId){
            careEpisodeIds.add(ev.ElixirSuite__Care_Episode__c);            
        }
         List<ElixirSuite__Form_Value__c> getFormId = [SELECT Id, Name, ElixirSuite__Account__c,ElixirSuite__Status__c,
                                                       ElixirSuite__Is_Approver__c,ElixirSuite__Form_Id__c,
                                                       ElixirSuite__Form_Name__c, ElixirSuite__Enable_As__c, ElixirSuite__Care_Episode__c 
                         FROM ElixirSuite__Form_Value__c 
                         WHERE ElixirSuite__Care_Episode__c IN:careEpisodeIds AND ElixirSuite__Enable_As__c='VisitNote'
                         WITH SECURITY_ENFORCED];
        
        return getFormId;
        
    }
    //added by Shivank
    @AuraEnabled
    public static List<String> getAllTypesOfAppointment(){
        Id patientPortalId = Schema.SObjectType.ElixirSuite__Master_Object__c.getRecordTypeInfosByDeveloperName().get('Patient_Portal').getRecordTypeId();
        List<ElixirSuite__Master_Object__c> recordList = [SELECT Id, ElixirSuite__Enable_Appointment_Booking__c, ElixirSuite__Appointment_types__c FROM ElixirSuite__Master_Object__c WHERE RecordTypeId = :patientPortalId AND ElixirSuite__Patient_Tile_Entity__c = 'Portal Definition' WITH SECURITY_ENFORCED LIMIT 1];
        
        String appointmentType = '';
        List<String> listOfAppointmentType;
        if (!recordList.isEmpty()) {
            appointmentType = recordList[0].ElixirSuite__Appointment_types__c;
            listOfAppointmentType= appointmentType.split(',');
        }
        return listOfAppointmentType;
        
         
    }
        
}
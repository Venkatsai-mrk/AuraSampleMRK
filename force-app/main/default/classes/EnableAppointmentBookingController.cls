public with sharing class EnableAppointmentBookingController {

  @AuraEnabled
public static List<Map<String, String>> getAppointmentTypes() {
    List<Map<String, String>> options = new List<Map<String, String>>();

    Schema.DescribeFieldResult fieldResult = ElixirSuite__Work_Schedule__c.ElixirSuite__Appointment_Types__c.getDescribe();
    List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();

    for (Schema.PicklistEntry entry : picklistValues) {
        Map<String, String> option = new Map<String, String>();
        option.put('label', entry.getLabel());
        option.put('value', entry.getValue());
        options.add(option);
    }

    return options;
}




   /* @AuraEnabled 
    public static Boolean fetchAppointmentBooking()
    {
        try{
            
            Id patientPortalId =Schema.SObjectType.ElixirSuite__Master_Object__c.getRecordTypeInfosByDeveloperName().get('Patient_Portal').getRecordTypeId();
            
            List<ElixirSuite__Master_Object__c> record = new List<ElixirSuite__Master_Object__c>();
            
            record =[select id,ElixirSuite__Enable_Appointment_Booking__c from ElixirSuite__Master_Object__c where recordtypeId =:patientPortalId and ElixirSuite__Patient_Tile_Entity__c='Portal Definition'];
            
            if(record.size() > 0)
            {
                return record[0].ElixirSuite__Enable_Appointment_Booking__c;
            }
            else
            {
                ElixirSuite__Master_Object__c masterRecord = new ElixirSuite__Master_Object__c();
                masterRecord.RecordTypeId = patientPortalId;
                masterRecord.ElixirSuite__Patient_Tile_Entity__c='Portal Definition';
                masterRecord.ElixirSuite__Enable_Appointment_Booking__c=true;
                insert masterRecord;
                
                return true;
            }
        }
        catch (Exception e) {
            ExceptionLog.logError(e);
            return null;
        }
    }
    
    @AuraEnabled
    public static void updateMasterRecord(Boolean enableAppointmentBookingValue){
        try {
            Id patientPortalId =Schema.SObjectType.ElixirSuite__Master_Object__c.getRecordTypeInfosByDeveloperName().get('Patient_Portal').getRecordTypeId();
            
            List<ElixirSuite__Master_Object__c> record =new List<ElixirSuite__Master_Object__c>();
            record =[select id,ElixirSuite__Enable_Appointment_Booking__c from ElixirSuite__Master_Object__c where recordtypeId=:patientPortalId and ElixirSuite__Patient_Tile_Entity__c='Portal Definition' limit 1];
            if(record.size() > 0)
            {
                record[0].ElixirSuite__Enable_Appointment_Booking__c = enableAppointmentBookingValue;
                update record[0];
            }
            
        }
        catch (Exception e) {
            ExceptionLog.logError(e);
        }
    }*/
    
    @AuraEnabled
    public static void saveRecord(String selectedValues, Boolean appointmentBookingValue, Boolean enablePayNowValue, Boolean enableScheduleZoomMeeting,String valuesForAppointmentColumns) {
        try {
            Id patientPortalId = Schema.SObjectType.ElixirSuite__Master_Object__c.getRecordTypeInfosByDeveloperName().get('Patient_Portal').getRecordTypeId();
            
            List<ElixirSuite__Master_Object__c> recordList = new List<ElixirSuite__Master_Object__c>();
            recordList = [SELECT Id, ElixirSuite__Enable_Appointment_Booking__c,ElixirSuite__Allow_patient_to_schedule_zoom_meeting__c, ElixirSuite__Appointment_types__c,ElixirSuite__Enable_Pay_Now__c,ElixirSuite__Columns_for_Portal_Appointment__c FROM ElixirSuite__Master_Object__c WHERE RecordTypeId = :patientPortalId AND ElixirSuite__Patient_Tile_Entity__c = 'Portal Definition' WITH SECURITY_ENFORCED LIMIT 1];
            if(appointmentBookingValue==null){
                appointmentBookingValue = FALSE;
            }
            if(enableScheduleZoomMeeting==null){
                enableScheduleZoomMeeting = FALSE;
            }
            if(enablePayNowValue==null){
                enablePayNowValue = FALSE;
            }
            if (recordList.isEmpty()) {
                // Create a new record if it doesn't exist
                ElixirSuite__Master_Object__c newRecord = new ElixirSuite__Master_Object__c(
                    RecordTypeId = patientPortalId,
                    ElixirSuite__Patient_Tile_Entity__c = 'Portal Definition',
                    ElixirSuite__Enable_Appointment_Booking__c = appointmentBookingValue,
                    ElixirSuite__Appointment_types__c = selectedValues,
                    ElixirSuite__Enable_Pay_Now__c=enablePayNowValue,
                    ElixirSuite__Allow_patient_to_schedule_zoom_meeting__c=enableScheduleZoomMeeting,
                    ElixirSuite__Columns_for_Portal_Appointment__c=valuesForAppointmentColumns
                );
                //insert newRecord;
                system.debug('INSERT '+ newRecord.ElixirSuite__Patient_Tile_Entity__c);
                DMLManager.insertAsUser(newRecord);
            } else {
                // Update the existing record with the selected values
                ElixirSuite__Master_Object__c existingRecord = new ElixirSuite__Master_Object__c(Id = recordList[0].Id);
                existingRecord.RecordTypeId = patientPortalId;
                existingRecord.ElixirSuite__Patient_Tile_Entity__c = 'Portal Definition';
                existingRecord.ElixirSuite__Enable_Appointment_Booking__c = appointmentBookingValue;
                existingRecord.ElixirSuite__Appointment_types__c = selectedValues;
                existingRecord.ElixirSuite__Enable_Pay_Now__c=enablePayNowValue;
                existingRecord.ElixirSuite__Allow_patient_to_schedule_zoom_meeting__c=enableScheduleZoomMeeting;
                existingRecord.ElixirSuite__Columns_for_Portal_Appointment__c=valuesForAppointmentColumns;
                //update existingRecord;
                
                DMLManager.updateAsUser(existingRecord);
            }
        } catch (Exception e) {
            //ExceptionLog.logError(e);
        }
    }

    @AuraEnabled
    public static ElixirSuite__Master_Object__c fetchRecordWithSelectedValues() {
        try {
            // Retrieve the record with selected values based on your criteria
            Id patientPortalId = Schema.SObjectType.ElixirSuite__Master_Object__c.getRecordTypeInfosByDeveloperName().get('Patient_Portal').getRecordTypeId();
            ElixirSuite__Master_Object__c record = [SELECT Id, ElixirSuite__Enable_Appointment_Booking__c, ElixirSuite__Appointment_types__c,
                                                    ElixirSuite__Enable_Pay_Now__c, ElixirSuite__Allow_patient_to_schedule_zoom_meeting__c,ElixirSuite__Columns_for_Portal_Appointment__c
                                                    FROM ElixirSuite__Master_Object__c
                                                    WHERE RecordTypeId = :patientPortalId
                                                    AND ElixirSuite__Patient_Tile_Entity__c = 'Portal Definition'
                                                    WITH SECURITY_ENFORCED
                                                    LIMIT 1];
            return record;
        } catch (Exception e) {
            ExceptionLog.logError(e);
            return null;
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

    
    
}
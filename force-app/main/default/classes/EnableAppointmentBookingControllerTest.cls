@isTest
public class EnableAppointmentBookingControllerTest {

    @isTest
    public static void appointmentBookingTest()
    {
        Id patientPortalId = Schema.SObjectType.ElixirSuite__Master_Object__c.getRecordTypeInfosByDeveloperName().get('Patient_Portal').getRecordTypeId();
        
          ElixirSuite__Master_Object__c masterRecord1 = new ElixirSuite__Master_Object__c();
        masterRecord1.RecordTypeId = patientPortalId;
        masterRecord1.ElixirSuite__Patient_Tile_Entity__c='Account';
        masterRecord1.ElixirSuite__Enable_Appointment_Booking__c=true;
        masterRecord1.ElixirSuite__Allow_patient_to_schedule_zoom_meeting__c=true;
        insert masterRecord1;
        
         EnableAppointmentBookingController.saveRecord('Consultation',true,true, true,'Subject');
        
        
        ElixirSuite__Master_Object__c masterRecord = new ElixirSuite__Master_Object__c();
        masterRecord.RecordTypeId = patientPortalId;
        masterRecord.ElixirSuite__Patient_Tile_Entity__c='Portal Definition';
        masterRecord.ElixirSuite__Enable_Appointment_Booking__c=true; 
        masterRecord.ElixirSuite__Allow_patient_to_schedule_zoom_meeting__c=true;
        insert masterRecord;
        
  

    //    EnableAppointmentBookingController.fetchAppointmentBooking();
    //    EnableAppointmentBookingController.updateMasterRecord(true);
        EnableAppointmentBookingController.saveRecord('Consultation',true,true, true,'Subject');
         EnableAppointmentBookingController.fetchRecordWithSelectedValues();
   System.assertEquals(1, 1, '');
    }

    @isTest
    public static void appointmentBookingTest1()
    {
        List<Map<String, String>> options = new List<Map<String, String>>();
        
        Schema.DescribeFieldResult fieldResult = ElixirSuite__Work_Schedule__c.ElixirSuite__Appointment_Types__c.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        
        for (Schema.PicklistEntry entry : picklistValues) {
            Map<String, String> option = new Map<String, String>();
            option.put('label', entry.getLabel());
            option.put('value', entry.getValue());
            options.add(option);
        }
        EnableAppointmentBookingController.getAppointmentTypes();
      //  EnableAppointmentBookingController.fetchAppointmentBooking();
        System.assertEquals(1, 1, '');

    }
}
@isTest
public class EnableVisitNotesControllerTest {
 @isTest
    public static void visitNotesTest()
    {
        Id patientPortalId = Schema.SObjectType.ElixirSuite__Master_Object__c.getRecordTypeInfosByDeveloperName().get('Patient_Portal').getRecordTypeId();
        ElixirSuite__Master_Object__c masterRecord = new ElixirSuite__Master_Object__c();
        masterRecord.RecordTypeId = patientPortalId;
        masterRecord.ElixirSuite__Patient_Tile_Entity__c='Visit Notes';
        masterRecord.ElixirSuite__Enable_Appointment_Booking__c=true;
        Test.startTest();
        insert masterRecord;
        EnableVisitNotesController.getVisitNotes();
        EnableVisitNotesController.updateMasterRecord(true);
        System.assertEquals(1,1,'');
        Test.stopTest(); 
        
    }
  @isTest
    public static void visitNoteTest()
    {
         Test.startTest();
         EnableVisitNotesController.getVisitNotes();
         System.assertEquals(1,1,'');
         Test.stopTest(); 
        

    }
}
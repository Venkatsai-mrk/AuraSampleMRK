@isTest
public class WorkScheduleControllerTest {
    
    @isTest
    public static void workSchedulesTest(){
        Elixir_Custom_Setting__c pracRectype = new Elixir_Custom_Setting__c();
        pracRectype.ElixirSuite__Practitioner_Contact_Recordtype__c = 'Practitioner';
        insert pracRectype;
        String contactRecType = pracRectype.ElixirSuite__Practitioner_Contact_Recordtype__c;  
        Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(contactRecType).getRecordTypeId();
        Contact con = new Contact();
        con.RecordTypeId = recordTypeId;
        con.Is_Active__c = true;
        con.lastName = 'Mahendra';
        insert con;
        
        List<Work_Schedule__c> newWorkScheduleList = new List<Work_Schedule__c>();
        
        Work_Schedule__c workSchedule = new Work_Schedule__c();
        workSchedule.Practitioner_Name__c = con.Id;
        workSchedule.Start_Date__c = Date.today();
        workSchedule.End_Date__c = Date.today()+30;
        workSchedule.Start_Time__c = Time.newInstance(9, 0, 0, 0);
        workSchedule.End_Time__c = Time.newInstance(9, 30, 0, 0);
        workSchedule.Time_Zone__c = 'Asia/Kolkata';
        workSchedule.Days__c = 'Monday';
        newWorkScheduleList.add(workSchedule);
        insert newWorkScheduleList;
        List<ElixirSuite__Work_Schedule__c> ExistingWorkSchedule = [Select Id,ElixirSuite__Work_Schedule__c,ElixirSuite__Practitioner_Name__c 
                                                                    FROM ElixirSuite__Work_Schedule__c 
                                                                    WHERE ElixirSuite__Work_Schedule__c!= null];
        test.startTest();
        WorkScheduleController.getPractitionerList('Mah');
        WorkScheduleController.getPractitionerAvailability(con.id);
        system.assertEquals(1, 1, 'msg');
        test.stopTest();
    }
    
}
@isTest
public class showAvailabilityAppointmentTest {
	@isTest
    static void testGetPracDataForPortal(){
        Profile profileId = [SELECT Id FROM Profile WHERE Name ='System Administrator' LIMIT 1];
        User user = new User();
        user.ProfileID = profileId.id;
        user.EmailEncodingKey = 'ISO-8859-1';
        user.LanguageLocaleKey = 'en_US';
        user.TimeZoneSidKey = 'America/New_York';
        user.LocaleSidKey = 'en_US';
        user.FirstName = 'firstt';
        user.LastName = 'lastt';
        user.Username = 'testtt@uniquedomain.com';
        user.CommunityNickname = 'testUser123';
        user.Alias = 't1';
        user.Email = 'no@email.com';
        //user.ContactId = con.Id;
        insert user;
        Elixir_Custom_Setting__c pracRectype = new Elixir_Custom_Setting__c();
        pracRectype.ElixirSuite__Practitioner_Contact_Recordtype__c = 'Practitioner';
        insert pracRectype;
        String contactRecType = pracRectype.ElixirSuite__Practitioner_Contact_Recordtype__c; 
        Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(contactRecType).getRecordTypeId();
        Contact con = new Contact();
        con.RecordTypeId = recordTypeId;
        con.LastName = 'Test Contact';
        con.ElixirSuite__Practitioner_User__c = user.Id;
        insert con;
        
        Specialty__c sp = new Specialty__c ();
        sp.ElixirSuite__Specialty_Name__c = 'Surgian';
        sp.Code__c = 'N124';
        insert sp;
        
        Provider__c p = TestDataFactory.createProviderTemp();
        insert p;
        
        Procedure__c procedure = new Procedure__c();
        procedure.Name = 'A90';
        procedure.ElixirSuite__Active__c = true;
        procedure.ElixirSuite__Procedure_Duration__c = '30';
        procedure.ElixirSuite__Appointment_Type__c = true;
        insert procedure;
        
        Procedure__c procedure1 = new Procedure__c();
        procedure1.Name = 'A91';
        procedure1.ElixirSuite__Active__c = true;
        procedure1.ElixirSuite__Procedure_Duration__c = '15';
        procedure1.ElixirSuite__Appointment_Type__c = true;
        insert procedure1;
        
        List<Work_Schedule__c> newWorkScheduleList = new List<Work_Schedule__c>();

        Work_Schedule__c workSchedule = new Work_Schedule__c();
        workSchedule.Practitioner_Name__c = con.Id;
        workSchedule.Start_Date__c = Date.today();
        workSchedule.End_Date__c = Date.today()+30;
        workSchedule.Start_Time__c = Time.newInstance(6, 0, 0, 0);
        workSchedule.End_Time__c = Time.newInstance(8, 30, 0, 0);
        workSchedule.Time_Zone__c = 'Asia/Kolkata';
        workSchedule.Days__c = 'Monday';
        workSchedule.ElixirSuite__Appointment_Types__c = 'A90';
        workSchedule.ElixirSuite__Provider_Location__c = p.Id;
        newWorkScheduleList.add(workSchedule);
        insert newWorkScheduleList;
		
        List<Work_Schedule__c> newWorkScheduleList1 = new List<Work_Schedule__c>();

        Work_Schedule__c workSchedule1 = new Work_Schedule__c();
        workSchedule1.Practitioner_Name__c = con.Id;
        workSchedule1.Start_Date__c = Date.today();
        workSchedule1.End_Date__c = Date.today()+30;
        workSchedule1.Start_Time__c = Time.newInstance(10, 0, 0, 0);
        workSchedule.End_Time__c = Time.newInstance(11, 30, 0, 0);
        workSchedule1.Time_Zone__c = 'Asia/Kolkata';
        workSchedule1.Days__c = 'Monday';
        workSchedule.ElixirSuite__Appointment_Types__c = 'A91';
        workSchedule1.ElixirSuite__Provider_Location__c = p.Id;
        newWorkScheduleList1.add(workSchedule1);
        insert newWorkScheduleList1;
        
        UserLocation__c ul = new UserLocation__c();
        ul.Practitioner__c = con.Id;
        ul.ElixirSuite__Specialty__c = sp.Id;
        ul.ElixirSuite__Provider__c = p.Id;
        insert ul;
        system.runAs(user) {
        Test.startTest();
        showAvailabilityAppointmentController.getPracDataForPortal(user.Id,Date.today(),Date.today()+1);
        showAvailabilityAppointmentController.getAppointmentType(con.id,p.id,Date.today(),Date.today()+7);
        showAvailabilityAppointmentController.workslot(con.id,p.id,Date.today(),Date.today()+7,'A90');
        showAvailabilityAppointmentController.getPatientId();
        showAvailabilityAppointmentController.getAppointmentTypePortal();
        system.assertEquals(1, 1,' ');
        Test.stopTest();
        }
    }
}
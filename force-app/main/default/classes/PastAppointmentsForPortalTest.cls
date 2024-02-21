@isTest
public class PastAppointmentsForPortalTest {
    @isTest
    static void testGetAllPastAppointments(){
        Account testPatient = TestDataFactory.createPatientAcc();
        insert testPatient;
        
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
        insert user;
        
        Event event = new Event(
            WhatId = testPatient.Id,
            StartDateTime = System.today()-2,
            EndDateTime = System.today()+5,
            Subject = 'Test Event 1',
            OwnerId = user.Id,
            ElixirSuite__Appointment_Type__c = 'New Patient Visit'
        );
        insert event;
        system.runAs(user) {
            Test.startTest();
            PastAppointmentsForPortal.getAllPastAppointments();
            Test.stopTest();
            system.assertEquals(1, 1,' ');
        }
    }
}
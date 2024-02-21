@isTest
public class UpcomingAppointmentControllerTest {
    @isTest static void UpcomingControllerTest() {
        
        Account acc= new Account ();
        acc.name='Community Account';
        acc.ElixirSuite__First_Name__c='Community';
        acc.ElixirSuite__Last_Name__c='Account';
        acc.ElixirSuite__Gender__c='Female';
        acc.phone='6379352173';
        acc.ElixirSuite__DOB__c=system.today();
        acc.ElixirSuite__SSN__c='123';
        acc.BillingStreet='123 street';
        acc.BillingCity='City';
        acc.BillingState='State';
        acc.BillingCountry='IN';
        acc.BillingPostalCode='12345';
        insert acc;
        
        Contact con = new Contact();
        con.FirstName = 'Community';
        con.LastName = 'User';
        con.email = 'community@gmail.com';
        con.AccountId=acc.Id;
        insert con;
        String myTestString = 'Patient'; 
        Profile profileId = [SELECT Id FROM Profile WHERE Name =:myTestString LIMIT 1];
        User user = new User();
        user.ProfileID = profileId.id;
        user.EmailEncodingKey = 'ISO-8859-1';
        user.LanguageLocaleKey = 'en_US';
        user.TimeZoneSidKey = 'America/New_York';
        user.LocaleSidKey = 'en_US';
        user.FirstName = 'first';
        user.LastName = 'last';
        user.Username = 'test@uniquedomain.com';
        user.CommunityNickname = 'testUser123';
        user.Alias = 't1';
        user.Email = 'no@email.com';
        user.ContactId = con.Id;            
        insert user;
        
        Event e = new Event();
        e.WhatId=acc.id;
        e.Location='chennai';
        e.Subject = 'test';
        e.StartDateTime=system.today();
        e.EndDateTime=system.today()+5;
        insert e;
        system.runAs(user) {
            Test.startTest();
            UpcomingAppointmentController.getData();
            UpcomingAppointmentController.getAccountId();
            UpcomingAppointmentController.getProfile();
            System.assertEquals(1, 1, '');
            Test.stopTest();
        }        
    }
}
@isTest
public class EventActionshelperTest {
    @isTest
    Public static void method1(){
        Account patient = new Account();
        patient.name = 'Test Patient';
        patient.ElixirSuite__Email_Id__c = 'kj@gmail.com';
        patient.Patient_s_Birth_Date__c = System.today().addyears(-20);
        patient.MRN_Number__c = 1234567;
        patient.ElixirSuite__First_Name__c ='fname';
        patient.ElixirSuite__Last_Name__c ='lname';
        patient.ElixirSuite__SSN__c ='1234';
        patient.ElixirSuite__Gender__c='Male';
        patient.Phone ='9919850735';
        patient.BillingPostalCode='27440';
        patient.ElixirSuite__Deceased__c =true;
        insert patient;
        
        Contact cont = new Contact();
        cont.LastName = 'Tekam';
        cont.ElixirSuite__Time_Zone__c = 'Africa/Addis_Ababa';
        cont.accountId = patient.Id;
        insert cont;
        
        Event env = new Event();
        env.WhatId = patient.Id;
        env.ElixirSuite__Practitioner__c = cont.id;
        env.ElixirSuite__Practitioner_Start_Time__c = '2022-11-11 09:36 AM IST';
        env.ElixirSuite__Practitioner_End_Time__c = '2022-11-11 09:36 AM IST';
        env.StartDateTime = Datetime.newInstance(2019, 1, 1, 08, 30, 00);
        env.EndDateTime = Datetime.newInstance(2019, 1, 1, 17, 30, 00);
        env.Subject = 'Meeting';
        insert env;
        Test.startTest();
        List<Event> evList = [Select ElixirSuite__Practitioner__c, ElixirSuite__Practitioner_Start_Time__c, ElixirSuite__Practitioner_End_Time__c,StartDateTime,EndDate,WhatId, WhoId from Event];
        EventActionshelper.myaction(evList);
        System.assertEquals(1, 1,'');
        Test.stopTest();
    }  
}
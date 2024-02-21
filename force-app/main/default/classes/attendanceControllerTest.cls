@isTest
public with sharing class attendanceControllerTest {
    
    @isTest
    public static void attend(){
        Elixir_Custom_Setting__c setting = new Elixir_Custom_Setting__c();
        setting.ElixirSuite__Patient_Account_Recordtype__c = 'Patient_Account';
        insert setting;
        String patAccRecType = setting.ElixirSuite__Patient_Account_Recordtype__c; 
        Account accrec= new Account();
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(patAccRecType).getRecordTypeId();
        accrec.RecordTypeId =recordTypeId;
        accrec.Name = 'Test';
        accrec.Phone = '900091111';
        accrec.ElixirSuite__Email_Id__c = 'a@g.com';
        accrec.ElixirSuite__Stage__c = 'Admitted';
        accrec.ElixirSuite__Current_Status_Of_Patient__c = 'Current Patients';
        insert accrec;
        
        ElixirSuite__Account_Group__c patientGroupRec = new ElixirSuite__Account_Group__c();
        patientGroupRec.Name = 'Detox';
        insert patientGroupRec;
        
        ElixirSuite__Group_Patient__c groupPatientRec = new ElixirSuite__Group_Patient__c();
        groupPatientRec.ElixirSuite__Group_Name__c = patientGroupRec.Id;
        groupPatientRec.ElixirSuite__Current_Patient_Name__c = accrec.Id;
        insert groupPatientRec;

        Event parobjevent = new Event();
        parobjevent.StartDateTime = dateTime.now();
        parobjevent.EndDateTime = dateTime.now().addMinutes(15);
        parobjevent.WhatId = patientGroupRec.id;
        parobjevent.ElixirSuite__Status__c = 'Scheduled';
        parobjevent.Subject = 'Upcoming Appointment with Test';
        insert parobjevent;
        
        Event objevent = new Event();
        objevent.StartDateTime = dateTime.now();
        objevent.EndDateTime = dateTime.now().addMinutes(15);
        objevent.WhatId = accrec.id;
        objevent.ElixirSuite__Status__c = 'Scheduled';
        objevent.Subject = 'Upcoming Appointment with Test';
        objevent.ElixirSuite__Parent_Event_Id__c = parobjevent.Id;
        insert objevent;
        MyObject instance = new MyObject();
        instance.accId = accrec.Id;
        instance.attended = true;
instance.notes = 'individual note';
        instance.notesChange = true;
        instance.eventId = objevent.Id;
        String myJSON = JSON.serialize(instance);
        String demoJSON = '{"keysToSave":[' + myJSON + ']}';
        
        attendanceController.newWrapper initWrp = attendanceController.getEventPatientGroup(parobjevent.Id);
        
        String grpNt= 'group note';
        Boolean grpNtCh = false;
        
        attendanceController.updatePatientAttendance(demoJSON,grpNt,grpNtCh);
        
        attendanceController.updatePatientAttendance(demoJSON,grpNt,true);
        
        attendanceController.LicensBasdPermission();
        
        System.assertEquals(parobjevent.Id,initWrp.eventData.Id,'EventId should match');
    }
    
    class MyObject
    {
        Id accId;
        Id eventId;
        Boolean attended;
        String notes;
        Boolean notesChange;
    }
    
}
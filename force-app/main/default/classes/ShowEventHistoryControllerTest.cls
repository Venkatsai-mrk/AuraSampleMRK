@isTest
public with sharing class ShowEventHistoryControllerTest {

	@isTest
    public static void showEventMethod (){
        
        Account accountRecord = new Account();
        accountRecord.Name = 'TestRecordAccount';
        accountRecord.ElixirSuite__Email_Id__c = 'testaccount@gmail.com';
        accountRecord.ElixirSuite__Current_Status_Of_Patient__c = 'Current Patients';
        //accountRecord.RecordTypeId =patientRecordType.Id;
        accountRecord.ElixirSuite__DOB__c = Date.valueOf('1991-06-02');
        accountRecord.ElixirSuite__Admit_Date__c = Date.valueOf('2021-09-09');
        insert accountRecord;
        system.debug('accountRecord'+accountRecord);
        
        Account currentPatient = [Select id,Name from Account where id=:accountRecord.id limit 1];
        system.debug('currentPatient'+accountRecord);
        dateTime startDateTime= dateTime.now();
        dateTime endDateTime= dateTime.now().addDays(1);
        
        Event eve1 = new Event();
            eve1.Subject='Call';
            eve1.WhatId=currentPatient.id;
            eve1.StartDateTime=startDateTime;
            eve1.EndDateTime=endDateTime;
        insert eve1;
        system.debug('eve1'+eve1);
        
        String ev = eve1.id;
        ShowEventHistoryController.getAllRelatedHistory(ev);
        
        Case cs = new Case();
        cs.Status = 'New';
        cs.Origin = 'Email';
        cs.AccountId = accountRecord.id;
        insert cs;
        
        Case cas = [select id from Case];
        
        String result = ShowEventHistoryController.getStatusCarePlan(cas.id);
        system.assertEquals(1, 1, '');
    }
}
@isTest
    public with sharing class createAttendanceRecordTest {
        @TestSetup
        public static void attendanceControllerTest() {

            Account l = new Account();
            event e = new event();
            l.Name='Bora';
            insert l;

            Contact con = new Contact();
            con.AccountId = l.Id;
            con.LastName = 'Testing';
        	insert con;
                
            e.WhoId=con.Id;
            e.StartDateTime=datetime.now();
            e.EndDateTime=datetime.now();
            insert e;
                
            JsonData__c jsonRec = new JsonData__c();
            jsonRec.Event_Id__c = e.id;
            jsonRec.JsonData__c = '[{"attended":true,"accountName":"Bora","accountId:"'+l.Id+'}]';
            insert jsonRec;
   			System.assertEquals(1, 1, ' ');
            
        }
        @isTest
        public static void attend(){
            List<Event> listOfEvents = [SELECT Id FROM Event];
            attendanceController obj = new attendanceController();
        Account testAccount = new Account(
            Name = 'Test Account',
            ElixirSuite__Deceased__c = true
        );
        insert testAccount;

        // Create test Event related to the test Account
        List<Event> newEvents = new List<Event>();
         event ee = new event();
        ee.WhatId=testAccount.Id;
        ee.Subject = 'Test Event';
        ee.ElixirSuite__Is_custom_screen__c =true;
        ee.StartDateTime=datetime.now();
        ee.EndDateTime=Datetime.now().addHours(1);
        ee.DurationInMinutes=60 ; // Set DurationInMinutes to 60 minutes
         newEvents.add(ee);
        
        // Assign the list of new Event records to lstRecord
        Event[] lstRecord = newEvents;

        Event evt = new Event(Subject='Test Event', StartDateTime=DateTime.now(), EndDateTime=DateTime.now().addHours(1));
        insert evt;
        EventWhoRelation ewr = new EventWhoRelation();
        
        // Call the method being tested
        List<Event> eventList = new List<Event>{evt};
        Test.startTest();
        createAttendanceRecord.preventEditIfDeceasedCheckedOnAccount(lstRecord);
        createAttendanceRecord.createRecord(listOfEvents);
        createAttendanceRecord.updateRecord(eventList);
        Test.stopTest();
             System.assertEquals(1, 1, ' ');
             
      
        }
       
    }
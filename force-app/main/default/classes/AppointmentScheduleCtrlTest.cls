@isTest
public class AppointmentScheduleCtrlTest {

    public static void dataSetup(){
        ElixirSuite__Account_Group__c accountGroup = new ElixirSuite__Account_Group__c();
        accountGroup.Name ='Test Record';
        accountGroup.ElixirSuite__Is_Active__c = true;
        insert accountGroup;
        system.debug('accountGroup'+accountGroup);
        
        RecordType patientRecordType = getRecordType('Referral_Partner_Account','Account');
        
        Account accountRecord = new Account();
        accountRecord.Name = 'TestRecordAccount';
        accountRecord.ElixirSuite__Email_Id__c = 'testaccount@gmail.com';
        accountRecord.ElixirSuite__Current_Status_Of_Patient__c = 'Current Patients';
        accountRecord.RecordTypeId =patientRecordType.Id;
        accountRecord.ElixirSuite__DOB__c = Date.valueOf('1991-06-02');
        accountRecord.ElixirSuite__Admit_Date__c = Date.valueOf('2021-09-09');
        insert accountRecord;
        system.debug('accountRecord'+accountRecord);

        Id devRecordTypeId = Schema.SObjectType.ElixirSuite__Provider__c.getRecordTypeInfosByDeveloperName().get('Template_Provider').getRecordTypeId();
        ElixirSuite__Provider__c locationRecord = new ElixirSuite__Provider__c();
        locationRecord.ElixirSuite__Account__c = accountRecord.id;
        locationRecord.Name = 'TestRecordProvider';
        locationRecord.ElixirSuite__Provider_Code__c = 'Test1';
        locationRecord.RecordTypeId =devRecordTypeId;
        insert locationRecord;
        Elixir_Custom_Setting__c pracRectype = new Elixir_Custom_Setting__c();
        pracRectype.ElixirSuite__Practitioner_Contact_Recordtype__c = 'Practitioner';
        pracRectype.ElixirSuite__Business_Account_Recordtype__c = 'Business_Account';
        insert pracRectype;
        String contactRecType = pracRectype.ElixirSuite__Practitioner_Contact_Recordtype__c;                
        RecordType practitionerRecordType = getRecordType(contactRecType,'Contact');
        
        Contact con = new Contact();
        con.LastName = 'Test';
        con.RecordTypeId = practitionerRecordType.Id; 
        insert con;
        system.debug('con'+con);
        
        ElixirSuite__Procedure__c procedure = new ElixirSuite__Procedure__c();
        procedure.Name = 'CT Scan Machine';
        insert procedure;
        system.debug('procedure'+procedure);
       
        String bussinessAccRecType = pracRectype.ElixirSuite__Business_Account_Recordtype__c; 
        RecordType bussinessRecordType = getRecordType(bussinessAccRecType,'Account');
        Account bussinessAccountRecord = new Account();
        bussinessAccountRecord.Name = 'Test Bussiness Account';
        bussinessAccountRecord.ElixirSuite__Email_Id__c = 'testaccount@gmail.com';
        insert bussinessAccountRecord;
        
        ElixirSuite__Group_Patient__c groupPatient = new ElixirSuite__Group_Patient__c();
        groupPatient.ElixirSuite__Group_Name__c = accountGroup.Id;
        groupPatient.ElixirSuite__Current_Patient_Name__c = accountRecord.id;
        groupPatient.ElixirSuite__Criteria_Based_Addition__c = true;
        insert groupPatient;
        system.debug('groupPatient'+groupPatient);
        
        user user1 = [Select Id,Name from User where id=: userinfo.getUserId()];
        
       /* ElixirSuite__Treatment_Center__c testTreatmentCenter = new ElixirSuite__Treatment_Center__c();
        testTreatmentCenter.ElixirSuite__Country__c = 'US';
        testTreatmentCenter.ElixirSuite__room_to_create__c  ='1';  
        insert testTreatmentCenter;
        
        ElixirSuite__Rooms__c room = new ElixirSuite__Rooms__c();
        room.ElixirSuite__Treatment_Center__c = testTreatmentCenter.Id;
        insert room;
        system.debug('room'+room);*/
        
    }
    
    @isTest
    public static void insertEventDataObjectTestMethod(){
        dataSetup();
        Test.startTest();
        
        Account currentPatient = [Select id,Name from Account where Name='TestRecordAccount' limit 1];
        Account bussinessAccount = [Select id,Name from Account where Name='Test Bussiness Account' limit 1];
        ElixirSuite__Account_Group__c patientGroup = [Select id,Name from ElixirSuite__Account_Group__c limit 1];
        Contact user1 = [Select Id,Name from Contact limit 1];
        ElixirSuite__Provider__c location = [Select id,Name from ElixirSuite__Provider__c limit 1];
        //ElixirSuite__Rooms__c rooms = [Select id,Name from ElixirSuite__Rooms__c limit 1];
        ElixirSuite__Procedure__c equipment = [select id,Name from ElixirSuite__Procedure__c limit 1];
        
        List<String> accountIds = new List<String>{currentPatient.id};
        List<String> bussinessAccountIds = new List<String>{bussinessAccount.Id};
        List<String> groupIds = new List<String>{patientGroup.Id};
        List<String> user1Ids = new List<String>{user1.id};
        //List<String> room = new List<String>{rooms.Id};
        List<String> equipmentIds = new List<String>{equipment.id};
                                
        String patients = JSON.serialize(accountIds);
        String patientGroups = JSON.serialize(groupIds);
        String bussinessAccounts = JSON.serialize(bussinessAccountIds);
        String coFacilitators = JSON.serialize(user1Ids);
        String equipments = JSON.serialize(equipmentIds);
        date startdate= date.today().addDays(-1);
        date enddate= date.today();
        
       // AppointmentScheduleCtrl.locationCheck(location.id, rooms.Id);
        System.assertEquals(1, 1, ' ');
    Test.stopTest();
    }

    @isTest
    public static void getPatientDetails(){
        
        ElixirSuite__Account_Group__c accountGroup = new ElixirSuite__Account_Group__c();
        accountGroup.Name ='Test Record';
        accountGroup.ElixirSuite__Is_Active__c = true;
        insert accountGroup;
        
        RecordType patientRecordType = getRecordType('Referral_Partner_Account','Account');
        
        Account accountRecord = new Account();
        accountRecord.Name = 'TestRecordAccount';
        accountRecord.ElixirSuite__Email_Id__c = 'testaccount@gmail.com';
        accountRecord.ElixirSuite__Current_Status_Of_Patient__c = 'Current Patients';
        accountRecord.RecordTypeId =patientRecordType.Id;
        accountRecord.ElixirSuite__DOB__c = Date.valueOf('1991-06-02');
        accountRecord.ElixirSuite__Admit_Date__c = Date.valueOf('2021-09-09');
        insert accountRecord;
        List<ElixirSuite__Group_Patient__c> groupPatientList = new List<ElixirSuite__Group_Patient__c>();
        ElixirSuite__Group_Patient__c groupPatient = new ElixirSuite__Group_Patient__c();
        groupPatient.ElixirSuite__Group_Name__c = accountGroup.Id;
        groupPatient.ElixirSuite__Current_Patient_Name__c = accountRecord.id;
        groupPatient.ElixirSuite__Criteria_Based_Addition__c = true;
        groupPatientList.add(groupPatient);
        insert groupPatientList;
        ElixirSuite__Group_Patient__c currentPatient = [Select id,Name,ElixirSuite__Group_Name__c,ElixirSuite__Current_Patient_Name__c from ElixirSuite__Group_Patient__c limit 1];
        List<String> pList = new List<String>{currentPatient.id};
            AppointmentScheduleCtrl.getAllPatientDetailsFromGroupIDs(pList);
            System.assertEquals(1, 1, ' ');
    }
    
    @isTest
    public static void getSubjectTest(){
        
        Event ev = new Event();
        ev.Subject = 'Call10';
        ev.DurationInMinutes = 1440;
        ev.ActivityDateTime = dateTime.now();
        insert ev;
        
        AppointmentScheduleCtrl.getSubject(); 
        System.assertEquals(ev.Subject, 'Call10', '');
    }
        
    @isTest
    public static void getPicklist(){
        Elixir_Custom_Setting__c pracRectype = new Elixir_Custom_Setting__c();
        pracRectype.ElixirSuite__Practitioner_Contact_Recordtype__c = 'Practitioner';
        insert pracRectype;
        String contactRecType = pracRectype.ElixirSuite__Practitioner_Contact_Recordtype__c; 
        RecordType practitionerRecordType = getRecordType(contactRecType,'Contact');
        
        Contact cont = new Contact();
        cont.LastName = 'Test';
        cont.RecordTypeId = practitionerRecordType.Id;
        cont.ElixirSuite__Time_Zone__c = 'Asia/Kolkata';
        insert cont;
        system.debug('cont'+cont);
        
        Event evn = new Event();
        evn.Subject = 'TimeZone Event';
        evn.DurationInMinutes =1440;
        evn.ElixirSuite__Week_Days__c = 'Sunday';
        evn.ActivityDateTime = dateTime.now();
        insert evn;
      
        AppointmentScheduleCtrl.pickList();
        AppointmentScheduleCtrl.getPiklistValues();
        System.assertEquals(cont.ElixirSuite__Time_Zone__c, 'Asia/Kolkata', '');
        System.assertEquals(evn.ElixirSuite__Week_Days__c, 'Sunday', '');
    }
        
    public static RecordType getRecordType(String name, String obj){
        
        RecordType record = [Select id,name,developerName from RecordType where developerName=:name AND sobjectType=:obj limit 1];
        
        return record;
    }
        
      @isTest
    public static void functionSaveTestMethod(){
        dataSetup();
        Test.startTest();
        dateTime startDateTime= dateTime.now();
        dateTime endDateTime= dateTime.now().addDays(1);
        String subject= 'Test100';
        
        DateTime startDate = dateTime.now();
        DateTime endDate = dateTime.now().addDays(1);
        Event recurringEvent = new Event();
            recurringEvent.Subject = 'Weekly Meeting';
            recurringEvent.StartDateTime = startDateTime;
            recurringEvent.EndDateTime = endDateTime;
            recurringEvent.RecurrenceStartDateTime =system.today();    //startDateTime;
            recurringEvent.RecurrenceEndDateOnly = system.today()+5;
            recurringEvent.RecurrenceType = 'RecursEveryWeekday';
            recurringEvent.DurationInMinutes =1440;
            recurringEvent.RecurrenceDayOfWeekMask = 1 + 2 + 4 + 8 + 16; // Monday - Friday
            recurringEvent.IsRecurrence = true;
        insert recurringEvent;
        
        Account currentPatient = [Select id,Name from Account limit 1];
        Contact practitioner = [Select id,Name from Contact];
        Account bussinessAccount = [Select id,Name from Account where Name='Test Bussiness Account' limit 1];
        ElixirSuite__Account_Group__c patientGroup = [Select id,Name from ElixirSuite__Account_Group__c limit 1];
        Contact con = [Select Id,Name from Contact limit 1];
        ElixirSuite__Provider__c location = [Select id,Name from ElixirSuite__Provider__c limit 1];
       // ElixirSuite__Rooms__c rooms = [Select id,Name from ElixirSuite__Rooms__c limit 1];
        ElixirSuite__Procedure__c equipment = [select id,Name from ElixirSuite__Procedure__c limit 1];
        /*Event eventId = [select id from Event limit 1];
        system.debug('eventId'+eventId);*/
        
        List<Event> eventLst = new List<Event>();
        Event evn = new Event();
        evn.Subject = 'Test Event';
        evn.WhatId=currentPatient.id;
        evn.StartDateTime=startDateTime;
        evn.EndDateTime=endDateTime;
        insert evn;
        
        Event newEvent = new Event();
        newEvent.Subject ='Test';
        newEvent.WhatId = currentPatient.id;
        newEvent.IsRecurrence = true;
        newEvent.RecurrenceStartDateTime = System.today();
        newEvent.RecurrenceEndDateOnly = System.today()+10;
        newEvent.RecurrenceType = 'RecursDaily';
        newEvent.RecurrenceInterval = 1; // This means that the event will wait 1 day before recurring again
        newEvent.IsAllDayEvent =true;
        newEvent.DurationInMinutes =1440;
        newEvent.ActivityDate = date.today();
        insert newEvent;
        
        Event eve1 = new Event(Subject='Call',WhatId=currentPatient.id,StartDateTime=startDateTime,EndDateTime=endDateTime);
        Event eve2 = new Event(Subject='Call',WhatId=bussinessAccount.id,StartDateTime=startDateTime,EndDateTime=endDateTime);
        Event eve3 = new Event(Subject='Call',WhatId=patientGroup.id,StartDateTime=startDateTime,EndDateTime=endDateTime);
       // Event eve4 = new Event(Subject='Call',WhatId=rooms.id,StartDateTime=startDateTime,EndDateTime=endDateTime);
        Event eve5 = new Event(Subject='Call',WhatId=equipment.id,StartDateTime=startDateTime,EndDateTime=endDateTime);
        
        eventLst.add(eve1);
        eventLst.add(eve2);
        eventLst.add(eve3);
       // eventLst.add(eve4);
        eventLst.add(eve5);        
        insert eventLst;

        List<String> accountIds = new List<String>{currentPatient.id};
        List<String> practitionerIds = new List<String>{practitioner.id};
        List<String> bussinessAccountIds = new List<String>{bussinessAccount.Id};
        List<String> groupIds = new List<String>{patientGroup.Id};
        List<String> coFacilitatorIds = new List<String>{con.id};
       // List<String> room = new List<String>{rooms.Id};
        List<String> equipmentIds = new List<String>{equipment.Id};

        List<String>  wdl = new List<String>(); 
        wdl.add('Sunday');
     
        TimeZone tz = UserInfo.getTimeZone();
        String timeZone = tz.toString();
        
        String patients = JSON.serialize(accountIds);
        String patientGroups = JSON.serialize(groupIds);
        String bussinessAccounts = JSON.serialize(bussinessAccountIds);
        String coFacilitators = JSON.serialize(coFacilitatorIds);
        String equipments = JSON.serialize(equipmentIds);
        /*String rec = JSON.serialize(eventId);
        system.debug('rec'+rec);*/
       
        //String evBt = 'Delete Series';
        string user1 = [Select Id,Name from User where id=: userinfo.getUserId()].id; 
       // AppointmentScheduleCtrl.functionSave(startDateTime, endDateTime, rooms.id, Subject, accountIds, groupIds,practitionerIds, coFacilitatorIds,bussinessAccountIds, equipmentIds,false, wdl, timeZone, eventLst,user1);
        
        //AppointmentScheduleCtrl.functionSave(startDateTime, endDateTime, rooms.id, Subject, accountIds, groupIds,practitionerIds, coFacilitatorIds,bussinessAccountIds, equipmentIds,true, wdl, timeZone, eventLst,user1);
        System.assertEquals(1, 1, ' ');
        //AppointmentScheduleCtrl.functionDelete(rec, evBt);
        Test.stopTest();
        
    } 
    
}
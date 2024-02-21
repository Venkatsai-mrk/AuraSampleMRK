@isTest
public class EditAppointmentScheduleTest {

    /*public static void dataSetup(){
        
        ElixirSuite__Provider__c locationRecord = new ElixirSuite__Provider__c();
        locationRecord.Name = 'TestRecordProvider';
        locationRecord.ElixirSuite__Provider_Code__c = 'Test1';
        locationRecord.RecordTypeId =Schema.SObjectType.ElixirSuite__Provider__c.getRecordTypeInfosByDeveloperName().get('Template_Provider').getRecordTypeId();
        insert locationRecord;
        
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
        Account accountRecord2 = new Account();
        accountRecord2.Name = 'TestRecordAccount';
        accountRecord2.ElixirSuite__Email_Id__c = 'testaccount@gmail.com';
        accountRecord2.ElixirSuite__Current_Status_Of_Patient__c = 'Current Patients';
        accountRecord2.RecordTypeId =patientRecordType.Id;
        accountRecord2.ElixirSuite__DOB__c = Date.valueOf('1991-06-02');
        accountRecord2.ElixirSuite__Admit_Date__c = Date.valueOf('2021-09-09');
        insert accountRecord2;
        
        RecordType bussinessRecordType = getRecordType('Business_Account','Account');
        Account bussinessAccountRecord = new Account();
        bussinessAccountRecord.Name = 'Test Bussiness Account';
        bussinessAccountRecord.ElixirSuite__Email_Id__c = 'testaccount@gmail.com';
        bussinessAccountRecord.RecordTypeId = bussinessRecordType.id;
        insert bussinessAccountRecord;
        
        ElixirSuite__Group_Patient__c groupPatient = new ElixirSuite__Group_Patient__c();
        groupPatient.ElixirSuite__Group_Name__c = accountGroup.Id;
        groupPatient.ElixirSuite__Current_Patient_Name__c = accountRecord.id;
        groupPatient.ElixirSuite__Criteria_Based_Addition__c = true;
        insert groupPatient;
        
        user user1 = [Select Id,Name from User where id=: userinfo.getUserId()];
        
        ElixirSuite__Treatment_Center__c testTreatmentCenter = new ElixirSuite__Treatment_Center__c();
        testTreatmentCenter.ElixirSuite__Country__c = 'US';
        testTreatmentCenter.ElixirSuite__room_to_create__c  ='1';  
        insert testTreatmentCenter;
        
        ElixirSuite__Rooms__c room = new ElixirSuite__Rooms__c();
        room.ElixirSuite__Treatment_Center__c = testTreatmentCenter.Id;
        
        insert room;
        
        ElixirSuite__Procedure__c testEquipment = new ElixirSuite__Procedure__c();
        testEquipment.Name ='Test Equipment';
        testEquipment.ElixirSuite__Quantity__c = 3;
        insert testEquipment;
        
        
        List<Equip> equipmentIds = new List<Equip>();
        Equip equipObject = new Equip();
        equipObject.Id = testEquipment.id;
        equipObject.EquipmentNeed = '4';
        equipmentIds.add(equipObject);
        
        List<String> accountIds = new List<String>{accountRecord2.id,accountRecord.id};
        List<String> bussinessAccountIds = new List<String>{bussinessAccountRecord.Id};
        List<String> groupIds = new List<String>{accountGroup.Id};
        List<String> user1Ids = new List<String>{user1.id};
            
            
        String patients = JSON.serialize(accountIds);
        String patientGroups = JSON.serialize(groupIds);
        String bussinessAccounts = JSON.serialize(bussinessAccountIds);
        String coFacilitators = JSON.serialize(user1Ids);
        //String equipments = JSON.serialize(equipmentIds);
        date startdate= date.today().addDays(-1);
        date enddate= date.today();
        
        List<ElixirSuite__Equipment_Line_Item__c> eqLineItemLst = new List<ElixirSuite__Equipment_Line_Item__c>();
        ElixirSuite__Equipment_Line_Item__c eqLineItem = new ElixirSuite__Equipment_Line_Item__c();
        eqLineItem.ElixirSuite__Room_No__c = room.id;
        
        ElixirSuite__Equipment_Line_Item__c eqLineItemSecond = new ElixirSuite__Equipment_Line_Item__c();
        eqLineItemSecond.ElixirSuite__Room_No__c = room.Id;
        
        ElixirSuite__Equipment_Line_Item__c eqLineItemThird = new ElixirSuite__Equipment_Line_Item__c();
        
        eqLineItemLst.add(eqLineItem);
        eqLineItemLst.add(eqLineItemSecond);
        eqLineItemLst.add(eqLineItemThird);
        insert eqLineItemLst;
        
        ElixirSuite__Event_Data_Object__c eventDataObject = new ElixirSuite__Event_Data_Object__c();
        eventDataObject.ElixirSuite__Assigned_To__c = user1.id;
        eventDataObject.ElixirSuite__All_Day_event__c = true;
        eventDataObject.ElixirSuite__End_Date_and_Time__c = enddate;
        eventDataObject.ElixirSuite__Start_Date_Time__c = startdate;
        eventDataObject.ElixirSuite__Rooms__c = room.Id;
        eventDataObject.ElixirSuite__Patients__c = patients;
        eventDataObject.ElixirSuite__Patient_Groups__c = patientGroups;
        eventDataObject.ElixirSuite__Related_Business_Accounts__c = bussinessAccounts;
        //eventDataObject.ElixirSuite__Co_Facilitators__c = coFacilitators;
       
        insert eventDataObject;
        
        Event eventTestRecord = new Event();
        eventTestRecord.Subject = 'Meeting Test';
        eventTestRecord.ElixirSuite__Event_Data_Object__c = eventDataObject.id;
        eventTestRecord.OwnerId = user1.id;
        eventTestRecord.IsAllDayEvent = true;
        eventTestRecord.StartDateTime = date.today().addDays(-2);
        eventTestRecord.EndDateTime = enddate;
        eventTestRecord.ElixirSuite__Is_custom_screen__c =true;
        eventTestRecord.ElixirSuite__By_Pass_Check__c = false;
        insert eventTestRecord;
        
        ElixirSuite__Event_Data_Object__c eventDataObject2 = new ElixirSuite__Event_Data_Object__c();
        eventDataObject2.ElixirSuite__Assigned_To__c = user1.id;
        eventDataObject2.ElixirSuite__All_Day_event__c = false;
        eventDataObject2.ElixirSuite__End_Date_and_Time__c = enddate;
        eventDataObject2.ElixirSuite__Start_Date_Time__c = startdate;
        eventDataObject2.ElixirSuite__Rooms__c = room.Id;
        eventDataObject2.ElixirSuite__Patients__c = patients;
        eventDataObject2.ElixirSuite__Patient_Groups__c = patientGroups;
        eventDataObject2.ElixirSuite__Related_Business_Accounts__c = bussinessAccounts;
        //eventDataObject.ElixirSuite__Co_Facilitators__c = coFacilitators;
        
        
        insert eventDataObject2;
        
        Event newEvent = new Event();
        newEvent.Subject ='Test';
        newEvent.IsRecurrence = true;
        newEvent.ElixirSuite__Event_Data_Object__c = eventDataObject2.id;
        newEvent.RecurrenceStartDateTime = System.today();
        newEvent.RecurrenceEndDateOnly = System.today()+30;
        newEvent.RecurrenceType = 'RecursDaily';
        newEvent.RecurrenceInterval = 1; // This means that the event will wait 1 day before recurring again
        newEvent.IsAllDayEvent =true;
        newEvent.DurationInMinutes =1440;
        newEvent.ElixirSuite__Is_custom_screen__c =true;
        newEvent.ElixirSuite__By_Pass_Check__c = true;
        newEvent.ActivityDate = Date.today();
        insert newEvent;
        
    }
    
    @isTest
    public static void updateEventWithRepeatFalseTestMethod(){
        dataSetup();
        ElixirSuite__Event_Data_Object__c ec =[SELECT Id, Name, ElixirSuite__Patients__c, ElixirSuite__Patient_Groups__c, ElixirSuite__Co_Facilitators__c,  ElixirSuite__Related_Business_Accounts__c FROM ElixirSuite__Event_Data_Object__c where ElixirSuite__All_Day_event__c =true limit 1];

        Event ev = [Select id,subject,StartDateTime,WhoId,Description,EndDateTime,IsAllDayEvent,IsRecurrence2,WhatId,ElixirSuite__Event_Data_Object__c,ElixirSuite__By_Pass_Check__c,ElixirSuite__Is_custom_screen__c from Event where ElixirSuite__Is_custom_screen__c=true AND IsRecurrence=false limit 1];
        
        Test.startTest();
       
        ev.Subject ='Meeting Test UPdated';
        
        update ev;
        CheckRecursive.run = true;
        EditAppointmentSchedule.editAppointmentForRepeatFalse(new List<Event>{ev});
        Test.stopTest();
        
        System.assertEquals(5, [Select id,Subject,ElixirSuite__Event_Data_Object__c from Event where IsRecurrence=false and ElixirSuite__Event_Data_Object__c =: ec.Id].size());
        System.assertEquals('Meeting Test UPdated', [Select id,Subject,StartDateTime from Event where IsRecurrence=false limit 1].Subject);

    }
    
    @isTest
    public static void updateEventWithRepeatFalseWithRoomONlyTestMethod(){
        dataSetup();
        ElixirSuite__Event_Data_Object__c ec =[SELECT Id, Name, ElixirSuite__Patients__c, ElixirSuite__Patient_Groups__c, ElixirSuite__Co_Facilitators__c, ElixirSuite__Related_Business_Accounts__c FROM ElixirSuite__Event_Data_Object__c where ElixirSuite__All_Day_event__c =true limit 1];
        Event ev = [Select id,IsRecurrence2,StartDateTime,WhoId,EndDateTime,WhatId,subject,ElixirSuite__By_Pass_Check__c,IsAllDayEvent,Description,ElixirSuite__Event_Data_Object__c,ElixirSuite__Is_custom_screen__c from Event where ElixirSuite__Is_custom_screen__c=true AND Subject='Meeting Test' limit 1];
        
        Test.startTest();
        List<Equip> equipmentIds = new List<Equip>();
        Equip equipObject = new Equip();
        equipObject.Id ='';
        equipObject.EquipmentNeed = '4';
        equipmentIds.add(equipObject);
        
        update ec;
        
        //ev.Subject ='Meeting Test UPdated';
        
        //update ev;
        
        CheckRecursive.run = true;
        EditAppointmentSchedule.editAppointmentForRepeatFalse(new List<Event>{ev});
        Test.stopTest();
        System.assertEquals(5, [Select id,Subject,ElixirSuite__Event_Data_Object__c from Event where IsRecurrence=false and ElixirSuite__Event_Data_Object__c =: ec.id].size());
        System.assertEquals('Meeting Test', [Select id,Subject,StartDateTime from Event where IsRecurrence=false limit 1].Subject);

    }
    @isTest
    public static void updateEventWithRepeatFalseWithoutRoomONlyTestMethod(){
        dataSetup();
        ElixirSuite__Event_Data_Object__c ec =[SELECT Id,ElixirSuite__Rooms__c, Name, ElixirSuite__Patients__c, ElixirSuite__Patient_Groups__c, ElixirSuite__Co_Facilitators__c, ElixirSuite__Related_Business_Accounts__c FROM ElixirSuite__Event_Data_Object__c where ElixirSuite__All_Day_event__c =true limit 1];
        Event ev = [Select id,subject,ElixirSuite__Is_custom_screen__c,Description from Event where ElixirSuite__Is_custom_screen__c=true AND IsRecurrence=false limit 1];
        
        Test.startTest();
        
        ec.ElixirSuite__Rooms__c = null;
        update ec;
        
        ev.Subject ='Meeting Test UPdated';
        
        update ev;
        Test.stopTest();
        //System.assertEquals(7, [Select id,Subject,ElixirSuite__Event_Data_Object__c from Event where IsRecurrence=false AND ElixirSuite__Event_Data_Object__c=: ec.id].size());
        System.assertEquals('Meeting Test UPdated', [Select id,Subject,StartDateTime from Event where IsRecurrence=false limit 1].Subject);
    }
    
    @isTest
    public static void updateEventWithRepeatTrueTestMethod(){
        dataSetup();
        ElixirSuite__Event_Data_Object__c ec =[SELECT Id,ElixirSuite__Rooms__c, Name, ElixirSuite__Patients__c, ElixirSuite__Patient_Groups__c, ElixirSuite__Co_Facilitators__c, ElixirSuite__Related_Business_Accounts__c FROM ElixirSuite__Event_Data_Object__c where ElixirSuite__All_Day_event__c =false limit 1];
        Event ev = [Select id,subject,ElixirSuite__Is_custom_screen__c from Event where ElixirSuite__Is_custom_screen__c=true AND IsRecurrence=true limit 1];
        
        Test.startTest();
        ev.Subject ='Meeting Test UPdated';
        update ev;
        Test.stopTest();
        //System.assertEquals(128, [Select id,Subject,ElixirSuite__Event_Data_Object__c from Event where  ElixirSuite__Event_Data_Object__c=: ec.id].size());
      
    
    }
    
    @isTest
    public static void updateEventWithRepeatTrueWithRoomOnlyTestMethod(){
        dataSetup();
        ElixirSuite__Event_Data_Object__c ec =[SELECT Id, Name, ElixirSuite__Patients__c, ElixirSuite__Patient_Groups__c, ElixirSuite__Co_Facilitators__c, ElixirSuite__Related_Business_Accounts__c FROM ElixirSuite__Event_Data_Object__c limit 1];
        Event ev = [Select id,subject,ElixirSuite__Is_custom_screen__c from Event where ElixirSuite__Is_custom_screen__c=true AND IsRecurrence=true limit 1];
        
        Test.startTest();
        List<Equip> equipmentIds = new List<Equip>();
        Equip equipObject = new Equip();
        equipObject.Id ='';
        equipObject.EquipmentNeed = '4';
        equipmentIds.add(equipObject);
                update ec;
        
        ev.Subject ='Meeting Test UPdated';
        update ev;
        Test.stopTest();
    }
    
   /* @isTest
    public static void getEquipmentLineItemsIdForEquipmentTestMethod(){
        dataSetup();
        date startdate= date.today().addDays(-1);
        date enddate= date.today();
       
        
        Test.startTest();
        Set<String> equipmentLineItemsId =EditAppointmentSchedule.getEquipmentLineItemsIdForEquipment(equipment.id, 5, startdate, enddate, false);
        Test.stopTest();
        
        System.assertEquals(4, equipmentLineItemsId.size()); 
        
    }
    public static RecordType getRecordType(String name, String obj){
        RecordType record = [Select id,name,developerName from RecordType where developerName=:name AND sobjectType=:obj limit 1];
        
        return record;
    }
    public class Equip{
        String Id;
        String EquipmentNeed;
    }*/
    
}
@isTest
public class CreateAppointmentScheduleTest {
    
    
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
        
    }
    
    @isTest
    public static void insertEventDataObjectTestMethod(){
        dataSetup();
        
        
        List<Account> currentPatients = [Select id,Name from Account where ElixirSuite__Current_Status_Of_Patient__c = 'Current Patients'];
        Account bussinessAccount = [Select id,Name from Account where Name='Test Bussiness Account' limit 1];
        ElixirSuite__Account_Group__c patientGroup = [Select id,Name from ElixirSuite__Account_Group__c limit 1];
        user user1 = [Select Id,Name from User where id=: userinfo.getUserId()];
        
        ElixirSuite__Rooms__c rooms = [Select id,Name from ElixirSuite__Rooms__c limit 1];
        
        
        List<Equip> equipmentIds = new List<Equip>();
        Equip equipObject = new Equip();
        //equipObject.Id = equipment.id;
        equipObject.EquipmentNeed = '4';
        equipmentIds.add(equipObject);
        
        List<String> accountIds = new List<String>{currentPatients[0].id,currentPatients[1].id};
        List<String> bussinessAccountIds = new List<String>{bussinessAccount.Id};
        List<String> groupIds = new List<String>{patientGroup.Id};
        List<String> user1Ids = new List<String>{user1.id};
            
            
        String patients = JSON.serialize(accountIds);
        String patientGroups = JSON.serialize(groupIds);
        String bussinessAccounts = JSON.serialize(bussinessAccountIds);
        String coFacilitators = JSON.serialize(user1Ids);
        String equipments = JSON.serialize(equipmentIds);
        date startdate= date.today().addDays(-1);
        date enddate= date.today();
        
        Test.startTest();
        List<ElixirSuite__Equipment_Line_Item__c> eqLineItemLst = new List<ElixirSuite__Equipment_Line_Item__c>();
        ElixirSuite__Equipment_Line_Item__c eqLineItem = new ElixirSuite__Equipment_Line_Item__c();
        //eqLineItem.ElixirSuite__Equipment_Name__c = equipment.id;
        eqLineItem.ElixirSuite__Room_No__c = rooms.id;
        
        ElixirSuite__Equipment_Line_Item__c eqLineItemSecond = new ElixirSuite__Equipment_Line_Item__c();
       // eqLineItemSecond.ElixirSuite__Equipment_Name__c = equipment.id;
        eqLineItemSecond.ElixirSuite__Room_No__c = rooms.Id;
        
        ElixirSuite__Equipment_Line_Item__c eqLineItemThird = new ElixirSuite__Equipment_Line_Item__c();
        //eqLineItemThird.ElixirSuite__Equipment_Name__c = equipment.id;
        
        eqLineItemLst.add(eqLineItem);
        eqLineItemLst.add(eqLineItemSecond);
        eqLineItemLst.add(eqLineItemThird);
        insert eqLineItemLst;
        
        Event ev = new Event(Subject='Test Call',WhatId=eqLineItemLst[0].id, StartDateTime=startdate,EndDateTime=enddate,IsAllDayEvent=true);
        insert ev;
        
        ElixirSuite__Event_Data_Object__c eventDataObject = new ElixirSuite__Event_Data_Object__c();
        eventDataObject.ElixirSuite__Assigned_To__c = user1.id;
        eventDataObject.ElixirSuite__All_Day_event__c = true;
        eventDataObject.ElixirSuite__End_Date_and_Time__c = enddate;
        eventDataObject.ElixirSuite__Start_Date_Time__c = startdate;
        eventDataObject.ElixirSuite__Rooms__c = rooms.Id;
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
        
        Test.stopTest();
        String eveObj = eventDataObject.id;
       // System.assertEquals(7, [Select id,Subject,ElixirSuite__Event_Data_Object__c from Event where Subject='Meeting Test'].size());
        System.assertEquals(date.today().addDays(-2), [Select id,Subject,StartDateTime from Event where Subject='Meeting Test' limit 1].StartDateTime);
        System.assertEquals(enddate, [Select id,Subject,EndDateTime from Event where Subject='Meeting Test' limit 1].EndDateTime);
    
    }
    
    @isTest
    public static void insertEventDataObjectWithRoomAndWithoutEquipmentTestMethod(){
        dataSetup();
        
        
        List<Account> currentPatients = [Select id,Name from Account where ElixirSuite__Current_Status_Of_Patient__c = 'Current Patients'];
        Account bussinessAccount = [Select id,Name from Account where Name='Test Bussiness Account' limit 1];
        ElixirSuite__Account_Group__c patientGroup = [Select id,Name from ElixirSuite__Account_Group__c limit 1];
        user user1 = [Select Id,Name from User where id=: userinfo.getUserId()];
        
        ElixirSuite__Rooms__c rooms = [Select id,Name from ElixirSuite__Rooms__c limit 1];
       
        List<Equip> equipmentIds = new List<Equip>();
       
        
        List<String> accountIds = new List<String>{currentPatients[0].id,currentPatients[1].id};
        List<String> bussinessAccountIds = new List<String>{bussinessAccount.Id};
        List<String> groupIds = new List<String>{patientGroup.Id};
        List<String> user1Ids = new List<String>{user1.id};
            
            
        String patients = JSON.serialize(accountIds);
        String patientGroups = JSON.serialize(groupIds);
        String bussinessAccounts = JSON.serialize(bussinessAccountIds);
        String coFacilitators = JSON.serialize(user1Ids);
        String equipments = JSON.serialize(equipmentIds);
        date startdate= date.today().addDays(-1);
        date enddate= date.today();
        
        Test.startTest();
        List<ElixirSuite__Equipment_Line_Item__c> eqLineItemLst = new List<ElixirSuite__Equipment_Line_Item__c>();
        ElixirSuite__Equipment_Line_Item__c eqLineItem = new ElixirSuite__Equipment_Line_Item__c();
        //eqLineItem.ElixirSuite__Equipment_Name__c = equipment.id;
        eqLineItem.ElixirSuite__Room_No__c = rooms.id;
        
        ElixirSuite__Equipment_Line_Item__c eqLineItemSecond = new ElixirSuite__Equipment_Line_Item__c();
        //eqLineItemSecond.ElixirSuite__Equipment_Name__c = equipment.id;
        eqLineItemSecond.ElixirSuite__Room_No__c = rooms.Id;
        
        eqLineItemLst.add(eqLineItem);
        eqLineItemLst.add(eqLineItemSecond);
        insert eqLineItemLst;

        Event ev = new Event(Subject='Test Call',WhatId=eqLineItemLst[0].id, StartDateTime=startdate,EndDateTime=enddate,IsAllDayEvent=true);
        insert ev;
        
        ElixirSuite__Event_Data_Object__c eventDataObject = new ElixirSuite__Event_Data_Object__c();
        eventDataObject.ElixirSuite__Assigned_To__c = user1.id;
        eventDataObject.ElixirSuite__All_Day_event__c = true;
        eventDataObject.ElixirSuite__End_Date_and_Time__c = enddate;
        eventDataObject.ElixirSuite__Start_Date_Time__c = startdate;
        eventDataObject.ElixirSuite__Rooms__c = rooms.Id;
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
        
        Test.stopTest();
        System.assertEquals(7, [Select id,Subject,ElixirSuite__Event_Data_Object__c from Event where Subject='Meeting Test'].size());
        System.assertEquals(date.today().addDays(-2), [Select id,Subject,StartDateTime from Event where Subject='Meeting Test' limit 1].StartDateTime);
        System.assertEquals(enddate, [Select id,Subject,EndDateTime from Event where Subject='Meeting Test' limit 1].EndDateTime);
        
    }
    
    @isTest
    public static void insertEventDataObjectWithEquipmentAndWithoutRoomTestMethod(){
        dataSetup();
        
        
        List<Account> currentPatients = [Select id,Name from Account where ElixirSuite__Current_Status_Of_Patient__c = 'Current Patients'];
        Account bussinessAccount = [Select id,Name from Account where Name='Test Bussiness Account' limit 1];
        ElixirSuite__Account_Group__c patientGroup = [Select id,Name from ElixirSuite__Account_Group__c limit 1];
        user user1 = [Select Id,Name from User where id=: userinfo.getUserId()];
        
        ElixirSuite__Rooms__c rooms = [Select id,Name from ElixirSuite__Rooms__c limit 1];
        
        
        List<Equip> equipmentIds = new List<Equip>();
        Equip equipObject = new Equip();
        //equipObject.Id = equipment.id;
        equipObject.EquipmentNeed = '10';
        equipmentIds.add(equipObject);
        
        List<String> accountIds = new List<String>{currentPatients[0].id,currentPatients[1].id};
        List<String> bussinessAccountIds = new List<String>{bussinessAccount.Id};
        List<String> groupIds = new List<String>{patientGroup.Id};
        List<String> user1Ids = new List<String>{user1.id};
            
            
        String patients = JSON.serialize(accountIds);
        String patientGroups = JSON.serialize(groupIds);
        String bussinessAccounts = JSON.serialize(bussinessAccountIds);
        String coFacilitators = JSON.serialize(user1Ids);
        String equipments = JSON.serialize(equipmentIds);
        date startdate= date.today().addDays(-1);
        date enddate= date.today();
        
        Test.startTest();
        List<ElixirSuite__Equipment_Line_Item__c> eqLineItemLst = new List<ElixirSuite__Equipment_Line_Item__c>();
        ElixirSuite__Equipment_Line_Item__c eqLineItem = new ElixirSuite__Equipment_Line_Item__c();
        //eqLineItem.ElixirSuite__Equipment_Name__c = equipment.id;
        eqLineItem.ElixirSuite__Room_No__c = rooms.id;
        
        ElixirSuite__Equipment_Line_Item__c eqLineItemSecond = new ElixirSuite__Equipment_Line_Item__c();
        //eqLineItemSecond.ElixirSuite__Equipment_Name__c = equipment.id;
        eqLineItemSecond.ElixirSuite__Room_No__c = rooms.Id;
        
        eqLineItemLst.add(eqLineItem);
        eqLineItemLst.add(eqLineItemSecond);
        insert eqLineItemLst;
        
        Event ev = new Event(Subject='Test Call',WhatId=eqLineItemLst[0].id, StartDateTime=startdate,EndDateTime=enddate,IsAllDayEvent=true);
        insert ev;
        
        ElixirSuite__Event_Data_Object__c eventDataObject = new ElixirSuite__Event_Data_Object__c();
        eventDataObject.ElixirSuite__Assigned_To__c = user1.id;
        eventDataObject.ElixirSuite__All_Day_event__c = true;
        eventDataObject.ElixirSuite__End_Date_and_Time__c = enddate;
        eventDataObject.ElixirSuite__Start_Date_Time__c = startdate;
       // eventDataObject.ElixirSuite__Rooms__c = rooms.Id;
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
        insert eventTestRecord;
        
        Test.stopTest();
        System.assertEquals(10, [Select id,Subject,ElixirSuite__Event_Data_Object__c from Event where Subject='Meeting Test'].size());
        System.assertEquals(date.today().addDays(-2), [Select id,Subject,StartDateTime from Event where Subject='Meeting Test' limit 1].StartDateTime);
        System.assertEquals(enddate, [Select id,Subject,EndDateTime from Event where Subject='Meeting Test' limit 1].EndDateTime);
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
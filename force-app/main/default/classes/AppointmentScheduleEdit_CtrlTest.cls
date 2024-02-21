@isTest
public class AppointmentScheduleEdit_CtrlTest {

   
   /* public static void dataSetup(){
        
        ElixirSuite__Provider__c locationRecord = new ElixirSuite__Provider__c();
        locationRecord.Name = 'TestRecordProvider';
        locationRecord.ElixirSuite__Provider_Code__c = 'Test1';
        locationRecord.RecordTypeId = Schema.SObjectType.ElixirSuite__Provider__c.getRecordTypeInfosByDeveloperName().get('Template_Provider').getRecordTypeId();

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
        
        ElixirSuite__Procedure__c procedure = new ElixirSuite__Procedure__c();
        procedure.Name = 'CT Scan Machine';
        insert procedure;
        system.debug('procedure'+procedure);
                
        List<String> accountIds = new List<String>{accountRecord.id,accountRecord2.id};
        List<String> bussinessAccountIds = new List<String>{bussinessAccountRecord.Id};
        List<String> groupIds = new List<String>{accountGroup.Id};
        List<String> user1Ids = new List<String>{user1.id};
            
        List<ElixirSuite__Procedure__c> equipmentIds = new List<ElixirSuite__Procedure__c>();
        ElixirSuite__Procedure__c equipObject = new ElixirSuite__Procedure__c();
        equipObject.Id = procedure.id;
        equipmentIds.add(equipObject);
            
        String patients = JSON.serialize(accountIds);
        String patientGroups = JSON.serialize(groupIds);
        String bussinessAccounts = JSON.serialize(bussinessAccountIds);
        String coFacilitators = JSON.serialize(user1Ids);
        String equipments = JSON.serialize(equipmentIds);
        date startdate= date.today().addDays(-1);
        date enddate= date.today();
        
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
        //eventDataObject.ElixirSuite__Procedure__c = equipments;
        
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
        
    }
    @isTest
    public static void getEventDataObjectTestMethod(){
        /*dataSetup();
        ElixirSuite__Event_Data_Object__c eveDataObj = [select id,Name from ElixirSuite__Event_Data_Object__c limit 1];
        Event getEventRecord = [Select id,Subject,ElixirSuite__Event_Data_Object__c from Event limit 1];
        Test.startTest();
        
        String actualRes =AppointmentScheduleEdit_Ctrl.getEventDataObject(getEventRecord.id);
        Test.stopTest();
        
        System.assertEquals(eveDataObj.id, actualRes);
        
    }
    @isTest
    public static void getMultiSelectedObjectRecordsTestMethod(){
        dataSetup();
        List<Account> currentPatients = [Select id,Name from Account where ElixirSuite__Current_Status_Of_Patient__c = 'Current Patients'];
        Account bussinessAccount = [Select id,Name from Account where Name='Test Bussiness Account' limit 1];
        ElixirSuite__Account_Group__c patientGroup = [Select id,Name from ElixirSuite__Account_Group__c limit 1];
        
        ElixirSuite__Event_Data_Object__c eventDataRecord =[Select id,ElixirSuite__Patients__c,ElixirSuite__Patient_Groups__c,ElixirSuite__Provider__c,ElixirSuite__Rooms__c,
                                                           ElixirSuite__Related_Business_Accounts__c,ElixirSuite__Co_Facilitators__c from ElixirSuite__Event_Data_Object__c  limit 1];
        
        Test.startTest();
       
        AppointmentScheduleEdit_Ctrl.MulitSelectedRecordsWrapper wrap= AppointmentScheduleEdit_Ctrl.getMultiSelectedObjectRecords(eventDataRecord.id);
        Test.stopTest();
        
        System.assertEquals(2, wrap.selectedpatientAccounts.size());
        System.assertEquals(1, wrap.selectedGroups.size());
        System.assertEquals(1, wrap.selectedbussinessAccounts.size());
    }
    /*
    @isTest
    public static void modifyEventDataObjectTestMethod(){
        dataSetup();
        
        List<Account> currentPatients = [Select id,Name from Account where ElixirSuite__Current_Status_Of_Patient__c = 'Current Patients'];
        Account bussinessAccount = [Select id,Name from Account where Name='Test Bussiness Account' limit 1];
        ElixirSuite__Account_Group__c patientGroup = [Select id,Name from ElixirSuite__Account_Group__c limit 1];
        user user1 = [Select Id,Name from User where id=: userinfo.getUserId()];
        ElixirSuite__Rooms__c rooms = [Select id,Name from ElixirSuite__Rooms__c limit 1];
        ElixirSuite__Provider__c location = [Select id,Name from ElixirSuite__Provider__c limit 1];
        ElixirSuite__Procedure__c equipment = [select id,Name from ElixirSuite__Procedure__c limit 1];
        ElixirSuite__Event_Data_Object__c eveDataObj = [select id,Name from ElixirSuite__Event_Data_Object__c limit 1];
        
        List<Equip> equipmentIds = new List<Equip>();
        ElixirSuite__Procedure__c equipObject = new ElixirSuite__Procedure__c();
        equipObject.Id = equipment.id;
        equipmentIds.add(equipObject);
        
        List<String> accountIds = new List<String>{currentPatients[0].id,currentPatients[1].id};
        List<String> bussinessAccountIds = new List<String>{bussinessAccount.Id};
        List<String> groupIds = new List<String>{patientGroup.Id};
        List<String> user1Ids = new List<String>{user1.id};
            
            
        String patients = JSON.serialize(accountIds);
        String patientGroups = JSON.serialize(groupIds);
        String bussinessAccounts = JSON.serialize(bussinessAccountIds);
        String coFacilitators = JSON.serialize(user1Ids);
        //String equipments = JSON.serialize(equipmentIds);
        
        Test.startTest();
        
        AppointmentScheduleEdit_Ctrl.modifyEventDataObject(eveDataObj.id, patients, patientGroups, bussinessAccounts, coFacilitators, location.id, rooms.id, equipments,'');
        Test.stopTest();
        
        ElixirSuite__Event_Data_Object__c eventDataRecord =[Select id,ElixirSuite__Patients__c,ElixirSuite__Patient_Groups__c,ElixirSuite__Provider__c,ElixirSuite__Rooms__c,
                                                           ElixirSuite__Related_Business_Accounts__c,ElixirSuite__Co_Facilitators__c,ElixirSuite__Procedure__c from ElixirSuite__Event_Data_Object__c where id=: eveDataObj.id];
        
        System.assertEquals(patients, eventDataRecord.ElixirSuite__Patients__c);
        System.assertEquals(patientGroups, eventDataRecord.ElixirSuite__Patient_Groups__c);
        System.assertEquals(bussinessAccounts, eventDataRecord.ElixirSuite__Related_Business_Accounts__c);
        System.assertEquals(coFacilitators, eventDataRecord.ElixirSuite__Co_Facilitators__c);
        
    }
    
    
    public static RecordType getRecordType(String name, String obj){
        
        RecordType record = [Select id,name,developerName from RecordType where developerName=:name AND sobjectType=:obj limit 1];
        
        return record;
    }
    /*public class Equip{
        String Id;
        String EquipmentNeed;
    }*/
    
}
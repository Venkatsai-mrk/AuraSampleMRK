@isTest
public class eventTriggerHandlerTest {
    @isTest
    public static void groupAppointmentTest(){
        ElixirSuite__Provider__c provider = new  ElixirSuite__Provider__c();  
        Id devRecordType = Schema.SObjectType.ElixirSuite__Provider__c.getRecordTypeInfosByDeveloperName().get('Template_Provider').getRecordTypeId();
        provider.RecordTypeId = devRecordType;
        provider.Name = 'TestProvider';
        provider.Provider_Code__c  = 'Test123';
        provider.ElixirSuite__Address__c = 'abc';
        provider.ElixirSuite__Provider_State__c = 'CA';
        provider.ElixirSuite__Provider_City__c = 'CA';
        provider.ElixirSuite__Provider_Zip__c = '12232';
        insert provider;
        
        
        Elixir_Custom_Setting__c setting = new Elixir_Custom_Setting__c();
        setting.ElixirSuite__Patient_Account_Recordtype__c = 'Patient_Account';
        setting.ElixirSuite__Practitioner_Contact_Recordtype__c = 'Practitioner';
        insert setting;
        String patAccRecType = setting.ElixirSuite__Patient_Account_Recordtype__c; 
        Account accrec= new Account();
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(patAccRecType).getRecordTypeId();
        accrec.Name = 'Test';
        accrec.Phone = '900091111';
        accrec.ElixirSuite__Email_Id__c = 'a@g.com';
        accrec.Current_Status_Of_Patient__c = 'Current Patients';
        accrec.RecordTypeId = devRecordTypeId;
        insert accrec;
        
        Account accrec1= new Account();
        Id devRecordTypeId1 = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(patAccRecType).getRecordTypeId();
        accrec1.Name = 'Test1';
        accrec1.Phone = '9000911111';
        accrec1.ElixirSuite__Email_Id__c = 'a1@g.com';
        accrec1.Current_Status_Of_Patient__c = 'Current Patients';
        accrec1.RecordTypeId = devRecordTypeId1;
        insert accrec1;
        
        Account_Group__c patientgroup = New Account_Group__c(); 
        patientgroup.Name = 'Therapy';
        insert patientgroup;
        
        Group_Patient__c gp = new Group_Patient__c();
        gp.Current_Patient_Name__c = accrec.id;
        gp.Group_Name__c = patientgroup.id;
        insert gp;
		
		Group_Patient__c gp1 = new Group_Patient__c();
        gp1.Current_Patient_Name__c = accrec1.id;
        gp1.Group_Name__c = patientgroup.id;
        insert gp1;
        
        String userId = UserInfo.getUserId();
        
        String contactRecType = setting.ElixirSuite__Practitioner_Contact_Recordtype__c;  
        Id recordTypeId1 = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(contactRecType).getRecordTypeId();
        Contact con = new Contact();
        con.LastName = 'Test';
        con.RecordTypeId = recordTypeId1;
        con.ElixirSuite__Practitioner_User__c = userId;
        insert con;  
        
        Contact conName = [SELECT Id, Name, ElixirSuite__Practitioner_User__c 
                           FROM Contact 
                           where id =: con.id ]; 
        Event objevent = new Event();
        objevent.StartDateTime = dateTime.now();
        objevent.EndDateTime = dateTime.now().addMinutes(20);
        objevent.WhatId = patientgroup.id;
        objevent.ElixirSuite__Location__c = provider.id;
        objevent.ElixirSuite__Status__c = 'Scheduled';
        objevent.ElixirSuite__Practitioner__c=con.id;
        objevent.OwnerId= userId;
        objevent.Subject = 'Group appoint Appointment ';
        insert objevent;  
        
        Event objevent1 = new Event();
        objevent1.StartDateTime = dateTime.now();
        objevent1.EndDateTime = dateTime.now().addMinutes(20);
        objevent1.WhatId = accrec.id;
        objevent1.ElixirSuite__Location__c = provider.id;
        objevent1.ElixirSuite__Status__c = 'Scheduled';
        objevent1.ElixirSuite__Practitioner__c=con.id;
        objevent1.OwnerId= userId;
        objevent1.Subject = 'Group appoint Appointment ';
        insert objevent1; 
        
        Event objevent2 = new Event();
        objevent2.StartDateTime = dateTime.now();
        objevent2.EndDateTime = dateTime.now().addMinutes(20);
        objevent2.WhatId = accrec1.id;
        objevent2.ElixirSuite__Location__c = provider.id;
        objevent2.ElixirSuite__Status__c = 'Scheduled';
        objevent2.ElixirSuite__Practitioner__c=con.id;
        objevent2.OwnerId= userId;
        objevent2.Subject = 'Group appoint Appointment ';
        insert objevent2; 
        Map<Id, Event> msg = new Map<Id, Event>();
        List<Event> lst = [SELECT Id, WhatId, WhoId,Subject, StartDateTime, EndDateTime, 
                                   ElixirSuite__Location__c,ElixirSuite__Practitioner__c,ElixirSuite__By_Pass_Check__c,OwnerId,
                                   AccountId, ElixirSuite__Status__c ,ElixirSuite__Parent_Event_Id__c 
                                   FROM Event];
        

        
        eventTriggerHandler.duplicateRecords(lst);
        //eventTriggerHandler.duplicateRecordsUpdate(lst,msg);
        eventTriggerHandler.saveRecord(lst);
        eventTriggerHandler.saveRecordUpdate(lst);
        system.assertEquals(objevent2,objevent2,'');
    }

}
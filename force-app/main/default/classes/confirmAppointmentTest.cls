@isTest
public class confirmAppointmentTest {
    @isTest
    public static void appointmentTest(){
        ElixirSuite__Provider__c provider = new  ElixirSuite__Provider__c();  
        Id devRecordTypeId = Schema.SObjectType.ElixirSuite__Provider__c.getRecordTypeInfosByDeveloperName().get('Template_Provider').getRecordTypeId();
        provider.RecordTypeId = devRecordTypeId;
        provider.Name = 'TestProvider';
        provider.Provider_Code__c  = 'Test123';
        provider.ElixirSuite__Address__c = 'abc';
        provider.ElixirSuite__Provider_State__c = 'CA';
        provider.ElixirSuite__Provider_City__c = 'CA';
        provider.ElixirSuite__Provider_Zip__c = '12232';
        insert provider;
        
        Account accrec= new Account();
        accrec.Name = 'Test';
        accrec.Phone = '900091111';
        accrec.ElixirSuite__Email_Id__c = 'a@g.com';
        insert accrec;
        Account accr = new Account();
        accr.Name = 'Test';
        accr.Phone = '900091111';
        accr.ElixirSuite__Email_Id__c = 'a@g.com';
        insert accr;
        String userId = UserInfo.getUserId();
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        Elixir_Custom_Setting__c pracRectype = new Elixir_Custom_Setting__c();
        pracRectype.ElixirSuite__Practitioner_Contact_Recordtype__c = 'Practitioner';
        pracRectype.Elixir_portal_url__c=baseUrl;
        insert pracRectype;
        String contactRecType = pracRectype.ElixirSuite__Practitioner_Contact_Recordtype__c;    
        Id recordTypeId1 = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(contactRecType).getRecordTypeId();
        Contact con = new Contact();
        con.LastName = 'Test';
        con.AccountId = accr.Id;
        con.RecordTypeId =recordTypeId1;
        con.ElixirSuite__Practitioner_User__c = userId;
        insert con;  
        
        Contact conName = [SELECT Id, Name, ElixirSuite__Practitioner_User__c 
                           FROM Contact 
                           where id =: con.id ]; 
        Event objevent = new Event();
        objevent.StartDateTime = dateTime.now();
        objevent.EndDateTime = dateTime.now().addMinutes(15);
        objevent.WhatId = accrec.id;
        objevent.ElixirSuite__Location__c = provider.id;
        objevent.ElixirSuite__Status__c = 'Scheduled';
        objevent.ElixirSuite__Practitioner__c=con.id;
        objevent.ElixirSuite__Appointment_Type__c = 'Test';
        objevent.OwnerId= conName.Practitioner_User__c;
        objevent.Subject = 'Upcoming Appointment with Test';
        insert objevent;  
        Id objectRecordTypeIdLoc = Schema.SObjectType.ElixirSuite__Location__c.getRecordTypeInfosByDeveloperName().get('Building').getRecordTypeId();
        ElixirSuite__Location__c build = new ElixirSuite__Location__c();
        build.Name = 'Superior Building';
        build.RecordTypeId = objectRecordTypeIdLoc;
        insert build;
        Id objectRecordTypeId = Schema.SObjectType.ElixirSuite__Location__c.getRecordTypeInfosByDeveloperName().get('Room').getRecordTypeId();
        ElixirSuite__Location__c room = new ElixirSuite__Location__c();
        room.Name = 'Superior Room';
        room.ElixirSuite__Room_Category__c = 'Business Room';
        room.RecordTypeId = objectRecordTypeId;
        room.ElixirSuite__Room__c = build.Id;
        insert room;
        
        
      
        dateTime startDateTime= dateTime.now().addMinutes(30);
        dateTime endDateTime= dateTime.now().addMinutes(45);
        ElixirSuite__Work_Schedule__c ec = new ElixirSuite__Work_Schedule__c();
        ec.ElixirSuite__Start_Date__c = Date.today();
        ec.ElixirSuite__Start_Time__c = DateTime.now().time();
        ec.ElixirSuite__Practitioner_Name__c = con.id;
        ec.ElixirSuite__Provider_Location__c = provider.id;
        insert ec;

        String disclaimersJSON = '{"keysToSave":[]}';
        confirmAppointment.InitWrapper initWrp = confirmAppointment.wrapperRec(accrec.id,provider.id,con.id); 
        confirmAppointment.saveMethod(startDateTime,endDateTime,accrec.id,provider.id, con.id,'new','Consultation',room.Id,false, true,'Link','test@gmail.com','additional',disclaimersJSON);
        // confirmAppointment.getNextAvailableSlot(provider.id, con.id,room.Id);
        System.AssertEquals(provider.Id,initWrp.providerRecord.Id,'');
    }
}
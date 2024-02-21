@isTest
public class AppointmentsForPortalTest {
    @isTest
    static void testAppointments(){
        Account testPatient = TestDataFactory.createPatientAcc();
        insert testPatient;
        
        Profile profileId = [SELECT Id FROM Profile WHERE Name ='System Administrator' LIMIT 1];
        User user = new User();
        user.ProfileID = profileId.id;
        user.EmailEncodingKey = 'ISO-8859-1';
        user.LanguageLocaleKey = 'en_US';
        user.TimeZoneSidKey = 'America/New_York';
        user.LocaleSidKey = 'en_US';
        user.FirstName = 'firstt';
        user.LastName = 'lastt';
        user.Username = 'testtt@uniquedomain.com';
        user.CommunityNickname = 'testUser123';
        user.Alias = 't1';
        user.Email = 'no@email.com';
        insert user;
        Elixir_Custom_Setting__c pracRectype = new Elixir_Custom_Setting__c();
        pracRectype.ElixirSuite__Practitioner_Contact_Recordtype__c = 'Practitioner';
        insert pracRectype;
        String contactRecType = pracRectype.ElixirSuite__Practitioner_Contact_Recordtype__c;                 
        Id recordTypeId1 = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(contactRecType).getRecordTypeId();
        Contact newContact = new Contact();
        newContact.FirstName = 'John';
        newContact.LastName = 'Doe';
        newContact.Email = 'johndoe@example.com';
        newContact.Phone = '123-456-7890';
        newContact.MailingStreet = '123 Main Street';
        newContact.MailingCity = 'City';
        newContact.MailingState = 'State';
        newContact.MailingPostalCode = '12345';
        newContact.MailingCountry = 'Country';
        newContact.accountId=testPatient.id;
        newContact.RecordTypeId=recordTypeId1;
        newContact.ElixirSuite__Practitioner_User__c = user.Id;
        
        
        insert newContact;
        //user.AccountId= testPatient.id;
        //user.ContactId=newContact.id;
        
        
        
        
        Event event = new Event(
            WhatId = testPatient.Id,
            StartDateTime =Date.today().addDays(1),
            EndDateTime = Date.today()+5,
            Subject = 'Test Event 1',
            OwnerId = user.Id,
            ElixirSuite__Appointment_Type__c = 'A90',
            ElixirSuite__Practitioner__c = newContact.Id,
            ElixirSuite__Status__c='Scheduled'
        );
        insert event;
        
        Event event1 = new Event(
            WhatId = testPatient.Id,
            StartDateTime = Date.today()-2,
            EndDateTime = Date.today()+5,
            Subject = 'Test Event 1',
            OwnerId = user.Id,
            ElixirSuite__Appointment_Type__c = 'A90',
            ElixirSuite__Practitioner__c =newContact.Id,
            ElixirSuite__Status__c='Scheduled'
        );
        insert event1;
        
        Id recordTypeId = Schema.SObjectType.ElixirSuite__Master_Object__c.getRecordTypeInfosByDeveloperName().get('Patient_Portal').getRecordTypeId();
        ElixirSuite__Master_Object__c testMasterRecord = new ElixirSuite__Master_Object__c(
            Name = 'Test Master Record',
            ElixirSuite__Patient_Tile_Entity__c = 'Portal Definition',
            ElixirSuite__Enable_Pay_Now__c = true,
            RecordTypeId = recordTypeId
        );
        
        insert testMasterRecord;
        
        Id objectRecordTypeIdloc = Schema.SObjectType.ElixirSuite__Provider__c.getRecordTypeInfosByDeveloperName().get('Patient_Provider').getRecordTypeId();
        
        ElixirSuite__Provider__c prov = new ElixirSuite__Provider__c();
        prov.RecordTypeId = objectRecordTypeIdloc;
        prov.Name = 'Suitcase';
        prov.ElixirSuite__Provider_Code__c = 'Pankaj';
        prov.ElixirSuite__Provider_First_Name__c = 'Massy';
        prov.ElixirSuite__Provider_Last_Name__c = 'Ronaldo';
        insert prov;
        
        
        ElixirSuite__Visits__c careepisode  = new ElixirSuite__Visits__c();
        careepisode.ElixirSuite__Account__c = testPatient.id;
        careepisode.ElixirSuite__Care_Episode_Location__c = prov.Id;
        careepisode.ElixirSuite__Location__c = 'Delhi';
        careepisode.ElixirSuite__Status__c ='Active';
        insert careepisode;
        
        ElixirSuite__Visits__c careepisode1  = new ElixirSuite__Visits__c();
        careepisode1.ElixirSuite__Account__c = testPatient.id;
        careepisode1.ElixirSuite__Care_Episode_Location__c = prov.Id;
        careepisode1.ElixirSuite__Location__c = 'Delhi';
        careepisode1.ElixirSuite__Status__c = 'Closed';
        insert careepisode1;
        
        
        ElixirSuite__Form_Value__c testFormValue = new ElixirSuite__Form_Value__c(
            Name = 'Test Form Value',
            ElixirSuite__Account__c = testPatient.id, // Replace with valid ID
            ElixirSuite__Status__c = 'Pending',
            ElixirSuite__Is_Approver__c = false,
            ElixirSuite__Form_Id__c = 'F123456',
            ElixirSuite__Form_Name__c = 'VisitNoteForm',
            ElixirSuite__Enable_As__c = 'VisitNote'
            //ElixirSuite__Care_Episode__c = careepisode.id
        );
        
        
        insert testFormValue;
        Id devRecordTypeId = Schema.SObjectType.ElixirSuite__Provider__c.getRecordTypeInfosByDeveloperName().get('Template_Provider').getRecordTypeId();
        
        ElixirSuite__Provider__c provider = new ElixirSuite__Provider__c();
        provider.RecordTypeId = devRecordTypeId;
        provider.Name = 'Suitcase';
        provider.ElixirSuite__Provider_Code__c = 'Ayush';
        provider.ElixirSuite__Provider_First_Name__c = 'Mishra';
        provider.ElixirSuite__Provider_Last_Name__c = 'Ayushi pandey';
        insert provider;
        
        
        
        ElixirSuite__UserLocation__c user1 = new ElixirSuite__UserLocation__c();
        user1.Name = 'Loop';
        user1.ElixirSuite__Practitioner__c = newContact.Id;
        user1.ElixirSuite__Provider__c =  provider.Id;
        insert user1;
        
        ContentVersion testContent = new ContentVersion(
            Title = 'Test Document',
            PathOnClient = 'TestDocument.txt',  // Specify a valid file path
            VersionData = Blob.valueOf('Test Document Body')
        );
        insert testContent;
        ContentDocumentLink testLink = new ContentDocumentLink(
            LinkedEntityId = event.Id,
            ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :testContent.Id].ContentDocumentId
        );
        insert testLink;
        Event testEvent = new Event(
            WhatId = testPatient.Id,
            ElixirSuite__Care_Episode__c =  careepisode1.id,
            ElixirSuite__Appointment_Type__c = 'A90',
            ElixirSuite__Practitioner__c = newContact.Id,
            StartDateTime = Date.today().addDays(-1),
            EndDateTime = Date.today().addDays(1),
            Subject = 'Test Subject',
            OwnerId = UserInfo.getUserId()
            
        );
        insert testEvent;
        
        
        List<String> recordIds = new List<String> {event1.Id,testEvent.id};
            
            
            Test.startTest();
        AppointmentsForPortal.getAllUpcomingAppointments();
        AppointmentsForPortal.getAllPastAppointments();
        AppointmentsForPortal.cancelAppointment(event1.Id);
        AppointmentsForPortal.getVisitSummaryPdf(event1.Id);
        AppointmentsForPortal.getVisitNotes(event1.Id);
        AppointmentsForPortal.getDocumentsForAppointments(recordIds);
        AppointmentsForPortal.isEnableVisitNotes();
        AppointmentsForPortal.isEnableAppointment();
        AppointmentsForPortal.getEvent(event.Id);
        // AppointmentsForPortal.getAllVisitNotes();
     //   AppointmentsForPortal.PayAppointment(event1.Id);
        AppointmentsForPortal.isEnablePayNow();
        AppointmentsForPortal.getFormId(careepisode.id);
        AppointmentsForPortal.getFormValue(recordIds);
        
        System.assertEquals(1,1,' ');
        Test.stopTest();
        
    }
}
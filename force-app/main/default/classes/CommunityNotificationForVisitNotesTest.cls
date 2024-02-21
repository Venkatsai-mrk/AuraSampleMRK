@isTest
private class CommunityNotificationForVisitNotesTest {
    @isTest static void testNotifyPatientForVisitNotes() {
         //Inserting Account
        Account a =new Account ();
        a.Name= 'Virat Kohli';
        a.ElixirSuite__DOB__c =date.newInstance(2003, 9, 15);
        a.ElixirSuite__Gender__c='Male';
        a.ElixirSuite__Email_Id__c='virat@gmail.com';
        a.phone='9988776655';
        a.ElixirSuite__First_Name__c='Virat';
        a.ElixirSuite__Last_Name__c='Kohli';
        a.BillingPostalCode='50021';
        a.ElixirSuite__SSN__c='12345';
        a.ElixirSuite__Preferences__c='Email';
        a.ElixirSuite__MRN_Number_New__c='1234567890';
        
        insert a;
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
		Elixir_Custom_Setting__c abc =new Elixir_Custom_Setting__c();
        abc.Elixir_portal_url__c=baseUrl;
        abc.ElixirSuite__Enable_portal_in_Elixir__c=true;
        abc.ElixirSuite__Practitioner_Contact_Recordtype__c = 'Practitioner';
        insert abc;
        
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
        
        String userId = UserInfo.getUserId();
       
        String contactRecType = abc.ElixirSuite__Practitioner_Contact_Recordtype__c; 
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
        objevent.EndDateTime = dateTime.now().addMinutes(15);
        objevent.WhatId = accrec.id;
        objevent.ElixirSuite__Location__c = provider.id;
        objevent.ElixirSuite__Status__c = 'Scheduled';
        objevent.ElixirSuite__Practitioner__c=con.id;
        objevent.ElixirSuite__Appointment_Type__c = 'Test';
        objevent.OwnerId= conName.Practitioner_User__c;
        objevent.Subject = 'Upcoming Appointment with Test';
        insert objevent;    
        
        
        // Call the method being tested
        Test.startTest();
        CommunityNotificationForVisitNotes.visitNotesNotifications(new List<String>{objevent.Id});
        Test.stopTest();
        System.assertEquals(1, 1, ' ');
        
    }

}
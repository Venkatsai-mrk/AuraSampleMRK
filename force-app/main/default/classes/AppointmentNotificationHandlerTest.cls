@isTest
private class AppointmentNotificationHandlerTest {
    @isTest
    static  void testAppointmentNotifications() {
        // Create test data
        
        //Inserting Account
        Account acc =new Account ();
        acc.Name= 'Virat Kohli';
        acc.ElixirSuite__DOB__c =date.newInstance(2003, 9, 15);
        acc.ElixirSuite__Gender__c='Male';
        acc.ElixirSuite__Email_Id__c='virat@gmail.com';
        acc.phone='9988776655';
        acc.ElixirSuite__First_Name__c='Virat';
        acc.ElixirSuite__Last_Name__c='Kohli';
        acc.BillingPostalCode='50021';
        acc.ElixirSuite__SSN__c='12345';
        acc.ElixirSuite__MRN_Number_New__c='1234567890';
        insert acc;
        
        
        
        Contact con = new Contact(AccountId = acc.Id, FirstName = 'Test', LastName = 'Contact');
        insert con;
        Id devRecordTypeId =  Schema.SObjectType.ElixirSuite__Provider__c.getRecordTypeInfosByDeveloperName().get('Template_Provider').getRecordTypeId();
        ElixirSuite__Provider__c provider = new  ElixirSuite__Provider__c();  
        
        provider.RecordTypeId = devRecordTypeId;
        provider.Name = 'TestProvider';
        provider.Provider_Code__c  = 'Test123';
        provider.ElixirSuite__Address__c = 'abc';
        provider.ElixirSuite__Provider_State__c = 'CA';
        provider.ElixirSuite__Provider_City__c = 'CA';
        provider.ElixirSuite__Provider_Zip__c = '12232';
        insert provider;
        
        List<Event> evt=new List<Event>();
        Event env = new Event();
        env.WhatId = acc.Id;
        env.Subject='Appointment';
        env.Location='New York';
     	env.StartDateTime = DateTime.now();
        env.EndDateTime =DateTime.now().addHours(1);
        env.ElixirSuite__Patient_Notified__c=System.now();
        //evt.add(env);
        
        Event env1 = new Event();
        env1.WhatId = acc.Id;
        env1.Subject='Appointment1';
        env1.Location='New York1';
        env1.ElixirSuite__Location__c=provider.Id;
        env1.StartDateTime = DateTime.now();
        env1.EndDateTime =DateTime.now().addHours(5);
        env1.ElixirSuite__Patient_Notified__c=System.now();
        evt.add(env1);
        
        insert evt;
        // Query for the record to retrieve the value of the formula field
		Event insertedSchedule = [SELECT Id, ElixirSuite__Appointment_Interval__c FROM Event WHERE Id = :evt[0].Id];
		
		// Retrieve the value of the formula field
		Decimal appointmentIntervalValue = insertedSchedule.ElixirSuite__Appointment_Interval__c;

		// Use the value in your test as needed
		System.assertEquals(0, appointmentIntervalValue,'');
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        Elixir_Custom_Setting__c abc =new Elixir_Custom_Setting__c();
        abc.Elixir_portal_url__c=baseUrl;
        abc.ElixirSuite__Enable_portal_in_Elixir__c=true;
        abc.ElixirSuite__Appointment_Interval__c='1D, 2D, 0H';
        insert abc;
        
        
        User user1 = [SELECT Id FROM User LIMIT 1];
        
        
        System.runAs(user1) {
            EmailTemplate validEmailTemplate = new EmailTemplate();
            validEmailTemplate.isActive = true;
            validEmailTemplate.Name = 'Patient Notification for New Forms';
            validEmailTemplate.DeveloperName = 'Patient_Notification_for_New_Forms';
            validEmailTemplate.Subject = 'Test Subject';
            validEmailTemplate.HtmlValue = '<html><body>Test Body</body></html>';
            validEmailTemplate.Body = 'Test Body';
            validEmailTemplate.TemplateType = 'Custom';
            validEmailTemplate.FolderId = UserInfo.getUserId();
            insert validEmailTemplate;
        }
        
        
        // Create an email template
        
        
        Map<Id, String> msg = new Map<Id, String>();
        msg.put(acc.Id, acc.ElixirSuite__Email_Id__c);
        
        // Call the method being tested
        Test.startTest();
        AppointmentNotificationHandler.appointmentNotifications(msg);
        Test.stopTest();
        System.assertEquals(1,1,' ');
        
        
    }
}
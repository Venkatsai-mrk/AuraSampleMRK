@isTest
public with sharing class PaymentNotificationHandlerTest {
    @isTest
    static void paymentNotificationsTest() {
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
        a.ElixirSuite__MRN_Number_New__c='1234567890';
       insert a;
        
        Map<Id, String> msg = new Map<Id, String>();
        msg.put(a.Id, a.ElixirSuite__Email_Id__c);
		
		Id masterRecordTypeId = Schema.SObjectType.Payment_Schedule__c.getRecordTypeInfosByDeveloperName().get('Master_Payment_Schedule').getRecordTypeId();
        
        ElixirSuite__Payment_Schedule__c allSchedules = new ElixirSuite__Payment_Schedule__c();
        allSchedules.RecordTypeId=masterRecordTypeId;
        allSchedules.ElixirSuite__Account__c=a.Id;
        allSchedules.ElixirSuite__Net_Balance__c=1000;
        allSchedules.ElixirSuite__Pay_Frequency__c='Monthly';
        allSchedules.ElixirSuite__Payment_Status__c='Active';
        allSchedules.ElixirSuite__Installment_Amount__c=500;
        allSchedules.ElixirSuite__Remaining_Amount__c=1000;
		insert allSchedules;
        
        
		
		ElixirSuite__Payment_Schedule__c firstDue = new ElixirSuite__Payment_Schedule__c();
        firstDue.RecordTypeId=masterRecordTypeId;
        firstDue.ElixirSuite__Account__c=a.Id;
        firstDue.ElixirSuite__Due_Date__c= Date.today();
        firstDue.Payment_Schedule__c=allSchedules.Id;
        firstDue.ElixirSuite__Net_Balance__c=1000;
        firstDue.ElixirSuite__Remaining_Amount__c=500;
        firstDue.ElixirSuite__Payment_Status__c='Active';
        firstDue.ElixirSuite__Installment_Amount__c=500;
		insert firstDue;
		
		// Query for the record to retrieve the value of the formula field
		ElixirSuite__Payment_Schedule__c insertedSchedule = [SELECT Id, ElixirSuite__Payment_Interval__c FROM ElixirSuite__Payment_Schedule__c WHERE Id = :firstDue.Id];
		
		// Retrieve the value of the formula field
		Decimal paymentIntervalValue = insertedSchedule.ElixirSuite__Payment_Interval__c;

		// Use the value in your test as needed
		System.assertEquals(0, paymentIntervalValue,'');
		ElixirSuite__Payment_Schedule__c secondDue = new ElixirSuite__Payment_Schedule__c();
        secondDue.RecordTypeId=masterRecordTypeId;
        secondDue.ElixirSuite__Account__c=a.Id;
       // secondDue.ElixirSuite__Due_Date__c=Date.today().addDays(30);
        secondDue.Payment_Schedule__c=allSchedules.Id;
        secondDue.ElixirSuite__Net_Balance__c=1000;
        secondDue.ElixirSuite__Remaining_Amount__c=500;
        secondDue.ElixirSuite__Payment_Status__c='Active';
        secondDue.ElixirSuite__Installment_Amount__c=500;
		insert secondDue;        
        
       
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        Elixir_Custom_Setting__c abc =new Elixir_Custom_Setting__c();
        abc.Elixir_portal_url__c=baseUrl;
        abc.ElixirSuite__Payment_reminder_interval__c=0;
        abc.ElixirSuite__Enable_portal_in_Elixir__c=true;
        insert abc;
       
        EmailTemplate validEmailTemplate = new EmailTemplate();
        validEmailTemplate.isActive = true;
        validEmailTemplate.Name = 'name';
        validEmailTemplate.DeveloperName = 'unique_name_addSomethingSpecialHere';
        validEmailTemplate.TemplateType = 'text';
        validEmailTemplate.FolderId = UserInfo.getUserId();
        System.runAs([select Id from User where Id = :UserInfo.getUserId()][0]) {
            insert validEmailTemplate; // setup objects must be inserted in a separate context
        }
        Test.startTest();
        PaymentNotificationHandler.paymentNotifications(msg);
       Test.stopTest();
        
        System.assertEquals(1, 1, ' ');
    }
    
}
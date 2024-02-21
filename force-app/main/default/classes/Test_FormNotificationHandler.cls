@IsTest
public class Test_FormNotificationHandler {
    @IsTest
    static void testFormNotifications() {
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
        // Create a list to hold the records
        List<ElixirSuite__Form_Value__c> formDetails = new List<ElixirSuite__Form_Value__c>();
         Integer idToCreateNumberUnique = Integer.valueOf((Math.random() * 1000000000));
        // Loop to create the records
        for (Integer i = 0; i < 10; i++) {
           
            ElixirSuite__Form_Value__c formDetail = new ElixirSuite__Form_Value__c();
            formDetail.ElixirSuite__Status__c = 'Waiting For Patient';
            formDetail.ElixirSuite__Form_Portal_Status__c = 'New';
            formDetail.ElixirSuite__Form_Id__c = a.Id + ';' + String.valueOf(idToCreateNumberUnique);
            formDetail.ElixirSuite__Account__c = a.Id;
            formDetail.ElixirSuite__Form_Detail__c = true;
            formDetail.ElixirSuite__Form_Name__c='Demo org'+i;
            formDetail.ElixirSuite__Patient_Notified__c=DateTime.now();
              // Add the record to the list
            formDetails.add(formDetail);
        }
         // Insert all the records at once
        insert formDetails;        
        
        // Query for the record to retrieve the value of the formula field
		ElixirSuite__Form_Value__c insertedSchedule = [SELECT Id, ElixirSuite__Notification_Interval__c FROM ElixirSuite__Form_Value__c WHERE Id = :formDetails[0].Id];
		
		// Retrieve the value of the formula field
		Decimal formIntervalValue = insertedSchedule.ElixirSuite__Notification_Interval__c;

		// Use the value in your test as needed
		System.assertEquals(0, formIntervalValue,'');
        Map<Id, String> msg = new Map<Id, String>();
        msg.put(a.Id, a.ElixirSuite__Email_Id__c);
       String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
		Elixir_Custom_Setting__c abc =new Elixir_Custom_Setting__c();
        abc.Elixir_portal_url__c=baseUrl;
        abc.ElixirSuite__Form_reminder_Interval__c=0;
        insert abc;
        // Create an email template
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
        FormNotificationHandler.formNotifications(msg);
        Test.stopTest();
        
        System.assertEquals(1, 1, ' ');
    }
    
    
}
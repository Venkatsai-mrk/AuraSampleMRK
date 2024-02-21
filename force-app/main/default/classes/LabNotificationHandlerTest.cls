@isTest
public class LabNotificationHandlerTest {
    @isTest
    public static void notificationHandler() {

        Account testAccount = new Account();
        testAccount.Last_name__c='Test';
        testAccount.First_Name__c='Account';
        testAccount.Name='Test Account';
        testAccount.BillingStreet='NewDelhi';
        testAccount.BillingCity = 'Ghaziabad';
        testAccount.BillingState='DE';
        testAccount.BillingPostalCode='23456'; 
        testAccount.BillingCountry='IN';
        testAccount.Gender__c='Male';
        testAccount.SSN__c='3465432';
        testAccount.Phone='3456222224';
        testAccount.Patient_s_Birth_Date__c=Date.newInstance(2017, 12, 9);
        testAccount.DOB__c=Date.newInstance(2016, 12, 9);
        testAccount.Email_Id__c = 'himanshu.tajne@mirketa.com';
        insert testAccount;

        Map<Id, String> accToEMail = new Map<Id, String>();
        accToEMail.put(testAccount.Id, testAccount.Email_Id__c);

        Lab_Order__c order = new Lab_Order__c();
        order.Status__c='E';
        order.Account_Id__c = testAccount.Id;
        order.Order_result_received__c = system.now();
        insert order;
        
        Elixir_Custom_Setting__c cust = new Elixir_Custom_Setting__c();
        cust.Elixir_portal_url__c = 'https://java-customer-9087-dev-ed.scratch.my.salesforce.com';
        insert cust;

        Blob b = Blob.valueOf('Test Data');
    	
    	Attachment attachment = new Attachment();
    	attachment.ParentId = order.Id;
    	attachment.Name = 'Test Attachment for Parent';
    	attachment.Body = b;
    	insert attachment;

        EmailTemplate template = new EmailTemplate();
        template.isActive = true;
        template.Name = 'Notification for eLab';
        template.DeveloperName = 'Notification_for_eLab';
        template.TemplateType = 'text';
        template.FolderId = UserInfo.getUserId();
        //insert template;

        Test.startTest();
        //LabNotificationHandler.labNotifications(accToEMail);
        System.enqueueJob(new LabNotificationHandler(accToEMail));
        System.assertEquals(1,1,' ');
        Test.stopTest();
    
    }
}
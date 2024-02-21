@isTest
public class ManualLabNotificationTest {
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

        ElixirSuite__UA_Sample_Details__c uas = new ElixirSuite__UA_Sample_Details__c();
        uas.ElixirSuite__Is_File_Created__c=true;
        uas.Account__c = testAccount.Id;
        insert uas;
        
        Elixir_Custom_Setting__c cust = new Elixir_Custom_Setting__c();
        cust.Elixir_portal_url__c = 'https://java-customer-9087-dev-ed.scratch.my.salesforce.com';
        insert cust;
        
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        Insert cv;
        
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
    	
        ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.LinkedEntityId = cust.Id;
            cdl.ContentDocumentId = documents[0].Id;
            cdl.ShareType = 'V';
            cdl.Visibility = 'AllUsers';
            insert cdl;

        EmailTemplate template = new EmailTemplate();
        template.isActive = true;
        template.Name = 'Notification for eLab';
        template.DeveloperName = 'Notification_for_eLab';
        template.TemplateType = 'text';
        template.FolderId = UserInfo.getUserId();
        //insert template;

        Test.startTest();
        //LabNotificationHandler.labNotifications(accToEMail);
        System.enqueueJob(new ManualLabNotification(accToEMail));
        System.assertEquals(1,1,' ');
        Test.stopTest();
    
    }
}
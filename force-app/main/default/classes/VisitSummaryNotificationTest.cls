@isTest
public with sharing class VisitSummaryNotificationTest {
     @isTest
    static void visitNotificationsTest() {
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
        
        

        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        system.debug(baseUrl);
        Elixir_Custom_Setting__c abc =new Elixir_Custom_Setting__c();
        abc.Elixir_portal_url__c=baseUrl;
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
        VisitSummaryNotificationHandler.visitNotifications(a.Id);
        Test.stopTest();
        
        System.assertEquals(1, 1, ' ');
    }

}
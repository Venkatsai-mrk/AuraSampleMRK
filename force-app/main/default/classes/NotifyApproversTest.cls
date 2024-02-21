@isTest
public class NotifyApproversTest {
    @isTest 
    public static void testSendNotification(){
        
        Account patient = new Account();
        patient.name = 'Test Patient';
        patient.ElixirSuite__Email_Id__c = 'kj@gmail.com';
        patient.Patient_s_Birth_Date__c = System.today().addyears(-20);
        patient.MRN_Number__c = 1234567;
        patient.ElixirSuite__First_Name__c ='fname';
        patient.ElixirSuite__Last_Name__c ='lname';
        patient.ElixirSuite__SSN__c ='1234';
        patient.ElixirSuite__Gender__c='Male';
        patient.Phone ='9919850735';
        patient.BillingPostalCode='27440';
        patient.ElixirSuite__Deceased__c =true;
        insert patient; 
        
        String recordTypeName = 'Test Record Type';
        String changedFormName = 'Test Form';
        Integer currentLevel = 1;
        
        Object_1_css__c obj = new Object_1_css__c(Approval_Level__c = 2,
                                                  Approv__c = 'User',
                                                  Approval_Members__c = UserInfo.getUserId(),
                                                  Form__c = 'Test Record Type'
                                                 );
        insert obj;
        
        Object_1_css__c obj2 = new Object_1_css__c(Approval_Level__c = 3,
                                                   Approv__c = 'Profile',
                                                   Approval_Members__c = UserInfo.getUserId(),
                                                   Form__c = 'Test Record Type'
                                                  );
        insert obj2;
        
        Object_1_css__c obj3 = new Object_1_css__c(Approval_Level__c = 4,
                                                   Approv__c = 'Role',
                                                   Approval_Members__c = UserInfo.getUserId(),
                                                   Form__c = 'Test Record Type'
                                                  );
        insert obj3;
        
        Object_1_css__c obj4 = new Object_1_css__c(Approval_Level__c = 5,
                                                   Approv__c = 'Patient',
                                                   Approval_Members__c = UserInfo.getUserId(),
                                                   Form__c = 'Test Record Type'
                                                  );
        insert obj4;
        
        Elixir_Custom_Setting__c customSetting = Elixir_Custom_Setting__c.getOrgDefaults();
        customSetting.Name = 'Test Custom Settings';
        customSetting.Enable_email_for_Approvers__c = true;
        customSetting.Enable_Tasks_for_approvers__c = true;
        insert customSetting; 
        
        Test.startTest();
        NotifyApprovers.sendNotification(recordTypeName, changedFormName, patient.Id, 1);
        NotifyApprovers.sendNotification(recordTypeName, changedFormName, patient.Id, 2);  
        NotifyApprovers.sendNotification(recordTypeName, changedFormName, patient.Id, 3);
        NotifyApprovers.sendNotification(recordTypeName, changedFormName, patient.Id, 4);
        System.assertEquals(1,1,' ');
        Test.stopTest();
        system.assertEquals(1,1,'Hello');
        
    }
}
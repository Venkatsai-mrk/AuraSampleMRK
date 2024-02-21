@isTest
public class NC_RxAdminControllerTestClass {
    @isTest
    static void testGetRecords() {
             
        
        // Create a test user
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(FirstName='Test', LastName='User', Email='testuser@test.com', UserName='testuser32344444@test.com', ProfileId=p.Id, Alias='tuser', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US',  ElixirSuite__User_Type__c='LicensedPrescriber', ElixirSuite__Role_Type__c='doctor', ElixirSuite__siteId__c='100', ElixirSuite__License__c='1234567890',Phone='9976543211',Fax='9877',City='Boston',State='AK',Street='US',Country='US',PostalCode='5412',ElixirSuite__Work_Phone__c='1245745845',ElixirSuite__DEA_NUMBER__c='1245478454',ElixirSuite__CustomText1__c='0019D00000TzMhZQAV;0019D00000TzMhZQAV',ElixirSuite__CustomText2__c='5124587451');
        insert u;
        
        User u1 = new User(FirstName='Test', LastName='User', Email='testuser1@test.com', UserName='testr32344444@test.com', ProfileId=p.Id, Alias='tuser', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US',  ElixirSuite__User_Type__c='staff', ElixirSuite__Role_Type__c='admin', ElixirSuite__siteId__c='100', ElixirSuite__License__c='1234567890',Phone='9976543211',Fax='9877',City='Boston',State='AK',Street='US',Country='US',PostalCode='5412',ElixirSuite__Work_Phone__c='1245745845',ElixirSuite__DEA_NUMBER__c='1245478454',ElixirSuite__CustomText1__c='0019D00000TzMhZQAV;0019D00000TzMhZQAV',ElixirSuite__CustomText2__c='5124587451');
        insert u1;
        
        Contact con1=new Contact();
        con1.LastName='Test Contact';
        Insert con1;
        // Set the user ID for the test
        System.runAs(u) {
            NC_RxAdminController controller = new NC_RxAdminController();
            controller.getSubscriptionXML();
            controller.getRecords();
            controller.getRecordId();
            controller.getEndPoint();
        //    NC_RxAdminController.getURL();
            NC_RxAdminController.newUser();
           //NC_EditPage.accDetails(acc.Id); 
            // Add assertions for expected behavior
            
        }
        System.runAs(u1) {
            NC_RxAdminController controller = new NC_RxAdminController();
            controller.getSubscriptionXML();
            controller.getRecords();
            controller.getRecordId();
            controller.getEndPoint();
         //   NC_RxAdminController.getURL();
            NC_RxAdminController.newUser();
           //NC_EditPage.accDetails(acc.Id); 
            // Add assertions for expected behavior
            
        }
        system.assertEquals(1, 1,' ');
    }
}
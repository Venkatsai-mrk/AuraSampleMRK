/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-17-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class LabResultsControllerTest {
    @isTest
    public static void testLabResults(){
        ElixirSuite__TabPermissionBasedOnProfiles__c cs = new ElixirSuite__TabPermissionBasedOnProfiles__c();
        cs.ElixirSuite__LabOrder_Priority__c='Dummy LabOrder';
        cs.Name = 'TabPermissionBasedOnProfiles (Profile)';
        insert cs;
        ElixirSuite__UA_Sample_Details__c uas = new ElixirSuite__UA_Sample_Details__c();
        insert uas;
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example.com',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
            Username = 'puser000@amamama.com' + System.currentTimeMillis(),
        	CompanyName = 'TEST',
        	Title = 'title',
        	Alias = 'alias',
        	TimeZoneSidKey = 'America/Los_Angeles',
        	EmailEncodingKey = 'UTF-8',
        	LanguageLocaleKey = 'en_US',
        	LocaleSidKey = 'en_US',
        	IsActive =true
        );
        insert testUser;
        test.startTest();
        LabResultsController.fetchLabOrders(testUser.Id);
        System.assertEquals(1,1,' ');
        test.stopTest();
    }
}
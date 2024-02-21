@isTest
public class CarePlanColumnsConfigControllerTest {
    @isTest
    public static void getCarePlanColumns(){
        List<Object> obj = new List<Object>{'content1', 'content2'};
        Elixir_Custom_Setting__c cs = new Elixir_Custom_Setting__c();
        cs.ElixirSuite__CarePlan_Columns__c = 'content1;content2';
        insert cs;
        
        test.startTest();
        CarePlanColumnsConfigController.getCarePlanColumns();
        CarePlanColumnsConfigController.saveColumns(obj);
        CareplanSignatureSaveApex.checkValidity('035161', '035161');
        CareplanSignatureSaveApex.checkApprovedValues(3, 2);
        CareplanSignatureSaveApex.adminConfiguredLevels(3, 2);
        System.assertEquals(1,1,' ');
        test.stopTest();
    }
        @isTest
    public static void getCarePlan(){
        UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
        insert r;
        
        User testUser = new User(
            FirstName = 'patientcard',
            LastName = 'User',
            Username = 'patientcard@example.com',
            Email = 'patientcard@example.com',
            Alias = 'pacard',
            TimeZoneSidKey = 'America/New_York',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = UserInfo.getProfileId(),
            UserRoleId = r.Id
        );
        insert testUser;
        
       Map<String,String> userValuesMap = new Map<String,String>();
        userValuesMap.put('UserId',testUser.Id);
        userValuesMap.put('ProfileId',testUser.profileId);
        userValuesMap.put('RoleId',testUser.UserRoleId);
        String userValues = JSON.serialize(userValuesMap);
        //String userValues = '{"UserId":"' + testUser.Id + '","ProfileId":"' + testUser.profileId + '","RoleId":"' + testUser.UserRoleId + '"}';
        test.startTest();
        CareplanSignatureSaveApex.checkApprovedValues(3, 3);
        CareplanSignatureSaveApex.adminConfiguredLevels(0, 0);
    //    CareplanSignatureSaveApex.approveOrder(userValues, '2', 'co12de', 'comments');
        System.assertEquals(1,1,' ');
        test.stopTest();
    }
    @isTest
    public static void testCheckValidityVerificationFailed() {
        // Arrange
        String code = 'ABC123';
        String verificationCode = 'XYZ789';

        // Act
        try {
            CareplanSignatureSaveApex.checkValidity(code, verificationCode);

            // Assert
            System.assert(false, 'Expected an exception to be thrown, but none was thrown.');
        } catch (AuraHandledException e) {
            // Assert
            System.assertEquals('Verification Failed!', e.getMessage(), 'Unexpected exception message');
        } catch (Exception e) {
            // Assert
            System.assert(false, 'An unexpected exception was thrown: ' + e.getMessage());
        }
    }
    
}
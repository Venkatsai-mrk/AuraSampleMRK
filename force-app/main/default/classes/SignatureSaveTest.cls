@isTest
public with sharing class SignatureSaveTest {
    @TestSetup
    public static void testData() {
        Id currentUser = UserInfo.getUserId();
        User users = [SELECT Id, Verification_Code_New__c FROM User WHERE Id= :currentUser];
        users.Verification_Code_New__c = '1234';
        users.Email = 'rohit@mirketa.com';
        Profile profiles = [SELECT Id FROM Profile WHERE Name ='System Administrator' LIMIT 1];
        users.ProfileId = profiles.Id;
        UserRole roles = [SELECT Id FROM UserRole WHERE Name ='CEO' LIMIT 1];
        users.UserRoleId = roles.Id;
        update users;
        System.runAs (users) {
            Account newAccount = new Account(Name='Stefan Salvatore', 
                                             Verification_Code__c = '1234',
                                             Email_Id__c = 'rohit@mirketa.com');
            
            insert newAccount;
            Object_1_css__c  level1 = new Object_1_css__c
                (Approval_Level__c = 1,
                 Form__c = 'ABC',
                 Approv__c = 'User',
                 Approval_Members__c = currentUser);
            insert level1;
            Object_1_css__c  level2 = new Object_1_css__c
                (Approval_Level__c = 2,
                 Form__c = 'ABC',
                 Approv__c = 'Patient',
                 Approval_Members__c = newAccount.Id);
            insert level2;
            Object_1_css__c  level3 = new Object_1_css__c
                (Approval_Level__c = 3,
                 Form__c = 'ABC',
                 Approv__c = 'Profile',
                 Approval_Members__c = users.ProfileId);
            insert level3;
            Object_1_css__c  level4 = new Object_1_css__c
                (Approval_Level__c = 4,
                 Form__c = 'ABC',
                 Approv__c = 'Role',
                 Approval_Members__c = users.UserRoleId);
            insert level4;
            Object_1_css__c  level5 = new Object_1_css__c
                (Approval_Level__c = 5,
                 Form__c = 'ABC',
                 Approv__c = 'User',
                 Approval_Members__c = currentUser);
            insert level5;
            
            Form_Value__c approvedValue = new Form_Value__c
                (Is_Approver__c = true,
                 Approval_Level__c = '1',
                 User__c = currentUser,
                 Form_Id__c = '##');
            insert approvedValue;
        }
    }
    @isTest
    public static void approveLevel2(){
        Test.startTest();
        Id currentUser = UserInfo.getUserId();
        Id profileId = UserInfo.getProfileId();
        Id roleId = UserInfo.getUserRoleId();
        List<Account> accounts = [SELECT Id FROM Account];
        String patientId = accounts[0].Id;
        String formName = 'ABC';
        String changedFormName = 'ABC';
        String formId = '##';
        SignatureSave.UserValues userDetails = new SignatureSave.UserValues();
        userDetails.userId = currentUser;
        userDetails.patientId = patientId;
        userDetails.profileId = profileId;
        userDetails.roleId = roleId;
        List<Object_1_css__c> currentLevels = [SELECT Id, Approval_Level__c, Approv__c, Approval_Members__c
                                               FROM Object_1_css__c
                                               WHERE Form__c= :formName AND Approval_Level__c!=NULL
                                               AND Approval_Level__c=2];
        Object_1_css__c currentLevel = currentLevels[0];
        SignatureSave.approveForm(formName, changedFormName, formId, JSON.serialize(userDetails)
                                  , JSON.serialize(currentLevel), '1234', 'xxx');
        List<Form_Value__c> approvedLevels =         
            [SELECT Id, Is_Approver__c, Approval_Level__c FROM Form_Value__c
             WHERE Is_Approver__c=true AND Form_Id__c= :formId AND Approval_Level__c= '2'];
        system.assertEquals(true, approvedLevels[0].Is_Approver__c);    
        Test.stopTest();
    }
    @isTest
    public static void approveLevel3(){
        Test.startTest();
        Id currentUser = UserInfo.getUserId();
        Id profileId = UserInfo.getProfileId();
        Id roleId = UserInfo.getUserRoleId();
        User users = [SELECT Id, Verification_Code_New__c FROM User WHERE Id= :currentUser];
        List<Account> accounts = [SELECT Id FROM Account];
        String patientId = accounts[0].Id;
        String formName = 'ABC';
        String changedFormName = 'ABC';
        String formId = '##';
        SignatureSave.UserValues userDetails = new SignatureSave.UserValues();
        userDetails.userId = currentUser;
        userDetails.patientId = patientId;
        userDetails.profileId = profileId;
        userDetails.roleId = roleId;
        System.runAs (users) {
            Form_Value__c approvedValue = new Form_Value__c
                (Is_Approver__c = true,
                 Approval_Level__c = '2',
                 Signed_Patient__c = patientId,
                 Form_Id__c = '##');
            insert approvedValue;
        }
        List<Object_1_css__c> currentLevels = [SELECT Id, Approval_Level__c, Approv__c, Approval_Members__c
                                               FROM Object_1_css__c
                                               WHERE Form__c= :formName AND Approval_Level__c!=NULL
                                               AND Approval_Level__c=3];
        Object_1_css__c currentLevel = currentLevels[0];
        SignatureSave.approveForm(formName, changedFormName, formId, JSON.serialize(userDetails)
                                  , JSON.serialize(currentLevel), '1234', 'xxx');
        List<Form_Value__c> approvedLevels =         
            [SELECT Id, Is_Approver__c, Approval_Level__c FROM Form_Value__c
             WHERE Is_Approver__c=true AND Form_Id__c= :formId AND Approval_Level__c= '3'];
        system.assertEquals(true, approvedLevels[0].Is_Approver__c);    
        Test.stopTest();
    }
    
    @isTest
    public static void approveLevel4(){
        Test.startTest();
        Id currentUser = UserInfo.getUserId();
        Id profileId = UserInfo.getProfileId();
        Id roleId = UserInfo.getUserRoleId();
        User users = [SELECT Id, Verification_Code_New__c FROM User WHERE Id= :currentUser];
        List<Account> accounts = [SELECT Id FROM Account];
        String patientId = accounts[0].Id;
        String formName = 'ABC';
        String changedFormName = 'ABC';
        String formId = '##';
        SignatureSave.UserValues userDetails = new SignatureSave.UserValues();
        userDetails.userId = currentUser;
        userDetails.patientId = patientId;
        userDetails.profileId = profileId;
        userDetails.roleId = roleId;
        List<Object_1_css__c> currentLevels = [SELECT Id, Approval_Level__c, Approv__c, Approval_Members__c
                                               FROM Object_1_css__c
                                               WHERE Form__c= :formName AND Approval_Level__c!=NULL
                                               AND Approval_Level__c=4];
        Object_1_css__c currentLevel = currentLevels[0];
        System.runAs(Users){
            Form_Value__c approvedValue = new Form_Value__c
                (Is_Approver__c = true,
                 Approval_Level__c = '2',
                 Signed_Patient__c = patientId,
                 Form_Id__c = '##');
            insert approvedValue;
            Form_Value__c approvedLevel3 = new Form_Value__c
                (Is_Approver__c = true,
                 Approval_Level__c = '3',
                 Signed_Patient__c = patientId,
                 Form_Id__c = '##');
            insert approvedLevel3;
                }
                    SignatureSave.approveForm(formName, changedFormName, formId, JSON.serialize(userDetails)
                                              , JSON.serialize(currentLevel), '1234', 'xxx');
        List<Form_Value__c> approvedLevels =         
            [SELECT Id, Approval_Level__c, Is_Approver__c FROM Form_Value__c
             WHERE Is_Approver__c=true AND Form_Id__c= :formId AND Approval_Level__c= '4'];
        system.assertEquals(true, approvedLevels[0].Is_Approver__c);      
        Test.stopTest();
    }
    @isTest
    public static void approveLevel5(){
        Test.startTest();
        Id currentUser = UserInfo.getUserId();
        Id profileId = UserInfo.getProfileId();
        Id roleId = UserInfo.getUserRoleId();
        User users = [SELECT Id, Verification_Code_New__c FROM User WHERE Id= :currentUser];
        List<Account> accounts = [SELECT Id FROM Account];
        String patientId = accounts[0].Id;
        String formName = 'ABC';
        String changedFormName = 'ABC';
        String formId = '##';
        SignatureSave.UserValues userDetails = new SignatureSave.UserValues();
        userDetails.userId = currentUser;
        userDetails.patientId = patientId;
        userDetails.profileId = profileId;
        userDetails.roleId = roleId;
        List<Object_1_css__c> currentLevels = [SELECT Id, Approval_Level__c, Approv__c, Approval_Members__c
                                               FROM Object_1_css__c
                                               WHERE Form__c= :formName AND Approval_Level__c!=NULL
                                               AND Approval_Level__c=5];
        Object_1_css__c currentLevel = currentLevels[0];
        System.runAs(users){
            Form_Value__c approvedValueLevel2 = new Form_Value__c
                (Is_Approver__c = true,
                 Approval_Level__c = '2',
                 Signed_Patient__c = patientId,
                 Form_Id__c = '##');
            insert approvedValueLevel2;
            Form_Value__c approvedValueLevel3 = new Form_Value__c
                (Is_Approver__c = true,
                 Approval_Level__c = '3',
                 User__c = currentUser,
                 Form_Id__c = '##');
            insert approvedValueLevel3;
            Form_Value__c approvedValueLevel4 = new Form_Value__c
                (Is_Approver__c = true,
                 Approval_Level__c = '4',
                 User__c = currentUser,
                 Form_Id__c = '##');
            insert approvedValueLevel4;
        }
        SignatureSave.approveForm(formName, changedFormName, formId, JSON.serialize(userDetails)
                                  , JSON.serialize(currentLevel), '1234', 'xxx');
        List<Form_Value__c> approvedLevels =         
            [SELECT Id, Approval_Level__c, Is_Approver__c FROM Form_Value__c
             WHERE Is_Approver__c=true AND Form_Id__c= :formId AND Approval_Level__c= '5'];
        system.assertEquals(true, approvedLevels[0].Is_Approver__c);    
        Test.stopTest();
    }
    
}
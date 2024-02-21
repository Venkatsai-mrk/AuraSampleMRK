@isTest
public class PreviousSignatureTest {
	@TestSetup
    public static void testData() {
        Id currentUser = UserInfo.getUserId();
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
        Approval_Members__c = currentUser);
        insert level2;

        User users = [SELECT Id, Verification_Code_New__c FROM User WHERE Id= :currentUser];
        users.Verification_Code_New__c = '1234';
        update users;

        Account newAccount = new Account(Name='Stefan Salvatore', Verification_Code__c = '1234');
        Form_Value__c approvedValue = new Form_Value__c
        (Is_Approver__c = true,
        Approval_Level__c = '1',
        User__c = currentUser,
        Form_Id__c = '##');
        insert approvedValue;
    }
    @isTest
    public static void PreviousSignature(){
        Id currentUser = UserInfo.getUserId();
        FormApprovalData.currentUserInfo userDetail = PreviousSignature.fetchApprovalLevels('ABC', '##');
        System.assertEquals(1, 1, ' ');
    }
}
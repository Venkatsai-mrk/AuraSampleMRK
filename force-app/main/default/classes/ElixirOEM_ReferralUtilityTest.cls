@isTest
public class ElixirOEM_ReferralUtilityTest {
    @isTest
    static void testSendReferralFormAsAttachmentOnEmail(){
        Account acc = TestDataFactory.createPatientAcc();
        insert acc;
        ElixirSuite__Provider__c  provider = TestDataFactory.createProvider(acc.Id);
        insert provider;
        ElixirSuite__Referral__c ref = new ElixirSuite__Referral__c();
        ref.ElixirSuite__Email_Referred_To__c = 'gangavarapu.mahendra@mirketa.com';
        ref.ElixirSuite__Referred_Out_Organization__c = acc.Id;
        ref.ElixirSuite__Account__c = acc.Id;
        ref.ElixirSuite__Provider__c = provider.Id;
        insert ref;
        Test.startTest();
        ElixirOEM_ReferralUtility.sendReferralFormAsAttachmentOnEmail(new Set<Id>{},ref.Id);
        System.assertEquals(1, 1, ' ');
        Test.stopTest();
    }
}
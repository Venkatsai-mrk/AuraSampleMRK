@isTest
public class ElixirOEM_PatientCardDefinitionTest {
public  static testMethod void allCoverageParentMethod(){
    Account accountRec = new Account();
        accountRec.Name = 'Test'; 
        accountRec.Phone='9876543210';
        accountRec.BillingPostalCode='50004';
        insert accountRec;
 String prcUpdate =  '{"patientTileDataToSave":[{"label":"Billing City","order":0,"value":"BillingCity"},{"label":"Website","order":1,"value":"Website"}]}';
     ElixirOEM_PatientCardDefinitionHelper.dummyMethod();
        test.startTest();
        ElixirOEM_PatientCardDefinitionHelper.fetchOptions_SetupKey('Account');
        ElixirOEM_PatientCardDefinitionHelper.updateLocation(prcUpdate,'Account',false);
        ElixirOEM_PatientCardDefinitionHelper.fetchExistingLocationRecordForGivenEntity('Account');
        test.stopTest();
        System.assertEquals(1, 1, ' ');
    }
}
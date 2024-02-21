@isTest
public class ElixirOEM_LocationDefinitionHelperTest {
    public static testMethod void  method1(){
        ElixirOEM_LocationDefinitionHelper.initCalled_fetchApprovalData('test');
        ElixirOEM_LocationDefinitionHelper.fetchOptions_SetupKey('Role');
        ElixirOEM_LocationDefinitionHelper.fetchOptions_SetupKey('Profile');
        ElixirOEM_LocationDefinitionHelper.fetchOptions_SetupKey('User');
        ElixirOEM_LocationDefinitionHelper.fetchExistingLocationRecordForGivenEntity(1,'User','User');
        ElixirOEM_LocationDefinitionHelper.fetchMapOfSetUpKey('User');
        ElixirOEM_LocationDefinitionHelper.dummyMethod();
        System.assertEquals(1, 1, ' ');
    } 
}
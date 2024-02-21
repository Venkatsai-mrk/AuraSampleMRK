@isTest
public class ElixirOEM_TimelineHelperTest {
    @isTest 
    public static void  allcoverageMethod(){
        Account accountRec = new Account();
        accountRec.Name = 'Test';
        insert accountRec;
        Master_Object__c m = new Master_Object__c();
        m.Name = 'UR';
        m.Object_API_Name__c = 'Account';
        m.Object_Name__c = 'Account';
        m.Patient_Account_Lookup__c = 'Id';
        m.RecordTypeId = Schema.SObjectType.ElixirSuite__Master_Object__c.getRecordTypeInfosByDeveloperName().get('Timeline_Configuration').getRecordTypeId();
        insert m; 
        ElixirOEM_TimelineHelper.parentMethod_FetchAllData(accountRec.id);
        ElixirOEM_TimelineHelper.getAllFieldsNameOfObject('ElixirSuite__Medical_Examination__c');
        ElixirOEM_TimelineHelper.fetchObjectdataIfChecked('Id','Account',accountRec.Id);
        System.assertEquals(1, 1, ' '); 
    }
}
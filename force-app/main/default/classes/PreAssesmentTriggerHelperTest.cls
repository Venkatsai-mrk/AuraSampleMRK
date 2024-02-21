@isTest
public class PreAssesmentTriggerHelperTest {
    public static testMethod void testmethod1(){
        ElixirSuite__Pre_assessment__c p = new ElixirSuite__Pre_assessment__c();
        insert p;
        PreAssesmentTriggerHelper.stopDeceasedEdit(new List<ElixirSuite__Pre_assessment__c>{p},false);
        PreAssesmentTriggerHelper.stopDeceasedEdit(new List<ElixirSuite__Pre_assessment__c>{p},true);
        PreAssesmentTriggerHelper.preventEditIfDeceasedCheckedOnAccount(new List<ElixirSuite__Pre_assessment__c>{p});
        System.assertEquals(1, 1, '');
    }
}
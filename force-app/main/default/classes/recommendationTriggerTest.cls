@isTest
public class recommendationTriggerTest {
	@isTest
    public static void updateTaskOwnerTest(){
        ElixirSuite__Recommendation__c recommendation = new ElixirSuite__Recommendation__c();
        recommendation.RecordTypeId= Schema.SobjectType.ElixirSuite__Recommendation__c.getRecordTypeInfosByDeveloperName().get('ElixirSuite_Supplemental_Remark_Codes').getRecordTypeId();
        recommendation.ElixirSuite__Elixir_Recommendation__c='Test';
        insert recommendation;
        Task t = new Task();
        t.subject='test';
        t.whatid=recommendation.id;
        insert t;
        recommendation.ElixirSuite__Elixir_Assign_To__c=UserInfo.getUserId();
        update recommendation;
        id recommendationOwnerId = [select ElixirSuite__Elixir_Assign_To__c from ElixirSuite__Recommendation__c][0].ElixirSuite__Elixir_Assign_To__c;
        id taskOwnerId = [select OwnerId from task][0].OwnerId;
		System.assertEquals(recommendationOwnerId, taskOwnerId,'');       
    }
}
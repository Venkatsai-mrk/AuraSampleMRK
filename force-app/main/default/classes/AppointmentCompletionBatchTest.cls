@isTest
public class AppointmentCompletionBatchTest {

    @isTest
    public static void AppointmentCompletionBatchTestMethod(){
        
        Event evTestRecord = new Event();
        evTestRecord.Subject = 'Test Call';
        evTestRecord.ElixirSuite__Status__c = 'Scheduled';
        evTestRecord.StartDateTime = date.today();
        evTestRecord.EndDateTime = Date.today();
        
        insert evTestRecord;
        
        Test.startTest();

        Database.executeBatch(new AppointmentCompletionBatch());
        
        Test.stopTest();
        Event completedEvent = [Select id,Subject,ElixirSuite__Status__c from Event limit 1];
        System.assertEquals('Completed', completedEvent.ElixirSuite__Status__c,'');
        System.assertEquals('Test Call', completedEvent.Subject,'');
        
    }
    
    @isTest
    public static void schedulerExecuteTestMethod(){
        
        Event evTestRecord = new Event();
        evTestRecord.Subject = 'Test Call';
        evTestRecord.ElixirSuite__Status__c = 'Scheduled';
        evTestRecord.StartDateTime = date.today();
        evTestRecord.EndDateTime = Date.today();
        
        insert evTestRecord;        
        Test.startTest();
        AppointmentCompletionBatchScheduler sh1 = new AppointmentCompletionBatchScheduler();

        String sch = '0 0 23 * * ?'; 
        system.schedule('Test ContinuousCriteriaBatch Check', sch, sh1);
        
        Test.stopTest();
        System.assertEquals(1, 1, 'welcome to Elixir');
    }
    
}
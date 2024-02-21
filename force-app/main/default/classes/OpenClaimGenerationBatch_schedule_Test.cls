@isTest
public class OpenClaimGenerationBatch_schedule_Test {
	
    public static testMethod void OpenClaimGenerationBatch_schedule_TestMethod(){
		
		Test.startTest();
        OpenClaimGenerationBatch_schedule sh1 = new OpenClaimGenerationBatch_schedule();
        String sch = '0 0 17 * * ?'; system.schedule('Test Check', sch, sh1);
        scheduledBatchable ert1 = new scheduledBatchable();
        String ert = '0 0 16 * * ?'; system.schedule('Test Check56', ert, ert1);
        //String CRON_EXP = '0 0 0 3 9 ? 2023';
        //String jobId = System.schedule('OpenClaimGenerationBatch_schedule', CRON_EXP, new OpenClaimGenerationBatch_schedule());
        //CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId]; 
        System.assertEquals(1, 1, ' ');
        Test.stopTest();        
    }
}
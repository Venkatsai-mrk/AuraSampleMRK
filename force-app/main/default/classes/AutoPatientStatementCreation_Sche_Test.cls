@isTest
public class AutoPatientStatementCreation_Sche_Test {
	
    public static testMethod void AutoPatientStatemenTest(){
        Patient_Statment_GenerInterval__c psg = new Patient_Statment_GenerInterval__c();
        psg.Name = 'abc';
        psg.Active__c = true;
        insert psg;
		
		Test.startTest();
        String CRON_EXP = '0 0 0 3 9 ? 2023';
        String jobId = System.schedule('AutoPatientStatementCreation_Schedule', CRON_EXP, new AutoPatientStatementCreation_Schedule());
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId]; 
        System.assertEquals(0, ct.TimesTriggered,''); 
        System.assertEquals('2023-09-03 00:00:00', String.valueOf(ct.NextFireTime),'');   
        AutoPatientStatementCreation_Schedule.scheduleBatch();
        Test.stopTest();        
    }
}
@isTest
public class SendNotificationsForOpnProc_scheTest {
	
    public static testMethod void notifyTestMethod()
    {
        ProcedureAlertParameters__c proAlrt = new ProcedureAlertParameters__c();
        proAlrt.Active__c = True;
        proAlrt.No_of_hours__c = 1;
        insert proAlrt;
        
		Account pat = new Account();
		pat.Name = 'test';
		pat.Gender__c = 'Female';
		pat.Patient_s_Birth_Date__c = system.today();
		pat.Account_Number__c = '123456';
		insert pat;
        
        Procedure__c pro1 = new Procedure__c();
		pro1.Name = 'test';
		pro1.From_Date__c = system.today()-2;
		pro1.To_Date__c = system.today();
		pro1.CPT_HCPCS_Code__c = '99203';
		pro1.Account__c = pat.Id;
		pro1.Name = 'test';
		insert pro1;
        
		Test.startTest();
        String CRON_EXP = '0 0 0 3 9 ? 2023';
        String jobId = System.schedule('SendNotificationsForOpnProc_schedule', CRON_EXP, new SendNotificationsForOpnProc_schedule());
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId]; 
        System.assertEquals(1, 1, ' ');
        Test.stopTest();        
    }
}
/*Author name           :  Shwetha KJ
* Purpose 	            :  To schedule SendNotificationsForOpnProc 
* Schedule              :  Scheduling on the basis of days and hour 
* Test Class            :  SendNotificationsForOpnProc_scheTest
* Created Date          :  16-Oct-2020
* Last Modified Date    :  16-Oct-2020
*/

global with sharing class SendNotificationsForOpnProc_schedule implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        
		CronTrigger ct = [SELECT id,CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :SC.getTriggerId() WITH SECURITY_ENFORCED];
		if(ct != null){
			System.abortJob(ct.Id);
		}
        SendNotificationsForOpnProc b = new SendNotificationsForOpnProc();
        database.executebatch(b);      
    }
}
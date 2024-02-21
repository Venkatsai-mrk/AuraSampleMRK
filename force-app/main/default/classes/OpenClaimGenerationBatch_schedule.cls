/*Author name           :  Abhishek Singh
* Purpose 	            :  To schedule OpenClaimGenerationBatch 
* Schedule              :  Scheduling on the basis of days and hour 
* Test Class            :  OpenClaimGenerationBatch_schedule_Test
* Created Date          :  15-Oct-2020
* Last Modified Date    :  15-Oct-2020
*/

global  with sharing class OpenClaimGenerationBatch_schedule implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        
		//CronTrigger ct = [SELECT id,CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :SC.getTriggerId() WITH SECURITY_ENFORCED];
		//if(ct != null){
		//	System.abortJob(ct.Id);
		//}
        //OpenClaimGenerationBatch b = new OpenClaimGenerationBatch();
        //database.executebatch(b);      
    }
}
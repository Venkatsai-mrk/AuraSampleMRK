global with sharing class AutoPatientStatementCreation_Schedule implements Schedulable{
    global void execute(SchedulableContext sc) {
        //USELESS PIECE OF CODE
    }
    global static void scheduleBatch(){
        List<CronTrigger> jobs = [SELECT Id
                                  FROM CronTrigger 
                                  WHERE CronJobDetail.Name  LIKE '%AutoPatientStatementCreation%' WITH SECURITY_ENFORCED];
        if(jobs!=null && jobs.size()>0){
            for(CronTrigger job :jobs){
                System.abortJob(job.Id);
            }
        }
        String schdays;
        String schhours;
        List<Patient_Statment_GenerInterval__c> patlist = [SELECT Id, No_of_Days__c, No_of_Hours__c, Active__c 
                                                           FROM Patient_Statment_GenerInterval__c
                                                           WHERE Active__c = true WITH SECURITY_ENFORCED];
        List<Patient_Statment_GenerInterval__c> intervals = Patient_Statment_GenerInterval__c.getAll().values();
        if(intervals!=null && intervals.size()>0){
            Patient_Statment_GenerInterval__c pro = intervals[0];
            if(pro.No_of_Days__c!= null){
                Integer n = Integer.valueOf(pro.No_of_Days__c);
                schdays = '0 10 ' + '*/' + n + ' * *';//At 10:AM after every 'n' days...
            }
        }
        AutoPatientStatementCreation schd = new AutoPatientStatementCreation();
        if(schdays!= null){
            System.schedule('AutoPatientStatementCreation_Days', schdays, schd);
        }
    }
}
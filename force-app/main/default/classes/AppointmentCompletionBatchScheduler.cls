/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-24-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class AppointmentCompletionBatchScheduler implements Schedulable{

    public void execute(SchedulableContext SC){       
      Database.executeBatch(new AppointmentCompletionBatch(), 10);  
    }
}
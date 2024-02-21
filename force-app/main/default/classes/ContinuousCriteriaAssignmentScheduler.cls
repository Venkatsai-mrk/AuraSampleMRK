public with sharing class ContinuousCriteriaAssignmentScheduler implements Schedulable{

    public void execute(SchedulableContext SC){
       
      Database.executeBatch(new ContinuousCriteriaAssignmentBatch(), 10);  
    }
}
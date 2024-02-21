/*Author name           :  
* Test Class            :  
*/
public with sharing class PayerStatusHandler implements Queueable, Database.AllowsCallouts{
    
    public void execute(QueueableContext context) {
        
        AutoPatientStatementGeneration.autoPdfGen();
    }

}
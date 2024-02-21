public with sharing class NextAvailSlotHandler implements Queueable, Database.AllowsCallouts {
    
    public void execute(QueueableContext context) {
        
        AutoNextAvailSlotGeneration.autoSlots();
    }

}
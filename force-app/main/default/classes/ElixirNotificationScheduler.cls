global with sharing class ElixirNotificationScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        ElixirNotificationBatch b = new ElixirNotificationBatch(); 
       Database.executeBatch(b);
    }
}
public class editEventsTimeZoneQueueable implements Queueable {
    List<Event> events;
    public editEventsTimeZoneQueueable(List<Event> events){
        this.events = events;
    }
    public void execute(QueueableContext context) {
        StopRecursion.eventTimeZone = true;
        Database.update(events,false);       
    }
}
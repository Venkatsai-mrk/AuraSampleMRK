global class Schedulablehl7Clinical implements Schedulable {
global void execute(SchedulableContext sc) {
   System.enqueueJob(new getHL7());
 
}


}
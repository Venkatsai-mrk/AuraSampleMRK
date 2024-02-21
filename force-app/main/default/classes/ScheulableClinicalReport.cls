global class ScheulableClinicalReport implements Schedulable {
    global void execute(SchedulableContext sc) {
   System.enqueueJob(new getClinicalNonDownloaded());
 

}

}
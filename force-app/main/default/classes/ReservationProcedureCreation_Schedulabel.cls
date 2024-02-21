global with sharing class ReservationProcedureCreation_Schedulabel implements Schedulable{

    global void execute(SchedulableContext sc) {
        ReservationProcedureCreation_Batch b = new ReservationProcedureCreation_Batch();
        Database.executeBatch(b, 50);
    }
}
Global with sharing virtual class GlobalReservationTrigger {
    global virtual void beforeUpdate(List<ElixirSuite__Reservation__c> ResRecords, Map<Id,ElixirSuite__Reservation__c> oldResRecords ){
        ReservationTriggerHelper.checkDateTime(ResRecords, oldResRecords);
        ReservationTriggerHelper.updateParent(ResRecords);
        
    }
    global virtual void afterUpdate(List<ElixirSuite__Reservation__c> oldResListRecords, List<ElixirSuite__Reservation__c> newResListRecords){
        ReservationTriggerHelper.updateResLineItemFields(oldResListRecords, newResListRecords);
        ReservationTriggerHelper.updateCancelationProcedure(newResListRecords);
        Map<Id, ElixirSuite__Reservation__c> reservationMap = new Map<Id, ElixirSuite__Reservation__c>(newResListRecords);
        //ReservationDashboardHelper.createResercationDashboard(reservationMap);
    }
}
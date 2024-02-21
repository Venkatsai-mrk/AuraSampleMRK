public with sharing class ReservationTriggerHelper {
    public static void checkDateTime(List<ElixirSuite__Reservation__c> resLst, Map<Id, ElixirSuite__Reservation__c> oldResLst) {
        try {
            for (ElixirSuite__Reservation__c res : resLst) {
                ElixirSuite__Reservation__c oldmap = oldResLst.get(res.Id);
                
                if(res.ElixirSuite__Status__c == 'Active'){
                    Date dateOnlyValue = res.ElixirSuite__Start_Date__c.date();
                    if(Date.today() < dateOnlyValue){
                        res.addError('The status change to "Active" cannot be processed at this moment. This should only happen on the Start Date and not before that.');
                    }
                }
                if (res.ElixirSuite__End_Date__c != oldmap.ElixirSuite__End_Date__c) {
                    if (res.ElixirSuite__Status__c == 'Pending' || res.ElixirSuite__Status__c == 'Confirmed' || res.ElixirSuite__Status__c == 'Active') {
                        if (res.ElixirSuite__End_Date__c <= res.ElixirSuite__Start_Date__c) {
                            res.addError('End Date-Time cannot be less than Start Date-Time');
                        }
                        if (res.ElixirSuite__End_Date__c <= DateTime.now()) {
                            res.addError('End Date-Time cannot be less than Current Date-Time');
                        }
                        if (res.ElixirSuite__End_Date__c >= oldmap.ElixirSuite__End_Date__c) {
                            res.addError('Please create a new reservation to extend the End Date-Time');
                        }
                    }
                    else {
                        res.addError('Changes to End Date are only allowed for reservations with statuses Pending, Confirmed and Active');
                    }
                }
                
                
                if (res.ElixirSuite__Start_Date__c != oldmap.ElixirSuite__Start_Date__c) {
                    if (res.ElixirSuite__Status__c == 'Pending' || res.ElixirSuite__Status__c == 'Confirmed') {
                        if (res.ElixirSuite__Start_Date__c <= oldmap.ElixirSuite__Start_Date__c) {
                            res.addError('Please create a new reservation to extend the Start Date-Time');
                        }
                        if (res.ElixirSuite__Start_Date__c >= res.ElixirSuite__End_Date__c) {
                            res.addError('Start Date-Time cannot be greater  than End Date-Time');
                        }
                    } 
                    else {
                        res.addError('Changes to Start Date are only allowed for reservations with statuses Pending and Confirmed');
                    }
                }
            }
        }
        catch (Exception e) {
            ExceptionLog.logError(e);
        }
    }
    public static void updateResLineItemFields(List<ElixirSuite__Reservation__c> resOld, List<ElixirSuite__Reservation__c> resNew) {
        // List<ElixirSuite__Reservation_Line_Item__c> lineItemsToUpdate = new List<ElixirSuite__Reservation_Line_Item__c>();
        List<ElixirSuite__Reservation_Line_Item__c> newLineItems = new List<ElixirSuite__Reservation_Line_Item__c>();
        List<ElixirSuite__Reservation__c> resItems = new List<ElixirSuite__Reservation__c>();
        List<String> errorMessages = new List<String>();
            resItems=[SELECT Id, Account__c, Status__c,ElixirSuite__Start_Date__c,ElixirSuite__End_Date__c,
                      
                      (SELECT Id, ElixirSuite__Start_Date__c,ElixirSuite__End_Date__c,ElixirSuite__Account__c, ElixirSuite__Bed_Status__c,ElixirSuite__Reservation__c FROM Reservation_Line_Items__r)
                      
                      FROM ElixirSuite__Reservation__c
                      
                      WHERE Id IN : resNew WITH SECURITY_ENFORCED];
            
            
            for (ElixirSuite__Reservation__c res1 : resItems) {
                for (ElixirSuite__Reservation_Line_Item__c lineItem : res1.Reservation_Line_Items__r) {
                    if(lineItem.ElixirSuite__Reservation__c==res1.Id){
                        lineItem.ElixirSuite__Start_Date__c = res1.ElixirSuite__Start_Date__c;
                        lineItem.ElixirSuite__End_Date__c = res1.ElixirSuite__End_Date__c;
                        lineItem.ElixirSuite__Bed_Status__c = res1.ElixirSuite__Status__c;
                        newLineItems.add(lineItem);
                    }
                    
                }
            }
           
            if (!newLineItems.isEmpty()) {
                try {
                    DMLManager.updateAsUser(newLineItems);
                } catch (Exception e) {
                     // Capture the error message
                    errorMessages.add(e.getMessage());
                }
            }
            // Check if there are any error messages and add them to the parent reservation
            if (!errorMessages.isEmpty()) {
                resNew[0].addError(String.join(errorMessages, ', '));
                
            }
      }
    public static void updateParent(List<ElixirSuite__Reservation__c> reservations) {
        Map<Id, Id> reservationToParent = new Map<Id, Id>();
        
        for (ElixirSuite__Reservation__c reservation : reservations) {
            if (reservation.ElixirSuite__Parent_Reservation__c != null) {
                reservationToParent.put(reservation.Id, reservation.ElixirSuite__Parent_Reservation__c);
            }
        }
        
        Map<Id, ElixirSuite__Reservation__c> parentReservations = new Map<Id, ElixirSuite__Reservation__c>([SELECT Id, ElixirSuite__Grand_Parent_Reservation__c FROM ElixirSuite__Reservation__c WHERE Id IN :reservationToParent.values() WITH SECURITY_ENFORCED]);
        for (ElixirSuite__Reservation__c reservation : reservations) {
            if (reservation.Parent_Reservation__c != null) {
                ElixirSuite__Reservation__c parentReservation = parentReservations.get(reservationToParent.get(reservation.Id));
                if (parentReservation != null && parentReservation.ElixirSuite__Grand_Parent_Reservation__c != null) {
                    //reservation.ElixirSuite__Grand_Parent_Reservation__c = parentReservation.Grand_Parent_Reservation__c;
                } else {
                  //  reservation.ElixirSuite__Grand_Parent_Reservation__c = reservationToParent.get(reservation.Id);
                }
            }
        }
    }
    // Added by jami for LX3-11843
    public static void updateCancelationProcedure(List<ElixirSuite__Reservation__c> resNew) {
        Set<Id> resIds = new Set<Id>();
        for (ElixirSuite__Reservation__c rs : resNew) {
            if (rs.ElixirSuite__Status__c == 'Canceled') {
                resIds.add(rs.Id);
            }
        }
        
        List<ElixirSuite__Procedure__c> proListToUpdate = new List<ElixirSuite__Procedure__c>();
        Map<Id, List<ElixirSuite__Procedure__c>> ReservationToProceduresMap = new Map<Id, List<ElixirSuite__Procedure__c>>();
        Id objectRecordTypeId = Schema.SObjectType.ElixirSuite__Procedure__c.getRecordTypeInfosByDeveloperName().get('Patient_Procedure').getRecordTypeId();
        List<ElixirSuite__Procedure__c> proList = [SELECT Id, Name, ElixirSuite__Status__c, ElixirSuite__Reservation_Line_Item__c,ElixirSuite__Reservation_Line_Item__r.ElixirSuite__Reservation__c
                                                   FROM ElixirSuite__Procedure__c
                                                   WHERE ElixirSuite__Reservation_Line_Item__c != null AND ElixirSuite__Reservation_Line_Item__r.ElixirSuite__Reservation__c IN:resIds 
                                                   AND RecordTypeId =:objectRecordTypeId WITH SECURITY_ENFORCED];
        if (proList != null && proList.size() > 0) {
            for (ElixirSuite__Procedure__c pr : proList) {
                if (pr.ElixirSuite__Reservation_Line_Item__c != null && !ReservationToProceduresMap.containsKey(pr.ElixirSuite__Reservation_Line_Item__c)) {
                    ReservationToProceduresMap.put(pr.ElixirSuite__Reservation_Line_Item__c, new List<ElixirSuite__Procedure__c>());
                }
                ReservationToProceduresMap.get(pr.ElixirSuite__Reservation_Line_Item__c).add(pr);
            }
        }
        List<ElixirSuite__Reservation_Line_Item__c> resLineItems = [SELECT Id, ElixirSuite__Start_Date__c, ElixirSuite__End_Date__c, ElixirSuite__Account__c, ElixirSuite__Bed_Status__c,
                                                                    ElixirSuite__Reservation__c, ElixirSuite__Reservation__r.ElixirSuite__Status__c
                                                                    FROM ElixirSuite__Reservation_Line_Item__c
                                                                    WHERE ElixirSuite__Reservation__c IN :resIds AND ElixirSuite__isBillable__c = 'True' WITH SECURITY_ENFORCED];
        
        if (resLineItems != null && resLineItems.size() > 0) {
            for (ElixirSuite__Reservation_Line_Item__c resLn : resLineItems) {
                if (resLn.ElixirSuite__Reservation__r.ElixirSuite__Status__c == 'Canceled' && ReservationToProceduresMap.containsKey(resLn.Id)) {
                    List<ElixirSuite__Procedure__c> procedures = ReservationToProceduresMap.get(resLn.Id);
                    for (ElixirSuite__Procedure__c prd : procedures) {
                        prd.ElixirSuite__Status__c = 'Canceled';
                        proListToUpdate.add(prd);
                    }
                }
            }
        }
        
        if (proListToUpdate != null && proListToUpdate.size() > 0) {
            DMLManager.updateAsUser(proListToUpdate);
        }
    }
}
public with sharing class BedAssignmentHelper {
    
    public static void updatePatientOnDashboard(List<ElixirSuite__Reservation_Line_Item__c> lineItemLst, Map<Id, ElixirSuite__Reservation_Line_Item__c> lineItemOldMap){
        Set<Id> lineItemIds = new Set<Id>();
        for(ElixirSuite__Reservation_Line_Item__c lineItem : lineItemLst){
            lineItemIds.add(lineItem.Id);
        }
        Map<Id, List<ElixirSuite__Reservation_Dashboard__c>> lineItemIdToDashboard = new Map<Id, List<ElixirSuite__Reservation_Dashboard__c>>();
        List<ElixirSuite__Reservation_Dashboard__c> dashboardsToUpdate = new List<ElixirSuite__Reservation_Dashboard__c>();
        List<ElixirSuite__Reservation_Dashboard__c> relatedDashboards = [SELECT Id, ElixirSuite__Patient__c, ElixirSuite__Reservation_Line_Item__c
                                                                         FROM ElixirSuite__Reservation_Dashboard__c
                                                                         WHERE ElixirSuite__Reservation_Line_Item__c IN:lineItemIds
                                                                         WITH SECURITY_ENFORCED];
        
        for(ElixirSuite__Reservation_Dashboard__c dash : relatedDashboards){
            if(lineItemIdToDashboard.containsKey(dash.ElixirSuite__Reservation_Line_Item__c)){
                lineItemIdToDashboard.get(dash.ElixirSuite__Reservation_Line_Item__c).add(dash);
            }
            else{
                lineItemIdToDashboard.put(dash.ElixirSuite__Reservation_Line_Item__c, new List<ElixirSuite__Reservation_Dashboard__c>{dash});
            }            
        }
        
        for(ElixirSuite__Reservation_Line_Item__c lineItem : lineItemLst){
            ElixirSuite__Reservation_Line_Item__c oldRecord = lineItemOldMap.get(lineItem.Id);
            if(oldRecord.ElixirSuite__Account__c != lineItem.ElixirSuite__Account__c){
                List<ElixirSuite__Reservation_Dashboard__c> dashboard = lineItemIdToDashboard.get(lineItem.Id);
                if(dashboard!=null && dashboard.size()>0){
                for(ElixirSuite__Reservation_Dashboard__c d : dashboard){
                    d.ElixirSuite__Patient__c = lineItem.ElixirSuite__Account__c;
                    dashboardsToUpdate.add(d);
                }
                }
            }
        }
        DMLManager.updateAsUser(dashboardsToUpdate);
    }
    
    public static void bedAssignment(List<ElixirSuite__Reservation_Line_Item__c> resLineItems,Map<Id,ElixirSuite__Reservation_Line_Item__c> oldResLineItems) {  
        
        DateTime startDate =null;
		DateTime endDate= null;
        Set<Id> reservationIds = new Set<Id>();
        Set<Id> patientIds = new Set<Id>();
        //Set<Id> activeLineItemsForPatients = new Set<Id>();
        Map<Id, ElixirSuite__Reservation__c> reservationMap;
        
        try{
            for(ElixirSuite__Reservation_Line_Item__c resLine:resLineItems){
                reservationIds.add(resLine.ElixirSuite__Reservation__c);
                patientIds.add(resLine.ElixirSuite__Account__c);
                // Assuming ElixirSuite__Start_Date__c and ElixirSuite__End_Date__c are DateTime fields
            startDate = resLine.ElixirSuite__Start_Date__c;
           endDate = resLine.ElixirSuite__End_Date__c;

            }
            // Query parent reservations and populate the reservation map
            List<ElixirSuite__Reservation__c> reservations = [SELECT Id, 
                                                             ElixirSuite__Status__c 
                                                             FROM ElixirSuite__Reservation__c 
                                                             WHERE Id IN :reservationIds
                                                             WITH SECURITY_ENFORCED];
            reservationMap = (Map<Id,ElixirSuite__Reservation__c>) new Map<Id, ElixirSuite__Reservation__c>(reservations);
            for(ElixirSuite__Reservation_Line_Item__c resLine:resLineItems){
                ElixirSuite__Reservation_Line_Item__c oldmap=oldResLineItems.get(resLine.Id);
                ElixirSuite__Reservation__c parentReservation = reservationMap.get(resLine.ElixirSuite__Reservation__c);
                
                if(resLine.ElixirSuite__Bed_Status__c == 'Active'){
                      Date dateOnlyValue = resLine.ElixirSuite__Start_Date__c.date();
                    if(Date.today() < dateOnlyValue){
                        resLine.addError('The status change to "Active" cannot be processed at this moment. This should only happen on the Start Date and not before that.');
                    }
                    if (parentReservation.ElixirSuite__Status__c != 'Active' ) {
                        resLine.addError('The parent reservation must have a status of "Active" in order to change the status to "Active" for related reservation line item.');
                    }
                }
                if( oldmap.ElixirSuite__Bed__c !=resLine.ElixirSuite__Bed__c){
                    resLine.addError('Please create a new reservation to select a different bed.');
                }//not allowing bed to change at any cost
                
                if(resLine.ElixirSuite__End_Date__c != oldmap.ElixirSuite__End_Date__c ){
                    if(resLine.ElixirSuite__Bed_Status__c == 'Pending' 
                       || resLine.ElixirSuite__Bed_Status__c == 'Confirmed' 
                       || resLine.ElixirSuite__Bed_Status__c == 'Active'){
                           
                           performEndDateValidation(resLine, oldmap);
                       }
                    else {
                        resLine.addError('Changes to End Date are only allowed for reservation line items with statuses Pending, Confirmed, and Active.');
                    }
                }
               	 if(resLine.ElixirSuite__Start_Date__c != oldmap.ElixirSuite__Start_Date__c ){
                        if(resLine.ElixirSuite__Bed_Status__c == 'Pending' || resLine.ElixirSuite__Bed_Status__c == 'Confirmed'){
                         performStartDateValidation(resLine, oldmap);
                        }
                        else {
                        resLine.addError('Changes to Start Date are only allowed for reservation line items with statuses Pending and Confirmed.');
                        }
                    }
                   
               
            }
            // Perform the SOQL query to retrieve the relevant Reservation Line Items
            List<ElixirSuite__Reservation_Line_Item__c> resLineItemsLst = [SELECT Id, ElixirSuite__Account__c, ElixirSuite__Bed_Status__c
                                                                            FROM ElixirSuite__Reservation_Line_Item__c
                                                                            WHERE ElixirSuite__Account__c IN :patientIds
                                                                            AND ElixirSuite__Account__c!= NULL
                                                                            AND Id NOT IN :resLineItems   
                                                                            AND (ElixirSuite__Bed_Status__c = 'Active' OR
                                                                            ElixirSuite__Bed_Status__c ='Pending' OR
                                                                            ElixirSuite__Bed_Status__c = 'Confirmed')
                                                                            AND (NOT((ElixirSuite__Start_Date__c > :startDate AND 
                                                                                      ElixirSuite__Start_Date__c >= :endDate) 
                        																 OR (ElixirSuite__End_Date__c <= :startDate AND 
                                                                                         	ElixirSuite__End_Date__c < :endDate)))
                                                                            WITH SECURITY_ENFORCED];
            Map<Id,String> accountIdsWithReservations = new Map<Id,String>();
            for (ElixirSuite__Reservation_Line_Item__c lineItem : resLineItemsLst) {
                accountIdsWithReservations.put(lineItem.ElixirSuite__Account__c, lineItem.ElixirSuite__Bed_Status__c);
            }
            for (Reservation_Line_Item__c lineItem : resLineItems) {
                if(accountIdsWithReservations.containsKey(lineItem.ElixirSuite__Account__c)){
                   performBedAssignmentValidation(lineItem, accountIdsWithReservations.get(lineItem.ElixirSuite__Account__c)); 
                }
            }        
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
    }
    private static void performBedAssignmentValidation(Reservation_Line_Item__c lineItem, String bedStatus){
        lineItem.addError(bedStatus +' bed associated with the patient found!. Please choose a different patient or cancel the existing reservation.');
    }
    public static void performEndDateValidation(ElixirSuite__Reservation_Line_Item__c resLineItems, ElixirSuite__Reservation_Line_Item__c oldMapLineItems){
      	if (resLineItems.ElixirSuite__End_Date__c < DateTime.now()) {
            resLineItems.addError('End Date-Time cannot be less than Current Date-Time.');
            }
        if (resLineItems.ElixirSuite__End_Date__c < resLineItems.ElixirSuite__Start_Date__c) {
            resLineItems.addError('End Date-Time cannot be less than Start Date-Time.');
            } 
        if (resLineItems.ElixirSuite__End_Date__c > oldMapLineItems.ElixirSuite__End_Date__c) {
            resLineItems.addError('Please create a new reservation to extend the End Date-Time.');
            }  
    }
    public static void performStartDateValidation(ElixirSuite__Reservation_Line_Item__c resLineItems, ElixirSuite__Reservation_Line_Item__c oldMapLineItems){
      	if (resLineItems.ElixirSuite__Start_Date__c < oldMapLineItems.ElixirSuite__Start_Date__c) {
           resLineItems.addError('Please create a new reservation to extend the Start Date-Time.');
           }
        if (resLineItems.ElixirSuite__Start_Date__c >= resLineItems.ElixirSuite__End_Date__c) {
           resLineItems.addError('Start Date-Time cannot be greater than End Date-Time.');
           }
    }
        public static void updateAccountFields(List<ElixirSuite__Reservation_Line_Item__c> resLineItemsOld, List<ElixirSuite__Reservation_Line_Item__c> resLineItemsNew) {
        Map<Id,ElixirSuite__Reservation_Line_Item__c> accountToLineItems = new Map<Id,ElixirSuite__Reservation_Line_Item__c>();
        Set<Id> accountsToEmpty = new Set<Id>();
        
        // Collect the Account IDs from Reservation Line Items with active and Confirmed  bed status 
        for (ElixirSuite__Reservation_Line_Item__c resLineItem : resLineItemsNew) {
           
            if (resLineItem.ElixirSuite__Bed_Status__c == 'Active' || resLineItem.ElixirSuite__Bed_Status__c == 'Confirmed') {
                accountToLineItems.put(resLineItem.ElixirSuite__Account__c, resLineItem);       
            }
            if(resLineItem.ElixirSuite__Bed_Status__c != 'Active' && resLineItem.ElixirSuite__Bed_Status__c != 'Confirmed'){
                accountsToEmpty.add(resLineItem.ElixirSuite__Account__c);
            }
        }
		
 

        // Retrieve the related Account records
        List<Account> accountsToUpdate = [SELECT Id, ElixirSuite__Reserved_bed__c, ElixirSuite__Reservation__c, Start_Date_Time__c, End_Date_Time__c
                                          FROM Account
                                          WHERE Id IN :accountToLineItems.keySet()
                                          WITH SECURITY_ENFORCED];
        
        List<Account> accountsToRemoveBeds = [SELECT Id, ElixirSuite__Reserved_bed__c, ElixirSuite__Reservation__c, Start_Date_Time__c, End_Date_Time__c
                                          FROM Account
                                          WHERE Id IN :accountsToEmpty
                                          WITH SECURITY_ENFORCED];
        for (Account accountToUpdate : accountsToRemoveBeds) {
            accountToUpdate.ElixirSuite__Reserved_bed__c = null;
            accountToUpdate.ElixirSuite__Reservation__c = null;
            accountToUpdate.ElixirSuite__Start_Date_Time__c = null;
            accountToUpdate.ElixirSuite__End_Date_Time__c = null;
        }
        // Update the Account fields with Reservation Line Item details
        for (Account accountToUpdate : accountsToUpdate) {
            if(accountToLineItems.containsKey(accountToUpdate.Id)){
                ElixirSuite__Reservation_Line_Item__c resLineItem = accountToLineItems.get(accountToUpdate.Id);   
                accountToUpdate.ElixirSuite__Reserved_bed__c = resLineItem.ElixirSuite__Bed__c;//Lookup to location 
                accountToUpdate.ElixirSuite__Reservation__c = resLineItem.ElixirSuite__Reservation__c;//Lookup to Reservation
                accountToUpdate.ElixirSuite__Start_Date_Time__c = resLineItem.ElixirSuite__Start_Date__c;
                accountToUpdate.ElixirSuite__End_Date_Time__c = resLineItem.ElixirSuite__End_Date__c;
            }
        }
        try{
            if (accountsToUpdate!=null && accountsToUpdate.size()>0) {
                DMLManager.updateAsUser(accountsToUpdate);
            }if (accountsToRemoveBeds!=null && accountsToRemoveBeds.size()>0) {
                DMLManager.updateAsUser(accountsToRemoveBeds);
            }
        }   
        catch(Exception e){
            ExceptionLog.logError(e);
        }
    }
}
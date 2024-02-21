public with sharing class ReservationDashboardHelper {
    
    public static void createResercationDashboard(Map<Id, ElixirSuite__Reservation__c> reservationMap){
        try{
            Map<String, List<ElixirSuite__Reservation_Line_Item__c>> reservationToLineItem = new Map<String, List<ElixirSuite__Reservation_Line_Item__c>>();
            List<ElixirSuite__Reservation_Dashboard__c> dashboardItems = new List<ElixirSuite__Reservation_Dashboard__c>();
            List<ElixirSuite__Reservation_Line_Item__c> reservationLineItem = [SELECT Id, ElixirSuite__Account__c, ElixirSuite__Bed__c, ElixirSuite__Start_Date__c,
                                                                               ElixirSuite__End_Date__c, ElixirSuite__Reservation__c, ElixirSuite__Room__c, ElixirSuite__Suite__c
                                                                               FROM ElixirSuite__Reservation_Line_Item__c 
                                                                               WHERE ElixirSuite__Reservation__c IN:reservationMap.keySet()
                                                                               AND ElixirSuite__isBillable__c='False'
                                                                               WITH SECURITY_ENFORCED];
            for(ElixirSuite__Reservation_Line_Item__c lineItem : reservationLineItem){
                if(reservationToLineItem.containsKey(lineItem.ElixirSuite__Reservation__c)){
                    reservationToLineItem.get(lineItem.ElixirSuite__Reservation__c).add(lineItem);
                }
                else{
                    reservationToLineItem.put(lineItem.ElixirSuite__Reservation__c, new List<ElixirSuite__Reservation_Line_Item__c>{lineItem});
                }
            }
            
            for(Id reservationId : reservationMap.keySet()){
                if(reservationMap.get(reservationId).ElixirSuite__Status__c == 'Pending' || reservationMap.get(reservationId).ElixirSuite__Status__c == 'Confirmed'){
                    List<ElixirSuite__Reservation_Line_Item__c> lineItemLst = reservationToLineItem.get(reservationId);                
                    
                    
                    for(ElixirSuite__Reservation_Line_Item__c lineItem : lineItemLst){
                        
                        DateTime startDateTime = lineItem.ElixirSuite__Start_Date__c;
                        Date startDate = date.newinstance(startDateTime.year(), startDateTime.month(), startDateTime.day());
                        DateTime endDateTime = lineItem.ElixirSuite__End_Date__c;
                        Date endDate = date.newinstance(endDateTime.year(), endDateTime.month(), endDateTime.day());                    
                        Integer numberOfDays = startDate.daysBetween(endDate);
                        
                        for(Integer i=0; i<numberOfDays; i++){
                            if(String.isNotBlank(lineItem.ElixirSuite__Room__c)){
                                    ElixirSuite__Reservation_Dashboard__c dashboard = new ElixirSuite__Reservation_Dashboard__c();
                                    dashboard.ElixirSuite__Occupied_Date__c = startDate.addDays(i);
                                    dashboard.ElixirSuite__Location__c = lineItem.ElixirSuite__Room__c;
                                    dashboard.ElixirSuite__Reservation_Line_Item__c = lineItem.Id;
                                    dashboard.ElixirSuite__Reservation__c = lineItem.ElixirSuite__Reservation__c;
                                    dashboardItems.add(dashboard);
                            }
                            if(String.isNotBlank(lineItem.ElixirSuite__Suite__c)){
                                    ElixirSuite__Reservation_Dashboard__c dashboard = new ElixirSuite__Reservation_Dashboard__c();
                                    dashboard.ElixirSuite__Occupied_Date__c = startDate.addDays(i);
                                    dashboard.ElixirSuite__Location__c = lineItem.ElixirSuite__Suite__c;
                                    dashboard.ElixirSuite__Reservation_Line_Item__c = lineItem.Id;
                                    dashboard.ElixirSuite__Reservation__c = lineItem.ElixirSuite__Reservation__c;
                                    dashboardItems.add(dashboard);
                            }
                        }                
                        
                    }
                }
            }
            DMLManager.insertAsUser(dashboardItems);
        }catch(Exception e){
            ExceptionLog.logError(e);
        }
    }
}
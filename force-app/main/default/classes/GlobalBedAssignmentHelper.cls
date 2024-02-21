Global with sharing virtual class GlobalBedAssignmentHelper {
    global virtual void beforeUpdate(List<ElixirSuite__Reservation_Line_Item__c> ResLineRecords, Map<Id,ElixirSuite__Reservation_Line_Item__c> oldResLineRecords ){
        BedAssignmentHelper.bedAssignment(ResLineRecords, oldResLineRecords);
        
    }
    global virtual void afterUpdate(List<ElixirSuite__Reservation_Line_Item__c> oldResLineRecords, List<ElixirSuite__Reservation_Line_Item__c> newResLineRecords){
        BedAssignmentHelper.updateAccountFields(oldResLineRecords, newResLineRecords);
        Map<Id, ElixirSuite__Reservation_Line_Item__c> oldMap = new Map<Id, ElixirSuite__Reservation_Line_Item__c>(oldResLineRecords);
		BedAssignmentHelper.updatePatientOnDashboard(newResLineRecords, oldMap);
    }
}
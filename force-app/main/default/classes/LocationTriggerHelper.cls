public class LocationTriggerHelper {
	public static void checkOutOfOrder(List<ElixirSuite__Location__c> locLst, Map<Id, ElixirSuite__Location__c> oldLocLst) {
        List<ElixirSuite__Location__c> locationsToUpdate = new List<ElixirSuite__Location__c>();
        try {
            for(ElixirSuite__Location__c newLocLst: locLst){
                // Check if the "Status" picklist value is  Out of Order
                if(newLocLst.ElixirSuite__Status__c != 'Out of Order'){
                    // Clear the values of "Out of Order Reason" and "Out of Order Date" fields
                    newLocLst.ElixirSuite__Out_of_Order_Reason__c=null;
                    newLocLst.ElixirSuite__Out_of_Order_Date__c=null;
                    locationsToUpdate.add(newLocLst);
                }
            }
            System.debug('Records'+locationsToUpdate);
            try{
                if (locationsToUpdate !=null && locationsToUpdate.size()>0) {
                    System.debug('sss'+locationsToUpdate.size());
                   // update locationsToUpdate;
                    DMLManager.updateAsUser(locationsToUpdate);
                }
            }
            catch (DMLException e) {
                System.debug('The following exception has occurred: ' + e.getMessage());
            }
            
            }
        catch (Exception e) {
         ExceptionLog.logError(e);
         }
    }
}
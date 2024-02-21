public with sharing class HandleVisibilityOnLocationChange implements Queueable{
    List<Visits__c> newVisits = new List<Visits__c>();
    Set<Id> accountIds = new Set<Id>();
    Boolean isVob = false;
    
    public void execute(QueueableContext context) {
        //  code removal for LX3-10737
    }
    private void addPermissionVOB(List<Visits__c> newVisits){
        //  code removal for LX3-10737
    }
    private static void removePermissionVOB(Map<Id,Set<Id>> vobToAllowedLocations, Set<Id> vobIds){
    //  code removal for LX3-10737
    }
}
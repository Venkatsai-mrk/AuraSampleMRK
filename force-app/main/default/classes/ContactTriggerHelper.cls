public with sharing class ContactTriggerHelper {
    public static void stopDeceasedEdit(contact[] lstRecord,Boolean wasRun){
        try{
        if(DeceasedGlobalStopRecursion.run){
            for(contact ct : lstRecord){
                if(ct.ElixirSuite__Deceased__c){
                    if(wasRun == false){
                        ct.ElixirSuite__Deceased__c.addError('You can only mark the patient as deceased on Account!');
                    }
                }
            }
        }
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
     }
    public static Boolean preventEditIfDeceasedCheckedOnAccount(contact[] lstRecord){
        Boolean flag = false;
        try{
        if(DeceasedGlobalStopRecursion.run){
            Map<Id,Contact> acctContMap = new Map<Id,Contact>();
            for(contact ct : lstRecord){
                acctContMap.put(ct.AccountId,ct);               
            }
            Contact[] recordsToBlock = new List<Contact>();
            Account[] acctLst = [SELECT ID,Name,ElixirSuite__Deceased__c from Account WHERE ID IN : acctContMap.keySet() WITH SECURITY_ENFORCED];
            for(Account acc : acctLst){
                if(acc.ElixirSuite__Deceased__c){
                    flag = true;
                    recordsToBlock.add(acctContMap.get(acc.Id));
                }
            }
            for(Contact contsObj : recordsToBlock){
                contsObj.addError('This patient is deceased. You can not edit this patient record!');
            }
        }
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        return flag;
    }
    public static void blockDeleteIfDeceased(List<Contact> ContLst){
        try{
        for(Contact acc : ContLst){
            System.debug('del '+acc.ElixirSuite__Deceased__c);
            if(acc.ElixirSuite__Deceased__c){
                acc.adderror('Record cannot be deleted as patient is deceased!'); 
            }
        }
    }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
    }
    public static void editEventsTimeZone(List<Contact> oldcont, List<Contact> newCont){
        Set<String> eligibleContacts = new Set<String>();
        Map<Id,Contact> oldContMap = new Map<Id,Contact>(oldcont);
        Map<Id,Contact> newContMap = new Map<Id,Contact>(newCont);
         for(Contact cont : newCont){
             if(cont.Time_Zone__c != oldContMap.get(cont.id).Time_Zone__c){
                 eligibleContacts.add(cont.id);
                 system.debug('eligibleContacts==='+eligibleContacts);
             }
         }
         system.debug('eligibleContacts==='+eligibleContacts);
          if(eligibleContacts !=null && eligibleContacts.size()>0){
           List<Event> events = [SELECT Id,Practitioner_s_Time_Zone__c ,Practitioner__c
                                 FROM Event 
                                 WHERE Practitioner__c IN :eligibleContacts WITH SECURITY_ENFORCED
                                 ORDER BY CreatedDate DESC 
                                LIMIT 500];
            for(Event evt :events){
                if(newContMap.containsKey(evt.Practitioner__c)){
                    evt.Patient_s_Time_Zone__c = newContMap.get(evt.Practitioner__c).Time_Zone__c;
                }
            }
            System.enqueueJob(new editEventsTimeZoneQueueable(events));
        }
     }
}
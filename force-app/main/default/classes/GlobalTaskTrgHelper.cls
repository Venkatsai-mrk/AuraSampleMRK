public with sharing class GlobalTaskTrgHelper {
   public static Boolean preventEditIfDeceasedCheckedOnAccount(Task[] lstRecord){
        Boolean flag = false;
       try{
        if(DeceasedGlobalStopRecursion.run){
            Map<Id,Task> acctTaskMap = new Map<Id,Task>();
            for(Task ct : lstRecord){
                acctTaskMap.put(ct.WhatId ,ct);               
            }
            Task[] recordsToBlock = new List<Task>();
            Account[] acctLst = [SELECT ID,Name,ElixirSuite__Deceased__c from Account WHERE ID IN : acctTaskMap.keySet() WITH SECURITY_ENFORCED];
            for(Account acc : acctLst){
                if(acc.ElixirSuite__Deceased__c){
                    flag = true;
                    recordsToBlock.add(acctTaskMap.get(acc.Id));
                }
            }
            for(Task contsObj : recordsToBlock){
                contsObj.addError('This patient is deceased. You can not edit this patient record!');
            }
        }
       }
       catch(Exception e){
            ExceptionLog.logError(e);
        }
        return flag;
    }
    public static Boolean preventEditIfDeceasedCheckedOnAccountForEvent(Event[] lstRecord){
        Boolean flag = false;
       try{
        if(DeceasedGlobalStopRecursion.run){
            Map<Id,Event> acctTaskMap = new Map<Id,Event>();
            for(Event ct : lstRecord){
                acctTaskMap.put(ct.WhatId ,ct);               
            }
            Event[] recordsToBlock = new List<Event>();
            Account[] acctLst = [SELECT ID,Name,ElixirSuite__Deceased__c from Account WHERE ID IN : acctTaskMap.keySet() WITH SECURITY_ENFORCED];
            for(Account acc : acctLst){
                if(acc.ElixirSuite__Deceased__c){
                    flag = true;
                    recordsToBlock.add(acctTaskMap.get(acc.Id));
                }
            }
            for(Event contsObj : recordsToBlock){
                contsObj.addError('This patient is deceased. You can not edit this patient record!');
            }
        }
       }
       catch(Exception e){
            ExceptionLog.logError(e);
        }
        return flag;
    }
}
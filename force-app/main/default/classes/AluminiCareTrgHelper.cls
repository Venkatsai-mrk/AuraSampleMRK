public with sharing class AluminiCareTrgHelper {
    public static void stopDeceasedEdit(Alumni_Care_Services__c [] lstRecord,Boolean wasRun){
        try{
        if(DeceasedGlobalStopRecursion.run){
            for(Alumni_Care_Services__c  acs : lstRecord){
                if(acs.ElixirSuite__Deceased__c){
                    if(wasRun == false){
                        acs.ElixirSuite__Deceased__c.addError('You can only mark the patient as deceased on Account!');
                    }
                }
            }
        }
        }
        catch(Exception e){
        ExceptionLog.logError(e);
}

    }
    public static Boolean preventEditIfDeceasedCheckedOnAccount(Alumni_Care_Services__c[] lstRecord){
        Boolean flag = false;
        try{
        if(DeceasedGlobalStopRecursion.run){
            Map<Id,Alumni_Care_Services__c> acctAluminiMap = new Map<Id,Alumni_Care_Services__c>();
            Map<Id,Alumni_Care_Services__c> oppAluminiMap = new Map<Id,Alumni_Care_Services__c>();
            for(Alumni_Care_Services__c ct : lstRecord){
                acctAluminiMap.put(ct.ElixirSuite__Patient_Account__c,ct);     
                oppAluminiMap.put(ct.ElixirSuite__Patient_Name__c,ct);
            }
            Alumni_Care_Services__c[] recordsToBlock = new List<Alumni_Care_Services__c>();
            Account[] acctLst = [SELECT ID,Name,ElixirSuite__Deceased__c from Account WHERE ID IN : acctAluminiMap.keySet() WITH SECURITY_ENFORCED];
            for(Account acc : acctLst){
                if(acc.ElixirSuite__Deceased__c){
                    flag = true;
                    recordsToBlock.add(acctAluminiMap.get(acc.Id));
                }
            }
            /***********************************************/ // ALUMIN RECS CAN ALSO BE RELATED TO OPP AND OPP TO ACC || CAN BE MOVED TO ANOTHER METHOD
            Opportunity[] aluminiRelatedOpps = [SELECT ID,Name,AccountId FROM Opportunity WHERE ID IN : oppAluminiMap.KeySet() WITH SECURITY_ENFORCED];
            Map<Id,Id> acctOppMap = new Map<Id,Id>();
            for(Opportunity  opp : aluminiRelatedOpps){
                acctOppMap.put(opp.AccountId,opp.Id);
            }
            Account[] acctForAlumini = [SELECT ID,Name,ElixirSuite__Deceased__c from Account WHERE ID IN : acctOppMap.keySet() WITH SECURITY_ENFORCED];
            for(Account accsObj : acctForAlumini){
                if(accsObj.ElixirSuite__Deceased__c){
                    flag = true;
                    System.debug('#########'+flag);
                    recordsToBlock.add(oppAluminiMap.get(acctOppMap.get(accsObj.Id)));
                }
            }
            /***********************************************/
            for(Alumni_Care_Services__c contsObj : recordsToBlock){
                contsObj.addError('This patient is deceased. You can not edit this patient record!');
            }
        }
        return flag;
    }
        catch(Exception e){
        ExceptionLog.logError(e);
    }
      return flag;
    }
    public static void blockDeleteIfDeceased(List<Alumni_Care_Services__c> vobLst){
        for(Alumni_Care_Services__c acc : vobLst){
            System.debug('del '+acc.ElixirSuite__Deceased__c);
            try{
            if(acc.ElixirSuite__Deceased__c){
                acc.adderror('Record cannot be deleted as patient is deceased!'); 
            }
        }catch(Exception e){
     ExceptionLog.logError(e);
       }
     }
   }
}
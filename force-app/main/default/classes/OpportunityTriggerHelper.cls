public with sharing class OpportunityTriggerHelper{ 
    
    public void stopLocationUpdate(Map<Id,Opportunity> oldOpportunities, List<Opportunity> opportunities){
        if(StopRecursion.stopLocationUpdation){
            for(Opportunity opp :opportunities){
                if(oldOpportunities.get(opp.Id).Location__c!=opp.Location__c){
                    opp.Location__c.addError('You cannot edit the location on Opportunity! Please visit the related account for any location related changes!');
                }
            }
        }
    }  
    public void stageDateTime(Map<Id,Opportunity> oldOpportunities, List<Opportunity> newOpp){
        for(Opportunity opp :newOpp){
            String stage = opp.StageName;
            if(String.isNotBlank(stage) && oldOpportunities.get(opp.Id).StageName != opp.StageName){
                opp.Stage_Modified_Date__c = System.now();
            }
        }
    }
    public void stageDateTime(List<Opportunity> newOpp){
        for(Opportunity opp :newOpp){
            String stage = opp.StageName;
            if(String.isNotBlank(stage)){
                opp.Stage_Modified_Date__c = System.now();
            }
        }
    }
    public void updateAccount(List<Opportunity> newOpp){
        if(StopRecursion.opportunityUpdateForStage){
            return;
        }
        Set<Id> accountIds = new Set<Id>();
        for(Opportunity opp :newOpp){
            if(opp.AccountId!=null){
                accountIds.add(opp.AccountId);
            }
        }
        if(accountIds!=null && accountIds.size()>0){
            List<String> preAdmission = new List<String>{'Prospecting', 'Referred In', 'VOB Requested', 'Assessment In progress', 
                'Treatment Approved', 'Pending Admission'};
                    List<String> admitted = new List<String>{'Admitted'};
                        List<String> discharge = new List<String>{'Discharged'};
                            List<Account> accounts = [SELECT Id, Stage__c, (SELECT Id, StageName FROM Opportunities ORDER BY Stage_Modified_Date__c DESC LIMIT 1)
                                                      FROM Account WHERE Id IN :accountIds WITH SECURITY_ENFORCED];
            List<Account> accountsToUpdate = new List<Account>();
            for(Account acc :accounts){
                List<Opportunity> opp = acc.Opportunities;
                if(opp!=null && opp.size()>0){
                    String stage = opp[0].StageName;
                    if(preAdmission.contains(stage)){
                        stage = 'Pre Admission';
                    }else if(admitted.contains(stage)){
                        stage = 'Admitted';
                    }else if(discharge.contains(stage)){
                        stage = 'Discharged';
                    }else{
                        continue;
                    }
                    Account acct = new Account(
                        Id=acc.Id,
                        Stage__c = stage
                    );
                    accountsToUpdate.add(acct);
                }
            }
            if(accountsToUpdate!=null && accountsToUpdate.size()>0){
                if(Schema.sObjectType.Account.fields.Stage__c.isUpdateable()){
                    StopRecursion.opportunityUpdateForStage = true;
                    update accountsToUpdate;
                }
            }
        }
    }
    public static void stopDeceasedEdit(Opportunity[] lstRecord,Boolean wasRun){
        if(DeceasedGlobalStopRecursion.run){
            for(Opportunity opp : lstRecord){
                if(opp.ElixirSuite__Deceased__c){
                    if(wasRun == false){
                        opp.ElixirSuite__Deceased__c.addError('You can only mark the patient as deceased on Account!');
                    }
                }
            }
        }
        
    }
    public static Boolean preventEditIfDeceasedCheckedOnAccount(Opportunity[] lstRecord){
        Boolean flag = false;
        try{
        if(DeceasedGlobalStopRecursion.run){
            Map<Id,Opportunity> acctOppMap = new Map<Id,Opportunity>();
            for(Opportunity ct : lstRecord){
                acctOppMap.put(ct.AccountId,ct);               
            }
            Opportunity[] recordsToBlock = new List<Opportunity>();
            Account[] acctLst = [SELECT ID,Name,ElixirSuite__Deceased__c from Account WHERE ID IN : acctOppMap.keySet()];
            for(Account acc : acctLst){
                if(acc.ElixirSuite__Deceased__c){
                    flag = true;
                    recordsToBlock.add(acctOppMap.get(acc.Id));
                }
            }
            for(Opportunity oppsObj : recordsToBlock){
                oppsObj.addError('This patient is deceased. You can not edit this patient record!');
            }
        }
       // return flag;
    }
        catch(Exception e){
        ExceptionLog.logError(e);
        }
        return flag;
    }
     public static void blockDeleteIfDeceased(List<Opportunity> oppLst){
        for(Opportunity acc : oppLst){
            System.debug('del '+acc.ElixirSuite__Deceased__c);
            if(acc.ElixirSuite__Deceased__c){
                acc.adderror('Record cannot be deleted as patient is deceased!'); 
            }
        }
     }
}
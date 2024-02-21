public with sharing class PreAssesmentTriggerHelper {
    public static void stopDeceasedEdit(Pre_Assessment__c[] lstRecord,Boolean wasRun){
        if(DeceasedGlobalStopRecursion.run){
            for(Pre_Assessment__c pa : lstRecord){
                if(pa.ElixirSuite__Deceased__c){
                    if(wasRun == false){
                        pa.ElixirSuite__Deceased__c.addError('You can only mark the patient as deceased on Account!');
                    }
                }
            }
        }
    }
    public static Boolean preventEditIfDeceasedCheckedOnAccount(ElixirSuite__Pre_assessment__c[] lstRecord){
        Boolean flag = false;
        try{
        if(DeceasedGlobalStopRecursion.run){
            Map<Id,ElixirSuite__Pre_assessment__c> acctPreAssesMap = new Map<Id,ElixirSuite__Pre_assessment__c>();
            Set<Id> oppId = new Set<Id>();
            for(ElixirSuite__Pre_assessment__c ct : lstRecord){ 
                oppId.add(ct.ElixirSuite__Opportunity__c);
                acctPreAssesMap.put(ct.ElixirSuite__Opportunity__c,ct);               
            }
            ElixirSuite__Pre_assessment__c[] recordsToBlock = createRecordsToBlock(createAcctOppMap(oppId),flag,acctPreAssesMap);
            if(recordsToBlock!=null && recordsToBlock.size()>0){
                flag = true;  
                for(ElixirSuite__Pre_assessment__c oppsObj : recordsToBlock){
                    oppsObj.addError('This patient is deceased. You can not edit this patient record!');
                }
            }
        }
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        return flag;
    }
    public static  Map<Id,Id> createAcctOppMap( Set<Id> oppId ){
        Opportunity[] preRelatedOpp = [SELECT ID,AccountId FROM Opportunity where Id IN : oppId WITH SECURITY_ENFORCED];
        Map<Id,Id> acctOppMap = new Map<Id,Id>();
        for(Opportunity opp : preRelatedOpp){
            acctOppMap.put(opp.AccountId,opp.Id);
        } 
        return acctOppMap;
    }
    public static  ElixirSuite__Pre_assessment__c[]  createRecordsToBlock( Map<Id,Id> acctOppMap ,  Boolean flag, Map<Id,ElixirSuite__Pre_assessment__c> acctPreAssesMap){
        ElixirSuite__Pre_assessment__c[] recordsToBlock = new List<ElixirSuite__Pre_assessment__c>();
        try{
        Account[] acctLst = [SELECT ID,ElixirSuite__Deceased__c from Account WHERE ID IN : acctOppMap.keySet() WITH SECURITY_ENFORCED];
        for(Account acc : acctLst){
            if(acc.ElixirSuite__Deceased__c){
                flag = true;
                recordsToBlock.add(acctPreAssesMap.get(acctOppMap.get(acc.Id)));
            }
        }
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        return recordsToBlock;
    }
    public static void blockDeleteIfDeceased(List<ElixirSuite__Pre_assessment__c> preLst){
        for(ElixirSuite__Pre_assessment__c acc : preLst){
            System.debug('del '+acc.ElixirSuite__Deceased__c);
            if(acc.ElixirSuite__Deceased__c){
                acc.adderror('Record cannot be deleted as patient is deceased!!'); 
            }
        }
    }
}
public with sharing class ERATriggerHandler {
    public static void updateReconciliationStatus(List<ElixirSuite__EOB__c> lstERA){
        try{
            Set<Id> claimid = new Set<Id>();
            for(ElixirSuite__EOB__c eraRec : lstERA){
                if(eraRec.ElixirSuite__Claim__c != null){
                    claimid.add(eraRec.ElixirSuite__Claim__c);
                }
            }
            Map<Id, ElixirSuite__Claim__c> claimMap = new Map<Id, ElixirSuite__Claim__c>([
                SELECT Id, ElixirSuite__Posted__c, ElixirSuite__Reconciliation_Status__c
                FROM ElixirSuite__Claim__c 
                WHERE Id IN :claimid
                WITH SECURITY_ENFORCED
            ]);
            
            List<ElixirSuite__Claim__c> claimsLstUpdate = new List<ElixirSuite__Claim__c>();
            for(ElixirSuite__EOB__c eraRec: lstERA){
                if(eraRec.ElixirSuite__Primary_Posted__c  == false ){
                    ElixirSuite__Claim__c cl = claimMap.get(eraRec.ElixirSuite__Claim__c);
                    if(cl != null && cl.ElixirSuite__Posted__c == true){
                        cl.ElixirSuite__Reconciliation_Status__c = 'Pending Manual Reconciliation';
                        claimsLstUpdate.add(cl);
                    }  
                }
            }
            if(claimsLstUpdate.size()>0 && claimsLstUpdate!= null){
                DMLManager.updateAsUser(claimsLstUpdate);
            }  
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
    }
}
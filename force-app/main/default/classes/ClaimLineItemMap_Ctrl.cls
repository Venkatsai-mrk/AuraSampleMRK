public with sharing class ClaimLineItemMap_Ctrl {

    @AuraEnabled
    public static List<claimLineWrapper> getClaimLines(String recordId){
        
        ElixirSuite__Claim__c claim = [Select id,Name,(Select id,ElixirSuite__Proc_code__c,ElixirSuite__Procedure__r.Name,ElixirSuite__Procedure__r.ElixirSuite__CPT_HCPCS_Code__c from ElixirSuite__Claim_Line_Items__r) from ElixirSuite__Claim__c 
                                       where id =: recordId WITH SECURITY_ENFORCED limit 1];
        
        List<claimLineWrapper> claimLineWrapperList = new List<claimLineWrapper>();
        try{
        if(claim.Claim_Line_Items__r!=null && claim.Claim_Line_Items__r.size() >0){
            
            for(ElixirSuite__Claim_Line_Items__c cl: claim.Claim_Line_Items__r){
                claimLineWrapper wrapperCl = new claimLineWrapper();
                wrapperCl.id = cl.id;
                wrapperCl.procCode = cl.ElixirSuite__Procedure__r.Name;
                wrapperCl.procName = cl.ElixirSuite__Procedure__r.Name;
                wrapperCl.EraLineId = '';
                wrapperCl.disabled = false;
                system.debug('wrapperCl' +wrapperCl);
                claimLineWrapperList.add(wrapperCl);
            }
            
        }
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        return claimLineWrapperList;
    }   
    public class claimLineWrapper{
        @AuraEnabled public string id;
        @AuraEnabled public string procCode;
        @AuraEnabled public string procName;
        @AuraEnabled public string eraLineId;
        @AuraEnabled public boolean disabled;
    }
}
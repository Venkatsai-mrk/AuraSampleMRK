global with sharing virtual class GlobalReconciliationSummary {
set<id> parentsIds=new set<id>();
global virtual void afterUndelete(List<Claim_Line_Items__c> claimLstRecords){
    Elixir_Custom_Setting__c customSetting = Elixir_Custom_Setting__c.getOrgDefaults();
    if(customSetting!=null && customSetting.ElixirSuite__ClaimLineItemTrigger_Active__c){
    
        for(Claim_Line_Items__c tc:claimLstRecords)
            parentsIds.add(tc.Claim__c);
    
    }
    if(parentsIds != null && parentsIds.size()>0){ 
        UpdateReconciliationSummaryOnClaimsCls.updateParentClaims(parentsIds);
        //UpdateReconciliationSummaryOnClaimsCls.deniedStatusUpdate(parentsIds);
        UpdateReconciliationSummaryOnClaimsCls.paidAndPatientResponseSec(parentsIds);
    }

}
global virtual void afterUpdate(List<Claim_Line_Items__c> claimListRecords){
    Elixir_Custom_Setting__c customSetting = Elixir_Custom_Setting__c.getOrgDefaults();
    if(customSetting!=null && customSetting.ElixirSuite__ClaimLineItemTrigger_Active__c){
    
        for(Claim_Line_Items__c tc:claimListRecords)
            parentsIds.add(tc.Claim__c);
    
    }
    if(parentsIds != null && parentsIds.size()>0){ 
        UpdateReconciliationSummaryOnClaimsCls.updateParentClaims(parentsIds);
        //UpdateReconciliationSummaryOnClaimsCls.deniedStatusUpdate(parentsIds);
        UpdateReconciliationSummaryOnClaimsCls.paidAndPatientResponseSec(parentsIds);
    }

}
global virtual void afterDelete(List<Claim_Line_Items__c> oldClaimLstRecords){
    
        for(Claim_Line_Items__c tc:oldClaimLstRecords)
            parentsIds.add(tc.Claim__c);
            if(parentsIds != null && parentsIds.size()>0){ 
                UpdateReconciliationSummaryOnClaimsCls.updateParentClaims(parentsIds);
                //UpdateReconciliationSummaryOnClaimsCls.deniedStatusUpdate(parentsIds);
                UpdateReconciliationSummaryOnClaimsCls.paidAndPatientResponseSec(parentsIds);
            }
    
}

}
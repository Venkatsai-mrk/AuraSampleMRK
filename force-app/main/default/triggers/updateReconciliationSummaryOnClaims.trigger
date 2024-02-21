trigger updateReconciliationSummaryOnClaims on Claim_Line_Items__c (after update, after delete, after undelete) {
    if(System.FeatureManagement.checkPermission('DataMigration')) return; //LX3-6835 - Bypass the trigger execution during data migration
   /* set<id> parentsIds=new set<id>();
     Elixir_Custom_Setting__c customSetting = Elixir_Custom_Setting__c.getOrgDefaults();
    if(customSetting!=null && customSetting.ElixirSuite__ClaimLineItemTrigger_Active__c){
    if((Trigger.isUndelete || Trigger.isUpdate) && Trigger.isAfter){
        for(Claim_Line_Items__c tc:Trigger.new)
            parentsIds.add(tc.Claim__c);
    }
    }
    if(Trigger.isDelete && Trigger.isAfter){
        for(Claim_Line_Items__c tc:Trigger.old)
            parentsIds.add(tc.Claim__c);
    }
    
    if(parentsIds != null && parentsIds.size()>0){ 
        UpdateReconciliationSummaryOnClaimsCls.updateParentClaims(parentsIds);
        //UpdateReconciliationSummaryOnClaimsCls.deniedStatusUpdate(parentsIds);
        UpdateReconciliationSummaryOnClaimsCls.paidAndPatientResponseSec(parentsIds);
    }*/
    String virtualClassName = 'GlobalReconciliationSummary';// Added in Review
    List<Elixir_Pluggable_Classes__mdt> pluggableClass = new List<Elixir_Pluggable_Classes__mdt>();
    pluggableClass = [SELECT
                    DeveloperName,
                    Virtual_Class__c
                    FROM Elixir_Pluggable_Classes__mdt
                    WHERE DeveloperName='updateReconciliationSummaryOnClaims' WITH SECURITY_ENFORCED];
    if(!pluggableClass.isEmpty()){
        virtualClassName = pluggableClass[0].Virtual_Class__c;
    }
    Type t = Type.forName(virtualClassName);
    GlobalReconciliationSummary reconciliationSummary = (GlobalReconciliationSummary) t.newInstance(); 
    
    if(Trigger.isUndelete && Trigger.isAfter){
        reconciliationSummary.afterUndelete(trigger.new);
    }
    if(Trigger.isUpdate && Trigger.isAfter){
        reconciliationSummary.afterUpdate(trigger.new);
    }
    if(Trigger.isDelete && Trigger.isAfter){
        reconciliationSummary.afterDelete(Trigger.old);
    }
    
}
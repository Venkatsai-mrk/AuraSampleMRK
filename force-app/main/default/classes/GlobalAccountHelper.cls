global with sharing virtual class GlobalAccountHelper {
Elixir_Custom_Setting__c record = Elixir_Custom_Setting__c.getOrgDefaults();
global virtual void beforeAccount(List<Account> accountLst,Map<Id,Account> oldMapAccountLst){
    if(record.ElixirSuite__Patient_Deceased__c){ // WORKFLOW DECEASED
        AccountTriggerHelper.checkDeceasedFilter(accountLst);
        AccountTriggerHelper.blockEditIfDeceased(accountLst,oldMapAccountLst); 
            AccountTriggerHelper.replaceBirthSexField(accountLst);
            
    }
        AccountTriggerHelper.checkDuplicateFieldValue(accountLst);
}
global virtual void beforeDelete(List<Account> acctLstrecords){
    if(record.ElixirSuite__Patient_Deceased__c){ // WORKFLOW DECEASED
        AccountTriggerHelper.blockDeleteIfDeceased(acctLstrecords);

    }
    beforeAccount(new List<Account>(), new Map<Id, Account>(acctLstrecords));


}
global virtual void beforeUpdate(List<Account> accountListRecords, Map<Id,Account> oldAccLst ){
    if(StopRecursion.stopLocationUpdation){
        for(Account opp :accountListRecords){
            if(oldAccLst.get(opp.Id).Active_Care_Episode_Location__c!=opp.Active_Care_Episode_Location__c){
                opp.Active_Care_Episode_Location__c.addError('To change the Active Care Episode Location for the patient, please edit the location on the active care episode or create a new care episode!');
            }
        }
    }
    beforeAccount(accountListRecords, oldAccLst);
        AccountTriggerHelper.replaceBirthSexField(accountListRecords);
     
}

@deprecated
global virtual void afterUpdate(List<Account> accOldAccounts, List<Account> accNewAccounts, Map<Id,Account> oldAccMapLst){

}

global virtual void afterUpdate(List<Account> accOldAccounts, List<Account> accNewAccounts, Map<Id,Account> oldAccMapLst , Map<Id,Account> newAccMapLst ){
    AccountTriggerHelper.editEventsTimeZone(accOldAccounts, accNewAccounts);
    AccountTriggerHelper.auditTrailAccount(newAccMapLst, oldAccMapLst);
    if(record.ElixirSuite__Opportunity_stage_update__c){ 
    AccountTriggerHelper.opportunityUpdate(oldAccMapLst, accNewAccounts);
    }
    AccountTriggerHelper.updatePatientCurrentStatus(accNewAccounts);
    if(record.ElixirSuite__Patient_Deceased__c){ // WORKFLOW DECEASED
        AccountTriggerHelper.updateAllCCrelatedObctsForDeceasedAsTrue(accNewAccounts);

    }
    
}
global virtual void updatePatientStatus(List<Account> accRecordLst ){
    AccountTriggerHelper.updatePatientCurrentStatus(accRecordLst);
    
}
global virtual void afterInsert(List<Account> newAccountsLst){
    
    AccountTriggerHelper.updatePatientCurrentStatus(newAccountsLst);
    if(record.ElixirSuite__Patient_Deceased__c){ // WORKFLOW DECEASED
        AccountTriggerHelper.updateAllCCrelatedObctsForDeceasedAsTrue(newAccountsLst);

    }
    
}

}
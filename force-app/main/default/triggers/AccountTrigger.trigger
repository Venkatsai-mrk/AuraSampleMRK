trigger AccountTrigger on Account (before update, after update, after insert,before insert,before delete) {
if(System.FeatureManagement.checkPermission('DataMigration')) return;  //LX3-6835 - Bypass the trigger execution during data migration
/* Elixir_Custom_Setting__c record = Elixir_Custom_Setting__c.getOrgDefaults();
if(record.ElixirSuite__Patient_Deceased__c){ // WORKFLOW DECEASED
    if(trigger.isBefore){ 
        AccountTriggerHelper.checkDeceasedFilter(Trigger.new);
        AccountTriggerHelper.blockEditIfDeceased(Trigger.new,Trigger.oldMap); 
        
    }
    if(trigger.isAfter){ 
        AccountTriggerHelper.updateAllCCrelatedObctsForDeceasedAsTrue(Trigger.new);
    }  
    if(trigger.isBefore && Trigger.isDelete){ 
        System.debug('delete ');
        AccountTriggerHelper.blockDeleteIfDeceased(Trigger.old);
    }
}

if(trigger.isBefore && trigger.isUpdate){
    if(StopRecursion.stopLocationUpdation){
        for(Account opp :trigger.new){
            if(trigger.oldMap.get(opp.Id).Active_Care_Episode_Location__c!=opp.Active_Care_Episode_Location__c){
                opp.Active_Care_Episode_Location__c.addError('To change the Active Care Episode Location for the patient, please edit the location on the active care episode or create a new care episode!');
            }
        }
    }
}   
if(trigger.isAfter && trigger.isUpdate){
    AccountTriggerHelper.editEventsTimeZone(trigger.old, trigger.new);
    if(record.ElixirSuite__Opportunity_stage_update__c){ //added by Mahesh 5828
    AccountTriggerHelper.opportunityUpdate(trigger.oldMap, trigger.new);
    }
}
if(trigger.isAfter && (trigger.isUpdate || trigger.isInsert)){
    AccountTriggerHelper.updatePatientCurrentStatus(trigger.new);
}*/
String virtualClassName = 'GlobalAccountHelper';// Added in Review
List<Elixir_Pluggable_Classes__mdt> pluggableClass = new List<Elixir_Pluggable_Classes__mdt>();
pluggableClass = [SELECT
                DeveloperName,
                Virtual_Class__c
                FROM Elixir_Pluggable_Classes__mdt
                WHERE DeveloperName='AccountTrigger' WITH SECURITY_ENFORCED] ;
if(!pluggableClass.isEmpty()){
    virtualClassName = pluggableClass[0].Virtual_Class__c;
}
Type t = Type.forName(virtualClassName);
GlobalAccountHelper accountHelper = (GlobalAccountHelper) t.newInstance(); 
if(trigger.isBefore && trigger.isInsert ){ 
    accountHelper.beforeAccount(Trigger.new,Trigger.oldMap);
    AccountTriggerHelper.mrnFieldNullUpdate(Trigger.new);
        System.debug(' before insert trigger');
}

if(trigger.isBefore && Trigger.isDelete){ 
    accountHelper.beforeDelete(Trigger.old);
   // accountHelper.beforeAccount(Trigger.new,Trigger.oldMap);
}
if(trigger.isBefore && trigger.isUpdate){
    accountHelper.beforeUpdate( trigger.new, trigger.oldMap);
   // accountHelper.beforeAccount(Trigger.new,Trigger.oldMap);
   AccountTriggerHelper.mrnFieldNullClassBeforeUpdate(Trigger.new,Trigger.oldMap);
   AccountTriggerHelper.mrnValidationBeforeUpdate(Trigger.new,Trigger.oldMap);
} 
if(trigger.isAfter && trigger.isUpdate){
    accountHelper.afterUpdate( trigger.old, trigger.new, trigger.oldMap,trigger.newMap);
    
  //  accountHelper.updatePatientStatus(trigger.new);
   // accountHelper.updateAllAccounts(Trigger.new);
}
if(trigger.isAfter &&  trigger.isInsert){
    System.debug('old map : '+trigger.oldMap);
    accountHelper.afterInsert(trigger.new);
   // accountHelper.updatePatientStatus(trigger.new);
   // accountHelper.updateAllAccounts(Trigger.new);
   AccountTriggerHelper.generateMrnForAccount(Trigger.new);
}
}
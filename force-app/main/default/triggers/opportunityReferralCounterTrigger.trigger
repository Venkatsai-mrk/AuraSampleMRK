/* BY Prachi Goel
* Last updated on 16-Apr-2020
// Parent trigger on Opportunity and does all actions on opportunity
*/
trigger opportunityReferralCounterTrigger on Opportunity (after insert, after delete, after update, before update, before insert,
                                                         before delete) {
    if(System.FeatureManagement.checkPermission('DataMigration')) return; //LX3-6835 - Bypass the trigger execution during data migration
 
   /* Elixir_Custom_Setting__c record = Elixir_Custom_Setting__c.getOrgDefaults();
    if(record.ElixirSuite__Patient_Deceased__c){ // WORKFLOW DECEASED
     if(trigger.isBefore && (!(trigger.isBefore && Trigger.isDelete))){
        Boolean wasRun =  OpportunityTriggerHelper.preventEditIfDeceasedCheckedOnAccount(Trigger.new);
        OpportunityTriggerHelper.stopDeceasedEdit(Trigger.new,wasRun);
    }
        if(trigger.isBefore && Trigger.isDelete){ 
            OpportunityTriggerHelper.blockDeleteIfDeceased(Trigger.old);
        }

   
    if(trigger.isBefore && trigger.isInsert ){
        new OpportunityTriggerHelper().stageDateTime(trigger.new);
    }
    if(trigger.isAfter && (trigger.isInsert || trigger.isUpdate) ){
      
    }
    if(trigger.isBefore && trigger.isUpdate){ // Insertpatient_APEXT_Transferred - updating some bed details related to opportunity
        new OpportunityTriggerHelper().changeBed(trigger.oldMap,trigger.newMap);
        new OpportunityTriggerHelper().stopLocationUpdate(trigger.oldMap,trigger.new);
        new OpportunityTriggerHelper().stageDateTime(trigger.oldMap,trigger.new);
    }
    if(trigger.isAfter && trigger.isInsert){ // CreateCareEpisode_APXT_Transferred
        
    }
    if(trigger.isAfter && trigger.isUpdate) //CreateCareEpisode_APEXT_Transferred
    {
        
        
    } 
}*/

String virtualClassName = 'GlobalopportunityRefTrigger';// Added in Review
List<Elixir_Pluggable_Classes__mdt> pluggableClass = new List<Elixir_Pluggable_Classes__mdt>();
pluggableClass = [SELECT
                DeveloperName,
                Virtual_Class__c
                FROM Elixir_Pluggable_Classes__mdt
                WHERE DeveloperName='opportunityReferralCounterTrigger'
                WITH SECURITY_ENFORCED];
if(!pluggableClass.isEmpty()){
    virtualClassName = pluggableClass[0].Virtual_Class__c;
}
Type t = Type.forName(virtualClassName);
GlobalopportunityRefTrigger oppReferralHelper = (GlobalopportunityRefTrigger) t.newInstance(); 

if(trigger.isBefore && (!(trigger.isBefore && Trigger.isDelete))){
    oppReferralHelper.beforeModification(Trigger.new);

}
if(trigger.isBefore && Trigger.isDelete){ 
    oppReferralHelper.beforeDelete(Trigger.old);
}
if(trigger.isBefore && trigger.isInsert ){
    oppReferralHelper.beforeInsert(trigger.new);

   // new OpportunityTriggerHelper().stageDateTime(trigger.new);
}
if(trigger.isAfter && (trigger.isInsert || trigger.isUpdate) ){
      
}
if(trigger.isBefore && trigger.isUpdate){ 
    oppReferralHelper.beforeUpdate(trigger.old,trigger.new);

   // new OpportunityTriggerHelper().changeBed(trigger.oldMap,trigger.newMap);
   // new OpportunityTriggerHelper().stopLocationUpdate(trigger.oldMap,trigger.new);
    //new OpportunityTriggerHelper().stageDateTime(trigger.oldMap,trigger.new);
}
if(trigger.isAfter && trigger.isInsert){ // CreateCareEpisode_APXT_Transferred
        
}
if(trigger.isAfter && trigger.isUpdate) //CreateCareEpisode_APEXT_Transferred
{
    
    
} 


}
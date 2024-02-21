trigger ContactGlobalTrigger on Contact (before insert,before update,before delete,after update,after insert,after delete) {
    if(System.FeatureManagement.checkPermission('DataMigration')) return;  //LX3-6835 - Bypass the trigger execution during data migration
   /* Elixir_Custom_Setting__c record = Elixir_Custom_Setting__c.getOrgDefaults();
    if(record.ElixirSuite__Patient_Deceased__c){ // WORKFLOW DECEASED
        if(trigger.isBefore && (!(trigger.isBefore && Trigger.isDelete))){
            Boolean wasRun = ContactTriggerHelper.preventEditIfDeceasedCheckedOnAccount(Trigger.new);
            ContactTriggerHelper.stopDeceasedEdit(Trigger.new,wasRun);
        }
        if(trigger.isBefore && Trigger.isDelete){ 
            ContactTriggerHelper.blockDeleteIfDeceased(Trigger.old);
        }
    }
     if(trigger.isAfter && trigger.isUpdate){
        ContactTriggerHelper.editEventsTimeZone(trigger.old, trigger.new);
     }*/
     String virtualClassName = 'GlobalContactTriggerHelper';// Added in Review
    List<Elixir_Pluggable_Classes__mdt> pluggableClass = new List<Elixir_Pluggable_Classes__mdt>();
    pluggableClass = [SELECT
                    DeveloperName,
                    Virtual_Class__c
                    FROM Elixir_Pluggable_Classes__mdt
                    WHERE DeveloperName='ContactGlobalTrigger'
                    WITH SECURITY_ENFORCED];
    if(!pluggableClass.isEmpty()){
        virtualClassName = pluggableClass[0].Virtual_Class__c;
    }
    Type t = Type.forName(virtualClassName);
    GlobalContactTriggerHelper contactTrigger = (GlobalContactTriggerHelper) t.newInstance(); 
    
    if(trigger.isBefore && (!(trigger.isBefore && Trigger.isDelete))){
        contactTrigger.preventEditIfDeceasedChecked(Trigger.new);
      //  Boolean wasRun = contactTrigger.preventEditIfDeceasedChecked(Trigger.new);
       // contactTrigger.stopDeceasedEditing(Trigger.new,wasRun);
    }
    if(trigger.isBefore && Trigger.isDelete){ 
        contactTrigger.beforeDelete(Trigger.old);
    }
    if(trigger.isAfter && trigger.isUpdate){
        contactTrigger.afterUpdate(trigger.old, trigger.new);
     }
}
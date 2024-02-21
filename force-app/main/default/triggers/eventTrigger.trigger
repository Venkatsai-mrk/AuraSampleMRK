trigger eventTrigger on Event (After insert , After Update,before insert,before update,after delete ,before delete) { 
    if(System.FeatureManagement.checkPermission('DataMigration')) return; //LX3-6835 - Bypass the trigger execution during data migration
    
    String virtualClassName = 'GlobalVirtualeventTrigger';// Added in Review
    List<Elixir_Pluggable_Classes__mdt> pluggableClass = new List<Elixir_Pluggable_Classes__mdt>();
    pluggableClass = [SELECT
                    DeveloperName,
                    Virtual_Class__c
                    FROM Elixir_Pluggable_Classes__mdt
                    WHERE DeveloperName='eventTrigger' WITH SECURITY_ENFORCED];
    if(!pluggableClass.isEmpty()){
        virtualClassName = pluggableClass[0].Virtual_Class__c;
    }
    Type t = Type.forName(virtualClassName);
    GlobalVirtualeventTrigger eventTrigObj = (GlobalVirtualeventTrigger) t.newInstance(); 
    
    if(trigger.isBefore && trigger.isInsert){
        eventTrigObj.beforeInsert(trigger.new);
    }
    if(trigger.isBefore && trigger.isUpdate){
        eventTrigObj.beforeUpdate(trigger.new, trigger.oldMap);
    }
    if(trigger.isAfter && trigger.isInsert){
        eventTrigObj.afterInsert(trigger.new);
    }
    if(trigger.isAfter && trigger.isUpdate){
       eventTrigObj.afterUpdate(trigger.new);
       eventTrigObj.afterUpdateMap(trigger.new,trigger.oldMap);
    }

    //added by Anmol for LX3-8779
    if(trigger.isAfter && trigger.isDelete){
        eventTrigObj.afterDelete(trigger.old);
        eventTrigObj.afterDeleteMap(trigger.old,trigger.oldMap);
    }
    
    if(trigger.isBefore && trigger.isDelete){
        System.debug('eventTrigger line 35');
        eventTrigObj.beforeDelete(trigger.old);
    }
    //end by Anmol for LX3-8779
  
    /*if((trigger.isBefore && (trigger.isInsert || trigger.isUpdate))){             //trigger run on freshly created events
       // if(!system.isBatch()){  
           // EventActionshelper.myaction(trigger.new);
            System.enqueueJob(new EventQueueable(Trigger.New));
    }
    //if((trigger.isInsert || trigger.isUpdate) && !StopRecursion.eventTimeZone){
    if(Trigger.isAfter && (trigger.isInsert || trigger.isUpdate)){
    //EmailMessageTriggerHandler.sendEmail(trigger.new);
    System.enqueueJob(new EventQueueable(Trigger.New));
    } */
    
    
}
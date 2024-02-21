trigger TaskTrigger on Task (before insert, before update) {
    if(System.FeatureManagement.checkPermission('DataMigration')) return; //LX3-6835 - Bypass the trigger execution during data migration
   /* Elixir_Custom_Setting__c record = Elixir_Custom_Setting__c.getOrgDefaults();
    if(record.ElixirSuite__Patient_Deceased__c){ // WORKFLOW DECEASED
        if(trigger.isBefore) {
            GlobalTaskTrgHelper.preventEditIfDeceasedCheckedOnAccount(Trigger.new);
        }
    }*/
    String virtualClassName = 'GlobalTaskHelper';
    List<Elixir_Pluggable_Classes__mdt> pluggableClass = new List<Elixir_Pluggable_Classes__mdt>();
    pluggableClass = [SELECT
                    DeveloperName,
                    Virtual_Class__c
                    FROM Elixir_Pluggable_Classes__mdt
                    WHERE DeveloperName='TaskTrigger' WITH SECURITY_ENFORCED];
    if(!pluggableClass.isEmpty()){
        virtualClassName = pluggableClass[0].Virtual_Class__c;
    }
    Type t = Type.forName(virtualClassName);
    GlobalTaskHelper  taskRelatedData= (GlobalTaskHelper) t.newInstance(); 
    
    /*if(trigger.isBefore) { 
        taskRelatedData.beforeModify(trigger.new);
    }*/
    if(Trigger.isBefore && Trigger.isInsert){ 
        taskRelatedData.beforeInsert(trigger.new);
        
    }
    if(Trigger.isBefore && Trigger.isUpdate){ 
        taskRelatedData.beforeUpdate(trigger.new);
    }
    
    
  /*  list<Task> tasksToProcess = new list<Task>();
    
    if(Trigger.isInsert){
        for(task each : trigger.new){
            if(each.CallDisposition == null && each.Disposition__c != null)
                each.CallDisposition = each.Disposition__c;
            tasksToProcess.add(each);
        }
    }else{
        for(task each : trigger.new)
            if(each.Disposition__c != null && each.Disposition__c != trigger.oldMap.get(each.id).Disposition__c){
                if(each.CallDisposition == null)
                    each.CallDisposition = each.Disposition__c;
                tasksToProcess.add(each);
            }
    }
    
    
    map<task,lead> taskToLead = new map<task,lead>();
    list<string> leadIds = new list<string>();
    for(task each : tasksToProcess)
        if(each.whoId != null && ((string)each.WhoId).startsWith('00Q'))
        leadIds.add(each.whoId);
    
    map<id,lead> leads = new map<id,lead>([SELECT id, firstDisposition__c FROM Lead 
                                           WHERE Id IN:leadIds WITH SECURITY_ENFORCED]);
    for(task each : tasksToProcess){
        if(each.whoId != null && ((string)each.WhoId).startsWith('00Q')){
            if(leads.get(each.whoId).firstDisposition__c == null){
                leads.get(each.whoId).firstDisposition__c = each.CallDisposition;
                leads.get(each.whoId).FirstCallDurations__c = each.CallDurationInSeconds;
            }
            leads.get(each.whoId).lastDisposition__c = each.CallDisposition;
        }
    }
    if(!leads.isEmpty())
        if(Schema.sObjectType.Lead.fields.firstDisposition__c.isUpdateable() &&
           Schema.sObjectType.Lead.fields.FirstCallDurations__c.isUpdateable() &&
           Schema.sObjectType.Lead.fields.lastDisposition__c.isUpdateable()){
               update leads.values();
           }*/
}
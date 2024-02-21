trigger AluminiGlobalTrg on Alumni_Care_Services__c (before insert,before update,before delete) {
    if(System.FeatureManagement.checkPermission('DataMigration')) return; //LX3-6835 - Bypass the trigger execution during data migration
   /* Elixir_Custom_Setting__c record = Elixir_Custom_Setting__c.getOrgDefaults();
    if(record.ElixirSuite__Patient_Deceased__c){ // WORKFLOW DECEASED
        if(trigger.isBefore && (!(trigger.isBefore && Trigger.isDelete))){
            Boolean wasRun = AluminiCareTrgHelper.preventEditIfDeceasedCheckedOnAccount(Trigger.new);
            AluminiCareTrgHelper.stopDeceasedEdit(Trigger.new,wasRun);             
        }
        if(trigger.isBefore && Trigger.isDelete){ 
            AluminiCareTrgHelper.blockDeleteIfDeceased(Trigger.old);
        }
    }*/
    String virtualClassName = 'GlobalAluminiCareTrigger';// Added in Review
    List<Elixir_Pluggable_Classes__mdt> pluggableClass = new List<Elixir_Pluggable_Classes__mdt>();
    pluggableClass = [SELECT
                    DeveloperName,
                    Virtual_Class__c
                    FROM Elixir_Pluggable_Classes__mdt
                    WHERE DeveloperName='AluminiGlobalTrg'
                    WITH SECURITY_ENFORCED];
    if(!pluggableClass.isEmpty()){
        virtualClassName = pluggableClass[0].Virtual_Class__c;
    }
    Type t = Type.forName(virtualClassName);
    GlobalAluminiCareTrigger aluminiTrigger = (GlobalAluminiCareTrigger) t.newInstance(); 
    
   /* if(trigger.isBefore && (!(trigger.isBefore && Trigger.isDelete))){
        aluminiTrigger.preventEditIfDeceasedChecked(Trigger.new);
        //Boolean wasRun = AluminiCareTrgHelper.preventEditIfDeceasedCheckedOnAccount(Trigger.new);
       // AluminiCareTrgHelper.stopDeceasedEdit(Trigger.new,wasRun);
    }*/
    if(Trigger.isBefore && Trigger.isInsert){ 
        aluminiTrigger.beforeInsert(trigger.new);
        
    }
    if(Trigger.isBefore && Trigger.isUpdate){ 
        aluminiTrigger.beforeUpdate(trigger.new);
    }
    if(trigger.isBefore && Trigger.isDelete){ 
        aluminiTrigger.beforeDelete(Trigger.old);
    }
}
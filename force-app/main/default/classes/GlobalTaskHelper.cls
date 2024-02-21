Global with sharing virtual class GlobalTaskHelper {
    global virtual void beforeInsert(Task[] lstTaskRecords){
        Elixir_Custom_Setting__c record = Elixir_Custom_Setting__c.getOrgDefaults();
        if(record.ElixirSuite__Patient_Deceased__c){ // WORKFLOW DECEASED
            GlobalTaskTrgHelper.preventEditIfDeceasedCheckedOnAccount(lstTaskRecords);
        }
    }
    global virtual void beforeUpdate(Task[] listTaskRecords){
        Elixir_Custom_Setting__c record = Elixir_Custom_Setting__c.getOrgDefaults();
        if(record.ElixirSuite__Patient_Deceased__c){ // WORKFLOW DECEASED
            GlobalTaskTrgHelper.preventEditIfDeceasedCheckedOnAccount(listTaskRecords);
        }
    }
}
Global with sharing virtual class GlobalAluminiCareTrigger {
    global virtual void beforeInsert(Alumni_Care_Services__c[]  lstRecords){
        Elixir_Custom_Setting__c record = Elixir_Custom_Setting__c.getOrgDefaults();
        if(record.ElixirSuite__Patient_Deceased__c){ // WORKFLOW DECEASED
            Boolean wasRun = AluminiCareTrgHelper.preventEditIfDeceasedCheckedOnAccount(lstRecords);
            AluminiCareTrgHelper.stopDeceasedEdit(lstRecords,wasRun);
        }
    }
    global virtual void beforeUpdate(Alumni_Care_Services__c[]  listRecords){
        Elixir_Custom_Setting__c record = Elixir_Custom_Setting__c.getOrgDefaults();
        if(record.ElixirSuite__Patient_Deceased__c){ // WORKFLOW DECEASED
            Boolean wasRun = AluminiCareTrgHelper.preventEditIfDeceasedCheckedOnAccount(listRecords);
            AluminiCareTrgHelper.stopDeceasedEdit(listRecords,wasRun);
        }
    }
        global virtual void beforeDelete(List<Alumni_Care_Services__c> alumniListRecords){
            Elixir_Custom_Setting__c record = Elixir_Custom_Setting__c.getOrgDefaults();
        if(record.ElixirSuite__Patient_Deceased__c){ // WORKFLOW DECEASED
            AluminiCareTrgHelper.blockDeleteIfDeceased(alumniListRecords);
        }

    }
}
Global with sharing virtual class GlobalContactTriggerHelper {
    global virtual void preventEditIfDeceasedChecked(contact[] listRecords){
        Elixir_Custom_Setting__c record = Elixir_Custom_Setting__c.getOrgDefaults();
        if(record.ElixirSuite__Patient_Deceased__c){ // WORKFLOW DECEASED
            Boolean wasRun = ContactTriggerHelper.preventEditIfDeceasedCheckedOnAccount(listRecords);
            ContactTriggerHelper.stopDeceasedEdit(listRecords,wasRun);
        }
    }
        global virtual void beforeDelete(List<Contact> ContactListRecords){
            Elixir_Custom_Setting__c record = Elixir_Custom_Setting__c.getOrgDefaults();
        if(record.ElixirSuite__Patient_Deceased__c){ // WORKFLOW DECEASED
            ContactTriggerHelper.blockDeleteIfDeceased(ContactListRecords);
        }

    }
    global virtual void afterUpdate(List<Contact> oldcontactRecords, List<Contact> newContactRecords){
        ContactTriggerHelper.editEventsTimeZone(oldcontactRecords, newContactRecords);

    }
}
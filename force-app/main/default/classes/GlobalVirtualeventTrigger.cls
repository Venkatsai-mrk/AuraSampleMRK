global virtual  class GlobalVirtualeventTrigger {
	global virtual void beforeInsert(List<Event> eventLst)
    {
        eventTriggerHandler.duplicateRecords(eventLst);
        Elixir_Custom_Setting__c record = Elixir_Custom_Setting__c.getOrgDefaults();
        if(record.ElixirSuite__Patient_Deceased__c){ // WORKFLOW DECEASED
            GlobalTaskTrgHelper.preventEditIfDeceasedCheckedOnAccountForEvent(eventLst);
        }
        
    }
    @deprecated
    global virtual void beforeUpdate(List<Event> eventLst)
    {
        
    }
    global virtual void beforeUpdate(List<Event> eventLst, Map<id,Event> oldEventMap )
    {
        eventTriggerHandler.duplicateRecordsUpdate(eventLst, oldEventMap);
        Elixir_Custom_Setting__c record = Elixir_Custom_Setting__c.getOrgDefaults();
        if(record.ElixirSuite__Patient_Deceased__c){ // WORKFLOW DECEASED
            GlobalTaskTrgHelper.preventEditIfDeceasedCheckedOnAccountForEvent(eventLst);
        }
        eventTriggerHandler.preventAppointmentViaEdit(eventLst, oldEventMap);
    }
    global virtual void afterInsert(List<Event> eventLst)
    {      
        eventTriggerHandler.saveRecord(eventLst);
        Map<Id,Event> oldEvMap = new Map<Id,Event>();
        eventTriggerHandler.calculateNextAvailSlot(eventLst,oldEvMap);
    }
    global virtual void afterUpdate(List<Event> eventLst)
    {
        eventTriggerHandler.saveRecordUpdate(eventLst);
    }

    global virtual void afterUpdateMap(List<Event> eventLst,Map<Id,Event> oldEvMap)
    {
        eventTriggerHandler.calculateNextAvailSlot(eventLst,oldEvMap);
    }
    
    global virtual void afterDeleteMap(List<Event> eventLst,Map<Id,Event> oldEvMap)
    {
        eventTriggerHandler.calculateNextAvailSlot(eventLst,oldEvMap);
    }

    //added by Anmol for LX3-8779
    global virtual void afterDelete(List<Event> eventLst)
    {
        eventTriggerHandler.deleteChildRecords(eventLst);
    }
    
    global virtual void beforeDelete(List<Event> eventLst)
    {
        System.debug('GlobalVirtualeventTrigger line 40');
        eventTriggerHandler.beforeDeleteCheckSessionNotes(eventLst);
    }
    //end by Anmol for LX3-8779
}
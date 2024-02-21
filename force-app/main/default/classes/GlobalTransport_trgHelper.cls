global virtual class GlobalTransport_trgHelper {
    
    global virtual void afterInsert(List<Transport__c> transportLst)
    {
        ProcCreatnForTransport_handler.createProc(transportLst);
    }
    global virtual void afterUpdate(List<Transport__c> transportLst)
    {
        ProcCreatnForTransport_handler.updateProc(transportLst);
    }
    global virtual void beforeInsert(List<Transport__c> transportLst)
    {
        ProcCreatnForTransport_handler.createProc(transportLst);
        ProcCreatnForTransport_handler.populateCareEpisode(transportLst);
    }
    global virtual void beforeUpdate(List<Transport__c> transportLst)
    {
        ProcCreatnForTransport_handler.populateCareEpisode(transportLst);
    }
}
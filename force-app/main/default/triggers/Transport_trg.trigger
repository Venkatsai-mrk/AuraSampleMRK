trigger Transport_trg on Transport__c (after insert,after update, before insert, before update) 
{
    if(System.FeatureManagement.checkPermission('DataMigration')) return; //LX3-6835 - Bypass the trigger execution during data migration
	
    String virtualClassName = 'GlobalTransport_trgHelper';// Added in Review
    List<Elixir_Pluggable_Classes__mdt> pluggableClass = new List<Elixir_Pluggable_Classes__mdt>();
    pluggableClass = [SELECT
                    DeveloperName,
                    Virtual_Class__c
                    FROM Elixir_Pluggable_Classes__mdt
                    WHERE DeveloperName='Transport_trg'
                    WITH SECURITY_ENFORCED];
    if(!pluggableClass.isEmpty()){
        virtualClassName = pluggableClass[0].Virtual_Class__c;
    }
    Type t = Type.forName(virtualClassName);
    GlobalTransport_trgHelper transport_triObj = (GlobalTransport_trgHelper) t.newInstance(); 
    
    if(trigger.isBefore && trigger.isInsert){
       transport_triObj.beforeInsert(trigger.new);
    }
    if(trigger.isBefore && trigger.isUpdate){
        transport_triObj.beforeUpdate(trigger.new);
    }
    if(trigger.isAfter && trigger.isInsert){
       transport_triObj.afterInsert(trigger.new);
    }
    if(trigger.isAfter && trigger.isUpdate){
        transport_triObj.afterUpdate(trigger.new);
    }
    
    
    /* if(Trigger.IsInsert )
    {
        ProcCreatnForTransport_handler.createProc(Trigger.new);
    }
    if(Trigger.IsUpdate)
    {
        ProcCreatnForTransport_handler.updateProc(Trigger.new);
    }
    if((Trigger.isBefore && Trigger.isInsert) || (Trigger.isBefore && Trigger.isUpdate)){
        ProcCreatnForTransport_handler.populateCareEpisode(Trigger.new);
    }*/
 /*   if(trigger.isInsert || trigger.isUpdate){
        List<UserLocation__c> userLocations = [SELECT Id FROM UserLocation__c WITH SECURITY_ENFORCED LIMIT 1];
        Boolean locationConfigured = false;
        if(userLocations!=null){
            locationConfigured = true;
        }
        system.debug('locationConfigured '+locationConfigured);
        if(locationConfigured){
            Set<Id> oppId = new Set<Id>();
            for(Transport__c transport:trigger.new){
                system.debug('transport '+transport.Patient_name__c);
                if(transport.Patient_name__c!=null){
                    if(trigger.isUpdate && transport.Patient_name__c!=trigger.oldMap.get(transport.Id).Patient_name__c){
                        oppId.add(transport.Patient_name__c);
                    }else if(trigger.isInsert){
                        oppId.add(transport.Patient_name__c);
                    }
                }
            }
            system.debug('oppId '+oppId);
            List<Opportunity> opportunities = [SELECT Id,AccountId FROM Opportunity WHERE Id IN :oppId WITH SECURITY_ENFORCED];
            Set<Id> accountId = new Set<Id>();
            for(Opportunity opp :opportunities){
                accountId.add(opp.AccountId);
            }
            if(accountId!=null && accountId.size()>0){
                //  code removal for LX3-10737
            }
        }
    }*/
}
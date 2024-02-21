/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-25-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class AppointmentHandlingForPatients {

    public static void eventHandlingForDeletedGroupPatients(List<ElixirSuite__Group_Patient__c> groupPatientToBeDeleted){
        
        system.debug('inenter'+groupPatientToBeDeleted);  
        Set<Id> patientIds = new Set<Id>();
        Set<Id> groupIds = new Set<Id>();
        
        for(ElixirSuite__Group_Patient__c record: groupPatientToBeDeleted){
            
            groupIds.add(record.ElixirSuite__Group_Name__c);
            patientIds.add(record.ElixirSuite__Current_Patient_Name__c);
        }
        
        List<Event> eventToBeDeleted = new List<Event>();
        system.debug('data'+patientIds);
        system.debug('data'+groupIds);
        
        
        Set<Id> setOfRemainingParentGroup = new Set<Id>();
        for(ElixirSuite__Group_Patient__c record: [Select id,ElixirSuite__Current_Patient_Name__c,ElixirSuite__Group_Name__c from ElixirSuite__Group_Patient__c where ElixirSuite__Current_Patient_Name__c IN: patientIds WITH SECURITY_ENFORCED]){
            
            setOfRemainingParentGroup.add(record.ElixirSuite__Group_Name__c);
            
            
            
        }
        try{
        
        if(setOfRemainingParentGroup.size() >0){
            for(Id gpId: groupIds){
                if(setOfRemainingParentGroup.contains(gpId)){
                    setOfRemainingParentGroup.remove(gpId);
                }
            }
        }
        system.debug('remaingp'+setOfRemainingParentGroup);
        String mapkey;
        Map<String,List<String >> mapOfEventToListOfRemainingGPId = new Map<String,List<String>>();
        for(Event record: [Select id,subject,whatId,StartDateTime,EndDateTime from Event where whatId IN: setOfRemainingParentGroup WITH SECURITY_ENFORCED]){
            mapkey = record.subject +  record.StartDateTime + record.EndDateTime;
            if(mapOfEventToListOfRemainingGPId.containsKey(mapkey)){
                 mapOfEventToListOfRemainingGPId.get(mapkey).add(record.whatId);
            }else{
                mapOfEventToListOfRemainingGPId.put(mapkey, new List<String>{record.whatId});
            }
            system.debug('remainMap'+mapOfEventToListOfRemainingGPId);
        }
       
        Map<String,List<String >> mapOfEventToListOfDeletedGPId = new Map<String,List<String>>();
        for(Event record: [Select id,subject,whatId,StartDateTime,EndDateTime from Event where whatId IN: groupIds WITH SECURITY_ENFORCED]){
            mapkey = record.subject +  record.StartDateTime + record.EndDateTime;
            if(mapOfEventToListOfDeletedGPId.containsKey(mapkey)){
                 mapOfEventToListOfDeletedGPId.get(mapkey).add(record.whatId);
            }else{
                mapOfEventToListOfDeletedGPId.put(mapkey, new List<String>{record.whatId});
            }
           system.debug('deleMap'+mapOfEventToListOfDeletedGPId);
        }
        for(Event record: [Select id,subject,whatId,StartDateTime,EndDateTime from Event where whatId IN: patientIds WITH SECURITY_ENFORCED]){
            
            mapkey = record.subject +  record.StartDateTime + record.EndDateTime;
            if(mapOfEventToListOfRemainingGPId.containsKey(mapkey)){
                continue;
            }else{
                if(mapOfEventToListOfDeletedGPId.containsKey(mapkey)){
                    eventToBeDeleted.add(record);
                }else{
                    continue;
                }
            }
            system.debug('lst'+eventToBeDeleted);
        }
        
        
        if(eventToBeDeleted.size() >0){
        //if(Schema.sObjectType.Event.isDeletable()){
            
                //delete eventToBeDeleted;
                DMLManager.deleteAsUser(eventToBeDeleted);
            //}  
        }
    }
        catch(Exception e){
        ExceptionLog.logError(e);
}

    }
    
    
    public static void eventHandlingForInsertedGroupPatients( List<ElixirSuite__Group_Patient__c> groupPatientInserted){
        system.debug('inenter');
        
        Map<String,Set<String>> mapOfEventKeyToPatientsId = new Map<String,Set<String>>();
        Map<String,List<Event>> mapOfGroupIdToEvent = new Map<String,List<Event>>();
        Set<Id> patientIds = new Set<Id>();
        Set<Id> groupIds = new Set<Id>();
        List<Event> eventToBeInserted = new List<Event>();
        
        for(ElixirSuite__Group_Patient__c record: groupPatientInserted){
            
            groupIds.add(record.ElixirSuite__Group_Name__c);
            patientIds.add(record.ElixirSuite__Current_Patient_Name__c);
        }
        
        
        
        
        for(Event record: [Select id,subject,whatId,StartDateTime,EndDateTime from Event where whatId IN: groupIds WITH SECURITY_ENFORCED]){
            try{
            if(!mapOfGroupIdToEvent.containsKey(record.whatId)){
                
                mapOfGroupIdToEvent.put(record.whatId, new List<Event>{record});
            }else{
                mapOfGroupIdToEvent.get(record.whatId).add(record);
            }
            
        }
            catch(Exception e){
            ExceptionLog.logError(e);
}

        }
        
        String mapkey;
        for(Event eveRecord: [Select id,subject,whatId,StartDateTime,EndDateTime from Event where whatId IN: patientIds WITH SECURITY_ENFORCED]){
            
            mapkey = eveRecord.subject +  eveRecord.StartDateTime + eveRecord.EndDateTime;
            try{
            if(!mapOfEventKeyToPatientsId.containsKey(mapkey)){
                
                mapOfEventKeyToPatientsId.put(mapkey, new Set<String>{eveRecord.whatId});
            }else{
                mapOfEventKeyToPatientsId.get(mapkey).add(eveRecord.whatId);
            }
        }
            catch(Exception e){
            ExceptionLog.logError(e);
}

        }
        Set<String> tempSet = new Set<String>();
        for(ElixirSuite__Group_Patient__c record: groupPatientInserted){
            if(mapOfGroupIdToEvent.size() >0 && mapOfGroupIdToEvent.containsKey(record.ElixirSuite__Group_Name__c)){
                if(mapOfGroupIdToEvent.get(record.ElixirSuite__Group_Name__c).size() >0){
                    for(Event eveRecord: mapOfGroupIdToEvent.get(record.ElixirSuite__Group_Name__c)){
                        mapkey = eveRecord.subject +  eveRecord.StartDateTime + eveRecord.EndDateTime;
                        if(mapOfEventKeyToPatientsId.size() >0 && mapOfEventKeyToPatientsId.containsKey(mapkey)){
                            if(mapOfEventKeyToPatientsId.get(mapkey).size() >0){
                                
                                tempSet = mapOfEventKeyToPatientsId.get(mapkey);
                                if(tempSet.contains(record.ElixirSuite__Current_Patient_Name__c)){
                                    
                                }else{
                                    Event newrecord = eveRecord.clone(false,false,false,false);
                                    newrecord.WhatId = record.ElixirSuite__Current_Patient_Name__c;
                                    
                                    eventToBeInserted.add(newrecord);
                                }
                            }
                        }else{
                            Event newrecord = eveRecord.clone(false,false,false,false);
                            newrecord.WhatId = record.ElixirSuite__Current_Patient_Name__c;
                            
                            eventToBeInserted.add(newrecord);
                            system.debug('ins '+eventToBeInserted);
                        }
                    }
                }
            }
        }        
        
       
        system.debug('ins '+eventToBeInserted.size());
        try{
        
        
            if(eventToBeInserted.size() >0){
                if(Schema.sObjectType.Event.isCreateable() &&
                Schema.sObjectType.Event.fields.WhatId.isCreateable()){    
                insert eventToBeInserted;
            }
        
        }
      }  
    catch(Exception e){
    ExceptionLog.logError(e);
}
}
}
public with sharing class eventTriggerHandler {
    public static void duplicateRecords(List<Event> lstEvent){
        system.debug('duplicateRecords'+lstEvent[0].id);
        Set<Id> patientGroupIds = new Set<Id>();
        Set<Id> accIds = new Set<Id>();
        List<Event> existingRecords = new List<Event>();
        Map<Id, string> groupName = new Map<Id, string>();
        
        for(Event event : lstEvent) {
            if(event.WhatId != null){
                 String relatedObjectName = event.WhatId.getSObjectType().getDescribe().getName();
            	if(relatedObjectName == 'ElixirSuite__Account_Group__c'){
                patientGroupIds.add(event.WhatId);
            }
            }
           
        }
        if(patientGroupIds.size() >0 && patientGroupIds != null){
            List<ElixirSuite__Group_Patient__c> groupPatientIds = [SELECT Id, Name, ElixirSuite__Current_Patient_Name__c,
                                                                   ElixirSuite__Group_Name__c,ElixirSuite__Group_Name__r.Name
                                                                     FROM ElixirSuite__Group_Patient__c 
                                                                     where ElixirSuite__Group_Name__c IN:patientGroupIds
                                                                     WITH SECURITY_ENFORCED];
            if(groupPatientIds.size() >0 && groupPatientIds != null){
                for(Group_Patient__c groupRec : groupPatientIds){
                    accIds.add(groupRec.ElixirSuite__Current_Patient_Name__c);
                    groupName.put(groupRec.ElixirSuite__Group_Name__c, groupRec.ElixirSuite__Group_Name__r.Name);
                    
                }
            }
            system.debug('accIds'+accIds);
            system.debug('groupName'+groupName);
            if(accIds.size() >0 && accIds != null){
                existingRecords = [SELECT Id, WhatId, Subject, StartDateTime, EndDateTime, 
                                   ElixirSuite__Location__c,ElixirSuite__Practitioner__c,ElixirSuite__By_Pass_Check__c,
                                   AccountId, ElixirSuite__Status__c, ElixirSuite__Parent_Event_Id__c
                                   FROM Event 
                                   where AccountId IN: accIds
                                   WITH SECURITY_ENFORCED];
                
            }
            if(existingRecords != null && existingRecords.size() >0){
                for(Event newRec : lstEvent ){  
                    system.debug('newRecvalll+++++'+newRec.ElixirSuite__Parent_Event_Id__c);
                    
                	for(Event existingRec :existingRecords){
                        if(newRec.By_Pass_Check__c != true){
                            if(newRec.ElixirSuite__Parent_Event_Id__c == null)
                            {
                                if((newRec.StartDateTime >= existingRec.StartDateTime && newRec.StartDateTime <= existingRec.EndDateTime) || 
                                   (newRec.EndDateTime >= existingRec.StartDateTime && newRec.EndDateTime <= existingRec.EndDateTime) ||
                                   (existingRec.StartDateTime >= newRec.StartDateTime && existingRec.StartDateTime <= newRec.EndDateTime)  ||
                                   (existingRec.EndDateTime >= newRec.StartDateTime && existingRec.EndDateTime <= newRec.EndDateTime))
                                {
                                    newRec.addError(groupName.get(newRec.WhatId) +' Group not available for the requested time frame');
                                }
                            }
                            
                        }
                        
                    }
                }
                
                
            }
            
        }
        
    }

    public static void calculateNextAvailSlot(List<Event> lstEvent,Map<Id,Event> oldWorkScheduleMap){
        
        Set<String> juncPracLst = new Set<String>();
        Set<String> juncLocLst = new Set<String>();
        
        try{
        for(Event ev : lstEvent){
            juncPracLst.add(String.valueof(ev.ElixirSuite__Practitioner__c));
            juncLocLst.add(String.valueof(ev.ElixirSuite__Location__c));
            if (oldWorkScheduleMap != null && !oldWorkScheduleMap.isEmpty()) {
                juncLocLst.add(String.valueof(oldWorkScheduleMap.get(ev.Id).ElixirSuite__Location__c));
                juncPracLst.add(String.valueof(oldWorkScheduleMap.get(ev.Id).ElixirSuite__Practitioner__c));
            }
        }

        List<String> pracStrings1 = new List<String>(juncPracLst);
        List<String> locStrings1 = new List<String>(juncLocLst);
            
        eventTriggerHandler.createSlots(pracStrings1,locStrings1);
        
    }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        
    }
    
    @future(callout=true)
    public static void createSlots(List<String> pracStrings,List<String> locStrings){
        
        Date startDate1 = system.today();
        try{
        Elixir_Utility.Wrapper3 appointmentTyp1 = Elixir_Utility.getBulkAppointmentType(pracStrings,locStrings,startDate1);
        Map<String,String> pracLocVsAppTyp = appointmentTyp1.pracLocVsAptTyp;
        List<String> appTypLst = appointmentTyp1.appTypLstWrp;
        
        Map<String,String> pracMap = new Map<String,String>();
        pracMap = Elixir_Utility.bulkWorkslot(pracStrings,locStrings,startDate1,appTypLst,pracLocVsAppTyp);
        
        List<ElixirSuite__UserLocation__c> juncLst = [SELECT Id, Name, ElixirSuite__Practitioner__c, 
                                                      ElixirSuite__Provider__c, ElixirSuite__Next_available_slot__c 
                                                      FROM ElixirSuite__UserLocation__c
                                                      WHERE ElixirSuite__Practitioner__c IN : pracStrings
                                                      AND ElixirSuite__Provider__c IN : locStrings
                                                      WITH SECURITY_ENFORCED];
        
        for(ElixirSuite__UserLocation__c juncRec : juncLst){
            String finalKey = String.valueof(juncRec.ElixirSuite__Practitioner__c) + String.valueof(juncRec.ElixirSuite__Provider__c);
            if(String.isNotBlank(pracMap.get(finalKey)) && String.isNotEmpty(pracMap.get(finalKey))){
                juncRec.ElixirSuite__Next_available_slot__c = pracMap.get(finalKey);
            }
            else{
                juncRec.ElixirSuite__Next_available_slot__c = 'No Slots';
            }
        }
        
        DMLManager.updateAsUser(juncLst);
    }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        
    }

    //added by Anmol for LX3-8779
    public static void deleteChildRecords(List<Event> lstEvent){
        
        Set<Id> lstEventId = new Set<Id>();
        
        for(Event event : lstEvent) {
            if(event.WhatId != null){
                String relatedObjectName = event.WhatId.getSObjectType().getDescribe().getName();
                if(relatedObjectName == 'ElixirSuite__Account_Group__c'){
                    lstEventId.add(event.Id);
                }
            }
        }
        
        if(lstEventId.size() >0 && lstEventId != null){
            List<Event> childEventLst = [SELECT
                                         Id,
                                         ElixirSuite__Form_Unique_Id__c,
                                         ElixirSuite__Parent_Event_Id__c,
                                         ElixirSuite__Attendance__c
                                         FROM Event
                                         WHERE ElixirSuite__Parent_Event_Id__c=:lstEventId
                                         AND ElixirSuite__Form_Unique_Id__c=NULL
                                         WITH SECURITY_ENFORCED];
            
            if(childEventLst.size() >0 && childEventLst != null){
                DMLManager.deleteAsUser(childEventLst);
            }
            
        }
        
    }
    
    public static void beforeDeleteCheckSessionNotes(List<Event> lstEvent){
        System.debug('beforeDeleteCheckSessionNotes line 75');
        Set<Id> lstEventId = new Set<Id>();
        
        for(Event event : lstEvent) {
            if(event.WhatId != null){
                String relatedObjectName = event.WhatId.getSObjectType().getDescribe().getName();
                if(relatedObjectName == 'ElixirSuite__Account_Group__c'){
                    lstEventId.add(event.Id);
                }
            }
        }
        
        if(lstEventId.size() >0 && lstEventId != null){
            List<Event> childEventLst = [SELECT
                                         Id,
                                         ElixirSuite__Form_Unique_Id__c,
                                         ElixirSuite__Parent_Event_Id__c,
                                         ElixirSuite__Attendance__c
                                         FROM Event
                                         WHERE ElixirSuite__Parent_Event_Id__c=:lstEventId
                                         AND ElixirSuite__Form_Unique_Id__c!=NULL
                                         WITH SECURITY_ENFORCED];
            
            System.debug('childEventLst'+childEventLst);
            Map<String,String> parentVsChild = new Map<String,String>();
            
            if(childEventLst.size() >0 && childEventLst != null){
                for(Event ev : childEventLst){
                    parentVsChild.put(ev.ElixirSuite__Parent_Event_Id__c,ev.Id);
                }
            }
            
            System.debug('parentVsChild'+parentVsChild);
            
            for(Event ev : lstEvent) {
                
                if(parentVsChild!=null && parentVsChild.containsKey(ev.Id)){
                    System.debug('inside if 111');
                    ev.addError('There are existing session notes for this event.');
                }
                
            }
        }
        
        
    }
    //end by Anmol for LX3-8779
    
     public static void duplicateRecordsUpdate(List<Event> lstEvent, Map< id,Event> oldEventMap){
          system.debug('oldEventMap+++'+oldEventMap);
        Set<Id> patientGroupIds = new Set<Id>();
        Set<Id> accIds = new Set<Id>();
        List<Event> existingRecords = new List<Event>();
        Map<Id, string> groupName = new Map<Id, string>();
        
        for(Event event : lstEvent) {
            if(event.WhatId != null){
                 String relatedObjectName = event.WhatId.getSObjectType().getDescribe().getName();
            	if(relatedObjectName == 'ElixirSuite__Account_Group__c' && event.ElixirSuite__Parent_Event_Id__c == null &&
                   event.OwnerId == (oldEventMap.get(event.id)).OwnerId){
                patientGroupIds.add(event.WhatId);
            }
            }
           
        }
        if(patientGroupIds.size() >0 && patientGroupIds != null){
            List<ElixirSuite__Group_Patient__c> groupPatientIds = [SELECT Id, Name, ElixirSuite__Current_Patient_Name__c,
                                                                   ElixirSuite__Group_Name__c,ElixirSuite__Group_Name__r.Name
                                                                     FROM ElixirSuite__Group_Patient__c 
                                                                     where ElixirSuite__Group_Name__c IN:patientGroupIds
                                                                     WITH SECURITY_ENFORCED];
            if(groupPatientIds.size() >0 && groupPatientIds != null){
                for(Group_Patient__c groupRec : groupPatientIds){
                    accIds.add(groupRec.ElixirSuite__Current_Patient_Name__c);
                    groupName.put(groupRec.ElixirSuite__Group_Name__c, groupRec.ElixirSuite__Group_Name__r.Name);
                    
                }
            }
            
            if(accIds.size() >0 && accIds != null){
                existingRecords = [SELECT Id, WhatId, Subject, StartDateTime, EndDateTime, 
                                   ElixirSuite__Location__c,ElixirSuite__Practitioner__c,ElixirSuite__By_Pass_Check__c,
                                   AccountId, ElixirSuite__Status__c ,ElixirSuite__Parent_Event_Id__c 
                                   FROM Event
                                   where AccountId IN: accIds
                                   WITH SECURITY_ENFORCED];
                
            }
            if(existingRecords != null && existingRecords.size() >0){
                for(Event newRec : lstEvent ){
                    system.debug('newRec+++'+newRec.id);
                    if(oldEventMap == null || newRec.StartDateTime != (oldEventMap.get(newRec.Id)).StartDateTime || newRec.EndDateTime != (oldEventMap.get(newRec.Id)).EndDateTime){
                	for(Event existingRec :existingRecords){
                        if(newRec.By_Pass_Check__c != true){
                            if(newRec.id != existingRec.ElixirSuite__Parent_Event_Id__c){
                                   if(((newRec.StartDateTime >= existingRec.StartDateTime && newRec.StartDateTime <= existingRec.EndDateTime) || 
                                   (newRec.EndDateTime >= existingRec.StartDateTime && newRec.EndDateTime <= existingRec.EndDateTime) ||
                                   (existingRec.StartDateTime >= newRec.StartDateTime && existingRec.StartDateTime <= newRec.EndDateTime)  ||
                                   (existingRec.EndDateTime >= newRec.StartDateTime && existingRec.EndDateTime <= newRec.EndDateTime)) 
                                     )
                                {
                                    System.debug('Inside If');
                                    newRec.addError(groupName.get(newRec.WhatId) +' Group not available for the requested time frame');
                                } 
                            }
                            
                        }
                        
                    }
                }
                }
                
                
            }
            
        }
        
    }
     public static void preventAppointmentViaEdit(List<Event> newEvents, Map<Id, Event> oldEventMap) {
        for (Event event : newEvents) {
            Event oldEvent = oldEventMap.get(event.Id);
            if (event.ElixirSuite__Appointment_created_via__c != oldEvent.ElixirSuite__Appointment_created_via__c) {
                 event.addError('Appointment created via field is not editable.');
            }
        }
    }
    public static void saveRecord(List<Event> lstEvent){
        system.debug('saveRecord'+lstEvent[0].id);
        Set<Id> patientGroupIds = new Set<Id>();
        Set<Id> accIds = new Set<Id>();
        Set<Id> whoIds = new Set<Id>();
        Set<Id> eventIds = new Set<Id>();
        Map<Id, Event> eventMap = new Map<Id, Event>();
        List<Contact> conName  = new List<Contact>();
        Map<Id, Id> contactMap = new Map<Id, Id>();
        Map<Id,Set<Id>> accIdMap = new Map<Id,Set<Id>>();
        for(Event event : lstEvent) {
            if(event.WhatId != null){
                 String relatedObjectName = event.WhatId.getSObjectType().getDescribe().getName();
            	if(relatedObjectName == 'ElixirSuite__Account_Group__c'){
                patientGroupIds.add(event.WhatId);
                eventIds.add(event.id);
                whoIds.add(event.WhoId);    
             }
            }
        }
        if(patientGroupIds.size() >0 && patientGroupIds != null){
            List<ElixirSuite__Group_Patient__c> groupPatientIds = [SELECT Id, Name, ElixirSuite__Current_Patient_Name__c,
                                                                   ElixirSuite__Group_Name__c,ElixirSuite__Group_Name__r.Name
                                                                     FROM ElixirSuite__Group_Patient__c 
                                                                     where ElixirSuite__Group_Name__c IN:patientGroupIds
                                                                     WITH SECURITY_ENFORCED];
            if(groupPatientIds.size() >0 && groupPatientIds != null){
                system.debug('groupPatientIds'+groupPatientIds);
                for(Group_Patient__c groupRec : groupPatientIds){
                    if(accIdMap.containsKey(groupRec.ElixirSuite__Group_Name__c)){
                        accIdMap.get(groupRec.ElixirSuite__Group_Name__c).add(groupRec.ElixirSuite__Current_Patient_Name__c);
                    }
                    else{
                        accIds =new Set<Id>();
                        accIds.add(groupRec.ElixirSuite__Current_Patient_Name__c);
                        accIdMap.put(groupRec.ElixirSuite__Group_Name__c,accIds);
                    }                    
                }
            }
            if(whoIds.size() > 0 && whoIds!= null){
                conName = [SELECT Id, Name, ElixirSuite__Practitioner_User__c 
                                                         FROM Contact 
                                                         where id =: whoIds 
                                                         WITH SECURITY_ENFORCED];
                for(Contact con : conName){
                    contactMap.put(con.id,con.ElixirSuite__Practitioner_User__c);
                }
            } 
            
            List<Event> eventRec = new List<Event>(); 
            if(eventIds.size() > 0 && eventIds!= null){
                eventRec = [SELECT Id, WhatId, WhoId,OwnerId ,Subject, StartDateTime, EndDateTime, 
                        ElixirSuite__Location__c,ElixirSuite__Practitioner__c,ElixirSuite__By_Pass_Check__c,
                        IsRecurrence2,AccountId, ElixirSuite__Status__c ,ElixirSuite__Parent_Event_Id__c 
                        FROM Event 
                        where id IN: eventIds
                        WITH SECURITY_ENFORCED];
                for(Event ev : eventRec){
                    eventMap.put(ev.id, ev);
                }
            } 
            
            List<Event> lstEventRec = new List<Event>(); 
            List<Event> recordsToUpdate = new List<Event>();
             if(accIds.size() >0 && accIds != null){
                 for(Event newRec : lstEvent){
                     if(newRec.WhoId != null){
                                 id patUserid = contactMap.get(newRec.WhoId);
                                 Event evRec =  eventMap.get(newRec.id);
                                 if(patUserid != null && evRec != null && evRec.OwnerId != patUserid){
                                     system.debug('Inside user');
                         			 evRec.OwnerId = patUserid;
                                     recordsToUpdate.add(evRec);
                                 }
                                
                     }  
                     if(newRec.WhatId != null && newRec.ElixirSuite__Parent_Event_Id__c == null ){
                         String relatedObjectName = newRec.WhatId.getSObjectType().getDescribe().getName();
                         if(relatedObjectName == 'ElixirSuite__Account_Group__c'){
                             Set<Id> groupPatientRecIds = accIdMap.get(newRec.WhatId);
                             for(Id patientId : groupPatientRecIds){
                                 Event objevent1 = new Event();
                                 //objevent = newRec.clone(false, true, false, false); // clone the event object
                                objevent1.StartDateTime = newRec.StartDateTime;
                                objevent1.EndDateTime = newRec.EndDateTime;
                                objevent1.WhatId = patientId;
                                 objevent1.WhoId = newRec.WhoId;
                                objevent1.ElixirSuite__Location__c = newRec.ElixirSuite__Location__c;
                                objevent1.ElixirSuite__Status__c =newRec.ElixirSuite__Status__c;
                                objevent1.ElixirSuite__Practitioner__c=newRec.ElixirSuite__Practitioner__c;                                
								objevent1.OwnerId= newRec.OwnerId;
                                objevent1.Subject = newRec.Subject;
                                objevent1.ElixirSuite__By_Pass_Check__c = newRec.ElixirSuite__By_Pass_Check__c;
                                objevent1.ElixirSuite__Parent_Event_Id__c = newRec.Id;
                                 lstEventRec.add(objevent1);
                                 system.debug('objevent1'+objevent1);
                           }
                             
                           
                 		}
                     }
                     
                 }
                 DMLManager.insertAsUser(lstEventRec);
                 DMLManager.UpdateAsUser(recordsToUpdate);
             }
            
            
        }
    }
    
    public static void saveRecordUpdate(List<Event> lstEvent){
        Set<Id> patientGroupIds = new Set<Id>();
        Set<Id> accIds = new Set<Id>();
        Set<Id> patIds = new Set<Id>();
        Set<Id> patEventIds = new Set<Id>();
        Map<Id,Set<Id>> accIdMap = new Map<Id,Set<Id>>();
        List<Event> existingRecords = new List<Event>();
        for(Event event : lstEvent) {
            if(event.WhatId != null){
                 String relatedObjectName = event.WhatId.getSObjectType().getDescribe().getName();
            	if(relatedObjectName == 'ElixirSuite__Account_Group__c' && event.ElixirSuite__Parent_Event_Id__c == null){
                patientGroupIds.add(event.WhatId);
                patEventIds.add(event.Id);    
             }
            }
        }
        if(patientGroupIds.size() >0 && patientGroupIds != null){
            List<ElixirSuite__Group_Patient__c> groupPatientIds = [SELECT Id, Name, ElixirSuite__Current_Patient_Name__c,
                                                                   ElixirSuite__Group_Name__c,ElixirSuite__Group_Name__r.Name
                                                                     FROM ElixirSuite__Group_Patient__c 
                                                                     where ElixirSuite__Group_Name__c IN:patientGroupIds
                                                                     WITH SECURITY_ENFORCED];
            if(groupPatientIds.size() >0 && groupPatientIds != null){
                system.debug('groupPatientIds'+groupPatientIds);
                for(Group_Patient__c groupRec : groupPatientIds){
                    patIds.add(groupRec.ElixirSuite__Current_Patient_Name__c);
                    
                }
            }
            if(patEventIds.size() >0 && patEventIds != null){
                existingRecords = [SELECT Id, WhatId, WhoId,OwnerId ,Subject, StartDateTime, EndDateTime, 
                                   ElixirSuite__Location__c,ElixirSuite__Practitioner__c,ElixirSuite__By_Pass_Check__c,
                                   IsRecurrence2,AccountId, ElixirSuite__Status__c ,ElixirSuite__Parent_Event_Id__c 
                                   FROM Event 
                                   where ElixirSuite__Parent_Event_Id__c IN: patEventIds
                                   WITH SECURITY_ENFORCED];
                
            }
             if(existingRecords.size() >0 && existingRecords != null){
                 for(Event newRec : lstEvent){
                     if(newRec.WhatId != null){
                         String relatedObjectName = newRec.WhatId.getSObjectType().getDescribe().getName();
                         if(relatedObjectName == 'ElixirSuite__Account_Group__c' ){
                             for(Event existingRec : existingRecords){
                                 if(newRec.id == existingRec.ElixirSuite__Parent_Event_Id__c){
                                     existingRec.StartDateTime = newRec.StartDateTime;
                                     existingRec.EndDateTime = newRec.EndDateTime;
                                     existingRec.ElixirSuite__Location__c = newRec.ElixirSuite__Location__c;
                                     existingRec.ElixirSuite__Status__c = newRec.ElixirSuite__Status__c;
                                     //existingRec.OwnerId= newRec.OwnerId;
                                     existingRec.Subject = newRec.Subject;
                                 }
                                 
                             }
                            
                 		}
                     }
                     
                 }
                 DMLManager.updateAsUser(existingRecords);
                 
             }
            
            
        }
    }

}
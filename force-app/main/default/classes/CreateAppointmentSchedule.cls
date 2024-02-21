public with sharing class CreateAppointmentSchedule {
    /*public static boolean doUpdate=true;
    
    public static void markByPassCheck(Event[] newEventRecords){
        
        // It will mark the By Pass check box true if startdate or enddate changes on standard screen when creating new appointment.
        Set<Id> setOfEventDataObjectId = new set<Id>();
        List<Event> eventToBeUpdated = new List<Event>();
        
        Map<Id,ElixirSuite__Event_Data_Object__c> mapOfEventDataObjectLst = new Map<Id,ElixirSuite__Event_Data_Object__c>();
        for(Event eventRecord: newEventRecords){
            
            if(!String.isBlank(eventRecord.ElixirSuite__Event_Data_Object__c)){
                if(eventRecord.ElixirSuite__Is_custom_screen__c){
                    setOfEventDataObjectId.add(eventRecord.ElixirSuite__Event_Data_Object__c);
                }
            }
        }
        
        if(setOfEventDataObjectId.size() >0){
            
            mapOfEventDataObjectLst = new Map<Id,ElixirSuite__Event_Data_Object__c>([Select id,ElixirSuite__By_Pass_Check__c,ElixirSuite__Start_Date_Time__c,ElixirSuite__End_Date_and_Time__c from ElixirSuite__Event_Data_Object__c where Id IN:setOfEventDataObjectId WITH SECURITY_ENFORCED]);
        }
        
        for(Event eventRecord: newEventRecords){
            
            ElixirSuite__Event_Data_Object__c eventDataRecord = mapOfEventDataObjectLst.get(eventRecord.ElixirSuite__Event_Data_Object__c);
            system.debug('ec' +eventDataRecord);
            if(!eventRecord.IsRecurrence2){
                if(eventDataRecord!=null){
                    if((eventRecord.StartDateTime!= eventDataRecord.ElixirSuite__Start_Date_Time__c) || (eventRecord.EndDateTime!=eventDataRecord.ElixirSuite__End_Date_and_Time__c)){
                        eventRecord.ElixirSuite__By_Pass_Check__c = true;
                        
                        eventToBeUpdated.add(eventRecord);
                    }
                }
            }
            
        }
        system.debug('eventToBeUpdated'+eventToBeUpdated.size());
        system.debug('eventToBeUpdated'+eventToBeUpdated);
        
    }
    
    public static void createAppointments(Event[] newEventLst){
        
        String patients;
        List<String> patientList;
        String groups;
        List<String> groupList;
        String coFacilitators;
        List<String> coFacilitatorList;
        String bussinessAccounts;
        List<String> bussinessAccountList;
        String equipments;
        List<Equip> equipList;
        
        Set<String> patientsIds;
        Set<String> groupIds;
        Set<String> userIds;
        Set<String> bussinessAccountIds;
        Set<String> roomIds = new Set<String>();
        String room;
        String assignedTo; 
        Map<String,Integer> mapOfEquipIdToNeededQuantity = new Map<String,Integer>();
        //(List<String>) JSON.deserializeStrict(patients,List<String>.class);
        
        List<Event> eventToBeUpdated = new List<Event>();
        List<Event> eventToBeInserted = new List<Event>();
        
        Map<Id,ElixirSuite__Event_Data_Object__c> mapOfEventDataObject = new Map<Id,ElixirSuite__Event_Data_Object__c>();
        Map<Id,Id> mapOfEventIdToEventDataObjectId = new Map<Id,Id>();
        Set<Id> setOfEventData = new Set<Id>();
        integer eventCount =0;
        DateTime startdate;
        DateTime enddate;
        Set<Id> eventIds = new Set<Id>();
        List<Event> eventsToBeCloned = new List<Event>();
        boolean byPassCheck;
        String eventDataRecordSFId;
        system.debug('eventRecordSize'+ newEventLst.size());
        event firstEvent;
        for(Event eventRecord: newEventLst){
             system.debug('eventRecord'+eventRecord.id);
            system.debug('eventRecord'+eventRecord.ElixirSuite__Event_Data_Object__c);
            system.debug('eventRecord'+eventRecord.ElixirSuite__Is_custom_screen__c);
            
            if(!String.isBlank(eventRecord.ElixirSuite__Event_Data_Object__c)){
                if(eventRecord.ElixirSuite__Is_custom_screen__c){
                    eventDataRecordSFId = eventRecord.ElixirSuite__Event_Data_Object__c;
                    setOfEventData.add(eventRecord.ElixirSuite__Event_Data_Object__c);
                    
                    eventCount++;
                    startdate = eventRecord.StartDateTime;
                    enddate = eventRecord.EndDateTime;
                    eventIds.add(eventRecord.id);
                    byPassCheck= eventRecord.ElixirSuite__By_Pass_Check__c;
                    //eventsToBeCloned.add(eventRecord);
                }
                
            }
            
        }
        List<Event> eclist = new List<Event>();
           eclist= [Select id,WhoId from Event where ElixirSuite__Event_Data_Object__c IN: setOfEventData AND ElixirSuite__Is_custom_screen__c=true WITH SECURITY_ENFORCED];
        system.debug('eclist'+ eclist.size());
        system.debug('eclist'+ eclist);
        if(eclist.size() >0){
            firstEvent = eclist[0];
        }
        
        eventsToBeCloned = [Select id,WhoId,Subject,StartDateTime,EndDateTime,WhatId,OwnerId,Description,ElixirSuite__Reason__c,ElixirSuite__By_Pass_Check__c,IsAllDayEvent,ElixirSuite__Event_Data_Object__c,Location,RecurrenceStartDateTime,IsRecurrence,RecurrenceEndDateOnly,RecurrenceType,RecurrenceInterval,Recurrence2PatternText from Event where Id IN: eventIds WITH SECURITY_ENFORCED];
        system.debug('eventCount'+eventCount);
        system.debug('eventsToBeCloned'+eventsToBeCloned.size());
        if(eventsToBeCloned.size() >0 && eventsToBeCloned!=null){ 
            if(setOfEventData.size() >0){
                mapOfEventDataObject = new Map<Id,ElixirSuite__Event_Data_Object__c>([Select id,ElixirSuite__Assigned_To__c,ElixirSuite__AllUsers__c,ElixirSuite__EquipmentLineItems__c,ElixirSuite__IndirectRooms__c,ElixirSuite__By_Pass_Check__c,ElixirSuite__All_Day_event__c,ElixirSuite__End_Date_and_Time__c,ElixirSuite__Start_Date_Time__c,
                                                                                      ElixirSuite__Rooms__c,ElixirSuite__Related_Business_Accounts__c,ElixirSuite__Patients__c,ElixirSuite__Patient_Groups__c,ElixirSuite__Co_Facilitators__c from ElixirSuite__Event_Data_Object__c where Id IN: setOfEventData]);
                
                if(mapOfEventDataObject.size() >0){
                    patientList = new List<String>();
                    groupList = new List<String>();
                    coFacilitatorList = new List<String>();
                    bussinessAccountList = new List<String>();
                    patientsIds = new  Set<String>();
                    groupIds = new  Set<String>();
                    userIds = new  Set<String>();
                    bussinessAccountIds = new  Set<String>();
                    for(Id eventDataRecordId: mapOfEventDataObject.keySet()){
                        patients = mapOfEventDataObject.get(eventDataRecordId).ElixirSuite__Patients__c;
                        groups = mapOfEventDataObject.get(eventDataRecordId).ElixirSuite__Patient_Groups__c;
                        coFacilitators = mapOfEventDataObject.get(eventDataRecordId).ElixirSuite__Co_Facilitators__c;
                        bussinessAccounts = mapOfEventDataObject.get(eventDataRecordId).ElixirSuite__Related_Business_Accounts__c;
                        room = mapOfEventDataObject.get(eventDataRecordId).ElixirSuite__Rooms__c;
                        assignedTo = mapOfEventDataObject.get(eventDataRecordId).ElixirSuite__Assigned_To__c;
                                              
                                                
                        if(!String.isBlank(patients)){
                            patientList = (List<String>)JSON.deserializeStrict(patients,List<String>.class);
                            for(String pt: patientList){
                                patientsIds.add(pt);
                            }
                        }
                        system.debug('patientsIds'+patientsIds);
                        if(!String.isBlank(groups)){
                            groupList = (List<String>)JSON.deserializeStrict(groups,List<String>.class);
                            for(String pt: groupList){
                                groupIds.add(pt);
                            }
                            patientsIds.addAll(getPatientsFromGroup(groupIds));
                            
                        }
                        system.debug('patientsIds'+patientsIds);
                        if(!String.isBlank(coFacilitators)){
                            coFacilitatorList = (List<String>)JSON.deserializeStrict(coFacilitators,List<String>.class);
                            
                            for(String pt: coFacilitatorList){
                                userIds.add(pt);
                            }
                        }
                        
                        if(!String.isBlank(bussinessAccounts)){
                            bussinessAccountList = (List<String>)JSON.deserializeStrict(bussinessAccounts,List<String>.class);
                            
                            for(String pt: bussinessAccountList){
                                bussinessAccountIds.add(pt);
                            }
                        }
                        
                        if(!String.isBlank(assignedTo)){
                            //userIds.add(assignedTo);
                        }
                        
                        if(!String.isBlank(equipments)){
                            
                            equipList = (List<Equip>) JSON.deserializeStrict(equipments,List<Equip>.class);
                            
                            for(Equip pt: equipList){  
                                
                                if(!String.isBlank(pt.Id) && !String.isBlank(pt.EquipmentNeed)){
                                    mapOfEquipIdToNeededQuantity.put(pt.Id, Integer.valueOf(pt.EquipmentNeed));
                                }
                                else if(!String.isBlank(pt.Id)){
                                    mapOfEquipIdToNeededQuantity.put(pt.Id, 0);
                                }
                                
                            }
                            system.debug('ee3'+mapOfEquipIdToNeededQuantity);
                        }
                    }
                }
            }
            
            Map<String,Set<String>> eventKeyToEquipLineItemSet = new Map<String,Set<String>>();
            Set<String> EquipmentLineItemsId = new Set<String>();
            Set<String> allEquipmentLineItemsIds = new Set<String>();
            Set<ElixirSuite__Equipment_Line_Item__c> setOfEquipmentLineItems = new Set<ElixirSuite__Equipment_Line_Item__c>();
            String timekey;
            if(String.isBlank(room) && mapOfEquipIdToNeededQuantity.size() >0){
                
                for(String equipId: mapOfEquipIdToNeededQuantity.keySet()){
                    for(Event cloneRecord: eventsToBeCloned){
                        timekey = cloneRecord.StartDateTime + '_' + cloneRecord.EndDateTime;
                        
                        EquipmentLineItemsId = getEquipmentLineItemsIdForEquipment(equipId,mapOfEquipIdToNeededQuantity.get(equipId),cloneRecord.StartDateTime,cloneRecord.EndDateTime,byPassCheck);
                        eventKeyToEquipLineItemSet.put(timekey, EquipmentLineItemsId);
                        allEquipmentLineItemsIds.addAll(EquipmentLineItemsId);
                    }
                    
                }
                
                if(allEquipmentLineItemsIds.size() >0){
                    for(ElixirSuite__Equipment_Line_Item__c eqlineItem: [Select id,Name,ElixirSuite__Room_No__c from ElixirSuite__Equipment_Line_Item__c where ID IN: allEquipmentLineItemsIds WITH SECURITY_ENFORCED]){
                        if(eqlineItem.ElixirSuite__Room_No__c!=null){
                            roomIds.add(eqlineItem.ElixirSuite__Room_No__c);
                        }
                        system.debug('roomIds'+roomIds);
                        // EquipmentLineItemsId.add(eqlineItem.id);
                    }
                    
                }
                
            }else if(!String.isBlank(room) && mapOfEquipIdToNeededQuantity.size()== 0){
                
                system.debug('roomIds'+room);
                for(Event cloneRecord: eventsToBeCloned){
                    timekey = cloneRecord.StartDateTime + '_' + cloneRecord.EndDateTime;
                    EquipmentLineItemsId = getEquipmentLineItemsId(room,cloneRecord.StartDateTime,cloneRecord.EndDateTime,byPassCheck);
                    eventKeyToEquipLineItemSet.put(timekey, EquipmentLineItemsId);
                }
                
                roomIds.add(room);
                
                
            }else if(!String.isBlank(room) && mapOfEquipIdToNeededQuantity.size() >0){
                system.debug('room'+room);
                system.debug('mapOfEquipIdToNeededQuantity'+mapOfEquipIdToNeededQuantity);
                
                roomIds.add(room);
                
                
              /*  for(String equipId: mapOfEquipIdToNeededQuantity.keySet()){
                    for(Event cloneRecord: eventsToBeCloned){
                        timekey = cloneRecord.StartDateTime + '_' + cloneRecord.EndDateTime;
                        EquipmentLineItemsId = getEquipmentLineItemsWithSelectedRoom(equipId,mapOfEquipIdToNeededQuantity.get(equipId),room,cloneRecord.StartDateTime,cloneRecord.EndDateTime,byPassCheck);
                       system.debug('EquipmentLineItemsId'+EquipmentLineItemsId);
                        eventKeyToEquipLineItemSet.put(timekey, EquipmentLineItemsId);
                        allEquipmentLineItemsIds.addAll(EquipmentLineItemsId);
                    }
                    
                }
                if(allEquipmentLineItemsIds.size() >0){
                    for(ElixirSuite__Equipment_Line_Item__c eqlineItem: [Select id,Name,ElixirSuite__Room_No__c from ElixirSuite__Equipment_Line_Item__c where ID IN: allEquipmentLineItemsIds WITH SECURITY_ENFORCED]){
                        if(eqlineItem.ElixirSuite__Room_No__c!=null){
                            roomIds.add(eqlineItem.ElixirSuite__Room_No__c);
                        }
                        system.debug('roomIds'+roomIds);
                        // EquipmentLineItemsId.add(eqlineItem.id);
                    }
                    
                }
            }
            
            
            string firstPatientElement;
            if(patientsIds.size() >0 && patientsIds!=null){
                firstPatientElement =(new list<string>(patientsIds))[0];
            }
            Event eventRecordTobeCloned;
            
            List<Event> eventLstToBeUpdated = new List<Event>();
            // update event what id of newly created event
            for(Event eventRecord: eventsToBeCloned){
                
                if(firstPatientElement!=null){
                   
                    eventRecord.WhatId = firstPatientElement;
                    
                    eventLstToBeUpdated.add(eventRecord);
                    system.debug('patientUpdatecloneBypass '+eventRecord.WhoId);
                }
            }
            system.debug('eventLstToBeUpdated'+eventLstToBeUpdated.size());
            
            patientsIds.remove(firstPatientElement);    
            system.debug('patientsIds'+patientsIds.size());
            // create event for patients
            if(patientsIds.size() >0){
                for(String patientId: patientsIds){
                    
                    for(Event cloneRecord: eventsToBeCloned){
                        Event newEvent = cloneRecord.clone(false, false, false, false);
                        newEvent.WhatId = patientId;
                        newEvent.Description = cloneRecord.Description;
                        newEvent.ElixirSuite__By_Pass_Check__c = cloneRecord.ElixirSuite__By_Pass_Check__c;
                        newEvent.IsAllDayEvent = cloneRecord.IsAllDayEvent;
                        newEvent.OwnerId = cloneRecord.OwnerId;
                        newEvent.WhoId = cloneRecord.WhoId;
                        newEvent.ElixirSuite__Reason__c= cloneRecord.ElixirSuite__Reason__c;
                        newEvent.ElixirSuite__Event_Data_Object__c = cloneRecord.ElixirSuite__Event_Data_Object__c;
                        eventToBeInserted.add(newEvent);
                         system.debug('patientcloneBypass '+cloneRecord.WhoId);
                    }
                }
            }
            
            system.debug('eventToBeInserted'+eventToBeInserted.size());
            //create event for groups
            if(groupIds.size() >0){
                for(String groupId: groupIds){
                    for(Event cloneRecord: eventsToBeCloned){
                        Event newEvent = cloneRecord.clone(false, false, false, false);
                        newEvent.WhatId = groupId;
                        newEvent.OwnerId = cloneRecord.OwnerId;
                        newEvent.Description = cloneRecord.Description;
                        newEvent.ElixirSuite__By_Pass_Check__c = cloneRecord.ElixirSuite__By_Pass_Check__c;
                        newEvent.IsAllDayEvent = cloneRecord.IsAllDayEvent;
                        newEvent.WhoId = firstEvent.WhoId;
                         newEvent.ElixirSuite__Reason__c= cloneRecord.ElixirSuite__Reason__c;
                        newEvent.ElixirSuite__Event_Data_Object__c = cloneRecord.ElixirSuite__Event_Data_Object__c;
                        eventToBeInserted.add(newEvent);
                    }
                }
            }
            
            system.debug('groupIds'+groupIds.size());
            system.debug('eventToBeInserted'+eventToBeInserted.size());
            List<EventRelation> eventRelationToBeInserted = new List<EventRelation >();
            //create event for users
            if(userIds.size() >0){
                for(String userId: userIds){
                    for(Event cloneRecord: eventsToBeCloned){
                        
                        EventRelation  newRecord =  new EventRelation();
                        newRecord.IsInvitee = true;
                        newRecord.RelationId = userId;
                        newRecord.EventId = cloneRecord.Id;
                        eventRelationToBeInserted.add(newRecord);
                        // eventToBeInserted.add(newEvent);
                    }
                    
                }
            }
            
            system.debug('userIds'+userIds.size());
            system.debug('eventToBeInserted'+eventToBeInserted.size());
            //create event for business accounts
            if(bussinessAccountIds.size() >0){
                for(String accountId: bussinessAccountIds){
                    for(Event cloneRecord: eventsToBeCloned){
                        Event newEvent = cloneRecord.clone(false, false, false, false);
                        newEvent.WhatId = accountId;
                        newEvent.OwnerId = cloneRecord.OwnerId;
                        newEvent.Description = cloneRecord.Description;
                        newEvent.ElixirSuite__By_Pass_Check__c = cloneRecord.ElixirSuite__By_Pass_Check__c;
                        newEvent.IsAllDayEvent = cloneRecord.IsAllDayEvent;
                        newEvent.WhoId = firstEvent.WhoId;
                         newEvent.ElixirSuite__Reason__c= cloneRecord.ElixirSuite__Reason__c;
                        newEvent.ElixirSuite__Event_Data_Object__c = cloneRecord.ElixirSuite__Event_Data_Object__c;
                        eventToBeInserted.add(newEvent);
                    }
                }
            }
            
            system.debug('bussinessAccountIds'+bussinessAccountIds.size());
            system.debug('eventToBeInserted'+eventToBeInserted.size());
            system.debug('mmm'+mapOfEquipIdToNeededQuantity);
            
            
            // create event for EquipmentLineItems
            
            String mapEquipKey;
            Set<String> eqlineItemSetTemp = new Set<String> ();
            for(Event cloneRecord: eventsToBeCloned){
                mapEquipKey = cloneRecord.StartDateTime + '_' +cloneRecord.EndDateTime;
                system.debug('lineitems'+eventKeyToEquipLineItemSet);
                system.debug('lineitems'+eventKeyToEquipLineItemSet.keySet());
                system.debug('lineitems'+mapEquipKey);
                
                if(eventKeyToEquipLineItemSet.size() >0 && eventKeyToEquipLineItemSet.containsKey(mapEquipKey)){
                    if(eventKeyToEquipLineItemSet.get(mapEquipKey)!=null && eventKeyToEquipLineItemSet.get(mapEquipKey).size() >0){
                        system.debug('lineitems'+eventKeyToEquipLineItemSet.get(mapEquipKey));
                        for(String temp: eventKeyToEquipLineItemSet.get(mapEquipKey)){
                            Event newEvent = cloneRecord.clone(false, false, false, false);
                            newEvent.WhatId = temp;
                            newEvent.OwnerId = cloneRecord.OwnerId;
                            newEvent.Description = cloneRecord.Description;
                            newEvent.ElixirSuite__By_Pass_Check__c = cloneRecord.ElixirSuite__By_Pass_Check__c;
                            newEvent.IsAllDayEvent = cloneRecord.IsAllDayEvent;
                            newEvent.WhoId = firstEvent.WhoId;
                             newEvent.ElixirSuite__Reason__c= cloneRecord.ElixirSuite__Reason__c;
                            newEvent.ElixirSuite__Event_Data_Object__c = cloneRecord.ElixirSuite__Event_Data_Object__c;
                            eventToBeInserted.add(newEvent);
                             system.debug('LineItemcloneBypass '+cloneRecord.WhoId);
                            eqlineItemSetTemp.add(temp);
                        }
                    }
                }
                
            }
            
           
            
            Set<String> roomSetTemp = new Set<String> ();
            system.debug('EquipmentLineItemsId'+EquipmentLineItemsId.size());
            system.debug('eventToBeInserted'+eventToBeInserted.size());
            // create event for rooms
            if(roomIds.size() >0){
                for(String roomId: roomIds){
                    for(Event cloneRecord: eventsToBeCloned){
                        Event newEvent = cloneRecord.clone(false, false, false, false);
                        newEvent.WhatId = roomId;
                        newEvent.OwnerId = cloneRecord.OwnerId;
                        newEvent.Description = cloneRecord.Description; 
                        newEvent.ElixirSuite__By_Pass_Check__c = cloneRecord.ElixirSuite__By_Pass_Check__c;
                        newEvent.IsAllDayEvent = cloneRecord.IsAllDayEvent;
                        newEvent.WhoId = firstEvent.WhoId;
                        //below 7 lines added by Anmol
                        newEvent.Location = cloneRecord.Location;
                        newEvent.IsRecurrence = cloneRecord.IsRecurrence;
                        newEvent.RecurrenceStartDateTime = cloneRecord.RecurrenceStartDateTime;
                        newEvent.RecurrenceEndDateOnly = cloneRecord.RecurrenceEndDateOnly;
                        newEvent.RecurrenceType = cloneRecord.RecurrenceType;
                        newEvent.RecurrenceInterval = cloneRecord.RecurrenceInterval;
                        newEvent.Recurrence2PatternText = cloneRecord.Recurrence2PatternText;
                         newEvent.ElixirSuite__Reason__c= cloneRecord.ElixirSuite__Reason__c;
                        newEvent.ElixirSuite__Event_Data_Object__c = cloneRecord.ElixirSuite__Event_Data_Object__c;
                        eventToBeInserted.add(newEvent);
                         system.debug('roomcloneBypass '+cloneRecord.WhoId);
                        roomSetTemp.add(roomId);
                    }
                } 
            }
            
            String stringFormattedLineItems='';
            if(eqlineItemSetTemp.size() >0){
                for(String eline: eqlineItemSetTemp){
                   stringFormattedLineItems+=eline+',';
                }
                stringFormattedLineItems.removeEnd(',');
            }
            
            mapOfEventDataObject.get(eventDataRecordSFId).ElixirSuite__EquipmentLineItems__c = JSON.serialize(new List<String>(eqlineItemSetTemp));
            
            String stringFormattedRooms='';
            if(roomSetTemp.size() >0){
                for(String rm: roomSetTemp){
                   stringFormattedRooms+=rm+',';
                }
                stringFormattedRooms.removeEnd(','); 
            }
            
            mapOfEventDataObject.get(eventDataRecordSFId).ElixirSuite__IndirectRooms__c = JSON.serialize(new List<String>(roomSetTemp));
            
            mapOfEventDataObject.get(eventDataRecordSFId).ElixirSuite__AllUsers__c =JSON.serialize(new List<String>(userIds));
            system.debug('roomIds'+roomIds.size());
            system.debug('eventToBeInserted'+eventToBeInserted.size());
            
                if(eventToBeInserted.size() >0){
                    if (Schema.sObjectType.Event.isCreateable()) {
                    insert eventToBeInserted;
                }
            }
            
            system.debug('creamap1'+eventRelationToBeInserted.size());
            system.debug('creamap2'+eventRelationToBeInserted);
                if(eventRelationToBeInserted.size() >0){
                    if (Schema.sObjectType.EventRelation.isCreateable()) {
                    insert eventRelationToBeInserted;
                }
            }
           
                
            if (Schema.sObjectType.Event.isUpdateable())
            {
                if(eventLstToBeUpdated.size() >0 && doUpdate){

                    doUpdate = false;
                    if (Schema.sObjectType.Event.isUpdateable()){
                    update eventLstToBeUpdated;
                    system.debug('afterinsertcode'+doUpdate);
                    }
                }
            }
            
            if(mapOfEventDataObject.size() >0){
                update mapOfEventDataObject.values();
            }
            
        }
        
    }
    
    public static Set<String> getEquipmentLineItemsId(String roomId,DateTime startdate, DateTime endDate,boolean byPassCheck){
        
        Set<String> equipmentLineItemsId = new Set<String>();
        List<Event> eqLineItemEventList  = new List<Event>();
        Map<Id,ElixirSuite__Equipment_Line_Item__c> equipLineItemMap= new Map<Id,ElixirSuite__Equipment_Line_Item__c>([Select id,Name,ElixirSuite__Is_Under_Maintenance__c from ElixirSuite__Equipment_Line_Item__c where ElixirSuite__Room_No__c = : roomId AND ElixirSuite__Is_Under_Maintenance__c=false WITH SECURITY_ENFORCED]);
        for(Id equipId: equipLineItemMap.keySet()){
            equipmentLineItemsId.add(String.valueOf(equipId));
        }
        if(!byPassCheck){
            if(equipmentLineItemsId.size() >0){
                eqLineItemEventList = [Select id,subject,whatId,StartDateTime,EndDateTime from Event where whatId IN: equipLineItemMap.keySet() AND StartDateTime >=: startdate AND EndDateTime <=: endDate WITH SECURITY_ENFORCED];
                system.debug('eqLineItemEventList'+eqLineItemEventList.size());
                if(eqLineItemEventList.size() >0){
                    for(Event record: eqLineItemEventList){
                        if(equipmentLineItemsId.contains(record.whatId)){
                            
                            equipmentLineItemsId.remove(record.whatId);
                        }
                    }
                }
            }
        }
        
        
        return equipmentLineItemsId;
        
    }
    
    public static Set<String> getEquipmentLineItemsWithSelectedRoom(String equipmentsId,integer neededAmount,String roomId, DateTime startdate, DateTime endDate,boolean byPassCheck){
        Set<String> equipmentLineItemsId = new Set<String>();
        Map<Id,ElixirSuite__Equipment_Line_Item__c> equipLineItemMap= new Map<Id,ElixirSuite__Equipment_Line_Item__c>([Select id,Name,ElixirSuite__Is_Under_Maintenance__c from ElixirSuite__Equipment_Line_Item__c where ElixirSuite__Room_No__c =: roomId AND ElixirSuite__Is_Under_Maintenance__c=false WITH SECURITY_ENFORCED]);
        List<Event> eqLineItemEventList  = new List<Event>();
        Map<Id,ElixirSuite__Equipment_Line_Item__c> allEquipLineItemsMap= new Map<Id,ElixirSuite__Equipment_Line_Item__c>([Select id,Name,ElixirSuite__Is_Under_Maintenance__c from ElixirSuite__Equipment_Line_Item__c where ElixirSuite__Is_Under_Maintenance__c=false WITH SECURITY_ENFORCED limit:neededAmount]);

        if(!byPassCheck){
            if(equipLineItemMap.size() >0){
                eqLineItemEventList = [Select id,subject,whatId,StartDateTime,EndDateTime from Event where whatId IN: equipLineItemMap.keySet() AND StartDateTime >=: startdate AND EndDateTime <=: endDate WITH SECURITY_ENFORCED];
                
                if(eqLineItemEventList.size() >0){
                    for(Event et: eqLineItemEventList){
                        if(equipLineItemMap.containsKey(et.WhatId)){
                            equipLineItemMap.remove(et.WhatId);
                            
                        }
                    }
                }
            }else{
       
                if(allEquipLineItemsMap.size() >0){
                    eqLineItemEventList = [Select id,subject,whatId,StartDateTime,EndDateTime from Event where whatId IN: allEquipLineItemsMap.keySet() AND StartDateTime >=: startdate AND EndDateTime <=: endDate WITH SECURITY_ENFORCED];
                    
                    if(eqLineItemEventList.size() >0){
                        for(Event et: eqLineItemEventList){
                            if(allEquipLineItemsMap.containsKey(et.WhatId)){
                                allEquipLineItemsMap.remove(et.WhatId);
                                
                            }
                        }
                    }
                }
            }
        }
        if(equipLineItemMap.size() >0){
            equipmentLineItemsId = (Set<String>)JSON.deserialize(JSON.serialize(equipLineItemMap.keySet()), Set<String>.class);
        }else{
            if(allEquipLineItemsMap.size() >0){
                equipmentLineItemsId = (Set<String>)JSON.deserialize(JSON.serialize(allEquipLineItemsMap.keySet()), Set<String>.class);
            }
            
        }
        
        
        return equipmentLineItemsId;
    }
    
    public static Set<String>  getEquipmentLineItemsIdForEquipment(String equipmentsId,integer noOfEquipLineItemNeeded,DateTime startdate,DateTime endDate,boolean byPassCheck){
        
        Set<ElixirSuite__Equipment_Line_Item__c> setOfEquipmentLineItems = new Set<ElixirSuite__Equipment_Line_Item__c>();
        Set<String> equipmentLineItemsId = new Set<String>();
        Set<String> relatedRoomIds = new Set<String>();
        List<Event> eqLineItemEventList  = new List<Event>();
        List<Event> relatedRoomEventList  =  new List<Event>();
        
        Map<Id,ElixirSuite__Equipment_Line_Item__c> equipLineItemMap= new Map<Id,ElixirSuite__Equipment_Line_Item__c>([Select id,Name,ElixirSuite__Is_Under_Maintenance__c from ElixirSuite__Equipment_Line_Item__c where ElixirSuite__Room_No__c=null AND ElixirSuite__Is_Under_Maintenance__c=false WITH SECURITY_ENFORCED]);
        for(Id equipId: equipLineItemMap.keySet()){
            equipmentLineItemsId.add(String.valueOf(equipId));
            setOfEquipmentLineItems.add(equipLineItemMap.get(equipId));
        }
        system.debug('eqsize'+equipmentLineItemsId);
        integer count =0;
        if(noOfEquipLineItemNeeded > equipmentLineItemsId.size()){
            count = noOfEquipLineItemNeeded - equipmentLineItemsId.size();
            system.debug('count'+count);
            if(count >=1){
                Map<Id,ElixirSuite__Equipment_Line_Item__c> allEquipLineItemMap= new Map<Id,ElixirSuite__Equipment_Line_Item__c>([Select id,Name,ElixirSuite__Room_No__c,ElixirSuite__Is_Under_Maintenance__c from ElixirSuite__Equipment_Line_Item__c where ElixirSuite__Is_Under_Maintenance__c=false WITH SECURITY_ENFORCED]);
                
                if(allEquipLineItemMap.size() >0){
                    for(Id eqlineItemId: allEquipLineItemMap.keySet()){
                        if(!String.isBlank(allEquipLineItemMap.get(eqlineItemId).ElixirSuite__Room_No__c)){
                            relatedRoomIds.add(allEquipLineItemMap.get(eqlineItemId).ElixirSuite__Room_No__c);
                        }
                    }
                    Map<Id,ElixirSuite__Rooms__c> roomMap = new Map<Id,ElixirSuite__Rooms__c>([Select id,Name from ElixirSuite__Rooms__c where Id IN: relatedRoomIds AND ElixirSuite__Under_Maintenance_Removed__c=false WITH SECURITY_ENFORCED]);
                    //eqLineItemEventList = [Select id,subject,whatId,StartDateTime,EndDateTime from Event where whatId IN: allEquipLineItemMap.keySet() AND StartDateTime];
                    if(!byPassCheck){
                        if(roomMap.size() >0){
                            Set<String> setOfWhatIds = new Set<String>();
                            relatedRoomEventList = [Select id,subject,whatId,StartDateTime,EndDateTime from Event where whatId IN: roomMap.keySet() AND StartDateTime >=: startdate AND EndDateTime <=: endDate WITH SECURITY_ENFORCED];
                            
                            if(relatedRoomEventList.size() >0){
                                for(Event ev: relatedRoomEventList){
                                    if(ev.whatId!=null){
                                        setOfWhatIds.add(ev.whatId);
                                    }
                                    
                                }
                            }
                            
                            if(setOfWhatIds.size() >0){
                                for(String whatId: setOfWhatIds){
                                    if(roomMap.containsKey(whatId)){
                                        roomMap.remove(whatId);
                                    }
                                }
                            }
                        }
                    }
                    system.debug('rmap'+roomMap);
                    if(allEquipLineItemMap.size() >0 && roomMap.size() >0){
                        for(Id eqlineItemId: allEquipLineItemMap.keySet()){
                            if(!String.isBlank(allEquipLineItemMap.get(eqlineItemId).ElixirSuite__Room_No__c) && roomMap.containsKey(allEquipLineItemMap.get(eqlineItemId).ElixirSuite__Room_No__c)){
                                if(noOfEquipLineItemNeeded == equipmentLineItemsId.size()){
                                    break;
                                }else{
                                    equipmentLineItemsId.add(String.valueOf(eqlineItemId));
                                    setOfEquipmentLineItems.add(allEquipLineItemMap.get(eqlineItemId));
                                }
                            }
                        }
                    }
                }
                system.debug('equipmentLineItemsId'+equipmentLineItemsId);  
                
            }
        }
        else if(equipmentLineItemsId.size() > noOfEquipLineItemNeeded){
            if(noOfEquipLineItemNeeded>0){
                count = equipmentLineItemsId.size() - noOfEquipLineItemNeeded;
                system.debug('count'+count);
                List<String> temporaryEqList = new List<String>(equipmentLineItemsId);
                if(count >=1){
                    for(integer i=count-1; i>=0; i--){
                        try{
                        temporaryEqList.remove(i);
                        }
                        catch(exception e){
                            continue;
                        }
                    }
                }
                equipmentLineItemsId = new Set<String>(temporaryEqList);
            }
            
        }
        return equipmentLineItemsId;
    }
    
    public static Set<String> getPatientsFromGroup(Set<String> groupIds){
        
        Set<String> accountIds = new Set<String>();
        
        for(ElixirSuite__Group_Patient__c gp: [Select id,ElixirSuite__Current_Patient_Name__c,ElixirSuite__Group_Name__c from ElixirSuite__Group_Patient__c where ElixirSuite__Group_Name__c IN: groupIds WITH SECURITY_ENFORCED]){
            
            accountIds.add(gp.ElixirSuite__Current_Patient_Name__c);
            system.debug('acname'+gp.ElixirSuite__Current_Patient_Name__c);
        }
        system.debug('accountIds'+accountIds.size());
        return accountIds;
    }
    
    public class Equip{
        String Id;
        String EquipmentNeed;
    }*/
}
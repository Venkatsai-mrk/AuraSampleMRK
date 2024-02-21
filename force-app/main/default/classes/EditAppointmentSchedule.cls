/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-10-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class EditAppointmentSchedule { 
     

    /*public static void identifyEventType(List<Event> eventList){
        List<Event> eventWithRepeatFalse = new List<Event>();
        List<Event> eventWithRepeatTrue = new List<Event>();
        if(eventList.size() >0){
            for(Event record: eventList){
                if(!Test.isRunningTest()){
                    if(record.ElixirSuite__Is_custom_screen__c && !String.isBlank(record.ElixirSuite__Event_Data_Object__c)){
                        if(!record.IsRecurrence2){
                            eventWithRepeatFalse.add(record);
                        }else if(record.IsRecurrence2 && !record.IsRecurrence2Exception){
                            
                            eventWithRepeatTrue.add(record);
                        }
                    }
                }else{
                    if(record.ElixirSuite__Is_custom_screen__c && !String.isBlank(record.ElixirSuite__Event_Data_Object__c)){
                        if(!record.IsRecurrence){
                            eventWithRepeatFalse.add(record);
                        }else if(record.IsRecurrence && !record.IsRecurrence2Exception){
                            
                            eventWithRepeatTrue.add(record);
                        }
                    }
                }
                
            }
        }
        
        if(eventWithRepeatFalse.size() >0){
            EditAppointmentSchedule.editAppointmentForRepeatFalse(eventWithRepeatFalse);
        }
        
        if(eventWithRepeatTrue.size() >0){
            EditAppointmentSchedule.editAppointmentWithEditEntireSeriesForRepeatTrue(eventWithRepeatTrue);
        }
    }
    
    public static void editAppointmentForRepeatFalse(List<Event> eventList){
        
        List<Event> eventWithCustomScreen = new List<Event>();
        List<Id> setOfEventDataIds = new List<Id>();
        Map<String,List<Event>> mapOfEventDataIdToEvents = new Map<String,List<Event>>();
        Map<String,Set<String>> mapOfEventDataIdToSetOfEventId = new Map<String,Set<String>>();
        Map<String,Event> mapOfEventDataIdToCustomScreenUpdatedEvent = new Map<String,Event>();
        List<Event> eventListForAlreadyExistingData = new List<Event>();
        if(CheckRecursive.runOnce() && CreateAppointmentSchedule.doUpdate){
        if(eventList.size() >0){
            for(Event record: eventList){
                
                if(record.ElixirSuite__Is_custom_screen__c && !record.IsRecurrence2){
                    if(!String.isBlank(record.ElixirSuite__Event_Data_Object__c)){
                        system.debug('record' +record);
                        setOfEventDataIds.add(record.ElixirSuite__Event_Data_Object__c);
                        mapOfEventDataIdToCustomScreenUpdatedEvent.put(record.ElixirSuite__Event_Data_Object__c,record);
                    }
                }
            }
        }
        If(setOfEventDataIds.size() >0){
            eventWithCustomScreen = [Select id,ElixirSuite__Event_Data_Object__c,WhoId,Subject,StartDateTime,EndDateTime,WhatId,OwnerId,Description,ElixirSuite__By_Pass_Check__c,IsAllDayEvent from Event where ElixirSuite__Event_Data_Object__c IN: setOfEventDataIds WITH SECURITY_ENFORCED];
            
            system.debug('eventWithCustomScreen' +eventWithCustomScreen.size());
            if(eventWithCustomScreen.size() >0){
                for(Event record: eventWithCustomScreen){
                    if(mapOfEventDataIdToEvents.containsKey(record.ElixirSuite__Event_Data_Object__c)){
                        mapOfEventDataIdToEvents.get(record.ElixirSuite__Event_Data_Object__c).add(record);
                        mapOfEventDataIdToSetOfEventId.get(record.ElixirSuite__Event_Data_Object__c).add(record.WhatId);
                    }else{
                        mapOfEventDataIdToEvents.put(record.ElixirSuite__Event_Data_Object__c, new List<Event>{record});
                        mapOfEventDataIdToSetOfEventId.put(record.ElixirSuite__Event_Data_Object__c, new Set<String>{record.WhatId});
                    }
                }
            }
        }
            system.debug('map1' +mapOfEventDataIdToSetOfEventId.size());
            system.debug('map2' +mapOfEventDataIdToSetOfEventId);
            
        if(mapOfEventDataIdToEvents.size() >0){
            for(String evendataId: mapOfEventDataIdToEvents.keySet()){
                if(mapOfEventDataIdToEvents.get(evendataId).size() >0){
                    Event EventRecordFromUI = mapOfEventDataIdToCustomScreenUpdatedEvent.get(evendataId);
                    for(Event record: mapOfEventDataIdToEvents.get(evendataId)){
                        record.Subject = EventRecordFromUI.Subject;
                        record.StartDateTime = EventRecordFromUI.StartDateTime;
                        record.EndDateTime = EventRecordFromUI.EndDateTime;
                        record.Description = EventRecordFromUI.Description;
                        record.ElixirSuite__By_Pass_Check__c = EventRecordFromUI.ElixirSuite__By_Pass_Check__c;
                        record.IsAllDayEvent = EventRecordFromUI.IsAllDayEvent;
                        record.WhoId = EventRecordFromUI.WhoId;
                        //record.OwnerId = EventRecordFromUI.OwnerId;
                         record.ElixirSuite__Reason__c= EventRecordFromUI.ElixirSuite__Reason__c;
                        eventListForAlreadyExistingData.add(record);
                        system.debug('newrecordwhatid' +record.whatId);
                    } 
                } 
            }
        }
        system.debug('eventListForAlreadyExistingData' +eventListForAlreadyExistingData.size());
        if(eventListForAlreadyExistingData.size() >0){
            if(Schema.sObjectType.Event.isUpdateable() &&
            Schema.sObjectType.Event.fields.ElixirSuite__Reason__c.isUpdateable() &&
            Schema.sObjectType.Event.fields.WhoId.isUpdateable() &&
            Schema.sObjectType.Event.fields.IsAllDayEvent.isUpdateable() &&
            Schema.sObjectType.Event.fields.ElixirSuite__By_Pass_Check__c.isUpdateable() && 
            Schema.sObjectType.Event.fields.Description.isUpdateable() && 
            Schema.sObjectType.Event.fields.EndDateTime.isUpdateable() && 
            Schema.sObjectType.Event.fields.Subject.isUpdateable() &&
            Schema.sObjectType.Event.fields.StartDateTime.isUpdateable()){ 
       
            update eventListForAlreadyExistingData;
        }
    }
        Set<String> alreadyExistingDataSet;
        String patients;
        List<String> patientList;
        String groups;
        List<String> groupList;
        String coFacilitators;
        List<String> coFacilitatorList;
        String bussinessAccounts;
        List<String> bussinessAccountList;
        List<String> eqLineItemList;
        List<String> indirectRoomList;
            List<String> allUsersList;
            
        String equipments;
        List<EquipTemp> equipTempList;
        
         Set<String> oldAndNewDataSet;
        Set<String> patientsIds;
        Set<String> groupIds;
        Set<String> userIds;
        Set<String> bussinessAccountIds;
        Set<String> roomIds;
        Set<String> equipmentIds;
        Set<String> eqLineItemIds;
        Set<String> indirectRoomIds;
        Set<String> allUsersIds;
        String room;
            String lineItemString;
            String indirectRoomString;
            String allUsersString; 
        List<ElixirSuite__Event_Data_Object__c> eventDataList = new List<ElixirSuite__Event_Data_Object__c>();
        if(setOfEventDataIds.size() >0){
            Map<Id,ElixirSuite__Event_Data_Object__c> mapOfEventData = new Map<Id,ElixirSuite__Event_Data_Object__c>([Select id,ElixirSuite__By_Pass_Check__c,ElixirSuite__AllUsers__c,ElixirSuite__EquipmentLineItems__c,ElixirSuite__IndirectRooms__c,ElixirSuite__Start_Date_Time__c,ElixirSuite__End_Date_and_Time__c,ElixirSuite__Patients__c,ElixirSuite__Patient_Groups__c,ElixirSuite__Provider__c,ElixirSuite__Rooms__c,
                                                                                                                      ElixirSuite__Related_Business_Accounts__c,ElixirSuite__Co_Facilitators__c from ElixirSuite__Event_Data_Object__c where Id IN: setOfEventDataIds WITH SECURITY_ENFORCED]);
            
            for(Id eventDataId: mapOfEventData.keySet()){
                if(mapOfEventDataIdToCustomScreenUpdatedEvent.containsKey(eventDataId)){
                    ElixirSuite__Event_Data_Object__c record = mapOfEventData.get(eventDataId);
                    record.ElixirSuite__Start_Date_Time__c = mapOfEventDataIdToCustomScreenUpdatedEvent.get(eventDataId).StartDateTime;
                    record.ElixirSuite__End_Date_and_Time__c = mapOfEventDataIdToCustomScreenUpdatedEvent.get(eventDataId).EndDateTime;
                    eventDataList.add(record);
                }
            }
            system.debug('eventDataList' +eventDataList);
             system.debug('eventDataList' +eventDataList.size());
            if(eventDataList.size() >0){
                if(Schema.sObjectType.ElixirSuite__Event_Data_Object__c.isUpdateable() && 
                Schema.sObjectType.ElixirSuite__Event_Data_Object__c.fields.ElixirSuite__End_Date_and_Time__c.isUpdateable() && 
                Schema.sObjectType.ElixirSuite__Event_Data_Object__c.fields.ElixirSuite__Start_Date_Time__c.isUpdateable()){  
                update eventDataList; 
            }
        }
            for(Id eventDataId: mapOfEventData.keySet()){
                alreadyExistingDataSet = new Set<String>();
                oldAndNewDataSet = new Set<String>(); 
                patientsIds = new Set<String>();
                groupIds = new Set<String>();
                userIds = new Set<String>();
                bussinessAccountIds = new Set<String>();
                roomIds = new Set<String>();
                equipmentIds = new Set<String>();
                indirectRoomIds = new Set<String>();
                eqLineItemIds = new Set<String>();
                
                   
                patientList = new List<String> ();
                groupList =new List<String> ();
                coFacilitatorList =new List<String> ();
                bussinessAccountList =new List<String> ();
                equipTempList =  new List<EquipTemp> ();
                indirectRoomList =new List<String> ();
                eqLineItemList =  new List<String> ();
                allUsersList =new List<String> ();
            allUsersIds =new Set<String>();
                if(mapOfEventDataIdToSetOfEventId.containsKey(eventDataId) && mapOfEventDataIdToSetOfEventId.get(eventDataId).size() >0){
                    
                    alreadyExistingDataSet.addAll(mapOfEventDataIdToSetOfEventId.get(eventDataId));
                    system.debug('ExistingDS'+alreadyExistingDataSet);
                }
                
                patients = mapOfEventData.get(eventDataId).ElixirSuite__Patients__c;
                groups = mapOfEventData.get(eventDataId).ElixirSuite__Patient_Groups__c;
                coFacilitators = mapOfEventData.get(eventDataId).ElixirSuite__Co_Facilitators__c;
                bussinessAccounts = mapOfEventData.get(eventDataId).ElixirSuite__Related_Business_Accounts__c;
                room = mapOfEventData.get(eventDataId).ElixirSuite__Rooms__c;
                lineItemString = mapOfEventData.get(eventDataId).ElixirSuite__EquipmentLineItems__c;
                indirectRoomString = mapOfEventData.get(eventDataId).ElixirSuite__IndirectRooms__c;
                allUsersString = mapOfEventData.get(eventDataId).ElixirSuite__AllUsers__c;
                
               
                
                 
                   
                    if(!String.isBlank(allUsersString)){  
                        allUsersList = (List<String>)JSON.deserializeStrict(allUsersString,List<String>.class);
                        for(String pt: allUsersList){
                            if(!String.isBlank(pt)){
                                allUsersIds.add(pt);
                            }
                            
                        }
                    }
                if(!String.isBlank(lineItemString)){  
                    eqLineItemList = (List<String>)JSON.deserializeStrict(lineItemString,List<String>.class);
                    for(String pt: eqLineItemList){
                        if(!String.isBlank(pt)){
                            eqLineItemIds.add(pt);
                        }
                        
                    }
                }
                if(!String.isBlank(indirectRoomString)){
                    indirectRoomList = (List<String>)JSON.deserializeStrict(indirectRoomString,List<String>.class);
                    for(String pt: indirectRoomList){
                        if(!String.isBlank(pt)){
                            indirectRoomIds.add(pt);
                        }
                        
                    }
                }
                
                
                if(!String.isBlank(patients)){
                    patientList = (List<String>)JSON.deserializeStrict(patients,List<String>.class);
                    for(String pt: patientList){
                        if(!String.isBlank(pt)){
                            patientsIds.add(pt);
                        }
                        
                    }
                }
                system.debug('patientsIds'+patientsIds);
                if(!String.isBlank(groups)){
                    groupList = (List<String>)JSON.deserializeStrict(groups,List<String>.class);
                    for(String pt: groupList){
                        if(!String.isBlank(pt)){
                            groupIds.add(pt);
                        }
                        
                    }
                    patientsIds.addAll(getPatientsFromGroup(groupIds));
                    system.debug('patientsIds'+patientsIds);
                    
                }
                if(!String.isBlank(coFacilitators)){
                    coFacilitatorList = (List<String>)JSON.deserializeStrict(coFacilitators,List<String>.class);
                    
                    for(String pt: coFacilitatorList){
                        if(!String.isBlank(pt)){
                            userIds.add(pt);
                        }
                        
                    }
                }
                system.debug('userIds'+userIds);
                if(!String.isBlank(bussinessAccounts)){
                    bussinessAccountList = (List<String>)JSON.deserializeStrict(bussinessAccounts,List<String>.class);
                    
                    for(String pt: bussinessAccountList){
                        if(!String.isBlank(pt)){
                            bussinessAccountIds.add(pt);
                        }
                        
                    }
                }
                system.debug('bussinessAccountIds'+bussinessAccountIds);
                 Map<String,Integer> mapOfEquipIdToNeededQuantity = new Map<String,Integer>();
                
                if(!String.isBlank(equipments)){
                    
                    equipTempList = (List<EquipTemp>) JSON.deserializeStrict(equipments,List<EquipTemp>.class);
                    
                    for(EquipTemp pt: equipTempList){  
                        
                        if(!String.isBlank(pt.Id) && !String.isBlank(pt.EquipmentNeed)){
                            mapOfEquipIdToNeededQuantity.put(pt.Id, Integer.valueOf(pt.EquipmentNeed));
                        }
                        else if(!String.isBlank(pt.Id)){
                            mapOfEquipIdToNeededQuantity.put(pt.Id, 0);
                        }
                        
                    }
                    
                }
                Map<String,Set<String>> eventKeyToEquipLineItemSet = new Map<String,Set<String>>();
                Set<String> EquipmentLineItemsId = new Set<String>();
                Set<String> allEquipmentLineItemsIds = new Set<String>();
                Set<ElixirSuite__Equipment_Line_Item__c> setOfEquipmentLineItems = new Set<ElixirSuite__Equipment_Line_Item__c>();
                datetime timestart = mapOfEventData.get(eventDataId).ElixirSuite__Start_Date_Time__c;
                datetime timeend = mapOfEventData.get(eventDataId).ElixirSuite__End_Date_and_Time__c;
                boolean byPassCheck = mapOfEventData.get(eventDataId).ElixirSuite__By_Pass_Check__c;
                
                if(String.isBlank(room) && mapOfEquipIdToNeededQuantity.size() >0){
                    
                    for(String equipId: mapOfEquipIdToNeededQuantity.keySet()){
                        
                        EquipmentLineItemsId = getEquipmentLineItemsIdForEquipment(equipId,mapOfEquipIdToNeededQuantity.get(equipId),timestart,timeend,byPassCheck);
                        
                        allEquipmentLineItemsIds.addAll(EquipmentLineItemsId);
                    }
                    
                    if(allEquipmentLineItemsIds.size() >0){
                        for(ElixirSuite__Equipment_Line_Item__c eqlineItem: [Select id,Name,ElixirSuite__Room_No__c from ElixirSuite__Equipment_Line_Item__c where ID IN: allEquipmentLineItemsIds WITH SECURITY_ENFORCED]){
                            if(eqlineItem.ElixirSuite__Room_No__c!=null){
                                roomIds.add(eqlineItem.ElixirSuite__Room_No__c);
                            }
                        }
                        
                    }
                    
                }else if(!String.isBlank(room) && mapOfEquipIdToNeededQuantity.size()== 0){
                    EquipmentLineItemsId = getEquipmentLineItemsId(room,timestart,timeend,byPassCheck);
                    
                    allEquipmentLineItemsIds.addAll(EquipmentLineItemsId);
                    roomIds.add(room);
                    
                    
                }else if(!String.isBlank(room) && mapOfEquipIdToNeededQuantity.size() >0){
                    roomIds.add(room);
                    
                    
                    for(String equipId: mapOfEquipIdToNeededQuantity.keySet()){
                        
                        EquipmentLineItemsId = getEquipmentLineItemsWithSelectedRoom(equipId,mapOfEquipIdToNeededQuantity.get(equipId),room,timestart,timeend,byPassCheck);
                        allEquipmentLineItemsIds.addAll(EquipmentLineItemsId);     
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
            
                allEquipmentLineItemsIds.addAll(eqLineItemIds);
                roomIds.addAll(indirectRoomIds);
                
                mapOfEventData.get(eventDataId).ElixirSuite__EquipmentLineItems__c = JSON.serialize(new List<String>(allEquipmentLineItemsIds));
                mapOfEventData.get(eventDataId).ElixirSuite__IndirectRooms__c = JSON.serialize(new List<String>(roomIds));
                mapOfEventData.get(eventDataId).ElixirSuite__AllUsers__c = JSON.serialize(new List<String>(userIds));
                
                system.debug('allEquipmentLineItemsIds'+allEquipmentLineItemsIds);
                system.debug('roomIds'+roomIds);
                Id whatIdStartedOps =mapOfEventDataIdToCustomScreenUpdatedEvent.get(mapOfEventData.get(eventDataId).Id).WhatId;
                oldAndNewDataSet.addAll(patientsIds);
                oldAndNewDataSet.addAll(groupIds);
                oldAndNewDataSet.addAll(bussinessAccountIds);
                oldAndNewDataSet.addAll(roomIds);
                oldAndNewDataSet.addAll(allEquipmentLineItemsIds);
                
                  
                system.debug('oldAndNewDataSet'+oldAndNewDataSet);
                //oldAndNewDataSet.remove(whatIdStartedOps);
                
                system.debug('oldAndNewDataSet'+oldAndNewDataSet);
                system.debug('userIds'+userIds);
                system.debug('alreadyExistingDataSet'+alreadyExistingDataSet);
                
                if(alreadyExistingDataSet.size() > 0){
                    for(String eventId: alreadyExistingDataSet){
                        if(oldAndNewDataSet.size() >0 && oldAndNewDataSet.contains(eventId)){
                            oldAndNewDataSet.remove(eventId);
                            alreadyExistingDataSet.remove(eventId);
                        }
                        /*else if(userIds.size() >0 && userIds.contains(eventId)){
                            
                            userIds.remove(eventId);
                            alreadyExistingDataSet.remove(eventId);                        
                        }
                    }
                }
                
                    
                    if(allUsersIds.size() > 0){
                        for(String eventWhatId: allUsersIds){
                            if(userIds.size() >0 && userIds.contains(eventWhatId)){
                                
                                userIds.remove(eventWhatId);
                                allUsersIds.remove(eventWhatId);                            
                            }
                        }
                    }
                system.debug('userIds'+userIds);
                Set<String> relationIdSet = new Set<String>();
            if(userIds.size() >0){
                List<EventRelation> relationLst = [Select id,IsInvitee,RelationId,EventId from EventRelation where RelationId IN:userIds and IsInvitee=true];
                if(relationLst.size() >0){
                    for(EventRelation rel: relationLst){
                        if(userIds.contains(rel.RelationId)){
                            userIds.remove(rel.RelationId);
                        }
                    }
                }
            }
            system.debug('userIds'+userIds);
                List<Event> listOfEventToDelete = new List<Event>();
                system.debug('DSExx'+alreadyExistingDataSet);
                if(alreadyExistingDataSet.size() >0){
                    listOfEventToDelete = [Select id,Subject from Event where WhatId IN:alreadyExistingDataSet WITH SECURITY_ENFORCED];
                    
                    
                }
                system.debug('oldAndNewDataSet'+oldAndNewDataSet);
                List<Event> listOfEventToInsert = new List<Event> ();
                List<EventRelation> eventRelationToBeInserted = new List<EventRelation >();
                if(oldAndNewDataSet.size() >0){
                    for(string relatedToId: oldAndNewDataSet){
                        system.debug('relatedToId'+relatedToId);
                        Event EventRecordFromUI = mapOfEventDataIdToCustomScreenUpdatedEvent.get(eventDataId);
                        
                        Event newRecord = EventRecordFromUI.clone(false, false, false, false);
                        newRecord.ElixirSuite__Is_custom_screen__c = false;
                        newRecord.whatId = relatedToId;
                        newRecord.ElixirSuite__Event_Data_Object__c = EventRecordFromUI.ElixirSuite__Event_Data_Object__c;
                        newRecord.ElixirSuite__By_Pass_Check__c = mapOfEventData.get(eventDataId).ElixirSuite__By_Pass_Check__c;
                        newRecord.WhoId = EventRecordFromUI.WhoId;
                        
                        newRecord.Subject = EventRecordFromUI.Subject;
                        newRecord.StartDateTime = EventRecordFromUI.StartDateTime;
                        newRecord.EndDateTime = EventRecordFromUI.EndDateTime;
                        newRecord.Description = EventRecordFromUI.Description;
                        newRecord.IsAllDayEvent = EventRecordFromUI.IsAllDayEvent;
                        newRecord.ElixirSuite__Reason__c= EventRecordFromUI.ElixirSuite__Reason__c;
                        
                        listOfEventToInsert.add(newRecord);
                    }
                     
                }
                
                if(userIds.size() >0){
                    for(string userId: userIds){
                        Event EventRecordFromUI = mapOfEventDataIdToCustomScreenUpdatedEvent.get(eventDataId);
                        EventRelation  newRecord =  new EventRelation();
                        newRecord.IsInvitee = true;
                        newRecord.RelationId = userId;
                        newRecord.EventId = EventRecordFromUI.Id;
                        
                        eventRelationToBeInserted.add(newRecord);
                    }
                }
                
                system.debug('in'+listOfEventToInsert);
                system.debug('in'+eventRelationToBeInserted);
                system.debug('in'+eventRelationToBeInserted.size());
                
                    DeleteAppointmentHelper.deleteRecursiveCheck = false;
                    if (Schema.sObjectType.Event.isDeletable())
                {
                    delete listOfEventToDelete;
                }
                
                    if(listOfEventToInsert.size() >0){
                        if (Schema.sObjectType.Event.isCreateable()) {
                        insert listOfEventToInsert;
                    }
                }
                
                    if(eventRelationToBeInserted.size() >0){
                        if (Schema.sObjectType.EventRelation.isCreateable())
                        {
                        insert eventRelationToBeInserted;
                    }
                }
                

                //oldAndNewDataSet.addAll(elements); TO DO - Equipment k Liye
                
                
                
            }
            if(mapOfEventData.size() >0){
                update mapOfEventData.values();
            }
        }
           
            
        }
    }
    
     
    public static void editAppointmentWithEditEntireSeriesForRepeatTrue(List<Event> eventList){
        List<Event> eventsToBeCloned = new List<Event>();
        Map<String,Event> mapOfEventDataIdToEvent = new Map<String,Event>();
        Set<Id> eventIdSet= new Set<Id>();
        Set<Id> eventDataIdSet= new Set<Id>();
        String k;
        
        system.debug('event');
        if(CreateAppointmentSchedule.doUpdate){
            system.debug('event');
            for(Event record: eventList){
                system.debug('ss' );
                if(!String.isBlank(record.ElixirSuite__Event_Data_Object__c) && record.ElixirSuite__Is_custom_screen__c ==true){
                    system.debug('aa' );
                    if(!record.IsRecurrence2Exception){
                        system.debug('bb' );
                        eventIdSet.add(record.id);
                        eventDataIdSet.add(record.ElixirSuite__Event_Data_Object__c);
                        k = record.ElixirSuite__Event_Data_Object__c +'_'+ String.valueOf(record.StartDateTime) + String.valueOf( record.EndDateTime);
                        system.debug('k'+k);
                        system.debug('record'+record.id);
                        mapOfEventDataIdToEvent.put(k, record);
                    }
                }
            }
            
            Set<String> setOfWhatId = new Set<String>();
            Map<String,List<Event>> mapOfEventDataKeyToListOfEvent = new Map<String,List<Event>>();
            Map<String,Set<String>> mapOfEventDataKeyToWhatId = new Map<string,Set<String>>();
            if(eventDataIdSet.size() >0){
                system.debug('eventDataIdSet'+eventDataIdSet);
                
                List<Event> existingEvents = [Select id,Subject,WhatId,description,StartDateTime,WhoId,EndDateTime,ElixirSuite__Reason__c,ElixirSuite__Is_custom_screen__c,ElixirSuite__Event_Data_Object__c from Event where ElixirSuite__Event_Data_Object__c IN:eventDataIdSet AND Id NOT IN:eventIdSet AND IsChild=false WITH SECURITY_ENFORCED];
                system.debug('existingEvents'+existingEvents);
                system.debug('existingEvents'+existingEvents.size());
                String k2;
                if(existingEvents.size() >0){
                    for(Event record: existingEvents){
                        system.debug('existingEvent'+record.id);
                        setOfWhatId.add(record.WhatId);
                        k2 = record.ElixirSuite__Event_Data_Object__c +'_'+ String.valueOf(record.StartDateTime) + String.valueOf( record.EndDateTime);
                        if(mapOfEventDataKeyToListOfEvent.containsKey(k2)){
                            mapOfEventDataKeyToListOfEvent.get(k2).add(record);
                            mapOfEventDataKeyToWhatId.get(k2).add(record.WhatId);
                        }else{
                            mapOfEventDataKeyToListOfEvent.put(k2, new List<Event>{record});
                            mapOfEventDataKeyToWhatId.put(k2, new Set<String>{record.WhatId});
                        }
                        system.debug('k2'+k2);
                        
                    }
                }
                system.debug('mapOfEventDataKeyToListOfEvent'+mapOfEventDataKeyToListOfEvent.size());
                List<Event> eventListToUpdate = new List<Event>();
                integer count=0;
                event firstEvent;
                if(mapOfEventDataIdToEvent.size() >0){
                    for(String ky: mapOfEventDataIdToEvent.keySet()){
                        
                        system.debug('ky'+ky);
                        system.debug('ky'+mapOfEventDataKeyToListOfEvent.containsKey(ky));
                        if(mapOfEventDataKeyToListOfEvent.size() >0 && mapOfEventDataKeyToListOfEvent.containsKey(ky)){
                            if(mapOfEventDataKeyToListOfEvent.get(ky).size() >0){
                                for(event record: mapOfEventDataKeyToListOfEvent.get(ky)){
                                    event updatedRecord = mapOfEventDataIdToEvent.get(ky);
                                    if(count ==0){
                                        firstEvent = mapOfEventDataIdToEvent.get(ky);
                                        record.Subject = updatedRecord.Subject;
                                        // record.OwnerId = updatedRecord.OwnerId;
                                        record.StartDateTime = updatedRecord.StartDateTime;
                                        record.EndDateTime = updatedRecord.EndDateTime;
                                        // newRecord.ElixirSuite__Is_custom_screen__c = false;
                                        // newRecord.ElixirSuite__Event_Data_Object__c = updatedRecord.ElixirSuite__Event_Data_Object__c;
                                        record.ElixirSuite__Reason__c= updatedRecord.ElixirSuite__Reason__c;
                                        record.WhoId = updatedRecord.WhoId;
                                        
                                        record.description = updatedRecord.description;
                                        eventListToUpdate.add(record);
                                    }else{
                                        record.Subject = firstEvent.Subject;
                                        // record.OwnerId = updatedRecord.OwnerId;
                                        record.StartDateTime = firstEvent.StartDateTime;
                                        record.EndDateTime = firstEvent.EndDateTime;
                                        // newRecord.ElixirSuite__Is_custom_screen__c = false;
                                        // newRecord.ElixirSuite__Event_Data_Object__c = updatedRecord.ElixirSuite__Event_Data_Object__c;
                                        record.ElixirSuite__Reason__c= firstEvent.ElixirSuite__Reason__c;
                                        record.WhoId = firstEvent.WhoId;
                                        
                                        record.description = firstEvent.description;
                                        eventListToUpdate.add(record);
                                    }
                                    
                                    
                                    system.debug('ky'+record);
                                    system.debug('up'+updatedRecord);
                                    
                                }
                            }
                            //mapOfEventDataIdToEvent.remove(ky); 
                        }
                        count++;
                    }
                }
                system.debug('eventListToUpdate'+eventListToUpdate.size());
                system.debug('setOfWhatId'+setOfWhatId);
                system.debug('mapOfEventDataIdToEvent'+mapOfEventDataIdToEvent);
                system.debug('mapOfEventDataIdToEvent'+mapOfEventDataIdToEvent.size());
                List<Event> eventListToInserted = new List<Event>();
                /* if(mapOfEventDataIdToEvent.size() >0){
for(String ky: mapOfEventDataIdToEvent.keySet()){
if(setOfWhatId.size() >0){
for(String whatIdForExistingEvent: setOfWhatId){
event cloneRecord = mapOfEventDataIdToEvent.get(ky);
Event newEvent = cloneRecord.clone(false, false, false, false);
newEvent.WhatId = whatIdForExistingEvent;
newEvent.ElixirSuite__Event_Data_Object__c = cloneRecord.ElixirSuite__Event_Data_Object__c;
eventListToInserted.add(newEvent);
} 
}
}
}
                system.debug('eventListToUpdate'+eventListToUpdate.size());
                
                if (Schema.sObjectType.Event.isUpdateable())
                {
                    if(eventListToUpdate.size() >0){
                        if(Schema.sObjectType.Event.isUpdateable() &&
                        Schema.sObjectType.Event.fields.WhoId.isUpdateable() &&
                        Schema.sObjectType.Event.fields.ElixirSuite__Reason__c.isUpdateable() &&
                        Schema.sObjectType.Event.fields.EndDateTime.isUpdateable() &&
                        Schema.sObjectType.Event.fields.StartDateTime.isUpdateable() &&
                        Schema.sObjectType.Event.fields.Subject.isUpdateable() &&
                        Schema.sObjectType.Event.fields.description.isUpdateable()){
                        update eventListToUpdate;

                        CreateAppointmentSchedule.doUpdate =false;
                        }
                    }
                }
                
                
                
                Map<Id,ElixirSuite__Event_Data_Object__c> mapOfEventData = new Map<Id,ElixirSuite__Event_Data_Object__c>();
                if(eventDataIdSet.size() >0){
                    mapOfEventData =new Map<Id,ElixirSuite__Event_Data_Object__c>([Select id,ElixirSuite__By_Pass_Check__c,ElixirSuite__AllUsers__c,ElixirSuite__EquipmentLineItems__c,ElixirSuite__IndirectRooms__c,ElixirSuite__Start_Date_Time__c,ElixirSuite__End_Date_and_Time__c,ElixirSuite__Patients__c,ElixirSuite__Patient_Groups__c,ElixirSuite__Provider__c,ElixirSuite__Rooms__c,ElixirSuite__Related_Business_Accounts__c,ElixirSuite__Co_Facilitators__c from ElixirSuite__Event_Data_Object__c where Id IN: eventDataIdSet WITH SECURITY_ENFORCED]);
                    
                }
                
                //eventDataIdSet ,  Map<String,Set<String>> mapOfEventDataKeyToWhatId
                if(!test.isRunningTest()){
                    if(CheckRecursive.runOnce()){ 
                        processEventDataSelectedRecordForRepeatTrue(mapOfEventData,mapOfEventDataIdToEvent,mapOfEventDataKeyToWhatId);
                    }
                }
                else{
                    processEventDataSelectedRecordForRepeatTrue(mapOfEventData,mapOfEventDataIdToEvent,mapOfEventDataKeyToWhatId);
                    
                }
                
            } 
        }
        
    }
    
    public static void processEventDataSelectedRecordForRepeatTrue(Map<Id,ElixirSuite__Event_Data_Object__c> mapOfEventData,Map<String,Event> mapOfEventDataIdToEvent,Map<String,Set<String>> mapOfEventDataKeyToWhatId){
        Set<String> alreadyExistingDataSet;
        String patients;
        List<String> patientList;
        String groups;
        List<String> groupList;
        String coFacilitators;
        List<String> coFacilitatorList;
        String bussinessAccounts;
        List<String> bussinessAccountList;
        String equipments;
        List<EquipTemp> equipTempList;
        
        Set<String> oldAndNewDataSet;
        Set<String> patientsIds;
        Set<String> groupIds;
        Set<String> userIds;
        Set<String> bussinessAccountIds;
        Set<String> roomIds;
        Set<String> equipmentIds;
        String room;
        
        List<String> eqLineItemList;
        List<String> indirectRoomList;
        Set<String> eqLineItemIds;
        Set<String> indirectRoomIds;
        String lineItemString;
        String indirectRoomString;
        
        String allUsersString; 
        List<String> allUsersList;
        Set<String> allUsersIds;
        
        List<Event> listOfEventToInsert = new List<Event> ();
        List<EventRelation> eventRelationToBeInserted = new List<EventRelation >();
        List<Event> listOfEventToDelete = new List<Event> ();
        
        for(String k: mapOfEventDataIdToEvent.keySet()){
            String eventDataobjectId = k.split('_')[0];
            datetime st =mapOfEventDataIdToEvent.get(k).StartDateTime;
            datetime et = mapOfEventDataIdToEvent.get(k).EndDateTime;
            Event clonetoEvent = mapOfEventDataIdToEvent.get(k);
            
            ElixirSuite__Event_Data_Object__c eventDataRecord = mapOfEventData.get(eventDataobjectId);
            alreadyExistingDataSet = new Set<String>();
            oldAndNewDataSet = new Set<String>(); 
            patientsIds = new Set<String>();
            groupIds = new Set<String>();
            userIds = new Set<String>();
            bussinessAccountIds = new Set<String>();
            roomIds = new Set<String>();
            equipmentIds = new Set<String>();
            patientList = new List<String> ();
            groupList =new List<String> ();
            coFacilitatorList =new List<String> ();
            bussinessAccountList =new List<String> ();
            equipTempList =  new List<EquipTemp> ();
            
            eqLineItemList =new List<String> ();
            indirectRoomList =new List<String> ();
            eqLineItemIds =new Set<String>();
            indirectRoomIds =new Set<String>();
            
            allUsersList =new List<String> ();
            allUsersIds =new Set<String>();
            
            if(mapOfEventDataKeyToWhatId.containsKey(k) && mapOfEventDataKeyToWhatId.get(k).size() >0){
                
                alreadyExistingDataSet.addAll(mapOfEventDataKeyToWhatId.get(k));
            }
            
            patients = eventDataRecord.ElixirSuite__Patients__c;
            groups = eventDataRecord.ElixirSuite__Patient_Groups__c;
            coFacilitators = eventDataRecord.ElixirSuite__Co_Facilitators__c;
            bussinessAccounts = eventDataRecord.ElixirSuite__Related_Business_Accounts__c;
            room = eventDataRecord.ElixirSuite__Rooms__c;
            lineItemString = eventDataRecord.ElixirSuite__EquipmentLineItems__c;
            indirectRoomString = eventDataRecord.ElixirSuite__IndirectRooms__c;
            allUsersString = eventDataRecord.ElixirSuite__AllUsers__c;
            
            
            if(!String.isBlank(allUsersString)){  
                allUsersList = (List<String>)JSON.deserializeStrict(allUsersString,List<String>.class);
                for(String pt: allUsersList){
                    if(!String.isBlank(pt)){
                        allUsersIds.add(pt);
                    }
                    
                }
            }
            if(!String.isBlank(lineItemString)){
                eqLineItemList = (List<String>)JSON.deserializeStrict(lineItemString,List<String>.class);
                for(String pt: eqLineItemList){
                    if(!String.isBlank(pt)){
                        eqLineItemIds.add(pt);
                    }
                    
                }
            }
            if(!String.isBlank(indirectRoomString)){
                indirectRoomList = (List<String>)JSON.deserializeStrict(indirectRoomString,List<String>.class);
                for(String pt: indirectRoomList){
                    if(!String.isBlank(pt)){
                        indirectRoomIds.add(pt);
                    }
                    
                }
            }
            if(!String.isBlank(patients)){
                patientList = (List<String>)JSON.deserializeStrict(patients,List<String>.class);
                for(String pt: patientList){
                    if(!String.isBlank(pt)){
                        patientsIds.add(pt);
                    }
                    
                }
            }
            if(!String.isBlank(groups)){
                groupList = (List<String>)JSON.deserializeStrict(groups,List<String>.class);
                for(String pt: groupList){
                    if(!String.isBlank(pt)){
                        groupIds.add(pt);
                    }
                    
                }
                patientsIds.addAll(getPatientsFromGroup(groupIds));
                
            }
            if(!String.isBlank(coFacilitators)){
                coFacilitatorList = (List<String>)JSON.deserializeStrict(coFacilitators,List<String>.class);
                
                for(String pt: coFacilitatorList){
                    if(!String.isBlank(pt)){
                        userIds.add(pt);
                    }
                    
                }
            }
            
            if(!String.isBlank(bussinessAccounts)){
                bussinessAccountList = (List<String>)JSON.deserializeStrict(bussinessAccounts,List<String>.class);
                
                for(String pt: bussinessAccountList){
                    if(!String.isBlank(pt)){
                        bussinessAccountIds.add(pt);
                    }
                    
                }
            }
            Map<String,Integer> mapOfEquipIdToNeededQuantity = new Map<String,Integer>();
            if(!String.isBlank(equipments)){
                
                equipTempList = (List<EquipTemp>) JSON.deserializeStrict(equipments,List<EquipTemp>.class);
                
                for(EquipTemp pt: equipTempList){  
                    
                    if(!String.isBlank(pt.Id) && !String.isBlank(pt.EquipmentNeed)){
                        mapOfEquipIdToNeededQuantity.put(pt.Id, Integer.valueOf(pt.EquipmentNeed));
                    }
                    else if(!String.isBlank(pt.Id)){
                        mapOfEquipIdToNeededQuantity.put(pt.Id, 0);
                    }
                    
                }
                
            }
            Map<String,Set<String>> eventKeyToEquipLineItemSet = new Map<String,Set<String>>();
            Set<String> EquipmentLineItemsId = new Set<String>();
            Set<String> allEquipmentLineItemsIds = new Set<String>();
            Set<ElixirSuite__Equipment_Line_Item__c> setOfEquipmentLineItems = new Set<ElixirSuite__Equipment_Line_Item__c>();
            
            boolean byPassCheck = eventDataRecord.ElixirSuite__By_Pass_Check__c;
            
            if(String.isBlank(room) && mapOfEquipIdToNeededQuantity.size() >0){
                
                for(String equipId: mapOfEquipIdToNeededQuantity.keySet()){
                    
                    EquipmentLineItemsId = getEquipmentLineItemsIdForEquipment(equipId,mapOfEquipIdToNeededQuantity.get(equipId),st,et,byPassCheck);
                    
                    allEquipmentLineItemsIds.addAll(EquipmentLineItemsId);
                }
                
                if(allEquipmentLineItemsIds.size() >0){
                    for(ElixirSuite__Equipment_Line_Item__c eqlineItem: [Select id,Name,ElixirSuite__Room_No__c from ElixirSuite__Equipment_Line_Item__c where ID IN: allEquipmentLineItemsIds WITH SECURITY_ENFORCED]){
                        if(eqlineItem.ElixirSuite__Room_No__c!=null){
                            roomIds.add(eqlineItem.ElixirSuite__Room_No__c);
                        }
                    }
                    
                }
                
            }else if(!String.isBlank(room) && mapOfEquipIdToNeededQuantity.size()== 0){
                EquipmentLineItemsId = getEquipmentLineItemsId(room,st,et,byPassCheck);
                
                allEquipmentLineItemsIds.addAll(EquipmentLineItemsId);
                roomIds.add(room);
                
                
            }else if(!String.isBlank(room) && mapOfEquipIdToNeededQuantity.size() >0){
                roomIds.add(room);
                
                
                for(String equipId: mapOfEquipIdToNeededQuantity.keySet()){
                    
                    EquipmentLineItemsId = getEquipmentLineItemsWithSelectedRoom(equipId,mapOfEquipIdToNeededQuantity.get(equipId),room,st,et,byPassCheck);
                    allEquipmentLineItemsIds.addAll(EquipmentLineItemsId);     
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
            
            system.debug('patientsIds'+patientsIds);
            system.debug('groupIds'+groupIds);
            system.debug('bussinessAccountIds'+bussinessAccountIds);
            system.debug('roomIds'+roomIds);
            system.debug('allEquipmentLineItemsIds'+allEquipmentLineItemsIds);
            
            system.debug('userIds'+userIds);
            system.debug('allUsersIds'+allUsersIds);
            
            allEquipmentLineItemsIds.addAll(eqLineItemIds);
            roomIds.addAll(indirectRoomIds);
            
            oldAndNewDataSet.addAll(patientsIds);
            oldAndNewDataSet.addAll(groupIds);
            oldAndNewDataSet.addAll(bussinessAccountIds);
            oldAndNewDataSet.addAll(roomIds);
            oldAndNewDataSet.addAll(allEquipmentLineItemsIds);
            system.debug('oldAndNewDataSet'+oldAndNewDataSet);
            oldAndNewDataSet.remove(clonetoEvent.WhatId);
            system.debug('oldAndNewDataSet'+oldAndNewDataSet);
            
            mapOfEventData.get(eventDataobjectId).ElixirSuite__EquipmentLineItems__c = JSON.serialize(new List<String>(allEquipmentLineItemsIds));
            mapOfEventData.get(eventDataobjectId).ElixirSuite__IndirectRooms__c = JSON.serialize(new List<String>(roomIds));
            mapOfEventData.get(eventDataobjectId).ElixirSuite__AllUsers__c = JSON.serialize(new List<String>(userIds));
            
            system.debug('alreadyExistingDataSet'+alreadyExistingDataSet);
            
            if(alreadyExistingDataSet.size() > 0){
                system.debug('alreadyExistingDataSet'+alreadyExistingDataSet);
                for(String whatId: alreadyExistingDataSet){
                    system.debug('whatId'+whatId);
                    system.debug('containss'+oldAndNewDataSet.contains(whatId));
                    if(oldAndNewDataSet.size() >0 && oldAndNewDataSet.contains(whatId)){
                        oldAndNewDataSet.remove(whatId);
                        alreadyExistingDataSet.remove(whatId);
                    }
                    /* else if(userIds.size() >0 && userIds.contains(whatId)){

userIds.remove(whatId);
alreadyExistingDataSet.remove(whatId);                        
}
                }
            }
            if(allUsersIds.size() > 0){
                for(String eventWhatId: allUsersIds){
                    if(userIds.size() >0 && userIds.contains(eventWhatId)){
                        
                        userIds.remove(eventWhatId);
                        allUsersIds.remove(eventWhatId);                            
                    }
                }
            }
            system.debug('userIds'+userIds);
            system.debug('allUsersIds'+allUsersIds);
            
            /*if(userIds.size() >0){
List<EventRelation> relationLst = [Select id,IsInvitee,RelationId,EventId from EventRelation where RelationId IN:userIds and IsInvitee=true];
if(relationLst.size() >0){
for(EventRelation rel: relationLst){
if(userIds.contains(rel.RelationId)){
userIds.remove(rel.RelationId);
}
}
}
}
            system.debug('alreadyExistingDataSet'+alreadyExistingDataSet);
            if(alreadyExistingDataSet.size() >0){
                listOfEventToDelete.addAll( [Select id,Subject from Event where WhatId IN:alreadyExistingDataSet]);
                
            }
            
            system.debug('oldAndNewDataSet'+oldAndNewDataSet);
            if(oldAndNewDataSet.size() >0){
                for(string relatedToId: oldAndNewDataSet){
                    
                    
                    Event newRecord = clonetoEvent.clone(false, false, false, false);
                    newRecord.ElixirSuite__Is_custom_screen__c = false;
                    newRecord.whatId = relatedToId;
                    newRecord.ElixirSuite__Event_Data_Object__c = clonetoEvent.ElixirSuite__Event_Data_Object__c;
                    newRecord.ElixirSuite__By_Pass_Check__c = byPassCheck;
                    newRecord.ElixirSuite__Reason__c= clonetoEvent.ElixirSuite__Reason__c;
                    newRecord.WhoId = clonetoEvent.WhoId;
                    newRecord.description = clonetoEvent.description;
                    listOfEventToInsert.add(newRecord);
                    system.debug('newRecord'+newRecord);
                }
                
            }
            system.debug('userIds'+userIds);
            
            
            if(userIds.size() >0){
                for(string userId: userIds){
                    
                    EventRelation  newRecord =  new EventRelation();
                    newRecord.IsInvitee = true;
                    newRecord.RelationId = userId;
                    newRecord.EventId = clonetoEvent.Id;
                    
                    eventRelationToBeInserted.add(newRecord);
                    system.debug('rel'+newRecord);
                    system.debug('user'+userId);
                }
            }
            
        }
        system.debug('ed listOfEventToInsert'+listOfEventToInsert.size());

            if(listOfEventToInsert.size() >0){
               if (Schema.sObjectType.Event.isCreateAble())
                {
                insert listOfEventToInsert;
            }
        }
        system.debug('relList'+eventRelationToBeInserted);
        system.debug('relList'+eventRelationToBeInserted.size());
            if(eventRelationToBeInserted.size() >0){
                        if (Schema.sObjectType.EventRelation.isCreateable())
        {
                insert eventRelationToBeInserted;
            }
        }
        
        if(mapOfEventData.size() >0){
            update mapOfEventData.values();
        }
        
        
       /* if (Schema.sObjectType.Contact.isDeletable()) { 
            if(listOfEventToDelete.size() >0){
                delete listOfEventToDelete;
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
                eqLineItemEventList = [Select id,subject,whatId,StartDateTime,EndDateTime from Event where whatId IN: equipLineItemMap.keySet() AND ((StartDateTime <=: startdate AND EndDateTime >=: enddate) OR (StartDateTime <: enddate AND EndDateTime >: startdate)) WITH SECURITY_ENFORCED];
                
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
        Map<Id,ElixirSuite__Equipment_Line_Item__c> allEquipLineItemsMap= new Map<Id,ElixirSuite__Equipment_Line_Item__c>([Select id,Name,ElixirSuite__Is_Under_Maintenance__c from ElixirSuite__Equipment_Line_Item__c  WITH SECURITY_ENFORCED limit:neededAmount]);

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
        
        Map<Id,ElixirSuite__Equipment_Line_Item__c> equipLineItemMap= new Map<Id,ElixirSuite__Equipment_Line_Item__c>([Select id,Name,ElixirSuite__Is_Under_Maintenance__c from ElixirSuite__Equipment_Line_Item__c where  ElixirSuite__Room_No__c=null AND ElixirSuite__Is_Under_Maintenance__c=false WITH SECURITY_ENFORCED]);
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
                Map<Id,ElixirSuite__Equipment_Line_Item__c> allEquipLineItemMap= new Map<Id,ElixirSuite__Equipment_Line_Item__c>([Select id,Name,ElixirSuite__Room_No__c,ElixirSuite__Is_Under_Maintenance__c from ElixirSuite__Equipment_Line_Item__c    WITH SECURITY_ENFORCED]);
                
                if(allEquipLineItemMap.size() >0){
                    for(Id eqlineItemId: allEquipLineItemMap.keySet()){
                        if(!String.isBlank(allEquipLineItemMap.get(eqlineItemId).ElixirSuite__Room_No__c)){
                            relatedRoomIds.add(allEquipLineItemMap.get(eqlineItemId).ElixirSuite__Room_No__c);
                        }
                    }
                    Map<Id,ElixirSuite__Rooms__c> roomMap = new Map<Id,ElixirSuite__Rooms__c>([Select id,Name from ElixirSuite__Rooms__c where Id IN: relatedRoomIds AND ElixirSuite__Under_Maintenance_Removed__c=false WITH SECURITY_ENFORCED]);
                    //eqLineItemEventList = [Select id,subject,whatId,StartDateTime,EndDateTime from Event where whatId IN: allEquipLineItemMap.keySet() AND StartDateTime];
                    if(!byPassCheck){
                        system.debug('rmap'+roomMap);
                        if(roomMap.size() >0){
                            Set<String> setOfWhatIds = new Set<String>();
                            relatedRoomEventList = [Select id,subject,whatId,StartDateTime,EndDateTime from Event where whatId IN: roomMap.keySet() AND ((StartDateTime <=: startdate AND EndDateTime >=: enddate)) WITH SECURITY_ENFORCED];
                            
                            if(relatedRoomEventList.size() >0){
                                for(Event ev: relatedRoomEventList){
                                    if(ev.whatId!=null){
                                        setOfWhatIds.add(ev.whatId);
                                    }
                                    
                                }
                            }
                            system.debug('rmap'+setOfWhatIds);
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
            if(noOfEquipLineItemNeeded > 0){
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
        }
        
        return accountIds;
    }
    
    public class EquipTemp{
        String Id;
        String EquipmentNeed;
    }*/
}
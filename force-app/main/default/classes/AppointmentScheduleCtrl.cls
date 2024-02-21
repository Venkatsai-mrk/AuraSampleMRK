/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-10-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class AppointmentScheduleCtrl {
    
    @AuraEnabled
    public static ElixirSuite__Group_Patient__c[] getAllPatientDetailsFromGroupIDs(List<String> groupIDs){
        return  [SELECT ID,ElixirSuite__Current_Patient_Name__r.Id, 
                 ElixirSuite__Current_Patient_Name__r.Name,ElixirSuite__Current_Patient_Name__r.ElixirSuite__Profile_Picture__c
                 FROM ElixirSuite__Group_Patient__c WHERE ElixirSuite__Group_Name__c IN : groupIDs WITH SECURITY_ENFORCED];
    }
    
    @AuraEnabled
    public static List<String> getSubject(){
        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = Event.Subject.getDescribe();
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            options.add(p.getLabel());
        }
        return options;
    }
    //  For delete functionality
    @AuraEnabled
    public static void functionDelete(String recordID,String eventButton)
    {
        
        Event evenRecord = [Select id,ElixirSuite__TechTracking_ID__c from Event where Id =:recordID WITH SECURITY_ENFORCED];
        
        List<Event> techtrack  =[Select id,ElixirSuite__TechTracking_ID__c,startDateTime,EndDateTime from Event where ElixirSuite__TechTracking_ID__c=:evenRecord.ElixirSuite__TechTracking_ID__c AND startDateTime >:system.today() WITH SECURITY_ENFORCED];
        if(eventButton.contains('deleteSeries') && techtrack.size()>1 && Schema.sObjectType.Contact.isDeletable() ){
           // delete techtrack;
            DMLManager.deleteAsUser(techtrack);
        }
        else if(eventButton.contains('delete') && evenRecord!=null && Schema.sObjectType.Contact.isDeletable()){
            //delete evenRecord;
            DMLManager.deleteAsUser(evenRecord);
        }
    }
    //for   multi weekday     
    @AuraEnabled
    public static List <String> getPiklistValues() {
        List<String> plValues = new List<String>();
        //Get the object type from object name. Here I've used Event Object.
        Schema.SObjectType objType = Schema.getGlobalDescribe().get('Event');
        
        //Describe the sObject using its object type.
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        
        //Get the specific field information from field name. Here I've used custom field ElixirSuite__Week_Days__c of Event object.
        Schema.DescribeFieldResult objFieldInfo = objDescribe.fields.getMap().get('ElixirSuite__Week_Days__c').getDescribe();
        
        //Get the picklist field values.
        List<Schema.PicklistEntry> picklistvalues = objFieldInfo.getPicklistValues();
        
        //Add the picklist values to list.
        for(Schema.PicklistEntry plv: picklistvalues) {
            plValues.add(plv.getValue());
        }        
        return plValues;
    }
    
    // For Time zone picklist
    @AuraEnabled
    public static List<String> pickList() {
        List<String> regList = new List<String>(); 
        //Schema.DescribeFieldResult plistvalues = Schema.getGlobalDescribe().get(obj).getDescribe().fields.getMap().get(str).getDescribe();
        List<PicklistEntry> entries = Schema.SObjectType.User.fields.TimeZoneSidKey.picklistValues;
        for(PicklistEntry ent:entries)     {
            regList.add(ent.getLabel());
            System.debug('Value = ' +ent.getValue() +' , Label = ' +ent.getLabel());
        }
        
        return regList;
    }
    

    @AuraEnabled
    public  static List<Event> functionSave(DateTime startDateTime, DateTime endDateTime, String roomID,
                                     String subject, List<String> patientIds, List<String> patientGroupId,
                                     List<String> practitionerIds, List<String> coFacilitatorIds, List<String> relatedBusinessId,
                                     List<String> equipmentIds,Boolean repeat, List<String> weekDays,String tzIds,List<Event> evList,String assignedTo){
                                         
                                         Date targetDate = Date.newInstance(startDateTime.year(), startDateTime.month(), startDateTime.day());
                                         Time targetTime = Time.newInstance(startDateTime.hour(), startDateTime.minute(), startDateTime.second(), startDateTime.millisecond()); 
                                         Date targetEndDate = Date.newInstance(endDateTime.year(), endDateTime.month(), endDateTime.day()); 
                                         Time targetEndTime = Time.newInstance(endDateTime.hour(), endDateTime.minute(), endDateTime.second(), endDateTime.millisecond());                                                                                 
                                         TimeZone targetTimezone = TimeZone.getTimeZone(tzIds);                                                                                   
                                         Integer offsetSecondsForStartTime = targetTimezone.getOffset(targetDate) / 1000;                                                                                  
                                         Integer offsetSecondsForEndTime = targetTimezone.getOffset(targetEndDate) /1000;                                                                                  
                                         Datetime dtGMTStartTime = Datetime.newInstance(targetDate, targetTime).addSeconds(-offsetSecondsForStartTime);                                                                                   
                                         Datetime dtGMTEndTime = Datetime.newInstance(targetEndDate, targetEndTime).addSeconds(-offsetSecondsForEndTime);                                                                               
                                         system.debug('dtGMTStartTime ====='+dtGMTStartTime );
                                         system.debug('dtGMTEndTime ====='+dtGMTEndTime );
                                         
                                         // For techTracking Id
                                         DateTime myDateTime = DateTime.now();
                                         long dtTimeStamp = myDateTime.getTime();
                                         ExceptionLog.logDebugString('Tech Tracking ID==' + dtTimeStamp);   
                                         
                                         // Set<String> lstPtrTime = new  Set<String>();
                                         // for(Event evt:evList){
                                         //lstPtrTime.add(evt.ElixirSuite__Practitioner_Start_Time__c); 
                                         // }
                                         Set<Id> lstOfWhatIds = new Set<Id>(); 
                                         
                                         //For Room IDs
                                         if(roomID!=null) { 
                                             lstOfWhatIds.add(roomID);
                                             ExceptionLog.logDebugString('Room ID ==' + roomID);
                                         }                                             
                                         //For Patient IDs
                                         for(String strPatientID: patientIds){
                                             ExceptionLog.logDebugString('Patiend ID ==' + strPatientID);
                                             lstofWhatIds.add(strPatientID); 
                                         }                                         
                                         //For Patient IDs in the group(s)
                                         List<ElixirSuite__Group_Patient__c> groupmemberList= [Select ElixirSuite__Current_Patient_Name__c from ElixirSuite__Group_Patient__c 
                                                                                               where ElixirSuite__Group_Name__c IN:patientGroupId WITH SECURITY_ENFORCED];
                                         for(ElixirSuite__Group_Patient__c strRecord: groupmemberList){
                                             ExceptionLog.logDebugString('Patiend ID In the Group ==' + strRecord.ElixirSuite__Current_Patient_Name__c);
                                             lstofWhatIds.add(strRecord.ElixirSuite__Current_Patient_Name__c); 
                                         }                                          
                                         //For Business Account IDs
                                         for(String strID: relatedBusinessId){
                                             ExceptionLog.logDebugString('Business ID ==' + strID);   
                                             lstofWhatIds.add(strID); 
                                         }                                         
                                         //For Equipment  IDs
                                         for(String strID: equipmentIds){
                                             ExceptionLog.logDebugString('Equipment ID ==' + strID);   
                                             lstofWhatIds.add(strID); 
                                         }                                         
                                         ExceptionLog.logDebugString('List of all WhatIDs ===='+lstOfWhatIds);
                                         
                                         //===WHO IDs (typically Contacts e.g. Practitioner, Cofacilitator)
                                         Set<Id> lstOfWhoIds = new Set<Id>(); 
                                         //For Practitioner IDs
                                         for(String strID: practitionerIds){
                                             ExceptionLog.logDebugString('Practitioner ID ==' + strID);   
                                             lstOfWhoIds.add(strID); 
                                         }
                                         //For Cofacilitator IDs
                                         for(String strID: coFacilitatorIds){
                                             ExceptionLog.logDebugString('Co facilitator ID ==' + strID);   
                                             lstOfWhoIds.add(strID); 
                                         }
                                         List<Contact> contacts =[SELECT Id,ElixirSuite__Time_Zone__c FROM Contact WHERE Id IN:lstOfWhoIds WITH SECURITY_ENFORCED];
                                         Map<Id,Contact> contactsMap = new Map<Id,Contact>(contacts);
                                         
                                         ExceptionLog.logDebugString('List of all WhoIDs ===='+lstOfWhoIds);
                                         Date endDate = endDateTime.date();
                                         final Map<String,Integer> DAYS_MAP = new Map<String,Integer>{'Sunday'=>1,'Monday'=>2,'Tuesday'=>4,'Wednesday'=>8,'Thursday'=>16,'Friday'=>32,'Saturday'=>64};
                                             List<String> daysArray;
                                         Integer daysCount = 0; 
                                         
                                         for(String da: weekDays){
                                             daysCount+= DAYS_MAP.get(da);
                                             
                                         }
                                         
                                         List<Event> lstEventsToBeAdded = new List<Event>();
                                         for(Id whatIds:lstOfWhatIds){
                                             if(repeat == false){
                                                 Event objEvent = New Event();
                                                 objEvent.OwnerId = assignedTo;
                                                 objEvent.StartDateTime = dtGMTStartTime;                                                   
                                                 objEvent.EndDateTime = dtGMTEndTime;
                                                 ExceptionLog.logDebugString('StartDateTime====='+objEvent.StartDateTime);
                                                 ExceptionLog.logDebugString('EndDateTime====='+objEvent.EndDateTime);
                                                 objEvent.Subject =subject;
                                                 objEvent.WhatId = whatIds;
                                                 objEvent.ElixirSuite__TechTracking_ID__c = ''+dtTimeStamp;
                                                 for(Id whoIds:lstOfWhoIds){
                                                     objEvent.ElixirSuite__Practitioner__c=whoIds;
                                                     objEvent.whoId=whoIds;                                                     
                                                     if(contactsMap.containsKey(objEvent.WhoId)){
                                                 Contact cont = contactsMap.get(objEvent.WhoId);
                                                 System.debug('Dates$$'+ cont.ElixirSuite__Time_Zone__c);
                                                 
                                                 objEvent.ElixirSuite__Practitioner_s_Time_Zone__c = cont.ElixirSuite__Time_Zone__c;
                                                 objEvent.ElixirSuite__Practitioner_Start_Time__c = displayZone(dtGMTStartTime, cont.ElixirSuite__Time_Zone__c);
                                                 
                                                 objEvent.ElixirSuite__Practitioner_End_Time__c = displayZone(dtGMTEndTime, cont.ElixirSuite__Time_Zone__c);
                                            
                                             }
                                                     
                                                 }
                                                 lstEventsToBeAdded.add(objEvent);
                                             }
                                             else if(repeat == true && weekDays.size()>0){
                                                 Event event = new Event();
                                                 event.OwnerId = assignedTo;
                                                 event.WhatId = whatIds;
                                                 ExceptionLog.logDebugString('WhatID ==' + whatIds);                                                
                                                 event.Subject =subject;                                           
                                                 event.IsRecurrence = true;
                                                for(Id whoIds:lstOfWhoIds){
                                                     event.ElixirSuite__Practitioner__c=whoIds;
                                                     event.whoId=whoIds; 
                                                     if(contactsMap.containsKey(event.whoId)){
                                                 Contact cont = contactsMap.get(event.whoId);
                                                 System.debug('Dates$$'+ cont.ElixirSuite__Time_Zone__c);                                                 
                                                 event.ElixirSuite__Practitioner_s_Time_Zone__c = cont.ElixirSuite__Time_Zone__c;
                                                 event.ElixirSuite__Practitioner_Start_Time__c = displayZone(dtGMTStartTime, cont.ElixirSuite__Time_Zone__c);
                                                 event.ElixirSuite__Practitioner_End_Time__c = displayZone(dtGMTEndTime, cont.ElixirSuite__Time_Zone__c);
                                             
                                            
                                             }                                                    
                                                 }
                                                 event.DurationInMinutes = endDateTime.hour()*60 + endDateTime.minute() - startDateTime.hour()*60 + startDateTime.minute();
                                                 event.ElixirSuite__TechTracking_ID__c = ''+dtTimeStamp;
                                                 event.RecurrenceDayOfWeekMask = daysCount;                                                
                                                 event.RecurrenceStartDateTime = dtGMTStartTime; 
                                                 event.RecurrenceEndDateOnly =endDate;                                                
                                                 event.RecurrenceType = 'RecursEveryWeekday';
                                                 lstEventsToBeAdded.add(event);
                                             }
                                              
                                         }
                                         for(Id whoIds:lstOfWhoIds){
                                             Event objEvent = New Event();
                                             if(repeat == false){
                                                 ExceptionLog.logDebugString('Inside WhoID Event Loop');
                                                 for(Id whatIds:lstOfWhatIds){
                                                     objEvent.OwnerId = assignedTo;
                                                     objEvent.WhatId = whatIds;
                                                     if(contactsMap.containsKey(objEvent.WhoId)){
                                                 Contact cont = contactsMap.get(objEvent.WhoId);
                                                 System.debug('Dates$$'+ cont.ElixirSuite__Time_Zone__c);
                                                 
                                                 objEvent.ElixirSuite__Practitioner_s_Time_Zone__c = cont.ElixirSuite__Time_Zone__c;
                                                 objEvent.ElixirSuite__Practitioner_Start_Time__c = displayZone(dtGMTStartTime, cont.ElixirSuite__Time_Zone__c);
                                                 
                                                 objEvent.ElixirSuite__Practitioner_End_Time__c = displayZone(dtGMTEndTime, cont.ElixirSuite__Time_Zone__c);
                                            
                                             }
                                                 }
                                                 objEvent.StartDateTime = dtGMTStartTime;                                                    
                                                 objEvent.EndDateTime = dtGMTEndTime;
                                                 objEvent.Subject =subject;
                                                 objEvent.whoId = whoIds;
                                                 objEvent.ElixirSuite__Practitioner__c=whoIds; 
                                                 objEvent.ElixirSuite__TechTracking_ID__c = ''+dtTimeStamp;
                                                 lstEventsToBeAdded.add(objEvent);
                                             }
                                             else if(repeat == true && weekDays.size()>0){
                                                for(Id whatIds:lstOfWhatIds){
                                                     objEvent.WhatId = whatIds;
                                                 }
                                                 objEvent.OwnerId = assignedTo;
                                                 objEvent.WhoId = whoIds;
                                                 objEvent.ElixirSuite__Practitioner__c=whoIds;
                                                 ExceptionLog.logDebugString('WhoID ==' + whoIds);                                                
                                                 objEvent.Subject =subject;
                                                 objEvent.IsRecurrence = true;
                                                 objEvent.DurationInMinutes = endDateTime.hour()*60 + endDateTime.minute() - startDateTime.hour()*60 + startDateTime.minute();
                                                 objEvent.RecurrenceDayOfWeekMask = daysCount;  
                                                 objEvent.ElixirSuite__TechTracking_ID__c = ''+dtTimeStamp;
                                                 objEvent.RecurrenceStartDateTime = dtGMTStartTime;                                                 
                                                 objEvent.RecurrenceEndDateOnly =endDate;                                              
                                                 objEvent.RecurrenceType = 'RecursEveryWeekday';
                                                 lstEventsToBeAdded.add(objEvent);
                                                 System.debug('lstEventsToBeAdded'+lstEventsToBeAdded);
                                             }
                                             if(contactsMap.containsKey(objEvent.WhoId)){
                                                 Contact cont = contactsMap.get(objEvent.WhoId);
                                                 System.debug('Dates$$'+ cont.ElixirSuite__Time_Zone__c);
                                                 
                                                 objEvent.ElixirSuite__Practitioner_s_Time_Zone__c = cont.ElixirSuite__Time_Zone__c;
                                                 objEvent.ElixirSuite__Practitioner_Start_Time__c = displayZone(dtGMTStartTime, cont.ElixirSuite__Time_Zone__c);
                                                 
                                                 objEvent.ElixirSuite__Practitioner_End_Time__c = displayZone(dtGMTEndTime, cont.ElixirSuite__Time_Zone__c);
                                            
                                             }
                                         }
                                        // if(Schema.sObjectType.Event.isCreateable()){
                                            DMLManager.insertAsUser(lstEventsToBeAdded);
                                           // insert lstEventsToBeAdded;
                                         //}
                                         return lstEventsToBeAdded;
                                     }
    
    public static String displayZone(Datetime convertData, String zone){
        if(convertData==null || String.isBlank(zone)){
            return '';
        }
        String data = String.valueOf(convertData);
        Datetime dt = convertData;
        TimeZone target = TimeZone.getTimeZone(zone);        
        //return target.format('yyyy-MM-dd HH:ss a z', target.getID()) + ' ' + zone;
        return dt.format('yyyy-MM-dd HH:mm a z',target.getId());
    }
}
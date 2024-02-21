public without sharing class confirmAppointment {
    
    @AuraEnabled
    public static InitWrapper wrapperRec(string recId,string proId,string practId ){
        string patientId; 
        patientId =getPatientId();
        if(patientId == NULL){
            patientId = recId;
        }
        InitWrapper wrpr = new InitWrapper();
        Provider__c prorec = [SELECT Id, Name, ElixirSuite__Provider_City__c, ElixirSuite__Provider_Code__c, 
                              ElixirSuite__Provider_State__c, ElixirSuite__Address__c, ElixirSuite__Provider_Zip__c 
                              FROM ElixirSuite__Provider__c 
                              Where Id =: proId
                              WITH SECURITY_ENFORCED];
        Account accrec = [SELECT Id, Name, Phone, Email_Id__c
                          FROM Account 
                          Where Id =: patientId
                          WITH SECURITY_ENFORCED];
        Contact conName = [SELECT Id, Name, ElixirSuite__Practitioner_User__c,ElixirSuite__Virtual_Meeting_Link__c 
                           FROM Contact 
                           where id =: practId 
                           WITH SECURITY_ENFORCED];   
        
        List<ElixirSuite__Disclaimer__c> generalDisclaimer = [SELECT Id, ElixirSuite__Description__c, 
                                                              ElixirSuite__Type__c, ElixirSuite__Status__c, 
                                                              ElixirSuite__Require_Agreement__c, ElixirSuite__Priority_Order__c, 
                                                              ElixirSuite__Template_Procedure__c, ElixirSuite__Template_Procedure__r.Name,
                                                              ElixirSuite__Practitioner__c,ElixirSuite__Input_type__c 
                                                              FROM ElixirSuite__Disclaimer__c
                                                              WHERE ElixirSuite__Status__c = 'Active'
                                                              WITH SECURITY_ENFORCED ORDER BY ElixirSuite__Priority_Order__c ASC];
        
        
        if(prorec != null && accrec != null && conName != null){
            wrpr.providerRecord = prorec;
            wrpr.accrecord = accrec;
            wrpr.conrecord = conName;
        }
        
        if(generalDisclaimer.size() >0 && generalDisclaimer != null){
            wrpr.generalDiscLst = generalDisclaimer;
        }
        
        return wrpr;
    }
    
    public class InitWrapper {
        @AuraEnabled public Provider__c providerRecord; 
        @AuraEnabled public Account accrecord;
        @AuraEnabled public Contact conrecord;
        @AuraEnabled public String eventId;
        @AuraEnabled public List<ElixirSuite__Disclaimer__c> generalDiscLst;
    }
    @AuraEnabled
    public static InitWrapper saveMethod(DateTime startDate, DateTime endDate,string whatId, string locationId,
                                         string practitonerId,string acctype, string accTypeLabel, string roomId, Boolean confirmAppointment,Boolean checkbox,string link,string attendees ,string additionalComments, String disclaimerLst ){
                                             InitWrapper wrpr = new InitWrapper(); 
                                             boolean exceptionOccurred = false;
                                             List<Event> lstEvent = new List<Event>();  
                                             try{

                                                 
                                                 string patientId;

                                                 List<ElixirSuite__Disclaimer_Response__c> discInsInv = new List<ElixirSuite__Disclaimer_Response__c >();
                                                 Map<String, Object> objDataLst = new Map<String, Object>();
                                                 List<Object> apexDataLst = new List<Object>();
                                                 if(String.isNotBlank(disclaimerLst) && String.isNotEmpty(disclaimerLst)){
                                                     objDataLst =(Map<String, Object>) JSON.deserializeUntyped(disclaimerLst);
                                                     
                                                     if(objDataLst!=null && !objDataLst.isEmpty()){
                                                         apexDataLst = (List<Object>) objDataLst.get('keysToSave');
                                                     }
                                                     
                                                 }
                                                 
                                                 patientId = getPatientId();
                                                 String appointmentCreatedVia='';
                                                 if(patientId == NULL){
                                                     patientId = whatId;
                                                     appointmentCreatedVia='EHR';
                                                 }
                                                 else{
                                                    appointmentCreatedVia='Patient Portal';
                                                 }
                                                 Datetime startDatetime = Datetime.valueOf(startDate);
                                                 Datetime endDatetime = Datetime.valueOf(endDate);
                                                 if(!confirmAppointment){
                                                     List<Event> entAccList = [Select Id FROM Event Where 
                                                                               WhatId =:patientId
                                                                               AND ((StartDateTime >= :startDatetime AND StartDateTime < :endDatetime)
                                                                                    OR (EndDateTime > :startDatetime AND EndDateTime <= :endDatetime))
                                                                               AND (ElixirSuite__Status__c = 'Scheduled'
                                                                                    OR ElixirSuite__Status__c = 'Rescheduled')     
                                                                               WITH SECURITY_ENFORCED LIMIT 1];
                                                     if(entAccList != null && entAccList.size() > 0) {
                                                         throw new AuraHandledException('Patient already has an appointment for this time slot.');                                 
                                                     }
                                                 }
                                                 Contact conName = [SELECT Id, Name, ElixirSuite__Practitioner_User__c 
                                                                    FROM Contact 
                                                                    where id =: practitonerId 
                                                                    WITH SECURITY_ENFORCED];   
                                                 String practId = conName.ElixirSuite__Practitioner_User__c;                             
                                                 
                                                 List<Event> entList = [Select Id FROM Event Where 
                                                                        OwnerId =:practId
                                                                        AND ElixirSuite__Location__c = :locationId
                                                                        AND ((StartDateTime >= :startDate
                                                                              AND EndDateTime <= :endDate)
                                                                             OR (StartDateTime < :startDate
                                                                                 AND EndDateTime > :endDate)
                                                                             OR (StartDateTime >= :startDate
                                                                                 AND StartDateTime < :endDate
                                                                                 AND  EndDateTime > :endDate)
                                                                             OR (StartDateTime < :startDate
                                                                                 AND EndDateTime > :startDate
                                                                                 AND  EndDateTime <= :endDate))
                                                                        AND (ElixirSuite__Status__c = 'Scheduled'
                                                                             OR ElixirSuite__Status__c = 'Rescheduled')     
                                                                        WITH SECURITY_ENFORCED LIMIT 1];                              
                                                 
                                                 if(entList != null && entList.size() > 0) {
                                                     throw new AuraHandledException('Appointment is already booked for this slot, please select a new time.');                                 
                                                 }
                                                 else{                           
                                                     if(roomId != null && !confirmAppointment){
                                                         List<Event> roomConflictList = [SELECT Id FROM Event
                                                                                         WHERE ElixirSuite__Room__c = :roomId AND ElixirSuite__Location__c = :locationId
                                                                                         AND ((StartDateTime >= :startDatetime AND StartDateTime < :endDatetime)
                                                                                              OR (EndDateTime > :startDatetime AND EndDateTime <= :endDatetime))
                                                                                         AND (ElixirSuite__Status__c = 'Scheduled'
                                                                                              OR ElixirSuite__Status__c = 'Rescheduled')
                                                                                         WITH SECURITY_ENFORCED LIMIT 1];
                                                         if (roomConflictList != null && roomConflictList.size() > 0) {
                                                             throw new AuraHandledException('The room is already booked for this slot, please select a new room or time.');
                                                         }
                                                     }
                                                     Event objevent = new Event();
                                                     objevent.ElixirSuite__Room__c = roomId;
                                                     objevent.StartDateTime = startDatetime;
                                                     objevent.EndDateTime = endDatetime;
                                                     objevent.WhatId = patientId;
                                                     objevent.ElixirSuite__Location__c = locationId;
                                                     objevent.ElixirSuite__Status__c = 'Scheduled';
                                                     objevent.ElixirSuite__Practitioner__c=practitonerId;
                                                     objevent.ElixirSuite__Appointment_Type__c = acctype;
                                                     if(String.isNotBlank(accTypeLabel) && String.isNotEmpty(accTypeLabel)){
                                                     objevent.ElixirSuite__Appointment_Type_1__c = accTypeLabel;
                                                     }
                                                     objevent.ElixirSuite__Schedule_Zoom_Meeting__c = checkbox ;
                                                     objevent.ElixirSuite__Virtual_Meeting_Link__c = link;
                                                     objevent.ElixirSuite__Additional_Attendees__c = attendees;
                                                     objevent.ElixirSuite__Appointment_created_via__c=appointmentCreatedVia;
                                                     if(conName != null){
                                                         objevent.OwnerId= conName.Practitioner_User__c;
                                                         objevent.Subject = 'Appointment with ' +  conName.Name;
                                                     }
                                                     lstEvent.add(objevent);
                                                     insert lstEvent;
                                                     wrpr.eventId = lstEvent[0].Id;
                                                     addPractitionersToCareTeam(practitonerId, patientId);
                                                     //When the custom setting ElixirSuite__Notification_for_New_Appointment__c is enabled in Elixir_Custom_Setting__c, it allows sending notifications to the patient. 
                                                     ElixirSuite__Elixir_Custom_Setting__c settings = ElixirSuite__Elixir_Custom_Setting__c.getOrgDefaults();
                                                     if(settings.ElixirSuite__Notification_for_New_Appointment__c == true){
                                                         NewAppointmentNotificationHandler.notifyPatientForNewAppointment(lstEvent);
                                                     }

                                                     if (apexDataLst != null && apexDataLst.size() > 0) {
                                                         if (lstEvent != null && lstEvent.size() > 0) {
                                                             
                                                             for(Object obj : apexDataLst){
                                                                 
                                                                 
                                                                 Map<String,Object> mpData = ( Map<String,Object>) obj;
                                                                 System.debug('mpData***'+mpData);
                                                                 ElixirSuite__Disclaimer_Response__c discResRec = new ElixirSuite__Disclaimer_Response__c();
                                                                 
                                                                 discResRec.Name  = lstEvent[0].Subject;
                                                                 discResRec.ElixirSuite__Name__c  = lstEvent[0].Subject + ' - ' + String.valueof(startDatetime.format('yyyy-MM-dd'));
                                                                 discResRec.ElixirSuite__Patient__c  = patientId;
                                                                 discResRec.ElixirSuite__Event_Name__c  = lstEvent[0].Subject;
                                                                 discResRec.ElixirSuite__Event_Id__c  = lstEvent[0].Id;
                                                                 discResRec.ElixirSuite__Description__c  = String.valueof(mpData.get('description'));
                                                                 discResRec.ElixirSuite__Disclaimer__c  = String.valueof(mpData.get('disclaimerId'));
                                                                 discResRec.ElixirSuite__Input_Text__c  = String.valueof(mpData.get('inputBox'));
                                                                 
                                                                 if(Boolean.valueof(mpData.get('agreement'))){
                                                                     discResRec.ElixirSuite__Acceptance_from_Patient__c  = 'Yes';
                                                                 }
                                                                 else{
                                                                     discResRec.ElixirSuite__Acceptance_from_Patient__c  = 'No';
                                                                 }
                                                                 
                                                                 discInsInv.add(discResRec);
                                                             }
                                                             
                                                         }
                                                     }
                                                     
                                                     if(discInsInv != null && discInsInv.size() >0){
                                                         DMLManager.insertAsUser(discInsInv);
                                                     }
                                                     
                                                     if (lstEvent != null && lstEvent.size() > 0) {
                                                         if(additionalComments != null && additionalComments != '' ){
                                                             Type contentNoteType = Type.forName('ContentNote');
                                                             if(contentNoteType != null && contentNoteType.newInstance() instanceof SObject){
                                                                 
                                                                 String objectName = 'ContentNote';
                                                                 sObject sObj = Schema.getGlobalDescribe().get(objectName).newSObject(); 
                                                                 //Create ContentNote
                                                                 sObj.put('Content', Blob.valueof(additionalComments));
                                                                 sObj.put('Title', 'Appointment Comments');
                                                                 
                                                                 DMLManager.insertAsUser(sObj);
                                                                 ContentDocumentLink clnk = new ContentDocumentLink();
                                                                 clnk.LinkedEntityId = lstEvent[0].Id;
                                                                 clnk.ContentDocumentId = sObj.Id;
                                                                 clnk.ShareType = 'I';
                                                                 DMLManager.insertAsUser(clnk);
                                                             }
                                                             else{
                                                                 throw new AuraHandledException('Please contact the administrator to enable content notes to add comments.');
                                                                 
                                                             }
                                                         }
                                                         
                                                     }
                                                     
                                                 }
                                             }catch (Exception e) {
                                                 exceptionOccurred = true;
                                                 ExceptionLog.logError(e);
                                                 //throw new AuraHandledException(e.getMessage());
                                             }
                                             if(!exceptionOccurred && lstEvent != null && lstEvent.size() > 0){
                                                 List<Elixir_Pluggable_Classes__mdt> pluggableClass = new List<Elixir_Pluggable_Classes__mdt>();
                                                 // virtualClass = ScheduleAppointmentIntegration -- for reference.
                                                 String virtualClassName;
                                                 pluggableClass = [SELECT DeveloperName,Virtual_Class__c 
                                                                   FROM Elixir_Pluggable_Classes__mdt 
                                                                   WHERE DeveloperName='ScheduleAppointment' WITH SECURITY_ENFORCED];
                                                 if(pluggableClass != null && !pluggableClass.isEmpty()){
                                                     virtualClassName = pluggableClass[0].Virtual_Class__c;
                                                 }
                                                 if(virtualClassName != '' && virtualClassName !=null){
                                                     Callable cls = (Callable) Type.forName(virtualClassName).newInstance();
                                                     cls.call('scheduleAppointment', new Map<String, Object> {
                                                         'eventId' => wrpr.eventId
                                                             });
                                                 }
                                             }
                                             return wrpr;
                                         }
    
    public static void addPractitionersToCareTeam(string practionerId,String patientId){
        // Check if the practitioner is already a care team member for the patient
        List<AccountContactRelation> existingCareTeamMembers=[SELECT Id, AccountId, ContactId, IsActive, 
                                                              IsDirect, ElixirSuite__Care_Team_Role__c, 
                                                              ElixirSuite__Relationship__c, ElixirSuite__Contact_Type__c 
                                                              FROM AccountContactRelation 
                                                              where AccountId =:patientId AND 
                                                              IsDirect=false AND 
                                                              ContactId = :practionerId  AND 
                                                              ElixirSuite__Contact_Type__c ='Care team' WITH SECURITY_ENFORCED]; 
        // If the practitioner is not a care team member, relate the practitioner as a care team member
        if (existingCareTeamMembers.isEmpty()) {
            AccountContactRelation newCareTeamMember = new AccountContactRelation();
            newCareTeamMember.AccountId = patientId;
            newCareTeamMember.ContactId = practionerId;
            newCareTeamMember.IsActive = true; // Set IsActive to true to make the record active
            newCareTeamMember.ElixirSuite__Care_Team_Role__c = 'Doctor';
            
            // Insert the new care team member record
            //  insert newCareTeamMember;
        }
        
    }
    @AuraEnabled
    public static String getPatientId() {
        String patientId='';
        String uId = UserInfo.getUserId();
        List<User> userRecs = Database.query('SELECT id,ContactId,AccountId,IsPortalEnabled FROM User WHERE Id =:uId');
        if((Boolean)userRecs[0].get('IsPortalEnabled')){
            patientId = (String)userRecs[0].get('AccountId');
            return patientId;
        }else{
            return NULL;
        }
    }
    @AuraEnabled
    public static String getNextAvailableSlot(string locationId, string practitonerId, string roomId) {
        List<ElixirSuite__Work_Schedule__c> workSch = [
            SELECT Id, ElixirSuite__Start_Date__c, ElixirSuite__Start_Time__c, ElixirSuite__End_Time__c,
            ElixirSuite__Practitioner_Name__c, ElixirSuite__Provider_Location__c, ElixirSuite__End_Date__c,
            ElixirSuite__Days__c, ElixirSuite__Appointment_Types__c
            FROM ElixirSuite__Work_Schedule__c
            WHERE ElixirSuite__Practitioner_Name__c =: practitonerId
            AND ElixirSuite__Provider_Location__c =: locationId
            WITH SECURITY_ENFORCED];
        DateTime desiredStartTime = null;
        DateTime desiredEndTime = null;
        
        for (ElixirSuite__Work_Schedule__c workSchedule : workSch) {
            desiredStartTime = DateTime.newInstance(workSchedule.ElixirSuite__Start_Date__c, workSchedule.ElixirSuite__Start_Time__c);
            desiredEndTime = DateTime.newInstance(workSchedule.ElixirSuite__End_Date__c, workSchedule.ElixirSuite__End_Time__c);
        }
        List<Event> conflictingEvents = [
            SELECT StartDateTime, EndDateTime
            FROM Event
            WHERE ElixirSuite__Room__c =: roomId
            AND (StartDateTime >= :desiredStartTime AND StartDateTime < :desiredEndTime)
            AND (ElixirSuite__Status__c = 'Scheduled' OR ElixirSuite__Status__c = 'Rescheduled')
            WITH SECURITY_ENFORCED
            ORDER BY EndDateTime DESC
            LIMIT 1
        ];
        
        if (conflictingEvents.isEmpty()) {
            String finalDate = desiredStartTime.format('MM-dd-yyyy hh:mm a');
            return finalDate;
        } else {
            // Print the end time of the first conflicting event
            return conflictingEvents[0].EndDateTime.format('MM-dd-yyyy hh:mm a');
        }
        
        // return null;
    }
     @AuraEnabled
    public static Boolean enableScheduleZoomMeeting() {
        List<ElixirSuite__Master_Object__c> masterRecord = new List<ElixirSuite__Master_Object__c>();
        masterRecord =[select name,ElixirSuite__Patient_Tile_Entity__c,ElixirSuite__Allow_patient_to_schedule_zoom_meeting__c, ElixirSuite__Enable_Pay_Now__c, recordtype.name from ElixirSuite__Master_Object__c where RecordType.name='Patient Portal' and ElixirSuite__Patient_Tile_Entity__c='Portal Definition' WITH SECURITY_ENFORCED limit 1 ];
        if(masterRecord[0].ElixirSuite__Allow_patient_to_schedule_zoom_meeting__c)
        {
            return masterRecord[0].ElixirSuite__Allow_patient_to_schedule_zoom_meeting__c;
        }
        else{
            return false;
        }
    }
}
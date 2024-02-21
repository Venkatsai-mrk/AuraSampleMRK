public with sharing class EventNotesViewHelper {
    @AuraEnabled
    public static InitWrapperDomain fetchNotesListViewData(String acoountId) {
        Id recId = Schema.SObjectType.Notes__c.getRecordTypeInfosByDeveloperName().get('Individual_Session_Notes').getRecordTypeId();
        String query = formulateQueryString('ElixirSuite__Notes__c') + ' WHERE ElixirSuite__Account__c = : acoountId  AND RecordTypeId = : recId AND ElixirSuite__Session_Name__c!=null';                                       
        //   ElixirOEM_TimelineHelper.mDebugUntruncated(query);
        ElixirSuite__Notes__c[] ntsArr = Database.query(query);
        
        Set<Id> ntsEventIds = new Set<Id>(); 
        for(ElixirSuite__Notes__c nt : ntsArr){
            ntsEventIds.add(nt.ElixirSuite__EventId__c);
        }
        
        String evtQuery = formulateQueryString('Event')   + ' WHERE ID IN : ntsEventIds ';
        Event[] relatedEventArr = Database.query(evtQuery);
        InitWrapperDomain retObj = new InitWrapperDomain();
        System.debug('ntsArr b4 '+ntsArr);
        retObj.ntsArr = ntsArr;
        retObj.relatedEventArr = relatedEventArr;
        return retObj;
    }
    
    public static String formulateQueryString(String objectName) {
        String fieldApiNames =  ElixirOEM_TimelineHelper.getAllFieldsNameOfObject(objectName);
        fieldApiNames+=' FROM '+ String.escapeSingleQuotes(objectName);
        return fieldApiNames;
    }
    public class InitWrapperDomain{
        @AuraEnabled public ElixirSuite__Notes__c[] ntsArr;
        @AuraEnabled public Event[] relatedEventArr;
        @AuraEnabled public String coFaciliator;
        @AuraEnabled public String patientName;
        @AuraEnabled public String allGroupNames;
        @AuraEnabled public String allPatientName;
        @AuraEnabled public String AssignedToName;
        @AuraEnabled public String eventCreatedByName;
        @AuraEnabled public  String jsonData;
    }
    @AuraEnabled
    public static InitWrapperDomain fetchNoteRecord(String noteId) {
        ElixirSuite__Notes__c[] noteRecord = [SELECT ID,ElixirSuite__EventId__c FROM ElixirSuite__Notes__c WHERE ID = : noteId with security_enforced];
        String eventId = '';
        if(noteRecord!=null && noteRecord.size()>0){
            eventId = noteRecord[0].ElixirSuite__EventId__c;
        }
        Event[] evtArr =  [SELECT ID,ElixirSuite__Event_Data_Object__c FROM Event where id = : eventId WITH SECURITY_ENFORCED];
        String eventDataObject = '';
        if(evtArr!=null && evtArr.size()>0){
            eventDataObject = evtArr[0].ElixirSuite__Event_Data_Object__c;
        }
        ElixirSuite__Event_Data_Object__c[] evtDataObj = [SELECT ID,ElixirSuite__JSON_Data__c FROM ElixirSuite__Event_Data_Object__c WHERE ID = : eventDataObject WITH SECURITY_ENFORCED];
        String jsonData = '';
        if(evtDataObj!=null && evtDataObj.size()>0){
            jsonData = evtDataObj[0].ElixirSuite__JSON_Data__c;
        }
        InitWrapperDomain retObj = new InitWrapperDomain();
        String query = formulateQueryString('ElixirSuite__Notes__c') + ' WHERE Id = : noteId';           
        ElixirSuite__Notes__c[] ntsArr =   Database.query(query);
        Event[] relatedEventArr = new List<Event>();
        try{
        if(ntsArr!=null && ntsArr.size()>0){
            String ntId = ntsArr[0].ElixirSuite__EventId__c;
            String evtQuery = formulateQueryString('Event')   + ' WHERE ID =: ntId ';
            relatedEventArr = Database.query(evtQuery);
            if(relatedEventArr!=null && relatedEventArr.size()>0){
                fetchCreateByName(relatedEventArr[0].CreatedById,retObj);
                fetchAssignedToName(relatedEventArr[0].OwnerId,retObj);
            }
        }
        if(relatedEventArr!=null && relatedEventArr.size()>0){
            fetchEventDataResults(relatedEventArr[0],retObj);
        }
        fetchPatientName(noteId,retObj);
        System.debug('ntsArr b4 '+ntsArr);
        retObj.ntsArr = ntsArr;
        retObj.relatedEventArr = relatedEventArr;
        retObj.jsonData = jsonData;
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        return retObj;
            
    }
    public static void fetchCreateByName(String crreatedById, InitWrapperDomain retObj){   
        if(String.isNotBlank(crreatedById)){
            User[] ownerUser = [SELECT ID,Name FROM User WHERE ID = : crreatedById with security_enforced];
            if(ownerUser!=null && ownerUser.size()>0){
                retObj.eventCreatedByName = ownerUser[0].Name;
            }
        }
    }
    public static void fetchAssignedToName(String ownerId, InitWrapperDomain retObj){       
        if(String.isNotBlank(ownerId)){
            User[] ownerUser = [SELECT ID,Name FROM User WHERE ID = : ownerId with security_enforced];
            if(ownerUser!=null && ownerUser.size()>0){
                retObj.AssignedToName = ownerUser[0].Name;
            }
        }
    }
    public static void fetchPatientName(String ntsId, InitWrapperDomain retObj){
        ElixirSuite__Notes__c[] ntsArr = [SELECT ID,ElixirSuite__Account__r.Name FROM ElixirSuite__Notes__c WHERE ID = : ntsId with security_enforced];  
        if(ntsArr!=null && ntsArr.size()>0){
            retObj.patientName = ntsArr[0].ElixirSuite__Account__r.Name;
        }
    }
    public static void fetchEventDataResults(Event ev, InitWrapperDomain retObj){
        ElixirSuite__Event_Data_Object__c[] forAdditionalFields = new List<ElixirSuite__Event_Data_Object__c>();
        String allUserName  = '';
        String locationName = '';
        String patientGroupData = '';
        if(ev!=null){
            forAdditionalFields = [SELECT ID,ElixirSuite__Co_Facilitators__c,ElixirSuite__Provider__r.Name,
                                   ElixirSuite__Patients__c,ElixirSuite__Patient_Groups__c,ElixirSuite__JSON_Data__c
                                   FROM ElixirSuite__Event_Data_Object__c 
                                   WHERE ID = : ev.ElixirSuite__Event_Data_Object__c with security_enforced];
            
            if(forAdditionalFields!=null && forAdditionalFields.size()>0){
                fetchGroupName(forAdditionalFields[0].ElixirSuite__Patient_Groups__c,retObj);
                fetchPatientName_EventDataObj(forAdditionalFields[0].ElixirSuite__Patients__c,retObj);
                patientGroupData = forAdditionalFields[0].ElixirSuite__JSON_Data__c;
                locationName = forAdditionalFields[0].ElixirSuite__Provider__r.Name;
                String usersIdStringified = forAdditionalFields[0].ElixirSuite__Co_Facilitators__c;
                if(String.isNotBlank(usersIdStringified)){
                    System.debug('usersIdStringified '+usersIdStringified);
                    List<String> lstOfUserIDs = (List<String>)JSON.deserializeStrict(usersIdStringified, List<String>.class);
                    User[] allUsers = [SELECT ID,Name FROM User where id in : lstOfUserIDs with security_enforced];                    
                    for(User u : allUsers){
                        allUserName= allUserName + u.Name + ';';
                    }  
                }
                retObj.coFaciliator = allUserName;
            }
        }
    }
    public static void fetchPatientName_EventDataObj(String patientIds, InitWrapperDomain retObj){
        if(String.isNotBlank(patientIds)){
            List<String> patientIdLst = (List<String>)JSON.deserializeStrict(patientIds, List<String>.class);
            Set<String> myset = new Set<String>();
            myset.addAll(patientIdLst);
            List<String> allPatientName = new List<String>();
            Account[] ptientLst = [SELECT ID,Name FROM Account WHERE ID IN : patientIdLst with security_enforced];                                                        
            for(Account obj : ptientLst){
                allPatientName.add(obj.Name);
            }
            retObj.allPatientName = String.join( allPatientName, '; ' ); 
        }
    }
    public static void fetchGroupName(String patientGrp, InitWrapperDomain retObj){
        if(String.isNotBlank(patientGrp)){
            List<String> patientGroupId = (List<String>)JSON.deserializeStrict(patientGrp, List<String>.class);
            Set<String> myset = new Set<String>();
            myset.addAll(patientGroupId);
            List<String> allGrpName = new List<String>();
            ElixirSuite__Account_Group__c[] ptientGrpLst = [SELECT ID,Name FROM ElixirSuite__Account_Group__c 
                                                            WHERE ID IN : patientGroupId with security_enforced];
            for(ElixirSuite__Account_Group__c obj : ptientGrpLst){
                allGrpName.add(obj.Name);
            }
            retObj.allGroupNames = String.join( allGrpName, '; ' ); 
        }
    }
    @AuraEnabled
    public static void updateNoteRecord(String noteIndividual, String noteGroup,String noteRecId){
        System.debug(noteIndividual);
        System.debug(noteGroup);
        System.debug(noteRecId);
        ElixirSuite__Notes__c[] ntsArr = [SELECT ID,ElixirSuite__Note__c,ElixirSuite__Group_Notes__c,ElixirSuite__EventId__c
                                          FROM ElixirSuite__Notes__c WHERE ID = : noteRecId with security_enforced]; 
        try{
        if(ntsArr!=null && ntsArr.size()>0){
              ElixirSuite__Notes__c[] similarNotesLst = [SELECT ID,ElixirSuite__Note__c,ElixirSuite__Group_Notes__c,ElixirSuite__EventId__c
                                          FROM ElixirSuite__Notes__c WHERE ElixirSuite__EventId__c = : ntsArr[0].ElixirSuite__EventId__c 
                                                         with security_enforced]; 
            ElixirSuite__Notes__c[] toUpdate = new List<ElixirSuite__Notes__c>();
            for(ElixirSuite__Notes__c nts : similarNotesLst){
                nts.ElixirSuite__Group_Notes__c = noteGroup;
                toUpdate.add(nts);
            }
            if(Schema.sObjectType.ElixirSuite__Notes__c.isUpdateable()){
            update toUpdate;
            }
            ntsArr[0].ElixirSuite__Note__c = noteIndividual;
            ntsArr[0].ElixirSuite__Group_Notes__c = noteGroup;
            if (Schema.sObjectType.ElixirSuite__Notes__c.isUpdateable())
            {
                update ntsArr;
            }
        }
        }
            catch(Exception e){
            ExceptionLog.logError(e);
        }
        
    }
    @AuraEnabled
    public static void deleteAllEvent(List < String > lstRecordId) {
        List < String > oErrorMsg = new List < String > ();
        delete [select Id from ElixirSuite__Notes__c 
                where id IN: lstRecordId
                WITH SECURITY_ENFORCED];
    }
    
}
/* 
Updated By - Anmol Saxena
Updated Date - 12-May-2023
Description - Session notes and attendance on events detail page 
Test Class = attendanceControllerTest
*/

public with sharing class attendanceController {
    
    //Added by Anmol for LX3-8546
    @AuraEnabled
    public static newWrapper getEventPatientGroup(Id recordId){
        List<newAccountWrapper> accLst = new List<newAccountWrapper>();
        List<Id> childEventId = new List<Id>();
        List<Id> childEventWhatId = new List<Id>();
        List<Id> contentDocumentId = new List<Id>();
        List<Id> contentDocumentId2 = new List<Id>();
        List<Account> accountRecLst = new List<Account>();
        Map<String,String> evIdtoAccId = new Map<String,String>();
        Map<String,String> AccIdtoEvId = new Map<String,String>();
        Map<String,Boolean> accIdtoAttendance = new Map<String,Boolean>();
        Map<Id,ContentNote> accIdtoNotes = new Map<Id,ContentNote>();
        newWrapper w = new newWrapper();
        License_Class lCls = new License_Class();
        String grpNote='';
        
        try{
            Event ev = [SELECT  Id, StartDateTime, Subject, Location,ElixirSuite__Location__c,ElixirSuite__Location__r.Name, EndDateTime, AccountId , 
                        Description , WhatId,Facilitator__c,Co_Facilitator__c,Owner.Name
                        FROM Event 
                        WHERE Id=: recordId 
                        WITH SECURITY_ENFORCED];
            
            List<ContentDocumentLink> cdl1 = [Select Id,
                                              LinkedEntityId,
                                              ContentDocumentId
                                              FROM ContentDocumentLink
                                              WHERE LinkedEntityId = :ev.Id
                                              WITH SECURITY_ENFORCED];
            
            if(cdl1.size() >0 && cdl1 != null){
                for(ContentDocumentLink con : cdl1){
                    contentDocumentId2.add(con.ContentDocumentId);
                }
                List<ContentNote> cnt = [Select Id,
                                         Content
                                         From ContentNote
                                         Where Id IN :contentDocumentId2
                                         WITH SECURITY_ENFORCED];
                
                Blob myBlob = cnt[0].Content;
                grpNote = myBlob.toString();
            }
            
            Id relatedId = ev.WhatId;    
            String objName = String.valueOf(relatedId.getsobjecttype());       
            List<ElixirSuite__Group_Patient__c> groupPatientLst = new List<ElixirSuite__Group_Patient__c>();
            if(objName == 'ElixirSuite__Account_Group__c'){
                List<Event> lstEvent = [SELECT
                                        Id,
                                        WhatId,
                                        ElixirSuite__Parent_Event_Id__c,
                                        ElixirSuite__Attendance__c
                                        from Event
                                        where ElixirSuite__Parent_Event_Id__c=:recordId
                                        WITH SECURITY_ENFORCED];
                
                if(lstEvent.size() >0 && lstEvent != null){
                    for(Event evRec : lstEvent){
                        childEventId.add(evRec.Id);
                        childEventWhatId.add(evRec.WhatId);
                        evIdtoAccId.put(evRec.Id,evRec.WhatId);
                        AccIdtoEvId.put(evRec.WhatId,evRec.Id);
                        accIdtoAttendance.put(evRec.WhatId,evRec.ElixirSuite__Attendance__c);
                    }
                    lCls = attendanceController.LicensBasdPermission();
                    accountRecLst = [Select Id,Name,ElixirSuite__Profile_Picture__c
                                     FROM Account
                                     WHERE Id IN :childEventWhatId
                                     WITH SECURITY_ENFORCED];
                    List<ContentDocumentLink> cdl = [Select Id,
                                                     LinkedEntityId,
                                                     ContentDocumentId
                                                     FROM ContentDocumentLink
                                                     WHERE LinkedEntityId IN :childEventId
                                                     WITH SECURITY_ENFORCED];
                    Map<String,String> docIdtoEvId = new Map<String,String>();
                    Map<String,String> accIdtoNote = new Map<String,String>();
                    
                    if(cdl.size() >0 && cdl != null){
                        for(ContentDocumentLink con : cdl){
                            contentDocumentId.add(con.ContentDocumentId);
                            docIdtoEvId.put(con.ContentDocumentId,con.LinkedEntityId);
                        }
                        List<ContentNote> cnt = [Select Id,
                                                 Content
                                                 From ContentNote
                                                 Where Id IN :contentDocumentId
                                                 WITH SECURITY_ENFORCED];
                        for(ContentNote cntNote : cnt){
                            Blob myBlob = cntNote.Content;
                            if(docIdtoEvId !=null && docIdtoEvId.get(cntNote.Id)!=null){
                                accIdtoNote.put(evIdtoAccId.get(docIdtoEvId.get(cntNote.Id)),myBlob.toString());
                            }
                        }
                    }
                    System.debug('accIdtoNote'+accIdtoNote);
                    
                    for(Account acc : accountRecLst){
                        newAccountWrapper wrpRec = new newAccountWrapper();
                        wrpRec.accountId = acc.Id;
                        wrpRec.accName = acc.Name;
                        wrpRec.accProfilePic = acc.ElixirSuite__Profile_Picture__c;
                        wrpRec.attended = accIdtoAttendance.get(acc.Id);
                        wrpRec.eventId = AccIdtoEvId.get(acc.Id);
                        if(accIdtoNote.get(acc.Id)!=null){
                            wrpRec.individualNoteValue = accIdtoNote.get(acc.Id);
                        }
                        else{
                            wrpRec.individualNoteValue = '';
                        }
                        accLst.add(wrpRec);
                    }
                }   
            }
            w.eventData = ev ;
            w.accList = accLst;
            w.licenseClassValue = lCls;
            w.groupNoteValue = grpNote;
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        return w;
    }
    
    @AuraEnabled
    public static void updatePatientAttendance(String patientAttended , String groupNote , Boolean groupNoteChange){
        
        Map<String, Object> objDataLst =(Map<String, Object>) JSON.deserializeUntyped(patientAttended);
        List<Object> apexDataLst = (List<Object>) objDataLst.get('keysToSave');
        List<Event> updatedLst = new List<Event>();
        List<ContentNote> lstContentNote = new List<ContentNote>();
        List<Id> childEventId = new List<Id>();
        List<Id> accountLstId = new List<Id>();
        System.debug('groupNote***'+groupNote);
        Map<String,String> accIdToNotes = new Map<String,String>();
        Map<String,String> evIdToNotes = new Map<String,String>();
        Map<String,String> accIdtoEvId = new Map<String,String>();
        Map<String,String> accIdtoFormName = new Map<String,String>();
        Map<String,String> accIdtoFormUniqueId = new Map<String,String>();
        Map<String,Boolean> accIdtoNotesChange = new Map<String,Boolean>();
        Map<String,Boolean> evIdToAttendance = new Map<String,Boolean>();
        List<String> monthNames = new List<String>{'hello','January', 'February', 'March', 'April', 'May', 'June',
            'July', 'August', 'September', 'October', 'November', 'December'};
                List<ContentNote> cnt = new List<ContentNote>();
        List<ContentNote> delCnt = new List<ContentNote>();
        
        List<ContentNote> parentCnt = new List<ContentNote>();
        List<ContentNote> parentDelCnt = new List<ContentNote>();
        
        Boolean parentDelCntNote=false;
        Boolean parentUpdCntNote=false;
        
        Boolean delCntNote=false;
        Boolean updCntNote=false;
        List<Id> contentDocumentId = new List<Id>();
        List<Id> parentContentDocumentId = new List<Id>();
        List<Account> accountRecLst = new List<Account>();
        String eventformName;
        String evActualformName;
        String eventchangedFormName;
        String eventcategory;
        try{
            for(Object obj : apexDataLst){
                
                Map<String,Object> mpData = ( Map<String,Object>) obj;
                System.debug('wrapperList***accId'+String.valueOf(mpData.get('accId')));
                System.debug('wrapperList***attended'+String.valueOf(mpData.get('attended')));
                String accountId = String.valueOf(mpData.get('accId'));
                String attended = String.valueOf(mpData.get('attended'));
                String eveId = String.valueOf(mpData.get('eventId'));
                String notes = String.valueOf(mpData.get('notes'));
                String changeNote = String.valueOf(mpData.get('notesChange'));
                Boolean notesChange = changeNote.equals('true');
                Boolean booleanAttended = attended.equals('true');
                
                childEventId.add(eveId);
                accountLstId.add(accountId);
                accIdToNotes.put(accountId,notes);
                evIdToNotes.put(eveId,notes);
                accIdtoEvId.put(accountId,eveId);
                accIdtoNotesChange.put(accountId,notesChange);
                evIdToAttendance.put(eveId,booleanAttended);
                
            }
            
            List<Event> eventRec = [SELECT
                                    Id,
                                    WhatId,
                                    Subject,
                                    StartDateTime,
                                    ElixirSuite__Parent_Event_Id__c,
                                    ElixirSuite__Form_Unique_Id__c,
                                    ElixirSuite__Attendance__c
                                    FROM Event
                                    WHERE Id IN :childEventId AND
                                    WhatId IN :accountLstId
                                    WITH SECURITY_ENFORCED];
            
            String parentEventId = eventRec[0].ElixirSuite__Parent_Event_Id__c;
            
            for(Event ev : eventRec){
                
                DateTime dT = ev.StartDateTime;
                String startDate = dT.format('yyyy-MM-dd');
                Date startdt = date.valueOf(startDate);
                
                Integer d = startdt.Day();
                String m = monthNames[dt.Month()];
                Integer y = startdt.Year();
                
                String format1 = String.valueof(m) + ' ' + String.valueof(d) + ', ' + String.valueof(y);
                
                String formName = ev.Subject +' - '+format1+' - Session Note';
                accIdtoFormName.put(ev.WhatId,formName);
                accIdtoFormUniqueId.put(ev.WhatId,ev.ElixirSuite__Form_Unique_Id__c);
                
                ev.ElixirSuite__Attendance__c = evIdToAttendance.get(ev.Id);
                
            }
            
            accountRecLst = [Select Id,Name,ElixirSuite__Profile_Picture__c
                             FROM Account
                             WHERE Id IN :accountLstId
                             WITH SECURITY_ENFORCED];
            
            List<ContentDocumentLink> cdl = [Select Id,
                                             LinkedEntityId,
                                             ContentDocumentId
                                             FROM ContentDocumentLink
                                             WHERE LinkedEntityId IN :childEventId
                                             WITH SECURITY_ENFORCED];
            Map<String,String> docIdtoEvId = new Map<String,String>();
            Map<String,String> accIdtoNote = new Map<String,String>();
            Map<String,String> parentDocIdtoEvId = new Map<String,String>();
            
            if(cdl.size() >0 && cdl != null){
                for(ContentDocumentLink con : cdl){
                    contentDocumentId.add(con.ContentDocumentId);
                    docIdtoEvId.put(con.ContentDocumentId,con.LinkedEntityId);
                }
                cnt = [Select Id,
                       Content
                       From ContentNote
                       Where Id IN :contentDocumentId
                       WITH SECURITY_ENFORCED];
                for(ContentNote cntNote : cnt){
                    String updatedNotes = evIdToNotes.get(docIdtoEvId.get(cntNote.Id));
                    if(docIdtoEvId !=null && docIdtoEvId.get(cntNote.Id)!=null){
                        System.debug('inside if 261');
                        if(updatedNotes==''){
                            System.debug('inside if 263');
                            delCnt.add(cntNote);
                            delCntNote = true;
                        }
                        else{
                            System.debug('inside if 268');
                            cntNote.Content = Blob.valueOf(updatedNotes.stripHtmlTags());
                            cntNote.title = 'Session Notes';
                            updCntNote = true;
                        }
                    }
                }
            }
            
            List<ContentDocumentLink> cdl1 = [Select Id,
                                              LinkedEntityId,
                                              ContentDocumentId
                                              FROM ContentDocumentLink
                                              WHERE LinkedEntityId = :parentEventId
                                              WITH SECURITY_ENFORCED];
            
            if(cdl1.size() >0 && cdl1 != null){
                for(ContentDocumentLink con : cdl1){
                    parentContentDocumentId.add(con.ContentDocumentId);
                    parentDocIdtoEvId.put(con.ContentDocumentId,con.LinkedEntityId);
                }
                parentCnt = [Select Id,
                             Content
                             From ContentNote
                             Where Id IN :parentContentDocumentId
                             WITH SECURITY_ENFORCED];
                for(ContentNote cntNote : parentCnt){
                    String updatedNotes = groupNote;
                    if(parentDocIdtoEvId !=null && parentDocIdtoEvId.get(cntNote.Id)!=null){
                        System.debug('inside if 209');
                        if(updatedNotes==''){
                            parentDelCnt.add(cntNote);
                            parentDelCntNote = true;
                        }
                        else{
                            System.debug('inside if 301');
                            cntNote.Content = Blob.valueOf(updatedNotes.stripHtmlTags());
                            cntNote.title = 'Session Notes';
                            parentUpdCntNote = true;
                        }
                    }
                }
            }
            
            
            System.debug('accIdtoNote'+accIdtoNote);
            
            
            for(Account acc : accountRecLst){
                String individualNote = accIdToNotes.get(acc.Id);
                String formId = accIdtoFormUniqueId.get(acc.Id);
                String eveId = accIdtoEvId.get(acc.Id);
                Boolean notesChanged = accIdtoNotesChange.get(acc.Id);
                eventformName = 'Session Notes';
                eventchangedFormName = eventformName;
                eventcategory = 'Forms';
                evActualformName = accIdtoFormName.get(acc.Id);
                
                
                if(notesChanged || groupNoteChange){
                    if(formId == null){
                        attendanceController.saveIndividualNote(eveId,acc.Id,individualNote,eventformName,eventchangedFormName,eventcategory,evActualformName,groupNote);
                    }
                    else{
                        attendanceController.updateIndividualNote(eveId,acc.Id,individualNote,eventformName,formId,groupNote);
                    }
                }
                
            }
            
            DMLManager.updateAsUser(eventRec);
            
            if(updCntNote){
                DMLManager.updateAsUser(cnt);
            }
            
            if(delCntNote){
                DMLManager.deleteAsUser(delCnt);
            }
            
            if(parentUpdCntNote){
                DMLManager.updateAsUser(parentCnt);
            }
            
            if(parentDelCntNote){
                DMLManager.deleteAsUser(parentDelCnt);
            }
            
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        
    }
    
    @AuraEnabled
    public static void saveIndividualNote(String eventId, String accountId, String individualNote, String formName, String changedFormName, String category,String actualformName,String grpNote){
        
        Set<String> metadataObjects = new Set<String>();
        Map<String, sObject> objectNameToRecords = new Map<String, sObject>();
        sObject sObj;
        
        Event ev = [SELECT Id, 
                    StartDateTime,
                    EndDateTime, 
                    ElixirSuite__Parent_Event_Id__c,
                    ElixirSuite__Form_Unique_Id__c,
                    WhatId,
                    WhoId,
                    Facilitator__c
                    FROM Event 
                    WHERE Id=: eventId 
                    WITH SECURITY_ENFORCED];
        System.debug('individualNote***381'+individualNote);
        if(individualNote!=''){
            System.debug('inside if***383'+individualNote);
            //Create ContentNote
            ContentNote cnt = new ContentNote();
            cnt.Content = Blob.valueof(individualNote);
            cnt.Title = formName;
            DMLManager.insertAsUser(cnt);
            
            //Create ContentDocumentLink
            ContentDocumentLink clnk = new ContentDocumentLink();
            clnk.LinkedEntityId = eventId;
            clnk.ContentDocumentId = cnt.Id;
            clnk.ShareType = 'I';
            DMLManager.insertAsUser(clnk);
        }
        
        String evParentId = ev.ElixirSuite__Parent_Event_Id__c;
        
        String finalGroupNote;
        
        if(grpNote==null){
            finalGroupNote = '';
        }
        else{
            finalGroupNote = grpNote.stripHtmlTags();
        }
        
        List<ContentDocumentLink> cdl1 = [Select Id,
                                          LinkedEntityId,
                                          ContentDocumentId
                                          FROM ContentDocumentLink
                                          WHERE LinkedEntityId = :evParentId
                                          WITH SECURITY_ENFORCED];
        if(cdl1.size() ==0 ){
            if(finalGroupNote!=''){
                //Create ContentNote
                ContentNote cnt1 = new ContentNote();
                cnt1.Content = Blob.valueof(finalGroupNote);
                cnt1.Title = formName;
                DMLManager.insertAsUser(cnt1);
                
                //Create ContentDocumentLink
                ContentDocumentLink clnk1 = new ContentDocumentLink();
                clnk1.LinkedEntityId = evParentId;
                clnk1.ContentDocumentId = cnt1.Id;
                clnk1.ShareType = 'I';
                DMLManager.insertAsUser(clnk1);
            }
        }
        
        DateTime dT = ev.StartDateTime;
        DateTime enddT = ev.EndDateTime;
        String startTime = dT.format('HH:mm:ss');
        String endTime = enddT.format('HH:mm:ss'); 
        
        Event parentEv = [SELECT Id,
                          WhatId
                          FROM Event
                          Where Id=:evParentId
                          WITH SECURITY_ENFORCED];
        
        String evParentWhatId = parentEv.WhatId;
        
        ElixirSuite__Account_Group__c accGrp = [select Id,
                                                Name 
                                                from ElixirSuite__Account_Group__c
                                                Where Id=:evParentWhatId
                                                WITH SECURITY_ENFORCED];
        
        String groupName = accGrp.Name;
        
        Account accRec = [Select Id,
                          Name
                          from Account
                          where Id=:accountId
                          WITH SECURITY_ENFORCED];
        
        String accountName = accRec.Name;
        Date eventStartDate = Date.newInstance(dT.year(), dT.month(), dT.day());
        
        String facilitatorName = '';
        
        if(ev.WhoId != null){
            Id whoId = ev.WhoId;    
            String eventWhoId = String.valueOf(whoId.getsobjecttype());
            
            if(eventWhoId == 'Contact'){
                List<Contact> con = [Select Id,
                                     Name,
                                     Salutation
                                     From Contact
                                     Where Id=:whoId
                                     WITH SECURITY_ENFORCED];
                
                if(con!=null && con.size()>0){
                    if(con[0].Salutation == null){
                        facilitatorName = con[0].Name;
                    }
                    else{
                        facilitatorName = con[0].Salutation + ' '+ con[0].Name;
                    }
                }
                
            }
        }
        
        
        
        List<Form_Object__mdt> metadata = [SELECT Id, QualifiedApiName, Object_Name__c FROM Form_Object__mdt WHERE Object_Name__c!=NULL WITH SECURITY_ENFORCED LIMIT 1];//Getting metadata
        if(metadata!=null && metadata.size()>0){ 
            metadataObjects = new Set<String>(metadata[0].Object_Name__c.split(';'));
        }
        
        System.debug('metadataObjects**'+metadataObjects);
        
        for(String column : metadataObjects){
            
            String objectName = column;
            
            if(objectName == 'ONLYTEXT'){
                continue;
            }
            
            if(objectNameToRecords.containsKey(objectName.toLowerCase())){
                sObj = objectNameToRecords.get(objectName.toLowerCase());
                
            }
            else if(String.isNotBlank(objectName) && objectName!='undefined'){
                system.debug(objectName);
                sObj = Schema.getGlobalDescribe().get(objectName).newSObject(); 
                
                objectNameToRecords.put(objectName.toLowerCase(), sObj);
                
                
            }
            
        }
        
        
        system.debug('objectNameToRecords**'+objectNameToRecords);
        if(objectNameToRecords.size()>0){
            List<RecordType> recordTypes = [SELECT Id, Name, SobjectType FROM RecordType WHERE SobjectType IN :objectNameToRecords.keySet()
                                            AND Name =:formName WITH SECURITY_ENFORCED];
            Map<String,Id> objectNameToFormId = new Map<String,Id>();
            if(recordTypes!=null && recordTypes.size()>0){
                for(RecordType rec : recordTypes){
                    objectNameToFormId.put(rec.SobjectType.toLowerCase(), rec.Id);
                }
                for(String objName :objectNameToRecords.keySet()){
                    //AccountId__c is the custom field on Custom Form Object 
                    String objCaseInsensitive = objName.toLowerCase();
                    if(objectNameToFormId.containsKey(objCaseInsensitive)){
                        objectNameToRecords.get(objCaseInsensitive).put('RecordTypeId', objectNameToFormId.get(objCaseInsensitive));
                        objectNameToRecords.get(objCaseInsensitive).put('AccountId__c', accountId);
                        system.debug(objectNameToRecords.get(objCaseInsensitive));             
                    }
                } 
                upsert objectNameToRecords.values();
                
                //FORM-OBJECT data passing - END
                
                //STORING UNIQUE ID - START
                
                String idToCreateNumberUnique = String.valueOf(objectNameToRecords.values()[0].get('Id'));
                Integer uniqueIdFromRandomNo = generateRandomNumber();
                String uniqueId = String.valueOf(idToCreateNumberUnique) + ';' + String.valueOf(uniqueIdFromRandomNo);
                for(String objName :objectNameToRecords.keySet()){
                    if(objectNameToRecords.get(objName) !=null){
                        objectNameToRecords.get(objName).put('Form_unique_id__c',uniqueId);
                        objectNameToRecords.get(objName).put('Form_Name__c',actualformName);
                        objectNameToRecords.get(objName).put('Form_RecordType_Name__c',formName);
                        objectNameToRecords.get(objName).put('Form_Category__c',category);
                        
                        objectNameToRecords.get(objName).put('Individual_Notes__c',individualNote);
                        objectNameToRecords.get(objName).put('Facilitator__c',facilitatorName);
                        objectNameToRecords.get(objName).put('Date__c',eventStartDate);
                        objectNameToRecords.get(objName).put('Patient_Invited__c',accountName);
                        objectNameToRecords.get(objName).put('Group_Invited__c',groupName);
                        objectNameToRecords.get(objName).put('Start_Time__c',startTime);
                        objectNameToRecords.get(objName).put('End_Time__c',endTime);
                        objectNameToRecords.get(objName).put('Event_Id__c',eventId);
                        objectNameToRecords.get(objName).put('Group_Notes__c',finalGroupNote);
                    }
                }
                //  update objectNameToRecords.values();
                DMLManager.updateAsUser(objectNameToRecords.values());
                
                ev.ElixirSuite__Form_Unique_Id__c = uniqueId;
                DMLManager.updateAsUser(ev);
                
            }
            
        }
    }
    
    public static Integer generateRandomNumber(){
        Integer idToCreateNumberUnique = Integer.valueof((Math.random() * 1000000000));
        return idToCreateNumberUnique;
    }
    
    @AuraEnabled
    public static void updateIndividualNote(String eventId, String accountId, String individualNote, String formName , String formUniqueId , String grpNote){
        
        
        Set<String> metadataObjects = new Set<String>();
        
        Event ev = [SELECT Id, 
                    StartDateTime,
                    EndDateTime, 
                    ElixirSuite__Parent_Event_Id__c,
                    ElixirSuite__Form_Unique_Id__c,
                    WhatId,
                    WhoId,
                    Facilitator__c
                    FROM Event 
                    WHERE Id=: eventId 
                    WITH SECURITY_ENFORCED];
        
        String evParentId = ev.ElixirSuite__Parent_Event_Id__c;
        
        List<ContentDocumentLink> cdl1 = [Select Id,
                                                 LinkedEntityId,
                                                 ContentDocumentId
                                                 FROM ContentDocumentLink
                                                 WHERE LinkedEntityId = :evParentId
                                                 WITH SECURITY_ENFORCED];
        
        if(cdl1.size() >0 && cdl1 != null){
            System.debug('no document**');
        }
        else{
            
            if(grpNote!=''){
            //Create ContentNote
            ContentNote cnt = new ContentNote();
            cnt.Content = Blob.valueof(grpNote);
            cnt.Title = 'Session Notes';
            DMLManager.insertAsUser(cnt);
            
            //Create ContentDocumentLink
            ContentDocumentLink clnk = new ContentDocumentLink();
            clnk.LinkedEntityId = evParentId;
            clnk.ContentDocumentId = cnt.Id;
            clnk.ShareType = 'I';
            DMLManager.insertAsUser(clnk);
        }
            
        }
        
        List<ContentDocumentLink> cdl = [Select Id,
                                         LinkedEntityId,
                                         ContentDocumentId
                                         FROM ContentDocumentLink
                                         WHERE LinkedEntityId = :eventId
                                         WITH SECURITY_ENFORCED];
        
        if(cdl.size() >0 && cdl != null){
            System.debug('no document**');
        }
        else{
            
            if(individualNote!=''){
            //Create ContentNote
            ContentNote cnt = new ContentNote();
            cnt.Content = Blob.valueof(individualNote);
            cnt.Title = 'Session Notes';
            DMLManager.insertAsUser(cnt);
            
            //Create ContentDocumentLink
            ContentDocumentLink clnk = new ContentDocumentLink();
            clnk.LinkedEntityId = eventId;
            clnk.ContentDocumentId = cnt.Id;
            clnk.ShareType = 'I';
            DMLManager.insertAsUser(clnk);
        }
            
        }
        
        List<Form_Object__mdt> metadata = [SELECT Id, QualifiedApiName, Object_Name__c FROM Form_Object__mdt WHERE Object_Name__c!=NULL AND DeveloperName='Object_Names'  WITH SECURITY_ENFORCED LIMIT 1];//Getting metadata
        if(metadata!=null && metadata.size()>0){ 
            metadataObjects = new Set<String>(metadata[0].Object_Name__c.split(';'));
        }
        
        System.debug('metadataObjects**'+metadataObjects);
        
        for(String column : metadataObjects){
            
            String objectName = column;
            
            if(objectName == 'ONLYTEXT'){
                continue;
            }
            
            if(objectName.endsWithIgnoreCase('__c')){
                system.debug(objectName);
                String defineQuery = 'SELECT Id,Individual_Notes__c,Group_Notes__c FROM '+ String.escapeSingleQuotes(objectName) + ' WHERE Form_unique_id__c= :formUniqueId AND Form_unique_id__c!=NULL' ;
                // String defineQuery = 'SELECT Id FROM '+ +objName + ' WHERE Form_unique_id__c IN :String.escapeSingleQuotes(lstRecordId) AND Form_unique_id__c!=NULL' ;
                
                sObject records = Database.query(defineQuery);
                System.debug('records**'+records);
                records.put('Individual_Notes__c',individualNote);
                records.put('Group_Notes__c',grpNote.stripHtmlTags());
                //update records;
                DMLManager.updateAsUser(records);
                
            }
            
        }
    }
    
    //End by Anmol for LX3-8546
    
    @AuraEnabled
    public static License_Class LicensBasdPermission()
    {
        Id currentUid = UserInfo.getUserId();
        String AvailLicense = [Select Id,ElixirSuite__License_Type__c,Username,Name from User 
                               where Id =:currentUid WITH SECURITY_ENFORCED].ElixirSuite__License_Type__c;
        List<String> lst_availLicense = new List<String>();
        lst_availLicense = AvailLicense.split(';');
        License_Class lCls = new License_Class();
        try{
            for(String str : lst_availLicense)
            {
                if(str == 'Elixir EHR')
                {
                    lCls.isEhr = True;
                    continue;
                }
                
                if(str == 'Elixir Contact Center')
                {
                    lCls.isContactCenter = True;
                    continue;
                }
                
                if(str == 'Elixir RCM')
                {
                    lCls.isRcm = True;
                    continue;
                }
            }
            
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        return lCls;
    }
    public class License_Class
    {
        @AuraEnabled public Boolean isEhr;
        @AuraEnabled public Boolean isRcm;
        @AuraEnabled public Boolean isContactCenter;
    }
    
    public class newWrapper{
        @AuraEnabled
        public Event eventData ;
        @AuraEnabled
        public List<newAccountWrapper> accList;
        @AuraEnabled
        public License_Class licenseClassValue;
        @AuraEnabled
        public String groupNoteValue;
    }
    public class newAccountWrapper{
        @AuraEnabled
        public String accName;
        @AuraEnabled
        public String accountId;
        @AuraEnabled
        public String eventId;
        @AuraEnabled
        public String individualNoteValue;
        @AuraEnabled
        public String accProfilePic;
        @AuraEnabled
        public Boolean attended;
    }
    
    
}
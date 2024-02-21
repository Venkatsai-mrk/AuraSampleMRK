public with sharing class SessionNotesSignature {
    @AuraEnabled
    public static void checkValidation(string eventid){
        set<String> formSessionId = new set<String>();
        List<Event> evtlst = new List<Event>();
        Set<string> formValueId = new Set<string>();
        List<Form_Value__c> formLst = new List<Form_Value__c>();
        
        evtlst = [SELECT Id, WhoId, WhatId, Subject, ElixirSuite__Form_Unique_Id__c, 
                  ElixirSuite__Parent_Event_Id__c 
                  FROM Event
                  where ElixirSuite__Parent_Event_Id__c =: eventid
                  WITH SECURITY_ENFORCED];
        if(evtlst != null && evtlst.size() >0){
            for(Event recid :evtlst){
                if(recid.ElixirSuite__Form_Unique_Id__c != null){
                    formSessionId.add(recid.ElixirSuite__Form_Unique_Id__c);
                }
                
            }
        }
        System.debug('formSessionId**'+formSessionId);
        if(formSessionId != null && formSessionId.size() > 0){
            formLst = [SELECT Id, ElixirSuite__Account__c, ElixirSuite__Form_Id__c, 
                       ElixirSuite__Form_Name__c,Is_Approver__c 
                       FROM ElixirSuite__Form_Value__c
                       WHERE ElixirSuite__Form_Id__c IN:formSessionId
                       WITH SECURITY_ENFORCED];
            if(formLst != null && formLst.size() > 0){
                for(Form_Value__c rec : formLst){
                    if(rec.Is_Approver__c == true){
                        formValueId.add(rec.ElixirSuite__Form_Id__c);
                    }
                }
            }
        }
        
        
        if(formSessionId.size() == 0)
        {
            AuraHandledException e = new AuraHandledException('No notes exist for this session');
            e.setMessage('No notes exist for this session');
            throw e;
        }
        if(formSessionId.size() == formValueId.size())
        {
            AuraHandledException e = new AuraHandledException('All notes are already signed for this session');
            e.setMessage('All notes are already signed for this session');
            throw e;
        }
        
    }
    @AuraEnabled
    public static void approveForm(string eventid,String code, String comments){
        try {
            List<Event> evtlst = new List<Event>();
            set<String> formId = new set<String>();
            List<Form_Value__c> formDetails = new List<Form_Value__c>();
            Set<String> metadataObjects = new Set<String>();
            Set<id> userIds = new Set<id>();
            String signature;
            String userId;
            List<Event> eventAssignedID =[SELECT Id, WhoId, WhatId,OwnerId
                                          FROM Event
                                          where Id =: eventid
                                          WITH SECURITY_ENFORCED];
            if(eventAssignedID != null && eventAssignedID.size() >0){
                for(Event ids :eventAssignedID){
                    if(ids.id == eventid){
                        userIds.add(ids.OwnerId);
                    }
                    
                }
            }
             System.debug('userIds**'+userIds);
            if(userIds != null){
                
                User users = [SELECT Id, Signature_Attachment_Id__c, Verification_Code__c, Verification_Code_New__c
                              FROM User 
                              WHERE Id IN:userIds WITH SECURITY_ENFORCED LIMIT 1];
                if(users != null){
                    String verificationCode = users.Verification_Code_New__c;
                    userId = users.Id;
                    signature = users.Signature_Attachment_Id__c;
                    if(String.isBlank(signature)){
                        AuraHandledException e = new AuraHandledException('Please Register Signature First!');
                        e.setMessage('Please Register Signature First!');
                        throw e;
                    }
                    if(code != verificationCode){
                        AuraHandledException e = new AuraHandledException('Verification Failed!');
                        e.setMessage('Verification Failed!');
                        throw e;
                    }
                }
            }
            evtlst = [SELECT Id, WhoId, WhatId, Subject, ElixirSuite__Form_Unique_Id__c, 
                      ElixirSuite__Parent_Event_Id__c,OwnerId
                      FROM Event
                      where ElixirSuite__Parent_Event_Id__c =: eventid
                      WITH SECURITY_ENFORCED];
            if(evtlst != null && evtlst.size() >0){
                for(Event formuniqueid :evtlst){
                    formId.add(formuniqueid.ElixirSuite__Form_Unique_Id__c);
                }
            }
           
            if(formId != null && formId.size() >0){
                Set<string> formValueId = new Set<string>();
                List<Form_Value__c> formrecords = new List<Form_Value__c>();
                List<Form_Object__mdt> metadata = [SELECT Id, QualifiedApiName, Object_Name__c FROM Form_Object__mdt WHERE Object_Name__c!=NULL WITH SECURITY_ENFORCED LIMIT 1];//Getting metadata
                if(metadata!=null && metadata.size()>0){ 
                    metadataObjects = new Set<String>(metadata[0].Object_Name__c.split(';'));
                }
                formrecords = [SELECT Id, ElixirSuite__Account__c, ElixirSuite__Form_Id__c, 
                               ElixirSuite__Form_Name__c,Is_Approver__c 
                               FROM ElixirSuite__Form_Value__c
                               WHERE ElixirSuite__Form_Id__c IN:formId
                               WITH SECURITY_ENFORCED];
                if(formrecords != null && formrecords.size() > 0){
                    for(Form_Value__c rec : formrecords){
                        if(rec.Is_Approver__c == true){
                            formValueId.add(rec.ElixirSuite__Form_Id__c);
                        }
                    }
                }
                System.debug('formValueId**'+formValueId);
                for(String column : metadataObjects){
                    
                    String objectName = column;
                    
                    if(objectName == 'ONLYTEXT'){
                        continue;
                    }
                    
                    if(objectName.endsWithIgnoreCase('__c')){
                        system.debug(objectName);
                        String defineQuery = 'SELECT Id, AccountId__c, Form_Name__c, Form_unique_id__c, Event_Id__c FROM '+ String.escapeSingleQuotes(objectName) + ' WHERE Form_unique_id__c IN:formId AND Form_unique_id__c!=NULL' ;
                        // String defineQuery = 'SELECT Id FROM '+ +objName + ' WHERE Form_unique_id__c IN :String.escapeSingleQuotes(lstRecordId) AND Form_unique_id__c!=NULL' ;
                        
                        List<sObject> records = Database.query(defineQuery);
                        System.debug('records**'+records);
                        for(sObject obj : records){
                            String patientId = String.valueOf(obj.get('AccountId__c'));
                            String formUniqueId = String.valueOf(obj.get('Form_unique_id__c'));
                            String formName = String.valueOf(obj.get('Form_Name__c'));
                            if(!formValueId.contains(formUniqueId)){
                                System.debug('formValueId**'+formUniqueId);
                                Form_Value__c approvalValue = new Form_Value__c();
                                approvalValue.Account__c = patientId;
                                approvalValue.Form_Id__c = formUniqueId;
                                approvalValue.Form_Name__c = formName;
                                approvalValue.User__c = userId;
                                approvalValue.Approval_Level__c =  '1';
                                approvalValue.Comment__c = comments;
                                approvalValue.Approved_Signature__c = signature;
                                approvalValue.Date_Of_Approval__c = System.now();
                                approvalValue.Is_Approver__c = true;
                                approvalValue.Status__c = 'Completed';
                                approvalValue.Form_Detail__c = true;
                                formDetails.add(approvalValue);
                            }
                        }
                        DMLManager.insertAsUser(formDetails);
                        
                    }
                    
                }      
            }
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
}
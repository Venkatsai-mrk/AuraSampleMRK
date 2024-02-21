global without sharing class ElixirUtilityClass {
    
      public static Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
    
    global static returnWrapper1 procedureCreation(Map<String, Object> args){
        returnWrapper1 wrap = new returnWrapper1();
        string patientID;
        List<Id> procIds = new List<Id>();
        String eventId = (String) args.get('eventId');
        try{
            if(eventId != null && eventId != ''){
                List<ElixirSuite__Procedure__c> lstProcedure = new List<ElixirSuite__Procedure__c>();
                Event evtList = [SELECT Id, Subject,ElixirSuite__Care_Episode__c,ElixirSuite__Practitioner__c,ElixirSuite__Appointment_Type__c, AccountId,WhatId,StartDateTime,EndDateTime FROM Event 
                                 WHERE Id=:eventId WITH SECURITY_ENFORCED limit 1];
                patientID =  evtList.WhatId;
                
                String appointmentType = evtList.ElixirSuite__Appointment_Type__c;
                
                Id tempRecordTypeId = Schema.SObjectType.ElixirSuite__Procedure__c.getRecordTypeInfosByDeveloperName().get('Template_Procedure').getRecordTypeId();
                
                List<ElixirSuite__Procedure__c> tempProc = [SELECT Id, 
                                                            Name,
                                                            ElixirSuite__Code_Description__c,
                                                            ElixirSuite__Procedure_Duration__c,
                                                            ElixirSuite__Type_of_Procedure__c
                                                            FROM ElixirSuite__Procedure__c
                                                            WHERE Name=:appointmentType
                                                            AND RecordTypeId =:tempRecordTypeId
                                                            WITH SECURITY_ENFORCED limit 1];
                
                
                
                
                Id recordTypeId = Schema.SObjectType.ElixirSuite__Procedure__c.getRecordTypeInfosByDeveloperName().get('Patient_Procedure').getRecordTypeId();
                
                if(!tempProc.isEmpty() && tempProc[0]!=null){
                    
                    ElixirSuite__Procedure__c objProcedure = new ElixirSuite__Procedure__c();
                    objProcedure.Name = tempProc[0].Name;
                    objProcedure.ElixirSuite__Account__c = patientID;
                    objProcedure.RecordTypeId = recordTypeId;
                    if(  tempProc[0].ElixirSuite__Code_Description__c!=null){
                        objProcedure.ElixirSuite__Code_Description__c = tempProc[0].ElixirSuite__Code_Description__c;
                    }
                    
                    if( tempProc[0].ElixirSuite__Procedure_Duration__c!=null){
                        objProcedure.ElixirSuite__Procedure_Duration__c = tempProc[0].ElixirSuite__Procedure_Duration__c;
                    }
                    objProcedure.ElixirSuite__Event_Id__c = evtList.Id;
                    objProcedure.ElixirSuite__Type_of_Procedure__c = tempProc[0].ElixirSuite__Type_of_Procedure__c;
                    objProcedure.ElixirSuite__From_Date_of_Service__c =  evtList.StartDateTime;         
                    objProcedure.ElixirSuite__To_Date_of_Service__c =  evtList.EndDateTime;
                    objProcedure.ElixirSuite__Is_Billable__c = true;
                    objProcedure.ElixirSuite__Days_Units__c = 1;
                    lstProcedure.add(objProcedure);
                }
                
                if(lstProcedure.size() >0 && lstProcedure != null){
                    DMLManager.insertAsUser(lstProcedure);
                    for(ElixirSuite__Procedure__c p:lstProcedure){
                        procIds.add(p.Id);
                    }
                    wrap.procRecordId = procIds;
                }
            }
        }catch(Exception e){
            ExceptionLog.logError(e);
        }
        
        return wrap;    
    }
    
    global static returnWrapper1 careEpisodeCreation(Map<String, Object> args){
       returnWrapper1 wrap = new returnWrapper1();
        List<Id> careRecordId = new List<Id>();
        
        String eventId = (String) args.get('eventId');
        string patientID;
        
        try{
            if(eventId != null && eventId != ''){    
                Event evtList = [SELECT Id, Subject,ElixirSuite__Care_Episode__c,ElixirSuite__Practitioner__c, AccountId,WhatId,ElixirSuite__Appointment_Type__c,StartDateTime,EndDateTime FROM Event 
                                 WHERE Id=:eventId WITH SECURITY_ENFORCED limit 1];
                
                patientID =  evtList.WhatId;
                Integer countRecords;
                if(string.isBlank(evtList.ElixirSuite__Care_Episode__c) && string.isEmpty(evtList.ElixirSuite__Care_Episode__c) && evtList.ElixirSuite__Care_Episode__c == null){
                    ElixirSuite__Visits__c[] forCount = [SELECT ID,Account__r.Name,Name FROM ElixirSuite__Visits__c 
                                                         WHERE Account__c = : patientID AND Name LIKE '%Visit%' 
                                                         WITH SECURITY_ENFORCED
                                                         order by createdDate desc limit 1];
                    ElixirSuite__Visits__c[] forCounting = [SELECT ID,Account__r.Name,Name FROM ElixirSuite__Visits__c 
                                                            WHERE Account__c = : patientID AND Name LIKE '%Visit%' 
                                                            WITH SECURITY_ENFORCED
                                                            order by createdDate desc];
                    List<Account> accLst = [SELECT ID,Name from Account where id = : patientID WITH SECURITY_ENFORCED LIMIT 1];
                    Integer sizeVisitLst = forCounting.size();
                    String tpName;
                    if(forCount!=null && forCount.size()>0){
                        if(String.isNotBlank(forCount[0].Name)){ 
                            if(forCount[0].Name.containsIgnoreCase('Visit')){
                                if(sizeVisitLst<10){
                                    tpName = forCount[0].Name.right(1); 
                                }         
                                else if(sizeVisitLst>9 && sizeVisitLst<100){
                                    tpName = forCount[0].Name.right(2); 
                                }
                                else{
                                    tpName = forCount[0].Name.right(3);
                                }
                            }       
                        }
                    }
                    else {
                        tpName = '0';
                    } 
                    countRecords = Integer.valueOf(tpName)+1;
                    ElixirSuite__Visits__c visit = new ElixirSuite__Visits__c();
                    if(!accLst.isEmpty()){
                        visit.Name = accLst[0].Name +'\''+'s '+evtList.Subject+' Visit - '+ countRecords;
                        visit.ElixirSuite__Account__c = accLst[0].Id;
                    }
                    visit.ElixirSuite__Status__c = 'Active';
                    if( evtList.ElixirSuite__Practitioner__c != null){
                        visit.ElixirSuite__Rendering_Provider__c = evtList.ElixirSuite__Practitioner__c;
                    }
                    DMLManager.insertAsUser(visit);
                    careRecordId.add(visit.Id);
                    wrap.careRecordId = careRecordId;
                    evtList.ElixirSuite__Care_Episode__c = visit.Id;
                    DMLManager.updateAsUser(evtList);
                }
            }
        }catch(Exception e){
            ExceptionLog.logError(e);
        }
        
        return wrap; 
    }
    
    global static returnWrapper1 updateProcedure(Map<String, Object> args){
       returnWrapper1 wrap = new returnWrapper1();
        string patientID;
        List<Id> procIds = new List<Id>();
        String eventId = (String) args.get('eventId');
        try{
            if(eventId != null && eventId != ''){
                Event evtList = [SELECT Id, Subject,ElixirSuite__Care_Episode__c,ElixirSuite__Practitioner__c, AccountId,WhatId,ElixirSuite__Appointment_Type__c,StartDateTime,EndDateTime FROM Event 
                                 WHERE Id=:eventId WITH SECURITY_ENFORCED limit 1];
                if(!string.isBlank(evtList.ElixirSuite__Care_Episode__c) && !string.isEmpty(evtList.ElixirSuite__Care_Episode__c) && evtList.ElixirSuite__Care_Episode__c != null){
                   Id recordTypeId = Schema.SObjectType.ElixirSuite__Procedure__c.getRecordTypeInfosByDeveloperName().get('Patient_Procedure').getRecordTypeId();
                   List<Procedure__c> procLst = [SELECT Id,
                                          Name,
                                          ElixirSuite__Provider_Location__c,
                                          ElixirSuite__From_Date_of_Service__c,
                                          ElixirSuite__Template_Procedure__c,
                                          ElixirSuite__Type_of_Procedure__c,
                                          ElixirSuite__Charges__c,
                                          ElixirSuite__Account__c,ElixirSuite__To_Date_of_Service__c,
                                          ElixirSuite__Visits__c,
                                          ElixirSuite__Code_Description__c,ElixirSuite__Procedure_Duration__c
                                          FROM Procedure__c
                                          WHERE ElixirSuite__Event_Id__c=:evtList.Id
                                          AND RecordTypeId =:recordTypeId
                                          WITH SECURITY_ENFORCED LIMIT 1];
                    
                String appointmentType = evtList.ElixirSuite__Appointment_Type__c;
                Id tempRecordTypeId = Schema.SObjectType.ElixirSuite__Procedure__c.getRecordTypeInfosByDeveloperName().get('Template_Procedure').getRecordTypeId();
                
                List<ElixirSuite__Procedure__c> tempProc = [SELECT Id, 
                                                            Name,
                                                            ElixirSuite__Code_Description__c,
                                                            ElixirSuite__Procedure_Duration__c,
                                                            ElixirSuite__Type_of_Procedure__c
                                                            FROM ElixirSuite__Procedure__c
                                                            WHERE Name=:appointmentType
                                                            AND RecordTypeId =:tempRecordTypeId
                                                            WITH SECURITY_ENFORCED limit 1];
                    
                    if(!procLst.isEmpty() && procLst.size() > 0) {
                      ElixirSuite__Procedure__c objProcedure = procLst[0];
                        
                    if(!tempProc.isEmpty() && tempProc[0]!=null){
                    objProcedure.Name = tempProc[0].Name;
                    objProcedure.ElixirSuite__Account__c = patientID;
                    if(  tempProc[0].ElixirSuite__Code_Description__c!=null){
                        objProcedure.ElixirSuite__Code_Description__c = tempProc[0].ElixirSuite__Code_Description__c;
                    }
                    
                    if( tempProc[0].ElixirSuite__Procedure_Duration__c!=null){
                        objProcedure.ElixirSuite__Procedure_Duration__c = tempProc[0].ElixirSuite__Procedure_Duration__c;
                    }
                    
                    objProcedure.ElixirSuite__Type_of_Procedure__c = tempProc[0].ElixirSuite__Type_of_Procedure__c;
                    }
                      //objProcedure.ElixirSuite__Event_Id__c = evtList.Id;
                      objProcedure.ElixirSuite__From_Date_of_Service__c =  evtList.StartDateTime;         
                      objProcedure.ElixirSuite__To_Date_of_Service__c =  evtList.EndDateTime;
                      objProcedure.ElixirSuite__Visits__c = evtList.ElixirSuite__Care_Episode__c;
                      DMLManager.updateAsUser(objProcedure);
                      procIds.add(objProcedure.Id);
                      wrap.procRecordId = procIds;
                    }
                }
                
            }
        }catch(Exception e){
            ExceptionLog.logError(e);
        }
        return wrap;  
    }
    
    global static returnWrapper1 successRefund(Map<String, Object> refundMap){
         returnWrapper1 wrap = new returnWrapper1();
        List<Id> successrefundIdLst = new List<Id>();
        
        List<ElixirSuite__Refund__c> updaterefundRec = new List<ElixirSuite__Refund__c>();
        try{ 
            List<Id> refundIds = (List<Id>)refundMap.get('refundIds');
            String refNumber = (String) refundMap.get('refNumber');
            List<ElixirSuite__Refund__c> refundLst = [SELECT Id, Name, ElixirSuite__Account__c, 
                                                      ElixirSuite__Credit_Check_Reference_field__c, ElixirSuite__Date_Created__c, 
                                                      ElixirSuite__Date_Issued__c, ElixirSuite__Issued_User__c, 
                                                      ElixirSuite__Master_Transaction__c, ElixirSuite__Mode_of_Payment__c, 
                                                      ElixirSuite__Payment_Information__c, ElixirSuite__Reason_for_Refund__c, 
                                                      ElixirSuite__Refund_Amount__c, ElixirSuite__Requested_User__c, 
                                                      ElixirSuite__Status__c, ElixirSuite__Transactions__c, 
                                                      ElixirSuite__Prior_Transaction__c 
                                                      FROM ElixirSuite__Refund__c
                                                      where id IN : refundIds
                                                      WITH SECURITY_ENFORCED];
            List<String> PayInfolist = new List<String>();
            Map<Id,Id> masterid = new Map<Id,Id>();
            Map<Id, Transactions__c> refundIdToTransactionMap = new Map<Id, Transactions__c>();
            Map<Id, Master_Transaction__c> transactionToOtherTransactionMap = new Map<Id, Master_Transaction__c>();
            List<ElixirSuite__Master_Transaction__c> otherTransaction = new List<ElixirSuite__Master_Transaction__c>();
            String userId = UserInfo.getUserId();
            for(ElixirSuite__Refund__c recId : refundLst){
                if(recId.ElixirSuite__Status__c == 'Requested'){
                    masterid.put(recId.id,recId.ElixirSuite__Master_Transaction__c);
                }
                if(recId.ElixirSuite__Mode_of_Payment__c.contains('Credit Card')){
                    PayInfolist.add(recId.ElixirSuite__Payment_Information__c) ;
                }
                //LX3-9283 Refund to Unallocated Patient Credit
                if(recId.ElixirSuite__Mode_of_Payment__c == 'Patient Credit' && recId.ElixirSuite__Status__c == 'Requested'){
                    ElixirSuite__Master_Transaction__c otherTransRec = new ElixirSuite__Master_Transaction__c();
                    otherTransRec.ElixirSuite__Total_Amount_Paid__c =  recId.ElixirSuite__Refund_Amount__c;
                    otherTransRec.ElixirSuite__Total_Unallocated_Amount__c = recId.ElixirSuite__Refund_Amount__c;
                    otherTransRec.ElixirSuite__Account__c = recId.ElixirSuite__Account__c;
                    otherTransRec.ElixirSuite__Total_Remaining_Unallocated_Amount__c = recId.ElixirSuite__Refund_Amount__c;
                    otherTransRec.ElixirSuite__Transaction_Date__c = Date.today();
                    otherTransRec.ElixirSuite__Reason_Of_Payment__c = 'Unallocated Payment';
                    otherTransRec.ElixirSuite__Mode_of_Payment__c	= 'Patient Credit';
                    otherTransRec.ElixirSuite__Payment_Received_By__c = 'User';
                    otherTransRec.ElixirSuite__User__c = userId;
                    transactionToOtherTransactionMap.put(recId.Id, otherTransRec);
                }
            }
            
            
            List<Master_Transaction__c> otherTransRecList = new List<Master_Transaction__c>(transactionToOtherTransactionMap.values());
            DMLManager.insertAsUser(otherTransRecList);
            
            for(ElixirSuite__Refund__c rec : refundLst){
                if(rec.ElixirSuite__Status__c == 'Requested'){
                    string masterTransactionid = masterid.get(rec.id);
                    Transactions__c transObj = new Transactions__c();
                    transObj.ElixirSuite__Master_Transaction__c = masterTransactionid;
                    transObj.ElixirSuite__Amount_Paid__c = rec.ElixirSuite__Refund_Amount__c;
                    transObj.ElixirSuite__Payment_DateTime__c = system.now();
                    transObj.ElixirSuite__Payment_Received_By__c = 'Patient';
                    transObj.ElixirSuite__Type_of_Payment__c = 'Refund';
                    transObj.ElixirSuite__Cheque_Number__c = refNumber;
                    if(rec.ElixirSuite__Mode_of_Payment__c == 'Patient Credit'){
                        Master_Transaction__c othertransId = transactionToOtherTransactionMap.get(rec.Id);
                        transObj.ElixirSuite__Other_Transactions__c = othertransId.Id;
                    }
                    refundIdToTransactionMap.put(rec.Id, transObj);
                }
                
            }
            
            List<Transactions__c> transRecList = new List<Transactions__c>(refundIdToTransactionMap.values());
            DMLManager.insertAsUser(transRecList); 
            
            for (ElixirSuite__Refund__c rec : refundLst) {
                if (refundIdToTransactionMap.containsKey(rec.Id) && rec.ElixirSuite__Status__c == 'Requested') {
                    Transactions__c transId = refundIdToTransactionMap.get(rec.Id);
                    rec.ElixirSuite__Transactions__c = transId.Id;
                    rec.ElixirSuite__Date_Issued__c = Date.today();
                    rec.ElixirSuite__Issued_User__c = userId;
                    rec.ElixirSuite__Status__c = 'Issued';
                    if(rec.ElixirSuite__Mode_of_Payment__c.contains('-')){
                        string modeOfPayment =  rec.ElixirSuite__Mode_of_Payment__c.substringBefore('-').trim();
                        rec.ElixirSuite__Mode_of_Payment__c = modeOfPayment;
                    }
                    successrefundIdLst.add(rec.id);
                    updaterefundRec.add(rec);
                }
                
                
            }
            if(updaterefundRec != null && updaterefundRec.size()>0){
                DMLManager.updateAsUser(updaterefundRec);
                wrap.refundId = successrefundIdLst;
                
            }
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        return wrap;
    }
    
    global static returnWrapper1 failedRefund(Map<String, Object> refundMap){
         returnWrapper1 wrap = new returnWrapper1();
        List<ElixirSuite__Refund__c> updaterefundRec = new List<ElixirSuite__Refund__c>();
        
        try{
            List<Id> refundIds = (List<Id>)refundMap.get('refundIds');
            List<ElixirSuite__Refund__c> refundLst = [SELECT Id, Name, ElixirSuite__Account__c, 
                                                      ElixirSuite__Credit_Check_Reference_field__c, ElixirSuite__Date_Created__c, 
                                                      ElixirSuite__Date_Issued__c, ElixirSuite__Issued_User__c, 
                                                      ElixirSuite__Master_Transaction__c, ElixirSuite__Mode_of_Payment__c, 
                                                      ElixirSuite__Payment_Information__c, ElixirSuite__Reason_for_Refund__c, 
                                                      ElixirSuite__Refund_Amount__c, ElixirSuite__Requested_User__c, 
                                                      ElixirSuite__Status__c, ElixirSuite__Transactions__c, 
                                                      ElixirSuite__Prior_Transaction__c 
                                                      FROM ElixirSuite__Refund__c
                                                      where id IN : refundIds
                                                      WITH SECURITY_ENFORCED];
            List<Id> failedrefundIdLst = new List<Id>();
            String userId = UserInfo.getUserId();
            for (ElixirSuite__Refund__c rec : refundLst) {
                rec.ElixirSuite__Date_Issued__c = Date.today();
                rec.ElixirSuite__Issued_User__c = userId;
                rec.ElixirSuite__Status__c = 'Denied';
                failedrefundIdLst.add(rec.id);
                updaterefundRec.add(rec);
            }
            if(updaterefundRec != null && updaterefundRec.size()>0){
                DMLManager.updateAsUser(updaterefundRec);
                wrap.refundId = failedrefundIdLst;
            }
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        return wrap;
    }
    
    global static List<sObject> getObjectRecord(String objectApiName, String fieldValue) {
        try{
            List<String> fieldNames = new List<String>();
            List<String> strList = new List<String>();
            // Get the object's describe information
            Schema.SObjectType objectDescribe = globalDescribe.get(objectApiName);
            
            // Add field names in lowercase to the fieldsToExclude set
            Set<String> fieldsToExclude = new Set<String>{'lastvieweddate', 'lastreferenceddate'};

            // Get the fields for the object
            Map<String, Schema.SObjectField> objectFields = objectDescribe.getDescribe().fields.getMap();
            
            if(objectDescribe != null && objectDescribe.getDescribe().isAccessible()){
                
                for(String fieldName : objectFields.keySet()){
                    if(!fieldsToExclude.contains(fieldName)){
                        strList.add(fieldName);
                    }
                }
                   
                String definedQuery = 'SELECT ' + String.escapeSingleQuotes(String.join(strList, ',')) + ' FROM ' + String.escapeSingleQuotes(objectApiName) + ' WHERE Name = \'' + String.escapeSingleQuotes(fieldValue) + '\' WITH SECURITY_ENFORCED';
                return Database.query(definedQuery);
            }
            
            return new List<sObject>();
            
        } catch (Exception e){
            ExceptionLog.logError(e); 
            return null;
        }
    }
    
    global class returnWrapper1{
        @AuraEnabled global List<Id> procRecordId;
        @AuraEnabled global List<Id> careRecordId;
        @AuraEnabled global List<Id> refundId;
        
        
    }
    
}
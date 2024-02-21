/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-23-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class OppFieldsOnVOBHandler {
    
    public static void stopDeceasedEdit(ElixirSuite__VOB__c[] lstRecord,Boolean wasRun){
        if(DeceasedGlobalStopRecursion.run){
            for(ElixirSuite__VOB__c vb : lstRecord){ 
                if(vb.ElixirSuite__Deceased__c){
                    if(wasRun == false){
                        vb.ElixirSuite__Deceased__c.addError('You can only mark the patient as deceased on Account!');
                    } 
                }
            }
        }
    }
  
    public static Boolean preventEditIfDeceasedCheckedOnAccount(ElixirSuite__VOB__c[] lstRecord){
        Boolean  flag = false;
        try{
        ElixirSuite__VOB__c[] recordsToBlock = new List<ElixirSuite__VOB__c>();
        if(DeceasedGlobalStopRecursion.run){
            Map<Id,ElixirSuite__VOB__c> acctVobMap = new Map<Id,ElixirSuite__VOB__c>();
            Map<Id,ElixirSuite__VOB__c> oppVobMap = new Map<Id,ElixirSuite__VOB__c>();
            for(ElixirSuite__VOB__c ct : lstRecord){
                oppVobMap.put(ct.ElixirSuite__Opportunity__c,ct); 
                acctVobMap.put(ct.ElixirSuite__Account__c,ct);          
            }
            Account[] acctLst = [SELECT ID,Name,ElixirSuite__Deceased__c from Account WHERE ID IN : acctVobMap.keySet() WITH SECURITY_ENFORCED];
            for(Account acc : acctLst){
                if(acc.ElixirSuite__Deceased__c){
                    flag = true;
                    recordsToBlock.add(acctVobMap.get(acc.Id));
                }
            }
            Opportunity[] vobRelatedOpps = [SELECT ID,Name,AccountId FROM Opportunity WHERE ID IN : oppVobMap.KeySet() WITH SECURITY_ENFORCED];
            Map<Id,Id> acctOppMap = new Map<Id,Id>();
            for(Opportunity  opp : vobRelatedOpps){
                acctOppMap.put(opp.AccountId,opp.Id);
            }
            Account[] acctForVOB = [SELECT ID,Name,ElixirSuite__Deceased__c from Account WHERE ID IN : acctOppMap.keySet() WITH SECURITY_ENFORCED];
            for(Account accsObj : acctForVOB){
                if(accsObj.ElixirSuite__Deceased__c){
                    flag = true;
                    System.debug('#########'+flag);
                    recordsToBlock.add(oppVobMap.get(acctOppMap.get(accsObj.Id)));
                }
            }
            
            System.debug('flag doamin '+flag);
            for(ElixirSuite__VOB__c oppsObj : recordsToBlock){
                oppsObj.addError('This patient is deceased. You can not edit this patient record!');
            }
        }
        }
        catch(Exception e){
        ExceptionLog.logError(e);
        }
        return flag;
    }
       public static void blockDeleteIfDeceased(List<ElixirSuite__VOB__c> vobLst){
        for(ElixirSuite__VOB__c acc : vobLst){
            System.debug('del '+acc.ElixirSuite__Deceased__c);
            if(acc.ElixirSuite__Deceased__c){
                acc.adderror('Record cannot be deleted as patient is deceased!'); 
            }
        }
    }
    public static void populateRelatedLookup(Map<Id, Id> vobOppMap){
        
        Set<Id> vobIds = new Set<id>(vobOppMap.keyset());
        Set<Id> oppIds = new Set<id>(vobOppMap.values());
        List<ElixirSuite__VOB__c> lstvobToUpdate = new List<ElixirSuite__VOB__c>();
        try{
        list<ElixirSuite__VOB__c> vobList = [SELECT id, name,RecordtypeId, RecordType.name,ElixirSuite__Patient_Birth_Date__c,ElixirSuite__Account__c,
                                             ElixirSuite__VOB_Verification_Status__c,ElixirSuite__Service_Date__c,ElixirSuite__Status__c,Patient_Address__c,
                                             ElixirSuite__Insurance_Group_Number__c,ElixirSuite__Insurance_Providers__c,ElixirSuite__Insurance_Company_Phone__c,
                                             ElixirSuite__Insurance_Policy_ID__c,ElixirSuite__Insured_First_Name__c,ElixirSuite__Insured_Middle_Name__c,
                                             ElixirSuite__Insured_Last_Name__c,ElixirSuite__Date_Of_Birth__c,ElixirSuite__Insurance_Group_Number_Sec__c,
                                             ElixirSuite__Secondary_Insurance_Provider__c,Secondary_Insurance_Phone_Number__c,ElixirSuite__Patient_SSN__c,
                                             ElixirSuite__Secondary_Insurance_Policy_ID__c,ElixirSuite__Secondary_Subscriber_DOB__c,ElixirSuite__Patient_s_Gender__c,
                                             ElixirSuite__Subscriber_Name__c,ElixirSuite__Secondary_Subscriber_Name__c
                                             from ElixirSuite__VOB__c WHERE id =: vobIds WITH SECURITY_ENFORCED];
        system.debug('vobnew' +vobList);
        list<Opportunity> oppList = [SELECT id, name,  ElixirSuite__Patient_s_DOB__c,AccountId,ElixirSuite__Subscriber__c ,ElixirSuite__Secondary_Subscriber_Middle_Name__c,
                                     ElixirSuite__Primary_Insurance_Provider1__c, ElixirSuite__Insurance_Policy_ID__c,ElixirSuite__Secondary_Subscriber_Last_Name__c,
                                     ElixirSuite__Insurance_Group_Number__c, ElixirSuite__Insurance_Phone_Number__c,ElixirSuite__SSN__c,
                                     ElixirSuite__Subscriber_Name__c, ElixirSuite__Subscriber_DOB__c,ElixirSuite__Primary_Subscriber_Middle_Name__c,ElixirSuite__Primary_Subscriber_Last_Name__c,
                                     ElixirSuite__Secondary_Insurance_Provider__c, ElixirSuite__Secondary_Insurance_Policy_ID__c,
                                     ElixirSuite__Secondary_Insurance_Group_Number__c, ElixirSuite__Secondary_Insurance_Phone_Number__c,
                                     ElixirSuite__Secondary_Subscriber_Name__c, ElixirSuite__Secondary_Subscriber_DOB__c,ElixirSuite__Gender__c,
                                     ElixirSuite__Address__c,ElixirSuite__Address_City__c,ElixirSuite__Address_Street__c, 
                                     ElixirSuite__Address_Zip__c,ElixirSuite__Address_State__c,ElixirSuite__Address_Country__c
                                     from Opportunity WHERE Id =: oppIds WITH SECURITY_ENFORCED];    
        
        for(opportunity opp : oppList){
            for(ElixirSuite__VOB__c vobrec:vobList ){
                
                if(vobOppMap.get(vobrec.id)== opp.id){
                    if(vobrec.ElixirSuite__Patient_Birth_Date__c == null){
                        vobrec.ElixirSuite__Patient_Birth_Date__c= opp.ElixirSuite__Patient_s_DOB__c;
                    }
                    if(vobrec.ElixirSuite__Account__c == null){
                        vobrec.ElixirSuite__Account__c= opp.AccountId;
                    }
                    if(vobrec.ElixirSuite__VOB_Verification_Status__c == null){
                        vobrec.ElixirSuite__VOB_Verification_Status__c = 'Not Approved';
                    }
                    if(vobrec.ElixirSuite__Service_Date__c == null){
                        vobrec.ElixirSuite__Service_Date__c = system.today();
                    }
                    if(vobrec.ElixirSuite__Status__c == null){
                        vobrec.ElixirSuite__Status__c = 'Active';
                    }
                    if(vobrec.ElixirSuite__Patient_SSN__c == null){
                        vobrec.ElixirSuite__Patient_SSN__c = opp.ElixirSuite__SSN__c;
                    }
                     if(vobrec.ElixirSuite__Patient_s_Gender__c == null){
                        vobrec.ElixirSuite__Patient_s_Gender__c = opp.ElixirSuite__Gender__c;
                    }
                    // vobrec.ElixirSuite__Patient_Relationship_With_Insured__c=opp.ElixirSuite__Subscriber__c;
                    
                    List<String> address = new List<String>{'address_street__c', 'address_city__c','address_state__c', 'address_Zip__c','address_Country__c'};
                        
                        String Fulladdress = '';
                    if(vobrec.Patient_Address__c == null){
                        for(String field :address){
                            if(String.isNotBlank(((String)opp.get(field)))){
                                Fulladdress+=(String)opp.get(field) + ' ';
                                system.debug('fulladdress'+Fulladdress);
                            }
                            
                            vobrec.Patient_Address__c= Fulladdress;
                        }
                    } 
                    List<String> primaryName = new List<String>{'ElixirSuite__Subscriber_Name__c', 'ElixirSuite__Primary_Subscriber_Middle_Name__c','ElixirSuite__Primary_Subscriber_Last_Name__c'};
                    List<String> secondaryName = new List<String>{'ElixirSuite__Secondary_Subscriber_Name__c', 'ElixirSuite__Secondary_Subscriber_Middle_Name__c','ElixirSuite__Secondary_Subscriber_Last_Name__c'};
                        
                    String FullName = '';
                    String secondaryFullName = '';
                    
                    String developerName = Schema.getGlobalDescribe().get('Elixirsuite__VOB__c').getDescribe().getRecordTypeInfosById().get(vobrec.RecordTypeId).getDeveloperName();
                    
                    if(developerName== 'VOB_record_type'){
                        
                        vobrec.ElixirSuite__Type__c='Primary'; 
                        if(vobrec.ElixirSuite__Insurance_Group_Number__c == null){
                            vobrec.ElixirSuite__Insurance_Group_Number__c = opp.ElixirSuite__Insurance_Group_Number__c ;
                        }
                        if(vobrec.ElixirSuite__Insurance_Providers__c == null){
                            vobrec.ElixirSuite__Insurance_Providers__c = opp.ElixirSuite__Primary_Insurance_Provider1__c ;
                        }
                        if(vobrec.ElixirSuite__Insurance_Company_Phone__c == null){
                            vobrec.ElixirSuite__Insurance_Company_Phone__c = opp.ElixirSuite__Insurance_Phone_Number__c ;
                        }
                        if(vobrec.ElixirSuite__Insurance_Policy_ID__c == null){
                            vobrec.ElixirSuite__Insurance_Policy_ID__c = opp.ElixirSuite__Insurance_Policy_ID__c ;
                        }
                        if(vobrec.ElixirSuite__Insured_First_Name__c == null){
                            //  vobrec.ElixirSuite__Subscriber_Name__c= opp.Subscriber_Name__c ;
                            vobrec.ElixirSuite__Insured_First_Name__c=opp.Subscriber_Name__c; //this is first name //changing reference from Subscriber_Name__c to 	ElixirSuite__Insured_First_Name__c
                        }
                        if(vobrec.ElixirSuite__Insured_Middle_Name__c == null){
                            vobrec.ElixirSuite__Insured_Middle_Name__c=opp.ElixirSuite__Primary_Subscriber_Middle_Name__c; //middle name
                        }
                        if(vobrec.ElixirSuite__Insured_Last_Name__c == null){
                            vobrec.ElixirSuite__Insured_Last_Name__c=opp.ElixirSuite__Primary_Subscriber_Last_Name__c; //last name
                        }
                        if(vobrec.ElixirSuite__Date_Of_Birth__c == null){
                            vobrec.ElixirSuite__Date_Of_Birth__c= opp.Subscriber_DOB__c ;
                        }
                        if(vobrec.ElixirSuite__Subscriber_Name__c == null){
                            for(String field :primaryName){
                                if(String.isNotBlank(((String)opp.get(field)))){
                                    FullName+=(String)opp.get(field) + ' ';
                                }
                                
                                vobrec.ElixirSuite__Subscriber_Name__c= FullName;
                            }
                        } 
                    }
                    
                    if(developerName== 'Secondary_VOB'){
                        vobrec.ElixirSuite__Type__c='Secondary'; 
                        if(vobrec.ElixirSuite__Insurance_Group_Number_Sec__c == null){
                            vobrec.ElixirSuite__Insurance_Group_Number_Sec__c = opp.ElixirSuite__Secondary_Insurance_Group_Number__c ;
                        }
                        if(vobrec.ElixirSuite__Secondary_Insurance_Provider__c == null){
                            vobrec.ElixirSuite__Secondary_Insurance_Provider__c = opp.Secondary_Insurance_Provider__c ;
                        }
                        if(vobrec.Secondary_Insurance_Phone_Number__c == null){
                            vobrec.Secondary_Insurance_Phone_Number__c = opp.Secondary_Insurance_Phone_Number__c ;
                        }
                        if(vobrec.ElixirSuite__Secondary_Insurance_Policy_ID__c == null){
                            vobrec.ElixirSuite__Secondary_Insurance_Policy_ID__c = opp.ElixirSuite__Secondary_Insurance_Policy_ID__c ;
                        }
                        //vobrec.ElixirSuite__Secondary_Subscriber_Name__c = opp.Secondary_Subscriber_Name__c 
                        if(vobrec.ElixirSuite__Insured_First_Name__c == null){
                            vobrec.ElixirSuite__Insured_First_Name__c=opp.Secondary_Subscriber_Name__c; //this is first name //changing reference from Subscriber_Name__c to 	ElixirSuite__Insured_First_Name__c
                        }
                        if(vobrec.ElixirSuite__Insured_Middle_Name__c == null){
                            vobrec.ElixirSuite__Insured_Middle_Name__c=opp.ElixirSuite__Secondary_Subscriber_Middle_Name__c; //middle name
                        }
                        if(vobrec.ElixirSuite__Insured_Last_Name__c == null){
                            vobrec.ElixirSuite__Insured_Last_Name__c=opp.ElixirSuite__Secondary_Subscriber_Last_Name__c; //last name;
                        }
                        if(vobrec.ElixirSuite__Secondary_Subscriber_DOB__c == null){
                            vobrec.ElixirSuite__Secondary_Subscriber_DOB__c = opp.Secondary_Subscriber_DOB__c ;
                        }
                         if(vobrec.ElixirSuite__Secondary_Subscriber_Name__c == null){
                            for(String field :secondaryName){
                                if(String.isNotBlank(((String)opp.get(field)))){
                                    secondaryFullName+=(String)opp.get(field) + ' ';
                                }
                                
                                vobrec.ElixirSuite__Secondary_Subscriber_Name__c= secondaryFullName;
                            }
                        } 
                    }
                    
                    lstvobToUpdate.add(vobrec);
                }
            } 
            if(booleanFlag.flag== false){
                if(Schema.sObjectType.ElixirSuite__VOB__c.isUpdateable() &&
                   Schema.sObjectType.ElixirSuite__VOB__c.fields.ElixirSuite__Patient_Birth_Date__c.isUpdateable() &&
                   Schema.sObjectType.ElixirSuite__VOB__c.fields.ElixirSuite__Account__c.isUpdateable() &&
                   Schema.sObjectType.ElixirSuite__VOB__c.fields.ElixirSuite__VOB_Verification_Status__c.isUpdateable() &&
                   Schema.sObjectType.ElixirSuite__VOB__c.fields.ElixirSuite__Service_Date__c.isUpdateable() &&
                   Schema.sObjectType.ElixirSuite__VOB__c.fields.ElixirSuite__Status__c.isUpdateable() &&
                   Schema.sObjectType.ElixirSuite__VOB__c.fields.ElixirSuite__Patient_SSN__c.isUpdateable() &&
                   Schema.sObjectType.ElixirSuite__VOB__c.fields.Patient_Address__c.isUpdateable() &&
                   Schema.sObjectType.ElixirSuite__VOB__c.fields.ElixirSuite__Type__c.isUpdateable() &&
                   Schema.sObjectType.ElixirSuite__VOB__c.fields.ElixirSuite__Insurance_Group_Number__c.isUpdateable() &&
                   Schema.sObjectType.ElixirSuite__VOB__c.fields.ElixirSuite__Insurance_Providers__c.isUpdateable() &&
                   Schema.sObjectType.ElixirSuite__VOB__c.fields.ElixirSuite__Insurance_Company_Phone__c.isUpdateable() &&
                   Schema.sObjectType.ElixirSuite__VOB__c.fields.ElixirSuite__Insurance_Policy_ID__c.isUpdateable() &&
                   Schema.sObjectType.ElixirSuite__VOB__c.fields.ElixirSuite__Insured_First_Name__c.isUpdateable() &&
                   Schema.sObjectType.ElixirSuite__VOB__c.fields.ElixirSuite__Insured_Middle_Name__c.isUpdateable() &&
                   Schema.sObjectType.ElixirSuite__VOB__c.fields.ElixirSuite__Insured_Last_Name__c.isUpdateable() &&
                   Schema.sObjectType.ElixirSuite__VOB__c.fields.ElixirSuite__Date_Of_Birth__c.isUpdateable() &&
                   Schema.sObjectType.ElixirSuite__VOB__c.fields.ElixirSuite__Insurance_Group_Number_Sec__c.isUpdateable() &&
                   Schema.sObjectType.ElixirSuite__VOB__c.fields.ElixirSuite__Secondary_Insurance_Provider__c.isUpdateable() &&
                   Schema.sObjectType.ElixirSuite__VOB__c.fields.Secondary_Insurance_Phone_Number__c.isUpdateable() &&
                   Schema.sObjectType.ElixirSuite__VOB__c.fields.ElixirSuite__Secondary_Insurance_Policy_ID__c.isUpdateable() &&
                   Schema.sObjectType.ElixirSuite__VOB__c.fields.ElixirSuite__Secondary_Subscriber_DOB__c.isUpdateable() &&
                   Schema.sObjectType.ElixirSuite__VOB__c.fields.ElixirSuite__Secondary_Subscriber_Name__c.isUpdateable() &&
                   Schema.sObjectType.ElixirSuite__VOB__c.fields.ElixirSuite__Secondary_Insurance_Policy_ID__c.isUpdateable() &&
                   Schema.sObjectType.ElixirSuite__VOB__c.fields.Secondary_Insurance_Phone_Number__c.isUpdateable() &&
                   Schema.sObjectType.ElixirSuite__VOB__c.fields.ElixirSuite__Secondary_Insurance_Provider__c.isUpdateable() &&
                   Schema.sObjectType.ElixirSuite__VOB__c.fields.ElixirSuite__Insurance_Group_Number_Sec__c.isUpdateable() &&
                   Schema.sObjectType.ElixirSuite__VOB__c.fields.ElixirSuite__Subscriber_Name__c.isUpdateable() &&
                   Schema.sObjectType.ElixirSuite__VOB__c.fields.ElixirSuite__Date_Of_Birth__c.isUpdateable() &&
                   Schema.sObjectType.ElixirSuite__VOB__c.fields.ElixirSuite__Insured_Last_Name__c.isUpdateable() &&
                   Schema.sObjectType.ElixirSuite__VOB__c.fields.ElixirSuite__Insured_Middle_Name__c.isUpdateable() &&
                   Schema.sObjectType.ElixirSuite__VOB__c.fields.ElixirSuite__Insured_First_Name__c.isUpdateable() &&
                   Schema.sObjectType.ElixirSuite__VOB__c.fields.ElixirSuite__Insurance_Policy_ID__c.isUpdateable() &&
                   Schema.sObjectType.ElixirSuite__VOB__c.fields.ElixirSuite__Insurance_Company_Phone__c.isUpdateable() && 
                   Schema.sObjectType.ElixirSuite__VOB__c.fields.ElixirSuite__Insurance_Providers__c.isUpdateable() && 
                   Schema.sObjectType.ElixirSuite__VOB__c.fields.ElixirSuite__Insurance_Group_Number__c.isUpdateable() &&
                   Schema.sObjectType.ElixirSuite__VOB__c.fields.ElixirSuite__Type__c.isUpdateable() &&
                   Schema.sObjectType.ElixirSuite__VOB__c.fields.Patient_Address__c.isUpdateable() &&
                   Schema.sObjectType.ElixirSuite__VOB__c.fields.ElixirSuite__Patient_s_Gender__c.isUpdateable() &&
                   Schema.sObjectType.ElixirSuite__VOB__c.fields.ElixirSuite__Patient_SSN__c.isUpdateable() &&
                   Schema.sObjectType.ElixirSuite__VOB__c.fields.ElixirSuite__Status__c.isUpdateable() &&
                   Schema.sObjectType.ElixirSuite__VOB__c.fields.ElixirSuite__Service_Date__c.isUpdateable() &&
                   Schema.sObjectType.ElixirSuite__VOB__c.fields.ElixirSuite__VOB_Verification_Status__c.isUpdateable() &&
                   Schema.sObjectType.ElixirSuite__VOB__c.fields.ElixirSuite__Account__c.isUpdateable() &&
                   Schema.sObjectType.ElixirSuite__VOB__c.fields.ElixirSuite__Patient_Birth_Date__c.isUpdateable()){
                   update lstvobToUpdate;  
                    }
                   }
            }
        }
    
        catch(Exception e){
        ExceptionLog.logError(e);
        }
}
    //added this method for LX3-7342

    public static void qualifyStartingRecords(Map<ID, ElixirSuite__VOB__c> newVOB){
        //Set<Id> vobCreatedByIds = new Set<Id>();
        Set<Id> recordTypeIds = new Set<Id>();
        Set<Id> newInsertedIds = new Set<Id>();
        List<ElixirSuite__VOB__c> updateStatusVOBs = new List<ElixirSuite__VOB__c>();
        
        //starting qualification process
        try{
            DeceasedGlobalStopRecursion.runForPortal = false;
            for(ElixirSuite__VOB__c vob : newVOB.values()){
                System.debug('VOB after insert: ' + vob);
                System.debug('VOB after insert created by: ' + vob.CreatedById);
                //vobCreatedByIds.add(vob.CreatedById); 
                newInsertedIds.add(vob.Id);
                recordTypeIds.add(vob.RecordTypeId);
            }

            user usr = patientCardController.getUserInfo();
            if(usr != null){
                Id accId = usr.AccountId;
                List<ElixirSuite__VOB__c> lstVOB= [SELECT Id,Name,ElixirSuite__Status__c FROM ElixirSuite__VOB__c WHERE RecordTypeId =: recordTypeIds AND ElixirSuite__Account__c =: accId AND Id !=: newInsertedIds WITH SECURITY_ENFORCED];
                if(lstVOB != null && !lstVOB.isEmpty()){
                    for(ElixirSuite__VOB__c vob : lstVOB){
                        if(vob.ElixirSuite__Status__c == 'Active'){
                            vob.ElixirSuite__Status__c = 'InActive';
                            updateStatusVOBs.add(vob);
                        }
                    }
                }
            }
            if(updateStatusVOBs != null && !updateStatusVOBs.isEmpty()){
                if(Schema.sObjectType.ElixirSuite__VOB__c.isUpdateable() && 
                   Schema.sObjectType.ElixirSuite__VOB__c.fields.ElixirSuite__Status__c.isUpdateable() ){
                       update updateStatusVOBs;
                       
                   }
            }
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        
        
    }
    //added this method for LX3-7343
    public static void qualifyUpdateRecords(Map<ID, ElixirSuite__VOB__c> modifiedVOB, Map<ID, ElixirSuite__VOB__c> originalVOB){
        Set<Id> vobIds = new Set<Id>();
        Set<Id> lastModifiedIds = new Set<Id>();
        List<ElixirSuite__VOB__c> updateVOBs = new List<ElixirSuite__VOB__c>();
        
        try{
             
            //starting qualification process
            user usr = patientCardController.getUserInfo();
            if(usr != null){
                for(ElixirSuite__VOB__c vob : modifiedVOB.values()){
                    if(vob.ElixirSuite__Status__c == 'Active' && originalVOB.get(vob.Id).ElixirSuite__Status__c == 'Active'){
                        updateVOBs.add(vob);
                    }
                    else{
                        vob.addError('You can only update active insurance details!');
                    }
                }
            }
            
            if(updateVOBs != null && !updateVOBs.isEmpty()){
                if(Schema.sObjectType.ElixirSuite__VOB__c.isUpdateable()){
                    update updateVOBs;
                }
            }
        }
        catch(Exception e){
            ExceptionLog.logError(e);
}

    }
}
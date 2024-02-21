public with sharing class AccountTriggerHelper {
    public static void opportunityUpdate(Map<Id,Account> oldAccounts, List<Account> accounts) {
        try{
            if(StopRecursion.accountUpdateForStage){ 
                return;
            }
            Set<Id> accountIds = new Set<Id>();
            List<String> stages = new List<String>{'Admitted','Discharged'};
                for(Account acc: accounts){
                    String stage = acc.Stage__c;
                    if(String.isNotBlank(stage) && oldAccounts.get(acc.Id).Stage__c != acc.Stage__c){
                        accountIds.add(acc.Id);
                    }
                }
            List<Account> DBaccounts = [SELECT Id, Stage__c, (SELECT Id, StageName FROM Opportunities ORDER BY Stage_Modified_Date__c DESC LIMIT 1)
                                        FROM Account WHERE Id IN :accountIds AND Stage__c IN :stages WITH SECURITY_ENFORCED];
            List<Opportunity> oppsToUpdate = new List<Opportunity>(); 
            for(Account acc :DBaccounts){
                String stage = acc.Stage__c;
                List<Opportunity> opp = acc.Opportunities;
                if(opp!=null && opp.size()>0){
                    Opportunity oppo = new Opportunity(
                        Id=opp[0].Id,
                        StageName=stage
                    );
                    oppsToUpdate.add(oppo);
                }
            }
            if(oppsToUpdate!=null && oppsToUpdate.size()>0){
                if(Schema.sObjectType.Opportunity.fields.StageName.isUpdateable()){
                    stopRecursion.accountUpdateForStage = true;
                    update oppsToUpdate;
                }
            }
        }
        
        catch(Exception e){
        ExceptionLog.logError(e);
        }
    }
    
    //Method to update current status of patient based on stage
    public static void updatePatientCurrentStatus(List<Account> accounts) {
        try{
            if(StopRecursion.accountUpdateForStage){
                return;
            }
            
            
            //code for getting dependent values
            Schema.sObjectField dependToken = Account.ElixirSuite__Stage__c;
            Schema.DescribeFieldResult depend = dependToken.getDescribe();
            Schema.sObjectField controlToken = depend.getController();
            // if ( controlToken == null ) return null;
            Schema.DescribeFieldResult control = controlToken.getDescribe();
            List<Schema.PicklistEntry> controlEntries =
                (   control.getType() == Schema.DisplayType.Boolean
                 ?   null
                 :   control.getPicklistValues()
                );
            
            String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
            Map<String,List<String>> dependentPicklistValues = new Map<String,List<String>>();
            for ( Schema.PicklistEntry entry : depend.getPicklistValues() ) if ( entry.isActive() )
            {
                List<String> base64chars =
                    String.valueOf
                    (   ((Map<String,Object>) JSON.deserializeUntyped( JSON.serialize( entry ) )).get( 'validFor' )
                    ).split( '' );
                for ( Integer index = 0; index < (controlEntries != null ? controlEntries.size() : 2); index++ )
                {
                    Object controlValue =
                        (   controlEntries == null
                         ?   (Object) (index == 1)
                         :   (Object) (controlEntries[ index ].isActive() ? controlEntries[ index ].getLabel() : null)
                        );
                    Integer bitIndex = index / 6, bitShift = 5 - Math.mod( index, 6 );
                    if  (   controlValue == null
                         ||  (base64map.indexOf( base64chars[ bitIndex ] ) & (1 << bitShift)) == 0
                        ) continue;
                    String controlValue1 = String.valueOf(controlValue);
                    if ( !dependentPicklistValues.containsKey( controlValue1 ) )
                    {
                        dependentPicklistValues.put( controlValue1, new List<String>() );
                    }
                    dependentPicklistValues.get( controlValue1 ).add( entry.getLabel() );
                }
                
            }
            
            List<String> valueSet1 = new List<String>();
            List<String> valueSet2 = new List<String>();
            List<String> valueSet3 = new List<String>();
            for(String key: dependentPicklistValues.keySet()){
                if(key == 'Patients In Review'){
                    valueSet1 = dependentPicklistValues.get(key);
                }
                else if(key == 'Current Patients'){
                    valueSet2 = dependentPicklistValues.get(key);
                }
                else if(key =='Discharged Patients'){
                    valueSet3 = dependentPicklistValues.get(key);
                }
            }
            // code ends for getting dependent values
            
            
            Set<Id> accountIds = new Set<Id>();
            for(Account acc: accounts){
                String stage = acc.Stage__c;
                if(String.isNotBlank(stage)){
                    accountIds.add(acc.Id);
                }
            }
            
            List<Account> accToUpdate = new List<Account>();
            List<Account> getAcc = [SELECT id,stage__c from account where id IN: accountIds WITH SECURITY_ENFORCED];
            for(Account accRec : getAcc){
                String stage = accRec.Stage__c;
                if(String.isNotBlank(stage)){
                    Account accNew = new Account();
                    if(valueSet1.contains(stage)){
                        accNew.id = accRec.id ;
                        accNew.ElixirSuite__Current_Status_Of_Patient__c = 'Patients In Review';
                        accToUpdate.add(accNew);
                    }
                    if(valueSet2.contains(stage)){
                        accNew.id = accRec.id ;
                        accNew.ElixirSuite__Current_Status_Of_Patient__c = 'Current Patients';
                        accToUpdate.add(accNew);
                    }
                    if(valueSet3.contains(stage)){
                        accNew.id = accRec.id ;
                        accNew.ElixirSuite__Current_Status_Of_Patient__c = 'Discharged Patients';
                        accToUpdate.add(accNew);
                    }       
                }
            }
            if(accToUpdate!=null && accToUpdate.size()>0){
                
                    stopRecursion.accountUpdateForStage = true;
                    if(Schema.sObjectType.Account.isUpdateable() &&
                    Schema.sObjectType.Account.fields.Stage__c.isUpdateable() &&
                    Schema.sObjectType.Account.fields.id.isUpdateable() &&
                    Schema.sObjectType.Account.fields.ElixirSuite__Current_Status_Of_Patient__c.isUpdateable()){       
                    update accToUpdate;
                    }
                }
            }
        
        catch(Exception e){
            ExceptionLog.logError(e);
        }
    }
    public static void blockEditIfDeceased(List<Account> accounts,Map<Id,Account> oldMapTrigger) {  
        try{
            if(DeceasedGlobalStopRecursion.run){
                if(checkRecursive.runOnce()){
                    if(accounts!=null){
                        for(Account acc : accounts){
                            if(oldMapTrigger!=null){
                                Account oldAccount = oldMapTrigger.get(acc.ID);
                                if(oldAccount.ElixirSuite__Deceased__c){
                                    acc.addError('This patient is deceased. You can not edit this patient record!');
                                }
                            }                    
                        }
                    }
                }
            }
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
    }
    public static void checkDeceasedFilter(List<Account> accounts) {
        try{
            if(accounts!=null){
                for(Account acc : accounts){
                    if(acc.ElixirSuite__Deceased__c){
                        if(acc.ElixirSuite__Deceased_Date__c==null){
                            acc.ElixirSuite__Deceased_Date__c.addError('Deceased date is required if patient is deceased');
                        }
                        if(acc.Preliminary_Cause_of_death__c==null){
                            acc.Preliminary_Cause_of_death__c.addError('Preliminary Cause of death is required if patient is deceased');
                        }
                    }
                    
                    if(!acc.ElixirSuite__Deceased__c){
                        if(acc.ElixirSuite__Deceased_Date__c !=null || acc.Preliminary_Cause_of_death__c!=null ){
                            acc.addError('Deceased checkbox should be true when deceased date and the Preliminary cause of death is mentioned.');
                        }
                    }
                }
            }
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
    }
    public static void  updateAllCCrelatedObctsForDeceasedAsTrue(List<Account> accounts){
        try{
            if(StopRecursion.deceasedStop){
                return;
            }
            Set<Id> acctId = new Set<Id>();
            for(Account acc : accounts){
                if(acc.ElixirSuite__Deceased__c){
                    acctId.add(acc.Id);
                }
            }
            System.debug('acctId '+acctId);
            DeceasedGlobalStopRecursion.run = false;
            StopRecursion.deceasedStop = true;
            Set<Id> oppId  = updateAllOpportunity(acctId); // UPDATE OPPORTUNITY AND GET OPP ID IN RETURN FOR PRE ASSES
            updateAllPreAsses(oppId); // UPDATE PREASSES
            updateAllVOB(acctId,oppId);
            updateAllContact(acctId);
            updateAllAluminiCare(acctId,oppId);
            updateAllEvent(acctId);
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
    }
    public static void updateAllEvent(Set<Id> acctId ){
         try{
            List<Task> lstTask = [SELECT ID,WhatId,Subject FROM Task where WhatId IN :  acctId WITH SECURITY_ENFORCED];
            for(Task t : lstTask){
                t.Status = 'Cancelled'; 
            }
            List<event> lstEvent = [SELECT ID,WhatId,Subject, Account.ElixirSuite__Deceased__c, 
                                    ElixirSuite__Status__c from event where WhatId IN :  acctId WITH SECURITY_ENFORCED];
            for(event evt : lstEvent){
                evt.ElixirSuite__Status__c = 'Cancelled'; 
            }
            if(!lstTask.isEmpty()){
                DMLManager.updateAsUser(lstTask);
            }
            if(!lstEvent.isEmpty()){
                DMLManager.updateAsUser(lstEvent);
            }
            
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
    }
    public static Set<Id> updateAllOpportunity(Set<Id> acctId ){
       Map<Id,Opportunity> allRelatedopp = new Map<Id,Opportunity>();
        try{
            list<opportunity> opplist=[SELECT ID,ElixirSuite__Deceased__c FROM Opportunity WHERE AccountID IN : acctId];
            for(opportunity opp :opplist){
            allRelatedopp.put(opp.id,opp);    
            }
            Opportunity[] toUpdtopp = new List<Opportunity>();
            for(Opportunity oppObj : allRelatedopp.values()){
                oppObj.ElixirSuite__Deceased__c = true;
                toUpdtopp.add(oppObj);
            }
            //  StopRecursion.opportunityUpdateForStage = true;
            if(Schema.sObjectType.Opportunity.isUpdateable() &&
            Schema.sObjectType.Opportunity.fields.ElixirSuite__Deceased__c.isUpdateable()){    
            update toUpdtopp;
            }
           }
        catch(Exception e){
        ExceptionLog.logError(e);
        } 
        return allRelatedopp.keySet();
    }
    public static void updateAllPreAsses(Set<Id> oppId ){
        try{
            ElixirSuite__Pre_assessment__c[] allRelatedPreAss = [SELECT ID,ElixirSuite__Deceased__c FROM ElixirSuite__Pre_assessment__c WHERE 
                                                                 ElixirSuite__Opportunity__c IN : oppId WITH SECURITY_ENFORCED]; 
            for(ElixirSuite__Pre_assessment__c preAssobj : allRelatedPreAss){
                preAssobj.ElixirSuite__Deceased__c = true;
            }
            if(Schema.sObjectType.ElixirSuite__Pre_assessment__c.isUpdateable()) {
                update allRelatedPreAss;
             }
        }
        catch(Exception e){
        ExceptionLog.logError(e);
        } 
    }
    public static void updateAllVOB(Set<Id> acctId ,Set<Id> oppId ){
        try{
            
            ElixirSuite__VOB__c[] allRelatedVOBToAcc = [SELECT ID,ElixirSuite__Deceased__c FROM ElixirSuite__VOB__c WHERE 
                                                        ElixirSuite__Account__c IN : acctId WITH SECURITY_ENFORCED]; 
            ElixirSuite__VOB__c[] allRelatedVOBToOpp = [SELECT ID,ElixirSuite__Deceased__c FROM ElixirSuite__VOB__c WHERE 
                                                        ElixirSuite__Opportunity__c IN : acctId WITH SECURITY_ENFORCED];
            ElixirSuite__VOB__c[] toUpdtLst = new List<ElixirSuite__VOB__c>();
            allRelatedVOBToAcc.addAll(allRelatedVOBToopp);
            for(ElixirSuite__VOB__c sObj : allRelatedVOBToAcc){
                if(!sObj.ElixirSuite__Deceased__c){
                    sObj.ElixirSuite__Deceased__c = true;
                    toUpdtLst.add(sObj);
                }
            }
            if(Schema.sObjectType.ElixirSuite__VOB__c.isUpdateable() &&
                Schema.sObjectType.ElixirSuite__VOB__c.fields.ElixirSuite__Deceased__c.isUpdateable()){
                update toUpdtLst;
             }
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
    }
    
    public static void updateAllContact(Set<Id> acctId ){
        try{
            System.debug('cont update started'+acctId);
            Contact[] allRelatedCont = [SELECT ID,ElixirSuite__Deceased__c FROM Contact WHERE AccountID IN : acctId WITH SECURITY_ENFORCED];
            for(Contact ct : allRelatedCont){
                ct.ElixirSuite__Deceased__c = true;
            }
            if(Schema.sObjectType.Contact.isUpdateable()) {
                update allRelatedCont;
             }
            System.debug('cont update done');
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
    }
    public static void updateAllAluminiCare(Set<Id> acctId ,Set<Id> oppId ){
        try{
        ElixirSuite__Alumni_Care_Services__c[] allRelatedAluminiToAcc = [SELECT ID,ElixirSuite__Deceased__c FROM ElixirSuite__Alumni_Care_Services__c WHERE 
                                                                         ElixirSuite__Patient_Account__c  IN : acctId WITH SECURITY_ENFORCED]; // RELATED TO ACC
        ElixirSuite__Alumni_Care_Services__c[] allRelatedAluminiToOpp = [SELECT ID,ElixirSuite__Deceased__c FROM ElixirSuite__Alumni_Care_Services__c WHERE 
                                                                         ElixirSuite__Patient_Name__c  IN : acctId WITH SECURITY_ENFORCED]; // RELATED TO OPP
        ElixirSuite__Alumni_Care_Services__c[] toUpdtLst = new List<ElixirSuite__Alumni_Care_Services__c>();
        allRelatedAluminiToAcc.addAll(allRelatedAluminiToOpp);
        for(ElixirSuite__Alumni_Care_Services__c sObj : allRelatedAluminiToAcc){
            if(!sObj.ElixirSuite__Deceased__c){
                sObj.ElixirSuite__Deceased__c = true;
                toUpdtLst.add(sObj);
            }
        }
        if(Schema.sObjectType.ElixirSuite__Alumni_Care_Services__c.isUpdateable() &&
           Schema.sObjectType.ElixirSuite__Alumni_Care_Services__c.fields.ElixirSuite__Deceased__c.isUpdateable()){
            update toUpdtLst;
         }
    }
        catch(Exception e){
        ExceptionLog.logError(e);
        }
    }
    public static void blockDeleteIfDeceased(List<Account> acctLst){
        try{
            System.debug('delete in apex');
            for(Account acc : acctLst){
                System.debug('del '+acc.ElixirSuite__Deceased__c);
                if(acc.ElixirSuite__Deceased__c){
                    acc.adderror('Account cannot be deleted as patient is deceased!'); 
                }
            }
        }
        catch(Exception e){
        ExceptionLog.logError(e);
        }
    }
        public static void editEventsTimeZone(List<Account> oldAccs, List<Account> newAccs){
            Set<Id> eligibleAccounts = new Set<Id>();
            Map<Id,Account> oldAccsMap = new Map<Id,Account>(oldAccs);
            Map<Id,Account> newAccsMap = new Map<Id,Account>(newAccs);
             for(Account acc : newAccs){
                 if(acc.Time_Zone__c != oldAccsMap.get(acc.Id).Time_Zone__c){
                     eligibleAccounts.add(acc.Id);
                 }
             }
            system.debug('OldAccsMap======='+oldAccsMap);
            system.debug('EligibleAccounts======'+eligibleAccounts);
            if(eligibleAccounts!=null && eligibleAccounts.size()>0){
               List<Event> events = [SELECT Id,Patient_s_Time_Zone__c ,WhatId
                                     FROM Event 
                                     WHERE WhatId IN :eligibleAccounts WITH SECURITY_ENFORCED
                                     ORDER BY CreatedDate DESC
                                     LIMIT 500];
                for(Event evt :events){
                    if(newAccsMap.containsKey(evt.whatId)){
                        evt.Patient_s_Time_Zone__c = newAccsMap.get(evt.whatId).Time_Zone__c;
                    }
                }
                System.enqueueJob(new editEventsTimeZoneQueueable(events));
        }
    }
    
    public static void auditTrailAccount(Map<Id,Account> newAccMap, Map<Id,Account> oldAccMap){
        
        List<ElixirSuite__Audit_fields_new__mdt> auditClass = new List<ElixirSuite__Audit_fields_new__mdt>();
        String virtualFieldName;
        auditClass = [SELECT DeveloperName,ElixirSuite__Audit_fields__c,ElixirSuite__Audit_Object__c FROM ElixirSuite__Audit_fields_new__mdt WHERE ElixirSuite__Audit_Object__c='Account' WITH SECURITY_ENFORCED];
        if(auditClass != null && !auditClass.isEmpty()){
            
            virtualFieldName = auditClass[0].ElixirSuite__Audit_fields__c;
            
        }
        
        if(virtualFieldName != '' && virtualFieldName !=null){
        //Added by Anmol for LX3-8862
    // instantiate a new instance of the Queueable class
    String objName = 'Account';
    AuditTrailUtility updateJob = new AuditTrailUtility(newAccMap, oldAccMap,objName);
    // enqueue the job for processing
    ID jobID = System.enqueueJob(updateJob);
    //End by Anmol for LX3-8862
}
    }
    
    public static void generateMrnForAccount(List<Account> lstAccount){
        try{
            ElixirSuite.ProductMRNGenerator mrnGenerator;
            Type classType;
            String className = Elixir_Custom_Setting__c.getInstance().ProductMRNGenertaorExtensionClassName__c;
            /*if(Test.isRunningTest()){
                className = 'ElixirSuite.ProductMRNGenerator';
            }*/
            if(className == NULL){
                className = 'ElixirSuite.ProductMRNGenerator';
            }
       //     if(className != NULL){
                if(className == 'ElixirSuite.ProductMRNGenerator'){
                    mrnGenerator = new ElixirSuite.ProductMRNGenerator();
                }else{
                    classType = Type.forName(className);
                    if(classType != NULL){
                        mrnGenerator = (ElixirSuite.ProductMRNGenerator) classType.newInstance();
                    }
                }
           // }
            Elixir_Custom_Setting__c val = Elixir_Custom_Setting__c.getOrgDefaults();
            String patAccRecType = val.ElixirSuite__Patient_Account_Recordtype__c; 
            Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(patAccRecType).getRecordTypeId();
            List<Account> accListToUpdate = new List<Account>();
            Set<Id> accountIdSet = new Set<Id>();
            for (Account acc : lstAccount) {
                if(String.isNotBlank(acc.Id)){
                    accountIdSet.add(acc.Id);
                }
            }
            List<Account> accList = [SELECT Id,MRN_Number_New__c FROM Account WHERE Id IN:accountIdSet AND RecordTypeId=:recordTypeId WITH SECURITY_ENFORCED];
            
            for(Account ac : accList){
                if(String.isBlank(ac.MRN_Number_New__c)){
                    if(mrnGenerator != null){
                        ac.MRN_Number_New__c = mrnGenerator.generateMRN(ac.Id);
                        accListToUpdate.add(ac); 
                    }
                }
                
            }
            if(!accListToUpdate.isEmpty()){
                DMLManager.updateAsUser(accListToUpdate);
            }
   // }
        }catch(Exception e){
            ExceptionLog.logError(e);
        }
    }
    public static void mrnFieldNullUpdate(List<Account> accList){
        String className = Elixir_Custom_Setting__c.getInstance().ProductMRNGenertaorExtensionClassName__c;
        for(Account acc : accList){
            if(String.isBlank(acc.MRN_Number_New__c)){
                acc.MRN_Number_New__c = '';
            }
        }
    }
    public static void mrnFieldNullClassBeforeUpdate(List<Account> accList,Map<Id,Account> accOldMap){
        String className = Elixir_Custom_Setting__c.getInstance().ProductMRNGenertaorExtensionClassName__c;
        for(Account acc : accList){
            String oldValue = accOldMap.get(acc.Id).MRN_Number_New__c;
            String newValue = acc.MRN_Number_New__c;
            if(String.isBlank(className) && String.isBlank(oldValue)){
                //acc.MRN_Number_New__c.addError('You are not allowed to edit this field');
            }else{
               // acc.MRN_Number_New__c.addError('You are not allowed to edit this field');
            }
        }
    }
    public static void replaceBirthSexField(List<Account> accList){
        for(Account acc : accList){
            if(String.isBlank(acc.ElixirSuite__Gender__c)){
                acc.ElixirSuite__Gender__c = 'UNK';
            }
        }
    }
    public static void mrnValidationBeforeUpdate(List<Account> accList,Map<Id,Account> oldAccMap){
        for (Account acc : accList) {
            String oldValue = oldAccMap.get(acc.Id).MRN_Number_New__c;
            String newValue = acc.MRN_Number_New__c;
            if (oldValue != null && oldValue != newValue) {
           //     acc.MRN_Number_New__c.addError('You are not allowed to edit this field');
            }
        }
    }
    public static void checkDuplicateFieldValue(List<Account> accounts) {
        try{
            for(Account acc : accounts){
                List<String> raceList = new List<String>();
                List<String> etencityList = new List<String>();
                List<String> langList = new List<String>();
                if(acc.ElixirSuite__Race_1__c != null){
                  raceList.add(acc.ElixirSuite__Race_1__c);  
                }
                if(acc.ElixirSuite__Race_2__c != null){
                  raceList.add(acc.ElixirSuite__Race_2__c);    
                }
                if(acc.ElixirSuite__Race_3__c != null){
                  raceList.add(acc.ElixirSuite__Race_3__c); 
                }
                if(acc.ElixirSuite__Race_4__c != null){
                  raceList.add(acc.ElixirSuite__Race_4__c); 
                }
                if(acc.ElixirSuite__Ethnicity_1__c != null){
                  etencityList.add(acc.ElixirSuite__Ethnicity_1__c); 
                }
                if(acc.ElixirSuite__Ethnicity_2__c != null){
                  etencityList.add(acc.ElixirSuite__Ethnicity_2__c); 
                }
                if(acc.ElixirSuite__Ethnicity_3__c != null){
                  etencityList.add(acc.ElixirSuite__Ethnicity_3__c); 
                }
                if(acc.ElixirSuite__Ethnicity_4__c != null){
                  etencityList.add(acc.ElixirSuite__Ethnicity_4__c); 
                }
                if(acc.ElixirSuite__Preferred_Language_1__c != null){
                  langList.add(acc.ElixirSuite__Preferred_Language_1__c); 
                }
                if(acc.ElixirSuite__Preferred_Language_2__c != null){
                  langList.add(acc.ElixirSuite__Preferred_Language_2__c); 
                }
                if(acc.ElixirSuite__Preferred_Language_3__c != null){
                  langList.add(acc.ElixirSuite__Preferred_Language_3__c); 
                }
                if(acc.ElixirSuite__Preferred_Language_4__c != null){
                  langList.add(acc.ElixirSuite__Preferred_Language_4__c); 
                }
                
                Set<String> rSet = new Set<String>(raceList);
                if(raceList.size() != rSet.size()){
                    acc.addError('Duplicate Race fields are not allowed, please deselect the duplicate Race(s).');
                }
                Set<String> eSet = new Set<String>(etencityList);
                if(etencityList.size() != eSet.size()){
                    acc.addError('Duplicate Ethnicity fields are not allowed, please deselect the duplicate Ethnicity(s).');
                }
                Set<String> lSet = new Set<String>(langList);
                if(langList.size() != lSet.size()){
                    acc.addError('Duplicate Preferred Language fields are not allowed, please deselect the duplicate Preferred Language(s).');
                }
                
            } 
        }catch(Exception e){
            ExceptionLog.logError(e);
        }
    }
    
}
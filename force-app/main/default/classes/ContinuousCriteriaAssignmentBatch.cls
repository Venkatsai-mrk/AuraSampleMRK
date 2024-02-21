/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-25-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class ContinuousCriteriaAssignmentBatch implements Database.Batchable<sObject>{

    public Database.QueryLocator start(Database.BatchableContext BC){
        String query='Select id,Name,ElixirSuite__Is_Active__c,ElixirSuite__QueryBuilder__c,ElixirSuite__Continuous_Criteria_based_assignment__c from ElixirSuite__Account_Group__c where ElixirSuite__Is_Active__c=true AND ElixirSuite__Continuous_Criteria_based_assignment__c=true';
        return Database.getQueryLocator(query); 
    }
    public void execute(Database.BatchableContext BC, List<ElixirSuite__Account_Group__c> scope){
        Set<Id> setOfAccountId ;
            //= new Set<Id>();
        Set<Id> setOfCareTeamId ;
        Set<Id> setOfLocationId ;
        Set<Id> setOfLocId ;
        
        Map<Id,List<Account>> mapOfGroupIdToAccounts = new Map<Id,List<Account>>();
        
        Set<Id> setOfGroupId = new Set<Id>();
        for(ElixirSuite__Account_Group__c groupRecord: scope){
            setOfGroupId.add(groupRecord.Id);
        }
        Map<Id,List<ElixirSuite__Criteria_Assignment__c>> mapOfGroupIdToListOfCriteriaAssignments = new Map<Id,List<ElixirSuite__Criteria_Assignment__c>>();
        List<ElixirSuite__Account_Group__c> listOfGroups = [Select id,Name,(Select id,name,ElixirSuite__Criteria_Type__c, ElixirSuite__Field_Value__c  FROM ElixirSuite__Criteria_Assignments__r
                                                                           ) from ElixirSuite__Account_Group__c where Id IN:setOfGroupId];
        
        List<ElixirSuite__Criteria_Assignment__c> criteriaAssignments;
        for(ElixirSuite__Account_Group__c accountGroup: listOfGroups){
            criteriaAssignments = new List<ElixirSuite__Criteria_Assignment__c>();
            if(accountGroup.ElixirSuite__Criteria_Assignments__r.size() >0){
                for(ElixirSuite__Criteria_Assignment__c criteriaRecord: accountGroup.ElixirSuite__Criteria_Assignments__r){
                    
					criteriaAssignments.add(criteriaRecord);                    
                }
            }
            mapOfGroupIdToListOfCriteriaAssignments.put(accountGroup.Id,criteriaAssignments);
        }
        Map<Id,ElixirSuite__Group_Patient__c> mapOfGroupPatients = new Map<Id,ElixirSuite__Group_Patient__c>([Select id,ElixirSuite__Group_Name__c,ElixirSuite__Current_Patient_Name__c from ElixirSuite__Group_Patient__c where
                                                                                                             ElixirSuite__Group_Name__c IN:setOfGroupId]);
        
        Map<String,ElixirSuite__Group_Patient__c> mapOfUnqiueKeyToGroupPatient = new Map<String,ElixirSuite__Group_Patient__c>();
        
        if(mapOfGroupPatients.size() >0){
            for(Id groupPatientId: mapOfGroupPatients.keySet()){
                String uniqueKey = mapOfGroupPatients.get(groupPatientId).ElixirSuite__Group_Name__c + '_'+mapOfGroupPatients.get(groupPatientId).ElixirSuite__Current_Patient_Name__c;
                
                mapOfUnqiueKeyToGroupPatient.put(uniqueKey,mapOfGroupPatients.get(groupPatientId));
            }
        }
        //Map<Id,Id>  mapOfAccountIdToGroupId= new  Map<Id,Id>();
        List<ElixirSuite__Group_Patient__c> listOfGroupPatientsToInsert = new List<ElixirSuite__Group_Patient__c>();
        
        for(ElixirSuite__Account_Group__c groupRecord: scope){
            system.debug('groupRecord '+groupRecord.id);
            criteriaAssignments =mapOfGroupIdToListOfCriteriaAssignments.get(groupRecord.Id);
            setOfAccountId =new Set<Id>();
            setOfCareTeamId = new Set<Id>();
            setOfLocationId = new Set<Id>();
            setOfLocId = new Set<Id>();
            if(criteriaAssignments.size() >0){
                for(ElixirSuite__Criteria_Assignment__c criteriaRecord: criteriaAssignments){
                    if(criteriaRecord.ElixirSuite__Criteria_Type__c =='Current Patient Name'){
                        List<FieldJson> rawObj = (List<FieldJson>) JSON.deserializeStrict(criteriaRecord.ElixirSuite__Field_Value__c,List<FieldJson>.class);
                        
                        for(FieldJson obj: rawObj){
                            String objId = String.valueOf(obj.Id);
                            if(objId!=null){
                                setOfAccountId.add(Id.valueOf(objId));
                            }
                        }
                        system.debug('setOfAccountId '+setOfAccountId);
                    }else if(criteriaRecord.ElixirSuite__Criteria_Type__c =='Care Team Member'){
                        List<FieldJson> rawObj = (List<FieldJson>) JSON.deserializeStrict(criteriaRecord.ElixirSuite__Field_Value__c,List<FieldJson>.class);
                        
                        for(FieldJson obj: rawObj){
                            String objId = String.valueOf(obj.Id);
                            if(objId!=null){
                                setOfCareTeamId.add(Id.valueOf(objId));
                            }
                        }
                    }else if(criteriaRecord.ElixirSuite__Criteria_Type__c =='Location'){
                        List<FieldJson> rawObj = (List<FieldJson>) JSON.deserializeStrict(criteriaRecord.ElixirSuite__Field_Value__c,List<FieldJson>.class);
                       
                        for(FieldJson obj: rawObj){
                            String objId = String.valueOf(obj.Id);
                            if(objId!=null){
                                setOfLocationId.add(Id.valueOf(objId));
                            }
                        }
                    }else if(criteriaRecord.ElixirSuite__Criteria_Type__c =='LOC'){
                        List<FieldJson> rawObj = (List<FieldJson>) JSON.deserializeStrict(criteriaRecord.ElixirSuite__Field_Value__c,List<FieldJson>.class);
                        
                        for(FieldJson obj: rawObj){
                            String objId = String.valueOf(obj.Id);
                            if(objId!=null){
                                setOfLocId.add(Id.valueOf(objId));
                            }
                        }
                    }
                }
            }
            if(groupRecord.ElixirSuite__QueryBuilder__c!=null){
                system.debug('qqq '+groupRecord.ElixirSuite__QueryBuilder__c);
                List<Account> matchingAccounts = (List<Account>)Database.query(groupRecord.ElixirSuite__QueryBuilder__c);
                system.debug('acc '+matchingAccounts.size());
                if(matchingAccounts.size() >0){
                    mapOfGroupIdToAccounts.put(groupRecord.id, matchingAccounts);
                    for(Account accountRecord: matchingAccounts){
                        string key = groupRecord.Id + '_' + accountRecord.Id;
                        
                        if(!mapOfUnqiueKeyToGroupPatient.containsKey(key)){
                             system.debug('acc '+accountRecord.Name+ ' group '+ groupRecord.name);
                            ElixirSuite__Group_Patient__c newGroupPatient = new ElixirSuite__Group_Patient__c();
                            newGroupPatient.ElixirSuite__Current_Patient_Name__c = accountRecord.Id;
                            newGroupPatient.ElixirSuite__Group_Name__c = groupRecord.Id;
                            newGroupPatient.ElixirSuite__Criteria_Based_Addition__c = true;
                            listOfGroupPatientsToInsert.add(newGroupPatient);
                        }
                    }
                }else{
                    mapOfGroupIdToAccounts.put(groupRecord.id, matchingAccounts);
                }
            }
        }
        
        if(listOfGroupPatientsToInsert.size() >0){
            if(Schema.sObjectType.ElixirSuite__Group_Patient__c.isCreateable() &&
            Schema.sObjectType.ElixirSuite__Group_Patient__c.fields.ElixirSuite__Criteria_Based_Addition__c.isCreateable() &&
            Schema.sObjectType.ElixirSuite__Group_Patient__c.fields.ElixirSuite__Group_Name__c.isCreateable() &&
            Schema.sObjectType.ElixirSuite__Group_Patient__c.fields.ElixirSuite__Current_Patient_Name__c.isCreateable()){
                 
            insert listOfGroupPatientsToInsert;
            }
        }
        Map<Id,List<ElixirSuite__Group_Patient__c>> mapOfGroupToGroupPatients = new Map<Id,List<ElixirSuite__Group_Patient__c>>();
        
        List<ElixirSuite__Account_Group__c> accountGroups= [Select id, Name, (Select id, name,ElixirSuite__Group_Name__c, ElixirSuite__Criteria_Based_Addition__c, ElixirSuite__Current_Patient_Name__c FROM ElixirSuite__Group_Patients__r ) from ElixirSuite__Account_Group__c where Id IN: setOfGroupId];
        if(accountGroups.size() >0){
            for(ElixirSuite__Account_Group__c acGroup: accountGroups){
                if(acGroup.ElixirSuite__Group_Patients__r.size() >0){
                    
                    mapOfGroupToGroupPatients.put(acGroup.id, acGroup.ElixirSuite__Group_Patients__r);
                }
            }
        }
        Map<Id,Account> mapOfAccounts;
        List<ElixirSuite__Group_Patient__c> groupPatientToBeDeleted = new List<ElixirSuite__Group_Patient__c>();
        if(mapOfGroupIdToAccounts.size() >0){
            for(Id groupId: mapOfGroupIdToAccounts.keySet()){
                if(mapOfGroupIdToAccounts.get(groupId).size() >0){
                    mapOfAccounts = new Map<Id,Account>(mapOfGroupIdToAccounts.get(groupId));
                    
                    if(mapOfGroupToGroupPatients.get(groupId).size() >0){
                        for(ElixirSuite__Group_Patient__c groupPatient: mapOfGroupToGroupPatients.get(groupId)){
                            if(!mapOfAccounts.containsKey(groupPatient.ElixirSuite__Current_Patient_Name__c)){
                                if(groupPatient.ElixirSuite__Criteria_Based_Addition__c){
                                    
                                    // system.debug('Patient '+ groupPatient.ElixirSuite__Current_Patient_Name__r.Name +' g '+ groupPatient.ElixirSuite__Group_Name__r.Name);
                                    groupPatientToBeDeleted.add(groupPatient);
                                }
                            }
                        }
                    }
                }else{
                    if(mapOfGroupToGroupPatients.get(groupId).size() >0){
                        for(ElixirSuite__Group_Patient__c groupPatient: mapOfGroupToGroupPatients.get(groupId)){
                            if(groupPatient.ElixirSuite__Criteria_Based_Addition__c){
                                groupPatientToBeDeleted.add(groupPatient);
                            }
                        }
                    }
                }
            }
        }
            if(Schema.sObjectType.ElixirSuite__Group_Patient__c.isDeletable()){
           // if(groupPatientToBeDeleted.size() >0){ 
                DMLManager.deleteAsUser(groupPatientToBeDeleted);   
            //delete groupPatientToBeDeleted;
       // }
    }
    }
    
    public void finish(Database.BatchableContext BC){
    }
    
    public class FieldJson{
        public String Id;
        public String Name;
        public String RecordTypeId;
    }
}
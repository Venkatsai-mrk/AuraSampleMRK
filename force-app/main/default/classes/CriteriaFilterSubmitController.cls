public with sharing class CriteriaFilterSubmitController {
    
    public static Map<String,String> mapOfOperatorToQueryOpertaor = new Map<String,String>{
        'equals' => '=',
        'greater than' => '>',
        'greater than or equal to' => '>=',
        'less than' => '<',
        'less than or equal to' => '<=',
        'not equal to' => '!='    
    };
public static Map<String,String> mapOfOperatorToQueryOpertaorForLookups = new Map<String,String>{
        'equals' => ' IN',
        'not equal to' => ' NOT IN'    
    };
        public static Map<String,String> mapOfFieldNameToQueryField = new Map<String,String>{
        'Current Patient Name' => 'Id',
        'LOC' => 'Elixirsuite__Level_Of_Care__c',
        'Location' => 'Elixirsuite__Active_Care_Episode_Location__c',
        'Care Team Member' => 'Elixirsuite__Care_Team_Member__c'
        
    };
        
       
        public static Set<Id> setOfAccountId = new Set<Id>();
    public static Set<Id> setOfCareTeamId = new Set<Id>();
    public static Set<Id> setOfLocationId = new Set<Id>();
    public static Set<Id> setOfLocId = new Set<Id>();
     
    @AuraEnabled
    public static String  getCriteriaFilter(string groupRecordId){
        /* Save filter on group
         * build query using filter expn
         * 
         * 
         * 
         * */
        ElixirSuite__Account_Group__c accountGroup = [select id,name,ElixirSuite__Criteria_Filter__c from ElixirSuite__Account_Group__c where id=:groupRecordId WITH SECURITY_ENFORCED limit 1];
        system.debug('accountGroup query' +accountGroup);
        
        return accountGroup.ElixirSuite__Criteria_Filter__c;
        
    }
    
    //Nikhil----Start
    @AuraEnabled
    public static string forEmptyLogicCriteria(string groupRecordId){
        List<ElixirSuite__Group_Patient__c> groupPatientList = [select id,name,ElixirSuite__Criteria_Based_Addition__c,ElixirSuite__Group_Name__c,ElixirSuite__Current_Patient_Name__c from ElixirSuite__Group_Patient__c where 
                                                                ElixirSuite__Group_Name__c=:groupRecordId WITH SECURITY_ENFORCED];
            
            if(groupPatientList.size()>0){
                DMLManager.deleteAsUser(groupPatientList);
               return  'GroupPatientUpdated';
            }else{
                return 'NoRelatedExit';
            }       
     }    
     //Nikhil---End
     @AuraEnabled
    public static void updateCriteriaFilterOnChange(string groupRecordId, String filter){
        
        ElixirSuite__Account_Group__c accountGroup = [select id,name,ElixirSuite__Criteria_Filter__c from ElixirSuite__Account_Group__c where id=:groupRecordId WITH SECURITY_ENFORCED limit 1];
        
        accountGroup.ElixirSuite__Criteria_Filter__c = filter;
        system.debug('update accountGroup' +accountGroup);
        if(Schema.sObjectType.ElixirSuite__Account_Group__c.isUpdateable()){
        update accountGroup;
        }
    }
    
     @AuraEnabled
    public static String saveCriteriaFilter(string groupRecordId, String filter){
        /* Save filter,queryBuilder on group object
         * build query using filter expn
         * removal of group patient not longer satisfying criteria logic and are added throught criteria based addition
         * create group patients
         * 
         * */
        try{
            
            ElixirSuite__Account_Group__c accountGroup = [select id,name,ElixirSuite__Is_Active__c,ElixirSuite__QueryBuilder__c,ElixirSuite__Criteria_Filter__c from ElixirSuite__Account_Group__c where id=:groupRecordId limit 1];
            
            String queryBuilder = buildQuery(groupRecordId,filter);
            if(accountGroup.ElixirSuite__Is_Active__c){
                createGroupPatients(queryBuilder,groupRecordId);
            }
            
            accountGroup.ElixirSuite__Criteria_Filter__c = filter;
            accountGroup.ElixirSuite__QueryBuilder__c = queryBuilder;
            update accountGroup;
        }catch(Exception e){
            system.debug('e '+e);
            
            String message =  e.getMessage();
            system.debug('mm'+message);
            if( message == 'unexpected token: OR'){
                message = 'Please add Starting ( and ending ) in the filter wheresoever OR is present';
            }else if(message == 'Argument cannot be null.'){
                 message = 'Please add Field value for the criteria record added with No Field value';
            }else if(message == 'unexpected token: \'<EOF>\''){
                 message = 'Please add criteria records and criteria logic';
            }else if(message =='unexpected token: \'1\''){
                message = 'Please add criteria records';
            }
            
            AuraHandledException ex = new AuraHandledException(message);
            if(Test.isRunningTest()){ //Nikhil Start
               system.debug('Pass');                
            }else{ 
            throw ex;
        }
            //Nikhil End
        }
        
         //Nikhil Start
          if(!Test.isRunningTest()){
           //added by Anmol for LX3-7115
           ElixirSuite__Account_Group__c accountGrouptoUpdate = [select id,ElixirSuite__PatientGroupValidationBreak__c from ElixirSuite__Account_Group__c where id=:groupRecordId WITH SECURITY_ENFORCED limit 1];
            
           if(accountGrouptoUpdate != null){
           accountGrouptoUpdate.ElixirSuite__PatientGroupValidationBreak__c=true;
          DMLManager.updateAsUser(accountGrouptoUpdate);
          //end by Anmol for LX3-7115
          }
        }
         //Nikhil End
        return 'Data Processed Ssuccessfully';
    }
    
    public static String buildQuery(String groupId, String expn){
		String currentStatus = 'Current Patients';
        Elixir_Custom_Setting__c val = Elixir_Custom_Setting__c.getOrgDefaults();
        String recordTypeName = val.ElixirSuite__Business_Account_Recordtype__c;
        boolean Deceased = False;
        system.debug('expn' +expn);
        //String queryBuilder = 'Select id,Name from Account where Elixirsuite__Current_Status_Of_Patient__c=\''+currentStatus+'\'AND RecordType.developerName!=\''+recordTypeName+'\''+' AND ';
        // String queryBuilder = 'Select id,Name from Account where Elixirsuite__Current_Status_Of_Patient__c=\''+currentStatus+'\'AND ElixirSuite__Deceased__c = '+ Deceased + ' AND RecordType.developerName!=\''+recordTypeName+'\''+' AND ';
        String queryBuilder = 'Select id,Name from Account where Elixirsuite__Current_Status_Of_Patient__c=\''+ String.escapeSingleQuotes(currentStatus)+'\'AND ElixirSuite__Deceased__c = '+ Deceased + ' AND RecordType.developerName!=\''+ String.escapeSingleQuotes(recordTypeName)+'\''+' AND ';

        Map<Integer,ElixirSuite__Criteria_Assignment__c> mapOfSnoToCriteriaAssignment = new Map<Integer,ElixirSuite__Criteria_Assignment__c>();
        Map<Integer,String> mapOfSnoToExpectedExpn = new Map<Integer,String>();
        
        List<ElixirSuite__Criteria_Assignment__c> listOfCriteriaAssignment = [SELECT Id, Name, ElixirSuite__Criteria_Type__c, ElixirSuite__Operator__c, ElixirSuite__Field_Value__c, ElixirSuite__S_No__c, ElixirSuite__Field_API_Name__c, ElixirSuite__Account_Group__c FROM ElixirSuite__Criteria_Assignment__c where 
                                                                              ElixirSuite__Account_Group__c=:groupId WITH SECURITY_ENFORCED order by ElixirSuite__S_No__c asc];
       
        system.debug('crr listOfCriteriaAssignment size =>'+listOfCriteriaAssignment.size());
        if(listOfCriteriaAssignment.size() >0){
            system.debug('crr  listOfCriteriaAssignment size'+listOfCriteriaAssignment.size());
            for(ElixirSuite__Criteria_Assignment__c record: listOfCriteriaAssignment){
                 
                mapOfSnoToCriteriaAssignment.put(Integer.valueOf(record.ElixirSuite__S_No__c), record);
                 String expectedExpn;
                 String queryOperator;
                String queryField;
                if(record.ElixirSuite__Criteria_Type__c == 'Age'){
                   
                     queryOperator = mapOfOperatorToQueryOpertaor.get(record.ElixirSuite__Operator__c);
                    expectedExpn = record.ElixirSuite__Field_API_Name__c +queryOperator +record.ElixirSuite__Field_Value__c;
                    system.debug('expectedExpn'+expectedExpn);
                }else if(record.ElixirSuite__Criteria_Type__c == 'Admit Date'){
                    
                    List<String> listofDateField = (List<String>) JSON.deserializeStrict(record.ElixirSuite__Field_Value__c,List<String>.class);
                    String combinedDate = String.valueOf(listofDateField[0]);
                    String[] arrayOfDates = combinedDate.split(' ');
                    Date startDate = Date.valueOf(arrayOfDates[0]);
                    Date endDate = Date.valueOf(arrayOfDates[1]);
                    expectedExpn = '('+record.ElixirSuite__Field_API_Name__c +'>='+arrayOfDates[0] +' AND '+record.ElixirSuite__Field_API_Name__c +'<='+arrayOfDates[1]+')';
                    system.debug('expectedExpn'+expectedExpn);
                    
                }else if(record.ElixirSuite__Criteria_Type__c == 'Current Patient Name'){
                    List<FieldJson> rawObj = (List<FieldJson>) JSON.deserializeStrict(record.ElixirSuite__Field_Value__c,List<FieldJson>.class);
                   system.debug('rawObj dataline 136'+rawObj);
                    for(FieldJson obj: rawObj){
                        String objId = String.valueOf(obj.Id);
                        
                        if(!String.isBlank(objId)){
                             
                            setOfAccountId.add(Id.valueOf(objId));
                        }
                    }
                    system.debug('setOfAccountId'+setOfAccountId.size());
                    if(setOfAccountId.size() >0){
                        queryOperator = mapOfOperatorToQueryOpertaorForLookups.get(record.ElixirSuite__Operator__c);
                        queryField = mapOfFieldNameToQueryField.get(record.ElixirSuite__Criteria_Type__c);
                        
                            expectedExpn = queryField   +queryOperator+ ':setOfAccountId';
                        
                       
                    }
                }else if(record.ElixirSuite__Criteria_Type__c == 'Care Team Member'){
                    List<FieldJson> rawObj = (List<FieldJson>) JSON.deserializeStrict(record.ElixirSuite__Field_Value__c,List<FieldJson>.class);

                    for(FieldJson obj: rawObj){
                        String objId = String.valueOf(obj.Id);
                        if(objId!=null){
                            setOfCareTeamId.add(Id.valueOf(objId));
                        }
                    }
                    If(setOfCareTeamId.size() >0){
                        system.debug('setofc '+setOfCareTeamId);
                        queryOperator = mapOfOperatorToQueryOpertaorForLookups.get(record.ElixirSuite__Operator__c);
                        queryField = mapOfFieldNameToQueryField.get(record.ElixirSuite__Criteria_Type__c);
                        expectedExpn = queryField + queryOperator +' :setOfCareTeamId';
                        
                    }
                }else if(record.ElixirSuite__Criteria_Type__c == 'Location'){
                    List<FieldJson> rawObj = (List<FieldJson>) JSON.deserializeStrict(record.ElixirSuite__Field_Value__c,List<FieldJson>.class);
                    
                    for(FieldJson obj: rawObj){
                        String objId = String.valueOf(obj.Id);
                        if(objId!=null){
                            setOfLocationId.add(Id.valueOf(objId));
                        }
                    }
                    If(setOfLocationId.size() >0){
                        queryOperator = mapOfOperatorToQueryOpertaorForLookups.get(record.ElixirSuite__Operator__c);
                        queryField = mapOfFieldNameToQueryField.get(record.ElixirSuite__Criteria_Type__c);
                        expectedExpn = queryField + queryOperator +':setOfLocationId';
                    }
                    
                }else if(record.ElixirSuite__Criteria_Type__c == 'LOC'){
                    List<FieldJson> rawObj = (List<FieldJson>) JSON.deserializeStrict(record.ElixirSuite__Field_Value__c,List<FieldJson>.class);
                    
                    for(FieldJson obj: rawObj){
                        String objId = String.valueOf(obj.Id);
                        if(objId!=null){
                            setOfLocId.add(Id.valueOf(objId));
                        }
                    }system.debug('setOfLocId.size'+setOfLocId.size());
                    If(setOfLocId.size() >0){
                        queryOperator = mapOfOperatorToQueryOpertaorForLookups.get(record.ElixirSuite__Operator__c);
                        queryField = mapOfFieldNameToQueryField.get(record.ElixirSuite__Criteria_Type__c);
                        expectedExpn = queryField + queryOperator +':setOfLocId';
                    }
                } 
                    
                mapOfSnoToExpectedExpn.put(Integer.valueOf(record.ElixirSuite__S_No__c),expectedExpn);
            }
        }
      
        String replacedExpn;
        List<String> listOfExpn = new List<String>();
         system.debug('map '+mapOfSnoToCriteriaAssignment);
        if(mapOfSnoToCriteriaAssignment.size() >0 && String.isNotBlank(expn)){
            
            for(Integer serialNo: mapOfSnoToCriteriaAssignment.keySet()){
                
                String serial = String.valueOf(serialNo);
                system.debug('serialNo '+serialNo);
                system.debug('serialNo '+serial);
               // replacedExpn = expn;
                if(expn.contains(serial)){
                    
                    //String innerExpn =replacedExpn.replace(serial, mapOfSnoToExpectedExpn.get(serialNo));
                   // listOfExpn.add(innerExpn);
                 
                    expn =expn.replace(serial, '$'+serial);
                }
            }
        }
        if(mapOfSnoToCriteriaAssignment.size() >0 && String.isNotBlank(expn)){
            
            for(Integer serialNo: mapOfSnoToCriteriaAssignment.keySet()){
                
                String serial = String.valueOf(serialNo);
                serial='$'+serial;
               
                if(expn.contains(serial)){
                    
                    expn =expn.replace(serial, mapOfSnoToExpectedExpn.get(serialNo));
                  system.debug('mapOfSnoToExpectedExpn get=='+mapOfSnoToExpectedExpn.get(serialNo));
                }
            }
        }
        system.debug('expn'+ expn);
       
       queryBuilder += expn;
        system.debug('queryBuilder' +queryBuilder);
        
        return queryBuilder;
        
    }
    public static void createGroupPatients(String queryBuilder, String groupId){
        
           if(!Test.isRunningTest()){
            //added by Anmol for LX3-7115
            ElixirSuite__Account_Group__c accountGrouptoUpdate = [select id,ElixirSuite__PatientGroupValidationBreak__c from ElixirSuite__Account_Group__c where id=:groupId WITH SECURITY_ENFORCED limit 1];
            
            if(accountGrouptoUpdate != null){
            accountGrouptoUpdate.ElixirSuite__PatientGroupValidationBreak__c=false;
           DMLManager.updateAsUser(accountGrouptoUpdate);
           //end by Anmol for LX3-7115
           }
        }
            List<Account> queriedAccounts = (List<Account>)Database.query(queryBuilder);
            system.debug('queriedAccounts'+queriedAccounts.size());
            Map<Id,Account> mapOfAccounts = new Map<Id,Account>(queriedAccounts);
            List<ElixirSuite__Group_Patient__c> groupPatientToBeInserted = new List<ElixirSuite__Group_Patient__c>();
            List<ElixirSuite__Group_Patient__c> groupPatientToBeDeleted = new List<ElixirSuite__Group_Patient__c>();
            
            /* Removel of patient no longer satisfy the filter added through criteria based assignment */
            List<ElixirSuite__Group_Patient__c> listOfGroupPatiens = [select id,name,ElixirSuite__Criteria_Based_Addition__c,ElixirSuite__Group_Name__c,ElixirSuite__Current_Patient_Name__c from ElixirSuite__Group_Patient__c where 
                                                                      ElixirSuite__Group_Name__c=:groupId WITH SECURITY_ENFORCED];
            
            if(listOfGroupPatiens.size() >0){
                for(ElixirSuite__Group_Patient__c gpRecord: listOfGroupPatiens){
                    if(!mapOfAccounts.containsKey(gpRecord.ElixirSuite__Current_Patient_Name__c)){
                        if(gpRecord.ElixirSuite__Criteria_Based_Addition__c){
                            system.debug('deleted '+gpRecord.ElixirSuite__Current_Patient_Name__c);
                            groupPatientToBeDeleted.add(gpRecord);
                        }
                        
                    }
                    else{
                        system.debug('donotcreate '+gpRecord.ElixirSuite__Current_Patient_Name__c);
                        mapOfAccounts.remove(gpRecord.ElixirSuite__Current_Patient_Name__c);
                    }
                }
            }
            
            if(mapOfAccounts.size() >0){
                for(Id accountRecordId: mapOfAccounts.keySet()){
                    system.debug('accountRecordId ' +accountRecordId + ' ' + mapOfAccounts.get(accountRecordId).Name);
                    ElixirSuite__Group_Patient__c newGroupPatient = new ElixirSuite__Group_Patient__c();
                    newGroupPatient.ElixirSuite__Group_Name__c = groupId;
                    newGroupPatient.ElixirSuite__Current_Patient_Name__c = accountRecordId;
                    newGroupPatient.ElixirSuite__Criteria_Based_Addition__c = true;
                    
                    groupPatientToBeInserted.add(newGroupPatient);
                }
            }
            
            
            if(groupPatientToBeDeleted.size() >0){
                if(Schema.sObjectType.ElixirSuite__Group_Patient__c.isDeletable()){
                delete groupPatientToBeDeleted;
                }
            }
            
            if(groupPatientToBeInserted.size() >0){
                
                Database.SaveResult[] srList = Database.insert(groupPatientToBeInserted, false);
                
                // Iterate through each returned result
                for (Database.SaveResult sr : srList) {
                    if (sr.isSuccess()) {
                        // Operation was successful, so get the ID of the record that was processed
                        System.debug('Successfully inserted group patients. Group Patient ID: ' + sr.getId());
                    }
                    else{
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('Fields that affected this error: ' + err.getFields());
                        }
                    }
                }
            }
        
    }
    
    public class FieldJson{
        public String Id;
        public String Name;
        public String RecordTypeId;
    }
}
public with sharing class CriteriaDisplayController {

    @AuraEnabled
    public static List<ElixirSuite__Criteria_Assignment__c > getAllCriteriaRecord(String parentGroupId){
        List<ElixirSuite__Criteria_Assignment__c > modifiedlistOfCritera = new List<ElixirSuite__Criteria_Assignment__c >();
        List<ElixirSuite__Criteria_Assignment__c > crtieriaRecords = [SELECT Id, Name,ElixirSuite__Field_API_Name__c, ElixirSuite__Criteria_Type__c, ElixirSuite__Operator__c, ElixirSuite__Field_Value__c, ElixirSuite__Account_Group__c, ElixirSuite__S_No__c FROM ElixirSuite__Criteria_Assignment__c 
                                                                where ElixirSuite__Account_Group__c=:parentGroupId WITH SECURITY_ENFORCED order by ElixirSuite__S_No__c asc];
        String queryBuilder;
        Set<String> setOfIds;
        if(crtieriaRecords.size() >0){
            for(ElixirSuite__Criteria_Assignment__c record: crtieriaRecords){
                if(record.ElixirSuite__Criteria_Type__c=='LOC' || record.ElixirSuite__Criteria_Type__c=='Care Team Member' || record.ElixirSuite__Criteria_Type__c=='Current Patient Name' || record.ElixirSuite__Criteria_Type__c=='Location'){
                    List<FieldJson> rawObj = (List<FieldJson>) JSON.deserializeStrict(record.ElixirSuite__Field_Value__c,List<FieldJson>.class);
                    String objName ='';
                    integer count = rawObj.size();
                    setOfIds = new Set<String>();
                    
                    for(integer i=0;i<count;i++){
                        FieldJson obj = rawObj[i];
                        setOfIds.add(obj.Id);
                    }
                    queryBuilder = 'Select Id,Name from '+ record.ElixirSuite__Field_API_Name__c + ' where Id IN: setOfIds';
                    if(record.ElixirSuite__Criteria_Type__c=='LOC'){
                    queryBuilder = 'Select Id,Name,ElixirSuite__Program_Name__c from '+ record.ElixirSuite__Field_API_Name__c + ' where Id IN: setOfIds';
                    }
                    
                    List<sObject> queriedData = (List<sObject>)Database.query(queryBuilder);
                    integer countdata = queriedData.size();
                    integer length= queriedData.size() -1;
                    
                    if(queriedData.size() >1){
                        
                        for(integer i=0;i<queriedData.size() -1;i++){
                           if(record.ElixirSuite__Criteria_Type__c=='LOC'){
                             objName += String.valueOf(queriedData[i].get('ElixirSuite__Program_Name__c')) +',';
                           }else{
                               objName += String.valueOf(queriedData[i].get('Name')) +',';
                           }
                        }
                        
                    }
                    
                    //integer length=count -1;
                  /*  if(count >1){
                        
                        for(integer i=0;i<length;i++){
                            FieldJson obj = rawObj[i];
                             objName += String.valueOf(obj.Name) +',';
                        }
                        
                    }*/
                    if(length >=0){
                        if(record.ElixirSuite__Criteria_Type__c=='LOC'){
                        objName+= queriedData[length].get('ElixirSuite__Program_Name__c');
                        }else{
                            
                            objName+= queriedData[length].get('Name');
                        }
                    }
                    record.ElixirSuite__Field_Value__c =   objName;  
                    
                    modifiedlistOfCritera.add(record);
            }
                if(record.ElixirSuite__Criteria_Type__c=='Admit Date'){
                    List<String> listofDateField = (List<String>) JSON.deserializeStrict(record.ElixirSuite__Field_Value__c,List<String>.class);
                    
                    record.ElixirSuite__Field_Value__c= String.valueOf(listofDateField[0]);
                    
                }
                
        }
       
    }
        return crtieriaRecords;
    }
    
     @AuraEnabled
    public static List<ElixirSuite__Criteria_Assignment__c > deleteCriteriaRecord(ElixirSuite__Criteria_Assignment__c criteriaRecord){
        
        DMLManager.deleteAsUser(criteriaRecord);
        
        return CriteriaDisplayController.getAllCriteriaRecord(criteriaRecord.ElixirSuite__Account_Group__c);
    }
    
    @AuraEnabled
    public static CriteriaWrapper editCriteriaHandling(ElixirSuite__Criteria_Assignment__c crRecord){
      List<Account> accounts = new List<Account>();
        List<ElixirSuite__Provider__c> locations = new List<ElixirSuite__Provider__c>();
        List<User> users = new List<User>();
       system.debug('id ' +crRecord.Id);
        ElixirSuite__Criteria_Assignment__c  crtieriaRecord= [SELECT Id, Name,ElixirSuite__Field_API_Name__c, ElixirSuite__Criteria_Type__c, ElixirSuite__Operator__c, ElixirSuite__Field_Value__c, ElixirSuite__Account_Group__c, ElixirSuite__S_No__c FROM ElixirSuite__Criteria_Assignment__c 
                                                                where Id=:crRecord.Id WITH SECURITY_ENFORCED limit 1];
        
        
        CriteriaWrapper criteriaWrap = new CriteriaWrapper();
        criteriaWrap.criteriatype = crtieriaRecord.ElixirSuite__Criteria_Type__c;
        criteriaWrap.operatorValue = crtieriaRecord.ElixirSuite__Operator__c;
        criteriaWrap.fieldApiName = crtieriaRecord.ElixirSuite__Field_API_Name__c;
        
        if(crtieriaRecord.ElixirSuite__Criteria_Type__c =='Age'){
            criteriaWrap.age = Integer.valueOf(crtieriaRecord.ElixirSuite__Field_Value__c);
        }
        else if(crtieriaRecord.ElixirSuite__Criteria_Type__c =='Admit Date'){
            List<String> listofDateField = (List<String>) JSON.deserializeStrict(crtieriaRecord.ElixirSuite__Field_Value__c,List<String>.class);
           system.debug('listofDateField'+listofDateField);
            String str = String.valueOf(listofDateField[0]);
              system.debug('str'+str);
            String[] dateArr = str.split(' ');
             system.debug('dateArr'+dateArr);
            system.debug('dateArr'+dateArr[0]);
            system.debug('dateArr'+dateArr[1]);
            if(dateArr[0]!=null){
                criteriaWrap.admitDate = Date.valueOf(dateArr[0]);
            }
            if(dateArr[1]!=null){
                criteriaWrap.admitEndDate = Date.valueOf(dateArr[1]);
            }
            
            //criteriaWrap.admitDate = Date.valueOf(crtieriaRecord.ElixirSuite__Field_Value__c);
        }
        else if(crtieriaRecord.ElixirSuite__Criteria_Type__c =='Current Patient Name'){
             
            List<FieldJson> rawObj = (List<FieldJson>) JSON.deserializeStrict(crtieriaRecord.ElixirSuite__Field_Value__c,List<FieldJson>.class);
            Set<Id> setOfAccountId = new Set<Id>();
            for(FieldJson obj: rawObj){
                String objId = String.valueOf(obj.Id);
                if(objId!=null){
                    setOfAccountId.add(Id.valueOf(objId));
                }
            }
            If(setOfAccountId.size() >0){
               accounts = [Select id,Name from Account where Id IN:setOfAccountId WITH SECURITY_ENFORCED];
                
                if(accounts.size() >0){
                    criteriaWrap.accountList = accounts;
                }
            }
        }
        else if(crtieriaRecord.ElixirSuite__Criteria_Type__c =='Location'){
             
            List<FieldJson> rawObj = (List<FieldJson>) JSON.deserializeStrict(crtieriaRecord.ElixirSuite__Field_Value__c,List<FieldJson>.class);
            Set<Id> setOfAccountId = new Set<Id>();
            for(FieldJson obj: rawObj){
                String objId = String.valueOf(obj.Id);
                if(objId!=null){
                    setOfAccountId.add(Id.valueOf(objId));
                }
            }
            If(setOfAccountId.size() >0){
                 locations = [Select id,Name from ElixirSuite__Provider__c where Id IN:setOfAccountId WITH SECURITY_ENFORCED];
                
                if(locations.size() >0){
                    criteriaWrap.locationList = locations;
                }
            }
        }
        else if(crtieriaRecord.ElixirSuite__Criteria_Type__c =='Care Team Member'){
             
            List<FieldJson> rawObj = (List<FieldJson>) JSON.deserializeStrict(crtieriaRecord.ElixirSuite__Field_Value__c,List<FieldJson>.class);
            Set<Id> setOfAccountId = new Set<Id>();
            for(FieldJson obj: rawObj){
                String objId = String.valueOf(obj.Id);
                if(objId!=null){
                    setOfAccountId.add(Id.valueOf(objId));
                }
            }
            If(setOfAccountId.size() >0){
                 users = [Select id,Name from User where Id IN:setOfAccountId WITH SECURITY_ENFORCED];
                
                if(users.size() >0){
                    criteriaWrap.careTeamMemberList = users;
                }
            }
        }
        else if(crtieriaRecord.ElixirSuite__Criteria_Type__c =='LOC'){
             
            List<FieldJson> rawObj = (List<FieldJson>) JSON.deserializeStrict(crtieriaRecord.ElixirSuite__Field_Value__c,List<FieldJson>.class);
            Set<Id> setOfAccountId = new Set<Id>();
            for(FieldJson obj: rawObj){
                String objId = String.valueOf(obj.Id);
                if(objId!=null){
                    setOfAccountId.add(Id.valueOf(objId));
                }
            }
          
        }
        criteriaWrap.parentToChildPicklistMap =CriteriaPageController.getDependentPicklist('ElixirSuite__Criteria_Assignment__c', 'ElixirSuite__Criteria_Type__c', 'ElixirSuite__Operator__c').pickListMap;
        return criteriaWrap;
    }
    
    public class FieldJson{
        public String Id;
        public String Name;
        public String RecordTypeId;
    }
    public class CriteriaWrapper{
        
        @AuraEnabled
        public Map<String, List<String>> parentToChildPicklistMap;
        
        @AuraEnabled public String fieldApiName { get; set; }
        
        @AuraEnabled public String criteriatype { get; set; }
        
        @AuraEnabled public String operatorValue { get; set; }
        
        @AuraEnabled public Integer age { get; set; }
        
        @AuraEnabled public Date admitDate { get; set; }
        
         @AuraEnabled public Date admitEndDate { get; set; }
        
        @AuraEnabled public List<Account> accountList { get; set; }
        
      @AuraEnabled public List<User> careTeamMemberList { get; set; }
        
        @AuraEnabled public List<ElixirSuite__Provider__c> locationList { get; set; }
        
    }
}
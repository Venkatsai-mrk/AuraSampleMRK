public with sharing class AppointmentreUsableMultiSelectLookupCtrl{
    
    @AuraEnabled
    public static User getCurrentUser(){
        
        system.debug('a '+[Select id,Name from User where Id=:UserInfo.getUserId() limit 1]);
        return [Select id,Name from User where Id=:UserInfo.getUserId() with security_enforced limit 1 ];
    }
    
  
    
    @AuraEnabled
    public static List<String> getSubject(){
        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = Event.Subject.getDescribe();
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            options.add(p.getLabel());
        }
        return options;
    }

    
   
    
    @AuraEnabled
    public static List<ElixirSuite__Utilization_Review__c> getSessionCount(string recId){
        List<ElixirSuite__Utilization_Review__c> countLst = new List<ElixirSuite__Utilization_Review__c>();
        countLst =  [Select ElixirSuite__Sessions_Available__c from ElixirSuite__Utilization_Review__c where ElixirSuite__Account__c =: recId WITH SECURITY_ENFORCED order by CreatedDate Desc limit 1];
        return countLst;
    }
    
    @AuraEnabled
    public static List<ElixirSuite__Elixir_Custom_Setting__c> getsessionPredefinedNo()
    {
        List<ElixirSuite__Elixir_Custom_Setting__c> alertCount= new List<ElixirSuite__Elixir_Custom_Setting__c>();
        alertCount =  [select ElixirSuite__UR_Alert_when_usable_session_count_below__c from ElixirSuite__Elixir_Custom_Setting__c WITH SECURITY_ENFORCED];
        System.debug('alertcount'+alertCount);
        return alertCount;
    }

    @AuraEnabled
    public static List < sObject > fetchLookUpValues(String searchKeyWord, String ObjectName, List<sObject> ExcludeitemsList, String assignedTo,
                                                     String coFacilitator) {
        String searchKey = '%' + searchKeyWord + '%';
        List < sObject > returnList = new List < sObject > ();
        String typeOfUser= 'Guest';
        List<string> lstExcludeitems = new List<string>();
        for(sObject item : ExcludeitemsList ){
            lstExcludeitems.add(item.id);
        }
        Elixir_Custom_Setting__c val = Elixir_Custom_Setting__c.getOrgDefaults();
        String bussinessAccRecType = val.ElixirSuite__Business_Account_Recordtype__c; 
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(bussinessAccRecType).getRecordTypeId();
        Id conRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Facilitator').getRecordTypeId();
        Id equipRecordTypeId = Schema.SObjectType.ElixirSuite__Procedure__c.getRecordTypeInfosByDeveloperName().get('Template_Equipment').getRecordTypeId();                                                 
        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5 and exclude already selected records 
        String sQuery =  'select id, Name from ' +string.escapeSingleQuotes(ObjectName) + ' where Name LIKE: searchKey AND Id NOT IN : lstExcludeitems order by createdDate DESC  limit 5';
        //String recordTypeName = 'Business_Account';
        try{
            if(ObjectName =='Account'){
                String currentStatus = 'Current Patients';
                
                sQuery =  'select id, Name,ElixirSuite__State__c,ElixirSuite__Services_Requested__c,ElixirSuite__Profile_Picture__c  from ' +string.escapeSingleQuotes(ObjectName) + ' where Name LIKE: searchKey AND Id NOT IN : lstExcludeitems AND ElixirSuite__Current_Status_Of_Patient__c = : currentStatus AND RecordTypeId !=: devRecordTypeId  order by createdDate DESC limit 5';
                
            }else if(ObjectName =='Account1'){
                ObjectName ='Account';
                sQuery =  'select id, Name from ' +string.escapeSingleQuotes(ObjectName) + ' where Name LIKE: searchKey AND Id NOT IN : lstExcludeitems AND RecordTypeId = : devRecordTypeId  order by createdDate DESC  limit 5';
                
            }else if(ObjectName =='ElixirSuite__Account_Group__c'){
                boolean status =true;
                sQuery =  'select id, Name from ' +string.escapeSingleQuotes(ObjectName) + ' where Name LIKE: searchKey AND Id NOT IN : lstExcludeitems AND ElixirSuite__Is_Active__c = : status order by createdDate DESC  limit 5';
                
            }else if(ObjectName =='User'){
                lstExcludeitems.add(assignedTo);
                system.debug('lstExcludeitems' +lstExcludeitems);
                sQuery =  'select id, Name from ' +string.escapeSingleQuotes(ObjectName) + ' where Name LIKE: searchKey AND Id NOT IN : lstExcludeitems AND  IsActive =true AND userType !=: typeOfUser order by createdDate DESC  limit 5'; 
            }else if(ObjectName =='Contact'){
                
                sQuery =  'select id, Name from ' +string.escapeSingleQuotes(ObjectName) + ' where Name LIKE: searchKey AND Id NOT IN : lstExcludeitems AND RecordTypeId = : conRecordTypeId order by createdDate DESC  limit 5';
                
            }
            
            
            List < sObject > lstOfRecords = Database.query(sQuery);
            
            for (sObject obj: lstOfRecords) {
                returnList.add(obj);
                
            }
           // return returnList;
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        return returnList;
    }
    
    @AuraEnabled
    public static List < sObject > fetchSingleLookUpValue1(String searchKeyWord, String ObjectName,ElixirSuite__Provider__c locationObj,String ExcludeitemsList,datetime startt, datetime endt) {
        system.debug('ObjectName-->' + ObjectName);
        String searchKey = searchKeyWord + '%';
        String typeOfUser= 'Guest';
        
        List<string> lstExcludeitems = (List<string>) JSON.deserialize(ExcludeitemsList, List<string>.class);
         
        
        List < sObject > returnList = new List < sObject > ();
        String sQuery =  'select id, Name from ' +string.escapeSingleQuotes(ObjectName) + ' where Name LIKE: searchKey order by createdDate DESC limit 5';
        Id locRecordtypeId =Schema.SObjectType.ElixirSuite__Provider__c.getRecordTypeInfosByDeveloperName().get('Template_Provider').getRecordTypeId();
     
        try{
            if(ObjectName.equalsIgnoreCase('ElixirSuite__Provider__c')){
                sQuery =  'select id, Name from ' +string.escapeSingleQuotes(ObjectName) + ' where Name LIKE: searchKey AND RecordTypeId =: locRecordtypeId order by createdDate DESC limit 5';
            }
            if(ObjectName.equalsIgnoreCase('User')){
                sQuery =  'select id, Name from ' +string.escapeSingleQuotes(ObjectName) + ' where Name LIKE: searchKey AND IsActive =true AND userType !=: typeOfUser order by createdDate DESC limit 5';
            }
            if(!(ObjectName.equalsIgnoreCase('User') || ObjectName.equalsIgnoreCase('ElixirSuite__Provider__c'))){
                String locationId =locationObj.Id;
                boolean underMaintainance =false;
                sQuery =  'select id, Name from ' +string.escapeSingleQuotes(ObjectName) + ' where Name LIKE: searchKey AND ElixirSuite__Location__c = : locationId order by createdDate DESC limit 5';
                if(ObjectName == 'ElixirSuite__Rooms__c'){
                    sQuery =  'select id, Name,ElixirSuite__Location__c from ' +string.escapeSingleQuotes(ObjectName) + ' where Name LIKE: searchKey AND ElixirSuite__Location__c = : locationId AND ElixirSuite__Under_Maintenance_Removed__c = : underMaintainance order by createdDate DESC limit 5';
                    
                }
                
            }
            //Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business_Room').getRecordTypeId();
            
            
            
            List < sObject > lstOfRecords = Database.query(sQuery);
            
            for (sObject obj: lstOfRecords) {
                returnList.add(obj);
            }
            
            //return returnList;
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        return returnList;
    }
    
    
       

}
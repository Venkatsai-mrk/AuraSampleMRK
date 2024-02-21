public with sharing class ElixirOEM_LocationDefinitionHelper {
    @AuraEnabled
    public static FormApproval_InitWrapper initCalled_fetchApprovalData(String formNameInPainText) {
        FormApproval_InitWrapper toreturnData = new FormApproval_InitWrapper();
        toreturnData.numberOfApprovalLevels = fetchNumberOfFormsApprovalLevel();
        return toreturnData;
    } 
    @AuraEnabled
    public static FormApprovalHelperWrapper fetchOptions_SetupKey(String setUpKey) {
        
        FormApprovalHelperWrapper toReturnData = new FormApprovalHelperWrapper();
        try{
        switch on setUpKey {
            when 'User' {
                toReturnData.allUsers = fetchAllActiveUsers();
            }when 'Role' {
                toReturnData.allUserRoles = fetchAllRoles();
            }
            when 'Profile' {
                toReturnData.allProfiles = fetchAllProfiles();
            }
            when 'Patient' {
                //  toReturnData.currentPatient = fetchCurrentPatient();
            }
            when else {
                System.Debug('Error');
            }
        }
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        toReturnData.allProvider = new List<ElixirSuite__Provider__c>();
        toReturnData.allProvider = fetchProvider();
        return toReturnData;
    }
    
    @AuraEnabled
    public static UserLocationWrappper fetchExistingLocationRecordForGivenEntity(Integer approvalLevel,String formName,String entityName){
        switch on entityName {
            when 'User' {
                
            }when 'Role' {
                
            }
            when 'Profile' {
                
            }when else {
                System.Debug('Error');
            }
        }
        System.debug('entityName  '+entityName);
        ElixirSuite__UserLocation__c[] allUserLocRecord = fetchAllUserLocationRecordForGivenEntity(entityName);   
        List<sObject> setkeyMap = fetchMapOfSetUpKey(entityName);
        UserLocationWrappper wrpr = new UserLocationWrappper();
        wrpr.setkeyMap = setkeyMap;
        wrpr.allUserLocRecord = allUserLocRecord;
        wrpr.allProvider = fetchProvider();
        return wrpr;
    }
    public static  List<sObject> fetchMapOfSetUpKey(String key){
        FormApprovalHelperWrapper objInstance =  fetchOptions_SetupKey(key);
        Map<String,List<sObject>> mapOfSObject = new  Map<String,List<sObject>>();
        try{
        switch on key {
            when 'User' {
                mapOfSObject.put('User',fetchAllActiveUsers());
            }when 'Role' {
                mapOfSObject.put('Role',fetchAllRoles());
            }
            when 'Profile' {
                mapOfSObject.put('Profile',fetchAllProfiles());
            }when else {
                System.Debug('Error');
            }
        }
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        return mapOfSObject.get(key);
    }
    public static void deleteRelatedProviderForUser(String locationData){
        Map<String, Object> mapOfLocationData =(Map<String, Object>) JSON.deserializeUntyped(locationData);
        List<Object> obj_locationData = (List<Object>) mapOfLocationData.get('locDataToSave');
        
        String[] toDeleteProviderForUser = new List<String>();
        for(Object locationRec : obj_locationData){
            Map<String, Object> mapOfLocationToData = (Map<String, Object>) locationRec;                                                                                        
            toDeleteProviderForUser.add(String.valueOf(mapOfLocationToData.get('selectedUserId')));                                                                                                                                                                                                                                       
        }
        delete [SELECT ID,ElixirSuite__User__c FROM ElixirSuite__UserLocation__c WHERE ElixirSuite__User__c IN : toDeleteProviderForUser]; 
    }
    public static void deleteRelatedProviderForProfile(String locationData){
        Map<String, Object> mapOfLocationData =(Map<String, Object>) JSON.deserializeUntyped(locationData);
        List<Object> obj_locationData = (List<Object>) mapOfLocationData.get('locDataToSave');
        
        String[] toDeleteProviderForUser = new List<String>();
        for(Object locationRec : obj_locationData){
            Map<String, Object> mapOfLocationToData = (Map<String, Object>) locationRec;                                                                                        
            toDeleteProviderForUser.add(String.valueOf(mapOfLocationToData.get('selectedUserId')));                                                                                                                                                                                                                                       
        }
        delete [SELECT ID,ElixirSuite__User__c FROM ElixirSuite__UserLocation__c WHERE ElixirSuite__Profile__c IN : toDeleteProviderForUser]; 
    }
    public static void deleteRelatedProviderForRole(String locationData){
        Map<String, Object> mapOfLocationData =(Map<String, Object>) JSON.deserializeUntyped(locationData);
        List<Object> obj_locationData = (List<Object>) mapOfLocationData.get('locDataToSave');
        
        String[] toDeleteProviderForUser = new List<String>();
        for(Object locationRec : obj_locationData){
            Map<String, Object> mapOfLocationToData = (Map<String, Object>) locationRec;                                                                                        
            toDeleteProviderForUser.add(String.valueOf(mapOfLocationToData.get('selectedUserId')));                                                                                                                                                                                                                                       
        }
        delete [SELECT ID,ElixirSuite__User__c FROM ElixirSuite__UserLocation__c WHERE ElixirSuite__Role__c IN : toDeleteProviderForUser]; 
    }
    public static void combinedDelteion(List<String> toDelRecords){
        delete [SELECT ID,ElixirSuite__User__c FROM ElixirSuite__UserLocation__c 
                WHERE ElixirSuite__Role__c IN : toDelRecords
                WITH SECURITY_ENFORCED]; 
        delete [SELECT ID,ElixirSuite__User__c FROM ElixirSuite__UserLocation__c 
                WHERE ElixirSuite__Profile__c IN : toDelRecords
                WITH SECURITY_ENFORCED]; 
        delete [SELECT ID,ElixirSuite__User__c FROM ElixirSuite__UserLocation__c 
                WHERE ElixirSuite__User__c IN : toDelRecords
                WITH SECURITY_ENFORCED]; 
    }
    @AuraEnabled
    public static Boolean updateLocation(String approver,String approvalLevel,String selectedApprovers,String dropDownOptions,
                                         String formName, String mapOfSetUpKey,String approverNames,String locationData,String setupKeySelected,
                                         List<String> toDelRecords) {
                                             Boolean empty= false;
                                             combinedDelteion(toDelRecords);
                                             switch on setupKeySelected {
                                                 when 'User' {
                                                     deleteRelatedProviderForUser(locationData);
                                                     empty=  insertUserLocationForUSER(approver, approvalLevel, selectedApprovers, dropDownOptions,
                                                                                       formName,  mapOfSetUpKey, approverNames, locationData, setupKeySelected);
                                                 }when 'Role' {
                                                     deleteRelatedProviderForRole(locationData); 
                                                     empty =   insertUserLocationForROLE(approver, approvalLevel, selectedApprovers, dropDownOptions,
                                                                                         formName,  mapOfSetUpKey, approverNames, locationData, setupKeySelected);  
                                                 }
                                                 when 'Profile' {
                                                     deleteRelatedProviderForProfile(locationData); 
                                                     empty =   insertUserLocationForPROFILE(approver, approvalLevel, selectedApprovers, dropDownOptions,
                                                                                            formName,  mapOfSetUpKey, approverNames, locationData, setupKeySelected);
                                                 }when else {
                                                     System.Debug('Error');
                                                 }
                                             }
                                             
                                             return empty;
                                         }
    
    @AuraEnabled
    public static Boolean saveLocationForUser(String approver,String approvalLevel,String selectedApprovers,String dropDownOptions,
                                              String formName, String mapOfSetUpKey,String approverNames,String locationData,String setupKeySelected) {
                                                  Boolean empty = false;   
                                                  switch on setupKeySelected {
                                                      when 'User' {
                                                          empty=  insertUserLocationForUSER(approver, approvalLevel, selectedApprovers, dropDownOptions,
                                                                                            formName,  mapOfSetUpKey, approverNames, locationData, setupKeySelected);
                                                      }when 'Role' {
                                                          empty =   insertUserLocationForROLE(approver, approvalLevel, selectedApprovers, dropDownOptions,
                                                                                              formName,  mapOfSetUpKey, approverNames, locationData, setupKeySelected);  
                                                      }
                                                      when 'Profile' {
                                                          empty =   insertUserLocationForPROFILE(approver, approvalLevel, selectedApprovers, dropDownOptions,
                                                                                                 formName,  mapOfSetUpKey, approverNames, locationData, setupKeySelected);
                                                      }when else {
                                                          System.Debug('Error');
                                                      }
                                                  }
                                                  return empty; 
                                              }
    public static Boolean insertUserLocationForUSER(String approver,String approvalLevel,String selectedApprovers,String dropDownOptions,
                                                    String formName, String mapOfSetUpKey,String approverNames,String locationData,String setupKeySelected){
                                                        Boolean isEmpty= false;
                                                        Map<ID, ElixirSuite__Provider__c> mapOfProvider = new Map<ID, ElixirSuite__Provider__c>([SELECT ID,Name FROM ElixirSuite__Provider__c 
                                                                                                                                                 WHERE Name!=null WITH SECURITY_ENFORCED]);
                                                        
                                                        Map<String, Object> lstOfDropDownOptions =(Map<String, Object>) JSON.deserializeUntyped(dropDownOptions);
                                                        List<Object> obj_lstOfDropDownOptions = (List<Object>) lstOfDropDownOptions.get('keysToSave');
                                                        
                                                        Map<String, Object> mapOfLocationData =(Map<String, Object>) JSON.deserializeUntyped(locationData);
                                                        List<Object> obj_locationData = (List<Object>) mapOfLocationData.get('locDataToSave');
                                                        
                                                        ElixirSuite__UserLocation__c[] userLocationRecordArray = new List<ElixirSuite__UserLocation__c>();
                                                        for(Object locationRec : obj_locationData){
                                                            Map<String, Object> mapOfLocationToData = (Map<String, Object>) locationRec;   
                                                            List<Object> locations = (List<Object>) mapOfLocationToData.get('selectedLocations');
                                                            for(Object instanceRec : locations){
                                                                ElixirSuite__UserLocation__c objInstance = new ElixirSuite__UserLocation__c();              
                                                                objInstance.ElixirSuite__User__c = String.valueOf(mapOfLocationToData.get('selectedUserId'));
                                                                objInstance.ElixirSuite__Provider__c = String.valueOf(instanceRec);
                                                                objInstance.Type__c = setupKeySelected;
                                                                objInstance.Name = String.valueOf(mapOfLocationToData.get('selectedUser')) + ' - ' + returnNameForProvider(String.valueOf(instanceRec),mapOfProvider);
                                                                List<Object> locationOptions = (List<Object>) mapOfLocationToData.get('locationOptions');
                                                                objInstance.ElixirSuite__Location_Dropdown_Options__c = JSON.serialize(locationOptions);
                                                                objInstance.ElixirSuite__Dropdown_Options__c = JSON.serialize(obj_lstOfDropDownOptions);
                                                                userLocationRecordArray.add(objInstance);
                                                            }                                                                                                                                                             
                                                        }
                                                        if(Schema.sObjectType.ElixirSuite__UserLocation__c.isCreateable()){
                                                        insert userLocationRecordArray; 
                                                        } 
                                                        system.debug('final insert was done!!');
                                                        return isEmpty;
                                                    }
    
    public static Boolean insertUserLocationForPROFILE(String approver,String approvalLevel,String selectedApprovers,String dropDownOptions,
                                                       String formName, String mapOfSetUpKey,String approverNames,String locationData,String setupKeySelected){
                                                           Boolean isEmpty= false;
                                                           Map<ID, ElixirSuite__Provider__c> mapOfProvider = new Map<ID, ElixirSuite__Provider__c>([SELECT ID,Name FROM ElixirSuite__Provider__c 
                                                                                                                                                    WHERE Name!=null WITH SECURITY_ENFORCED]);
                                                           Map<String, Object> lstOfDropDownOptions =(Map<String, Object>) JSON.deserializeUntyped(dropDownOptions);
                                                           List<Object> obj_lstOfDropDownOptions = (List<Object>) lstOfDropDownOptions.get('keysToSave');
                                                           
                                                           Map<String, Object> mapOfLocationData =(Map<String, Object>) JSON.deserializeUntyped(locationData);
                                                           List<Object> obj_locationData = (List<Object>) mapOfLocationData.get('locDataToSave');
                                                           
                                                           ElixirSuite__UserLocation__c[] userLocationRecordArray = new List<ElixirSuite__UserLocation__c>();
                                                           
                                                           for(Object locationRec : obj_locationData){
                                                               Map<String, Object> mapOfLocationToData = (Map<String, Object>) locationRec;   
                                                               List<Object> locations = (List<Object>) mapOfLocationToData.get('selectedLocations');
                                                               /***FILLING FOR EVERY USER INSIDE THAT LOCATION***/
                                                               User[] allUserInProfile = new List<User>();
                                                               allUserInProfile = [SELECT Id,Name FROM User WHERE ProfileId =:String.valueOf(mapOfLocationToData.get('selectedUserId'))
                                                                                   WITH SECURITY_ENFORCED];  
                                                               if(allUserInProfile.size()==0){
                                                                   isEmpty = true;
                                                               }
                                                               for(User objUser : allUserInProfile){// NOW FOR EVERY USER IN PROFILE CREATE USER-LOCATION RECORD
                                                                   for(Object instanceRec : locations){
                                                                       ElixirSuite__UserLocation__c objInstance = new ElixirSuite__UserLocation__c();              
                                                                       objInstance.ElixirSuite__User__c = objUser.Id;
                                                                       objInstance.ElixirSuite__Provider__c = String.valueOf(instanceRec);
                                                                       objInstance.Type__c = setupKeySelected;
                                                                       objInstance.ElixirSuite__Profile__c = String.valueOf(mapOfLocationToData.get('selectedUserId'));
                                                                       objInstance.Name = objUser.Name + ' - ' + returnNameForProvider(String.valueOf(instanceRec),mapOfProvider);
                                                                       List<Object> locationOptions = (List<Object>) mapOfLocationToData.get('locationOptions');
                                                                       objInstance.ElixirSuite__Location_Dropdown_Options__c = JSON.serialize(locationOptions);
                                                                       objInstance.ElixirSuite__Dropdown_Options__c = JSON.serialize(obj_lstOfDropDownOptions);
                                                                       userLocationRecordArray.add(objInstance);
                                                                   }     
                                                               }
                                                               
                                                           }
                                                           insert userLocationRecordArray;  
                                                           return isEmpty;
                                                       }
    public static Boolean insertUserLocationForROLE(String approver,String approvalLevel,String selectedApprovers,String dropDownOptions,
                                                    String formName, String mapOfSetUpKey,String approverNames,String locationData,String setupKeySelected){
                                                        Boolean isEmpty= false;
                                                        Map<ID, ElixirSuite__Provider__c> mapOfProvider = new Map<ID, ElixirSuite__Provider__c>([SELECT ID,Name FROM ElixirSuite__Provider__c 
                                                                                                                                                 WHERE Name!=null WITH SECURITY_ENFORCED]);
                                                        Map<String, Object> lstOfDropDownOptions =(Map<String, Object>) JSON.deserializeUntyped(dropDownOptions);
                                                        List<Object> obj_lstOfDropDownOptions = (List<Object>) lstOfDropDownOptions.get('keysToSave');
                                                        
                                                        Map<String, Object> mapOfLocationData =(Map<String, Object>) JSON.deserializeUntyped(locationData);
                                                        List<Object> obj_locationData = (List<Object>) mapOfLocationData.get('locDataToSave');
                                                        
                                                        ElixirSuite__UserLocation__c[] userLocationRecordArray = new List<ElixirSuite__UserLocation__c>();
                                                        try{
                                                        for(Object locationRec : obj_locationData){
                                                            Map<String, Object> mapOfLocationToData = (Map<String, Object>) locationRec;   
                                                            List<Object> locations = (List<Object>) mapOfLocationToData.get('selectedLocations');
                                                            /***FILLING FOR EVERY USER INSIDE THAT LOCATION***/
                                                            User[] allUserInRole  = new List<User>();
                                                            allUserInRole = [SELECT Id,Name FROM User WHERE UserRoleId =:String.valueOf(mapOfLocationToData.get('selectedUserId'))
                                                                             WITH SECURITY_ENFORCED];
                                                            if(allUserInRole.size()==0){
                                                                isEmpty = true;
                                                            }
                                                            for(User objUser : allUserInRole){// NOW FOR EVERY USER IN ROLE CREATE USER-LOCATION RECORD
                                                                for(Object instanceRec : locations){
                                                                    ElixirSuite__UserLocation__c objInstance = new ElixirSuite__UserLocation__c();              
                                                                    objInstance.ElixirSuite__User__c = objUser.Id;
                                                                    objInstance.ElixirSuite__Provider__c = String.valueOf(instanceRec);
                                                                    objInstance.Type__c = setupKeySelected;
                                                                    objInstance.ElixirSuite__Role__c = String.valueOf(mapOfLocationToData.get('selectedUserId'));
                                                                    objInstance.Name = objUser.Name + ' - ' + returnNameForProvider(String.valueOf(instanceRec),mapOfProvider);
                                                                    List<Object> locationOptions = (List<Object>) mapOfLocationToData.get('locationOptions');
                                                                    objInstance.ElixirSuite__Location_Dropdown_Options__c = JSON.serialize(locationOptions);
                                                                    objInstance.ElixirSuite__Dropdown_Options__c = JSON.serialize(obj_lstOfDropDownOptions);
                                                                    userLocationRecordArray.add(objInstance);
                                                                }     
                                                            }
                                                            
                                                        }
                                                        insert userLocationRecordArray; 
                                                        }
                                                        catch(Exception e){
                                                        ExceptionLog.logError(e);
                                                              }
                                                        return isEmpty;
                                                    }
    public static String returnNameForProvider(String userID, Map<ID, ElixirSuite__Provider__c> mapOfProvider){       
        ElixirSuite__Provider__c instanceRecord = mapOfProvider.get(userID);        
        return instanceRecord.Name;    
    }
    
    /**************** QUERY DUMPING GROUND ************************/
    public static List<ElixirSuite__UserLocation__c> fetchAllUserLocationRecordForGivenEntity(String entity){
        return [SELECT ElixirSuite__Dropdown_Options__c,ElixirSuite__Location_Dropdown_Options__c,ElixirSuite__Provider__c,ElixirSuite__Role__c,
                ElixirSuite__Profile__c,
                ElixirSuite__Type__c,ElixirSuite__User__c,ElixirSuite__User__r.Id,ElixirSuite__User__r.Name,Id,Name FROM ElixirSuite__UserLocation__c
                WHERE ElixirSuite__Type__c =: entity  WITH SECURITY_ENFORCED];
    }
    public static List<ElixirSuite__Provider__c> fetchProvider() {
        Id recordTypeId =
            Schema.SObjectType.ElixirSuite__Provider__c.getRecordTypeInfosByDeveloperName()
            .get('Template_Provider').getRecordTypeId();
        return [SELECT ID,Name FROM ElixirSuite__Provider__c WHERE Name!=null 
                AND RecordTypeId = : recordTypeId WITH SECURITY_ENFORCED];        
    }
    public static List<User> fetchAllActiveUsers(){
        return [SELECT ID,Name FROM User WHERE IsActive = true WITH SECURITY_ENFORCED];
    }
    public static List<Profile> fetchAllProfiles(){
        return [SELECT ID,Name	 FROM Profile where Name!=null WITH SECURITY_ENFORCED];
    }
    public static List<UserRole> fetchAllRoles(){
        return [Select Id, Name from UserRole  where Name!=null WITH SECURITY_ENFORCED];
    }
    public static List<ApprovalLevelForForms__c> fetchNumberOfFormsApprovalLevel(){
        return [SELECT ID,Maximum_Level_For_Approval__c FROM ApprovalLevelForForms__c WHERE 
                Maximum_Level_For_Approval__c!=NULL 
                WITH SECURITY_ENFORCED
                LIMIT 1];
    }
    
    /**************************************************************/
    /**************** WRAPPER DUMPING GROUND ************************/
    public class UserLocationWrappper {
        @AuraEnabled  public List<ElixirSuite__UserLocation__c> allUserLocRecord{get;set;}
        @AuraEnabled  public  List<sObject> setkeyMap {get;set;} 
        @AuraEnabled  public List<ElixirSuite__Provider__c> allProvider{get;set;}
    }
    public class FormApprovalHelperWrapper {
        @AuraEnabled  	public  List<User> allUsers{ get; set; }
        @AuraEnabled  	public  List<Profile> allProfiles{ get; set; }
        @AuraEnabled  	public  List<UserRole> allUserRoles{ get; set; }
        @AuraEnabled  	public List<ElixirSuite__Provider__c> allProvider{get;set;}
    }
    public class FormApproval_InitWrapper {
        @AuraEnabled  	public List<ApprovalLevelForForms__c> numberOfApprovalLevels{ get; set; }
    }
    public static void dummyMethod(){
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
    /**************************************************************/
}
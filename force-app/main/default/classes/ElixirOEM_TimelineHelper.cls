/*
Developer Name : Tanveer Ahmed
Created Date : 07 / 12 / 2020  2:00PM
Purpose : To send data of Master objects(Timeline Configuration Object) and it's records to timeline component
*/
public with sharing class ElixirOEM_TimelineHelper { 
    //Added by Ashwini
    @AuraEnabled
    public static string fetchAccountName(string accountId){
        List<Account> acc=[SELECT Id, name FROM Account WHERE Id= :accountId WITH SECURITY_ENFORCED];
        string accName = acc[0].name;
        return accName;
    }
    @AuraEnabled 
    public static ParentWrapperForAllAccountInformation parentMethod_FetchAllData(String acctId) {
        System.debug('init ');
        Map<String,List<sObject>> dirtyMap = new Map<String,List<sObject>>();
        Map<String,List<sObject>> allDataOnGraph = new Map<String,List<sObject>>();
        Map<String,List<sObject>> objectNameAndDataMap = new Map<String,List<sObject>>();
        List<DisplayGraphdataWrappper> tolist = new List<DisplayGraphdataWrappper>();
        String recType =  Schema.SObjectType.ElixirSuite__Master_Object__c.getRecordTypeInfosByDeveloperName().get('Timeline_Configuration').getRecordTypeId();
        List<Master_Object__c> allObjectsToDisplayOnTimeline = [SELECT CreatedById,CreatedDate,Id,Object_Color__c,IsDeleted,LastModifiedById,LastModifiedDate,Name,
                                                                Object_API_Name__c,Object_Category__c,Object_Name__c,OwnerId,Patient_Account_Lookup__c,
                                                                Sort_Order__c FROM Master_Object__c WHERE RecordTypeId =:recType
                                                                WITH SECURITY_ENFORCED LIMIT 49999];
        
        if(allObjectsToDisplayOnTimeline!=null && allObjectsToDisplayOnTimeline.size()>0){
            List<TimelineSortWrapper> toSortTimeLineObjects = new List<TimelineSortWrapper>();
            for(Master_Object__c toAddRecords : allObjectsToDisplayOnTimeline){
                toSortTimeLineObjects.add(new TimelineSortWrapper(toAddRecords));          
            }
            toSortTimeLineObjects.sort();
            allObjectsToDisplayOnTimeline = new List<Master_Object__c>();
            List<Master_Object__c> getData = new List<Master_Object__c>();
            for(TimelineSortWrapper f : toSortTimeLineObjects){              
                allObjectsToDisplayOnTimeline.add(f.oppy);  
            }
            System.debug('allObjectsToDisplayOnTimeline '+allObjectsToDisplayOnTimeline);
            for(Integer i=0;i<allObjectsToDisplayOnTimeline.size();i++){
                
                String objectName = allObjectsToDisplayOnTimeline[i].ElixirSuite__Object_API_Name__c;     
                System.debug('objectName '+objectName);
                String fieldApiNames = String.escapeSingleQuotes(getAllFieldsNameOfObject(objectName));
                fieldApiNames+=' FROM '+ String.escapeSingleQuotes(objectName) 
                    + ' WHERE ' + String.escapeSingleQuotes(allObjectsToDisplayOnTimeline[i].ElixirSuite__Patient_Account_Lookup__c) + ' = '+ '\''+
                    String.escapeSingleQuotes(acctId)+'\'';
                mDebugUntruncated(fieldApiNames);
                List<sObject> objectWiseData = new List<sObject>();
                objectWiseData = Database.query(fieldApiNames);
                objectNameAndDataMap.put(objectName,objectWiseData);
                allDataOnGraph.put(allObjectsToDisplayOnTimeline[i].Object_Category__c,objectWiseData);
            }
            list<Master_Object__c> sameObjectCategoryRecords = new list<Master_Object__c>();
            for(Master_Object__c rec : allObjectsToDisplayOnTimeline){
                if(dirtyMap.containsKey(rec.Object_Category__c)){
                    sameObjectCategoryRecords.add(rec);
                    List<sObject> getCurrentIndexList = dirtyMap.get(rec.Object_Category__c);
                    getCurrentIndexList.add(rec);
                    dirtyMap.put(rec.Object_Category__c,getCurrentIndexList);
                }
                else {
                    list<Master_Object__c> currentInstanceList = new list<Master_Object__c>();
                    currentInstanceList.add(rec);
                    dirtyMap.put(rec.Object_Category__c,currentInstanceList);
                }
                
            }
            for(String iterationOverKey : dirtyMap.keySet()){
                DisplayGraphdataWrappper dirtyWrapperInstance  = new DisplayGraphdataWrappper();
                dirtyWrapperInstance.objectCategory = iterationOverKey;
                dirtyWrapperInstance.data = dirtyMap.get(iterationOverKey);
                tolist.add(dirtyWrapperInstance);
            }
            for(String dataKeys : allDataOnGraph.keySet()){
                for(DisplayGraphdataWrappper dirtyRecords : tolist){
                    if(dirtyRecords.objectCategory == dataKeys){
                        dirtyRecords.allObjectDataForGraph = (allDataOnGraph.get(dirtyRecords.objectCategory));
                    }
                }
            }
        }
        System.debug('dirty map' +dirtyMap);
        
        
        ParentWrapperForAllAccountInformation toReturnParentWrapper = new ParentWrapperForAllAccountInformation(); 
        toReturnParentWrapper.allObjectsToDisplayOnTimeline=allObjectsToDisplayOnTimeline;
        toReturnParentWrapper.allDataOnGraph = allDataOnGraph;
        toReturnParentWrapper.cleanMapOfGraphObjects = dirtyMap;
        toReturnParentWrapper.rootDataObject = tolist;
        toReturnParentWrapper.objectNameAndDataMap = objectNameAndDataMap;
        toReturnParentWrapper.nameSpace= Elixir_Utility.getNamespace();
        toReturnParentWrapper.baseURL = System.URL.getSalesforceBaseUrl().toExternalForm();
        System.debug('---> '+toReturnParentWrapper);
        return toReturnParentWrapper;
    }
    @AuraEnabled
    public static  List<sObject> fetchObjectdataIfChecked(String lookupField, String objectName,String acctId) {
        String startAppendingQueryItems = String.escapeSingleQuotes(getAllFieldsNameOfObject(objectName));
        startAppendingQueryItems+=' FROM '+ String.escapeSingleQuotes(objectName) + ' WHERE ' + String.escapeSingleQuotes(lookupField) + ' = '+ '\''+
            String.escapeSingleQuotes(acctId)+'\'';
        mDebugUntruncated(startAppendingQueryItems);
        List<sObject> parentData = Database.query(startAppendingQueryItems);
        return parentData;
    }
    public class ParentWrapperForAllAccountInformation {     
        @AuraEnabled public List<DisplayGraphdataWrappper> rootDataObject {get;set;}
        @AuraEnabled public Map<String,List<sObject>> cleanMapOfGraphObjects {get;set;}
        @AuraEnabled public  Map<String,List<sObject>> allDataOnGraph {get;set;}
        @AuraEnabled public List<Master_Object__c> allObjectsToDisplayOnTimeline {get;set;}
        @AuraEnabled public  List<Medical_Examination__c> listOfAllergy{ get; set; }
        @AuraEnabled public  List<Prescription_Order__c> listOfMedication{ get; set; }
        @AuraEnabled public User currentUser { get; set; }
        @AuraEnabled public List<Dataset1__c> parentProblems {get;set;}
        @AuraEnabled public List<Notes__c> listOfrelatedNotes {get;set;}
        @AuraEnabled public Integer dynamicOffset{get;set;}
        @AuraEnabled public List<ICD_Codes__c> listOfRelatedDaignoses {get;set;}
        @AuraEnabled public List<Form__c> formData{ get; set; }
        @AuraEnabled public String VerficationCode{ get; set; }
        @AuraEnabled public String userVerifyCode{ get; set; }
        @AuraEnabled public List<Account> acctDetails{ get; set; }
        @AuraEnabled public List<Medical_Examination__c> vitalData{ get; set; }
        @AuraEnabled public List<Medical_Examination__c> glucoseData{ get; set; }
        @AuraEnabled public Map<String,List<sObject>> objectNameAndDataMap {get;set;}
        @AuraEnabled public String nameSpace;
        @AuraEnabled public String baseURL;
    }
    public class DisplayGraphdataWrappper{
        @AuraEnabled public String objectCategory;
        @AuraEnabled public Boolean isObjectOnGraph;
        @AuraEnabled  public List<Master_Object__c> data;
        @AuraEnabled  public List<sObject> allObjectDataForGraph= new List<sObject>();
    }
    public static String getAllFieldsNameOfObject(String objectName){
        if(objectName.endsWith('__c')){
            objectName = 'ElixirSuite__' + objectName;
        }
        String fieldApiNames = 'SELECT '; 
        Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map <String, Schema.SObjectField> fieldMap = schemaMap.get(objectName).getDescribe().fields.getMap();
        for(Schema.SObjectField sfield : fieldMap.Values())
        {
            schema.describefieldresult dfield = sfield.getDescribe();
            fieldApiNames+=dfield.getname()+',';
        }
        System.debug(fieldApiNames);
        fieldApiNames = fieldApiNames.removeEnd(',');
        return  fieldApiNames;
    }
    public static void mDebugUntruncated(String sMsg) {
        for (Integer i = 0; i < sMsg.length(); i=i+300) {
            Integer iEffectiveEnd = (i+300 > (sMsg.length()-1) ? sMsg.length()-1 : i+300);
            System.debug(sMsg.substring(i,iEffectiveEnd));
        }
    }
    @AuraEnabled
    public static void tryCallback() { 
    }
}
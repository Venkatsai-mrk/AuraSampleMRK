public with sharing class EquipmentMultiCtrl {
   
     @AuraEnabled
    public static List<ElixirSuite__Procedure__c> fetchLookUpValues(){
         List<ElixirSuite__Procedure__c> procedureLst=new List<ElixirSuite__Procedure__c>();
        List<ElixirSuite__Procedure__c>returnlst=new List<ElixirSuite__Procedure__c>();
        procedureLst=[Select Id,Name,ElixirSuite__Item_type__c,ElixirSuite__Sub_type__c from ElixirSuite__Procedure__c
                      where 
                      RecordType.Name='Template Equipment' WITH SECURITY_ENFORCED];
        system.debug('Procedure lst====='+procedureLst);
        for(ElixirSuite__Procedure__c proced:procedureLst){
            returnlst.add(proced);
        }         
        return returnlst;
}
/*@AuraEnabled
    public static List < sObject > fetchLookUpValues(String searchKeyWord, String ObjectName, List<sObject> ExcludeitemsList
                                                    ) {
        String searchKey = '%' + searchKeyWord + '%';
        List < sObject > returnList = new List < sObject > ();
        String typeOfUser= 'Guest';
        List<string> lstExcludeitems = new List<string>();
        for(sObject item : ExcludeitemsList ){
            lstExcludeitems.add(item.id);
        }
        Id devRecordTypeId = Schema.SObjectType.ElixirSuite__Procedure__c.getRecordTypeInfosByDeveloperName().get('Template_Equipment').getRecordTypeId();
        String sQuery =  'select id, Name from ' +ObjectName + ' where Name LIKE: searchKey AND Id NOT IN : lstExcludeitems order by createdDate DESC  limit 5';
         try{
            if(ObjectName =='ElixirSuite__Procedure__c'){
                sQuery =  'select id, Name,ElixirSuite__Item_type__c,ElixirSuite__Sub_type__c from ' +ObjectName + ' where Name LIKE: searchKey AND Id NOT IN : lstExcludeitems AND  RecordTypeId =: devRecordTypeId  order by createdDate DESC limit 5';
                
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
}*/
    
    
     
}
public with sharing class CriteriaPageController {

    private static final String base64Chars = '' +
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
        'abcdefghijklmnopqrstuvwxyz' +
        '0123456789+/';
    
    
   
    @AuraEnabled
    public static List<ElixirSuite__Criteria_Assignment__c> addcriteria(String criteriaRecordId,String groupId,String criteriaType,String operator,String selectedvalue,String fieldApiName){
                                        
        
        integer count =1;
        system.debug('criteriaRecordId' +criteriaRecordId);
         system.debug('groupId' +groupId);
        system.debug('criteriaType' +criteriaType);
        system.debug('operator' +operator);
        system.debug('fieldApiName' +fieldApiName);
        system.debug('selectedvalue' +selectedvalue);
        
        ElixirSuite__Account_Group__c accountGroup = [select id,name,ElixirSuite__Criteria_Filter__c from ElixirSuite__Account_Group__c where Id=:groupId WITH SECURITY_ENFORCED limit 1];
        
        if(String.isNotBlank(criteriaRecordId)){
            ElixirSuite__Criteria_Assignment__c updateRecord = [Select id,ElixirSuite__Criteria_Type__c, ElixirSuite__Operator__c, ElixirSuite__Field_Value__c, ElixirSuite__S_No__c, ElixirSuite__Field_API_Name__c FROM ElixirSuite__Criteria_Assignment__c 
                                                               where id=:criteriaRecordId WITH SECURITY_ENFORCED limit 1 ];
            
            updateRecord.ElixirSuite__Criteria_Type__c = criteriaType;
            updateRecord.ElixirSuite__Operator__c = operator;
           /* if(criteriaType=='LOC' || criteriaType=='Care Team Member' || criteriaType=='Current Patient Name' || criteriaType=='Location'){
                String storedFieldValue = updateRecord.ElixirSuite__Field_Value__c;
                System.debug('storedFieldValue'+storedFieldValue);
                List<FieldJson> rawObj = (List<FieldJson>) JSON.deserializeStrict(selectedvalue,List<FieldJson>.class);
                List<FieldJson> presentObj = (List<FieldJson>) JSON.deserializeStrict(updateRecord.ElixirSuite__Field_Value__c,List<FieldJson>.class);
                integer i=0;
                for(FieldJson obj: rawObj){
                    String idofselectedValue = String.valueOf(obj.Id);
                    if(storedFieldValue.contains(idofselectedValue)){
                        rawObj.remove(i);
                    }
                  i++;  
                }
                System.debug('rawObj'+rawObj); 
                if(rawObj.size() >0){
                    presentObj.addAll(rawObj);
                }
                 System.debug('presentObj'+presentObj);
                 
                  System.debug('presentObj'+String.valueOf(presentObj));    
                 System.debug('presentObj'+ JSON.serialize(presentObj)); 
                updateRecord.ElixirSuite__Field_Value__c = JSON.serialize(presentObj); 
            }
            */
            updateRecord.ElixirSuite__Field_Value__c = selectedvalue;
            updateRecord.ElixirSuite__Field_API_Name__c = fieldApiName;
            if(Schema.sObjectType.ElixirSuite__Criteria_Assignment__c.isUpdateable()){
            update updateRecord;
            }
            
        }else{
            List<ElixirSuite__Criteria_Assignment__c> criteriaRecordsToInsert = new List<ElixirSuite__Criteria_Assignment__c>();
            List<ElixirSuite__Criteria_Assignment__c> criteriaRecords = [SELECT Id, Name, ElixirSuite__Criteria_Type__c, ElixirSuite__Operator__c, ElixirSuite__Field_Value__c, ElixirSuite__Account_Group__c, ElixirSuite__S_No__c FROM ElixirSuite__Criteria_Assignment__c 
                                                                         where ElixirSuite__Account_Group__c=:groupId WITH SECURITY_ENFORCED];
            
            if(criteriaRecords.size() >0){
                integer i = criteriaRecords.size();
                count = i+1;
            }
            
            
            ElixirSuite__Criteria_Assignment__c newRecord = new ElixirSuite__Criteria_Assignment__c();
            newRecord.ElixirSuite__S_No__c = count;
            newRecord.ElixirSuite__Account_Group__c =groupId;
            newRecord.ElixirSuite__Criteria_Type__c = criteriaType;
            newRecord.ElixirSuite__Operator__c = operator;
            newRecord.ElixirSuite__Field_Value__c = selectedvalue; 
            newRecord.ElixirSuite__Field_API_Name__c = fieldApiName;
            
            criteriaRecordsToInsert.add(newRecord);
            
            //insert criteriaRecordsToInsert; 
            if(criteriaRecordsToInsert.size() >0){
                Database.SaveResult[] srList = Database.insert(criteriaRecordsToInsert, false);
                
                // Iterate through each returned result
                for (Database.SaveResult sr : srList) {
                    if (sr.isSuccess()) {
                      system.debug('success');
                        if(count <2){
                            accountGroup.ElixirSuite__Criteria_Filter__c = '1';
                        }
                        else if(count ==2){
                            system.debug('count'+count);
                            accountGroup.ElixirSuite__Criteria_Filter__c = '1 AND 2';
                            
                            
                        }else if(count >2){
                            accountGroup.ElixirSuite__Criteria_Filter__c = accountGroup.ElixirSuite__Criteria_Filter__c + ' AND ' + String.valueOf(count);  
                            
                        }
                    } 
                } 
                if (Schema.sObjectType.ElixirSuite__Account_Group__c.fields.ElixirSuite__Criteria_Filter__c.isUpdateable()) {
                    update accountGroup;
                 }
            }
            
        }
        
        List<ElixirSuite__Criteria_Assignment__c> upsertedRecords = [SELECT Id, Name, ElixirSuite__Criteria_Type__c, ElixirSuite__Operator__c, ElixirSuite__Field_Value__c, ElixirSuite__Account_Group__c,ElixirSuite__Account_Group__r.ElixirSuite__Criteria_Filter__c	, ElixirSuite__S_No__c FROM ElixirSuite__Criteria_Assignment__c 
                                                                         where ElixirSuite__Account_Group__c=:groupId WITH SECURITY_ENFORCED order by ElixirSuite__S_No__c asc];
        
        
        system.debug('upsertedRecords'+upsertedRecords);
        if(upsertedRecords.size() >0){
            for(ElixirSuite__Criteria_Assignment__c record: upsertedRecords){
                if(record.ElixirSuite__Criteria_Type__c=='LOC' || record.ElixirSuite__Criteria_Type__c=='Care Team Member' || record.ElixirSuite__Criteria_Type__c=='Current Patient Name' || record.ElixirSuite__Criteria_Type__c=='Location'){
                  // String json = record.ElixirSuite__Field_Value__c;
                   // json.replace('"":', '"currencyRep":');
                    List<FieldJson> rawObj = (List<FieldJson>) JSON.deserializeStrict(record.ElixirSuite__Field_Value__c,List<FieldJson>.class);
                    String objName ='';
                    integer counter = rawObj.size();
                    integer length=counter -1;
                    if(counter >1){
                        
                        for(integer i=0;i<length;i++){
                            FieldJson obj = rawObj[i];
                            objName += String.valueOf(obj.Name) +',';
                        }
                        
                    }
                    if(length >=0){
                    objName+= rawObj[length].Name;
                    }
                    record.ElixirSuite__Field_Value__c =   objName;  
                    
                    // modifiedlistOfCritera.add(record);
                }
                if(record.ElixirSuite__Criteria_Type__c=='Admit Date'){
                    List<String> listofDateField = (List<String>) JSON.deserializeStrict(record.ElixirSuite__Field_Value__c,List<String>.class);
                    
                    record.ElixirSuite__Field_Value__c= String.valueOf(listofDateField[0]);
                    
                }
        }
       
    }
        return upsertedRecords;
    }
    
    
    @AuraEnabled 
    public static PicklistWrapper getDependentPicklist(String ObjectName, string parentField, string childField) {
        Map<String,List<String>> pickListMap = new Map<String,List<String>>();
        PicklistWrapper pw = new PicklistWrapper();
        pw.pickListMap = pickListMap;
        
        if (Schema.getGlobalDescribe().get(ObjectName) ==null || String.isBlank(parentField) || String.isBlank(ChildField)){
            return pw;
        }
 
        Schema.sObjectType objType = Schema.getGlobalDescribe().get(ObjectName).newSObject().getSObjectType();
        Map<String, Schema.SObjectField> objFieldMap = objType.getDescribe().fields.getMap();
        
        if (!objFieldMap.containsKey(parentField) || !objFieldMap.containsKey(childField)){
            return pw;     
        }
        
        List<PicklistEntryWrapper> depEntries = (List<PicklistEntryWrapper>)JSON.deserialize(JSON.serialize(objFieldMap.get(ChildField).getDescribe().getPicklistValues()), List<PicklistEntryWrapper>.class);
        List<String> controllingValues = new List<String>();
        
        for (Schema.PicklistEntry ple : objFieldMap.get(parentField).getDescribe().getPicklistValues()) {
            pickListMap.put(ple.getLabel(), new List<String>());
            controllingValues.add(ple.getLabel());
        }
        
        for (PicklistEntryWrapper plew : depEntries) {
            String validForBits = base64ToBits(plew.validFor);
            for (Integer i = 0; i < validForBits.length(); i++) {
                String bit = validForBits.mid(i, 1);
                if (bit == '1') {
                    pickListMap.get(controllingValues.get(i)).add(plew.label);
                }
            }
        }
        
        pw.pickListMap = pickListMap;
        pw.parentFieldLabel = objFieldMap.get(parentField).getDescribe().getLabel();
        pw.childFieldLabel = objFieldMap.get(childField).getDescribe().getLabel();
        return pw;
    }
    
  
    public static String decimalToBinary(Integer val) {
        String bits = '';
        while (val > 0) {
            Integer remainder = Math.mod(val, 2);
            val = Integer.valueOf(Math.floor(val / 2));
            bits = String.valueOf(remainder) + bits;
        }
        return bits;
    }
    
    public static String base64ToBits(String validFor) {
        if (String.isEmpty(validFor)) return '';
        
        String validForBits = '';
        
        for (Integer i = 0; i < validFor.length(); i++) {
            String thisChar = validFor.mid(i, 1);
            Integer val = base64Chars.indexOf(thisChar);
            String bits = decimalToBinary(val).leftPad(6, '0');
            validForBits += bits;
        }
        
        return validForBits;
    }
    
    public class MultiselectedOptionClass{
        String Id;
        String Name;
        
    }
    public class PicklistWrapper{
    	@AuraEnabled
        public Map<String, List<String>> pickListMap;
        @AuraEnabled
        public String parentFieldLabel;
        @AuraEnabled
        public String childFieldLabel;      
    }
        
    public class PicklistEntryWrapper{
        public String active;
        public String defaultValue;
        public String label;
        public String value;
        public String validFor;
        
    }
    
    public class FieldJson{
        public String Id;
        public String Name;
        public String RecordTypeId;
    }
}
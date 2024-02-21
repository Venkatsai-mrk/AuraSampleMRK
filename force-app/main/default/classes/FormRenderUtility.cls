/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-17-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class FormRenderUtility {
    static List<String> filteredFields = new List<String>();
    public static Set<String> fetchObjects(String formName){// formName = RecordType name
        Set<String> qualifiedFormObjects = new Set<String>();
        List<Form_Object__mdt> metadata = [SELECT Id, QualifiedApiName, Object_Name__c FROM Form_Object__mdt WHERE Object_Name__c!=NULL AND DeveloperName='Object_Names' WITH SECURITY_ENFORCED LIMIT 1];//Getting metadata
        if(metadata!=null && metadata.size()>0){
            Set<String> metadataObjects = new Set<String>();
            metadataObjects = new Set<String>(metadata[0].Object_Name__c.split(';'));
            List<RecordType> recordTypes = [SELECT Id, Name, DeveloperName, NamespacePrefix, SobjectType, IsActive FROM RecordType
                                            WHERE IsActive = true AND SobjectType IN :metadataObjects AND Name =:formName WITH SECURITY_ENFORCED];
            if(recordTypes!=null && recordTypes.size()>0){
                for(RecordType recordType :recordTypes){
                    qualifiedFormObjects.add(recordType.SobjectType);
                } 
            }
        }
        return qualifiedFormObjects;
    }
    public static Map<Id,sObject> getFxData(String formName, String accountId){
        Map<Id,sObject> formCssToFxValue = new Map<Id,sObject>();
        try {
            List<Object_1_css__c> cssRecords = [SELECT Id, Map_object__c, Map_field__c, Object_Name__c, Field_Name__c, Form__c,
            WHERE_clause_per_field__c,Account_Lookup_API__c
                            FROM Object_1_css__c
                            WHERE Object_1_css__r.Form__c= :formName 
                            AND Formula_Map_Enabled__c=TRUE
                            AND WHERE_clause_per_field__c!=NULL
                            AND Account_Lookup_API__c!=NULL
                            WITH SECURITY_ENFORCED];
            if(cssRecords!=null && cssRecords.size()>0){
                for(Object_1_css__c formCss :cssRecords){
                    String createdQuery = createQuery(formCss, accountId);
                    List<sObject> records = Database.query(createdQuery);
                    if(records!=null && records.size()>0){
                        sObject record = records[0];
                        formCssToFxValue.put(formCss.Id, record);
                    }
                }
            }
            
        } catch (Exception e) {
            ExceptionLog.logError(e);
        }

        return formCssToFxValue;
    }
    public static Set<String> fetchObjectsUpdate(String formName){// formName = RecordType name
        Set<String> qualifiedFormObjects = new Set<String>();
        List<Form_Object__mdt> metadata = [SELECT Id, QualifiedApiName, Object_Name__c FROM Form_Object__mdt WHERE Object_Name__c!=NULL AND DeveloperName='Object_Names' WITH SECURITY_ENFORCED LIMIT 1];//Getting metadata
        if(metadata!=null && metadata.size()>0){
            Set<String> metadataObjects = new Set<String>();
            metadataObjects = new Set<String>(metadata[0].Object_Name__c.split(';'));
            List<RecordType> recordTypes = [SELECT Id, Name, DeveloperName, NamespacePrefix, SobjectType, IsActive FROM RecordType
            WHERE IsActive = true AND SobjectType IN :metadataObjects AND Name =:formName WITH SECURITY_ENFORCED];
            if(recordTypes!=null && recordTypes.size()>0){
                for(RecordType recordType :recordTypes){
                    qualifiedFormObjects.add(recordType.SobjectType);
                } 
            }
        }
        return qualifiedFormObjects;
    }
    @TestVisible
    private static String createQuery(Object_1_css__c formCss, String accountId){
        String fieldName  = formCss.Map_field__c;
        String whereClause  = formCss.WHERE_clause_per_field__c;
        String objName  = formCss.Map_object__c;
        String referAccountField = formCss.Account_Lookup_API__c;
        String createdQuery = 'SELECT Id,'+String.escapeSingleQuotes(fieldName) +' FROM ' + String.escapeSingleQuotes(objName) + 
        ' WHERE ' +String.escapeSingleQuotes(referAccountField)  + '= :accountId';
        if(String.isNotBlank(whereClause)){
            String nestedQuery = ' AND ' + whereClause;
            createdQuery += nestedQuery;
    }
        return createdQuery;
    } 
    public static Map<String, sObject> getObjectFormData(Object_1_css__c cssRecord, String accountId){
        try {
            if(String.isBlank(cssRecord.Parent_query__c)){
                return new Map<String, sObject>();
            }
            Map<String, sObject> objToData = new Map<String, sObject>();
            List<String> splittedQuery = cssRecord.Parent_query__c.split(';');
            if(splittedQuery != null && splittedQuery.size()>0){
                for(String mainQuery :splittedQuery){
                    List<String> splitQuery = mainQuery.split('&');
                    if(splitQuery[0].endsWith('USER') || splitQuery[0].endsWith('User')){
                        Id currentUserId = UserInfo.getUserId();
                       String createQuery =String.escapeSingleQuotes(splitQuery[0]) + ' WHERE Id = :currentUserId ' +'ORDER BY CreatedDate DESC LIMIT 1';
                       
                        List<sObject> data = Database.query(createQuery);
                        if(data!=null && data.size()>0){
                            String sObjName = data[0].Id.getSObjectType().getDescribe().getName();
                            objToData.put(sObjName, data[0]);  
                        } 
                    }else{
                       String createQuery =String.escapeSingleQuotes(splitQuery[0])  + ' WHERE ' +string.escapeSingleQuotes(splitQuery[1])  + '=:accountId ORDER BY CreatedDate DESC LIMIT 1';
                        
                        system.debug(createQuery);
                        List<sObject> data = Database.query(createQuery);
                        if(data!=null && data.size()>0){
                            String sObjName = data[0].Id.getSObjectType().getDescribe().getName();
                            objToData.put(sObjName, data[0]);  
                        }   
                    }
                }
            }
            return objToData;            
        } catch (Exception e) {
            ExceptionLog.logError(e);
        }

        return new Map<String, sObject>();
    }
    public static Map<String, sObject> getQueryDataConsent(Object_1_css__c cssRecord, String accountId, String userId){
        Map<String, sObject> objToData = new Map<String, sObject>();
        Map<String,String> objs = new Map<String,String>{'Account'=>accountId,
        'User'=>UserInfo.getUserId()};
        String accQuery;
    try{
        Map <String,Schema.SObjectType> gd = Schema.getGlobalDescribe();
        for(String objName :objs.keySet()){
            String recId = objs.get(objName);
            List<String> objFields = new List<String>();
            Schema.SObjectType sobjType = gd.get(objName);
            Schema.DescribeSObjectResult r = sobjType.getDescribe();
            Map<String, Schema.SObjectField> mapofField = r.fields.getMap();
            objFields = new List<String>(mapofField.keySet());
            accQuery = 'SELECT ' +String.escapeSingleQuotes(String.join(objFields,','))  + ' FROM ' + String.escapeSingleQuotes(objName) + ' WHERE Id= :recId';
            List<sObject> records = Database.query(accQuery);
            if(records!=null && records.size()>0){
                objToData.put(objName,records[0]);             
                    }
                }
            }
    catch(Exception e){
        String manualStackTrace = 'className: FormRenderUtility, function: getQueryDataConsent, query: ' + accQuery + 'line number: ' + e.getLineNumber() + 'exceptionMessage: '+ e.getMessage();
        ExceptionLog.logDebugString(manualStackTrace);
        ExceptionLog.logError(e);
        String consentQuery = cssRecord.Consent_Query__c;
        if(String.isNotBlank(consentQuery)){
            List<String> formCssQueryMain = consentQuery.split(';');//query is in loop but it can have at max
            if(formCssQueryMain!=null){                             //Account AND User value
                for(String perQuery :formCssQueryMain){
                    List<String> formCssQuery = perQuery.split(':');
                    if(formCssQuery!=null){
                        String objName = formCssQuery[0];
                        String objQuery = formCssQuery[1];
                        if(objName.equalsIgnoreCase('ACCOUNT')){
                            try{
                                List<sObject> records = Database.query(String.escapeSingleQuotes(objQuery)  + ' WHERE Id= :accountId');
                                if(records!=null){
                                    objToData.put(objName,records[0]);     
                                }
                            }
                            catch(Exception ex){
                                String manualStackTraceLocal = 'className: FormRenderUtility, function: getQueryDataConsent, query: ' +string.escapeSingleQuotes(objQuery)  + 'line number: ' +ex.getLineNumber() + 'exceptionMessage: '+String.escapeSingleQuotes(ex.getMessage()) ;
                                ExceptionLog.logDebugString(manualStackTraceLocal);
                                ExceptionLog.logError(ex);
                            }        
                        }else if(objName.equalsIgnoreCase('USER')){
                            try{
                                List<sObject> records = Database.query(string.escapeSingleQuotes(objQuery) + ' WHERE Id= :userId');
                                if(records!=null){
                                    objToData.put(objName,records[0]);             
                                }
                            }
                            catch(Exception ex){
                                String manualStackTraceLocal = 'className: FormRenderUtility, function: getQueryDataConsent, query: ' + objQuery + 'line number: ' + ex.getLineNumber() + 'exceptionMessage: '+ ex.getMessage();
                                ExceptionLog.logDebugString(manualStackTraceLocal);
                                ExceptionLog.logError(ex);
                            }
                        }
                    }
                }
            }
        }
    }
        return objToData;
    }
    public static void populateValue(sObject sObj, List<Form_Value__c> defaultValuesSaveObject, String accountId,
                                     List<String> commonFields, String fieldName, Map<String, Object> columnMap,
                                     Account changeAccount){
                                         //Handling Datatypes
                                         String multiValue;
                                         system.debug(columnMap.get('value'));
                                         String dataType = String.valueOf(columnMap.get('ElixirSuite__Data_Type__c'));
                                         if(!Boolean.valueOf(columnMap.get('ElixirSuite__Is_formula_Field__c'))){
                                         try{
                                         switch on dataType{
                                            when  'TIME', 'time' {
                                                if(columnMap.get('value') == null){
                                                    sObj.put(fieldName ,null); 
                                                }else {
                                                    // Time value comes as string like this- '18:30:00.000z'
                                                    List<String> timeSplit = String.valueOf(columnMap.get('value')).split(':');
                                                    sObj.put(fieldName , Time.newInstance(Integer.valueOf(timeSplit[0]), Integer.valueOf(timeSplit[1]), 0, 0));
                                                }
                                             }
                                             
                                             when 'DATE','date'{
                                                 if(columnMap.get('value') == null){
                                                     sObj.put(fieldName ,null); 
                                                 }else
                                                     sObj.put(fieldName , Date.valueOf(String.valueOf(columnMap.get('value'))));
                                             }
                                             when 'DATETIME','datetime'{
                                                 if(columnMap.get('value') == null){
                                                     sObj.put(fieldName ,null); 
                                                 }else
                                                     sObj.put(fieldName , (DateTime)JSON.deserialize('"' + columnMap.get('value') + '"', DateTime.class));
                                                 //sObj.put(fieldName , Datetime.valueOf(columnMap.get('value')));  
                                             }
                                             when 'BOOLEAN','boolean'{
                                                 if(columnMap.get('value') == null){
                                                     sObj.put(fieldName ,false); 
                                                 }else
                                                     sObj.put(fieldName , Boolean.valueof(columnMap.get('value')));  
                                             }
                                             when 'DOUBLE','double'{
                                                 if(columnMap.get('value') == null){
                                                     sObj.put(fieldName ,null); 
                                                 }else
                                                     sObj.put(fieldName , Double.valueOf(String.valueOf(columnMap.get('value'))));   
                                             }when 'PHONE','phone'{
                                                 if(columnMap.get('value') == null){
                                                     sObj.put(fieldName ,null); 
                                                 }else
                                                     sObj.put(fieldName , columnMap.get('value'));   
                                             }
                                             when 'TEXTAREA','textarea','STRING','string'{
                                                 if(columnMap.get('value') == null){
                                                     sObj.put(fieldName ,''); 
                                                 }else
                                                     sObj.put(fieldName , columnMap.get('value'));  
                                             }
                                             when 'PICKLIST','picklist'{
                                                 if(columnMap.get('value') == null){
                                                     sObj.put(fieldName ,null); 
                                                 }else
                                                     sObj.put(fieldName , columnMap.get('value'));  
                                             }
                                             when 'MULTIPICKLIST','multipicklist'{
                                                 if(columnMap.get('value') == null){
                                                     sObj.put(fieldName ,null); 
                                                 }else{
                                                     List<Object> values = (List<Object>) columnMap.get('value');
                                                      system.debug(values);
                                                       if(values!=null && values.size()>0){
                                                           multiValue = String.join(values, ';');
                                                           sObj.put(fieldName , String.join(values, ';'));  
                                                        }else{
                                                            sObj.put(fieldName ,null); 
                                                        }  
                                                                                                              
                                                 }
                                             }
                                             when 'REFERENCE','reference'{ //Added by Vidish
                                                 if(columnMap.get('value') == null){
                                                     sObj.put(fieldName ,null); 
                                                 }else
                                                     sObj.put(fieldName , columnMap.get('value'));  
                                             }
                                             when 'EMAIL','email'{ //Added by Ajit
                                                if(columnMap.get('value') == null){
                                                    sObj.put(fieldName ,null); 
                                                }else
                                                    sObj.put(fieldName , columnMap.get('value'));  
                                            }
                                         }
                                             /*String strErrorMessage = 'FieldName ='+ fieldName +', dataType = '+dataType+', value = '+String.valueOf(columnMap.get('value'));
                                            ExceptionLog.logDebugString(strErrorMessage);*/
                                         }catch(Exception e){
                                            String strErrorMessage = 'FieldName ='+ fieldName +', dataType = '+dataType+', value = '+String.valueOf(columnMap.get('value'));
                                            ExceptionLog.logDebugString(strErrorMessage);
                                         }
                                            
                                         }
                                         //FORM-FORM data passing - START
                                         if(((columnMap.get('ElixirSuite__IsCommon__c')!=null && Boolean.valueOf(columnMap.get('ElixirSuite__IsCommon__c'))) || 
                                           (columnMap.get('ElixirSuite__Is_Common_Parent__c')!=null && Boolean.valueOf(columnMap.get('ElixirSuite__Is_Common_Parent__c')))) && columnMap.get('value') != null){
                                             Form_Value__c dataValue = new Form_Value__c();
                                             dataValue.Account__c = accountId;
                                             dataValue.Field_Api_Name__c = fieldName;
                                             if(dataType.equalsIgnoreCase('MULTIPICKLIST')){
                                                 if(String.isNotBlank(multiValue)){
                                                     dataValue.Default1__c = multiValue;
                                                 }
                                             }else{
                                                 if(String.isNotBlank(String.valueOf(columnMap.get('value')))){
                                                     dataValue.Default1__c = String.valueOf(columnMap.get('value'));
                                                 }
                                             }
                                             commonFields.add(fieldName);
                                             defaultValuesSaveObject.add(dataValue);
                                         }
                                         
                                         //FORM-OBJECT data passing - START
                                         String mapObj = String.valueOf(columnMap.get('ElixirSuite__Map_object__c'));
                                         String mapField = String.valueOf(columnMap.get('ElixirSuite__Map_field__c'));
                                         if(String.isNotBlank(mapObj) && String.isNotBlank(mapField) && mapObj.equalsIgnoreCase('ACCOUNT')){ 
                                             if(dataType.equalsIgnoreCase('MULTIPICKLIST')){
                                                 if(String.isNotBlank(multiValue)){
                                                     changeAccount.put(mapField, multiValue);
                                                 }
                                             }else{
                                                 try{
                                                     if(String.isNotBlank(String.valueOf(columnMap.get('value')))){
                                                         changeAccount.put(mapField, String.valueOf(columnMap.get('value')));
                                                     }
                                                 }catch(Exception e){
                                                     ExceptionLog.logError(e);
                                                 }
                                             }
                                         }
                                     }
    
    public static void populateConsentValue(String fieldName, Map<String, Object> columnMap, List<Form_Value__c> consentValues,
                                            Integer secNo, Integer rowno, Integer columnNo, String accountId,Boolean isClone){
                                                String defaultText = (String) columnMap.get('defaultText');
                                                Id savedId = (String) columnMap.get('savedId');
                                                String inputJSON = (String) columnMap.get('inputJSON');
                                                String consentPdf = (String) columnMap.get('consentPdf');
                                                system.debug(defaultText);
                                                    Form_Value__c consentRec = new Form_Value__c();
                                                    if(String.isNotBlank(savedId) && !isClone){
                                                       consentRec.Id = savedId;
                                                    }
                                                    consentRec.Account__c = accountId;
                                                    consentRec.Section_Number__c = secNo;
                                                    consentRec.Row_Number__c = rowNo;
                                                    consentRec.Column_Number__c = columnNo;
                                                    consentRec.Is_Consent__c= true;
                                                    if(String.isNotBlank(defaultText)){
                                                        consentRec.Consent_Default_Text__c = defaultText;
                                                    }
                                                    consentRec.Consent_Pdf__c = consentPdf;
                                                    consentRec.Consent_Input_JSON__c = inputJSON;
                                                    consentValues.add(consentRec);
                                            }
    public static objFieldSchema fetchFields(Set<String> qualifiedFormObjects, Map<String,List<String>> objectToFieldsMap , String formName){
        List<Object_1_css__c> cssPicklistFields = [SELECT Field_Name__c FROM Object_1_css__c
        WHERE Object_1_css__r.Form__c= :formName 
        AND Field_Name__c!=NULL
        AND Data_Type__c!= NULL
        AND Data_Type__c!='undefined' WITH SECURITY_ENFORCED];
        for(Object_1_css__c field :cssPicklistFields){
            filteredFields.add(field.Field_Name__c);
        }
        objFieldSchema objSchema ;
        List<FieldSchema> fieldSchemas = new List<FieldSchema>();
        List<FieldSchema> dependentPicklistSchemas = new List<FieldSchema>();
        List<FieldSchema> onlyPicklistPicklistSchemas = new List<FieldSchema>();
        Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        try{
        List<FieldSchema> schemasToUpdate = new List<FieldSchema>();
        for(String selectedObject :qualifiedFormObjects){
            Map <String, Schema.SObjectField> fieldMap = schemaMap.get(selectedObject).getDescribe().fields.getMap();
            for(Schema.SObjectField sfield : fieldMap.Values()){
                List<String> pickListValuesList = new List<String>();
                schema.describefieldresult dfield = sfield.getDescribe();
                FieldSchema sch = new FieldSchema();
                sch.apiName = dfield.getname();
                sch.dataType = String.valueOf(dfield.getType());
                Schema.sObjectField dependedentField = dfield.getSObjectField();   // Added by Vidish     
                if(!filteredFields.contains((String) dfield.getName())){
                    continue;
                }  
                if(sch.dataType.equalsIgnoreCase('PICKLIST') || sch.dataType.equalsIgnoreCase('MULTIPICKLIST')){
                    sch.controllingValueToDependentValues = getDependentPicklistValues(dependedentField); //Added by Vidish   
                    if(sch.controllingValueToDependentValues.size()>0){
                        sch.isDependent = true;
                        sch.controllingField = String.valueOf(dfield.getController());
                        sch.dependentField = String.valueOf(dependedentField);
                        dependentPicklistSchemas.add(sch);
                    }
                }
                if(!objectToFieldsMap.containsKey(selectedObject)){
                    objectToFieldsMap.put(selectedObject, new List<String>{dfield.getname()});
                }else{
                    objectToFieldsMap.get(selectedObject).add(dfield.getname());
                }
                if(sch.dataType.equalsIgnoreCase('PICKLIST') || sch.dataType.equalsIgnoreCase('MULTIPICKLIST')){
                    List<Schema.PicklistEntry> ple = dfield.getPicklistValues();
                    for( Schema.PicklistEntry pickListVal : ple){
                        pickListValuesList.add(pickListVal.getLabel());
                    }   
                    onlyPicklistPicklistSchemas.add(sch);
                }
                sch.picklistValues = pickListValuesList;
                sch.lengthOfField = dfield.getLength();//added by Mahendra
                fieldSchemas.add(sch); 
            }
            objSchema = new objFieldSchema(objectToFieldsMap, fieldSchemas);
            for( fieldSchema fsDependent : dependentPicklistSchemas ){//Can be reduced
                    for( fieldSchema fsControlling : onlyPicklistPicklistSchemas ){
                        if(fsDependent.controllingField == fsControlling.apiName){
                            fsControlling.isControlling = true;                       
                            fsControlling.dependentField = String.valueOf(fsDependent.apiName);
                            fsControlling.controllingValueToDependentValuesCopy = fsDependent.controllingValueToDependentValues;
                            schemasToUpdate.add(fsControlling);
                            break;
                        }
                }
            }
            for( fieldSchema fsControlling : schemasToUpdate){
                fsControlling.controllingValueToDependentValues = fsControlling.controllingValueToDependentValuesCopy;
            }
        }
    }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
                  
        return objSchema;
    } 
    public class objFieldSchema{
        @AuraEnabled public Map<String,List<String>> objectToFieldsMap = new Map<String,List<String>>();
        @AuraEnabled public List<FieldSchema> fieldSchemas = new List<FieldSchema>();
        public objFieldSchema(Map<String,List<String>> objectToFieldsMap, List<FieldSchema> fieldSchemas){
            this.objectToFieldsMap =objectToFieldsMap;
            this.fieldSchemas = fieldSchemas;
        }
    }
    public class FieldSchema{
        @AuraEnabled public String apiName;
        @AuraEnabled public String dataType;
        @AuraEnabled public List<String> picklistValues;
        @AuraEnabled public Boolean isDependent; //Added by Vidish
        @AuraEnabled public Boolean isControlling;  //Added by Vidish
        @AuraEnabled public Map<String,List<String>> controllingValueToDependentValues;  //Added by Vidish
        @AuraEnabled public Map<String,List<String>> controllingValueToDependentValuesCopy;  //Added by Vidish
        @AuraEnabled public String dependentField ;  //Added by Vidish
        @AuraEnabled public String controllingField ;  //Added by Vidish    
        @AuraEnabled public integer lengthOfField ;  //Added by Mahendra 


    }
    public static Map<String, List<String>> getDependentPicklistValues(Schema.sObjectField dependToken) {
    Schema.DescribeFieldResult depend = dependToken.getDescribe();
    Schema.sObjectField controlToken = depend.getController();
    if (controlToken == null) {
        return new Map<String, List<String>>();
    }

    Schema.DescribeFieldResult control = controlToken.getDescribe();
    List<Schema.PicklistEntry> controlEntries;
    if(control.getType() != Schema.DisplayType.Boolean) {
        controlEntries = control.getPicklistValues();
    }

    String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
    Map<String,List<String>> dependentPicklistValues = new Map<String,List<String>>();
    try{
    for (Schema.PicklistEntry entry : depend.getPicklistValues()) {
        if (entry.isActive() && String.isNotEmpty(String.valueOf(((Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')))) {
            List<String> base64chars =
                    String.valueOf(((Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')).split('');
            for (Integer index = 0; index < (controlEntries != null ? controlEntries.size() : 2); index++) {
                Object controlValue =
                        (controlEntries == null
                                ?   (Object) (index == 1)
                                :   (Object) (controlEntries[index].isActive() ? controlEntries[index].getLabel() : null)
                        );
                Integer bitIndex = index / 6;
                if (bitIndex > base64chars.size() - 1) {
                    break;
                }
                Integer bitShift = 5 - Math.mod(index, 6);
                if  (controlValue == null || (base64map.indexOf( base64chars[ bitIndex ] ) & (1 << bitShift)) == 0)
                    continue;
                if (!dependentPicklistValues.containsKey((String) controlValue)) {
                    dependentPicklistValues.put((String) controlValue, new List<String>());
                }
                dependentPicklistValues.get((String) controlValue).add(entry.getLabel());
            }
        }
    }
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
    return dependentPicklistValues;
    }
    
}
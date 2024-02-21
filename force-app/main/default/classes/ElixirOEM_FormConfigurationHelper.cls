/*
Developer Name : Tanveer Ahmed
DOC : 02/03/2021
Purpose : To handle form config screen flow.
*/
public with sharing class ElixirOEM_FormConfigurationHelper {
    @AuraEnabled
    public static FormsConfigurationWrapper fetchAllRecordTypesOnMDTObject() {
        
        FormsConfigurationWrapper toReturn = new FormsConfigurationWrapper();
        List<Form_Object__mdt> allObjectNames = [select Object_Name__c from Form_Object__mdt 
                                                    WHERE Object_Name__c!=NULL WITH SECURITY_ENFORCED];
        
        List<Essential_Lookup_Fields__mdt> allEssentialLookupFields = [SELECT ID,Lookup_Api__c from Essential_Lookup_Fields__mdt WHERE Lookup_Api__c!=''
                                                                        WITH SECURITY_ENFORCED];
        
        List<String> objectNamesByApi = new List<String>();
        Map<String,String> conversionMap = new Map<String,String>();
        List<String> allObjectRecordtypelabels = new List<String>();
        
        List<String> alreadyExistingForms = new List<String>();
        for(Object_1_css__c obj : [SELECT ID,Form__c from Object_1_css__c WHERE Form__c!=NULL
                                    WITH SECURITY_ENFORCED]){
                                        alreadyExistingForms.add(obj.Form__c);
                                    } 
        
        
        for(Form_Object__mdt recordInstance : allObjectNames){
            if(String.isNotBlank(recordInstance.Object_Name__c)){
                objectNamesByApi.addAll(recordInstance.Object_Name__c.split(';'));
            }
            else {
                toReturn.noObjectAvailable = true;
            }
        }
        
        for(String objectNames : objectNamesByApi){  
            if(isObjectExist(objectNames)){
                Map<String, Schema.SObjectType> m = Schema.getGlobalDescribe() ;
                Schema.SObjectType s = m.get(objectNames) ;
                Schema.DescribeSObjectResult cfrSchema = s.getDescribe() ;
                Map<ID,Schema.RecordTypeInfo> recordTypeInfo = cfrSchema.getRecordTypeInfosByID();
                Map<id, Schema.RecordTypeInfo> recordTypeByIdMap = recordTypeInfo;
                for(String r:recordTypeByIdMap.keySet())
                {    
                    
                    if(recordTypeByIdMap.get(r).getDeveloperName().startsWithIgnoreCase('EHR_Form_'))
                    {
                        if(!alreadyExistingForms.contains(recordTypeByIdMap.get(r).getName())){
                            conversionMap.put(recordTypeByIdMap.get(r).getName(),recordTypeByIdMap.get(r).getDeveloperName());
                            allObjectRecordtypelabels.add(recordTypeByIdMap.get(r).getName());  
                        }
                    }
                }
            }
        }
        
        
        
        toReturn.mapByRecordTypeLabelAndDeveloperName = conversionMap;
        toReturn.allObjectRecordtypelabels = allObjectRecordtypelabels;
        toReturn.lookupApiToInclude = allEssentialLookupFields;   
        toReturn.mapOfContainer = fetchPickListValue('ElixirSuite__Object_1_css__c','ElixirSuite__Select_Form_Component__c');  
     
        // toReturn.mapOfInventory =  fetchPickListValue('ElixirSuite__Object_1_css__c','ElixirSuite__Default_Inventory_Type__c');
        return toReturn;
        
        
    }
    public static  Map<String, String> fetchPickListValue(String strObjectName,String strPicklistField ){
        
        Map<String, String> mapPickListValues = new Map<String, String>();
        Schema.SObjectType objSobjectType = Schema.getGlobalDescribe().get(strObjectName);
        Schema.DescribeSObjectResult objDescribeSobject = objSobjectType.getDescribe();
        Map<String, Schema.SObjectField> mapFields = objDescribeSobject.fields.getMap();
        List<Schema.PicklistEntry> lstPickListValues = mapFields.get(strPicklistField).getDescribe().getPickListValues();
        for (Schema.PicklistEntry objPickList : lstPickListValues) {
            mapPickListValues.put(objPickList.getLabel(),objPickList.getValue());
        }
        return mapPickListValues;
    }
    public static boolean isObjectExist(String ObjectNameParam){
        for (Schema.SObjectType sObjectType : Schema.getGlobalDescribe().values() ) {
            String sobjName = String.valueOf(sObjectType);
            if (sobjName.contains(ObjectNameParam) ) {
                return true;
            }
        }
        return false;
    }
        //Added by Vidish
    @AuraEnabled 
    public static boolean checkReferenceForAutoPopulation(String objectName,String fieldName){
        Boolean showAutoPopulation = false;
    Schema.DescribeFieldResult f = Schema.getGlobalDescribe()
    .get(objectName)
    .getDescribe()
    .fields
    .getMap()
    .get(fieldName)
    .getDescribe();
    
        
    for(Schema.SObjectType reference : f.getReferenceTo()) {
    if(String.valueOf(reference.getDescribe().getName()).equalsIgnoreCase('Account') || String.valueOf(reference.getDescribe().getName()).equalsIgnoreCase('User')){
        showAutoPopulation = true;
    }
    }
        return showAutoPopulation;
    }
    //Vidish code End
    
    
    // Get all the metadata for selected record type || Exact match for the label selected
    @AuraEnabled
    public static  FormsConfigurationWrapper fetchAllFieldsForSelectedRecordType(String selectedRecordTypeFuzzy) {
        
        list<String> allFieldApiToExculude = new list<String>{'ElixirSuite__Form_unique_id__c','ElixirSuite__AccountId__c',
            'ElixirSuite__Form_Name__c','ElixirSuite__Form_Category__c'};
                //Removing ElixirSuite__AccountId__c from the list
                Map<String,String> allRecordTypeToObjectApiMap = recordTypeByobjectNameMap(selectedRecordTypeFuzzy);
        List<String> duplicateObjects = new List<String>();
        Map<String,String> fieldsApiAndLabelMap = new Map<String,String>();
        Map<String,String> fieldsApiAndObjectLabelMap = new Map<String,String>();
        Map<String,String> dataTypeMap  = new Map<String,String>();
        List<String> allObjectApiNamesForFiledToQuery = new List<String>();
        Integer countForObjectForWhichRecordTypeMatch = 0; // object matching count
        FormsConfigurationWrapper toReturnData = new FormsConfigurationWrapper();
        
        
        for(String recrdEntity : allRecordTypeToObjectApiMap.keyset()){
            
            countForObjectForWhichRecordTypeMatch++;
            allObjectApiNamesForFiledToQuery.add(recrdEntity); 
            duplicateObjects.add(recrdEntity);
            
        }
        for(String filedInstance : allObjectApiNamesForFiledToQuery){
            Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Map <String, Schema.SObjectField> fieldMap = schemaMap.get(filedInstance).getDescribe().fields.getMap();
            dataTypeMap.putAll(cleanMapForFieldApiAndDataType(filedInstance));
            fieldsApiAndObjectLabelMap.putAll(cleanMapForFieldApiAndObjectName(filedInstance));
            for(Schema.SObjectField sfield : fieldMap.Values())
            {
                if (sfield.getDescribe().isCustom()) {
                    schema.describefieldresult dfield = sfield.getDescribe();
                    
                    if(!allFieldApiToExculude.contains(dfield.getname())){ // Exclude all pre-hard coded fields  
                        fieldsApiAndLabelMap.put(dfield.getname(),dfield.getLabel());
                    }
                }
            }
        }
        toReturnData.fieldApiNameAndLabel = fieldsApiAndLabelMap;
        toReturnData.objectMatchCount = countForObjectForWhichRecordTypeMatch;
        toReturnData.dataTypeMap = dataTypeMap;
        toReturnData.fieldsApiAndObjectLabelMap = fieldsApiAndObjectLabelMap;
        toReturnData.schemaObjectApiAndLabelMap = objectLabelAndApiNames();
        toReturnData.duplicateObjects = duplicateObjects;
        toReturnData.accountFieldApiMap = fetchFieldsForSelectedObject('Account');
        return toReturnData;
    }
    public static  Map<String,String> objectLabelAndApiNames(){
        List<Schema.SObjectType> gd = Schema.getGlobalDescribe().Values();    
        Map<String,String> objName = new Map<String,String>();
        for(Schema.SObjectType f : gd)
        {
            
            objName.put(f.getDescribe().getName(),f.getDescribe().getLabel());
            
        }
        
        return objName;
    }
    public static  Map<String,String> recordTypeByobjectNameMap(String recTypeToMatch) {
        List<Form_Object__mdt> allObjectNames = [select Object_Name__c from Form_Object__mdt 
                                                    where Object_Name__c!=null WITH SECURITY_ENFORCED];
        List<String> objectNamesByApi = new List<String>();
        List<String> duplicateRecordTypesOnDifferentObject = new List<String>();
        Map<String,String> conversionMap = new Map<String,String>();
        for(Form_Object__mdt recordInstance : allObjectNames){
            objectNamesByApi.addAll(recordInstance.Object_Name__c.split(';'));
        }
        
        for(String objectNames : objectNamesByApi){  
            if(isObjectExist(objectNames)){
                Map<String, Schema.SObjectType> m = Schema.getGlobalDescribe() ;
                Schema.SObjectType s = m.get(objectNames) ;
                Schema.DescribeSObjectResult cfrSchema = s.getDescribe();
                Map<ID,Schema.RecordTypeInfo> recordTypeInfo = cfrSchema.getRecordTypeInfosByID();
                Map<id, Schema.RecordTypeInfo> recordTypeByIdMap = recordTypeInfo;
                for(String r:recordTypeByIdMap.keySet())
                {    
                    if(recordTypeByIdMap.get(r).getName() == recTypeToMatch)
                    {
                        duplicateRecordTypesOnDifferentObject.add(recordTypeByIdMap.get(r).getName());
                        conversionMap.put(objectNames,recordTypeByIdMap.get(r).getName());
                    }
                }
            }
        }
        return conversionMap;
    }
    // Method to fetch all Account child objects
    @AuraEnabled
    public static  Map<String,String> fetchAccountAndRelatedChildObject() {
        Schema.DescribeSObjectResult r = Account.SObjectType.getDescribe();
        Map<String,String> allChildObjectNames = new Map<String,String>();
        for (Schema.ChildRelationship cr: r.getChildRelationships()) {
            allChildObjectNames.put(String.valueOf(cr.getChildSObject()),String.valueOf(cr.getField()));
        }
        return allChildObjectNames;
    }
    @AuraEnabled
    public static List<String> getFields(List<String> allIncomingAPis) {
        try{
            return ElixirOEM_DependentPicklist.getFields(allIncomingAPis);
        }
        catch(Exception e){
            ExceptionLog.logError(e);
            return null;
        }
        
    }
    @AuraEnabled
    public static String fetchLookupFieldApi(String objectName) {
        String lookupFieldApi = '';
        Boolean isFieldRefrence = false; 
        List<String> refrenceFields = fetchRefrenceFields(objectName);
        for(String fieldInstance : refrenceFields){
            isFieldRefrence =  filterField(fieldInstance);
            if(isFieldRefrence){
                lookupFieldApi = fieldInstance;
                break;
            }
        }
        
        
        
        return lookupFieldApi;
    }
    public static Boolean filterField(String fieldName){
        Boolean isMatch = false;
        String objectName = 'ElixirSuite__VOB__c';
        
        Schema.DescribeFieldResult f = Schema.getGlobalDescribe()
            .get(objectName)
            .getDescribe()
            .fields
            .getMap()
            .get(fieldName)
            .getDescribe();
        
        for(Schema.SObjectType reference : f.getReferenceTo()) {
            if(reference.getDescribe().getName()=='Account'){
                isMatch = true;
                break;
            }
            
        }
        return isMatch;
    }
    public static  List<String> fetchRefrenceFields(String objectName) {      
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();       
        Schema.SObjectType leadSchema = schemaMap.get(objectName);        
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
        List<String> fieldApiAndFieldTypeMap = new  List<String>();
        for (String fieldName: fieldMap.keySet()) {
            String fieldApi = fieldMap.get(fieldName).getDescribe().getname();
            Schema.DisplayType fielddataType = fieldMap.get(fieldName).getDescribe().getType();
            if(String.valueOf(fielddataType) == 'REFERENCE'){
                fieldApiAndFieldTypeMap.add(fieldApi);
            }
            
        }
        return fieldApiAndFieldTypeMap;
    }
    @Auraenabled
    public static formulaWrapper fetchFormulaRelatedInfo(String objectName){
        formulaWrapper fw = new formulaWrapper();
        fw.labelApicombo = fetchFieldsForSelectedObject(objectName);
        fw.accountRelatedLookupAPIs =  fetchAllAccountRelatedLookup(objectName);
        return fw;
    }
    public class formulaWrapper {
       @Auraenabled public  Map<String,String> labelApicombo = new Map<String,String>(); 
       @Auraenabled public List<String> accountRelatedLookupAPIs;
    }
    @AuraEnabled
    public static  Map<String,String> fetchFieldsForSelectedObject(String objectName) {
        Map<String,String> labelApicombo = new Map<String,String>();
        if(String.isNotBlank(objectName)){ 
            Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Map <String, Schema.SObjectField> fieldMap = schemaMap.get(objectName).getDescribe().fields.getMap();
            for(Schema.SObjectField sfield : fieldMap.Values())
            {
                
                schema.describefieldresult dfield = sfield.getDescribe();
                labelApicombo.put(String.valueOf(dfield.getname()),String.valueOf(dfield.getLabel()));
                
            }
        }
        return labelApicombo;
    }
    
    public static  List<String>  fetchAllAccountRelatedLookup(String refObjectName){
        List<String> lookupApis = new List<String>();
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();       
        Schema.SObjectType leadSchema = schemaMap.get(refObjectName);        
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
        for (String fieldName: fieldMap.keySet()) {   
            Schema.DescribeFieldResult f = fieldMap.get(fieldName).getDescribe();
            for(Schema.SObjectType reference : f.getReferenceTo()) {
                if(reference.getDescribe().getName().toLowerCase() == 'account'){
                    lookupApis.add(fieldName);
                    refObjectName = reference.getDescribe().getName(); 
                }   
            }
            
        }
        return lookupApis;
    }
    
    
    public static Map<String,String> cleanMapForFieldApiAndDataType(String objectName) {      
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();       
        Schema.SObjectType leadSchema = schemaMap.get(objectName);        
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
        Map<String,String> fieldApiAndFieldTypeMap = new Map<String,string>();
        for (String fieldName: fieldMap.keySet()) {
            String fieldApi = fieldMap.get(fieldName).getDescribe().getname();
            Schema.DisplayType fielddataType = fieldMap.get(fieldName).getDescribe().getType();
            fieldApiAndFieldTypeMap.put(fieldApi,String.valueOf(fielddataType));
            
        }
        return fieldApiAndFieldTypeMap;
    }
    public static Map<String,String> cleanMapForFieldApiAndObjectName(String objectName) {      
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();       
        Schema.SObjectType leadSchema = schemaMap.get(objectName);        
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
        Map<String,String> fieldApiAndObjectNameMap = new Map<String,string>();
        for (String fieldName: fieldMap.keySet()) {
            String fieldApi = fieldMap.get(fieldName).getDescribe().getname();
            fieldApiAndObjectNameMap.put(fieldApi,objectName);
            
        }
        return fieldApiAndObjectNameMap;
    }
    
    @AuraEnabled
    public static void saveFormconfigData(String formConfigurationDataToSave,String recordTypeName,String formCategoryFromJS,
                                            Boolean IstimeEnabled)
    {
        
            // Get all records to check for common records
            List<String> allRecordsForMatch = new  List<String>();
            List<String> allFieldNameRecordsToUpdate = new List<String>();
            for(Object_1_css__c obj : [SELECT ID,Field_Name__c from Object_1_css__c WHERE Field_Name__c!=NULL
                                        WITH SECURITY_ENFORCED]){
                                            allRecordsForMatch.add(obj.Field_Name__c);                                       
                                        } 
            // Saving logic starts
            Map<String, Object> mainJson =(Map<String, Object>) JSON.deserializeUntyped(formConfigurationDataToSave);
            List<Object> listOfProblems = (List<Object>) mainJson.get('keysToSave');
            List<Object_1_css__c> toInsertParentrecords = new List<Object_1_css__c>();
            Map<Integer,List<Object_1_css__c>> mapOfParentChildRecords = new Map<Integer,List<Object_1_css__c>>();
            for(Object configRecord : listOfProblems){
                Map<String, Object> mapOfCSSData = (Map<String, Object>) configRecord;
                Object_1_css__c newCSSRecord = new Object_1_css__c();    
                if(String.isNotBlank(String.valueOf(mapOfCSSData.get('serialNumber')))){                            
                    newCSSRecord.Section_Name_As_Rich_Text__c = String.valueOf(mapOfCSSData.get('sectionName')); // A new field with max limit characters were made - Section_Name_As_Rich_Text__c
                    newCSSRecord.Default_text__c = String.valueOf(mapOfCSSData.get('sectionName'));
                    newCSSRecord.Form__c = recordTypeName;
                    newCSSRecord.Columns_In_Section__c = Integer.valueOf(mapOfCSSData.get('typeOfColumn'));
                    newCSSRecord.Section_Number__c  = Integer.valueOf(mapOfCSSData.get('serialNumber'));
                    if(Integer.valueOf(mapOfCSSData.get('serialNumber')) == 1){ // PUT THE QUERY ( IF PRESENT ) TO SECTION NUMBER 1
                        newCSSRecord.ElixirSuite__Parent_Query__c = String.valueOf(mapOfCSSData.get('finalParentQueryForSection_One'));
                        newCSSRecord.ElixirSuite__Is_Time_Enabled__c = IstimeEnabled;
                        }                    
                    newCSSRecord.Map_Query__c = String.valueOf(String.valueOf(mapOfCSSData.get('mapQueryStringified')));
                    newCSSRecord.Raw_Map_Query__c = JSON.serialize(mapOfCSSData.get('mapQuery'));
                    newCSSRecord.Form_Specific_Data__c = Boolean.valueOf(String.valueOf(mapOfCSSData.get('isFormSpecificData')));
                    newCSSRecord.Section_As_Ext_Cmp__c = Boolean.valueOf(String.valueOf(mapOfCSSData.get('hasextCmp')));
                    newCSSRecord.Form_Category__c = formCategoryFromJS;
                    newCSSRecord.Field_APIs_For_AutoText__c = String.valueOf(mapOfCSSData.get('allFieldAPIs'));
                    newCSSRecord.ElixirSuite__Consent_Query__c = String.valueOf(mapOfCSSData.get('isConsent_finalParentQueryForSection_One'));
                    newCSSRecord.Consent_Fields_Per_Section_Stringified__c = String.valueOf(mapOfCSSData.get('isConsent_allFieldAPIStringified'));
                    List<Object> isConsentSelectedObjectLst = (List<Object>) (mapOfCSSData.get('isConsent_SelectedObject_Lst')); 
                    newCSSRecord.ElixirSuite__IS_CONSENT_Selected_Object__c = JSON.serialize(isConsentSelectedObjectLst);
                    List<Object> lstOfAllFieldsApi = (List<Object>) (mapOfCSSData.get('allFieldAPIsArray')); 
                    newCSSRecord.Field_API_AutoText_Array__c = JSON.serialize(lstOfAllFieldsApi);
                    newCSSRecord.ElixirSuite__Enable_Auto_text__c = Boolean.valueOf(mapOfCSSData.get('enableAutoText'));
                    newCSSRecord.ElixirSuite__isFormMacro__c = Boolean.valueOf(mapOfCSSData.get('isMacro'));
                    newCSSRecord.ElixirSuite__Is_matrix__c= Boolean.valueOf(mapOfCSSData.get('enableTable'));
                    newCSSRecord.ElixirSuite__Show_Heading__c = Boolean.valueOf(mapOfCSSData.get('showHeading'));
                    newCSSRecord.ElixirSuite__Add_Problem__c= Boolean.valueOf(mapOfCSSData.get('addProblem'));
                    newCSSRecord.ElixirSuite__Add_Procedure__c= Boolean.valueOf(mapOfCSSData.get('addProcedure'));
                    newCSSRecord.Add_Notes__c =  Boolean.valueOf(mapOfCSSData.get('enableProblemForNotes'));
                    newCSSRecord.ElixirSuite__Type_of_Note__c = String.valueOf(mapOfCSSData.get('typeOfNote'));
                  /*  newCSSRecord.ElixirSuite__Default_Inventory_Type__c = String.valueOf(mapOfCSSData.get('formInventoryVal'));
                    newCSSRecord.ElixirSuite__Lot_Number__c = Boolean.valueOf(mapOfCSSData.get('formCheckbox'));*/
                    newCSSRecord.ElixirSuite__Free_Text_SOQL__c = String.valueOf(mapOfCSSData.get('freeTextSOQL')); 
                  
                    newCSSRecord.ElixirSuite__Static_file_name__c = String.valueOf(mapOfCSSData.get('staticFieldLabel'));
                    if(String.isNotBlank(String.valueOf(mapOfCSSData.get('formComponentVal')))){
                        newCSSRecord.ElixirSuite__Select_Form_Component__c = String.valueOf(mapOfCSSData.get('formComponentVal'));   
                    }
                    else {
                        newCSSRecord.ElixirSuite__Select_Form_Component__c = null; 
                    }
                    if(Boolean.valueOf(mapOfCSSData.get('enableAutoText'))){
                        newCSSRecord.Auto_text__c = String.valueOf(mapOfCSSData.get('autoTextValue'));
                    }
                    else {
                        newCSSRecord.Auto_text__c = '';
                    }
                    newCSSRecord.ElixirSuite__Hide_Selections__c = Boolean.valueOf(mapOfCSSData.get('hideSctionsForAutotext'));
                    if(Boolean.valueOf(mapOfCSSData.get('isConsentForm'))){
                        newCSSRecord.Is_Consent__c = true;                   
                        /* COPY DATA TO CHILD ALSO IF IT IS CONSENT*/
                        List<Object_1_css__c> toInsertChildrecords = new List<Object_1_css__c>();
                        Object_1_css__c childCSSRecord = new Object_1_css__c();                           
                        childCSSRecord.Is_Consent__c = true;
                        childCSSRecord.Default_text__c = String.valueOf(mapOfCSSData.get('consentTextValue'));
                        childCSSRecord.Row__c = 1;
                        childCSSRecord.Column__c = 1;
                        childCSSRecord.Form_Category__c = formCategoryFromJS;
                        toInsertChildrecords.add(childCSSRecord);
                        mapOfParentChildRecords.put(Integer.valueOf(newCSSRecord.Section_Number__c),toInsertChildrecords);
                        /******************************************/
                    }
                    else {
                        if(!String.isEmpty( String.valueOf(mapOfCSSData.get('FieldsLst')))) {
                            
                            List<Object> listOfRelatedCSSRecord = (List<Object>) mapOfCSSData.get('FieldsLst'); 
                          
                            List<Object_1_css__c> toInsertChildrecords = new List<Object_1_css__c>();
                            if(Boolean.valueOf(mapOfCSSData.get('enableTable')) || String.valueOf(mapOfCSSData.get('formComponentVal')) == 'Enable Modular Table'){ // IF TABLE MATRIX STRUCTURE IS ENABLED
                              
                                newCSSRecord.ElixirSuite__Headings__c =  ElixirOEM_FormConfigTableHandling.tableDataSaving(mapOfCSSData,toInsertChildrecords);
                                newCSSRecord.ElixirSuite__Columns_Selected_For_Table__c = String.valueOf(mapOfCSSData.get('table_colSelected'));
                                if(String.isNotBlank(String.valueOf(mapOfCSSData.get('table_colSelected')))){
                                    newCSSRecord.elixirsuite__columns_in_section__c = Integer.valueOf(mapOfCSSData.get('table_colSelected'));
                                }
                            }
                            else {
                                for(Object childRec : listOfRelatedCSSRecord){
                                    Map<String, Object> mapOfchildCSSRecord = (Map<String, Object>) childRec;                        
                                    Object_1_css__c childCSSRecord = new Object_1_css__c();
                                    /*****************FOR IMAGE HANDLING ***********************************************/                        
                                    childCSSRecord.ElixirSuite__IMG_File_Name__c = String.valueOf(mapOfchildCSSRecord.get('fileName'));
                                    childCSSRecord.ElixirSuite__IMG_Default_Button_Label__c = String.valueOf(mapOfchildCSSRecord.get('fileUploadButtonDefaultLabel'));
                                    childCSSRecord.ElixirSuite__IMG_Type_of_Upload__c = String.valueOf(mapOfchildCSSRecord.get('typeOfUploadSelected'));  
                                    childCSSRecord.ElixirSuite__IMG_Type_of_Row__c = String.valueOf(mapOfchildCSSRecord.get('typeSelected'));                        
                                    /***********************************************************************************/
                                    childCSSRecord.ElixirSuite__No_Label__c = Boolean.valueOf(mapOfchildCSSRecord.get('noLabel')); // NO LABEL HANDLING
                                    childCSSRecord.Object_Record_Types__c = JSON.serialize(mapOfchildCSSRecord.get('ObjectRecordTypes')); 
                                    childCSSRecord.Form_Category__c = formCategoryFromJS;
                                    childCSSRecord.Is_Common_Engaged__c = Boolean.valueOf(mapOfchildCSSRecord.get('isCommon'));
                                    childCSSRecord.IsCommon__c = Boolean.valueOf(mapOfchildCSSRecord.get('isCommon'));
                                    if(String.isNotBlank(String.valueOf(mapOfchildCSSRecord.get('autoPopulate')))){
                                    childCSSRecord.Auto_Populate__c = Boolean.valueOf(mapOfchildCSSRecord.get('autoPopulate'));  //Added by Vidish                   
                                    }
                                  
                                 //   childCSSRecord.ElixirSuite__Account_Lookup_Fields__c = JSON.serialize((List<Object>) mapOfchildCSSRecord.get('accountLookupFieldLst')); 
                                    // ADDING FORMULA ENABLED OBJECT - FIELD DETAILS
                                    if(String.isNotBlank(String.valueOf(mapOfchildCSSRecord.get('switchFormulaEnabled')))){
                                        if(Boolean.valueOf(mapOfchildCSSRecord.get('switchFormulaEnabled'))){
                                            List<String> objectLookupName = (String.valueOf(mapOfchildCSSRecord.get('selectedObjectForFormula'))).split(';');
                                            if(objectLookupName.size()>0 && objectLookupName!=null){
                                                childCSSRecord.Map_object__c = objectLookupName[1];
                                                childCSSRecord.Object_lookup_Api__c =  objectLookupName[0];
                                            }               
                                            childCSSRecord.Formula_Map_Enabled__c = Boolean.valueOf(mapOfchildCSSRecord.get('switchFormulaEnabled'));
                                            childCSSRecord.Map_field__c =  String.valueOf(mapOfchildCSSRecord.get('selectedFieldForFormulaMapping'));
                                            List<Object> lst = (List<Object>) mapOfchildCSSRecord.get('fieldListForFormulaMapping'); 
                                            childCSSRecord.Object_Fields__c = JSON.serialize(lst);
                                             
                                           
                                            childCSSRecord.ElixirSuite__Account_Lookup_API__c = String.valueOf(mapOfchildCSSRecord.get('accountLookupAPI'));
                                               childCSSRecord.ElixirSuite__WHERE_clause_per_field__c = String.valueOf(mapOfchildCSSRecord.get('whereClause'));
                                               childCSSRecord.ElixirSuite__Account_Lookup_Fields__c = JSON.serialize((List<Object>) mapOfchildCSSRecord.get('accountLookupFieldLst')); 
                                               if(childCSSRecord.Map_object__c == 'Account' && String.isBlank(childCSSRecord.ElixirSuite__Account_Lookup_API__c)){
                                                childCSSRecord.ElixirSuite__Account_Lookup_API__c = 'Id';
                                               }
                                            
                                        }
                                    } 
                                    
                                    // Field type as CB OR RADIO handling
                                    if(Boolean.valueOf(mapOfchildCSSRecord.get('isPicklistAsRadio'))){
                                        childCSSRecord.Form_Data_Type__c = 'Radio';
                                        if(Boolean.valueOf(mapOfchildCSSRecord.get('verticalAlignForRadio'))){
                                            childCSSRecord.class__c = 'MultiVertical';
                                        }
                                    }
                                    else if(Boolean.valueOf(mapOfchildCSSRecord.get('isMultiPicklistAsCheckbox'))){
                                        childCSSRecord.Form_Data_Type__c = 'Checkbox';
                                        if(Boolean.valueOf(mapOfchildCSSRecord.get('verticalAlignForMultiPicklist'))){
                                            childCSSRecord.class__c = 'MultiVertical';
                                        }
                                    }
                                    else {
                                        childCSSRecord.Form_Data_Type__c = 'Default';
                                        childCSSRecord.class__c = '';
                                    }
                                    // External components data handling
                                    if(Boolean.valueOf(mapOfCSSData.get('hasextCmp'))){
                                        childCSSRecord.Form_Data_Type__c = String.valueOf(mapOfchildCSSRecord.get('selectedRecordType'));
                                        
                                    }
                                    
                                    childCSSRecord.Is_RecordType_Selected__c = Boolean.valueOf(mapOfchildCSSRecord.get('recordTypeExists'));
                                    // Saving depending upon the type of column selected. 
                                    if(INTEGER.valueOf(mapOfCSSData.get('typeOfColumn')) == 2){
                                        childCSSRecord.Column__c =  Integer.valueOf(mapOfchildCSSRecord.get('ColNumber'));
                                        childCSSRecord.Row__c =  Integer.valueOf(mapOfchildCSSRecord.get('RowNumber'));
                                    }
                                    else {
                                        childCSSRecord.Column__c =  1;
                                        childCSSRecord.Row__c =  Integer.valueOf(mapOfchildCSSRecord.get('RowNumber'));
                                    }
                                    // Split for data type || Label || object Name and Api Names
                                    if(String.valueOf(mapOfchildCSSRecord.get('selectedField')).contains(';')){
                                        List<String> selectedFiledJunction = (String.valueOf(mapOfchildCSSRecord.get('selectedField'))).split(';');
                                        if(selectedFiledJunction.size()>0 && selectedFiledJunction!=null) {
                                            childCSSRecord.Data_Type__c =  selectedFiledJunction[1];
                                            childCSSRecord.Field_Label_Long__c =  selectedFiledJunction[2];
                                            childCSSRecord.Default_Field_Label__c = selectedFiledJunction[2]; // Label of field saved in a default field regardless of the external label
                                            childCSSRecord.Field_Name__c =  selectedFiledJunction[0];
                                            childCSSRecord.Object_Name__c = selectedFiledJunction[3];
                                            //Added by Vidish
                                            if(String.valueOf(childCSSRecord.Data_Type__c).equalsIgnoreCase('STRING') || String.valueOf(childCSSRecord.Data_Type__c).equalsIgnoreCase('CURRENCY') 
                                                || String.valueOf(childCSSRecord.Data_Type__c).equalsIgnoreCase('DATE') || String.valueOf(childCSSRecord.Data_Type__c).equalsIgnoreCase('DATETIME')
                                                || String.valueOf(childCSSRecord.Data_Type__c).equalsIgnoreCase('TIME') || String.valueOf(childCSSRecord.Data_Type__c).equalsIgnoreCase('PERCENT') 
                                                
                                                ){
                                              
                                                    
                                                    childCSSRecord.ElixirSuite__Is_formula_Field__c =   checkFormulaField(childCSSRecord.Object_Name__c,childCSSRecord.Field_Name__c);
                                                    
                                                }
                                            
                                            if(String.valueOf(childCSSRecord.Data_Type__c).equalsIgnoreCase('REFERENCE')){
                                                String refObjectName = childCSSRecord.Object_Name__c;
                                                String refFieldName = childCSSRecord.Field_Name__c;
                                                Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();       
                                                Schema.SObjectType leadSchema = schemaMap.get(refObjectName);        
                                                Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
                                                for (String fieldName: fieldMap.keySet()) {
                                                    if(fieldName == refFieldName){
                                                        Schema.DescribeFieldResult f = fieldMap.get(fieldName).getDescribe();
                                                        // Schema.DescribeFieldResult f = leadSchema.getDescribe().fields.fieldName; 
                                                        for(Schema.SObjectType reference : f.getReferenceTo()) {
                                                           
                                                            refObjectName = reference.getDescribe().getName(); 
                                                            childCSSRecord.Reference_to_object__c = refObjectName;
                                                        }
                                                        
                                                        
                                                        //Schema.DescribeFieldResult f = Schema.sObjectType.ElixirSuite__Object_2__c.fields.ElixirSuite__Case__c;
                                                    }
                                                }
                                            }
                                            
                                            
                                            
                                            
                                            //Vidish code ends                                            
                                            
                                            
                                            if(allRecordsForMatch.contains(selectedFiledJunction[0])){                                    
                                                if(Boolean.valueOf(mapOfchildCSSRecord.get('isCommon'))){ // ENGAGE IS COMMON UPDATE ONLY IF THE FIELD IS SELECTED AS ICOMMON FROM CONFIG SCREEN
                                                    childCSSRecord.IsCommon__c = true;
                                                    // IS COMMON UPDATE RECORDS MAP                                         
                                                    allFieldNameRecordsToUpdate.add(selectedFiledJunction[0]);
                                                }                                    
                                            }                                                                
                                        }
                                    }
                                    // set external custom label if opted for the same.
                                    if(String.isNotBlank(String.valueOf(mapOfchildCSSRecord.get('defaultLabel')))){
                                        childCSSRecord.Default_Label_Filled__c = true;
                                        childCSSRecord.Field_Label_Long__c = String.valueOf(mapOfchildCSSRecord.get('defaultLabel'));                            
                                    }
                                    
                                    
                                    
                                    toInsertChildrecords.add(childCSSRecord);
                                }
                            }
                            
                            mapOfParentChildRecords.put(Integer.valueOf(newCSSRecord.Section_Number__c),toInsertChildrecords);
                        }
                        
                    }
                    toInsertParentrecords.add(newCSSRecord);
                }
            }
            
            if(toInsertParentrecords.size()>0 && toInsertParentrecords!=null){
                //insert toInsertParentrecords;
                DMLManager.insertAsUser(toInsertParentrecords);
            }
            List<Object_1_css__c> updatedChildRecordsToInsert = new List<Object_1_css__c>();
            
            // Parent - Child arrangement
            
            for(Object_1_css__c insertedRecords : toInsertParentrecords){
                for(Integer createMap : mapOfParentChildRecords.keySet()){
                    if(Integer.valueOf(insertedRecords.Section_Number__c) == createMap){
                        List<Object_1_css__c> childRecs = new List<Object_1_css__c>();
                        childRecs =  mapOfParentChildRecords.get(Integer.valueOf(insertedRecords.Section_Number__c));
                        for(Object_1_css__c updtIDs : childRecs){
                            updtIDs.Object_1_css__c = insertedRecords.Id;
                            updatedChildRecordsToInsert.add(updtIDs);
                        }
                        
                    }
                    
                }
                //    mapOfParentChildRecords.put(newCSSRecord,toInsertChildrecords);
            }        
            if(updatedChildRecordsToInsert.size()>0 && updatedChildRecordsToInsert!=null){
                //insert updatedChildRecordsToInsert;
                DMLManager.insertAsUser(updatedChildRecordsToInsert);
            }
            // IS COMMON UPDATE 
            
            List<Object_1_css__c> lstToUpdate = new List<Object_1_css__c>();
            for(Object_1_css__c recToUpdate : [SELECT ID,Is_Common_Parent__c FROM Object_1_css__c
                                                where Field_Name__c in : allFieldNameRecordsToUpdate WITH SECURITY_ENFORCED]){
                                                    recToUpdate.Is_Common_Parent__c = true;
                                                    lstToUpdate.add(recToUpdate);
                                                }
            //update lstToUpdate;
            DMLManager.updateAsUser(lstToUpdate);
        
       /* catch(Exception e){
            ExceptionLog.logError(e);
        }*/
        
        
    }
    public class FormsConfigurationWrapper{
        @AuraEnabled public Map<String, String> mapOfContainer;
        @AuraEnabled public Map<String, String> mapOfInventory;
        @AuraEnabled    public Map<String,String> mapByRecordTypeLabelAndDeveloperName{ get; set; }
        @AuraEnabled    public List<String> allObjectRecordtypelabels{ get; set; }   
        @AuraEnabled    public Map<String,String> fieldApiNameAndLabel{ get; set; }
        @AuraEnabled    public Map<String,String> accountFieldApiMap{ get; set; }
        @AuraEnabled    public Integer objectMatchCount {get;set;}
        @AuraEnabled    public Map<String,String> dataTypeMap{get;set;}
        @AuraEnabled    public Map<String,String> fieldsApiAndObjectLabelMap{get;set;}
        @AuraEnabled    public Map<String,String> schemaObjectApiAndLabelMap{get;set;}
        @AuraEnabled    public List<String>duplicateObjects{get;set;}
        @AuraEnabled    public List<Essential_Lookup_Fields__mdt> lookupApiToInclude{ get; set; }
        @AuraEnabled    public Boolean noObjectAvailable{ get; set; }
        
    } 
    /* ****************************************************************************************************************************************/
    /* FOLLOWING METHODS ARE FOR EDIT SCREEN*/
    @AuraEnabled
    public static FormsConfigurationWrapperForEditScreen fetchRecordDataForEditScreen(String recordNumericID){
        
        List<Object_1_css__c> currentRecordInView = new List<Object_1_css__c>(); 
       
        Map<ID, sObject> mapQuery = new Map<ID, sObject>(Database.query(ElixirOEM_TimelineHelper.getAllFieldsNameOfObject('ElixirSuite__Object_1_css__c') + ' FROM Object_1_css__c WHERE Form__c=:recordNumericID AND ElixirSuite__Is_Approval_Record__c = FALSE ORDER BY Section_Number__c '));
        List<Object_1_css__c> initialSection = [SELECT ID,Object_1_css__c from Object_1_css__c WHERE Form__c=:recordNumericID AND Section_Number__c = 1
                                                WITH SECURITY_ENFORCED
                                                Order by ElixirSuite__Row__c , ElixirSuite__Column__c
                                                LIMIT 1];
        currentRecordInView = mapQuery.values();
        List<Object_1_css__c> allChildRelatedobjects = Database.query(ElixirOEM_TimelineHelper.getAllFieldsNameOfObject('ElixirSuite__Object_1_css__c') + ' FROM Object_1_css__c WHERE Object_1_css__c IN : initialSection AND ElixirSuite__Is_Approval_Record__c = FALSE Order by ElixirSuite__Row__c , ElixirSuite__Column__c');
        
        
        FormsConfigurationWrapperForEditScreen toReturn = new FormsConfigurationWrapperForEditScreen();  
        toReturn.allParentSections = currentRecordInView;   
        toReturn.allChildRelatedobjects = allChildRelatedobjects;
        toReturn.dataForSavedRecordType = fetchAllFieldsForSelectedRecordTyev2(recordNumericID); 
        toReturn.accountChildObject = fetchAccountAndRelatedChildObject();
        toReturn.isConsent_AllAccountFields = fetchFieldsForSelectedObject('Account');
        toReturn.isConsent_AllUserFields = fetchFieldsForSelectedObject('User');
        toReturn.mapOfContainer = MasterProblemListController.fetchPickListValue('ElixirSuite__Object_1_css__c','ElixirSuite__Select_Form_Component__c');  
      
        return toReturn;
        
        
    }
    /*********************************************************************************************************************************/
    @AuraEnabled 
    public static FormsConfigurationWrapperForEditScreen fetchRecorrdsForEachSection(String parentID){
        
        List<Object_1_css__c> allChildRelatedobjects = Database.query(ElixirOEM_TimelineHelper.getAllFieldsNameOfObject('ElixirSuite__Object_1_css__c') + ' FROM Object_1_css__c WHERE Object_1_css__c =:parentID AND ElixirSuite__Is_Approval_Record__c = FALSE Order by ElixirSuite__Row__c , ElixirSuite__Column__c');
        FormsConfigurationWrapperForEditScreen instanceWrapper = new FormsConfigurationWrapperForEditScreen();
        instanceWrapper.allParentSections =  Database.query(ElixirOEM_TimelineHelper.getAllFieldsNameOfObject('ElixirSuite__Object_1_css__c') + ' FROM Object_1_css__c WHERE Id=:parentID AND ElixirSuite__Is_Approval_Record__c = FALSE Order by ElixirSuite__Row__c , ElixirSuite__Column__c');
                                               
        instanceWrapper.allChildRelatedobjects = allChildRelatedobjects;
        return instanceWrapper;
    }
    /*************************************************************************************************************************/
    @AuraEnabled
    public static FormsConfigurationWrapperForEditScreen fetchListOfFormsAsRecords(){
        List<Object_1_css__c> allFormsAsRecords = new List<Object_1_css__c>();
        Set<String> setOfDuplicateNames = new Set<String>();
        Map<String,Object_1_css__c[]> mapOfApprovalRecord = new Map<String,Object_1_css__c[]>();
        
        for (AggregateResult aggregate : [SELECT Form__c,count(id) FROM Object_1_css__c Form__c where Form__c!=null 
                                            WITH SECURITY_ENFORCED
                                            GROUP BY Form__c,Form_type__c HAVING count(Form__c)>=1 ])
        {
            setOfDuplicateNames.add((String)aggregate.get('ElixirSuite__Form__c'));
        }
        for (Object_1_css__c cssRecord : [
            SELECT Form__c,ElixirSuite__Approval_Members_Name__c, ElixirSuite__isActive__c, ElixirSuite__Expiry_Date__c, 
            ElixirSuite__Form_Template_Status__c,ElixirSuite__Enable_As__c
            FROM Object_1_css__c
            WHERE Form__c IN :setOfDuplicateNames
            AND ElixirSuite__Section_Number__c = 1
            WITH SECURITY_ENFORCED
        ]){
            // Determine form status here
            if (cssRecord.ElixirSuite__Expiry_Date__c != null) {
                // if expiry date is set and form is expired 
                if(cssRecord.ElixirSuite__Expiry_Date__c < Datetime.now()){
                    cssRecord.ElixirSuite__isActive__c = false;
                    cssRecord.ElixirSuite__Form_Template_Status__c = cssRecord.ElixirSuite__Expiry_Date__c.format('\'Inactive \' MMM d, yyyy hh:mm aaa');
                    cssRecord.ElixirSuite__Expiry_Date__c = null;
                        
                    }
                else { 
                    cssRecord.ElixirSuite__isActive__c = true;                                      
                    cssRecord.ElixirSuite__Form_Template_Status__c = cssRecord.ElixirSuite__Expiry_Date__c.format('\'Active, Valid Till \' MMM d, yyyy hh:mm aaa');
                    //cssRecord.ElixirSuite__Expiry_Date__c = null;
                }
            }
            else {
                // Expiry date is not set. use ElixirSuite__isActive__c to determine active/inactive status
                if (cssRecord.ElixirSuite__isActive__c) {
                    cssRecord.ElixirSuite__Form_Template_Status__c = 'Active';
                }
                else {
                    cssRecord.ElixirSuite__Form_Template_Status__c = 'Inactive';
                }
            }
            allFormsAsRecords.add(cssRecord);
        }
        DMLManager.updateAsUser(allFormsAsRecords);
        //update allFormsAsRecords;
        /*GET RELATED APPROVAL RECORD*/
        for(Object_1_css__c objInstance : [
            SELECT Form__c,ElixirSuite__Approval_Members_Name__c,ElixirSuite__Approval_Level__c
            FROM Object_1_css__c
            WHERE Form__c IN :setOfDuplicateNames AND ElixirSuite__Is_Approval_Record__c = true
            WITH SECURITY_ENFORCED]){            
                if(mapOfApprovalRecord.containsKey(objInstance.ElixirSuite__Form__c)){
                    mapOfApprovalRecord.get(objInstance.ElixirSuite__Form__c).add(objInstance);
                }else{
                    List<Object_1_css__c> approvalRecArray = new List<Object_1_css__c>();
                    approvalRecArray.add(objInstance);
                    mapOfApprovalRecord.put(objInstance.ElixirSuite__Form__c,approvalRecArray);
                }
                
            }
        /****************************/
        FormsConfigurationWrapperForEditScreen toReturn = new FormsConfigurationWrapperForEditScreen();
        toReturn.allFormsAsRecords = allFormsAsRecords;
        toReturn.allRecordTypesOfMDTObject = fetchAllRecordTypesOnMDTObject();
        toReturn.essentialLookupFields = fetchEssentialLookupFields();
        toReturn.totalApprovalLevel = ElixirOEM_FormApprovalHelper.fetchNumberOfFormsApprovalLevel();
        toreturn.mapOfApprovalRecord = mapOfApprovalRecord;
        return toReturn;
    }
    public static void approvalRecordsCleanMap(){
        /*** APPROVAL RECORDS QUERY***/
        Object_1_css__c[] cssApprovalRecords = [SELECT ID,Approval_Members__c from Object_1_css__c WHERE Is_Approval_Record__c = TRUE
                                                WITH SECURITY_ENFORCED];
        for(Object_1_css__c approvalrec : cssApprovalRecords){
            Map<String,Set<Id>> recordLevelsObjectAndIDs = new  Map<String,Set<Id>>();
            if(String.isNotBlank(approvalrec.Approval_Members__c)){
                String[] lstOfGenericIDs = approvalrec.Approval_Members__c.split(';');
                for(Id sObjID: lstOfGenericIDs){
                    String sObjectName = sObjID.getSObjectType().getDescribe().getName();
                    if(recordLevelsObjectAndIDs.containsKey(sObjectName)){
                        recordLevelsObjectAndIDs.get(sObjectName).add(sObjID);
                    }else{
                        Set<Id> sobjectSplitID = new  Set<Id>();
                        sobjectSplitID.add(sObjID);
                        recordLevelsObjectAndIDs.put(sObjectName,sobjectSplitID);
                    }
                    
                }
            }
            
        }
        /*****************************/
    }
    public static  List<Essential_Lookup_Fields__mdt> fetchEssentialLookupFields() {
        return [SELECT ID,Lookup_Api__c from Essential_Lookup_Fields__mdt WHERE Lookup_Api__c!='' WITH SECURITY_ENFORCED ];
    }
    @AuraEnabled
    public static  FormsConfigurationWrapper fetchAllFieldsForSelectedRecordTyev2(String selectedRecordTypeFuzzy) {
        
        Map<String,String> allRecordTypeToObjectApiMap = recordTypeByobjectNameMap(selectedRecordTypeFuzzy);
        //  List<String> duplicaterecordTypes = recievedWrapeer.duplicateRecordTypesOnDifferentObject;
        List<String> duplicateObjects = new List<String>();
        Map<String,String> fieldsApiAndLabelMap = new Map<String,String>();
        Map<String,String> fieldsApiAndObjectLabelMap = new Map<String,String>();
        Map<String,String> dataTypeMap  = new Map<String,String>();
        List<String> allObjectApiNamesForFiledToQuery = new List<String>();
        Integer countForObjectForWhichRecordTypeMatch = 0; // object matching count
        FormsConfigurationWrapper toReturnData = new FormsConfigurationWrapper();
        
        for(String recrdEntity : allRecordTypeToObjectApiMap.keyset()){
            //  if(recrdEntity.containsIgnoreCase(selectedRecordTypeFuzzy)){
            // if(recrdEntity == selectedRecordTypeFuzzy){
            countForObjectForWhichRecordTypeMatch++;
            allObjectApiNamesForFiledToQuery.add(recrdEntity); 
            duplicateObjects.add(recrdEntity);
            //  }
        }
        for(String filedInstance : allObjectApiNamesForFiledToQuery){
            Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Map <String, Schema.SObjectField> fieldMap = schemaMap.get(filedInstance).getDescribe().fields.getMap();
            dataTypeMap.putAll(cleanMapForFieldApiAndDataType(filedInstance));
            fieldsApiAndObjectLabelMap.putAll(cleanMapForFieldApiAndObjectName(filedInstance));
            for(Schema.SObjectField sfield : fieldMap.Values())
            {
                if (sfield.getDescribe().isCustom()) {
                    schema.describefieldresult dfield = sfield.getDescribe();
                    
                    fieldsApiAndLabelMap.put(dfield.getname(),dfield.getLabel());
                }
            }
            
        }
        toReturnData.fieldApiNameAndLabel = fieldsApiAndLabelMap;
        //   toReturnData.objectMatchCount = countForObjectForWhichRecordTypeMatch;
        toReturnData.dataTypeMap = dataTypeMap;
        toReturnData.fieldsApiAndObjectLabelMap = fieldsApiAndObjectLabelMap;
        //     toReturnData.schemaObjectApiAndLabelMap = objectLabelAndApiNames();
        //  toReturnData.duplicateObjects = duplicateObjects;
        
        return toReturnData;
    }
    public static Boolean childRecordsInsertion(String childJSON,List<String>allRecordsForMatch,String formCategoryFromJS){
        Map<String, Object> mainJson =(Map<String, Object>) JSON.deserializeUntyped(childJSON);
        List<Object> listOfProblems = (List<Object>) mainJson.get('keysToSave');
        Boolean isRecordFreshCreated = false;
        
        List<Object_1_css__c> toInsertChildrecords = new List<Object_1_css__c>();
        
        Map<Integer,List<Object_1_css__c>> mapOfParentChildRecords = new Map<Integer,List<Object_1_css__c>>();
        
        
        List<String> isCommonUpdate = new  List<String>();
        
        for(Object configRecord : listOfProblems){
            Map<String, Object> mapOfCSSData = (Map<String, Object>) configRecord;
            
            if(String.isNotBlank(String.valueOf(mapOfCSSData.get('serialNumber')))){      
                Object_1_css__c newCSSRecord = new Object_1_css__c();              
                newCSSRecord.Section_Name_As_Rich_Text__c = String.valueOf(mapOfCSSData.get('sectionName'));
                newCSSRecord.Default_text__c = String.valueOf(mapOfCSSData.get('sectionName'));
                newCSSRecord.Columns_In_Section__c = Integer.valueOf(mapOfCSSData.get('typeOfColumn'));
                newCSSRecord.Section_Number__c  = Integer.valueOf(mapOfCSSData.get('serialNumber'));
                newCSSRecord.Form_Category__c = formCategoryFromJS;
                if(Boolean.valueOf(mapOfCSSData.get('isConsentForm'))){
                    if(!Boolean.valueOf(mapOfCSSData.get('wasExistingConsent'))){ // CONVERTED FROM NON CONSENT TO CONSENT
                        newCSSRecord.Is_Consent__c = true;
                        /* COPY DATA TO CHILD ALSO IF IT IS CONSENT*/
                        Object_1_css__c childCSSRecord = new Object_1_css__c();                           
                        childCSSRecord.Is_Consent__c = true;
                        childCSSRecord.Default_text__c = String.valueOf(mapOfCSSData.get('consentTextValue'));
                        childCSSRecord.Row__c = 1;
                        childCSSRecord.Column__c = 1;
                        childCSSRecord.Object_1_css__c = String.valueOf(mapOfCSSData.get('parentID'));
                        childCSSRecord.Form_Category__c = formCategoryFromJS;
                        toInsertChildrecords.add(childCSSRecord);
                        isRecordFreshCreated = true;
                        mapOfParentChildRecords.put(Integer.valueOf(newCSSRecord.Section_Number__c),toInsertChildrecords);
                        /******************************************/
                    }
                    
                }
                else {
                    
                    
                    if(!String.isBlank( String.valueOf(mapOfCSSData.get('FieldsLst')))) {
                        List<Object> listOfRelatedCSSRecord = (List<Object>) mapOfCSSData.get('FieldsLst'); 
                        for(Object childRec : listOfRelatedCSSRecord){
                            Map<String, Object> mapOfchildCSSRecord = (Map<String, Object>) childRec;
                            if(String.isBlank(String.valueOf(mapOfchildCSSRecord.get('childID')))){
                                Object_1_css__c childCSSRecord = new Object_1_css__c(); 
                                /*****************FOR IMAGE HANDLING ***********************************************/
                                
                                childCSSRecord.ElixirSuite__IMG_File_Name__c = String.valueOf(mapOfchildCSSRecord.get('fileName'));
                                childCSSRecord.ElixirSuite__IMG_Default_Button_Label__c = String.valueOf(mapOfchildCSSRecord.get('fileUploadButtonDefaultLabel'));
                                childCSSRecord.ElixirSuite__IMG_Type_of_Upload__c = String.valueOf(mapOfchildCSSRecord.get('typeOfUploadSelected'));  
                                childCSSRecord.ElixirSuite__IMG_Type_of_Row__c = String.valueOf(mapOfchildCSSRecord.get('typeSelected'));
                                
                                /***********************************************************************************/
                                childCSSRecord.ElixirSuite__No_Label__c = Boolean.valueOf(mapOfchildCSSRecord.get('noLabel')); // NO LABEL HANDLING
                                childCSSRecord.Form_Category__c = formCategoryFromJS;
                                childCSSRecord.Object_1_css__c = String.valueOf(mapOfCSSData.get('parentID'));
                                childCSSRecord.Object_Record_Types__c = JSON.serialize(mapOfchildCSSRecord.get('ObjectRecordTypes')); 
                                childCSSRecord.Is_Common_Engaged__c = Boolean.valueOf(mapOfchildCSSRecord.get('isCommon')); // WAS IS COMMON EXERTED
                                childCSSRecord.IsCommon__c = Boolean.valueOf(mapOfchildCSSRecord.get('isCommon'));
                                if(String.isNotBlank(String.valueOf(mapOfCSSData.get('autoPopulate')))){
                                childCSSRecord.Auto_Populate__c = Boolean.valueOf(mapOfCSSData.get('autoPopulate'));  //Added by Vidish                  
                                }
                             //   childCSSRecord.ElixirSuite__Account_Lookup_Fields__c = JSON.serialize((List<Object>) mapOfchildCSSRecord.get('accountLookupFieldLst')); 
                                // ADDING FORMULA ENABLED OBJECT - FIELD DETAILS
                                if(String.isNotBlank(String.valueOf(mapOfchildCSSRecord.get('switchFormulaEnabled')))){
                                    if(Boolean.valueOf(mapOfchildCSSRecord.get('switchFormulaEnabled'))){
                                        List<String> objectLookupName = (String.valueOf(mapOfchildCSSRecord.get('selectedObjectForFormula'))).split(';');
                                        if(objectLookupName.size()>0 && objectLookupName!=null){
                                            childCSSRecord.Map_object__c = objectLookupName[1];
                                            childCSSRecord.Object_lookup_Api__c =  objectLookupName[0];
                                        }               
                                        
                                        childCSSRecord.Map_field__c =  String.valueOf(mapOfchildCSSRecord.get('selectedFieldForFormulaMapping'));
                                        List<Object> lst = (List<Object>) mapOfchildCSSRecord.get('fieldListForFormulaMapping'); 
                                        childCSSRecord.Object_Fields__c = JSON.serialize(lst);
                                        childCSSRecord.ElixirSuite__Account_Lookup_API__c = String.valueOf(mapOfchildCSSRecord.get('accountLookupAPI'));
                                        childCSSRecord.ElixirSuite__WHERE_clause_per_field__c = String.valueOf(mapOfchildCSSRecord.get('whereClause'));
                                        childCSSRecord.ElixirSuite__Account_Lookup_Fields__c = JSON.serialize((List<Object>) mapOfchildCSSRecord.get('accountLookupFieldLst')); 
                                        if(childCSSRecord.Map_object__c == 'Account' && String.isBlank(childCSSRecord.ElixirSuite__Account_Lookup_API__c)){
                                            childCSSRecord.ElixirSuite__Account_Lookup_API__c = 'Id';
                                           }
                                    }
                                    childCSSRecord.Formula_Map_Enabled__c = Boolean.valueOf(mapOfchildCSSRecord.get('switchFormulaEnabled')); 
                                } 
                                
                                // Field type as CB OR RADIO handling
                                Boolean doNotModifyMultipickList = false;
                                Boolean doNotModifyPickList = false;
                                if(Boolean.valueOf(mapOfchildCSSRecord.get('isPicklistAsRadio'))){
                                    doNotModifyMultipickList = true;
                                    childCSSRecord.Form_Data_Type__c = 'Radio';
                                    if(Boolean.valueOf(mapOfchildCSSRecord.get('verticalAlignForRadio'))){
                                        childCSSRecord.class__c = 'MultiVertical';
                                    }
                                } 
                                else if(Boolean.valueOf(mapOfchildCSSRecord.get('isMultiPicklistAsCheckbox'))){
                                    doNotModifyPickList = true;
                                    childCSSRecord.Form_Data_Type__c = 'Checkbox';
                                    if(Boolean.valueOf(mapOfchildCSSRecord.get('verticalAlignForMultiPicklist'))){
                                        childCSSRecord.class__c = 'MultiVertical';
                                    }
                                }
                                else {
                                    childCSSRecord.Form_Data_Type__c = 'Default';
                                    childCSSRecord.class__c = '';
                                }
                                // External components data handling
                                if(Boolean.valueOf(mapOfCSSData.get('hasextCmp'))){
                                    childCSSRecord.Form_Data_Type__c = String.valueOf(mapOfchildCSSRecord.get('selectedRecordType'));
                                    
                                }
                                childCSSRecord.Is_RecordType_Selected__c = Boolean.valueOf(mapOfchildCSSRecord.get('recordTypeExists'));
                                // Saving depending upon the type of column selected. 
                                if(INTEGER.valueOf(mapOfCSSData.get('typeOfColumn')) == 2){
                                    childCSSRecord.Column__c =  Integer.valueOf(mapOfchildCSSRecord.get('ColNumber'));
                                    childCSSRecord.Row__c =  Integer.valueOf(mapOfchildCSSRecord.get('RowNumber'));
                                }
                                else {
                                    childCSSRecord.Column__c =  1;
                                    childCSSRecord.Row__c =  Integer.valueOf(mapOfchildCSSRecord.get('RowNumber'));
                                }
                                // Split for data type || Label || object Name and Api Names
                                if(String.valueOf(mapOfchildCSSRecord.get('selectedField')).contains(';')){
                                   
                                    List<String> selectedFiledJunction = (String.valueOf(mapOfchildCSSRecord.get('selectedField'))).split(';');
                                    
                                    if(selectedFiledJunction.size()>0 && selectedFiledJunction!=null) {
                                        childCSSRecord.Data_Type__c =  selectedFiledJunction[1];
                                        childCSSRecord.Field_Label_Long__c =  selectedFiledJunction[2];
                                        childCSSRecord.Default_Field_Label__c = selectedFiledJunction[2]; // Label of field saved in a default field regardless of the external label
                                        childCSSRecord.Field_Name__c =  selectedFiledJunction[0];
                                        childCSSRecord.Object_Name__c = selectedFiledJunction[3];
                                        
                                        //Added by Vidish
                                        
                                        if(String.valueOf(childCSSRecord.Data_Type__c).equalsIgnoreCase('REFERENCE')){
                                         
                                            String refObjectName = childCSSRecord.Object_Name__c;
                                            String refFieldName = childCSSRecord.Field_Name__c;
                                            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();       
                                            Schema.SObjectType leadSchema = schemaMap.get(refObjectName);        
                                            Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
                                            for (String fieldName: fieldMap.keySet()) {
                                                if(fieldName == refFieldName){
                                                    Schema.DescribeFieldResult f = fieldMap.get(fieldName).getDescribe();
                                                    // Schema.DescribeFieldResult f = leadSchema.getDescribe().fields.fieldName; 
                                                    for(Schema.SObjectType reference : f.getReferenceTo()) {
                                                        refObjectName = reference.getDescribe().getName(); 
                                                        childCSSRecord.Reference_to_object__c = refObjectName;
                                                    }
                                                    
                                                    
                                                    //Schema.DescribeFieldResult f = Schema.sObjectType.ElixirSuite__Object_2__c.fields.ElixirSuite__Case__c;
                                                }
                                            }
                                        }
                                        // Ended by vidish
                                        
                                        if(allRecordsForMatch.contains(selectedFiledJunction[0])){
                                            if(Boolean.valueOf(mapOfchildCSSRecord.get('isCommon'))){ // ENGAGE IS COMMON UPDATE ONLY IF THE FIELD IS SELECTED AS ICOMMON FROM CONFIG SCREEN
                                                childCSSRecord.IsCommon__c = true;
                                                // IS COMMON UPDATE RECORDS MAP 
                                                isCommonUpdate.add(selectedFiledJunction[0]);
                                            }
                                        }
                                    }
                                }
                                // set external custom label if opted for the same.
                                if(String.isNotBlank(String.valueOf(mapOfchildCSSRecord.get('defaultLabel')))){
                                    childCSSRecord.Default_Label_Filled__c = true;
                                    childCSSRecord.Field_Label_Long__c = String.valueOf(mapOfchildCSSRecord.get('defaultLabel'));                            
                                }
                                toInsertChildrecords.add(childCSSRecord);
                                
                            }
                        }
                    }
                }
                
            }
        }
        
        // Child insert for new child records for existing parent record
        if(toInsertChildrecords.size()>0 && toInsertChildrecords!=null){
            //insert toInsertChildrecords;
            DMLManager.insertAsUser(toInsertChildrecords);
        }
        // IS COMMON UPDATE 
        List<Object_1_css__c> lstToUpdate = new List<Object_1_css__c>();
        for(Object_1_css__c recToUpdate : [SELECT ID,Is_Common_Parent__c 
                                            FROM Object_1_css__c where Field_Name__c in : isCommonUpdate
                                            WITH SECURITY_ENFORCED]){
                                                recToUpdate.Is_Common_Parent__c = true;
                                                lstToUpdate.add(recToUpdate);
                                            }
    
        //update lstToUpdate;
        DMLManager.updateAsUser(lstToUpdate);
        return isRecordFreshCreated;
    }
    
    @AuraEnabled
    public static void saveAfterEdit_FormconfigData(String formConfigurationDataToSave,String recordTypeName,String formNewSectionsToInsert, String formNewChildRecordsToInsert,
                                                    List<String> parentSectiondelList,String formCategoryFromJS,  Boolean IstimeEnabled,List<String> tableRecordsToDel){ 
                                                        try{
                                                            Boolean flagDeletion = false;
                                                            //New section records to insert after it has been added from edit screen
                                                            if(String.isNotBlank(formNewSectionsToInsert)){
                                                                saveFormconfigData(formNewSectionsToInsert,recordTypeName,formCategoryFromJS,IstimeEnabled);
                                                            }
                                                            
                                                            // Get all records to check for common records
                                                            List<String> allRecordsForMatch = new  List<String>();
                                                            List<String> allFieldNameRecordsToUpdate = new List<String>();
                                                            
                                                            for(Object_1_css__c obj : [SELECT ID,Field_Name__c from Object_1_css__c WHERE Field_Name__c!=NULL
                                                                                        WITH SECURITY_ENFORCED]){
                                                                                            allRecordsForMatch.add(obj.Field_Name__c);
                                                                                            
                                                                                        } 
                                                            //New child records to insert 
                                                            formNewChildRecordsToInsert = formConfigurationDataToSave;
                                                            if(String.isNotBlank(formNewChildRecordsToInsert)){
                                                                flagDeletion = childRecordsInsertion(formNewChildRecordsToInsert,allRecordsForMatch,formCategoryFromJS);
                                                            }   
                                                            List<String> parentRecordChildToBeDeleted = new List<String>();  
                                                            List<String> macroChildToBeDeleted = new List<String>(); 
                                                            
                                                            List<String> tableToDeleteRecords = new List<String>();
                                                            List<String> tableCounterToDeleteRecords = new List<String>();
                                                            List<Object_1_css__c> tableToInsertRecords = new List<Object_1_css__c>();
                                                            List<String> modularTableRecordsDel = new List<String>(); 
                                                            // Saving logic starts
                                                            Map<String, Object> mainJson =(Map<String, Object>) JSON.deserializeUntyped(formConfigurationDataToSave);
                                                            List<Object> listOfProblems = (List<Object>) mainJson.get('keysToSave');
                                                            
                                                            
                                                            List<Object_1_css__c> toUpdateParentrecords = new List<Object_1_css__c>();
                                                            List<Object_1_css__c> toUpdateChildrecords = new List<Object_1_css__c>();
                                                            
                                                            Map<Integer,List<Object_1_css__c>> mapOfParentChildRecords = new Map<Integer,List<Object_1_css__c>>();
                                                            List<String> isRecordConsent = new List<String>();
                                                            for(Object configRecord : listOfProblems){
                                                                Map<String, Object> mapOfCSSData = (Map<String, Object>) configRecord;
                                                                if(String.isNotBlank(String.valueOf(mapOfCSSData.get('parentID')))){
                                                                    
                                                                    
                                                                    Object_1_css__c newCSSRecord = new Object_1_css__c(); 
                                                                    
                                                                    newCSSRecord.Section_Name_As_Rich_Text__c = String.valueOf(mapOfCSSData.get('sectionName'));
                                                                    newCSSRecord.Default_text__c = String.valueOf(mapOfCSSData.get('sectionName'));
                                                                    newCSSRecord.Form__c = recordTypeName;
                                                                    newCSSRecord.Columns_In_Section__c = integer.valueOf(mapOfCSSData.get('typeOfColumn'));
                                                                    newCSSRecord.Section_Number__c  = Integer.valueOf(mapOfCSSData.get('serialNumber'));
                                                                    if(Integer.valueOf(mapOfCSSData.get('serialNumber')) == 1){ // PUT THE QUERY ( IF PRESENT ) TO SECTION NUMBER 1
                                                                        newCSSRecord.ElixirSuite__Parent_Query__c = String.valueOf(mapOfCSSData.get('finalParentQueryForSection_One'));
                                                                            newCSSRecord.ElixirSuite__Is_Time_Enabled__c=Boolean.valueOf(IstimeEnabled);
                                                                        }
                                                                    newCSSRecord.ID = String.valueOf(mapOfCSSData.get('parentID'));
                                                                    newCSSRecord.Is_Consent__c = Boolean.valueOf(mapOfCSSData.get('isConsentForm'));
                                                                    
                                                                    newCSSRecord.Map_Query__c = String.valueOf(String.valueOf(mapOfCSSData.get('mapQueryStringified')));
                                                                    newCSSRecord.Raw_Map_Query__c = JSON.serialize(mapOfCSSData.get('mapQuery'));
                                                                    newCSSRecord.Form_Specific_Data__c = Boolean.valueOf(String.valueOf(mapOfCSSData.get('isFormSpecificData')));
                                                                    newCSSRecord.Section_As_Ext_Cmp__c = Boolean.valueOf(String.valueOf(mapOfCSSData.get('hasextCmp')));
                                                                    newCSSRecord.ElixirSuite__Enable_Auto_text__c = Boolean.valueOf(mapOfCSSData.get('enableAutoText'));
                                                                    newCSSRecord.Field_APIs_For_AutoText__c = String.valueOf(mapOfCSSData.get('allFieldAPIs'));
                                                                    newCSSRecord.ElixirSuite__Default_Inventory_Type__c = String.valueOf(mapOfCSSData.get('formInventoryVal'));
                                                                  
                                                                    newCSSRecord.ElixirSuite__isFormMacro__c = Boolean.valueOf(mapOfCSSData.get('isMacro'));
                                                                    if(Boolean.valueOf(mapOfCSSData.get('isMacro'))){
                                                                        macroChildToBeDeleted.add(String.valueOf(mapOfCSSData.get('parentID')));
                                                                    } 
                                                                    newCSSRecord.ElixirSuite__Consent_Query__c = String.valueOf(mapOfCSSData.get('isConsent_finalParentQueryForSection_One'));
                                                                    newCSSRecord.Consent_Fields_Per_Section_Stringified__c = String.valueOf(mapOfCSSData.get('isConsent_allFieldAPIStringified'));
                                                                    newCSSRecord.ElixirSuite__Add_Problem__c= Boolean.valueOf(mapOfCSSData.get('addProblem'));
                                                                    if(Boolean.valueOf(mapOfCSSData.get('addProblem'))){
                                                                        macroChildToBeDeleted.add(String.valueOf(mapOfCSSData.get('parentID')));
                                                                    }
                                                                    newCSSRecord.ElixirSuite__Add_Procedure__c= Boolean.valueOf(mapOfCSSData.get('addProcedure'));
                                                                    if(Boolean.valueOf(mapOfCSSData.get('addProcedure'))){
                                                                        macroChildToBeDeleted.add(String.valueOf(mapOfCSSData.get('parentID')));
                                                                    }
                                                                    List<Object> lstOfAllFieldsApi = (List<Object>) (mapOfCSSData.get('allFieldAPIsArray')); 
                                                                    newCSSRecord.Field_API_AutoText_Array__c = JSON.serialize(lstOfAllFieldsApi);  
                                                                    newCSSRecord.Add_Notes__c =  Boolean.valueOf(mapOfCSSData.get('enableProblemForNotes'));
                                                                    if(Boolean.valueOf(mapOfCSSData.get('enableProblemForNotes'))){
                                                                        macroChildToBeDeleted.add(String.valueOf(mapOfCSSData.get('parentID')));
                                                                    }
                                                                    newCSSRecord.ElixirSuite__Type_of_Note__c = String.valueOf(mapOfCSSData.get('typeOfNote'));
                                                                    newCSSRecord.ElixirSuite__Static_file_name__c = String.valueOf(mapOfCSSData.get('staticFieldLabel'));
                                                                    if(String.valueOf(mapOfCSSData.get('formComponentVal')) != 'Enable Draw And Annotate'){
                                                                        newCSSRecord.ElixirSuite__Static_file_name__c = '';
                                                                    }
                                                                    if(Boolean.valueOf(mapOfCSSData.get('enableAutoText'))){
                                                                        newCSSRecord.Auto_text__c = String.valueOf(mapOfCSSData.get('autoTextValue'));
                                                                    }
                                                                    else {
                                                                        newCSSRecord.Auto_text__c = '';
                                                                    }
                                                                    if(String.isNotBlank(String.valueOf(mapOfCSSData.get('formComponentVal')))){
                                                                        newCSSRecord.ElixirSuite__Select_Form_Component__c = String.valueOf(mapOfCSSData.get('formComponentVal'));  
                                                                        if(String.valueOf(mapOfCSSData.get('formComponentVal')) == 'Enable Upload And Annotate' 
                                                                           || String.valueOf(mapOfCSSData.get('formComponentVal')) == 'Enable Draw And Annotate'
                                                                           || String.valueOf(mapOfCSSData.get('formComponentVal')) == 'Enable Inventory Order'
                                                                           || String.valueOf(mapOfCSSData.get('formComponentVal')) == 'Enable Prescription Order' 
                                                                           || String.valueOf(mapOfCSSData.get('formComponentVal')) == 'Enable Lab Order'
                                                                           || String.valueOf(mapOfCSSData.get('formComponentVal')) == 'Enable Diagnoses'
                                                                           || String.valueOf(mapOfCSSData.get('formComponentVal')) == 'Enable Medications List'){
                                                                               macroChildToBeDeleted.add(String.valueOf(mapOfCSSData.get('parentID')));
                                                                           }
                                                                    }   
                                                                    else {
                                                                        newCSSRecord.ElixirSuite__Select_Form_Component__c = null; 
                                                                    }
                                                                    newCSSRecord.ElixirSuite__Hide_Selections__c = Boolean.valueOf(mapOfCSSData.get('hideSctionsForAutotext'));
                                                                    newCSSRecord.ElixirSuite__Is_matrix__c= Boolean.valueOf(mapOfCSSData.get('enableTable'));
                                                                    newCSSRecord.ElixirSuite__Show_Heading__c = Boolean.valueOf(mapOfCSSData.get('showHeading'));
                                                                    newCSSRecord.ElixirSuite__Free_Text_SOQL__c = String.valueOf(mapOfCSSData.get('freeTextSOQL')); 
                                                                    if(Boolean.valueOf(mapOfCSSData.get('isConsentForm'))){
                                                                        newCSSRecord.Is_Consent__c = true;
                                                                        /* COPY DATA TO CHILD ALSO IF IT IS CONSENT*/
                                                                        List<Object_1_css__c> toInsertChildrecords = new List<Object_1_css__c>();
                                                                        List<Object> listOfRelatedCSSRecord = (List<Object>) mapOfCSSData.get('FieldsLst'); 
                                                                        
                                                                        for(Object childRec : listOfRelatedCSSRecord){
                                                                            Map<String, Object> mapOfchildCSSRecord = (Map<String, Object>) childRec;
                                                                            if(String.isNotBlank(String.valueOf(mapOfchildCSSRecord.get('childID')))){
                                                                                Object_1_css__c childCSSRecord = new Object_1_css__c();  
                                                                                
                                                                                childCSSRecord.Id = String.valueOf(mapOfchildCSSRecord.get('childID'));
                                                                                
                                                                                childCSSRecord.Default_text__c = String.valueOf(mapOfCSSData.get('consentTextValue'));
                                                                                childCSSRecord.ElixirSuite__Row__c = 1;
                                                                                childCSSRecord.ElixirSuite__Column__c = 1;
                                                                                toUpdateChildrecords.add(childCSSRecord);
                                                                                // toInsertChildrecords.add(childCSSRecord);  
                                                                                mapOfParentChildRecords.put(Integer.valueOf(newCSSRecord.Section_Number__c),toInsertChildrecords);
                                                                                /******************************************/
                                                                                
                                                                            }
                                                                        }
                                                                        if(Boolean.valueOf(mapOfCSSData.get('wasExistingConsent')) == false){
                                                                            parentRecordChildToBeDeleted.add(String.valueOf(mapOfCSSData.get('parentID')));
                                                                        }
                                                                        
                                                                    }
                                                                    else {
                                                                        if(Boolean.valueOf(mapOfCSSData.get('wasExistingConsent'))){
                                                                            isRecordConsent.add(String.valueOf(mapOfCSSData.get('parentID')));
                                                                        }
                                                                        if(String.isNotBlank(String.valueOf(mapOfCSSData.get('FieldsLst')))) {
                                                                            List<Object> listOfRelatedCSSRecord = (List<Object>) mapOfCSSData.get('FieldsLst'); 
                                                                            if(Boolean.valueOf(mapOfCSSData.get('enableTable')) || String.valueOf(mapOfCSSData.get('formComponentVal')) == 'Enable Modular Table' ){ // IF TABLE MATRIX STRUCTURE IS ENABLED
                                                                                List<Object> tableRow = (List<Object>) mapOfCSSData.get('table_fieldLst');
                                                                                if(tableRow!=null){
                                                                                    //  tableToDeleteRecords.add(String.valueOf(mapOfCSSData.get('parentID')));
                                                                                    if(String.valueOf(mapOfCSSData.get('formComponentVal')) == 'Enable Table'){
                                                                                    tableCounterToDeleteRecords.add(String.valueOf(mapOfCSSData.get('parentID'))); // TO DEL RECOEDS WHEN IT OS CONVERTED FROM NON TABLE TO TABLE
                                                                                    }
                                                                                    if(String.valueOf(mapOfCSSData.get('formComponentVal')) == 'Enable Modular Table'){
                                                                                        modularTableRecordsDel.add(String.valueOf(mapOfCSSData.get('parentID')));
                                                                                    }
                                                                                    newCSSRecord.ElixirSuite__Headings__c =  ElixirOEM_FormConfigTableHandling.tableDataSaving_Update(mapOfCSSData,tableToInsertRecords,String.valueOf(mapOfCSSData.get('parentID')));
                                                                                    
                                                                                    newCSSRecord.ElixirSuite__Columns_Selected_For_Table__c = String.valueOf(mapOfCSSData.get('table_colSelected'));
                                                                                    if(String.isNotBlank(String.valueOf(mapOfCSSData.get('table_colSelected')))){
                                                                                        newCSSRecord.elixirsuite__columns_in_section__c = Integer.valueOf(mapOfCSSData.get('table_colSelected'));
                                                                                    }
                                                                                }
                                                                                
                                                                            }
                                                                            else {
                                                                                tableToDeleteRecords.add(String.valueOf(mapOfCSSData.get('parentID'))); // TO DEL RECORDS WHEN IT IS CONVERTED FROM  TABLE TO NON TABLE BUT DELETE ONLY MATRIX RECORDS                                                                          
                                                                                for(Object childRec : listOfRelatedCSSRecord){
                                                                                    
                                                                                    Map<String, Object> mapOfchildCSSRecord = (Map<String, Object>) childRec;
                                                                                    if(String.isNotBlank(String.valueOf(mapOfchildCSSRecord.get('childID')))){
                                                                                        
                                                                                        Object_1_css__c childCSSRecord = new Object_1_css__c(); 
                                                                                        childCSSRecord.Id = String.valueOf(mapOfchildCSSRecord.get('childID')); // Updating existing child record
                                                                                        childCSSRecord.Is_Common_Engaged__c = Boolean.valueOf(mapOfchildCSSRecord.get('isCommon')); // WAS IS COMMON EXERTED
                                                                                        childCSSRecord.IsCommon__c = Boolean.valueOf(mapOfchildCSSRecord.get('isCommon'));
                                                                                        if(mapOfchildCSSRecord.get('autoPopulate') != null)
                                                                                        if(Boolean.valueOf(mapOfchildCSSRecord.get('autoPopulate'))){
                                                                                                childCSSRecord.Auto_Populate__c = Boolean.valueOf(mapOfchildCSSRecord.get('autoPopulate'));  //Added by Vidish                   
                                                                                            }                                                                             //Added by Vidish commented by Shivam (creating problem for update the form on configuration screen) 
                                                                                        childCSSRecord.Object_Record_Types__c = JSON.serialize(mapOfchildCSSRecord.get('ObjectRecordTypes')); 
                                                                                        childCSSRecord.ElixirSuite__No_Label__c = Boolean.valueOf(mapOfchildCSSRecord.get('noLabel')); // NO LABEL HANDLING
                                                                                        /*****************FOR IMAGE HANDLING ***********************************************/
                                                                                        
                                                                                        childCSSRecord.ElixirSuite__IMG_File_Name__c = String.valueOf(mapOfchildCSSRecord.get('fileName'));
                                                                                        childCSSRecord.ElixirSuite__IMG_Default_Button_Label__c = String.valueOf(mapOfchildCSSRecord.get('fileUploadButtonDefaultLabel'));
                                                                                        childCSSRecord.ElixirSuite__IMG_Type_of_Upload__c = String.valueOf(mapOfchildCSSRecord.get('typeOfUploadSelected'));  
                                                                                        childCSSRecord.ElixirSuite__IMG_Type_of_Row__c = String.valueOf(mapOfchildCSSRecord.get('typeSelected'));
                                                                                        if(String.valueOf(mapOfchildCSSRecord.get('typeSelected')) == 'Field'){
                                                                                            childCSSRecord.ElixirSuite__IMG_File_Name__c = '';
                                                                                            childCSSRecord.ElixirSuite__IMG_Default_Button_Label__c = '';
                                                                                            childCSSRecord.ElixirSuite__IMG_Type_of_Upload__c = 'Single';
                                                                                        }
                                                                                        /***********************************************************************************/
                                                                                    //    childCSSRecord.ElixirSuite__Account_Lookup_Fields__c = JSON.serialize((List<Object>) mapOfchildCSSRecord.get('accountLookupFieldLst')); 
                                                                                        // ADDING FORMULA ENABLED OBJECT - FIELD DETAILS 
                                                                                        if(String.isNotBlank(String.valueOf(mapOfchildCSSRecord.get('switchFormulaEnabled')))){
                                                                                            if(Boolean.valueOf(mapOfchildCSSRecord.get('switchFormulaEnabled'))){
                                                                                                List<String> objectLookupName = (String.valueOf(mapOfchildCSSRecord.get('selectedObjectForFormula'))).split(';');
                                                                                                if(objectLookupName.size()>0 && objectLookupName!=null){
                                                                                                    childCSSRecord.Map_object__c = objectLookupName[1];
                                                                                                    childCSSRecord.Object_lookup_Api__c =  objectLookupName[0];
                                                                                                }               
                                                                                                
                                                                                                childCSSRecord.Map_field__c =  String.valueOf(mapOfchildCSSRecord.get('selectedFieldForFormulaMapping'));
                                                                                                List<Object> lst = (List<Object>) mapOfchildCSSRecord.get('fieldListForFormulaMapping'); 
                                                                                                childCSSRecord.Object_Fields__c = JSON.serialize(lst);
                                                                                                
                                                                                            }
                                                                                            childCSSRecord.Formula_Map_Enabled__c = Boolean.valueOf(mapOfchildCSSRecord.get('switchFormulaEnabled')); 
                                                                                             childCSSRecord.ElixirSuite__Account_Lookup_API__c = String.valueOf(mapOfchildCSSRecord.get('accountLookupAPI'));
                                                                                                childCSSRecord.ElixirSuite__WHERE_clause_per_field__c = String.valueOf(mapOfchildCSSRecord.get('whereClause'));
                                                                                                childCSSRecord.ElixirSuite__Account_Lookup_Fields__c = JSON.serialize((List<Object>) mapOfchildCSSRecord.get('accountLookupFieldLst')); 
                                                                                                if(childCSSRecord.Map_object__c == 'Account' && String.isBlank(childCSSRecord.ElixirSuite__Account_Lookup_API__c)){
                                                                                                    childCSSRecord.ElixirSuite__Account_Lookup_API__c = 'Id';
                                                                                                   }
                                                                                        } 
                                                                                        
                                                                                        // Field type as CB OR RADIO handling
                                                                                        if(Boolean.valueOf(mapOfchildCSSRecord.get('isPicklistAsRadio'))){
                                                                                            childCSSRecord.Form_Data_Type__c = 'Radio';
                                                                                            if(Boolean.valueOf(mapOfchildCSSRecord.get('verticalAlignForRadio'))){
                                                                                                childCSSRecord.class__c = 'MultiVertical';
                                                                                            }
                                                                                            else {
                                                                                                childCSSRecord.class__c = '';
                                                                                            }
                                                                                        }
                                                                                        else if(Boolean.valueOf(mapOfchildCSSRecord.get('isMultiPicklistAsCheckbox'))){
                                                                                            childCSSRecord.Form_Data_Type__c = 'Checkbox';
                                                                                            if(Boolean.valueOf(mapOfchildCSSRecord.get('verticalAlignForMultiPicklist'))){
                                                                                                childCSSRecord.class__c = 'MultiVertical';
                                                                                            }
                                                                                            else {
                                                                                                childCSSRecord.class__c = '';
                                                                                            }
                                                                                            
                                                                                        }
                                                                                        else {
                                                                                            childCSSRecord.Form_Data_Type__c = 'Default';
                                                                                            childCSSRecord.class__c = '';
                                                                                        }
                                                                                        // External components data handling
                                                                                        if(Boolean.valueOf(mapOfCSSData.get('hasextCmp'))){
                                                                                            childCSSRecord.Form_Data_Type__c = String.valueOf(mapOfchildCSSRecord.get('selectedRecordType'));
                                                                                            
                                                                                        }
                                                                                        childCSSRecord.Is_RecordType_Selected__c = Boolean.valueOf(mapOfchildCSSRecord.get('recordTypeExists'));
                                                                                        // Saving depending upon the type of column selected. 
                                                                                        if(INTEGER.valueOf(mapOfCSSData.get('typeOfColumn')) == 2){
                                                                                            childCSSRecord.Column__c =  Integer.valueOf(mapOfchildCSSRecord.get('ColNumber'));
                                                                                            childCSSRecord.Row__c =  Integer.valueOf(mapOfchildCSSRecord.get('RowNumber'));
                                                                                        }
                                                                                        else {
                                                                                            childCSSRecord.Column__c =  1;
                                                                                            childCSSRecord.Row__c =  Integer.valueOf(mapOfchildCSSRecord.get('RowNumber'));
                                                                                        }
                                                                                        // Split for data type || Label || object Name and Api Names
                                                                                        if(String.valueOf(mapOfchildCSSRecord.get('selectedField')).contains(';')){
                                                                                            List<String> selectedFiledJunction = (String.valueOf(mapOfchildCSSRecord.get('selectedField'))).split(';');
                                                                                            if(selectedFiledJunction.size()>0 && selectedFiledJunction!=null) {
                                                                                                childCSSRecord.Data_Type__c =  selectedFiledJunction[1];
                                                                                                childCSSRecord.Field_Label_Long__c =  selectedFiledJunction[2];
                                                                                                childCSSRecord.Default_Field_Label__c = selectedFiledJunction[2]; // Label of field saved in a default field regardless of the external label
                                                                                                childCSSRecord.Field_Name__c =  selectedFiledJunction[0];
                                                                                                childCSSRecord.Object_Name__c = selectedFiledJunction[3];
                                                                                                
                                                                                                //Added by Vidish
                                                                                                
                                                                                                if(String.valueOf(childCSSRecord.Data_Type__c).equalsIgnoreCase('REFERENCE')){
                                                                                                    String refObjectName = childCSSRecord.Object_Name__c;
                                                                                                    String refFieldName = childCSSRecord.Field_Name__c;
                                                                                                    Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();       
                                                                                                    Schema.SObjectType leadSchema = schemaMap.get(refObjectName);        
                                                                                                    Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
                                                                                                   // List<String> fieldApiAndFieldTypeMap = new  List<String>();
                                                                                                    for (String fieldName: fieldMap.keySet()) {
                                                                                                        if(fieldName == refFieldName){
                                                                                                            Schema.DescribeFieldResult f = fieldMap.get(fieldName).getDescribe();
                                                                                                            // Schema.DescribeFieldResult f = leadSchema.getDescribe().fields.fieldName; 
                                                                                                            for(Schema.SObjectType reference : f.getReferenceTo()) {
                                                                                                                refObjectName = reference.getDescribe().getName(); 
                                                                                                                childCSSRecord.Reference_to_object__c = refObjectName;
                                                                                                            }
                                                                                                            
                                                                                                            
                                                                                                            //Schema.DescribeFieldResult f = Schema.sObjectType.ElixirSuite__Object_2__c.fields.ElixirSuite__Case__c;
                                                                                                        }
                                                                                                    }
                                                                                                }
                                                                                                // Ended by vidish
                                                                                                
                                                                                                if(allRecordsForMatch.contains(selectedFiledJunction[0])){
                                                                                                    if(Boolean.valueOf(mapOfchildCSSRecord.get('isCommon'))){ // ENGAGE IS COMMON UPDATE ONLY IF THE FIELD IS SELECTED AS ICOMMON FROM CONFIG SCREEN
                                                                                                        childCSSRecord.IsCommon__c = true;
                                                                                                        allFieldNameRecordsToUpdate.add(selectedFiledJunction[0]);
                                                                                                    }
                                                                                                    else {
                                                                                                        childCSSRecord.IsCommon__c = false;
                                                                                                    }
                                                                                                }
                                                                                            }
                                                                                        }
                                                                                            else{
                                                                                            childCSSRecord.Data_Type__c =  '';
                                                                                            childCSSRecord.Field_Label_Long__c =  '';
                                                                                            childCSSRecord.Default_Field_Label__c = ''; // This else block is to handle None in selected fields
                                                                                            childCSSRecord.Field_Name__c =  '';
                                                                                            childCSSRecord.Object_Name__c = '';
                                                                                        }
                                                                                        // set external custom label if opted for the same.
                                                                                        if(String.isNotBlank(String.valueOf(mapOfchildCSSRecord.get('defaultLabel')))){
                                                                                            childCSSRecord.Default_Label_Filled__c = true;
                                                                                            childCSSRecord.Field_Label_Long__c = String.valueOf(mapOfchildCSSRecord.get('defaultLabel'));                            
                                                                                        }
                                                                                        else {
                                                                                            childCSSRecord.Default_Label_Filled__c = false;
                                                                                            
                                                                                        }
                                                                                        
                                                                                        toUpdateChildrecords.add(childCSSRecord);
                                                                                    }
                                                                                    // }
                                                                                } 
                                                                            }
                                                                            
                                                                        }
                                                                    }
                                                                    toUpdateParentrecords.add(newCSSRecord);
                                                                }
                                                            }
                                                            // Parent Update
                                                            if(toUpdateParentrecords.size()>0 && toUpdateParentrecords!=null){
                                                                //update toUpdateParentrecords;
                                                                DMLManager.updateAsUser(toUpdateParentrecords);
                                                            }    
                                                            // Child Update
                                                            if(toUpdateChildrecords.size()>0 && toUpdateChildrecords!=null){
                                                                DMLManager.updateAsUser(toUpdateChildrecords);
                                                                //update toUpdateChildrecords;
                                                            }
                                                            
                                                            //upsert tableToInsertRecords; // update the existing records and insert new records if table is manipulated
                                                            DMLManager.upsertAsUser(tableToInsertRecords);
                                                            
                                                            //delete [SELECT ID FROM Object_1_css__c WHERE ID IN : tableRecordsToDel WITH SECURITY_ENFORCED]; // delte the table records because table was updated from screen and cells were reduced
                                                            // Delete records for table
                                                            DMLManager.deleteAsUser([SELECT ID FROM Object_1_css__c WHERE ID IN : tableRecordsToDel WITH SECURITY_ENFORCED]);
                                                        
                                                            DMLManager.deleteAsUser([SELECT ID FROM Object_1_css__c WHERE Object_1_css__c IN : tableToDeleteRecords AND ElixirSuite__Is_matrix__c = TRUE WITH SECURITY_ENFORCED]);
                                                            DMLManager.deleteAsUser ([SELECT ID FROM Object_1_css__c WHERE Object_1_css__c IN : tableCounterToDeleteRecords AND ElixirSuite__Select_Form_Component__c != 'Enable Table' WITH SECURITY_ENFORCED]);
                                                            DMLManager.deleteAsUser ([SELECT ID FROM Object_1_css__c WHERE Object_1_css__c IN : modularTableRecordsDel AND  ElixirSuite__Select_Form_Component__c != 'Enable Modular Table' WITH SECURITY_ENFORCED]);
                                                            
                                                            // insert table records
                                                            
                                                            
                                                            
                                                            // Child Delete if updated from non-consent to consent (Only non consent child will be deleted)
                                                            if(parentRecordChildToBeDeleted.size()>0 && parentRecordChildToBeDeleted!=null){
                                                                List<String> recToDelete = new List<String>();
                                                                for(Object_1_css__c rec : [SELECT ID,Is_Consent__c from Object_1_css__c 
                                                                                            where Object_1_css__c in : parentRecordChildToBeDeleted
                                                                                            WITH SECURITY_ENFORCED]){
                                                                                                if(rec.Is_Consent__c == false){
                                                                                                    recToDelete.add(rec.Id);
                                                                                                }
                                                                                            }
                                                                                            DMLManager.deleteAsUser([SELECT ID FROM Object_1_css__c WHERE ID IN : recToDelete]);
                                                            }
                                                            DMLManager.deleteAsUser([SELECT ID FROM Object_1_css__c  WHERE Object_1_css__c IN : macroChildToBeDeleted]);
                                                            
                                                            // delete parent section records if delete from edit screen
                                                            if(parentSectiondelList.size()>0 && parentSectiondelList!=null){
                                                                DMLManager.deleteAsUser([SELECT ID from Object_1_css__c where Id in : parentSectiondelList WITH SECURITY_ENFORCED]);
                                                            }
                                                            // DELETE CHILD RECORDS OF CONSENT PARENT RECORD IF IT WAS CONVERTED FROM CONSENT TO NON - CONSENT
                                                            List<String> toDeleteRecords = new List<String>();
                                                            List<Object_1_css__c> recordsLst = [SELECT ID,(SELECT ID,Is_Consent__c FROM Object_1_css__r) FROM Object_1_css__c  WHERE Id IN : isRecordConsent
                                                                                                WITH SECURITY_ENFORCED];
                                                            if(recordsLst.size()>0 && recordsLst!=null){
                                                                
                                                                for(Object_1_css__c rec : recordsLst){
                                                                    for(Object_1_css__c child : rec.Object_1_css__r){
                                                                        if(child.Is_Consent__c){
                                                                            toDeleteRecords.add(child.Id);
                                                                        } 
                                                                    }
                                                                    
                                                                }
                                                            }
                                                            DMLManager.deleteAsUser([SELECT ID FROM Object_1_css__c WHERE ID IN : toDeleteRecords WITH SECURITY_ENFORCED]);
                                                            // IS COMMON RECORDS UPDATE
                                                            isCommonLogicUpdateEngine(allFieldNameRecordsToUpdate);
                                                        }
                                                        catch(Exception e){
                                                            ExceptionLog.logError(e);
                                                        }
                                                        
                                                        
                                                    }
    public static void isCommonLogicUpdateEngine(List<String> isCommonUpdate){
        
        // IS COMMON UPDATE 
        List<Object_1_css__c> lstToUpdate = new List<Object_1_css__c>();
        for(Object_1_css__c recToUpdate : [SELECT ID,Is_Common_Parent__c 
                                            FROM Object_1_css__c where Field_Name__c in : isCommonUpdate
                                            WITH SECURITY_ENFORCED]){
                                                recToUpdate.Is_Common_Parent__c = true;
                                                lstToUpdate.add(recToUpdate);
                                            }
                                            DMLManager.updateAsUser(lstToUpdate);                                     
        //update lstToUpdate;
    }
    @AuraEnabled
    public static Map<String,String> fetchobjectRecordTypes(String objectName){
        Map<String,String> recordTypeApiAndLabel = new Map<String,String>();
        if(objectName == 'ElixirSuite__Medical_Examination__c' || objectName == 'Medical_Examination__c'){
            recordTypeApiAndLabel.put('Allergy','Allergy');
            recordTypeApiAndLabel.put('Glucose','Glucose');
            recordTypeApiAndLabel.put('Vital_Sign','Vital Sign');
        }
        else {
            objectName = 'ElixirSuite__'+objectName;
            Map<String, Schema.SObjectType> m = Schema.getGlobalDescribe() ;
            
            Schema.SObjectType s = m.get(objectName) ;
            Schema.DescribeSObjectResult cfrSchema = s.getDescribe() ;
            Map<ID,Schema.RecordTypeInfo> recordTypeInfo = cfrSchema.getRecordTypeInfosByID();
            Map<id, Schema.RecordTypeInfo> recordTypeByIdMap = recordTypeInfo;
            if(recordTypeByIdMap.size()>1){
                for(String r:recordTypeByIdMap.keySet())
                {    
                    //   if(recordTypeByIdMap.get(r).getDeveloperName().endsWith('_extCmp')){
                    recordTypeApiAndLabel.put(recordTypeByIdMap.get(r).getDeveloperName(),recordTypeByIdMap.get(r).getName());
                    //  }
                    
                }   
            }
        }
        return recordTypeApiAndLabel;
    }
    public class FormsConfigurationWrapperForEditScreen{
        @AuraEnabled public Map<String, String> mapOfContainer; 
        @AuraEnabled public Map<String, String> mapOfInventory;
        @AuraEnabled    public Map<String,Object_1_css__c[]> mapOfApprovalRecord = new Map<String,Object_1_css__c[]>();
        @AuraEnabled    public  List<Object_1_css__c> allParentSections{ get; set; }
        @AuraEnabled    public  List<Object_1_css__c> allChildRelatedobjects{ get; set; }  
        @AuraEnabled    public  List<Object_1_css__c> allFormsAsRecords{ get; set; }  
        @AuraEnabled    public FormsConfigurationWrapper dataForSavedRecordType{ get; set; }  
        @AuraEnabled    public FormsConfigurationWrapper allRecordTypesOfMDTObject{ get; set; }  
        @AuraEnabled    public  Map<String,String> objectLabelApiName{ get; set; }  
        @AuraEnabled    public  Map<String,String> accountChildObject{ get; set; }
        @AuraEnabled    public  Map<String,String> objectFields{ get; set; }
        @AuraEnabled    public List<Essential_Lookup_Fields__mdt> essentialLookupFields{ get; set; }
        @AuraEnabled    public List<ApprovalLevelForForms__c> totalApprovalLevel{ get; set; }
        @AuraEnabled    public Map<String,String> isConsent_AllAccountFields{ get; set; }
        @AuraEnabled    public Map<String,String> isConsent_AllUserFields{ get; set; }
        
        
    }
    @AuraEnabled 
    public static void deleteSavedForm(String formName){
        DMLManager.deleteAsUser([SELECT ID from ElixirSuite__Object_1_css__c where ElixirSuite__Form__c = : formName]); 
    }
    @AuraEnabled    
    public static void deleteAllForms(List < String > lstRecordId) {
        DMLManager.deleteAsUser([SELECT ID from ElixirSuite__Object_1_css__c where ElixirSuite__Form__c IN : lstRecordId]);              
    }
    @AuraEnabled
    public static List<String> doesFieldExist(String objName, string fieldName,List<String> fieldApiNames)
    {
        List<Form_Object__mdt> allObjectNames = [select Object_Name__c from Form_Object__mdt WHERE Object_Name__c!=NULL WITH SECURITY_ENFORCED];
        List<String> objectNamesByApi = new  List<String>();
        Map<String,String> labelApicombo = new   Map<String,String>();
        for(Form_Object__mdt recordInstance : allObjectNames){
            if(String.isNotBlank(recordInstance.Object_Name__c)){
                objectNamesByApi.addAll(recordInstance.Object_Name__c.split(';'));  
            }
            
        }
        for(String obj : objectNamesByApi){
            labelApicombo.putAll(fetchFieldsForSelectedObject(obj));
        }
        
        return new List<String>(labelApicombo.keySet()); 
    } 
    public class FieldsValidityWrapper{
        @AuraEnabled    public  Boolean isAnyFieldBad{ get; set; }
        @AuraEnabled    public  String dirtyField{ get; set; }
        @AuraEnabled    public   Set<String> objectFields{ get; set; }
    }
    @AuraEnabled
    public static void falseCallBack(){
    }
    //Method Added by Vidish
    public static Boolean checkFormulaField(String objectName, String fieldToCheck){
        Boolean isformula = false;
        String selectedObject = Account.sObjectType.getDescribe().getName();
        
        //selectedObject = childCSSRecord.Object_Name__c;
        selectedObject = objectName;
        
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType objectSchema = schemaMap.get(selectedObject);
        Map<String, Schema.SObjectField> fieldMap = objectSchema.getDescribe().fields.getMap();
        for (String fieldName: fieldMap.keySet()){  
            Schema.DescribeFieldResult df  =  fieldMap.get(fieldName).getDescribe();
            if (df.isCalculated() &&  df.getCalculatedFormula() != null ) {
                if(String.valueOf(fieldToCheck).equalsIgnoreCase(fieldName)){
                  
                    isformula = true;
                }
               
            }  
        }
        return isformula;
    }
    
    @AuraEnabled
    public static void setFormActivationStatus(List<String> formNames, Boolean status){
        try {
            // Fetch section 1 of forms provided in formNames,
            // Form activation/deactivation is determined a boolean(ElixirSuite__isActive__c) in section 1 
            List<Object_1_css__c> section1Records = [SELECT ElixirSuite__Form__c, Id, ElixirSuite__Section_Number__c, ElixirSuite__isActive__c FROM ElixirSuite__Object_1_css__c WHERE ElixirSuite__Section_Number__c = 1 AND ElixirSuite__Form__c IN :formNames WITH SECURITY_ENFORCED];
    
            for (Object_1_css__c section1 : section1Records) { 
                section1.ElixirSuite__isActive__c = status; 
            }
    
            //update section1Records;
            DMLManager.updateAsUser(section1Records);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static void toggleVisitNoteSetting(List<String> formNames, String enableAs) {
        List<ElixirSuite__Object_1_css__c> recordsToUpdate = new List<ElixirSuite__Object_1_css__c>();
        
        for (ElixirSuite__Object_1_css__c section1 : [SELECT ElixirSuite__Form__c, Id, ElixirSuite__Section_Number__c, ElixirSuite__Enable_As__c
                                                      FROM ElixirSuite__Object_1_css__c 
                                                      WHERE ElixirSuite__Section_Number__c = 1 AND ElixirSuite__Form__c IN :formNames 
                                                      WITH SECURITY_ENFORCED]) {
                                                          section1.ElixirSuite__Enable_As__c = enableAs;
                                                          recordsToUpdate.add(section1);
                                                      }
        
        if (!recordsToUpdate.isEmpty()) {
            try {
                DMLManager.updateAsUser(recordsToUpdate);
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
        }
    }



    @AuraEnabled
    public static void deployForm(String formName, String formId) {
        ElixirOEM_FormDeploy.deployForm(formName, formId);
    }
    
    @AuraEnabled
    public static List<String> getAllImageNamesInStaticResource(){
        try {
            List<StaticResource> allImageInStaticResource = [
                SELECT Name 
                    FROM StaticResource
                    WHERE ContentType LIKE 'Image/%'
                    WITH SECURITY_ENFORCED
            ];
    
            List<String> allImageNamesInStaticResource = new List<String>();
            for (StaticResource sr : allImageInStaticResource) {
                allImageNamesInStaticResource.add(sr.Name);
            }
    
            return allImageNamesInStaticResource;
    
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    
    }
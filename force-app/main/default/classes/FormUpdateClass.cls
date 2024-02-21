/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-16-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class FormUpdateClass { 
    
    public class NewProblemWrapper{
        @AuraEnabled
        public String problemColumns;
        @AuraEnabled
        public Map<String,String> mapRequiredFields;
        @AuraEnabled
        public Map<String,String> mapDataTypeToApi;
    }

    @AuraEnabled
    public static NewProblemWrapper getProblemColumns1(){
        NewProblemWrapper w = new NewProblemWrapper();
        String selectedObject = 'ElixirSuite__Dataset1__c' ;
       
       Map<String, String> dataTypeToApi = new Map<String, String>();
        Map<String,String> labelToApi = new Map<String,String>();  
        try {
            
            Map <String,Schema.SObjectType> gd = Schema.getGlobalDescribe();
            Schema.SObjectType sobjType = gd.get(selectedObject);
            Schema.DescribeSObjectResult r = sobjType.getDescribe();
            Map<String, Schema.SObjectField> MapofField = r.fields.getMap();
            
            for(String fieldName : MapofField.keySet()) {
                Schema.SObjectField field = MapofField.get(fieldName);
                Schema.DescribeFieldResult F = field.getDescribe();
                // Get data type of the field
        		String fieldType = String.valueOf(F.getType());
                 // Get API name of the field
        		String fieldApiName = String.valueOf(field);
                String fi = String.valueOf(field);
                System.debug('field-->'+field);
                labelToApi.put(String.valueOf(F.getLabel()),String.valueOf(field));
                // Map data type to API name
        		dataTypeToApi.put(fieldApiName, fieldType);
            }
            // Now, dataTypeToApi map contains data types as keys and API names as values
   			 System.debug('DataTypeToApi Map: ' + dataTypeToApi);
            
            Elixir_Custom_Setting__c mc = Elixir_Custom_Setting__c.getOrgDefaults();
            w.problemColumns = mc.ElixirSuite__Problem_Column__c;
            w.mapRequiredFields = labelToApi;
            w.mapDataTypeToApi=dataTypeToApi;
            return w;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static newWrapper getDiagnosisColumns1(){
        newWrapper w = new newWrapper();
        String selectedObject = 'ElixirSuite__ICD_Codes__c' ;
       
       Map<String, String> dataTypeToApi = new Map<String, String>();
        Map<String,String> labelToApi = new Map<String,String>();  
        try {
            
            Map <String,Schema.SObjectType> gd = Schema.getGlobalDescribe();
            Schema.SObjectType sobjType = gd.get(selectedObject);
            Schema.DescribeSObjectResult r = sobjType.getDescribe();
            Map<String, Schema.SObjectField> MapofField = r.fields.getMap();
            
            for(String fieldName : MapofField.keySet()) {
                Schema.SObjectField field = MapofField.get(fieldName);
                Schema.DescribeFieldResult F = field.getDescribe();
                // Get data type of the field
        		String fieldType = String.valueOf(F.getType());
                 // Get API name of the field
        		String fieldApiName = String.valueOf(field);
                String fi = String.valueOf(field);
                System.debug('field-->'+field);
                labelToApi.put(String.valueOf(F.getLabel()),String.valueOf(field));
                // Map data type to API name
        		dataTypeToApi.put(fieldApiName , fieldType);
            }
            // Now, dataTypeToApi map contains data types as keys and API names as values
   			 System.debug('DataTypeToApi Map: ' + dataTypeToApi);
            
            Elixir_Custom_Setting__c mc = Elixir_Custom_Setting__c.getOrgDefaults();
            w.diagnosisColumns = mc.ElixirSuite__Diagnosis_Column__c;
            w.mapRequiredFields = labelToApi;
            w.mapDataTypeToApi=dataTypeToApi;
            return w;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    
    public class newWrapper{
        @AuraEnabled
        public String diagnosisColumns;
        @AuraEnabled
        public Map<String,String> mapRequiredFields;
        @AuraEnabled
        public Map<String,String> mapDataTypeToApi;
    }
    
      @AuraEnabled
public static List<ElixirSuite__ICD_Codes__c> fetchAccountDiagnosis(String acctId,String formUniqueId) {
    String activeCareEpisodeId = getActiveCareEpisodeId(acctId);
    Boolean careEpisodeBasedFilter = getCustomSettingBooleanValue();
    
    String objectName = 'ElixirSuite__ICD_Codes__c';
    Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();

    String query = 'SELECT ';
    for (String fieldName : fieldMap.keySet()) {
        query += fieldName + ', ';
    }
    // Remove the trailing comma and space
    query = query.removeEnd(', ');
    
    // Add the subquery for related records (ElixirSuite__Diagnosis_Codes__r)
    query += ', (SELECT Id, Name, ElixirSuite__Account_Id__c, ElixirSuite__Care_Episode__c, ' +
             'ElixirSuite__Code_Description__c, ElixirSuite__Problem__c, ElixirSuite__Problem__r.Name, ' +
             'ElixirSuite__Diagnosis_Code__c FROM ElixirSuite__Diagnosis_Codes__r) ';

    query += ' FROM ' + objectName + ' WHERE ElixirSuite__Form_Value__r.ElixirSuite__Form_Id__c = \'' + String.escapeSingleQuotes(formUniqueId) + '\'';

    if (String.isNotBlank(activeCareEpisodeId) && careEpisodeBasedFilter == true) {
        query += ' AND ElixirSuite__Care_Episode__c = \'' + String.escapeSingleQuotes(activeCareEpisodeId) + '\'';
    }

    query += ' WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC';

    // Execute the dynamic query
    List<ElixirSuite__ICD_Codes__c> queryResults = Database.query(query);

    System.debug('Dynamic Query: ' + query);
    System.debug('Query Results: ' + queryResults);

    return queryResults;
}
    
    @AuraEnabled
    public static String getActiveCareEpisodeId(String accountId) {
        try {
            List<ElixirSuite__Visits__c> allCareEpisodes = [
                SELECT
                Id
                FROM
                ElixirSuite__Visits__c
                WHERE
                ElixirSuite__Account__c = :accountId
                AND
                ElixirSuite__Status__c = 'Active'
                WITH 
                SECURITY_ENFORCED
                ORDER BY
                CreatedDate DESC];
            
            if (allCareEpisodes != null && allCareEpisodes.size() > 0) {
                return allCareEpisodes[0].Id;
            }
            
            return '';   
        } catch (Exception e) {
            ExceptionLog.logError(e);
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static Boolean getCustomSettingBooleanValue() {
        try {
            ElixirSuite__Elixir_Custom_Setting__c customSetting = ElixirSuite__Elixir_Custom_Setting__c.getOrgDefaults();
            
            if (customSetting.ElixirSuite__Care_Episode_based_filtering_for_Notes__c) {
                return customSetting.ElixirSuite__Care_Episode_based_filtering_for_Notes__c;
            } else {
                return false; // Default value if custom setting instance is not found
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
     @AuraEnabled
    public static List<ElixirSuite__Dataset1__c> fetchAccountProblems(String acctId,String formUniqueId){ 
        List<ElixirSuite__Dataset1__c> problemList = new List<ElixirSuite__Dataset1__c>();
        String activeCareEpisodeId = getActiveCareEpisodeId(acctId);
        Boolean careEpisodeBasedFilter = getCustomSettingBooleanValue();
        String objectName = 'ElixirSuite__Dataset1__c';
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
        
        Set<String> excludedFields = new Set<String>{'ownerid', 'isdeleted', 'recordtypeid', 'createdbyid', 
            'lastmodifiedbyid', 'systemmodstamp', 'lastactivitydate'};
            
            String query = 'SELECT ';
        for (String fieldName : fieldMap.keySet()) {
            if (!excludedFields.contains(fieldName)) {
                query += fieldName + ', ';
            }
        }
        query = query.removeEnd(', ');
        query += ' FROM ' + objectName + ' WHERE ElixirSuite__Form_Value__r.ElixirSuite__Form_Id__c = \'' + String.escapeSingleQuotes(formUniqueId) + '\'';
        if (String.isNotBlank(activeCareEpisodeId) && careEpisodeBasedFilter == true) {
            query += ' AND ElixirSuite__Care_Episode__c = \'' + String.escapeSingleQuotes(activeCareEpisodeId) + '\'';
        }

        query += ' WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC';
        problemList = Database.query(query);
        return problemList;
    }
    
    @AuraEnabled
    public static string getProblemsColumns(){
        try {
            Elixir_Custom_Setting__c mc = Elixir_Custom_Setting__c.getOrgDefaults();
            return mc.ElixirSuite__Problem_Column__c;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static Boolean submitToProvider(String formName, String formUniqueId){
        Map<String,String> formIdNameMap = new Map<String,String>{'formId'=>formUniqueId,'formName'=>formName};
            List<Map<String,String>> formIdNameListMap = new List<Map<String,String>>();
        formIdNameListMap.add(formIdNameMap);
        Boolean isSubmitted  = false;
        Boolean isApprovalDone = Elixir_NewAccountAssociatedFormsApex.getApprovalAndSignatureData(formIdNameListMap);
        UpdateFormForPortal.updateFormWhenPatientStartsFillingOnPortal(formUniqueId);
        if(!isApprovalDone){
            Elixir_NewAccountAssociatedFormsApex.submitSelectedFormsToEHRFromPortal(formIdNameListMap);
            
            isSubmitted = true;
            List<ElixirSuite__Form_Value__c> formValLSt = [SELECT ID,ElixirSuite__Status__c FROM ElixirSuite__Form_Value__c
                                                           WHERE Form_Id__c = : formUniqueId AND ElixirSuite__Form_Detail__c = true with security_enforced];
            
            if(formValLSt!=null && formValLSt.size()>0){
                for(ElixirSuite__Form_Value__c obj : formValLSt){
                    obj.ElixirSuite__Status__c = 'Completed';
                    obj.ElixirSuite__Form_Portal_Status__c = 'Submitted to Provider';
                }
                DMLManager.updateAsUser(formValLSt);
               // update formValLSt;
                
            } 
            
            
        }
        
        return isSubmitted;
    }
    @AuraEnabled
    public static FormSchema buildForm(String formName, String accountId, String formUniqueId){
        FormSchema form;
        Map<String, sObject> objToValues = new Map<String, sObject>();
        List<Contact> conList = new List<Contact>();
        Map<String,List<string>> formTemplateToContactMap = new Map<String,List<String>>();
        List<Id> formTemplateIds = new List<Id>();
        Id currentUserId = UserInfo.getUserId();
        Elixir_Custom_Setting__c val = Elixir_Custom_Setting__c.getOrgDefaults();
        String contactRecType = val.ElixirSuite__Practitioner_Contact_Recordtype__c;
        Id practitionerRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(contactRecType).getRecordTypeId();
        
        List<Form_Template__c> mdt1 = new List<Form_Template__c>();
      
        
        String labelstoShow; 
        Map<String,List<String>> objectToFieldsMap = new Map<String,List<String>>();
        Map<String, sObject> objToData = new Map<String, sObject>();
        List<Object_1_css__c> cssRecords = new List<Object_1_css__c>();
        List<ElixirSuite__Inventory__c> invRecords = new List<ElixirSuite__Inventory__c>();
        List<Form_Value__c> autoTextFormValues= new List<Form_Value__c>();
        List<Form_Template__c> mdt = new List<Form_Template__c>();
        List<Form_Template_Data__c> mdtData = new List<Form_Template_Data__c>();
        List<Form_Template_Data__c> problemNoteData = new List<Form_Template_Data__c>();
        List<Form_Template_Data__c> diagnosisNoteData = new List<Form_Template_Data__c>();
        List<Form_Template_Data__c> procedureNoteData = new List<Form_Template_Data__c>();
        List< ElixirSuite__Form_Value__c> modularMatrixData = new List< ElixirSuite__Form_Value__c>();
        List< ElixirSuite__Form_Value__c> fetchFlag = new List< ElixirSuite__Form_Value__c>();
        Map<Id,sObject> formCssToFxValue = new Map<Id,sObject>();

        Map<String, sObject> consentData = new Map<String, sObject>(); 
        
        if(
                ElixirSuite__Inventory__c.SObjectType.getDescribe().isAccessible() &&
                Schema.SObjectType.ElixirSuite__Inventory__c.fields.ElixirSuite__Account__c.isAccessible() &&
                Schema.SObjectType.ElixirSuite__Inventory__c.fields.ElixirSuite__Inventory_Item_Name__c.isAccessible()&&
                Schema.SObjectType.ElixirSuite__Inventory__c.fields.ElixirSuite__Lot_Number__c.isAccessible()&&
                Schema.SObjectType.ElixirSuite__Inventory__c.fields.ElixirSuite__Units_Available__c.isAccessible()&&
                Schema.SObjectType.ElixirSuite__Inventory__c.fields.ElixirSuite__Units_Procured__c.isAccessible()
                
               
            ) {
                invRecords = [Select ElixirSuite__Account__c,ElixirSuite__Inventory_Item_Name__c,ElixirSuite__Total_Price__c,ElixirSuite__Lot_Number__c,ElixirSuite__Units_Available__c,ElixirSuite__Units_Procured__c,ElixirSuite__Form_Unique_Id__c from ElixirSuite__Inventory__c where ElixirSuite__Account__c=:accountId and ElixirSuite__Form_Unique_Id__c=:formUniqueId ];
            }

        //system.debug(formName);
        List<FormRenderUtility.FieldSchema> allFields = new List<FormRenderUtility.FieldSchema>();
        Set<String> qualifiedFormObjects = FormRenderUtility.fetchObjects(formName);//All Objects that have this Form.
        if(qualifiedFormObjects!=null && qualifiedFormObjects.size()>0){
            FormRenderUtility.objFieldSchema  objSchema = FormRenderUtility.fetchFields(qualifiedFormObjects, objectToFieldsMap, formName);
            objectToFieldsMap = objSchema.objectToFieldsMap;
            allFields = objSchema.fieldSchemas;
            cssRecords = [SELECT Id,Css__c,Indentation__c,Class__c,Section_Name__c,ElixirSuite__Default_Inventory_Type__c,ElixirSuite__Lot_Number__c,Form_Specific_Data__c,parent_query__c,ElixirSuite__Add_Problem__c,
                          Auto_text__c,Enable_Auto_text__c,Hide_Selections__c,Form_Category__c, Default_text__c,isFormMacro__c,ElixirSuite__Add_Procedure__c,
                          Map_query__c, Section_Number__c, Is_Consent__c, Columns_In_Section__c,Object_Name__c,ElixirSuite__Is_Time_Enabled__c,
                          Is_matrix__c, Columns_Matrix__c, Headings__c,Consent_Query__c,Add_Notes__c, Type_of_Note__c,Static_file_name__c,
                          Select_Form_Component__c,
                          (SELECT Id,Map_object__c,Class__c,Map_field__c,IsCommon__c,Object_Name__c,Is_Consent__c,Default_text__c, 
                           Field_Name__c, Form__c, Object_1_css__c, Field_Label_Long__c,Data_Type__c,No_Label__c,
                           Is_Common_Parent__c,Css__c,Form_Specific_Data__c,Row__c,Column__c,Form_Data_Type__c,
                           IMG_Default_Button_Label__c, IMG_File_Name__c, IMG_Type_of_Upload__c,IMG_Type_of_Row__c,
                           Is_matrix__c, Columns_Matrix__c, Headings__c,Is_formula_Field__c,Reference_to_object__c,Static_file_name__c
                           FROM Object_1_css__r                                                                                                                                                                                              
                           ORDER BY Row__c,Column__c ASC) FROM Object_1_css__c WHERE
                          Form__c =:formName AND Section_Number__c!=NULL AND Section_Number__c!=0 
                          WITH SECURITY_ENFORCED
                          ORDER BY Section_Number__c ASC];
            
            mdt1  = [select id,Form_Label__c,Form_Description__c,Select_Forms__c from Form_Template__c 
                    where Active__c = true AND Select_Forms__c INCLUDES (:formName)  WITH SECURITY_ENFORCED order by Form_Label__c asc];
            for(Form_Template__c formTmp : mdt1)
            {
                formTemplateIds.add(formtmp.id);
            }
            conList = [Select id,ElixirSuite__Practitioner_User__c,ElixirSuite__Form_Template__c from contact where recordtypeid =: practitionerRecordTypeId and ElixirSuite__Form_Template__c in : formTemplateIds  WITH SECURITY_ENFORCED];
            
            for(Contact con : conList)
            {
                List<String> userList = new List<String>();
                if(formTemplateToContactMap.get(con.ElixirSuite__Form_Template__c) != null)
                {
                    
                    formTemplateToContactMap.get(con.ElixirSuite__Form_Template__c).add(con.ElixirSuite__Practitioner_User__c);
                    
                }
                else
                {
                    
                    userList.add(con.ElixirSuite__Practitioner_User__c);
                    
                    formTemplateToContactMap.put(con.ElixirSuite__Form_Template__c, userList);
                }
            
                }
            
            for(Form_Template__c formTemplate : mdt1)
            {
                if((formTemplateToContactMap.get(formTemplate.id) != null && (formTemplateToContactMap.get(formTemplate.id).contains(currentUserId) || formTemplateToContactMap.get(formTemplate.id).size()==0 ) )|| (formTemplateToContactMap.get(formTemplate.id) == null))
                {
                    mdt.add(formTemplate);
                }
            }
            
            
            mdtData = [select id, name,Form_Unique_Id__c,Section_Number__c,Form_Data_Description__c,ElixirSuite__Type__c
                       FROM Form_Template_Data__c WHERE account__c=: accountId AND Form_Unique_Id__c= :formUniqueId AND ElixirSuite__Type__c='Macro'
                       WITH SECURITY_ENFORCED
                       ORDER BY Section_Number__c ASC];
            problemNoteData = [select id, name,Form_Unique_Id__c,Section_Number__c,Form_Data_Description__c,ElixirSuite__Type__c
                       FROM Form_Template_Data__c WHERE account__c=: accountId AND Form_Unique_Id__c= :formUniqueId AND ElixirSuite__Type__c='Problem'
                       WITH SECURITY_ENFORCED
                       ORDER BY Section_Number__c ASC];
            diagnosisNoteData = [select id, name,Form_Unique_Id__c,Section_Number__c,Form_Data_Description__c,ElixirSuite__Type__c
                       FROM Form_Template_Data__c WHERE account__c=: accountId AND Form_Unique_Id__c= :formUniqueId AND ElixirSuite__Type__c='Diagnosis'
                       WITH SECURITY_ENFORCED
                       ORDER BY Section_Number__c ASC];
            procedureNoteData = [select id, name,Form_Unique_Id__c,Section_Number__c,Form_Data_Description__c,ElixirSuite__Type__c
                       FROM Form_Template_Data__c WHERE account__c=: accountId AND Form_Unique_Id__c= :formUniqueId AND ElixirSuite__Type__c='Procedure'
                       WITH SECURITY_ENFORCED
                       ORDER BY Section_Number__c ASC];

            modularMatrixData = [
                SELECT Id, ElixirSuite__Modular_Matrix_Data_JSON__c
                  FROM ElixirSuite__Form_Value__c
                 WHERE ElixirSuite__Form_Id__c = :formUniqueId
                   AND ElixirSuite__Has_Modular_Matrix_Data__c = true
                  WITH SECURITY_ENFORCED
            ];
            fetchFlag = [SELECT Id, ElixirSuite__Is_old__c, ElixirSuite__Is_Approver__c,Approval_Level__c
                        FROM ElixirSuite__Form_Value__c
                        WHERE ElixirSuite__Form_Id__c = :formUniqueId
                        AND ElixirSuite__Is_old__c = true
                        WITH SECURITY_ENFORCED ];

            
            // Query whether patient mode for forms is checked or not
            Boolean isPatientModeEnabled = Elixir_Custom_Setting__c.getOrgDefaults().Patient_Mode_For_Forms__c;

            if(cssRecords!=null && cssRecords.size()>0){
                consentData = FormRenderUtility.getQueryDataConsent(cssRecords[0], accountId, UserInfo.getUserId());
                autoTextFormValues = [SELECT Id, Section_Number__c, Blue_Print__c, Account__c,Form_Id__c, Auto_text__c, Is_AutoText__c FROM Form_Value__c 
                                      WHERE Is_AutoText__c=true AND Account__c=: accountId AND Form_Id__c= :formUniqueId 
                                      WITH SECURITY_ENFORCED
                                      ORDER BY Section_Number__c ASC];
                
                objToData = FormRenderUtility.getObjectFormData(cssRecords[0], accountId); // added by himanshu
                
                formCssToFxValue = FormRenderUtility.getFxData(formName, accountId); // added by himanshu
                
                List<sObject> sObj = new List<sObject>();
                for(String obj :objectToFieldsMap.keySet()){
                    Integer flag = 0;
                    sObject so = Schema.getGlobalDescribe().get(obj).newSObject();
                    for(String fld :so.getSobjectType().getDescribe().fields.getMap().keySet()){
                        if(fld.endsWithIgnoreCase('Form_unique_id__c')){
                            flag = 1;
                            break;
                        }
                    }
                    if(flag == 0){
                        continue;
                    }
                    String fields = String.join(objectToFieldsMap.get(obj),',');
                    String objQuery = 'SELECT '  +string.escapeSingleQuotes(fields)+ ' FROM ' + string.escapeSingleQuotes(obj) + ' WHERE Form_unique_id__c =:formUniqueId AND AccountId__c =:accountId LIMIT 1';
                    sObj = Database.query(objQuery);
                    if(sObj.size()>0){
                        objToValues.put(obj, sObj[0]);
                    }
                }   
                // Form label fetch - START
                Elixir_Custom_Setting__c labelObject = Elixir_Custom_Setting__c.getOrgDefaults();
                if(labelObject!=null){
                    String labelObjOriginal = labelObject.Form_Label__c;
                    if(String.isNotBlank(labelObjOriginal)){
                        List<String> objs = labelObjOriginal.split(';');
                        for(Integer i=objs.size()-1; i>-1; i--){
                            String labelObj = objs[i];
                            List<sObject> labelExistsOrNot = Database.query('SELECT Id,Label__c, Label_Length__c FROM '+string.escapeSingleQuotes(labelObj)+ ' WHERE FormId__c=:formUniqueId AND AccountId__c=:accountId'); 
                            //System.debug(labelExistsOrNot);
                            if(labelExistsOrNot!=null && labelExistsOrNot.size()>0){
                                if(String.isNotBlank(String.valueOf(labelExistsOrNot[0].get('Label__c')))){
                                    labelstoShow = String.valueOf(labelExistsOrNot[0].get('Label__c'));
                                }
                            }
                        }
                    }
                }
                // Form label fetch - END
                // Consent Value - START
                Map<Decimal, Map<Decimal, List<Form_Value__c>>> sec_row_columns = new Map<Decimal, Map<Decimal, List<Form_Value__c>>>();
                List<Form_Value__c> DBconsentValues = [SELECT Id, Field_Api_Name__c,Section_Number__c,Row_Number__c,Column_Number__c,
                                                       Consent_Text__c,Consent_Default_text__c,Consent_Input_JSON__c,Consent_Pdf__c,
                                                       Blue_Print__c,Default1__c, Account__c,Only_text_in_consent__c FROM Form_Value__c 
                                                        WHERE Account__c =:accountId 
                                                        AND Field_Api_Name__c=NULL
                                                        AND Form_Id__c= :formUniqueId 
                                                        AND Is_AutoText__c=false 
                                                        AND Section_Number__c!=NULL
                                                        AND Is_Consent__c=TRUE
                                                        WITH SECURITY_ENFORCED
                                                        ORDER BY CreatedDate ASC LIMIT 9999]; 
                if(DBconsentValues!=null && DBconsentValues.size()>0){
                    for(Form_Value__c rec :DBconsentValues){
                            if(sec_row_columns.containsKey(rec.Section_Number__c)){
                                Map<Decimal, List<Form_Value__c>> row_columns = sec_row_columns.get(rec.Section_Number__c);
                                if(row_columns.containsKey(rec.Row_Number__c)){
                                    row_columns.get(rec.Row_Number__c).add(rec);
                                }else{
                                    row_columns.put(rec.Row_Number__c, new List<Form_Value__c> {rec});
                                }
                            }else{
                                Map<Decimal, List<Form_Value__c>> row_columns = new Map<Decimal, List<Form_Value__c>>();
                                row_columns.put(rec.Row_Number__c, new List<Form_Value__c> {rec});
                                sec_row_columns.put(rec.Section_Number__c, row_columns);
                            }
                    }
                }
                //collect content document ids from form value
                List<ContentVersion> allUploadedImages;
                List<ElixirSuite__Form_Value__c> fvList = [SELECT Id,ElixirSuite__Account__c,ElixirSuite__Form_Id__c,ElixirSuite__Form_Detail__c,ElixirSuite__AttachmentIds__c FROM ElixirSuite__Form_Value__c WHERE ElixirSuite__Form_Id__c =: formUniqueId AND ElixirSuite__Form_Detail__c = TRUE WITH SECURITY_ENFORCED];
                
                if(fvList != null && !fvList.isEmpty() && String.isNotBlank(fvList[0].ElixirSuite__AttachmentIds__c)){
                    List<String> documentIds = fvList[0].ElixirSuite__AttachmentIds__c.split(';');
                    allUploadedImages = [SELECT Id,Form_Id__c, File_Name__c, Unique_File_Name__c, 
                                         Sequence_Number__c, ContentDocumentId, FileType
                                         FROM ContentVersion
                                         WHERE ContentDocumentId IN : documentIds AND Unique_File_Name__c!=NULL ORDER BY Sequence_Number__c];
                }
                else{
                    allUploadedImages = [SELECT Id,Form_Id__c, File_Name__c, Unique_File_Name__c, 
                                         Sequence_Number__c, ContentDocumentId, FileType
                                         FROM ContentVersion
                                         WHERE Form_Id__c= :formUniqueId AND Unique_File_Name__c!=NULL ORDER BY Sequence_Number__c];
                }
                
                Map<String,List<ContentVersion>> versionBasedOnUniqueName = new Map<String,List<ContentVersion>>();
                if(allUploadedImages!=null && allUploadedImages.size()>0){
                    for(ContentVersion version :allUploadedImages){
                        if(versionBasedOnUniqueName.containsKey(version.Unique_File_Name__c)){
                            List<ContentVersion> versions = versionBasedOnUniqueName.get(version.Unique_File_Name__c);
                            versions.add(version);
                        }else{
                            versionBasedOnUniqueName.put(version.Unique_File_Name__c, new List<ContentVersion>{version});
                        }
                    }
                }
                // Consent Value - END

                Map<String, Boolean> sectionHasUploadedImage = new Map<String, Boolean>();

                // for sections in cssRecords
                for (Object_1_css__c section : cssRecords) {
                    // check if section contains 'upload and annotate' component
                    if (section.Select_Form_Component__c == 'Enable Upload And Annotate') {
                        // populate sectionHasUploadedImage with section ID as key and whether section has uploaded image as value(true/false)
                        sectionHasUploadedImage.put(
                            section.Id, 
                            containsUploadedImage(accountId, formUniqueId, section.Id)
                        );
                    }
                }
                
                List<Form_Value__c> formDefaultValues = new List<Form_Value__c>([SELECT Id, Default1__c, Account__c, Field_Api_Name__c,Only_text_in_consent__c
                                                                                 FROM Form_Value__c 
                                                                                 WHERE Account__c =:accountId AND Form_Id__c=NULL AND ElixirSuite__Field_Api_Name__c!=NULL 
                                                                                 WITH SECURITY_ENFORCED
                                                                                 LIMIT 999]);
                
                ElixirSuite__Procedure__c procedureOfForm = fetchTimingsAsProcedure(accountId,formUniqueId);
                form = new FormSchema(cssRecords, objToValues, allFields, sec_row_columns, labelstoShow, autoTextFormValues, versionBasedOnUniqueName,mdt,mdtData,
                                      problemNoteData,diagnosisNoteData,procedureNoteData,consentData, isPatientModeEnabled, sectionHasUploadedImage,
                                      procedureOfForm,invRecords, modularMatrixData,fetchFlag, formCssToFxValue, objToData, formDefaultValues);
                form.AccountName = [SELECT Id, Name FROM Account WITH SECURITY_ENFORCED LIMIT 1].Name;
            }
        }
        return form;
    } 
    public static ElixirSuite__Procedure__c fetchTimingsAsProcedure(String accountId,String formId){
        ElixirSuite__Procedure__c p = new ElixirSuite__Procedure__c();
        ElixirSuite__Procedure__c[] pLst = [SELECT ID,ElixirSuite__Start_Time__c,ElixirSuite__End_Time__c FROM ElixirSuite__Procedure__c
                                            WHERE ElixirSuite__Form_Unique_ID__c = : formId AND ElixirSuite__Account__c = : accountId WITH SECURITY_ENFORCED];
        if(pLst!=null && pLst.size()>0){
            p = pLst[0];
        }
        return p;
    }
    @AuraEnabled  
    public static List<user> UinfoNew(){
        ID UID =UserInfo.getUserId();
        List<User> lst_user = new List<User>();
        lst_user =[select id,ElixirSuite__Verification_Code_New__c from user where id =:UID 
        WITH SECURITY_ENFORCED
        LIMIT 1];
        return lst_user;
    }

    //added by Anmol for LX3-5770
    @AuraEnabled
    public static String fetchNameSpace() {
         String namespace = Elixir_Utility.getNamespace() ;
        return namespace;
    }
    //end by Anmol for LX3-5770

    //Added by Anmol for LX3-6263
    @AuraEnabled
    public static String fetchCustomSettingsPrescription() {
         String prescVal;
            ID UID =UserInfo.getProfileId();
         List<ElixirSuite__TabPermissionBasedOnProfiles__c> tb = [SELECT Id, ElixirSuite__Prescription_Priority__c 
                                                            FROM ElixirSuite__TabPermissionBasedOnProfiles__c where SetupOwnerId = :UID WITH SECURITY_ENFORCED LIMIT 1];

        if(tb!=null && tb.size()>0){

            prescVal = tb[0].ElixirSuite__Prescription_Priority__c ;
        }

        return prescVal;
    }
    //End by Anmol for LX3-6263

    
    @AuraEnabled
    public static Boolean saveForm(String accountId, String formName, String changedFormName, String cssRecords, String formUniqueId, String objNameToValue,
                                String problemData, String precriptionData,List<String> deletedProblem,List<String> toDelProblemFromUpdate,String toUpdateProblem,
                                Boolean isProblemEnabled,String procedureWrapper,String timeWrapper,Boolean isTimeEnabled,Boolean isClone,Boolean isDeceased, 
                                String modularMatrixData, String fetchFlag,Boolean formSubmitToProvider){
                                    try{
                                        if(String.isNotBlank(procedureWrapper)){
                                            ElixirOEM_ProcedureOnForms.procedureDataOnForm(procedureWrapper,accountId);
                                        }
                                        if(deletedProblem!=null && deletedProblem.size()>0){
                                            MasterProblemListController.deleteAllProbelm(deletedProblem);
                                        }
                                        if(toDelProblemFromUpdate!=null && toDelProblemFromUpdate.size()>0){
                                            MasterProblemListController.deleteAllProbelm(toDelProblemFromUpdate);
                                        }
                                        if(String.isNotBlank(toUpdateProblem)){ 
                                            MasterProblemListController.problemInsertFromForm(toUpdateProblem,accountId);
                                        }    
                                        try{
                                            if(!formSubmitToProvider)
                                            UpdateFormForPortal.updateFormWhenPatientStartsFillingOnPortal(formUniqueId);
                                        }
                                        catch(Exception e){
                                            ExceptionLog.logError(e);
                                        }
                                        Map<String, String> sectionIdToImage = new Map<String,String>();
                                        List<String> commonFields = new List<String>();
                                        Account changeAccount = new Account();
                                        List<Form_Value__c> defaultValuesSaveObject = new List<Form_Value__c>();
                                        List<Form_Value__c> consentValues = new List<Form_Value__c>();
                                        //Text generation Attributes - START
                                        List<Form_Value__c> ValueForAutoText = new List<Form_Value__c>();
                                        //for macros
                                        Boolean isMacroTemp = false ;
                                        Boolean isProblemNoteTemp = false;
                                        Boolean isDiagnosisNoteTemp = false;
                                        Boolean isProcedureNoteTemp = false;
                                        Id recordTypeId = Schema.SObjectType.ElixirSuite__Procedure__c.getRecordTypeInfosByDeveloperName().get('Patient_Procedure').getRecordTypeId();
                                        //String objNameForExtCmp;
                                        Set<String> sectionNumberForMacro = new Set<String>();
                                        List<Form_Template_Data__c> valueForMacroData = new List<Form_Template_Data__c>();
                                        //end for macros
                                        
                                        //added by Anmol for Inventory
                                        //List<ElixirSuite__Inventory__c> lstInsInv = new List<ElixirSuite__Inventory__c >();
                                        //List<ElixirSuite__Inventory__c> lstDelInv = new List<ElixirSuite__Inventory__c >();
                                        //List<ElixirSuite__Inventory__c> lstUpdInv = new List<ElixirSuite__Inventory__c >();
                                        List<Object> inventoryLst = new  List<Object>();
                                        boolean invCheck = false;
                                        
                                        //boolean dmlInsCheck;
                                        //boolean dmlDelCheck;
                                        //boolean dmlUpdCheck;
                                        //end by Anmol for Inventory

                                         //added by Anmol for LX3-6259
                                        String prescriptionLst;
                                        String selUser;
                                        String selVia;
                                        String startTm;
                                        String endTm;
                                        //boolean presCheck = false;
                                    //end by Anmol for LX3-6259

                                        List<Form_Template_Data__c> valueForProblemNoteData = new List<Form_Template_Data__c>();
                                        Set<String> sectionNumberForProblemNote = new Set<String>();
                                        List<Form_Template_Data__c> valueForDiagnosisNoteData = new List<Form_Template_Data__c>();
                                        Set<String> sectionNumberForDiagnosisNote = new Set<String>();
                                        List<Form_Template_Data__c> valueForProcedureNoteData = new List<Form_Template_Data__c>();
                                        Set<String> sectionNumberForProcedureNote = new Set<String>();
                                        
                                        Set<Integer> sectionNos = new Set<Integer>();
                                        //Text generation Attributes - END
                                        Map<String, sObject> objectNameToRecords = new Map<String, sObject>();
                                        Map<String, Map<String,String>> objectNameToApiNameAndLabel = new Map<String, Map<String,String>>();
                                        Map<String, Object> deserializedRecords = (Map<String, Object>) JSON.deserializeUntyped(cssRecords);
                                        List<Object> sections = (List<Object>) deserializedRecords.get('cssRecords');
                                        if(sections != null){
                                            for(Object section :sections){
                                                Map<String, Object> record = (Map<String, Object>) section; 
                                                //Text Generation - START 
                                                String autoText = (String) record.get('AutoText');
                                                Boolean isAutoText = (Boolean) record.get('ElixirSuite__Enable_Auto_text__c'); 
                                                //FOR MACRO TEMPLATE
                                                Boolean isMacroTemplate = (Boolean) record.get('ElixirSuite__isFormMacro__c');
                                                String macroData = String.valueOf(record.get('formMacro'));
                                                String problemNoteData = String.valueOf(record.get('problemNote'));
                                                List<Object> problemListFromNote = (List<Object>) record.get('problemNoteList');
                                                String diagnosisNoteData = String.valueOf(record.get('diagnosisNote'));
                                                String selectFormComp = String.valueOf(record.get('ElixirSuite__Select_Form_Component__c'));
                                                List<Object> diagnosisListFromNote = (List<Object>) record.get('diagnosisList');
                                                String procedureNoteData = String.valueOf(record.get('procedureNote'));
                                                List<Object> procedureListFromNote = (List<Object>) record.get('procedureList');
                                                if(selectFormComp == 'Enable Inventory Order'){
                                                    invCheck = true;
                                                }
                                                if(invCheck){
                                                if(inventoryLst != null && inventoryLst.isEmpty()){
                                                inventoryLst = (List<Object>) record.get('inventoryLst');
                                                }
                                            }
                                                 //added by Anmol for LX3-6259
                                                 if(String.isBlank(prescriptionLst) && String.isBlank(selUser) && String.isBlank(selVia) && String.isBlank(startTm) && String.isBlank(endTm)){
                                                     prescriptionLst = String.valueOf(record.get('prescLst'));
                                                     selUser = String.valueOf(record.get('selectedUser'));
                                                     selVia = String.valueOf(record.get('selectedVia'));
                                                     startTm = String.valueOf(record.get('starttime'));
                                                     endTm = String.valueOf(record.get('endtime'));
                                                         }
                                                   //end by Anmol for LX3-6259
                                                String imgData = (String) record.get('ImageData');
                                                String sectionId = (String) record.get('Id');            
                                                if(String.isNotBlank(sectionId) && String.isNotBlank(imgData)){
                                                      sectionIdToImage.put(sectionId, imgData);
                                                }

                                                List<ElixirSuite__Dataset1__c> listAbc = new List<ElixirSuite__Dataset1__c>();
                                                if(problemListFromNote != null && problemListFromNote.size()>0){
                                                    
                                                    for(Object sObj_loop : problemListFromNote){
                                                        Map<String, Object> obj_Record_Parent = ( Map<String, Object>) sObj_loop; 
                                                        ElixirSuite__Dataset1__c abc = new ElixirSuite__Dataset1__c();
                                                        abc.Name = String.valueof(obj_Record_Parent.get('FieldName'));
                                                        abc.ElixirSuite__Account__c = accountId;
                                                        abc.ElixirSuite__Description__c = String.valueof(obj_Record_Parent.get('Description'));
                                                        
                                                        listAbc.add(abc);
                                                        
                                                    }
                                                   // if (Schema.sObjectType.ElixirSuite__Dataset1__c.isCreateable()) {
                                                        DMLManager.insertAsUser(listAbc);
                                                   // insert listAbc ;
                                               // }
                                            }
                                                List<ElixirSuite__ICD_Codes__c> diagnosisList = new List<ElixirSuite__ICD_Codes__c>();
                                                   if(diagnosisListFromNote != null && diagnosisListFromNote.size()>0){
                                                      
                                                      for(Object sObj_loop : diagnosisListFromNote){
                                                          Map<String, Object> obj_Record_Parent = ( Map<String, Object>) sObj_loop; 
                                                          ElixirSuite__ICD_Codes__c abc = new ElixirSuite__ICD_Codes__c();
                                                          abc.Name = String.valueof(obj_Record_Parent.get('FieldName'));
                                                        //  abc.ElixirSuite__Account__c = accountId;
                                                          abc.ElixirSuite__Code_Description1__c = String.valueof(obj_Record_Parent.get('Description'));
                                                          
                                                          diagnosisList.add(abc);
                                                         
                                                      }
                                                      //if (Schema.sObjectType.ElixirSuite__ICD_Codes__c.isCreateable()){
                                                        DMLManager.insertAsUser(diagnosisList);
                                                         // insert diagnosisList ;
                                                  //}
                                                }
                                                
                                                List<ElixirSuite__Procedure__c> procedureList = new List<ElixirSuite__Procedure__c>();
                                                   if(procedureListFromNote != null && procedureListFromNote.size()>0){
                                                      
                                                      for(Object sObj_loop : procedureListFromNote){
                                                          Map<String, Object> obj_Record_Parent = ( Map<String, Object>) sObj_loop; 
                                                          ElixirSuite__Procedure__c abc = new ElixirSuite__Procedure__c();
                                                          abc.Name = String.valueof(obj_Record_Parent.get('FieldName'));
                                                          abc.ElixirSuite__Account__c = accountId;
                                                          abc.RecordTypeId = recordTypeId ;
                                                          abc.ElixirSuite__Code_Description__c = String.valueof(obj_Record_Parent.get('Description'));
                                                          
                                                          procedureList.add(abc);
                                                         
                                                      } //if (Schema.sObjectType.ElixirSuite__Procedure__c.isCreateable()) {
                                                        //DMLManager.insertAsUser(procedureList);
                                                       // insert procedureList ;
                                                 // }
                                                }

                                               //boolean changeUnit;
                                               
                                               

                                                //Text Generation - END
                                                if(String.isNotBlank(macroData) && isMacroTemplate ){
                                                    isMacroTemp = true;
                                                    Integer sectionNo1 = (Integer) record.get('ElixirSuite__Section_Number__c');
                                                    ElixirSuite__Form_Template_Data__c fdata = new ElixirSuite__Form_Template_Data__c();
                                                    fData.ElixirSuite__Form_Data_Description__c = macroData;
                                                    fData.ElixirSuite__Section_Number__c = String.valueOf(sectionNo1);
                                                    fData.ElixirSuite__Type__c = 'Macro';
                                                    
                                                    valueForMacroData.add(fdata);
                                                    
                                                    sectionNumberForMacro.add(String.valueOf(sectionNo1)); 
                                                }
                                                
                                                if(String.isNotBlank(problemNoteData) ){
                                                    
                                                    isProblemNoteTemp = true;
                                                    Integer sectionNo1 = (Integer) record.get('ElixirSuite__Section_Number__c');
                                                    ElixirSuite__Form_Template_Data__c fdata1 = new ElixirSuite__Form_Template_Data__c();
                                                    fData1.ElixirSuite__Form_Data_Description__c = problemNoteData;
                                                    fData1.ElixirSuite__Section_Number__c = String.valueOf(sectionNo1);
                                                    fData1.ElixirSuite__Type__c = 'Problem';
                                                    
                                                    valueForProblemNoteData.add(fdata1);
                                                    sectionNumberForProblemNote.add(String.valueOf(sectionNo1)); 
                                                }
                                                
                                                 if(String.isNotBlank(diagnosisNoteData) ){
                                                      
                                                      isDiagnosisNoteTemp = true;
                                                      Integer sectionNo1 = (Integer) record.get('ElixirSuite__Section_Number__c');
                                                      ElixirSuite__Form_Template_Data__c fdata1 = new ElixirSuite__Form_Template_Data__c();
                                                      fData1.ElixirSuite__Form_Data_Description__c = diagnosisNoteData;
                                                      fData1.ElixirSuite__Section_Number__c = String.valueOf(sectionNo1);
                                                      fData1.ElixirSuite__Type__c = 'Diagnosis';
                                                      
                                                      valueForDiagnosisNoteData.add(fdata1);
                                                      sectionNumberForDiagnosisNote.add(String.valueOf(sectionNo1)); 
                                                  }
                                                if(String.isNotBlank(procedureNoteData) ){
                                                      
                                                      isProcedureNoteTemp = true;
                                                      Integer sectionNo1 = (Integer) record.get('ElixirSuite__Section_Number__c');
                                                      ElixirSuite__Form_Template_Data__c fdata2 = new ElixirSuite__Form_Template_Data__c();
                                                      fData2.ElixirSuite__Form_Data_Description__c = procedureNoteData;
                                                      fData2.ElixirSuite__Account__c = accountId;
                                                      fData2.ElixirSuite__Section_Number__c = String.valueOf(sectionNo1);
                                                      fData2.ElixirSuite__Type__c = 'Procedure';
                                                      
                                                      valueForProcedureNoteData.add(fdata2);
                                                      sectionNumberForProcedureNote.add(String.valueOf(sectionNo1)); 
                                                  }
                                                
                                                List<Object> rows = (List<Object>) record.get('ElixirSuite__Object_1_css__r');
                                                if(rows != null){
                                                    //system.debug(rows);
                                                    for(Object row : rows){
                                                        Map<String, Object> rowMap = (Map<String, Object>) row; 
                                                        List<Object> columns = (List<Object>) rowMap.get('Columns');
                                                        sObject sObj;
                                                        if(columns != null && columns.size()>0){
                                                            //system.debug(columns);
                                                            for(Object column : columns){
                                                                Map<String, Object> columnMap = (Map<String, Object>) column; 
                                                                Integer secNo = Integer.valueOf(record.get('ElixirSuite__Section_Number__c'));
                                                                Integer rowNo = Integer.valueOf(columnMap.get('ElixirSuite__Row__c'));
                                                                Integer columnNo = Integer.valueOf(columnMap.get('ElixirSuite__Column__c'));
                                                                
                                                                String objectName = String.valueOf(columnMap.get('ElixirSuite__Object_Name__c'));

                                                                if(objectName == 'ONLYTEXT'){
                                    								continue;
                                								}

                                                                String fieldName = String.valueOf(columnMap.get('ElixirSuite__Field_Name__c'));
                                                                //String fullLabel = String.valueOf(columnMap.get('ElixirSuite__Default_text__c'));
                                                                String fieldLabel = String.valueOf(columnMap.get('ElixirSuite__Field_Label_Long__c'));
                                                                if((String.isBlank(fieldName) || String.isBlank(objectName) || objectName == 'undefined') && !Boolean.valueOf(columnMap.get('ElixirSuite__Is_Consent__c'))){
                                                                    continue;
                                                                }
                                                                if(Boolean.valueOf(columnMap.get('ElixirSuite__Is_Consent__c'))){                             
                                                                    FormRenderUtility.populateConsentValue(fieldName, columnMap, consentValues,
                                                                                                           secNo, rowNo, columnNo, accountId,isClone);  
                                                                    continue;
                                                                }
                                                                //Map creation For Label Saving - START
                                                                if(String.isNotBlank(fieldLabel)){
                                                                    if(!Boolean.valueOf(columnMap.get('ElixirSuite__Is_Consent__c'))){
                                                                        //FormLabelClass.createMapOfLabel(objectNameToApiNameAndLabel, objectName, fieldName, fieldLabel);
                                                                    }
                                                                }
                                                                //Map creation For Label Saving - END
                                                                //system.debug(columnMap);
                                                                //FOR Saving Forms - START
                                                                if(objectNameToRecords.containsKey(objectName.toLowerCase())){
                                                                    sObj = objectNameToRecords.get(objectName.toLowerCase());
                                                                    FormRenderUtility.populateValue(sObj, defaultValuesSaveObject, accountId,
                                                                                                    commonFields, fieldName, columnMap, changeAccount);    
                                                                }else{
                                                                    //system.debug(objectName);
                                                                    //system.debug(!Boolean.valueOf(columnMap.get('ElixirSuite__Is_Consent__c')));
                                                                    sObj = Schema.getGlobalDescribe().get(objectName).newSObject();       
                                                                    FormRenderUtility.populateValue(sObj, defaultValuesSaveObject, accountId,
                                                                                                    commonFields, fieldName, columnMap, changeAccount);
                                                                    objectNameToRecords.put(objectName.toLowerCase(), sObj);
                                                                }
                                                                //FOR Saving Forms - END
                                                            }
                                                        }
                                                    } 
                                                }  
                                            }
                                            if(valueForMacroData.size()>0){
                                                FormRenderClass.saveMacroData(accountId, formUniqueId, sectionNumberForMacro, valueForMacroData);
                                            }
                                            if(valueForProblemNoteData.size()>0){
                                                FormRenderClass.saveProblemNoteData(accountId, formUniqueId, sectionNumberForProblemNote, valueForProblemNoteData);
                                            }
                                            if(valueForDiagnosisNoteData.size()>0){
                                                FormRenderClass.saveDiagnosisNoteData(accountId, formUniqueId, sectionNumberForDiagnosisNote, valueForDiagnosisNoteData);
                                            }
                                            if(valueForProcedureNoteData.size()>0){
                                               FormRenderClass.saveProcedureNoteData(accountId, formUniqueId, sectionNumberForProcedureNote, valueForProcedureNoteData);
                                                  }
                                        }
                                        //system.debug(objectNameToRecords);
                                        //Object To Form Id For Update - START
                                        Map<String,String> objNameToRecId = new Map<String,String>();
                                        Map<String, Object> deserializedObjNameToValue = (Map<String, Object>) JSON.deserializeUntyped(objNameToValue);
                                        for(String objName :deserializedObjNameToValue.keySet()){
                                            Map<String, Object> record = (Map<String, Object>) deserializedObjNameToValue.get(objName);
                                            //system.debug(record);
                                            if(record.containsKey('Id')){
                                                objNameToRecId.put(objName.toLowerCase(), String.valueOf(record.get('Id')));
                                            }
                                        }
                                        
                                        //Object To Form Id For Update - START
                                        if(objectNameToRecords.size()>0){
                                            List<RecordType> recordTypes = [SELECT Id, Name, SobjectType FROM RecordType WHERE SobjectType IN :objectNameToRecords.keySet()
                                                                            AND Name =:formName WITH SECURITY_ENFORCED];
                                            Map<String,Id> objectNameToFormId = new Map<String,Id>();
                                            if(recordTypes!=null && recordTypes.size()>0){
                                                for(RecordType rec : recordTypes){
                                                    objectNameToFormId.put(rec.SobjectType.toLowerCase(), rec.Id);
                                                }
                                                //upsert objectNameToRecords.values();
                                                String idToCreateNumberUnique = String.valueOf(objectNameToRecords.values()[0].get('Id'));
                                                Integer uniqueIdFromRandomNo = FormRenderClass.generateRandomNumber();
                                                if(isClone){
                                                    formUniqueId = String.valueOf(idToCreateNumberUnique) + ';' + String.valueOf(uniqueIdFromRandomNo); 
                                                }
                                                //system.debug('formUniqueId '+formUniqueId);
                                                for(String objName :objectNameToRecords.keySet()){
                                                    
                                                    String objCaseInsensitive = objName.toLowerCase();
                                                    if(objectNameToFormId.containsKey(objCaseInsensitive)){
                                                        if(objNameToRecId.containsKey(objCaseInsensitive) && !isClone){//If we do Not have Id to this saved object, then its INSERT
                                                            objectNameToRecords.get(objCaseInsensitive).put('Id',objNameToRecId.get(objCaseInsensitive));
                                                        }
                                                        if(isClone){
                                                            objectNameToRecords.get(objName).put('Form_unique_id__c',formUniqueId);
                                                        }
                                                        objectNameToRecords.get(objCaseInsensitive).put('RecordTypeId', objectNameToFormId.get(objCaseInsensitive));
                                                        objectNameToRecords.get(objCaseInsensitive).put('AccountId__c', accountId);
                                                        objectNameToRecords.get(objCaseInsensitive).put('Form_Name__c', changedFormName);
                                                    }
                                                } 
                                                upsert objectNameToRecords.values();
                                                if(valueForMacroData.size()>0){
                                                    FormRenderClass.saveMacroData(accountId, formUniqueId, sectionNumberForMacro, valueForMacroData);
                                                }
                                                if(valueForProblemNoteData.size()>0){
                                                    FormRenderClass.saveProblemNoteData(accountId, formUniqueId, sectionNumberForProblemNote, valueForProblemNoteData);
                                                }
                                                if(valueForDiagnosisNoteData.size()>0){
                                                    FormRenderClass.saveDiagnosisNoteData(accountId, formUniqueId, sectionNumberForDiagnosisNote, valueForDiagnosisNoteData);
                                                }
                                                if(valueForProcedureNoteData.size()>0){
                                                    FormRenderClass.saveProcedureNoteData(accountId, formUniqueId, sectionNumberForProcedureNote, valueForProcedureNoteData);
                                                }
                                                if(isClone == true){
                                                    FormRenderClass.attachCareEpisode(formUniqueId, accountId, changedFormName);
                                                }

                                                 //added by Anmol for Lx3-6230
                                                 FormRenderClass.attachInventory(formUniqueId, accountId, inventoryLst);
                                                 //end by Anmol for Lx3-6230

                                                 //System.debug('formName***'+formName);
                                                   if(formName == 'Session Notes'){
                                                   FormUpdateClass.updateIndividualNote(formUniqueId, accountId);
                                                   }

                                                  //added by Anmol for Lx3-6259
                                                FormRenderClass.attachPrescription(formUniqueId, accountId, prescriptionLst,selUser,selVia,startTm,endTm);
                                                //end by Anmol for Lx3-6259
                                                
                                                //Whenever form gets editing the status goes to IN Progress START- Nithin 
                                               //system.debug('formUniqueId '+formUniqueId);
                                                if(isClone == false){
                                                    List<Form_Value__c> status = [Select ElixirSuite__Care_Episode__r.ElixirSuite__Status__c,ElixirSuite__Status__c 
                                                                            from ElixirSuite__Form_Value__c 
                                                                            where ElixirSuite__Form_Id__c =:formUniqueId and Is_CareEpisode__c = true
                                                                           WITH SECURITY_ENFORCED];
                                                    List<Form_Value__c> totalValue = [select id,ElixirSuite__Form_Id__c,ElixirSuite__Approval_Level__c,ElixirSuite__Approved_Signature__c , 
                                                                                      ElixirSuite__Is_old__c,ElixirSuite__Is_Approver__c
                                                                                      from ElixirSuite__Form_Value__c
                                                                                      where ElixirSuite__Form_Id__c =:formUniqueId AND ElixirSuite__Is_old__c!= true 
                                                                                      AND ElixirSuite__Is_Approver__c =true WITH SECURITY_ENFORCED];
                                                    
                                                    List<Form_Value__c> statusop =[Select Id, ElixirSuite__Status__c 
                                                                                    from ElixirSuite__Form_Value__c 
                                                                                    where ElixirSuite__Form_Id__c =:formUniqueId and ElixirSuite__Form_Detail__c = true
                                                                                WITH SECURITY_ENFORCED];
                                                    if(status != null & status.size() > 0){
                                                        if(status[0].ElixirSuite__Care_Episode__r.ElixirSuite__Status__c == 'Reopened' && totalValue.size() == 0){
                                                            for(Form_Value__c statusvalue : statusop){
                                                                statusvalue.ElixirSuite__Status__c = 'In Progress';
                                                            }
                                                          //  if (Schema.sObjectType.Form_Value__c.isUpdateable()){
                                                                DMLManager.updateAsUser(statusop);
                                                               // update statusop;
                                                          //  }
                                                            
                                                        }
                                                    }
                                                }
                                                // END
                                                
                                                //FORM-OBJECT data passing - END
                                                changeAccount.Id = accountId;
                                                
                                                try{
                                                    if (Schema.sObjectType.Account.isUpdateable()){
                                                  //  update changeAccount;
                                                    }
                                                }
                                                catch(Exception e){
                                                    ExceptionLog.logError(e);
                                                }
                                                //FORM-OBJECT data passing - END
                                                
                                                //Text Generation - START
                                                if(ValueForAutoText.size()>0){
                                                    FormRenderClass.saveAutoText(accountId, formUniqueId, sectionNos, ValueForAutoText);
                                                }
                                                //Text Generation - END
                                                
                                                
                                                
                                                //FORM_FORM DATA SAVING - START
                                                if(defaultValuesSaveObject.size()>0){
                                                    saveDefaultValues(accountId, commonFields, JSON.serialize(defaultValuesSaveObject));// SAVE FORM-FORM values
                                                }
                                                //FORM_FORM DATA SAVING - END
                                                FormLabelClass.saveLabel(objectNameToApiNameAndLabel, accountId, formUniqueId);//Utility to save Label         
                                            }
                                        }

                                        //CONSENT VALUES - START
                                                if(consentValues!=null && consentValues.size()>0){
                                              
                                                    //System.debug('outer consentValues: ' + consentValues);
                                                    for(Form_Value__c rec :consentValues){
                                                        rec.Form_Id__c = formUniqueId;
                                                    }
                                                   // if (Schema.sObjectType.Form_Value__c.isUpdateable()&&

                                                   // Schema.sObjectType.Form_Value__c.isCreateable()) {
                                                    //System.debug('outer consentValues: ' + consentValues);
                                                    DMLManager.upsertAsUser(consentValues);
                                                   // upsert consentValues;
                                              //  }
                                            }
                                         //CONSENT VALUES - END
                                               
                                        if(sectionIdToImage.size()>0){
                                            saveImages(sectionIdToImage, accountId, formUniqueId);
                                      }
                                        /* PRESCRIPTION88*/
                                        if(String.isNotBlank(precriptionData)){
                                            Map<String, Object> deserializedPrescriptionRecords = (Map<String, Object>) JSON.deserializeUntyped(precriptionData);
                                            //Object selectedUser= (Object) deserializedPrescriptionRecords.get('selectedUser');
                                            //Object selectedVia = (Object)  deserializedPrescriptionRecords.get('selectedVia');
                                            Object medicationJSON = (Object) deserializedPrescriptionRecords.get('medicationJSON');
                                            if(String.isNotBlank(String.valueOf(medicationJSON))){
                                                SelectionMedicationRecordsApexController.saveData(String.valueOf(medicationJSON),'','',accountId,String.valueOf(system.today()),String.valueOf(System.today()),formUniqueId);
                                            }
                                            if(isTimeEnabled){
                                                handleTimeDataOnForm(formUniqueId,accountId,timeWrapper,changedFormName);
                                            }
                                        }
                                        //System.debug('is modular matrix data empty: ' + String.isBlank(modularMatrixData));
                                        if (!String.isBlank(modularMatrixData)) {

                                            ElixirSuite__Form_Value__c modularMatrixDataRecord = [SELECT Id, ElixirSuite__Modular_Matrix_Data_JSON__c
                                                                                                    FROM ElixirSuite__Form_Value__c
                                                                                                   WHERE ElixirSuite__Form_Id__c = :formUniqueId
                                                                                                     AND ElixirSuite__Has_Modular_Matrix_Data__c = true
                                                                                                    WITH SECURITY_ENFORCED];
                                            
                                            modularMatrixDataRecord.ElixirSuite__Modular_Matrix_Data_JSON__c = modularMatrixData;
                                           // if (Schema.sObjectType.ElixirSuite__Form_Value__c.isUpdateable()&&

                                           // Schema.sObjectType.ElixirSuite__Form_Value__c.isCreateable()) {
                                                DMLManager.upsertAsUser(modularMatrixDataRecord);
                                           // upsert modularMatrixDataRecord;
        }

                                      //  }
                                    }catch(Exception e){
                                        ExceptionLog.logError(e);
                                        throw new AuraHandledException(e.getMessage());
                                    }
                                    List<Account> accList = [select id,ElixirSuite__Deceased__c from Account where id=:accountId WITH SECURITY_ENFORCED];
                                    isDeceased = accList[0].ElixirSuite__Deceased__c;
                                    return isDeceased;
                                }
    public static void handleTimeDataOnForm(String formUniqueId, String accountId,String timeWrapper,string changedFormName){
        Map<String, Object> deserializedTimeRecords = (Map<String, Object>) JSON.deserializeUntyped(timeWrapper);  
        ElixirSuite__Procedure__c[] pLst = [SELECT ID,ElixirSuite__Start_Time__c,ElixirSuite__End_Time__c FROM ElixirSuite__Procedure__c
                                            WHERE ElixirSuite__Form_Unique_ID__c = : formUniqueId AND ElixirSuite__Account__c = : accountId  WITH SECURITY_ENFORCED];
        if(pLst!=null && pLst.size()>0){
            pLst[0].ElixirSuite__Start_Time__c = FormRenderClass.compileCleanDateTime('startTime',deserializedTimeRecords);
            pLst[0].ElixirSuite__End_Time__c = FormRenderClass.compileCleanDateTime('startTime',deserializedTimeRecords);
            if(Boolean.valueOf(deserializedTimeRecords.get('paramSame'))){
                pLst[0].ElixirSuite__End_Time__c = pLst[0].ElixirSuite__Start_Time__c.addMinutes(1); 
            }
            if(Boolean.valueOf(deserializedTimeRecords.get('setEndTimeAsCurrent'))){
                pLst[0].ElixirSuite__End_Time__c = System.now();
            }
          //  if (Schema.sObjectType.ElixirSuite__Procedure__c.isUpdateable()){
                DMLManager.updateAsUser(pLst);
            //update pLst; 
       // }
    }
         
        
        
                                }


                                public static void updateIndividualNote(String formUniqueId, String accountId){
        
                                    Set<String> metadataObjects = new Set<String>();
                                    List<ContentNote> lstContentNote = new List<ContentNote>();
                                    List<ContentNote> parentLstContentNote = new List<ContentNote>();
                                    List<ContentNote> parentDelLstContentNote = new List<ContentNote>();
                                    String parentEventId;
                                    String grpNote='';
                                    Boolean delCntNote=false;
                                    Boolean updCntNote=false;
                                    
                                    Boolean delParentCntNote=false;
                                    Boolean updParentCntNote=false;
                                    
                                    List<ContentNote> delCnt = new List<ContentNote>();
                                    
                                    List<Form_Object__mdt> metadata = [SELECT Id, QualifiedApiName, Object_Name__c FROM Form_Object__mdt WHERE Object_Name__c!=NULL AND DeveloperName='Object_Names'  WITH SECURITY_ENFORCED LIMIT 1];//Getting metadata
                                    if(metadata!=null && metadata.size()>0){ 
                                        metadataObjects = new Set<String>(metadata[0].Object_Name__c.split(';'));
                                    }
                                    
                                    //System.debug('metadataObjects**'+metadataObjects);
                                    
                                    for(String column : metadataObjects){
                                        
                                        String objectName = column;
                                        
                                        if(objectName == 'ONLYTEXT'){
                                            continue;
                                        }
                                        
                                        if(objectName.endsWithIgnoreCase('__c')){
                                            //system.debug(objectName);
                                            String defineQuery = 'SELECT Id,Individual_Notes__c,Group_Notes__c FROM '+ String.escapeSingleQuotes(objectName) + ' WHERE Form_unique_id__c= :formUniqueId AND Form_unique_id__c!=NULL' ;
                                            // String defineQuery = 'SELECT Id FROM '+ +objName + ' WHERE Form_unique_id__c IN :String.escapeSingleQuotes(lstRecordId) AND Form_unique_id__c!=NULL' ;
                                            
                                            sObject records = Database.query(defineQuery);
                                            //System.debug('records**updateIndividualNote'+records);
                                            String indNote='';
                                            if(records.get('Individual_Notes__c')!=null){
                                                indNote= String.valueof(records.get('Individual_Notes__c'));
                                            }
                                            if(records.get('Group_Notes__c')!=null){
                                            grpNote = String.valueof(records.get('Group_Notes__c'));
                                            }
                                            Event eventRec = [SELECT
                                                              Id,
                                                              ElixirSuite__Form_Unique_Id__c,
                                                              ElixirSuite__Parent_Event_Id__c,
                                                              ElixirSuite__Attendance__c
                                                              FROM Event
                                                              WHERE ElixirSuite__Form_Unique_Id__c=:formUniqueId AND
                                                              WhatId=:accountId
                                                              WITH SECURITY_ENFORCED];
                                            
                                            parentEventId = eventRec.ElixirSuite__Parent_Event_Id__c;
                                            
                                            /*Event parentEventRec = [SELECT
                                                                    Id,
                                                                    ElixirSuite__Form_Unique_Id__c,
                                                                    ElixirSuite__Parent_Event_Id__c,
                                                                    ElixirSuite__Attendance__c
                                                                    FROM Event
                                                                    WHERE Id=:parentEventId
                                                                    WITH SECURITY_ENFORCED];*/
                                            
                                            
                                            List<ContentDocumentLink> cdl = [Select Id,
                                                                             LinkedEntityId,
                                                                             ContentDocumentId
                                                                             FROM ContentDocumentLink
                                                                             WHERE LinkedEntityId=:eventRec.Id
                                                                             WITH SECURITY_ENFORCED];
                                            
                                            if(cdl.size() >0 && cdl != null){
                                                ContentNote cnt = [Select Id,
                                                                   Content
                                                                   From ContentNote
                                                                   Where Id=:cdl[0].ContentDocumentId
                                                                   WITH SECURITY_ENFORCED];
                                                
                                                if(indNote!=''){
                                                    //System.debug('line 852');
                                                    Blob myBlob = Blob.valueOf(indNote);
                                                    cnt.Content = myBlob;
                                                    cnt.title = 'Session Notes';
                                                    updCntNote = true;
                                                    lstContentNote.add(cnt);
                                                }
                                                else{
                                                    //System.debug('line 860');
                                                    delCnt.add(cnt);
                                                    delCntNote = true;
                                                }
                                            }
                                            else{
                                                
                                                if(indNote!=''){
                                                    //Create ContentNote
                                                    ContentNote cnt = new ContentNote();
                                                    cnt.Content = Blob.valueof(indNote);
                                                    cnt.Title = 'Session Notes';
                                                    DMLManager.insertAsUser(cnt);
                                                    
                                                    //Create ContentDocumentLink
                                                    ContentDocumentLink clnk = new ContentDocumentLink();
                                                    clnk.LinkedEntityId = eventRec.Id;
                                                    clnk.ContentDocumentId = cnt.Id;
                                                    clnk.ShareType = 'I';
                                                    DMLManager.insertAsUser(clnk);
                                                }
                                                
                                            }
                                            
                                            //update records;
                                            //  DMLManager.updateAsUser(records);
                                            
                                        }
                                        
                                    }
                                    
                                    List<ContentDocumentLink> cdl1 = [Select Id,
                                                                      LinkedEntityId,
                                                                      ContentDocumentId
                                                                      FROM ContentDocumentLink
                                                                      WHERE LinkedEntityId=:parentEventId
                                                                      WITH SECURITY_ENFORCED];
                                    
                                    if(cdl1.size() >0 && cdl1 != null){
                                        ContentNote cnt1 = [Select Id,
                                                            Content
                                                            From ContentNote
                                                            Where Id=:cdl1[0].ContentDocumentId
                                                            WITH SECURITY_ENFORCED];
                                        
                                        if(grpNote!=''){
                                                    Blob myBlob = Blob.valueOf(grpNote);
                                                    cnt1.Content = myBlob;
                                                    cnt1.title = 'Session Notes';
                                                    updParentCntNote = true;
                                                    parentLstContentNote.add(cnt1);
                                                }
                                                else{
                                                    parentDelLstContentNote.add(cnt1);
                                                    delParentCntNote = true;
                                                }
                                        
                                        
                                      /*  Blob myBlob = Blob.valueOf(grpNote);
                                        cnt1.Content = myBlob;
                                        cnt1.title = 'Session Notes';
                                        parentLstContentNote.add(cnt1);*/
                                    }
                                    else{
                                                
                                                if(grpNote!=''){
                                                    //Create ContentNote
                                                    ContentNote cnt = new ContentNote();
                                                    cnt.Content = Blob.valueof(grpNote);
                                                    cnt.Title = 'Session Notes';
                                                    DMLManager.insertAsUser(cnt);
                                                    
                                                    //Create ContentDocumentLink
                                                    ContentDocumentLink clnk = new ContentDocumentLink();
                                                    clnk.LinkedEntityId = parentEventId;
                                                    clnk.ContentDocumentId = cnt.Id;
                                                    clnk.ShareType = 'I';
                                                    DMLManager.insertAsUser(clnk);
                                                }
                                                
                                            }
                                    
                                    if(updCntNote){
                                        DMLManager.updateAsUser(lstContentNote);
                                    }
                                    if(delCntNote){
                                        DMLManager.deleteAsUser(delCnt);
                                    }
                                    
                                    if(updParentCntNote){
                                        DMLManager.updateAsUser(parentLstContentNote);
                                    }
                                    if(delParentCntNote){
                                        DMLManager.deleteAsUser(parentDelLstContentNote);
                                    }
                                    
                                    List<Event> childEventLst = [SELECT
                                                                 Id,
                                                                 ElixirSuite__Form_Unique_Id__c,
                                                                 ElixirSuite__Parent_Event_Id__c,
                                                                 ElixirSuite__Attendance__c
                                                                 FROM Event
                                                                 WHERE ElixirSuite__Parent_Event_Id__c=:parentEventId
                                                                 WITH SECURITY_ENFORCED];
                                    Set<String> lstFormUniqueId = new Set<String>();
                                    List<sObject> records = new List<sObject>();
                                    
                                    if(childEventLst.size() >0 && childEventLst != null){
                                        for(Event ev : childEventLst){
                                            lstFormUniqueId.add(ev.ElixirSuite__Form_Unique_Id__c);
                                        }
                                    }    
                                    if(lstFormUniqueId.size() >0 && lstFormUniqueId != null){
                                        for(String column : metadataObjects){
                                            
                                            String objectName = column;
                                            
                                            if(objectName == 'ONLYTEXT'){
                                                continue;
                                            }
                                            
                                            if(objectName.endsWithIgnoreCase('__c')){
                                                String defineQuery = 'SELECT Id,Individual_Notes__c,Group_Notes__c FROM '+ String.escapeSingleQuotes(objectName) + ' WHERE Form_unique_id__c IN :lstFormUniqueId AND Form_unique_id__c!=NULL' ;
                                                // String defineQuery = 'SELECT Id FROM '+ +objName + ' WHERE Form_unique_id__c IN :String.escapeSingleQuotes(lstRecordId) AND Form_unique_id__c!=NULL' ;
                                                
                                                records = Database.query(defineQuery);
                                                
                                                for(sObject rec : records){
                                                    rec.put('Group_Notes__c',grpNote.stripHtmlTags());
                                                }
                                                
                                                
                                            }
                                            
                                        }
                                    }
                                    if(records.size() >0 && records != null){
                                        DMLManager.updateAsUser(records);
                                    }
                                    
                                }


                                public static void saveImages(Map<String, String> imgData, String accountId, String formId){
                                    Set<String> sectionIds = imgData.keySet();
                                    List<ContentVersion> documents = [SELECT Id, ContentDocumentId,Form_css_id__c
                                                                        FROM ContentVersion 
                                                                        WHERE Form_Id__c= :formId AND Form_css_id__c IN :sectionIds  WITH SECURITY_ENFORCED];
                                    
                                    Map<Id,Id> sectionIdsAlreadyPresent = new Map<Id,Id>();
                                    for(ContentVersion version :documents){
                                        sectionIdsAlreadyPresent.put(version.Form_css_id__c, version.Id);
                                    }
                                    List<ContentVersion> contents = new List<ContentVersion>(); 
                                    Set<Id> versionsToDel = new Set<Id>();
                                    //List<ContentDocumentLink> contentLinks = new List<ContentDocumentLink>(); 
                                    
                                    for(String sectionId :imgData.keySet()){
                                        String img = imgData.get(sectionId);
                                        if(sectionIdsAlreadyPresent.containsKey(sectionId)){
                                            versionsToDel.add(sectionIdsAlreadyPresent.get(sectionId));
                                        }
                                        String cleanBase64 = img.removeStart('data:image/png;base64,');
                                        ContentVersion cv = new ContentVersion();
                                        if(!Test.isRunningTest()){
                                            cv.VersionData = EncodingUtil.base64Decode(cleanBase64);                              
                                            cv.Title = 'staticDraw'+sectionId;
                                            cv.PathOnClient ='staticDraw'+sectionId+'.PNG';
                                            cv.Form_Id__c = formId;
                                            cv.Form_css_id__c = sectionId;                                   
                                            contents.add(cv);
                                        }
                                        else{
                                            Blob b=Blob.valueOf('This is version data'); 
                                            cv.VersionData = b;
                                        }
                                    }
                                    Set<Id> documentsToDel = new Set<Id>();
                                    if(versionsToDel.size()>0){
                                        Set<String> combinations = new Set<String>();
                                        List<ContentVersion> versions = [SELECT Id, ContentDocumentId,
                                                                        Form_Id__c, Form_css_id__c
                                                                        FROM ContentVersion 
                                                                        WHERE Id IN :versionsToDel  WITH SECURITY_ENFORCED];
                                        for(ContentVersion version :versions){
                                            documentsToDel.add(version.ContentDocumentId);
                                            combinations.add(version.Form_Id__c+ '&' +version.Form_css_id__c);
                                        }
                                        List<ContentDocument> docs = [SELECT Id
                                                                    FROM ContentDocument
                                                                    WHERE Id IN :documentsToDel  WITH SECURITY_ENFORCED];
                                                                    //if (Schema.sObjectType.ContentDocument.isDeletable()){
                                        //delete docs;
                                        DMLManager.deleteAsUser(docs);
                                                                    //}

                                        List<Attachment> attachments = [SELECT Id,Body,Name
                                        FROM Attachment 
                                        WHERE Name IN :combinations  WITH SECURITY_ENFORCED];
                                        //if (Schema.sObjectType.Attachment.isDeletable()){
                                        //delete attachments;
                                        DMLManager.deleteAsUser(attachments);

                                   // }
                                }
                                    //system.debug(contents);
                                    if(contents.size()>0){
                                       // if (Schema.sObjectType.ContentVersion.isCreateable()){
                                            DMLManager.insertAsUser(contents);
                                       // insert contents;
                                       // }
                                        List<Attachment> attachments = new List<Attachment>();  
                                        for(ContentVersion version :contents){
                                            Attachment attch = new Attachment();
                                            attch.Body = version.VersionData;
                                            attch.ContentType = 'PNG';
                                            attch.ParentId = accountId;
                                            attch.Name = version.Form_Id__c+'&'+version.Form_css_id__c;
                                            attachments.add(attch);
                                        }
                                       // if (Schema.sObjectType.Attachment.isCreateable()){
                                            DMLManager.insertAsUser(attachments);
                                       // insert attachments;
                                   // }
                                }
                                    /*Integer i=0;
                                    List<ContentVersion> documents = [SELECT 
                                                                    Id, ContentDocumentId
                                                                    FROM ContentVersion 
                                                                    WHERE Id IN :contents];
                                    List<Id> contentDocIds = new List<Id>();
                                    for(ContentVersion content :documents){
                                        contentDocIds.add(content.ContentDocumentId);
                                    }
                                    for(Id contentDocId :contentDocIds){            
                                        ContentDocumentLink cdl = new ContentDocumentLink();            
                                        cdl.LinkedEntityId = accountId;
                                        cdl.ContentDocumentId = contentDocId;
                                        cdl.ShareType = 'V';
                                        contentLinks.add(cdl);
                                        i++;
                                    }
                                    if(contentLinks.size()>0){
                                        insert contentLinks;
                                    }*/
                                }
    public class FormSchema{
        @AuraEnabled public List<Object_1_css__c> cssRecords;
        @AuraEnabled public Map<String, sObject> objToValues;
        @AuraEnabled public List<Form_Value__c> autoTextFormValues;
        @AuraEnabled public List<FormRenderUtility.FieldSchema> allFields;
        @AuraEnabled public Map<Decimal, Map<Decimal, List<Form_Value__c>>> sec_row_columns = new Map<Decimal, Map<Decimal, List<Form_Value__c>>>();
        @AuraEnabled public String labelstoShow;
        @AuraEnabled public Map<String,List<ContentVersion>> versionBasedOnUniqueName;
        @AuraEnabled public String AccountName;
        @AuraEnabled public List<Form_Template__c> formTemp ;
        @AuraEnabled public List<Form_Template_Data__c> formTempData ;
         @AuraEnabled public List<Form_Template_Data__c> problemNoteData ;
        @AuraEnabled public List<Form_Template_Data__c> diagnosisNoteData ;
        @AuraEnabled public List<Form_Template_Data__c> procedureNoteData ;
        @AuraEnabled public Map<String, sObject> consentData = new Map<String, sObject>();
        @AuraEnabled public Boolean isPatientModeEnabled;
        @AuraEnabled public Map<String, Boolean> sectionHasUploadedImage;
        @AuraEnabled public ElixirSuite__Procedure__c procedureOfForm;
        @AuraEnabled public List<ElixirSuite__Inventory__c> invRecords = new List<ElixirSuite__Inventory__c>();
        @AuraEnabled public List<Form_value__c> modularMatrixData;
        @AuraEnabled public List<Form_value__c> fetchFlag;
        @AuraEnabled public Map<Id, sObject> formCssToFxValue;
        @AuraEnabled public Map<String, sObject> objToData;
        @AuraEnabled public List<Form_Value__c> formDefaultValues;
        public FormSchema(List<Object_1_css__c> cssRecords, Map<String, sObject> objToValues, List<FormRenderUtility.FieldSchema> allFields,
                          Map<Decimal, Map<Decimal, List<Form_Value__c>>> sec_row_columns, String labelstoShow, List<Form_Value__c> autoTextFormValues,
                          Map<String,List<ContentVersion>> versionBasedOnUniqueName, List<Form_Template__c> formTemps , List<Form_Template_Data__c> formTempDatas,
                          List<Form_Template_Data__c> problemNoteDatas,List<Form_Template_Data__c> diagnosisNoteDatas, List<Form_Template_Data__c> procedureNoteDatas, Map<String,sObject> consentData,
                          Boolean isPatientModeEnabled, Map<String, Boolean> sectionHasUploadedImage,ElixirSuite__Procedure__c procedureOfForm,List<ElixirSuite__Inventory__c> invRecords, List<Form_value__c> modularMatrixDatas,  List<Form_value__c> fetchFlag,
                          Map<Id,sObject> formCssToFxValue, Map<String, sObject> objToData, List<Form_Value__c> formDefaultValues){
            this.cssRecords = cssRecords;
            this.objToValues = objToValues;
            this.allFields = allFields;
            this.sec_row_columns = sec_row_columns;
            this.labelstoShow = labelstoShow;
            this.autoTextFormValues = autoTextFormValues;
            this.versionBasedOnUniqueName = versionBasedOnUniqueName;
            this.formTemp = formTemps;
            this.formTempData = formTempDatas ;
            this.problemNoteData = problemNoteDatas ;
            this.diagnosisNoteData = diagnosisNoteDatas ;
            this.procedureNoteData = procedureNoteDatas ;
            this.consentData = consentData;
            this.objToData = objToData;
            this.isPatientModeEnabled = isPatientModeEnabled;
            this.sectionHasUploadedImage = sectionHasUploadedImage;
            this.procedureOfForm = procedureOfForm;
            this.invRecords = invRecords;
            this.modularMatrixData = modularMatrixDatas;
            this.fetchFlag = fetchFlag;
            this.formCssToFxValue = formCssToFxValue;
            this.formDefaultValues = formDefaultValues;

        }
    }
    //@future
    public static void saveDefaultValues(String accountId, List<String> commonFields, String defaultValuesSaveObject){
        FormRenderClass.saveDefaultValues(accountId, commonFields, defaultValuesSaveObject);
    }
    @AuraEnabled
    public static  ExternalComponents_InsideFormHelper.EditScreen_ExternalComponentsObjectData externalCmpDataForEditScreen(String acctId,String formUniqueID){ 
        ExternalComponents_InsideFormHelper.EditScreen_ExternalComponentsObjectData globalWrapper = ExternalComponents_InsideFormHelper.allExtCompDataForEditScreen(acctId,formUniqueID);
        return globalWrapper; 
        
    }
     @AuraEnabled
    public static void deleteAllProblemSavedFromForm(List<String> recIds,String[] procedureId){
       MasterProblemListController.deleteAllProbelm(recIds);
          delete [SELECT ID FROM ElixirSuite__Procedure__c WHERE ID IN : procedureId];
    }

    @AuraEnabled
    public static Boolean containsUploadedImage(String accountId, String formUniqueId, String formCssId){
        List<ContentVersion> versions = [SELECT Id, VersionData FROM ContentVersion
                                        WHERE Form_css_id__c= :formCssId
                                        AND Form_Id__c= :formUniqueId  WITH SECURITY_ENFORCED];
                                        //system.debug(formUniqueId + formCssId);
                                        //system.debug(versions);
        if(versions!=null && versions.size()>0){
            return true;
        }
        return false;
    }
     @AuraEnabled
    public static String deleteRecords(string recordIds) {
        try {
            // Delete the records
             List<ElixirSuite__ICD_Codes__c> lstIcd=[SELECT Id FROM ElixirSuite__ICD_Codes__c WHERE Id =:recordIds WITH SECURITY_ENFORCED];
            if(lstIcd.size() > 0)
        {
            DMLManager.deleteAsUser(lstIcd);
        }
            return 'Record deleted successfully.';
        } catch (DmlException e) {
            return 'Error deleting records: ' + e.getMessage();
        }
    }
    @AuraEnabled
    public static String deleteProblemRecords(string recordIds) {
        try {
            // Delete the records
            List<ElixirSuite__Dataset1__c> lstProblem= [SELECT Id FROM ElixirSuite__Dataset1__c WHERE Id =:recordIds WITH SECURITY_ENFORCED];
            if(lstProblem.size() > 0)
        {
            DMLManager.deleteAsUser(lstProblem);
        }
            return 'Record deleted successfully.';
        } catch (DmlException e) {
            return 'Error deleting records: ' + e.getMessage();
        }
    }
    @AuraEnabled
    public static String saveRecords(List<SObject> updates) {
        try {
           //system.debug('save record', updates);
            DMLManager.updateAsUser(updates);
            return 'Success';
        } catch (Exception e) {
            return 'Error: ' + e.getMessage();
        }
    }
    @AuraEnabled
    public static MedicationWrapper getMedicationColumns(){
        MedicationWrapper w = new MedicationWrapper();
        String selectedObject = 'ElixirSuite__Prescription_Order__c' ;
       
       Map<String, String> dataTypeToApi = new Map<String, String>();
        Map<String,String> labelToApi = new Map<String,String>();
        Map<String,String> apiAndType = new Map<String,String>();
        try {
            
            Map <String,Schema.SObjectType> gd = Schema.getGlobalDescribe();
            Schema.SObjectType sobjType = gd.get(selectedObject);
            Schema.DescribeSObjectResult r = sobjType.getDescribe();
            Map<String, Schema.SObjectField> MapofField = r.fields.getMap();
            
            for(String fieldName : MapofField.keySet()) {
                Schema.SObjectField field = MapofField.get(fieldName);
                Schema.DescribeFieldResult F = field.getDescribe();
                // Get data type of the field
        		String fieldType = String.valueOf(F.getType());
                 // Get API name of the field
        		String fieldApiName = String.valueOf(field);
                String fi = String.valueOf(field);
                //System.debug('field-->'+field);
                labelToApi.put(String.valueOf(F.getLabel()),String.valueOf(field));
                apiAndType.put(String.valueOf(field),String.valueOf(F.getType()));
            }
            // Now, dataTypeToApi map contains data types as keys and API names as values
   			 System.debug('DataTypeToApi Map: ' + dataTypeToApi);
            
            Elixir_Custom_Setting__c mc = Elixir_Custom_Setting__c.getOrgDefaults();
            w.medicationColumns = mc.ElixirSuite__Medication_Columns__c;
            w.mapRequiredFields = labelToApi;
            w.mapFieldsApiAndType = apiAndType;
            return w;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    
    public class MedicationWrapper{
        @AuraEnabled
        public String medicationColumns;
        @AuraEnabled
        public Map<String,String> mapRequiredFields;
        @AuraEnabled
        public Map<String,String> mapFieldsApiAndType;
    }
   @AuraEnabled
public static List<ElixirSuite__Prescription_Order__c> fetchAccountMedication(String acctId,String formUniqueId) {
    Elixir_Custom_Setting__c mc = Elixir_Custom_Setting__c.getOrgDefaults();
    String medicationData = mc.ElixirSuite__Medication_Data_Limit_On_Notes__c;
    Id medicationRecordType = Schema.SObjectType.ElixirSuite__Prescription_Order__c.getRecordTypeInfosByDeveloperName().get('Medication').getRecordTypeId();

    String objectName = 'ElixirSuite__Prescription_Order__c';
    String conditionField = 'ElixirSuite__Form_Value__r.ElixirSuite__Form_Id__c';
    Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();

    String query = 'SELECT ';
    for (String fieldName : fieldMap.keySet()) {
        query += fieldName + ', ';
    }
    query += 'ElixirSuite__Account__r.Name, CreatedBy.Name, ElixirSuite__Dosage1__r.Name, ElixirSuite__Prescription_Order__r.Name, Owner.Name, RecordType.Name, ElixirSuite__Medication__r.Name, ElixirSuite__Route_New_1__r.Name ';
    // Remove the trailing comma and space
    query = query.removeEnd(', ');
    
    // Add the subquery for related records (ElixirSuite__Frequency__r)
    query += ', (SELECT Id, ElixirSuite__Strength__c, ElixirSuite__Strength_1__c, ElixirSuite__Strength_10__c, ElixirSuite__Strength_17__c, ElixirSuite__Strength_18__c FROM ElixirSuite__Frequency__r) ';

    query += ' FROM ' + objectName + ' WHERE ' + conditionField + ' = \'' + String.escapeSingleQuotes(formUniqueId) + '\'';
    
    // Add the conditions for record type and any additional conditions
    query += ' AND RecordTypeId = \'' + String.escapeSingleQuotes(medicationRecordType) + '\'';
    query += ' WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC';
    if (String.isNotBlank(medicationData)) {
        query += ' ' + medicationData;
    }

    System.debug('Dynamic Query: ' + query);

    List<ElixirSuite__Prescription_Order__c> queryResults = Database.query(query);
    System.debug('Query Results: ' + queryResults);

    return queryResults;
}
public class NewAllergyWrapper{
    @AuraEnabled
    public String allergyColumns;
    @AuraEnabled
    public Map<String,String> mapRequiredFields;
    @AuraEnabled
    public Map<String,String> mapDataTypeToApi;
}

@AuraEnabled
public static NewAllergyWrapper getAllergyColumns1(){
   NewAllergyWrapper w = new NewAllergyWrapper();
    String selectedObject = 'ElixirSuite__Medical_Examination__c' ;
   
   Map<String, String> dataTypeToApi = new Map<String, String>();
    Map<String,String> labelToApi = new Map<String,String>();  
    try {
        
        Map <String,Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType sobjType = gd.get(selectedObject);
        Schema.DescribeSObjectResult r = sobjType.getDescribe();
        Map<String, Schema.SObjectField> MapofField = r.fields.getMap();
        
        for(String fieldName : MapofField.keySet()) {
            Schema.SObjectField field = MapofField.get(fieldName);
            Schema.DescribeFieldResult F = field.getDescribe();
            // Get data type of the field
            String fieldType = String.valueOf(F.getType());
             // Get API name of the field
            String fieldApiName = String.valueOf(field);
            String fi = String.valueOf(field);
            labelToApi.put(String.valueOf(F.getLabel()),String.valueOf(field));
            // Map data type to API name
            dataTypeToApi.put(fieldApiName,fieldType);
        }
        // Now, dataTypeToApi map contains data types as keys and API names as values
        
        Elixir_Custom_Setting__c mc = Elixir_Custom_Setting__c.getOrgDefaults();
        w.allergyColumns = mc.ElixirSuite__Allergy_Columns__c;
        w.mapRequiredFields = labelToApi;
        w.mapDataTypeToApi=dataTypeToApi;
        return w;
    } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
    }
}

}
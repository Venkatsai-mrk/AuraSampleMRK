public with sharing class FormRenderClass {
    @AuraEnabled
    public static List<Medical_Examination__c> fetchAccountSpecificVitals(String acctId, String sortBy, String sortDirection,List<String> vitalIds,String formUniqueId) { 
        Elixir_Custom_Setting__c customSetting = Elixir_Custom_Setting__c.getOrgDefaults();
        String historicalVitals = customSetting.ElixirSuite__Historical_Vitals__c;
        //Boolean includePatientSpecificVitals = customSetting.ElixirSuite__Patient_Specific_Vital__c;
        
        String objectName = 'ElixirSuite__Medical_Examination__c';
        if(String.isBlank(formUniqueId)){
            String conditionField = 'ElixirSuite__Account__c';
            Id vitalRecordType = Schema.SObjectType.ElixirSuite__Medical_Examination__c.getRecordTypeInfosByDeveloperName().get('Vital_Sign').getRecordTypeId();
            Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
            
            String query = 'SELECT ';
            for (String fieldName : fieldMap.keySet()) {
                query += fieldName + ', ';
            }
            query = query.removeEnd(', ');
            query += ' FROM ' + objectName + ' WHERE ' + conditionField + ' = \'' + String.escapeSingleQuotes(acctId) + '\' AND RecordTypeId = \'' + String.escapeSingleQuotes(vitalRecordType) + '\' AND Name != null';
            query += ' AND ID IN : vitalIds';
            
            if (sortBy != null && sortDirection != null) {
                query += ' ORDER BY ' + sortBy + ' ' + sortDirection;
            } else {
                query += ' ORDER BY CreatedDate DESC ';
            }
            
            if (String.isNotBlank(historicalVitals)) {
                query += ' ' + historicalVitals;
            }
            
            List<ElixirSuite__Medical_Examination__c> queryResults = Database.query(query);
            return queryResults;
        }
        else{
            // if we have formUniqueId it means form opened in edit mode..
            
             String conditionField = 'ElixirSuite__Form_Value__r.ElixirSuite__Form_Id__c';
            Id vitalRecordType = Schema.SObjectType.ElixirSuite__Medical_Examination__c.getRecordTypeInfosByDeveloperName().get('Vital_Sign').getRecordTypeId();
            Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
            
            String query = 'SELECT ';
            for (String fieldName : fieldMap.keySet()) {
                query += fieldName + ', ';
            }
            query = query.removeEnd(', ');
            query += ' FROM ' + objectName + ' WHERE ' + conditionField + ' = \'' + String.escapeSingleQuotes(formUniqueId) + '\' AND RecordTypeId = \'' + String.escapeSingleQuotes(vitalRecordType) + '\' AND Name != null';
            
            if (sortBy != null && sortDirection != null) {
                query += ' ORDER BY ' + sortBy + ' ' + sortDirection;
            } else {
                query += ' ORDER BY CreatedDate DESC ';
            }
            
            if (String.isNotBlank(historicalVitals)) {
                query += ' ' + historicalVitals;
            }
            
            List<ElixirSuite__Medical_Examination__c> queryResults = Database.query(query);
            return queryResults;
        }
        
    }

      @AuraEnabled
    public static List<Medical_Examination__c> fetchAccountSpecificVitalsPdf(String acctId , List<string> lstIds){ 
        Elixir_Custom_Setting__c customSetting = Elixir_Custom_Setting__c.getOrgDefaults();
        String historicalVitals = customSetting.ElixirSuite__Historical_Vitals__c;
             
        
        String objectName = 'ElixirSuite__Medical_Examination__c';
        String conditionField = 'ElixirSuite__Account__c';
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
		Id vitalRecordType = Schema.SObjectType.ElixirSuite__Medical_Examination__c.getRecordTypeInfosByDeveloperName().get('Vital_Sign').getRecordTypeId();
        
        String query = 'SELECT ';
        for (String fieldName : fieldMap.keySet()) {
            query += fieldName + ', ';
        }
        query = query.removeEnd(', ');
        query += ' FROM ' + objectName + ' WHERE ' + conditionField + ' = \'' + String.escapeSingleQuotes(acctId) + '\' AND RecordTypeId = \'' + String.escapeSingleQuotes(vitalRecordType) + '\' AND Name != null';
query += ' AND ID IN : lstIds';
        query += ' ORDER BY CreatedDate DESC ';
        if(string.isNotBlank(historicalVitals)){
            query += historicalVitals;
        }
        
        List<ElixirSuite__Medical_Examination__c> queryResults = Database.query(query);
        return queryResults;
    }
    

 @AuraEnabled
    public static FormSchema buildForm(String formName, String accountId){// formName = RecordType name
        FormSchema form;
        Map<String,List<String>> objectToFieldsMap = new Map<String,List<String>>();
        Map<String, sObject> objToData = new Map<String, sObject>();
        Map<String, sObject> consentData = new Map<String, sObject>();
        List<Object_1_css__c> cssRecords = new List<Object_1_css__c>();
        Map<Id,sObject> formCssToFxValue = new Map<Id,sObject>();
        List<Id> formTemplateIds = new List<Id>();
        List<Contact> conList = new List<Contact>();
        Map<String,List<string>> formTemplateToContactMap = new Map<String,List<String>>();
           
        List<FormRenderUtility.FieldSchema> allFields = new List<FormRenderUtility.FieldSchema>();
        
        List<Form_Template__c> mdt = new List<Form_Template__c>();
        List<Form_Template__c> mdt1 = new List<Form_Template__c>();
        Id currentUserId = UserInfo.getUserId();
        Elixir_Custom_Setting__c val = Elixir_Custom_Setting__c.getOrgDefaults();
        String contactRecType = val.ElixirSuite__Practitioner_Contact_Recordtype__c;
        Id practitionerRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(contactRecType).getRecordTypeId();
        Set<String> qualifiedFormObjects = FormRenderUtility.fetchObjects(formName);//All Objects that have this Form.
        
        if(qualifiedFormObjects!=null && qualifiedFormObjects.size()>0){
            FormRenderUtility.objFieldSchema  objSchema = FormRenderUtility.fetchFields(qualifiedFormObjects, objectToFieldsMap, formName);
            objectToFieldsMap = objSchema.objectToFieldsMap;
            allFields = objSchema.fieldSchemas;
            //All fields with regards to these objects.
            cssRecords = [SELECT Id,Auto_text__c,Enable_Auto_text__c,Hide_Selections__c,Consent_Query__c,ElixirSuite__Add_Problem__c,
                          Form_Category__c,Css__c,Indentation__c,Class__c,parent_query__c,isFormMacro__c,ElixirSuite__Add_Procedure__c,
                          Form_Specific_Data__c, Map_query__c,Default_text__c,Section_Name__c,  ElixirSuite__Is_Time_Enabled__c, ElixirSuite__Default_Inventory_Type__c,ElixirSuite__Lot_Number__c,
                          Section_Number__c, Is_Consent__c, Columns_In_Section__c,Object_Name__c,
                          Is_matrix__c, Columns_Matrix__c, Headings__c,Add_Notes__c, Type_of_Note__c,
                          Select_Form_Component__c,Static_file_name__c,
                          (SELECT Id,Class__c,Is_Common_Parent__c,Form_Specific_Data__c,No_Label__c,ElixirSuite__Is_Time_Enabled__c,
                           Map_object__c,Map_field__c,IsCommon__c,Object_Name__c,Is_Consent__c,
                           Css__c,Default_text__c, Field_Name__c, Form__c, Object_1_css__c, 
                           Field_Label_Long__c,Data_Type__c,Reference_to_object__c,Row__c,Column__c,Form_Data_Type__c,
                           IMG_Default_Button_Label__c, IMG_File_Name__c, IMG_Type_of_Upload__c, IMG_Type_of_Row__c,
                           Is_matrix__c, Columns_Matrix__c, Headings__c, Add_Notes__c, Type_of_Note__c,Is_formula_Field__c,ElixirSuite__Auto_Populate__c
                           FROM Object_1_css__r
                           ORDER BY Row__c,Column__c ASC) FROM Object_1_css__c WHERE 
                          Form__c =:formName AND Section_Number__c!=NULL AND Section_Number__c!=0 
                          WITH SECURITY_ENFORCED
                          ORDER BY Section_Number__c ASC];

            //Vidish Added Reference_to_object__c and Is_formula_Field__c and ElixirSuite__Auto_Populate__c field in the query 
            
            
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
            
            
            
            
            // Query whether patient mode for forms is checked or not
            Boolean isPatientModeEnabled = Elixir_Custom_Setting__c.getOrgDefaults().Patient_Mode_For_Forms__c;
            
            if(cssRecords!=null && cssRecords.size()>0){
                // For Object-FORM -- START
                objToData = FormRenderUtility.getObjectFormData(cssRecords[0], accountId);
                consentData = FormRenderUtility.getQueryDataConsent(cssRecords[0], accountId, UserInfo.getUserId());
                formCssToFxValue = FormRenderUtility.getFxData(formName, accountId);
                // For Object-FORM -- END
                List<Account> accounts = [SELECT Id, Name FROM Account WHERE Id= :accountId WITH SECURITY_ENFORCED];
                //For FORM-FORM data transmission - START
                List<Form_Value__c> formDefaultValues = new List<Form_Value__c>([SELECT Id, Default1__c, Account__c, Field_Api_Name__c,Only_text_in_consent__c
                                                                                 FROM Form_Value__c 
                                                                                 WHERE Account__c =:accountId AND Form_Id__c=NULL AND ElixirSuite__Field_Api_Name__c!=NULL 
                                                                                 WITH SECURITY_ENFORCED
                                                                                 LIMIT 999]);
                form = new FormSchema(cssRecords, allFields, formDefaultValues, objToData, consentData, 
                                      accounts[0].Name, mdt, isPatientModeEnabled,System.now(), formCssToFxValue);
                //FormRenderUtility.queryPreFilledData(formName, accountId);
                //For FORM-FORM data transmission - END
            }
        }
        return form;
    }  
    
    @AuraEnabled  
    public static List<user> UinfoNew(){
        ID userId =UserInfo.getUserId();
        List<User> lstUser = new List<User>();
        lstUser =[select id,ElixirSuite__Verification_Code_New__c from user where id =:userId 
                   WITH SECURITY_ENFORCED LIMIT 1];
        return lstUser;
    }

    //Added by Anmol for LX3-5770
    @AuraEnabled
    public static String fetchNameSpace() {
         String namespace = Elixir_Utility.getNamespace() ;
        return namespace;
    }
    //End by Anmol for LX3-5770

  //Added by Anmol for LX3-6263
  @AuraEnabled
  public static String fetchCustomSettingsPrescription() {
       String prescVal;
          ID userId =UserInfo.getProfileId();
       List<ElixirSuite__TabPermissionBasedOnProfiles__c> tb = [SELECT Id, ElixirSuite__Prescription_Priority__c 
                                                          FROM ElixirSuite__TabPermissionBasedOnProfiles__c where SetupOwnerId = :userId WITH SECURITY_ENFORCED LIMIT 1];

      if(tb!=null && tb.size()>0){

          prescVal = tb[0].ElixirSuite__Prescription_Priority__c ;
      }

      return prescVal;
  }
  //End by Anmol for LX3-6263
    
 
    //end by Anmol for LX3-5676
    
    @AuraEnabled
    public static String saveForm(String accountId, String formName, String changedFormName, String category, String cssRecords,String problemData,
                                  String precriptionData,List<String> deletedProblem,List<String> toDelProblemFromUpdate,String toUpdateProblem,
                                  Boolean isProblemEnabled,String procedureWrapper, Boolean isProcedureEnabled,String timeWrapper,Boolean isTimeEnabled, String modularMatrixData,String toUpdateNotesSpecific)
    {
        Map<String, String> sectionIdToImage = new Map<String,String>();
        String uniqueId;
        List<String> commonFields = new List<String>();
        Account changeAccount = new Account();
        List<Form_Value__c> defaultValuesSaveObject = new List<Form_Value__c>();
        List<Form_Value__c> consentValues = new List<Form_Value__c>();
        //Text generation Attributes - START
        List<Form_Value__c> valueForAutoText = new List<Form_Value__c>();
        Set<Integer> sectionNos = new Set<Integer>();
        
        //Text generation Attributes - END
        List<Form_Template_Data__c> valueForMacroData = new List<Form_Template_Data__c>();
        Set<String> sectionNumberForMacro = new Set<String>();
        
           //added by Anmol for LX3-7236
           Elixir_Custom_Setting__c customSetting = Elixir_Custom_Setting__c.getOrgDefaults();
           String careFilter = customSetting.ElixirSuite__Default_Active_Care_Episode_Filter__c;
           if(string.isBlank(careFilter)){
            careFilter = 'createddate desc';
        }
           String careStatus = 'Active';
   
           string querystr = '';
           querystr += 'Select Id,ElixirSuite__Account__c,ElixirSuite__Status__c from ElixirSuite__Visits__c where ElixirSuite__Status__c=:careStatus AND ElixirSuite__Account__c =: accountId WITH SECURITY_ENFORCED order by ';
           querystr += careFilter ;
           List<ElixirSuite__Visits__c> lstVisits = database.query(querystr);
           //end by Anmol for LX3-7236
        
        List<Form_Template_Data__c> valueForProblemNoteData = new List<Form_Template_Data__c>();
        Set<String> sectionNumberForProblemNote = new Set<String>();
        List<Form_Template_Data__c> valueForDiagnosisNoteData = new List<Form_Template_Data__c>();
        Set<String> sectionNumberForDiagnosisNote = new Set<String>();
        List<Form_Template_Data__c> valueForProcedureNoteData = new List<Form_Template_Data__c>();
        Set<String> sectionNumberForProcedureNote = new Set<String>();
        
        Map<String, sObject> objectNameToRecords = new Map<String, sObject>();
        Map<String, Map<String,String>> objectNameToApiNameAndLabel = new Map<String, Map<String,String>>();
        Map<String, Object> deserializedRecords = (Map<String, Object>) JSON.deserializeUntyped(cssRecords);
        List<Object> sections = (List<Object>) deserializedRecords.get('cssRecords');
        
        List<Object> inventoryLst = new  List<Object>();
        boolean invCheck = false;

        //added by Anmol for LX3-6259
        String prescriptionLst;
        String selUser;
        String selVia;
        String startTm;
        String endTm;
        boolean presCheck = false;
        //end by Anmol for LX3-6259

        String objNameForExtCmp;
        Boolean isExtCmp = false;
        // form macro template
        Boolean isMacroTemp = false;
        
        Boolean isProblemNoteTemp = false;
        Boolean isDiagnosisNoteTemp = false;
        Boolean isProcedureNoteTemp = false;
        Id recordTypeId = Schema.SObjectType.ElixirSuite__Procedure__c.getRecordTypeInfosByDeveloperName().get('Patient_Procedure').getRecordTypeId();
        //added by sagili sivasai as per LX3-5900
        Id recordTypeId1 = Schema.SObjectType.ElixirSuite__ICD_Codes__c .getRecordTypeInfosByDeveloperName().get('Patient_Diagnosis_Code').getRecordTypeId();
        Set<String> metadataObjects = new Set<String>();
        List<Form_Object__mdt> metadata = [SELECT Id, QualifiedApiName, Object_Name__c FROM Form_Object__mdt WHERE Object_Name__c!=NULL WITH SECURITY_ENFORCED LIMIT 1];//Getting metadata
        if(metadata!=null && metadata.size()>0){ 
            metadataObjects = new Set<String>(metadata[0].Object_Name__c.split(';'));
        }    
      
        if(sections != null){
            for(Object section :sections){
                Map<String, Object> record = (Map<String, Object>) section; 
                //Text Generation - START 
                String autoText = (String) record.get('AutoText');
                List<Object> bluePrint = (List<Object>) record.get('bluePrint');
                Boolean isAutoText = (Boolean) record.get('ElixirSuite__Enable_Auto_text__c');
                Boolean consentTextAllowed = (Boolean) record.get('ElixirSuite__Is_Consent__c');
                Boolean isMacroForm = (Boolean) record.get('ElixirSuite__isFormMacro__c');
                String macroData = String.valueOf(record.get('formMacro'));
                String problemNoteData = String.valueOf(record.get('problemNote'));
                String selectFormComp = String.valueOf(record.get('ElixirSuite__Select_Form_Component__c'));
                List<Object> problemListFromNote = (List<Object>) record.get('problemNoteList');
                String diagnosisNoteData = String.valueOf(record.get('diagnosisNote'));
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
                 if(selectFormComp == 'Enable Prescription Order'){
                     presCheck = true;
                 }
                 if(presCheck){
                     if(String.isBlank(prescriptionLst) && String.isBlank(selUser) && String.isBlank(selVia) && String.isBlank(startTm) && String.isBlank(endTm)){
                 prescriptionLst = String.valueOf(record.get('prescLst'));
                 selUser = String.valueOf(record.get('selectedUser'));
                 selVia = String.valueOf(record.get('selectedVia'));
                 startTm = String.valueOf(record.get('starttime'));
                 endTm = String.valueOf(record.get('endtime'));
                     }
                 }
                 //end by Anmol for LX3-6259

                String imgData = (String) record.get('ImageData');
                String sectionId = (String) record.get('Id');            
                if(String.isNotBlank(sectionId) && String.isNotBlank(imgData)){
                    sectionIdToImage.put(sectionId, imgData);
                }
                List<ElixirSuite__Dataset1__c> listAbc = new List<ElixirSuite__Dataset1__c>();
                if(problemListFromNote != null && problemListFromNote.size()>0){
                    
                    for(Object sObjLoop : problemListFromNote){
                        Map<String, Object> objRecordParent = ( Map<String, Object>) sObjLoop; 
                        ElixirSuite__Dataset1__c abc = new ElixirSuite__Dataset1__c();
                        abc.Name = String.valueof(objRecordParent.get('fieldName'));
                        abc.ElixirSuite__Account__c = accountId;
                        abc.ElixirSuite__Description__c = String.valueof(objRecordParent.get('description'));
                        if(!lstVisits.isEmpty()){
                            abc.ElixirSuite__Care_Episode__c =lstVisits[0].Id;
                        }
                        listAbc.add(abc);
                        
                    }
                    DMLManager.insertAsUser(listAbc);
                }
                
                List<ElixirSuite__ICD_Codes__c> diagnosisList = new List<ElixirSuite__ICD_Codes__c>();
                if(diagnosisListFromNote != null && diagnosisListFromNote.size()>0){
                    
                    for(Object sObjLoop : diagnosisListFromNote){
                        Map<String, Object> objRecordParent = ( Map<String, Object>) sObjLoop; 
                        ElixirSuite__ICD_Codes__c abc = new ElixirSuite__ICD_Codes__c();
                        abc.Name = String.valueof(objRecordParent.get('fieldName'));
                        //  abc.ElixirSuite__Account__c = accountId;
                        abc.RecordTypeId = recordTypeId1 ;
                        abc.ElixirSuite__Code_Description1__c = String.valueof(objRecordParent.get('description'));
                        if(!lstVisits.isEmpty()){
                            abc.ElixirSuite__Care_Episode__c =lstVisits[0].Id;
                        }
                        diagnosisList.add(abc);                      
                    }
                    DMLManager.insertAsUser(diagnosisList);
                }
                
                List<ElixirSuite__Procedure__c> procedureList = new List<ElixirSuite__Procedure__c>();
                if(procedureListFromNote != null && procedureListFromNote.size()>0){
                    
                    for(Object sObjLoop : procedureListFromNote){
                        
                        Map<String, Object> objRecordParent = ( Map<String, Object>) sObjLoop; 
                        ElixirSuite__Procedure__c abc = new ElixirSuite__Procedure__c();
                        abc.Name = String.valueof(objRecordParent.get('fieldName'));
                        abc.ElixirSuite__Account__c = accountId;
                        abc.RecordTypeId = recordTypeId ;
                        abc.ElixirSuite__Code_Description__c = String.valueof(objRecordParent.get('description'));
                        if(!lstVisits.isEmpty()){
                            abc.ElixirSuite__Visits__c =lstVisits[0].Id;
                        }
                        procedureList.add(abc);
                        
                    }
                    //DMLManager.insertAsUser(procedureList);
                }
                
                if(String.isNotBlank(autoText) && isAutoText){
                    Integer sectionNo = (Integer) record.get('ElixirSuite__Section_Number__c');
                    Form_Value__c autoTextValue = new Form_Value__c();
                    autoTextValue.Section_Number__c = sectionNo;
                    autoTextValue.Auto_text__c = autoText;
                    autoTextValue.Is_AutoText__c = true;
                    if(bluePrint!=null){
                        autoTextValue.Blue_Print__c = JSON.serialize(bluePrint); 
                    }
                    valueForAutoText.add(autoTextValue);
                    sectionNos.add(sectionNo);
                }
                if(String.isNotBlank(macroData) && isMacroForm ){
                    isMacroTemp = true;
                    objNameForExtCmp = new List<String> (metadataObjects).get(0); 
                    Integer sectionNo1 = (Integer) record.get('ElixirSuite__Section_Number__c');
                    ElixirSuite__Form_Template_Data__c fdata = new ElixirSuite__Form_Template_Data__c();
                    fData.ElixirSuite__Form_Data_Description__c = macroData;
                    fData.ElixirSuite__Account__c = accountId;
                    fData.ElixirSuite__Form_Unique_Id__c = uniqueId;
                    fData.ElixirSuite__Section_Number__c = String.valueOf(sectionNo1);
                    fData.ElixirSuite__Type__c = 'Macro';
                    
                    valueForMacroData.add(fdata);
                    sectionNumberForMacro.add(String.valueOf(sectionNo1)); 
                }
                
                if(String.isNotBlank(problemNoteData) ){
                    
                    isProblemNoteTemp = true;
                    objNameForExtCmp = new List<String> (metadataObjects).get(0); 
                    Integer sectionNo1 = (Integer) record.get('ElixirSuite__Section_Number__c');
                    ElixirSuite__Form_Template_Data__c fdata1 = new ElixirSuite__Form_Template_Data__c();
                    fData1.ElixirSuite__Form_Data_Description__c = problemNoteData;
                    fData1.ElixirSuite__Account__c = accountId;
                    fData1.ElixirSuite__Form_Unique_Id__c = uniqueId;
                    fData1.ElixirSuite__Section_Number__c = String.valueOf(sectionNo1);
                    fData1.ElixirSuite__Type__c = 'Problem';
                    
                    valueForProblemNoteData.add(fdata1);
                    sectionNumberForProblemNote.add(String.valueOf(sectionNo1)); 
                }
                
                if(String.isNotBlank(diagnosisNoteData) ){
                    
                    isDiagnosisNoteTemp = true;
                    objNameForExtCmp = new List<String> (metadataObjects).get(0); 
                    Integer sectionNo1 = (Integer) record.get('ElixirSuite__Section_Number__c');
                    ElixirSuite__Form_Template_Data__c fdata1 = new ElixirSuite__Form_Template_Data__c();
                    fData1.ElixirSuite__Form_Data_Description__c = diagnosisNoteData;
                    fData1.ElixirSuite__Account__c = accountId;
                    fData1.ElixirSuite__Form_Unique_Id__c = uniqueId;
                    fData1.ElixirSuite__Section_Number__c = String.valueOf(sectionNo1);
                    fData1.ElixirSuite__Type__c = 'Diagnosis';
                    
                    valueForDiagnosisNoteData.add(fdata1);
                    sectionNumberForDiagnosisNote.add(String.valueOf(sectionNo1)); 
                }
                if(String.isNotBlank(procedureNoteData) ){
                    
                    isProcedureNoteTemp = true;
                    objNameForExtCmp = new List<String> (metadataObjects).get(0); 
                    Integer sectionNo1 = (Integer) record.get('ElixirSuite__Section_Number__c');
                    ElixirSuite__Form_Template_Data__c fdata2 = new ElixirSuite__Form_Template_Data__c();
                    fData2.ElixirSuite__Form_Data_Description__c = procedureNoteData;
                    fData2.ElixirSuite__Account__c = accountId;
                    fData2.ElixirSuite__Form_Unique_Id__c = uniqueId;
                    fData2.ElixirSuite__Section_Number__c = String.valueOf(sectionNo1);
                    fData2.ElixirSuite__Type__c = 'Procedure';
                    
                    valueForProcedureNoteData.add(fdata2);
                    sectionNumberForProcedureNote.add(String.valueOf(sectionNo1)); 
                }
                
                if(consentTextAllowed){
                    objNameForExtCmp = new List<String> (metadataObjects).get(0); 
                }
                if(isProblemEnabled){
                    objNameForExtCmp = new List<String> (metadataObjects).get(0);
                }
                if(isProcedureEnabled){
                    objNameForExtCmp = new List<String> (metadataObjects).get(0);
                }
                
                //Text Generation - END
                List<Object> rows = (List<Object>) record.get('ElixirSuite__Object_1_css__r');
                if(rows != null){
                    for(Object row : rows){
                        Map<String, Object> rowMap = (Map<String, Object>) row; 
                        List<Object> columns = (List<Object>) rowMap.get('Columns');
                        sObject sObj;
                        if(columns != null && columns.size()>0){
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
                                String fullLabel='';
                                fullLabel = columnMap.get('ElixirSuite__Default_text__c')==null?' ':String.valueOf(columnMap.get('ElixirSuite__Default_text__c'));
                                String fieldLabel = columnMap.get('ElixirSuite__Field_Label_Long__c')==null?' ':String.valueOf(columnMap.get('ElixirSuite__Field_Label_Long__c'));
                                String extCmpTypes = String.valueOf(columnMap.get('ElixirSuite__Form_Data_Type__c'));
                                
                                if(String.isNotBlank(extCmpTypes) && (extCmpTypes.equalsIgnoreCase('GLUCOSE') || extCmpTypes.equalsIgnoreCase('ALLERGY') || 
                                                                      extCmpTypes.equalsIgnoreCase('VITAL SIGN') || extCmpTypes.equalsIgnoreCase('PROBLEM') ||
                                                                      extCmpTypes.equalsIgnoreCase('MEDICATION_LIST'))){
                                                                          isExtCmp = true;
                                                                          objNameForExtCmp = objectName;
                                                                          continue;
                                                                      }
                                if(!Boolean.valueOf(columnMap.get('ElixirSuite__Is_Consent__c')) && fieldLabel.equalsIgnoreCase('nbsp')){
                                    continue;
                                }
                                if(fieldName == null && !Boolean.valueOf(columnMap.get('ElixirSuite__Is_Consent__c'))){
                                    continue;
                                }
                                if(Boolean.valueOf(columnMap.get('ElixirSuite__Is_Consent__c'))){                             
                                    FormRenderUtility.populateConsentValue(fieldName, columnMap, consentValues,
                                                                           secNo, rowNo, columnNo, accountId,true);  
                                    
                                    continue;
                                }
                                
                                //Map creation For Label Saving - START
                               /* if(String.isNotBlank(fieldLabel) && columnMap.get('value')!=null){
                                    if(!Boolean.valueOf(columnMap.get('ElixirSuite__Is_Consent__c'))){
                                        //FormLabelClass.createMapOfLabel(objectNameToApiNameAndLabel, objectName, fieldName, fieldLabel);
                                    }
                                }*/
                                //Map creation For Label Saving - END
                                //FOR Saving Forms - END
                                if(objectNameToRecords.containsKey(objectName.toLowerCase())){
                                    sObj = objectNameToRecords.get(objectName.toLowerCase());
                                    if(columnMap.get('value')!=null){
                                        FormRenderUtility.populateValue(sObj, defaultValuesSaveObject, accountId,
                                                                        commonFields, fieldName, columnMap, changeAccount); 
                                    }
                                }
                                else if(String.isNotBlank(objectName) && objectName!='undefined'){
                                    sObj = Schema.getGlobalDescribe().get(objectName).newSObject(); 
                                    if(columnMap.get('value')!=null){
                                        FormRenderUtility.populateValue(sObj, defaultValuesSaveObject, accountId,
                                                                        commonFields, fieldName, columnMap, changeAccount);
                                        objectNameToRecords.put(objectName.toLowerCase(), sObj);
                                    }
                                    if(Boolean.valueOf(columnMap.get('ElixirSuite__Is_Consent__c'))){
                                        objectNameToRecords.put(objectName.toLowerCase(), sObj);
                                    }/*else{
                                       // objectNameToRecords.put(objectName.toLowerCase(), sObj);//Added later on insert empty forms too
                                 // commented the above line because causing problem while saving new Form/Note - LX3-6941,6942.
                                    }*/
                                }
                                //FOR Saving Forms - END
                            }
                        }
                    } 
                }  
            }
        }
        if(objectNameToRecords.size()>0){
            List<RecordType> recordTypes = [SELECT Id, Name, SobjectType FROM RecordType WHERE SobjectType IN :objectNameToRecords.keySet()
                                            AND Name =:formName WITH SECURITY_ENFORCED];
            Map<String,Id> objectNameToFormId = new Map<String,Id>();
            if(recordTypes!=null && recordTypes.size()>0){
                for(RecordType rec : recordTypes){
                    objectNameToFormId.put(rec.SobjectType.toLowerCase(), rec.Id);
                }
                for(String objName :objectNameToRecords.keySet()){
                    //AccountId__c is the custom field on Custom Form Object 
                    String objCaseInsensitive = objName.toLowerCase();
                    if(objectNameToFormId.containsKey(objCaseInsensitive)){
                        objectNameToRecords.get(objCaseInsensitive).put('RecordTypeId', objectNameToFormId.get(objCaseInsensitive));
                        objectNameToRecords.get(objCaseInsensitive).put('AccountId__c', accountId);
                                    
                    }
                } 
                upsert objectNameToRecords.values();
                //FORM-OBJECT data passing - START
                changeAccount.Id = accountId;
                
                //FORM-OBJECT data passing - END
                
                //STORING UNIQUE ID - START
                
                String idToCreateNumberUnique = String.valueOf(objectNameToRecords.values()[0].get('id'));
                Integer uniqueIdFromRandomNo = generateRandomNumber();
                uniqueId = String.valueOf(idToCreateNumberUnique) + ';' + String.valueOf(uniqueIdFromRandomNo);
                for(String objName :objectNameToRecords.keySet()){
                    if(objectNameToRecords.get(objName) !=null){
                        objectNameToRecords.get(objName).put('Form_unique_id__c',uniqueId);
                        objectNameToRecords.get(objName).put('Form_Name__c',changedFormName);
                        objectNameToRecords.get(objName).put('Form_RecordType_Name__c',formName);
                        objectNameToRecords.get(objName).put('Form_Category__c',category);
                    }
                }
              //  update objectNameToRecords.values();
                 DMLManager.updateAsUser(objectNameToRecords.values());
                if(sectionIdToImage.size()>0){
                    saveImages(sectionIdToImage, accountId, uniqueId);
                }
                //ADDED LOGIC FOR CARE EPISODE - START
                attachCareEpisode(uniqueId, accountId, formName);
                //ADDED LOGIC FOR CARE EPISODE - END

                attachInventory(uniqueId, accountId, inventoryLst);

                //added by Anmol for LX3-6259
                attachPrescription(uniqueId, accountId, prescriptionLst,selUser,selVia,startTm,endTm);
                //end by Anmol for LX3-6259

                //CONSENT VALUES - START
                if(consentValues.size()>0){
                    for(Form_value__c rec : consentValues){
                        rec.Form_Id__c =  uniqueId;
                    }
                    DMLManager.insertAsUser(consentValues);
                    //insert consentValues;
                }
                //CONSENT VALUES - END
                //Text Generation - START
                if(valueForAutoText.size()>0){
                    saveAutoText(accountId, uniqueId, sectionNos, valueForAutoText);
                }
                if(valueForMacroData.size()>0){
                    saveMacroData(accountId, uniqueId, sectionNumberForMacro, valueForMacroData);
                }
                if(valueForProblemNoteData.size()>0){
                    saveProblemNoteData(accountId, uniqueId, sectionNumberForProblemNote, valueForProblemNoteData);
                }
                if(valueForDiagnosisNoteData.size()>0){
                    saveDiagnosisNoteData(accountId, uniqueId, sectionNumberForDiagnosisNote, valueForDiagnosisNoteData);
                }
                if(valueForProcedureNoteData.size()>0){
                    saveProcedureNoteData(accountId, uniqueId, sectionNumberForProcedureNote, valueForProcedureNoteData);
                }
                //Text Generation - END
                if(defaultValuesSaveObject.size()>0){
                    saveDefaultValues(accountId, commonFields, JSON.serialize(defaultValuesSaveObject));
                }
                
                //STORING UNIQUE ID - END
                FormLabelClass.saveLabel(objectNameToApiNameAndLabel, accountId, uniqueId);
                //Utility to save Label
            }
        }
        else if((isExtCmp && String.isNotBlank(objNameForExtCmp)) || (isMacroTemp && String.isNotBlank(objNameForExtCmp))
                || consentValues.size()!=null && consentValues.size()>0 || isProblemEnabled || isProcedureEnabled || objectNameToRecords.size() == 0){
                    try {
                        if (metadataObjects != null && metadataObjects.size() > 0) {
                            List<RecordType> allRecordTypesAvaialable = [SELECT Id, Name, SobjectType FROM RecordType WHERE SobjectType IN :metadataObjects AND Name =:formName WITH SECURITY_ENFORCED];
                    
                            if (allRecordTypesAvaialable != null && allRecordTypesAvaialable.size() > 0) {
                                String objectName = allRecordTypesAvaialable[0].SobjectType; //'ElixirSuite__Form_Object1__c'; //(new List<String>(metadataObjects))[0];
                                
                                objectNameToRecords.put(objectName.toLowerCase(), Schema.getGlobalDescribe().get(objectName).newSObject());
                                objNameForExtCmp = objectName;
                            }
                        }
                    } catch (Exception e) {
                        ExceptionLog.logError(e);
                    }
                  if(isProcedureEnabled && String.isNotBlank(procedureWrapper)){
                        ElixirOEM_ProcedureOnForms.procedureDataOnForm(procedureWrapper,accountId);
                    }
                    if(deletedProblem!=null && deletedProblem.size()>0){
                        MasterProblemListController.deleteAllProbelm(deletedProblem);
                    }
                    if(toDelProblemFromUpdate!=null && toDelProblemFromUpdate.size()>0){
                        MasterProblemListController.deleteAllProbelm(toDelProblemFromUpdate);
                    }
                    if(isProblemEnabled && String.isNotBlank(toUpdateProblem)){
                        MasterProblemListController.problemInsertFromForm(toUpdateProblem,accountId);
                    }  
                    sObject sObj = Schema.getGlobalDescribe().get(objNameForExtCmp).newSObject(); 
                    List<RecordType> recordTypes = [SELECT Id, Name, SobjectType FROM RecordType WHERE SobjectType= :objNameForExtCmp
                                                    AND Name =:formName WITH SECURITY_ENFORCED];
                    Map<String,Id> objectNameToFormId = new Map<String,Id>();
                    if(recordTypes!=null && recordTypes.size()>0){
                        for(RecordType rec : recordTypes){
                            objectNameToFormId.put(rec.SobjectType.toLowerCase(), rec.Id);
                        }
                        //AccountId__c is the custom field on Custom Form Object 
                        String objCaseInsensitive = objNameForExtCmp.toLowerCase();
                        if(objectNameToFormId.containsKey(objCaseInsensitive)){
                            objectNameToRecords.put(objCaseInsensitive, sObj);
                            objectNameToRecords.get(objCaseInsensitive).put('RecordTypeId', objectNameToFormId.get(objCaseInsensitive));
                            objectNameToRecords.get(objCaseInsensitive).put('Form_Name__c',changedFormName);
                            objectNameToRecords.get(objCaseInsensitive).put('Form_RecordType_Name__c',formName);
                            objectNameToRecords.get(objCaseInsensitive).put('Form_Category__c',category);
                            objectNameToRecords.get(objCaseInsensitive).put('AccountId__c', accountId);
                            upsert objectNameToRecords.values();
                            //FORM-OBJECT data passing - END
                            changeAccount.Id = accountId;
                            try{
                 			 DMLManager.updateAsUser(changeAccount);
                			}
                			catch(Exception e){
                    		ExceptionLog.logError(e);
                			}
                           
                            //update changeAccount;
                            //FORM-OBJECT data passing - END
                            //STORING UNIQUE ID - START
                            String idToCreateNumberUnique = String.valueOf(objectNameToRecords.values()[0].get('id'));
                            Integer uniqueIdFromRandomNo = generateRandomNumber();
                            uniqueId = String.valueOf(idToCreateNumberUnique) + ';' + String.valueOf(uniqueIdFromRandomNo);
                            for(String objName :objectNameToRecords.keySet()){
                                if(objectNameToRecords.get(objName) !=null){
                                    objectNameToRecords.get(objName).put('Form_unique_id__c',uniqueId);
                                    objectNameToRecords.get(objName).put('Form_Name__c',changedFormName);
                                    objectNameToRecords.get(objName).put('Form_RecordType_Name__c',formName);
                                    objectNameToRecords.get(objName).put('Form_Category__c',category);
                                    objectNameToRecords.get(objName).put('AccountId__c', accountId);
                                }
                            }
                           // update objectNameToRecords.values();
                              DMLManager.updateAsUser(objectNameToRecords.values());
                            if(sectionIdToImage.size()>0){
                                saveImages(sectionIdToImage, accountId, uniqueId);
                            }
                            if(consentValues.size()!=null && consentValues.size()>0){
                                for(Form_value__c rec : consentValues){
                                    rec.Form_Id__c =  uniqueId;
                                }  
                                DMLManager.insertAsUser(consentValues); 
                                //insert consentValues;
                            }
                            attachCareEpisode(uniqueId, accountId,formName);  
                            
                            attachInventory(uniqueId, accountId, inventoryLst);
                        }
                    }
                    if(valueForMacroData.size()>0){
                        saveMacroData(accountId, uniqueId, sectionNumberForMacro, valueForMacroData);
                    }
                    if(valueForProblemNoteData.size()>0){
                        saveProblemNoteData(accountId, uniqueId, sectionNumberForProblemNote, valueForProblemNoteData);
                    }
                    if(valueForDiagnosisNoteData.size()>0){
                        saveDiagnosisNoteData(accountId, uniqueId, sectionNumberForDiagnosisNote, valueForDiagnosisNoteData);
                    }
                    if(valueForProcedureNoteData.size()>0){
                        saveProcedureNoteData(accountId, uniqueId, sectionNumberForProcedureNote, valueForProcedureNoteData);
                    }
                }
        if(String.isNotBlank(precriptionData)){
            Map<String, Object> deserializedPrescriptionRecords = (Map<String, Object>) JSON.deserializeUntyped(precriptionData);
            Object selectedUser;
            selectedUser= (Object) deserializedPrescriptionRecords.get('selectedUser');
            Object selectedVia;
            selectedVia = (Object)  deserializedPrescriptionRecords.get('selectedVia');
            Object medicationJSON = (Object) deserializedPrescriptionRecords.get('medicationJSON');
            if(String.isNotBlank(String.valueOf(medicationJSON))){
                SelectionMedicationRecordsApexController.saveData(String.valueOf(medicationJSON),'','',accountId,String.valueOf(system.today()),String.valueOf(System.today()),uniqueId);
            }
        }
        // Save Modular Matrix Data
        if (!String.isBlank(modularMatrixData)) {
            // we have some section with modular matrix
            // String modularMatrixData = '{"1":[{"columns":[{"API":"elixirsuite__string__c","dataType":"text","value":"aditya","columnNumber":0},{"API":"elixirsuite__integer__c","dataType":"number","value":"12","columnNumber":1}],"rowNumber":0}]}';
            ElixirSuite__Form_Value__c modularMatrixFormValue = new ElixirSuite__Form_Value__c(ElixirSuite__Form_Id__c = uniqueId, ElixirSuite__Has_Modular_Matrix_Data__c=true, ElixirSuite__Modular_Matrix_Data_JSON__c=modularMatrixData);
            
            DMLManager.upsertAsUser(modularMatrixFormValue);
            //upsert modularMatrixFormValue;
        }
      /*  //Adding form name to form value name
        List<ElixirSuite__Object_1_css__c> ocss = [SELECT Id,Name,ElixirSuite__Form__c,ElixirSuite__Section_Number__c,
                                             ElixirSuite__Enable_As__c FROM ElixirSuite__Object_1_css__c 
                                             WHERE ElixirSuite__Form__c =: formName AND ElixirSuite__Section_Number__c = 1];*/
        String formValueName = '';
        if(changedFormName == ''){
            formValueName = formName;
        }
        else{
            formValueName = changedFormName;
        }

        //Create Status record on FORM_VALUE__c set 'Open'
        Form_Value__c formDetail = new Form_Value__c(
            Name = formValueName,
            Status__c = 'Open',
            Form_Id__c = uniqueId,
            Account__c = accountId,
            Form_Detail__c = true,
            Form_Name__c = changedFormName);

      /* if(ocss != null  && !ocss.isEmpty()){
            if(String.isNotBlank(ocss[0].ElixirSuite__Enable_As__c)){
                formDetail.ElixirSuite__Enable_As__c = ocss[0].ElixirSuite__Enable_As__c;                
            }
        }
        
        if(lstVisits != null && !lstVisits.isEmpty()){
           formDetail.ElixirSuite__Care_Episode__c = lstVisits[0].Id;
             formDetail.Episode_Id__c= lstVisits[0].Id;
        }*/
            DMLManager.insertAsUser(formDetail);
        //insert formDetail;

        //after insertion of form value attach Problems, Medications ,Allergies ,Vitals and Diagnosis to forms
        updateNotesSpecific(toUpdateNotesSpecific,formDetail.Id);
        
        if(isTimeEnabled){
            handleTimeDataOnForm(uniqueId,accountId,timeWrapper,changedFormName);
        }
        return uniqueId;
    }
    public static void handleTimeDataOnForm(String formUniqueId, String accountId,String timeWrapper,string changedFormName){
        Map<String, Object> deserializedTimeRecords = (Map<String, Object>) JSON.deserializeUntyped(timeWrapper);  
        
        ElixirSuite__Procedure__c p = new ElixirSuite__Procedure__c(
            Name = 'Form - '+changedFormName, 
            ElixirSuite__Account__c = accountId,ElixirSuite__Form_Unique_ID__c = formUniqueId , 
            ElixirSuite__Start_Time__c = compileCleanDateTime('startTime',deserializedTimeRecords),
            ElixirSuite__End_Time__c = compileCleanDateTime('endTime',deserializedTimeRecords),
            RecordtypeId = Schema.SObjectType.ElixirSuite__Procedure__c.getRecordTypeInfosByDeveloperName().get('Patient_Procedure').getRecordTypeId()
        );
        if(Boolean.valueOf(deserializedTimeRecords.get('paramSame'))){
            p.ElixirSuite__End_Time__c = p.ElixirSuite__Start_Time__c.addMinutes(1);
        }
        if(Boolean.valueOf(deserializedTimeRecords.get('setEndTimeAsCurrent'))){
            p.ElixirSuite__End_Time__c = System.now();
        }
        DMLManager.insertAsUser(p);
        //insert p;                                   
    }
    public static DateTime compileCleanDateTime(String getVal, Map<String, Object> deserializedTimeRecords){
        if(String.isNotBlank(String.valueOf(deserializedTimeRecords.get(getVal)))){
            String formatDateTime = String.valueOf(deserializedTimeRecords.get(getVal)).trim();
            formatDateTime = formatDateTime.replace('T', ' ');
            Datetime now = DateTime.valueOf(formatDateTime);
            Integer offset = UserInfo.getTimezone().getOffset(now);
            return now.addSeconds(offset/1000);    
        }
        else {
            return null;
        }
        
    }
    public static void attachCareEpisode(String formUniqueId, String accountId, String changedFormName){
        
           //added by Anmol for LX3-7236
           Elixir_Custom_Setting__c customSetting = Elixir_Custom_Setting__c.getOrgDefaults();
           String careFilter = customSetting.ElixirSuite__Default_Active_Care_Episode_Filter__c;
           if(string.isBlank(careFilter)){
            careFilter = 'createddate desc';
        }
           String careStatus = 'Active';
   
           string querystr = '';
           querystr += 'Select Id,ElixirSuite__Account__c,ElixirSuite__Status__c from ElixirSuite__Visits__c where ElixirSuite__Status__c=:careStatus AND ElixirSuite__Account__c =: accountId WITH SECURITY_ENFORCED order by ';
           querystr += careFilter ;
           List<Visits__c> visits = database.query(querystr);
           //end by Anmol for LX3-7236
           
           //Added this code to attch the Visit note with the careEpisode LX3-9955
            List<ElixirSuite__Object_1_css__c> ocss = [SELECT Id,Name,ElixirSuite__Form__c,ElixirSuite__Section_Number__c,
                                             ElixirSuite__Enable_As__c FROM ElixirSuite__Object_1_css__c 
                                             WHERE ElixirSuite__Form__c =: changedFormName AND ElixirSuite__Section_Number__c = 1 WITH SECURITY_ENFORCED];
            
            
        if(visits!=null && visits.size()>0){
            String formValueName = '';
            if(changedFormName == ''){
                formValueName = 'Form -' + system.now().format();
            }
            else{
                formValueName = changedFormName;
            }
            Form_value__c formValue = new Form_Value__C(
                Name = formValueName,
                Form_Name__c= changedFormName,
                Form_Id__c = formUniqueId,
                Account__c = accountId,
                Is_CareEpisode__c = true,
                Care_Episode__c = visits[0].Id,
                Episode_Id__c = visits[0].Id
            );
             if(ocss != null  && !ocss.isEmpty()){
            if(String.isNotBlank(ocss[0].ElixirSuite__Enable_As__c)){
                formValue.ElixirSuite__Enable_As__c = ocss[0].ElixirSuite__Enable_As__c;                
            }
        }
            DMLManager.insertAsUser(formValue);
            //insert formValue;
        }
    }

      //added by Anmol for LX3-6259
      public static void attachPrescription(String formUniqueId, String accountId, String prescriptionLst, String selUser, String selVia, String startTm, String endTm){

        if(String.isNotBlank(prescriptionLst) && String.isNotBlank(selUser) && String.isNotBlank(selVia) && String.isNotBlank(startTm) && String.isNotBlank(endTm))
        {
            SelectionMedicationRecordsApexController.saveData(prescriptionLst,selUser,selVia,accountId,startTm,endTm,formUniqueId);
        }

        
    }
    //end by Anmol for LX3-6259

      //added by Anmol for Lx3-6230
      public static void attachInventory(String formUniqueId, String accountId, List<Object> invLst){

        if(invLst != null ){


            List<ElixirSuite__Inventory__c> lstInsInv = new List<ElixirSuite__Inventory__c >();
                                                      
            
            Map<String,Integer> lotItemRqMap = new Map<String,Integer>();
            for(Object sObjLoop : invLst){
                Map<String, Object> objRecordParent = ( Map<String, Object>) sObjLoop;
                String lot = String.valueof(objRecordParent.get('Lot'));
                ElixirSuite__Inventory__c invRec = new ElixirSuite__Inventory__c();                                                                
                if(lot!=null){
                
                    invRec.ElixirSuite__Procedure_Codes__c  = String.valueof(objRecordParent.get('proid'));
                    invRec.ElixirSuite__Lot_Item__c  = String.valueof(objRecordParent.get('eid')); // assign the lot item id here
                    invRec.ElixirSuite__Account__c = accountId;
                    invRec.ElixirSuite__Form_Unique_Id__c = formUniqueId;
                    
                    invRec.ElixirSuite__Lot_Number__c  = String.valueof(objRecordParent.get('Lot'));
                    
                    if(!string.isBlank(String.valueof(objRecordParent.get('totalPrice')))){
                        invRec.ElixirSuite__Total_Price__c  = Integer.valueof(objRecordParent.get('totalPrice'));
                        }

                    invRec.ElixirSuite__Inventory_Item_Name__c  = String.valueof(objRecordParent.get('Name'));
                    invRec.ElixirSuite__Units_Procured__c  = Integer.valueof(objRecordParent.get('req'));
                }
            	String lotItemId = String.valueof(objRecordParent.get('eid'));
                
                Integer rq = Integer.valueof(objRecordParent.get('req'));
                
                lotItemRqMap.put(lotItemId,rq);
               

                
                lstInsInv.add(invRec);   
            }
            List<ElixirSuite__Lot_Item__c> lotUpdLst = new List<ElixirSuite__Lot_Item__c>();
            List<ElixirSuite__Lot_Item__c> lotItemRec = [select id,name,ElixirSuite__Available_Qty__c from ElixirSuite__Lot_Item__c where id IN:lotItemRqMap.keySet() WITH SECURITY_ENFORCED];
            for(ElixirSuite__Lot_Item__c lotItem : lotItemRec){
                if(lotItemRqMap.containsKey(lotItem.Id)){
                    lotItem.ElixirSuite__Available_Qty__c = lotItem.ElixirSuite__Available_Qty__c - lotItemRqMap.get(lotItem.Id);
                }
                lotUpdLst.add(lotItem);
            }

            
            
           DMLManager.insertAsUser(lstInsInv);//added by Anmol for LX3-6500
            
           try{
          //  if(ElixirSuite.DeceasedGlobalStopRecursion.run){
                ElixirSuite.DeceasedGlobalStopRecursion.run = false;
                DMLManager.updateAsUser(lotUpdLst);//added by Anmol for LX3-6500
           // }
        }
            catch(Exception e){
            ExceptionLog.logError(e);
        }
            
        }


    }
    //end by Anmol for Lx3-6230

    public static void saveImages(Map<String, String> imgData, String accountId, String formId){
        List<ContentVersion> contents = new List<ContentVersion>();
        //List<ContentDocumentLink> contentLinks = new List<ContentDocumentLink>(); 
        for(String sectionId :imgData.keySet()){
            String img = imgData.get(sectionId);
            String cleanBase64 = img.removeStart('data:image/png;base64,');
            ContentVersion cv = new ContentVersion();
            if(!Test.isRunningTest()){cv.VersionData = EncodingUtil.base64Decode(cleanBase64);}
            else{Blob b=Blob.valueOf('This is version data'); cv.VersionData = b;}
            cv.Title = 'staticDraw'+sectionId;
            cv.PathOnClient ='staticDraw'+sectionId+'.PNG';
            cv.Form_Id__c = formId;
            cv.Form_css_id__c = sectionId;
            contents.add(cv);
        }
        if(contents.size()>0){
            DMLManager.insertAsUser(contents);
            //insert contents;
            List<Attachment> attachments = new List<Attachment>();  
            for(ContentVersion version :contents){
                Attachment attch = new Attachment();
                attch.Body = version.VersionData;
                attch.ContentType = 'PNG';
                attch.ParentId = accountId;
                attch.Name = version.Form_Id__c+'&'+version.Form_css_id__c;
                attachments.add(attch);
            }
            DMLManager.insertAsUser(attachments);
        }
    }
    
    public static Integer generateRandomNumber(){
        Integer idToCreateNumberUnique = Integer.valueof((Math.random() * 1000000000));
        return idToCreateNumberUnique;
    }
    
    public class FormSchema{
        @AuraEnabled public List<Object_1_css__c> cssRecords;
        @AuraEnabled public List<Form_Value__c> formDefaultValues;
        @AuraEnabled public List<FormRenderUtility.FieldSchema> allFields;
        @AuraEnabled public Map<String, sObject> objToData;
        @AuraEnabled public Map<String, sObject> consentData = new Map<String, sObject>();
        @AuraEnabled public String accountName;
        @AuraEnabled public List<Form_Template__c> tempData;
        @AuraEnabled public Map<Id, sObject> formCssToFxValue;
        @AuraEnabled public DateTime currentDateTime;
        @AuraEnabled public Boolean isPatientModeEnabled;
        public FormSchema(List<Object_1_css__c> cssRecords, List<FormRenderUtility.FieldSchema> allFields,
                          List<Form_Value__c> formDefaultValues, Map<String, sObject> objToData, Map<String,sObject> consentData, String accountName,
                          List<Form_Template__c> templateData, Boolean isPatientModeEnabled,DateTime currentDateTime,
                         Map<Id,sObject> formCssToFxValue){
                              this.cssRecords = cssRecords;
                              this.allFields = allFields;
                              this.formDefaultValues = formDefaultValues;
                              this.objToData = objToData;
                              this.consentData = consentData;
                              this.accountName = accountName;
                              this.tempData = templateData;
                              this.isPatientModeEnabled = isPatientModeEnabled;
                              this.currentDateTime = currentDateTime;
                              this.formCssToFxValue = formCssToFxValue;
                          }
    }
    public static void saveDefaultValues(String accountId, List<String> commonFields, String defaultValuesSaveObject){
        Map<String,Form_Value__c> fieldToValues = new Map<String,Form_Value__c>();
        List<Form_Value__c> dbFormValues = [SELECT Id, Field_Api_Name__c, Default1__c, Account__c
                                            FROM Form_Value__c WHERE Account__c =:accountId AND Field_Api_Name__c!=NULL 
                                            WITH SECURITY_ENFORCED
                                            LIMIT 9999]; 
        for(Form_Value__c formValue :dbFormValues){
            fieldToValues.put(formValue.Field_Api_Name__c.toLowerCase(), formValue);
        }       
        List<Form_Value__c> formValues = (List<Form_Value__c>) JSON.deserialize(defaultValuesSaveObject, List<Form_value__c>.class);
        List<Form_Value__c> formValuesToSave = new List<Form_Value__c>();
        Set<Id> duplicates = new Set<Id>();
        Set<String> duplicateFields = new Set<String>();
        for(Form_Value__c formValue :formValues){
            String fieldName = formValue.Field_Api_Name__c.toLowerCase();
            Form_Value__c rec = new Form_Value__c(); 
            if(fieldToValues.containsKey(fieldName)){
                rec = fieldToValues.get(fieldName);
                rec.Default1__c = formValue.Default1__c;
            }else{
                rec = formValue;
            }
            if(duplicates.contains(rec.Id) || duplicateFields.contains(rec.Field_Api_Name__c)){   
                continue;
            }
            formValuesToSave.add(rec);  
            if(String.isNotBlank(rec.Id)){
                duplicates.add(rec.Id);
            }  
            if(String.isNotBlank(rec.Field_Api_Name__c)){
                duplicateFields.add(rec.Field_Api_Name__c);
            }
        }
        DMLManager.upsertAsUser(formValuesToSave);
        //upsert formValuesToSave;
        //Database.upsert(formValuesToSave, false);
    }
    public static void saveAutoText(String accountId, String uniqueId, Set<Integer> sectionNos, List<Form_value__c> valueForAutoText){
        if(sectionNos!=null && sectionNos.size()>0){
            Map<Integer,Form_Value__c> autoTextMap = new Map<Integer,Form_Value__c>();
            List<Form_Value__c> autoTexts = [SELECT Id, Blue_Print__c, Section_Number__c, Is_AutoText__c, Auto_Text__c FROM Form_Value__c
                                             WHERE Section_Number__c IN :sectionNos AND Is_AutoText__c = true AND Form_Id__c=:uniqueId
                                             AND Account__c=:accountId WITH SECURITY_ENFORCED];
            if(autoTexts!=null && autoTexts.size()>0){
                for(Form_Value__c autoText :autoTexts){
                    autoTextMap.put((Integer) autoText.Section_Number__c,autoText);
                }
            }
            if(valueForAutoText!=null && valueForAutoText.size()>0){
                for(Form_Value__c autoText :valueForAutoText){
                    Integer secNo = (Integer) autoText.Section_Number__c;
                    autoText.Form_Id__c = uniqueId;
                    autoText.Account__c = accountId;
                    if(autoTextMap.containsKey(secNo)){
                        autoText.Id = autoTextMap.get(secNo).Id;
                    }
                }
                DMLManager.upsertAsUser(valueForAutoText);
               // upsert valueForAutoText;
            }
        }
    }
    public static void saveMacroData(String accountId, String uniqueId, Set<String> sectNumber, List<Form_Template_Data__c> valueForTempData){
        if(sectNumber!=null && sectNumber.size()>0){
            Map<String,Form_Template_Data__c> macroMap = new Map<String,Form_Template_Data__c>();
            List<Form_Template_Data__c> macroTemp = [SELECT Id,name,Form_Unique_Id__c,Section_Number__c,Form_Data_Description__c FROM Form_Template_Data__c
                                                     WHERE Section_Number__c IN :sectNumber AND Form_Unique_Id__c=:uniqueId
                                                     AND Account__c=:accountId WITH SECURITY_ENFORCED];
            if(macroTemp!=null && macroTemp.size()>0){
                for(Form_Template_Data__c templateMacro :macroTemp){
                    macroMap.put(templateMacro.Section_Number__c,templateMacro);
                }
            }
            
            if(valueForTempData!=null && valueForTempData.size()>0){
                for(Form_Template_Data__c fdata :valueForTempData){
                    fData.Form_Unique_Id__c = uniqueId;
                    fData.Account__c = accountId;
                    String secNo = fdata.Section_Number__c;
                    if(macroMap.containsKey(secNo)){
                        fdata.Id = macroMap.get(secNo).Id;
                    }
                }
                DMLManager.upsertAsUser(ValueForTempData);
               //upsert valueForTempData;
            }
        }
    }
    
    public static void saveProblemNoteData(String accountId, String uniqueId, Set<String> sectNumber, List<Form_Template_Data__c> valueForTempData){
        if(sectNumber!=null && sectNumber.size()>0){
            Map<String,Form_Template_Data__c> macroMap = new Map<String,Form_Template_Data__c>();
            List<Form_Template_Data__c> macroTemp = [SELECT Id,name,Form_Unique_Id__c,Section_Number__c,Form_Data_Description__c,ElixirSuite__Type__c FROM Form_Template_Data__c
                                                     WHERE Section_Number__c IN :sectNumber AND Form_Unique_Id__c=:uniqueId
                                                     AND Account__c=:accountId WITH SECURITY_ENFORCED];
            if(macroTemp!=null && macroTemp.size()>0){
                for(Form_Template_Data__c templateMacro :macroTemp){
                    macroMap.put(templateMacro.Section_Number__c,templateMacro);
                }
            }
            
            if(valueForTempData!=null && valueForTempData.size()>0){
                for(Form_Template_Data__c fdata :valueForTempData){
                    fData.Form_Unique_Id__c = uniqueId;
                    fData.Account__c = accountId;
                    String secNo = fdata.Section_Number__c;
                    if(macroMap.containsKey(secNo)){
                        fdata.Id = macroMap.get(secNo).Id;
                    }
                }
                   DMLManager.upsertAsUser(valueForTempData);
               // upsert ValueForTempData;
            }
        }
    }
    
    
    public static void saveDiagnosisNoteData(String accountId, String uniqueId, Set<String> sectNumber, List<Form_Template_Data__c> valueForTempData){
        if(sectNumber!=null && sectNumber.size()>0){
            Map<String,Form_Template_Data__c> macroMap = new Map<String,Form_Template_Data__c>();
            List<Form_Template_Data__c> macroTemp = [SELECT Id,name,Form_Unique_Id__c,Section_Number__c,Form_Data_Description__c,ElixirSuite__Type__c FROM Form_Template_Data__c
                                                     WHERE Section_Number__c IN :sectNumber AND Form_Unique_Id__c=:uniqueId
                                                     AND Account__c=:accountId WITH SECURITY_ENFORCED];
            if(macroTemp!=null && macroTemp.size()>0){
                for(Form_Template_Data__c templateMacro :macroTemp){
                    macroMap.put(templateMacro.Section_Number__c,templateMacro);
                }
            }
            
            if(valueForTempData!=null && valueForTempData.size()>0){
                for(Form_Template_Data__c fdata :valueForTempData){
                    fData.Form_Unique_Id__c = uniqueId;
                    fData.Account__c = accountId;
                    String secNo = fdata.Section_Number__c;
                    if(macroMap.containsKey(secNo)){
                        fdata.Id = macroMap.get(secNo).Id;
                    }
                }
                   DMLManager.upsertAsUser(valueForTempData);
               // upsert ValueForTempData;
            }
        }
    }
    
    public static void saveProcedureNoteData(String accountId, String uniqueId, Set<String> sectNumber, List<Form_Template_Data__c> valueForTempData){
        if(sectNumber!=null && sectNumber.size()>0){
            Map<String,Form_Template_Data__c> macroMap = new Map<String,Form_Template_Data__c>();
            List<Form_Template_Data__c> macroTemp = [SELECT Id,name,Form_Unique_Id__c,Section_Number__c,Form_Data_Description__c,ElixirSuite__Type__c FROM Form_Template_Data__c
                                                     WHERE Section_Number__c IN :sectNumber AND Form_Unique_Id__c=:uniqueId
                                                     AND Account__c=:accountId WITH SECURITY_ENFORCED];
            if(macroTemp!=null && macroTemp.size()>0){
                for(Form_Template_Data__c templateMacro :macroTemp){
                    macroMap.put(templateMacro.Section_Number__c,templateMacro);
                }
            }
            
            if(valueForTempData!=null && valueForTempData.size()>0){
                for(Form_Template_Data__c fdata :valueForTempData){
                    fData.Form_Unique_Id__c = uniqueId;
                    fData.Account__c = accountId;
                    String secNo = fdata.Section_Number__c;
                    if(macroMap.containsKey(secNo)){
                        fdata.Id = macroMap.get(secNo).Id;
                    }
                }
                
   DMLManager.upsertAsUser(valueForTempData);
                //upsert ValueForTempData;
            }
        }
    }
    
    @AuraEnabled
    public static  ExternalComponents_InsideFormHelper.ExternalComponentsObjectData allergyDataAcctSpeific(String acctId,String notesSpecificData){ 
        ExternalComponents_InsideFormHelper.ExternalComponentsObjectData globalWrapper = ExternalComponents_InsideFormHelper.fetchAllergyData_AccountSpecific(acctId,notesSpecificData);
        return globalWrapper;
        
    }   
   /* @AuraEnabled
    public static  MasterProblemListController.wrapper fetchAccountProblems(String acctId){ 
        MasterProblemListController.wrapper globalWrapper =   MasterProblemListController.problemList(acctId);
        return globalWrapper;        
    } */
    
    
    @AuraEnabled
    public static List<ElixirSuite__Dataset1__c> fetchAccountProblems(String acctId, List<String> problemIds) {
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
        query += ' FROM ' + objectName + ' WHERE ElixirSuite__Account__c = \'' + String.escapeSingleQuotes(acctId) + '\'';
        query += ' AND ID IN : problemIds';
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
        		dataTypeToApi.put(fieldApiName , fieldType);
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
public static List<ElixirSuite__ICD_Codes__c> fetchAccountDiagnosis(String acctId,List<String> diagnosisIds) {
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

    query += ' FROM ' + objectName + ' WHERE ElixirSuite__Account__c = \'' + String.escapeSingleQuotes(acctId) + '\'';
    query += ' AND ID IN : diagnosisIds';
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
    public static string getDiagnosisColumns(){
        try {
            Elixir_Custom_Setting__c mc = Elixir_Custom_Setting__c.getOrgDefaults();
            return mc.ElixirSuite__Diagnosis_Column__c;
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
                System.debug('field-->'+field);
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
public static List<ElixirSuite__Prescription_Order__c> fetchAccountMedication(String acctId,List<String> medicationIds) {
    Elixir_Custom_Setting__c mc = Elixir_Custom_Setting__c.getOrgDefaults();
    String medicationData = mc.ElixirSuite__Medication_Data_Limit_On_Notes__c;
 
         //Boolean includePatientSpecificMedication = mc.ElixirSuite__Patient_Specific_Medication__c;
    Id medicationRecordType = Schema.SObjectType.ElixirSuite__Prescription_Order__c.getRecordTypeInfosByDeveloperName().get('Medication').getRecordTypeId();

    String objectName = 'ElixirSuite__Prescription_Order__c';
    String conditionField = 'ElixirSuite__Account__c';
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

    query += ' FROM ' + objectName + ' WHERE ' + conditionField + ' = \'' + String.escapeSingleQuotes(acctId) + '\'';
    query += ' AND ID IN : medicationIds';
       /*  if ( includePatientSpecificMedication == false) {
            // Append patient-specific vitals condition to the query
            query += ' AND ' + 'ElixirSuite__Form_Specific_Medication__c = true'; // Replace with the actual field name
        }*/
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



    @AuraEnabled
    public static void deleteAllProblemSavedFromForm(List<String> recIds,String[] procedureId){ 
        MasterProblemListController.deleteAllProbelm(recIds);
       // delete [SELECT ID FROM ElixirSuite__Procedure__c WHERE ID IN : procedureId];
         DMLManager.deleteAsUser([SELECT ID FROM ElixirSuite__Procedure__c WHERE ID IN : procedureId]);
    }
    public class AllDataForProblemUtilityWrapper{
        
        @AuraEnabled  public  list<Notes__c> toUpdateNotes;
        @AuraEnabled  public List<String> diagnoseToDel;
        @AuraEnabled  public List<String> problemToDel;
        @AuraEnabled  public List<sObject> toUpdateProblemsOnForm;
        @AuraEnabled  public String allNotes;
        @AuraEnabled  public String problemDaignosesDataToSave;
        
    }
    
    public class Problems{
        List<DeserializeWrapper> problems;
    }
    public class DeserializeWrapper{
        public String id;
        public String fieldName;
        public String description;
    }
    
    
    //added by user-----------------
    //
    //
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
    public static void updateNotesSpecific(String toUpdateNotesSpecific,String formId){
        Map<String, Object> lstOfPayload =(Map<String, Object>) JSON.deserializeUntyped(toUpdateNotesSpecific);
        List<Object> listOfProblems = (List<Object>) lstOfPayload.get('problemData');
        List<Object> listOfDiagnosis = (List<Object>) lstOfPayload.get('diagnosisData');
        List<Object> listOfMedication = (List<Object>) lstOfPayload.get('medicationData');
        List<Object> listOfAllergy = (List<Object>) lstOfPayload.get('allergyData');
        List<Object> listOfVital = (List<Object>) lstOfPayload.get('vitalData');
        
        if(listOfProblems != null && !listOfProblems.isEmpty()){
            List<String> objAsStrings = (List<String>) JSON.deserialize(JSON.serialize(listOfProblems), List<String>.class);

            List<ElixirSuite__Dataset1__c> lstProblems = [Select Id,ElixirSuite__Form_Value__c from ElixirSuite__Dataset1__c WHERE Id IN : objAsStrings WITH SECURITY_ENFORCED];
            for(ElixirSuite__Dataset1__c ds : lstProblems){
                ds.ElixirSuite__Form_Value__c = formId;
            }

            if(lstProblems.size() > 0){
                DMLManager.updateAsUser(lstProblems);
            }
        }

        if(listOfDiagnosis != null && !listOfDiagnosis.isEmpty()){
            List<String> objAsStrings = (List<String>) JSON.deserialize(JSON.serialize(listOfDiagnosis), List<String>.class);

            List<ElixirSuite__ICD_Codes__c> lstDiagnosis = [Select Id,ElixirSuite__Form_Value__c from ElixirSuite__ICD_Codes__c WHERE Id IN : objAsStrings WITH SECURITY_ENFORCED];
            for(ElixirSuite__ICD_Codes__c ds : lstDiagnosis){
                ds.ElixirSuite__Form_Value__c = formId;
            }

            if(lstDiagnosis.size() > 0){
                DMLManager.updateAsUser(lstDiagnosis);
            }
        }

        if(listOfMedication != null && !listOfMedication.isEmpty()){
            List<String> objAsStrings = (List<String>) JSON.deserialize(JSON.serialize(listOfMedication), List<String>.class);

            List<ElixirSuite__Prescription_Order__c> lstMedication = [Select Id,ElixirSuite__Form_Value__c from ElixirSuite__Prescription_Order__c WHERE Id IN : objAsStrings WITH SECURITY_ENFORCED];
            for(ElixirSuite__Prescription_Order__c po : lstMedication){
                po.ElixirSuite__Form_Value__c = formId;
            }

            if(lstMedication.size() > 0){
                DMLManager.updateAsUser(lstMedication);
            }
        }
        
        if(listOfAllergy != null && !listOfAllergy.isEmpty()){
            List<String> objAsStrings = (List<String>) JSON.deserialize(JSON.serialize(listOfAllergy), List<String>.class);

            List<ElixirSuite__Medical_Examination__c> lstAllergy = [Select Id,ElixirSuite__Form_Value__c from ElixirSuite__Medical_Examination__c WHERE Id IN : objAsStrings WITH SECURITY_ENFORCED];
            for(ElixirSuite__Medical_Examination__c alg : lstAllergy){
                alg.ElixirSuite__Form_Value__c = formId;
            }

            if(lstAllergy.size() > 0){
                DMLManager.updateAsUser(lstAllergy);
            }
        }
        
        if(listOfVital != null && !listOfVital.isEmpty()){
            List<String> objAsStrings = (List<String>) JSON.deserialize(JSON.serialize(listOfVital), List<String>.class);

            List<ElixirSuite__Medical_Examination__c> lstVital = [Select Id,ElixirSuite__Form_Value__c from ElixirSuite__Medical_Examination__c WHERE Id IN : objAsStrings WITH SECURITY_ENFORCED];
            for(ElixirSuite__Medical_Examination__c vital : lstVital){
                vital.ElixirSuite__Form_Value__c = formId;
            }

            if(lstVital.size() > 0){
                DMLManager.updateAsUser(lstVital);
            }
        }

    }
}
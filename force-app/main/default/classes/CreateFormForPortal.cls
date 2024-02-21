/**
* @description       : 
* @author            : ChangeMeIn@UserSettingsUnder.SFDoc
* @group             : 
* @last modified on  : 02-09-2023
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class CreateFormForPortal {
    public static SObject getNewSobject(String t) {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();   
        Schema.SObjectType st = gd.get(t);
        System.assert(st != null,'Type provided: "' + t + '" doesnt map to an sobject token in this org.');
        Sobject s = st.newSobject();
        return s;
    }
    @Future 
    public static void createForm(String accountId,List<String> formsToSendOnPortal){  
        
        try{
            List<Form_Value__c> consentValues = new List<Form_Value__c>();
        List<Object_1_css__c> cssRecords = new List<Object_1_css__c>();
        
        
            List<String> allObjectForForms =   ElixirOEM_DependentPicklist.fetchAllValidObject();
            if(allObjectForForms!=null && allObjectForForms.size()>0){
                
                List<ObjectAndRecordTypeAsForm> objectsForFormCreate = new List<ObjectAndRecordTypeAsForm>();
                objectsForFormCreate = findObjectsPerRecordType(allObjectForForms,formsToSendOnPortal);
                
                Sobject[] formsToinsert = new List<sobject>();
                ElixirSuite__Form_Value__c[] formValues = new List<ElixirSuite__Form_Value__c>();
                List<CareEpisodeHandler> cleanCP = new List<CareEpisodeHandler>();
                for(ObjectAndRecordTypeAsForm obj : objectsForFormCreate){
                cssRecords = fetchFormData(accountId,formsToSendOnPortal);
                    if(ElixirOEM_FormConfigurationHelper.isObjectExist(obj.objectName)){
                        Sobject s = getNewSObject(obj.objectName);  
                        String accID = accountId;
                       
                        s.put('AccountId__c' , accID);  
                        Integer uniqueIdFromRandomNo = generateRandomNumber(); 
                        s.put('Form_unique_id__c',accountId + ';' + String.valueOf(uniqueIdFromRandomNo));
                        s.put('Form_RecordType_Name__c',obj.formName); 
                        s.put('Form_Name__c',obj.formName); 
                        s.put('Form_Category__c','Form');                       
                        s.put('RecordtypeId',fetchRTID(obj.objectName,obj.formName)); 
                        s.put('Is_Patient_Portal_Form__c' , 'Portal Form');
                        CareEpisodeHandler cpobj = new CareEpisodeHandler();
                        cpobj.changedFormName = String.valueOf(s.get('Form_Name__c'));
                        cpobj.formUniqueId = String.valueOf(s.get('Form_unique_id__c'));
                        cleanCP.add(cpobj);
                        formsToinsert.add(s);
                        ElixirSuite__Form_Value__c formDetail = new ElixirSuite__Form_Value__c();
                        formDetail.ElixirSuite__Status__c = 'Waiting For Patient';
                        formDetail.ElixirSuite__Form_Portal_Status__c = 'New'; 
                        formDetail.ElixirSuite__Form_Id__c = accountId + ';' + String.valueOf(uniqueIdFromRandomNo);
                        formDetail.ElixirSuite__Account__c = accID;
                        formDetail.ElixirSuite__Form_Detail__c = true;
                        formDetail.ElixirSuite__Form_Name__c=obj.formName;
                        formDetail.ElixirSuite__Patient_Notified__c=System.now();
                        //insert formDetail;
                        formValues.add(formDetail); 
                    
                    for(Object_1_css__c record : cssRecords){
                        for(Object_1_css__c row : record.ElixirSuite__Object_1_css__r){
                            Integer secNo = Integer.valueOf(record.ElixirSuite__Section_Number__c);
                            Integer rowNo = Integer.valueOf(row.ElixirSuite__Row__c);
                            Integer columnNo = Integer.valueOf(row.ElixirSuite__Column__c);
                            String objectName = String.valueOf(row.ElixirSuite__Object_Name__c);
                            
                            /*if(objectName == 'ONLYTEXT'){
                                continue;
                   			 }*/
                            switch on objectName {
                                when 'ONLYTEXT' {
                                     continue;
                                }
                            }
                            String fieldName = String.valueOf(row.ElixirSuite__Field_Name__c);
                            if(Boolean.valueOf(row.ElixirSuite__Is_Consent__c)){
                                
                                     Object_1_css__c[] obcss = new List<Object_1_css__c>();
                                obcss.add(row);
                                populateConsentValuePortal(fieldName, obcss, consentValues,
                                                           secNo, rowNo, columnNo, accountId,true,accountId + ';' + String.valueOf(uniqueIdFromRandomNo));  
                    
                                continue;
                            }
                        }
                    }
                }
                
            }
            
            //CONSENT VALUES - START
            if(consentValues.size()>0){
                DMLManager.insertAsUser(consentValues);
            }
                
                DMLManager.insertAsUser(formsToinsert);
                generateCareEpisode(accountId,cleanCP);
                DMLManager.insertAsUser(formValues);
               // insert formValues;
               ElixirSuite__Elixir_Custom_Setting__c settings = ElixirSuite__Elixir_Custom_Setting__c.getOrgDefaults();
                try{
                    //When the custom setting ElixirSuite__Notification_for_New_Form__c is enabled in Elixir_Custom_Setting__c, it allows sending notifications to the patient.
                    if(settings.ElixirSuite__Notification_for_New_Form__c == true &&
                        settings.ElixirSuite__Enable_portal_in_Elixir__c == true){
                        notifyPatientForNewForms(formsToSendOnPortal,accountId);
                      }
                   
                }
                catch(Exception e){
                    ExceptionLog.logError(e);
                }
            } 
        }  
        catch(Exception e){
                    ExceptionLog.logError(e);
                }
        
        }
    
    public static void populateConsentValuePortal(String fieldName,List<Object_1_css__c> columnMapList, List<Form_Value__c> consentValues,
                                                  Integer secNo, Integer rowno, Integer columnNo, String accountId,Boolean isClone,String formId){

                                                      try{
                                                           if(columnMapList != NULL && columnMapList.size() > 0){
                                                          Object_1_css__c columnMap =columnMapList[0];
                                                      
                                                      String defaultText = columnMap.ElixirSuite__Default_text__c;
                                                      String inputJSON = '';
                                                      //String consentPdf = columnMap.ElixirSuite__Default_text__c;
                                                      
                                                      list<String> checkSobject = new list<String>();
                                                      
                                                      Pattern pattern = Pattern.compile('\\{[^}]+\\}');
                                                      Matcher matcher;
                                                      if(String.isNotBlank(defaultText)){
                                                           matcher = pattern.matcher(defaultText);
                                                      }
                                                      
                                                      while (matcher.find()) {
                                                          String matchWithBraces = matcher.group();
                                                          String matchWithoutBraces = matchWithBraces.remove('{').remove('}');
                                                          
                                                          if(String.isNotBlank(matchWithoutBraces)){
                                                              if(matchWithoutBraces.contains('.')){
                                                                  checkSobject = matchWithoutBraces.splitByCharacterTypeCamelCase();
                                                                
                                                                  String objectName = checkSobject[0];
                                                                  String objectFieldName = checkSobject[2];
                                                                  if(objectName == 'Account'){
                                                                      if(objectFieldName == 'Id'){
                                                                           defaultText = defaultText.replace(matchWithBraces, accountId); // replace with account id received in parameter
                                                                      }
                                                                      else{
                                                                          String query = 'Select ' + objectFieldName + ' FROM ' + objectName + ' WHERE Id =: accountId';
                                                                          List<Account> fetchData = executeDynamicSOQLQuery(query);
                                                                          if(fetchData != null && !fetchData.isEmpty()){
                                                                              defaultText = defaultText.replace(matchWithBraces, String.valueOf(fetchData[0].get(objectFieldName)));
                                                                          }
                                                                      }
                                                                  }
                                                                  if(objectName == 'User'){
                                                                      String userId = UserInfo.getUserId();
                                                                      
                                                                      if(objectFieldName == 'Id'){
                                                                          defaultText = defaultText.replace(matchWithBraces, userId); // replace with user id
                                                                      }
                                                                      else{
                                                                          
                                                                          String query = 'Select ' + objectFieldName + ' FROM ' + objectName + ' WHERE Id =: userId';
                                                                          
                                                                          list<User> fetchData = executeDynamicQuery(query);
                                                                          if(fetchData != null && !fetchData.isEmpty()){
                                                                              defaultText = defaultText.replace(matchWithBraces, String.valueOf(fetchData[0].get(objectFieldName)));
                                                                          }
                                                                      }
                                                                  } 
                                                              }
                                                              else{
                                                                  //matchWithoutBraces,defaultText,matchWithBraces,inputJSON
                                                                  if(matchWithoutBraces == 'date' || matchWithoutBraces == 'input' || matchWithoutBraces == 'datetime-local'){
                                                                      String random = String.valueOf(Math.floor(Math.random() * 10000000)); 
                                                                      defaultText = defaultText.replace(matchWithBraces, '{' + random.substringBefore('.') + '#' + matchWithoutBraces + '}');
                                                                      
                                                                      if(String.isNotBlank(inputJSON)){
                                                                          inputJSON += ',"'+random.substringBefore('.')+'":""';
                                                                      }
                                                                      else{
                                                                           inputJSON = '{"'+random.substringBefore('.')+'":""';
                                                                      }
                                                                  }
                                                                  else if(matchWithoutBraces == 'checkbox'){
                                                                      String random = String.valueOf(Math.floor(Math.random() * 10000000)); 
                                                                      defaultText = defaultText.replace(matchWithBraces, '{' + random.substringBefore('.') + '#' + matchWithoutBraces + '}');
                                                                      if(String.isNotBlank(inputJSON)){
                                                                          inputJSON += ',"'+random.substringBefore('.')+'":false';
        }
                                                                      else{
                                                                           inputJSON = '{"'+random.substringBefore('.')+'":false';
                                                                      }
                                                                  }
                                                                  
                                                              }
                                                          }
                                                      }
                                                      if(String.isNotBlank(inputJSON)){
                                                          inputJSON += '}';
                                                      }
                                                      
                                                      
                                                      
                                                      Form_Value__c consentRec = new Form_Value__c();
    
                                                      consentRec.Account__c = accountId;
                                                      consentRec.Section_Number__c = secNo;
                                                      consentRec.Row_Number__c = rowNo;
                                                      consentRec.Column_Number__c = columnNo;
                                                      consentRec.Is_Consent__c= true;
                                                      if(String.isNotBlank(defaultText)){
                                                          consentRec.Consent_Default_Text__c = defaultText;
                                                      }
                                                      consentRec.Consent_Pdf__c = defaultText;
                                                      consentRec.Consent_Input_JSON__c = inputJSON;
                                                      consentRec.ElixirSuite__Form_Id__c = formId;
                                                      consentValues.add(consentRec);
                                                      }
                                                      }
                                                      catch(Exception e){
                    ExceptionLog.logError(e);
                }
                                                     }
                                                  
    
    public static List<Object_1_css__c> fetchFormData(String accountId,List<String> formsToSendOnPortal){
        return [SELECT Id,Auto_text__c,Enable_Auto_text__c,Hide_Selections__c,Consent_Query__c,ElixirSuite__Add_Problem__c,
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
                Form__c IN : formsToSendOnPortal AND Section_Number__c!=NULL AND Section_Number__c!=0 WITH SECURITY_ENFORCED
                ORDER BY Section_Number__c ASC];
    }
    public static List<Account> executeDynamicSOQLQuery(String query) {
    // Escape single quotes in the query string
    return Database.query(String.escapeSingleQuotes(query));
	}
    public static List<User> executeDynamicQuery(String userQuery) {
    // Escape single quotes in the query string
    return Database.query(String.escapeSingleQuotes(userQuery));
	}
    public static void generateCareEpisode(String accountId,List<CareEpisodeHandler> cleanCP)
    {
        List<Visits__c> visits = new List<Visits__c>();
        visits = fetchVisitList(accountId);    
        List<Form_value__c> formValueLst = new List<Form_value__c>();
        for(CareEpisodeHandler cp : cleanCP){
            attachCareEpisode(cp.formUniqueId,accountId,cp.changedFormName,visits,formValueLst );
        }          
        DMLManager.insertAsUser(formValueLst);
    }
    public static  List<Visits__c> fetchVisitList(String accountId){
        
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

      return lstVisits;

    }
    public static void attachCareEpisode(String formUniqueId, String accountId, String changedFormName,List<Visits__c> visits,List<Form_value__c> formValueLst){
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
            formValueLst.add(formValue);
            //insert formValue;
        }
    }
    
    public static String fetchRTID(String obType,String recordTypeName){
        SObject record = Database.query('SELECT Id,name FROM recordtype where SobjectType = : obType and name = : recordTypeName');
        return (String)record.get('Id');
    }
    public static void notifyPatientForNewForms(List<String> allFormNames,String accountId){
        String htmlFormNames = '';
        for(String s : allFormNames){
            htmlFormNames = htmlFormNames + s + '<br/>';
        }
        Account acc = [SELECT ID,Name,ElixirSuite__Email_Id__c FROM Account where id = :AccountId WITH security_enforced];
        EmailTemplate emailTemplate = [select Id, Subject, HtmlValue, Body from EmailTemplate where Id =: fetchEmailTemplateId('Patient_Notification_for_New_Forms') WITH security_enforced];
        String htmlBody = emailTemplate.HtmlValue;
        
        //Elixir_Custom_Setting__c portalUrl = [SELECT Elixir_portal_url__c  FROM Elixir_Custom_Setting__c];
        Elixir_Custom_Setting__c portalUrl = ElixirSuite__Elixir_Custom_Setting__c.getOrgDefaults();
        
        htmlBody = htmlBody.replace('{!Account.Name}',acc.Name); 
        htmlBody = htmlBody.replace('{AllForms}', htmlFormNames);
        htmlBody = htmlBody.replace('{!Organization.Name}', UserInfo.getOrganizationName());
        htmlBody = htmlBody.replace('{Patientportallink}', '<a href='+ portalUrl.Elixir_portal_url__c+ '>click here</a>');
        // process the merge fields
        String subject = emailTemplate.Subject;
       // subject = subject.replace('{!Organization.Name}',UserInfo.getOrganizationName()); 
        String plainBody = emailTemplate.Body;
        
        List<OrgWideEmailAddress> specificOrgWideEmailAddress = [SELECT Id, Address FROM OrgWideEmailAddress LIMIT 1];
        //build the email message
        Messaging.Singleemailmessage email = new Messaging.Singleemailmessage();
        email.setTargetObjectId(UserInfo.getUserId());
        email.setSaveAsActivity(false);
        email.setTreatTargetObjectAsRecipient(false);
        email.setToAddresses(new List<String>{acc.ElixirSuite__Email_Id__c}); 
        if(specificOrgWideEmailAddress!=null && specificOrgWideEmailAddress.size() >0){
            email.setOrgWideEmailAddressId(specificOrgWideEmailAddress[0].Id);   
          }      
        email.setSubject(subject);
        email.setHtmlBody(htmlBody);
        email.setPlainTextBody(plainBody);           
        Messaging.sendEmail(new Messaging.SingleEmailmessage[] {email});  

        String userId = UserInfo.getUserId();
        //Inserting a record in message subject 
        Message_Subject__c messageSubject = new Message_Subject__c();
        messageSubject.Subject__c = subject;
        messageSubject.Account__c = accountId;
        messageSubject.IsPortal__c = false;
        messageSubject.User__c = userId;
        DMLManager.insertAsUser(messageSubject);
        
        //Inserting a record in message Detail 
        Message_Details__c messageDetails = new Message_Details__c();
        messageDetails.Message_Body__c = htmlBody;
        messageDetails.lookup_Message_Subject__c = messageSubject.Id;
        DMLManager.insertAsUser(messageDetails);
     }
    
    public static List<ObjectAndRecordTypeAsForm> findObjectsPerRecordType(List<String> allObjectForForms , List<String> formsToSendOnPortal){
        List<ObjectAndRecordTypeAsForm> lstObjForm = new List<ObjectAndRecordTypeAsForm>();
        
        
        for(String sObj : formsToSendOnPortal){
            for(String formObj : allObjectForForms){
                Set<String> allRecordTypePerObject = new Set<String>();
                allRecordTypePerObject =  fetchRecordTypeByObject(formObj).keySet();
                
                if(allRecordTypePerObject.contains(sObj)){
                    ObjectAndRecordTypeAsForm formObjToCreate = new ObjectAndRecordTypeAsForm();
                    formObjToCreate.objectName = formObj;
                    formObjToCreate.formName = sObj;
                    lstObjForm.add(formObjToCreate);
                }
            }            
        }
        return lstObjForm;
    }
    public static Integer generateRandomNumber(){
        Integer idToCreateNumberUnique = Integer.valueof((Math.random() * 1000000000)); 
        return idToCreateNumberUnique; 
    }
    public static   Map<String,String> fetchRecordTypeByObject(String objectName){
        Map<String,String> conversionMap = new Map<String,String>();
        if(ElixirOEM_FormConfigurationHelper.isObjectExist(objectName)){
            Map<String, Schema.SObjectType> m = Schema.getGlobalDescribe() ;
            Schema.SObjectType s = m.get(objectName) ;
            
            Schema.DescribeSObjectResult cfrSchema = s.getDescribe() ;
            Map<ID,Schema.RecordTypeInfo> recordTypeInfo = cfrSchema.getRecordTypeInfosByID();
            Map<id, Schema.RecordTypeInfo> recordTypeByIdMap = recordTypeInfo;
            for(String r:recordTypeByIdMap.keySet())
            {    
                conversionMap.put(recordTypeByIdMap.get(r).getName(),recordTypeByIdMap.get(r).getDeveloperName());    
            }
        }
        return conversionMap;
    }
    public class ObjectAndRecordTypeAsForm{
        public String objectName;
        public string formName;
    }
    public class CareEpisodeHandler {
        public  String formUniqueId;
        public  String accountId;
        public  String changedFormName;
    }
     public static String fetchEmailTemplateId(String templateDevName){
        Schema.DescribeSObjectResult emailTemplateDescribe = EmailTemplate.sObjectType.getDescribe();
        
        // Get the ID field for the EmailTemplate object
        Schema.SObjectField idField = emailTemplateDescribe.fields.getMap().get('Id');
        
        // Get the DeveloperName field for the EmailTemplate object
        Schema.SObjectField devNameField = emailTemplateDescribe.fields.getMap().get('DeveloperName');
        
        // Build the query to find the Email Template
        String query = 'SELECT ' + idField  + ' FROM ' + emailTemplateDescribe.getName() + ' WHERE ' + devNameField + ' = \'' + String.escapeSingleQuotes(templateDevName)+ '\'';
        
        return  (Id)Database.query(query)[0].get(idField);
        
    }
}
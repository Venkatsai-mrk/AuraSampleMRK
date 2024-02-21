/**
* @description       : 
* @author            : ChangeMeIn@UserSettingsUnder.SFDoc
* @group             : 
* @last modified on  : 02-15-2023
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class Elixir_NewAccountAssociatedFormsApex {
    
    @AuraEnabled
    public static String getPortalUrl(){
        String url;
        Elixir_Custom_Setting__c orgDefalutValues = Elixir_Custom_Setting__c.getOrgDefaults();
        if(String.isNotBlank(orgDefalutValues.Elixir_portal_url__c)){
            url = orgDefalutValues.Elixir_portal_url__c;
        }
        
        return url;
    }
    
    @AuraEnabled
    public static List<Master_Object__c> getCustomForms(String actionType){
        Id recordTypeId = Schema.SObjectType.ElixirSuite__Master_Object__c.getRecordTypeInfosByDeveloperName().get('Custom_forms').getRecordTypeId();
        List<Master_Object__c> customForms = new List<Master_Object__c>();

        customForms = [SELECT Id, Form_name__c, Component_attributes__c, Action__c, Component_name__c
                       FROM Master_Object__c
                       WHERE RecordTypeId =: recordTypeId
                       AND Action__c =:actionType
                       WITH SECURITY_ENFORCED];
        
        
        return customForms;
    }

    @AuraEnabled
    public static Boolean checkExpiry(String formName){
        Boolean isExpired = false;
        List<Object_1_css__c> section1Records = [SELECT ElixirSuite__Form__c, ElixirSuite__isActive__c, ElixirSuite__Expiry_Date__c
                                                 FROM ElixirSuite__Object_1_css__c
                                                 WHERE ElixirSuite__Section_Number__c = 1
                                                 AND ElixirSuite__isActive__c = true
                                                 AND ElixirSuite__Form__c =: formName
                                                 WITH SECURITY_ENFORCED];
        if(section1Records.isEmpty()){
               isExpired = true; 
        }      
        
        return isExpired;
    }
    
    @AuraEnabled
    public static wrapperForAccName fetchAllForms(String category , String subCategory, String accountId){
        Set<String> formNames = new Set<String>();
        List<Form_Object__mdt> metadata = [SELECT Id, QualifiedApiName, Object_Name__c FROM Form_Object__mdt WHERE Object_Name__c!=NULL AND DeveloperName='Object_Names' WITH SECURITY_ENFORCED LIMIT 1];//Getting metadata
        if(metadata!=null && metadata.size()>0){
            Set<String> metadataObjects = new Set<String>();
            metadataObjects = new Set<String>(metadata[0].Object_Name__c.split(';'));
            List<RecordType> recordTypes;
            if(String.isBlank(category)){
                recordTypes = [SELECT Id, Name, DeveloperName, NamespacePrefix, SobjectType, IsActive FROM RecordType
                               WHERE IsActive = true AND SobjectType IN :metadataObjects AND DeveloperName LIKE'EHR%' AND (NOT DeveloperName LIKE '%Admission') WITH SECURITY_ENFORCED];
            }
            else{
                category = '%'+category;
                recordTypes = [SELECT Id, Name, DeveloperName, NamespacePrefix, SobjectType, IsActive FROM RecordType
                               WHERE IsActive = true AND SobjectType IN :metadataObjects AND DeveloperName LIKE'EHR%' AND DeveloperName LIKE : category WITH SECURITY_ENFORCED];
            }
            
            List<Object_1_css__c> section1Records = [SELECT ElixirSuite__Form__c, ElixirSuite__isActive__c, ElixirSuite__Expiry_Date__c
                                                     FROM ElixirSuite__Object_1_css__c
                                                     WHERE ElixirSuite__Section_Number__c = 1  WITH SECURITY_ENFORCED];
            
            // some forms are disabled using activate/deactivate and expiry date
            // pick forms which are not disabled in formNamesToShow
            List<String> formNamesToShow = new List<String>();
            for (Object_1_css__c i : section1Records) {
                if (
                    i.ElixirSuite__isActive__c == true &&
                    (i.ElixirSuite__Expiry_Date__c == null || i.ElixirSuite__Expiry_Date__c > Datetime.now())
                ) {
                    formNamesToShow.add(i.ElixirSuite__Form__c);
                }
            }    
            
            if(recordTypes!=null && recordTypes.size()>0){
                for(RecordType form :recordTypes){
                    if (formNamesToShow.contains(form.Name)) {
                        formNames.add(form.Name);
                    }
                }
            }
        }
        wrapperForAccName wrpr = new wrapperForAccName();
        
        List<Account> listOfAcc = [SELECT Id , Verification_Code__c , Name FROM Account 
                                   WHERE Id= : accountId WITH SECURITY_ENFORCED];
        wrpr.accName = listOfAcc[0].name;
        wrpr.passCode =  String.valueOf(listOfAcc[0].Verification_Code__c);
        wrpr.formNames = new List<String>(formNames);
        wrpr.isSendPortalButtonEnabled = sendFormsToPortalAbility();
        return wrpr;
    }
    @AuraEnabled
    public static Boolean sendFormsToPortalAbility(){
        ElixirSuite__Elixir_Custom_Setting__c listCS = ElixirSuite__Elixir_Custom_Setting__c.getOrgDefaults();
        if(listCS!=null){
            return listCS.ElixirSuite__Enable_Send_Forms_To_Portal__c;
        }
        else {
            return null;
        }
    }
    
    @AuraEnabled
    public static List<FormWrapper> bringDataForpatientPortalUser(String accountId , String category , String subCategory,String route,List<String> setOfFormIds){
        try{ 
            Set<String> uniqueIds = new Set<String>();
            List<FormWrapper> forms = new List<FormWrapper>();
            List<Form_Object__mdt> metadata = [SELECT Id, QualifiedApiName,  Object_Name__c from Form_Object__mdt WHERE Object_Name__c!=NULL AND DeveloperName='Object_Names'  WITH SECURITY_ENFORCED LIMIT 1];//Getting metadata
            if(metadata!=null && metadata.size()>0){
                Set<String> metadataObjects = new Set<String>();
                metadataObjects = new Set<String>(metadata[0].Object_Name__c.split(';'));
                Map<String,String> unqiueIdToFormName = new Map<String,String>();
                for(String objName : metadataObjects){
                    sObject sObj;
                    try{
                        sObj = Schema.getGlobalDescribe().get(objName).newSObject(); 
                    }catch(Exception e){
                        continue;
                    }
                    Integer flag = 0;
                    Set<String> objs = new Set<String>();
                    for(String field :sObj.getSobjectType().getDescribe().fields.getMap().keySet()){
                        if(field.endsWithIgnoreCase('accountid__c')){
                            objs.add(field);
                        }else if(field.endsWithIgnoreCase('form_unique_id__c')){
                            objs.add(field);
                        }else if(field.endsWithIgnoreCase('form_name__c')){
                            objs.add(field);
                        }
                    }
                    if(objs.size()==3){
                        flag = 1;
                    }
                    if(objName.endsWithIgnoreCase('__c') && flag == 1){
                        
                        String defineQuery='';
                        if(route== 'referralSelectedForms'){
                            defineQuery = 'SELECT Id,CreatedBy.Name,RecordType.Name,Is_Patient_Portal_Form__c,Form_Category__c ,CreatedDate,RecordType.DeveloperName,AccountId__c,Form_RecordType_Name__c,Form_unique_id__c,Form_name__c FROM '+ String.escapeSingleQuotes(objName) + ' WHERE AccountId__c =:accountId AND Is_Patient_Portal_Form__c = true AND Form_unique_id__c IN : setOfFormIds order by createddate DESC';
                        }
                        else {
                            if(String.isEmpty(category)){
                                defineQuery = 'SELECT Id,CreatedBy.Name,RecordType.Name,Form_Category__c ,Is_Patient_Portal_Form__c,CreatedDate,RecordType.DeveloperName,AccountId__c,Form_RecordType_Name__c,Form_unique_id__c,Form_name__c FROM '+ String.escapeSingleQuotes(objName) + ' WHERE AccountId__c =:accountId AND Is_Patient_Portal_Form__c = true AND Form_unique_id__c!=NULL AND (NOT Form_Category__c LIKE \'%Admission\')'+' order by createddate DESC';
                            }
                            else{
                                category = '%'+category;
                                defineQuery = 'SELECT Id,CreatedBy.Name,RecordType.Name,Form_Category__c ,Is_Patient_Portal_Form__c,CreatedDate,RecordType.DeveloperName,AccountId__c,Form_RecordType_Name__c,Form_unique_id__c,Form_name__c FROM '+ String.escapeSingleQuotes(objName) + ' WHERE AccountId__c =:accountId AND Is_Patient_Portal_Form__c = true AND Form_unique_id__c!=NULL AND Form_Category__c LIKE ' + ':category'+' order by createddate DESC';
                                
                            }
                        }
                        String portalVal = 'Portal Form';
                        String portalElseVal = 'Portal And EHR Form';
                        defineQuery =  'SELECT Id,CreatedBy.Name,RecordType.Name,Form_Category__c ,LastModifiedDate,Is_Patient_Portal_Form__c,CreatedDate,RecordType.DeveloperName,AccountId__c,Form_RecordType_Name__c,Form_unique_id__c,Form_name__c FROM '+ String.escapeSingleQuotes(objName) + ' WHERE AccountId__c =:accountId AND (Is_Patient_Portal_Form__c = : portalVal OR Is_Patient_Portal_Form__c=:portalElseVal) AND Form_unique_id__c!=NULL order by createddate DESC';
                        List<sObject> records = Database.query(defineQuery);
                        for(sObject obj :records){
                            String recordTypeName = String.valueOf(obj.getSObject('RecordType').get('Name'));
                            String formUniqueId = String.valueOf(obj.get('Form_unique_id__c'));
                            if(uniqueIds.contains(formUniqueId)){
                            }else{
                                uniqueIds.add(formUniqueId);
                                //ApprovalProcess - START
                                unqiueIdToFormName.put(formUniqueId, recordTypeName);
                                //Key Name Map
                                //ApprovalProcess - END
                                FormWrapper wrpr = new FormWrapper(formUniqueId,
                                                                   String.valueOf(obj.get('Form_name__c')), 
                                                                   recordTypeName, 
                                                                   Datetime.valueOf(obj.get('LastModifiedDate')),
                                                                   String.valueOf(obj.getSObject('RecordType').get('DeveloperName')),
                                                                   '',
                                                                   String.valueOf(obj.get('Form_Category__c'))
                                                                  ); 
                                Elixir_Custom_Setting__c mc = Elixir_Custom_Setting__c.getOrgDefaults();
                                String formColumns = mc.Forms_Columns__c;
                                if(String.isNotBlank(formColumns)){
                                    wrpr.columns = formColumns.split(';'); 
                                }
                                forms.add(wrpr);
                            } 
                        }
                        //ApprovalProcess - START
                        //Key Name Map
                        //ApprovalProcess - END
                    }
                }
                ListViewFormApprovalUtility.updateFormWithApprovalValuesForcommunity(forms, unqiueIdToFormName); 
            }
            return forms;}
        catch(Exception e){
            ExceptionLog.logError(e);
            return null;
        }
        
    }
    @AuraEnabled
    public static List<FormWrapper> bringData(String accountId , String category , String subCategory,String route,List<String> setOfFormIds){
        try{
            Boolean addPortalSpecificQuery = false;
            Set<String> uniqueIds = new Set<String>();
            List<FormWrapper> forms = new List<FormWrapper>();
            List<Form_Object__mdt> metadata = [SELECT Id, QualifiedApiName,  Object_Name__c from Form_Object__mdt WHERE Object_Name__c!=NULL AND DeveloperName='Object_Names'  WITH SECURITY_ENFORCED LIMIT 1];//Getting metadata
            List<ElixirSuite__Elixir_Custom_Setting__c> portalAbility = [SELECT ID,ElixirSuite__Enable_Send_Forms_To_Portal__c FROM ElixirSuite__Elixir_Custom_Setting__c WITH SECURITY_ENFORCED];
            if(portalAbility!=null && portalAbility.size()>0){
                addPortalSpecificQuery = portalAbility[0].ElixirSuite__Enable_Send_Forms_To_Portal__c; 
            }
            if(metadata!=null && metadata.size()>0){
                Set<String> metadataObjects = new Set<String>();
                metadataObjects = new Set<String>(metadata[0].Object_Name__c.split(';'));
                Map<String,String> unqiueIdToFormName = new Map<String,String>();
                for(String objName : metadataObjects){
                    sObject sObj;
                    try{
                        sObj = Schema.getGlobalDescribe().get(objName).newSObject(); 
                    }catch(Exception e){
                        continue;
                    }
                    Integer flag = 0;
                    Set<String> objs = new Set<String>();
                    for(String field :sObj.getSobjectType().getDescribe().fields.getMap().keySet()){
                        if(field.endsWithIgnoreCase('accountid__c')){
                            objs.add(field);
                        }else if(field.endsWithIgnoreCase('form_unique_id__c')){
                            objs.add(field);
                        }else if(field.endsWithIgnoreCase('form_name__c')){
                            objs.add(field);
                        }
                    }
                    if(objs.size()==3){
                        flag = 1;
                    }
                    if(objName.endsWithIgnoreCase('__c') && flag == 1){
                        //String portalVal = 'Waiting For Patient';
                        String defineQuery='';
                        if(route== 'referralSelectedForms'){
                            
                            defineQuery = 'SELECT Id,CreatedBy.Name,RecordType.Name,Form_Category__c ,CreatedDate,RecordType.DeveloperName,AccountId__c,Form_RecordType_Name__c,Form_unique_id__c,Form_name__c FROM '+ String.escapeSingleQuotes(objName)+ ' WHERE AccountId__c =:accountId AND Form_unique_id__c IN : setOfFormIds order by createddate DESC';
                            
                        }
                        else {
                            if(String.isEmpty(category)){
                                
                                defineQuery = 'SELECT Id,CreatedBy.Name,RecordType.Name,Form_Category__c ,CreatedDate,RecordType.DeveloperName,AccountId__c,Form_RecordType_Name__c,Form_unique_id__c,Form_name__c FROM '+ String.escapeSingleQuotes(objName)+ ' WHERE AccountId__c =:accountId AND Form_unique_id__c!=NULL AND (NOT Form_Category__c LIKE \'%Admission\')'+' order by createddate DESC';
                                
                            }
                            else{
                                category = '%'+category;
                                
                                defineQuery = 'SELECT Id,CreatedBy.Name,RecordType.Name,Form_Category__c ,CreatedDate,RecordType.DeveloperName,AccountId__c,Form_RecordType_Name__c,Form_unique_id__c,Form_name__c FROM '+ String.escapeSingleQuotes(objName)+ ' WHERE AccountId__c =:accountId AND Form_unique_id__c!=NULL AND Form_Category__c LIKE ' + ':category'+' order by createddate DESC';
                                
                                
                            }
                            // defineQuery = 'SELECT Id,CreatedBy.Name,RecordType.Name,Form_Category__c ,CreatedDate,RecordType.DeveloperName,AccountId__c,Form_RecordType_Name__c,Form_unique_id__c,Form_name__c FROM '+ String.escapeSingleQuotes(objName)+ ' WHERE AccountId__c =:accountId AND Form_unique_id__c!=NULL';
                        }
                        if(addPortalSpecificQuery){
                            defineQuery+=' ';
                        }
                        List<sObject> records = Database.query(defineQuery);
                        for(sObject obj :records){
                            String recordTypeName = String.valueOf(obj.getSObject('RecordType').get('Name'));
                            String formUniqueId = String.valueOf(obj.get('Form_unique_id__c'));
                            if(uniqueIds.contains(formUniqueId)){
                            }else{
                                uniqueIds.add(formUniqueId);
                                //ApprovalProcess - START
                                unqiueIdToFormName.put(formUniqueId, recordTypeName);
                                //Key Name Map
                                //ApprovalProcess - END
                                FormWrapper wrpr = new FormWrapper(formUniqueId,
                                                                   String.valueOf(obj.get('Form_name__c')), 
                                                                   recordTypeName, 
                                                                   Datetime.valueOf(obj.get('CreatedDate')),
                                                                   String.valueOf(obj.getSObject('RecordType').get('DeveloperName')),
                                                                   String.valueOf(obj.getSObject('CreatedBy').get('Name')),
                                                                   String.valueOf(obj.get('Form_Category__c'))
                                                                  ); 
                                Elixir_Custom_Setting__c mc = Elixir_Custom_Setting__c.getOrgDefaults();
                                String formColumns = mc.Forms_Columns__c;
                                if(String.isNotBlank(formColumns)){
                                    wrpr.columns = formColumns.split(';'); 
                                }
                                forms.add(wrpr);
                            } 
                        }
                        //ApprovalProcess - START
                        //Key Name Map
                        //ApprovalProcess - END
                    }
                }
                ListViewFormApprovalUtility.updateFormWithApprovalValues(forms, unqiueIdToFormName);
            }
            return forms;
        }
        catch(Exception e){
            ExceptionLog.logError(e);
            return null;
        }
        
    }
@AuraEnabled
        public static wrapperForCareStatusValue DeleteSavedForm(String formUniqueId){
        List<String> forms = new List<String>{formUniqueId};
            wrapperForCareStatusValue wrpr = new wrapperForCareStatusValue();
        wrpr = deleteAllForms(forms);
        return wrpr;
    }
    
    @AuraEnabled  
    public static user Uinfo(){
        ID uID =UserInfo.getUserId();
        user u = new user();
        u =[select id,Verification_Code__c from user where id =:uID  WITH SECURITY_ENFORCED];
        return u;
        
    }
    
    @AuraEnabled
    public static wrapperForCareStatusValue deleteAllForms(List<String> lstRecordId){
        boolean statusValue = false;
        string value;
        wrapperForCareStatusValue wrpr = new wrapperForCareStatusValue();
        List <Form_Value__c> status = [Select ElixirSuite__Care_Episode__r.ElixirSuite__Status__c from ElixirSuite__Form_Value__c where ElixirSuite__Form_Id__c =:lstRecordId and Is_CareEpisode__c = true WITH SECURITY_ENFORCED];
        Elixir_Custom_Setting__c val = Elixir_Custom_Setting__c.getOrgDefaults();
        //Elixir_Custom_Setting__c preDef = [SELECT ElixirSuite__Lock_forms_on_closure_of_a_care_episode__c FROM Elixir_Custom_Setting__c WITH SECURITY_ENFORCED];
        if(status != null && status.size() > 0 && val !=null){
            for(Form_Value__c careStatus:status){
                if((careStatus.ElixirSuite__Care_Episode__r.ElixirSuite__Status__c == 'Closed' && val.ElixirSuite__Lock_forms_on_closure_of_a_care_episode__c == true) || careStatus.ElixirSuite__Care_Episode__r.ElixirSuite__Status__c == 'Reopened'){
                    value = careStatus.ElixirSuite__Care_Episode__r.ElixirSuite__Status__c;
                    statusValue = true;
                }
            }
            wrpr.careValueStatus = value;
            wrpr.formValue = statusValue;
        } 
        
        if(statusValue != true){
            //List<FormWrapper> forms = new List<FormWrapper>();
            List<Form_Object__mdt> metadata = [SELECT Id, QualifiedApiName, Object_Name__c FROM Form_Object__mdt WHERE Object_Name__c!=NULL AND DeveloperName='Object_Names'  WITH SECURITY_ENFORCED LIMIT 1];//Getting metadata
            if(metadata!=null && metadata.size()>0){
                Set<String> metadataObjects = new Set<String>();
                metadataObjects = new Set<String>(metadata[0].Object_Name__c.split(';'));
                for(String objName : metadataObjects){
                    sObject sObj;
                    try{
                        sObj = Schema.getGlobalDescribe().get(objName).newSObject(); 
                    }catch(Exception e){
                        continue;
                    }
                    Integer flag = 0;
                    Set<String> objs = new Set<String>();
                    for(String field :sObj.getSobjectType().getDescribe().fields.getMap().keySet()){
                        if(field.endsWithIgnoreCase('accountid__c')){
                            objs.add(field);
                        }else if(field.endsWithIgnoreCase('form_unique_id__c')){
                            objs.add(field);
                        }else if(field.endsWithIgnoreCase('form_name__c')){
                            objs.add(field);
                        }
                    }
                    if(objs.size()==3){
                        flag = 1;
                    }
                    if(objName.endsWithIgnoreCase('__c') && flag==1){
                        String defineQuery = 'SELECT Id FROM '+ String.escapeSingleQuotes(objName) + ' WHERE Form_unique_id__c IN :lstRecordId AND Form_unique_id__c!=NULL' ;
                        // String defineQuery = 'SELECT Id FROM '+ +objName + ' WHERE Form_unique_id__c IN :String.escapeSingleQuotes(lstRecordId) AND Form_unique_id__c!=NULL' ;
                        
                        List<sObject> records = Database.query(defineQuery);
                        //delete records;
                        DMLManager.deleteAsUser(records);
                        
                        /*SObjectType recordType = records[0].getSObjectType();
if (Schema.sObjectType.recordType.isDeletable())
{
delete records; //Deleting Form Object
}*/
                        
                        
                        List<Form_Label__c> labels = [SELECT FormId__c, Id FROM Form_Label__c 
                                                      WHERE FormId__c IN :lstRecordId WITH SECURITY_ENFORCED];
                        if(labels!=null && labels.size()>0){
                            //if (Schema.sObjectType.Form_Label__c.isDeletable()) {
                            //Database.delete(labels,false);//Deleting Form Label
                            DMLManagerV2.deleteAsUser(labels,false);
                            // }
                        }
                        List<Form_Value__c> values = [SELECT Id,Form_Id__c FROM Form_Value__c 
                                                      WHERE Form_Id__c  IN :lstRecordId WITH SECURITY_ENFORCED];
                        if(values!=null && values.size()>0){
                            //if (Schema.sObjectType.Form_Value__c.isDeletable()) {
                            //Database.delete(values,false);//Deleting Form Values
                            DMLManagerV2.deleteAsUser(values,false);
                            //}
                        }
                    }
                }
                
                //Added by Anmol for LX3-8548
                List<Event> lstEvent = [SELECT
                                        Id,
                                        ElixirSuite__Form_Unique_Id__c,
                                        ElixirSuite__Parent_Event_Id__c
                                        FROM Event
                                        WHERE ElixirSuite__Form_Unique_Id__c IN :lstRecordId
                                        WITH SECURITY_ENFORCED];
                
                List<Id> lstEvId = new List<Id>();
                List<Id> contentDocumentId = new List<Id>();
                List<Id> contentDocumentId1 = new List<Id>();
                
                if(lstEvent!=null && lstEvent.size()>0){
                    String parentEvtId = lstEvent[0].ElixirSuite__Parent_Event_Id__c;
                for(Event ev : lstEvent){
                    ev.ElixirSuite__Form_Unique_Id__c = '';
                    lstEvId.add(ev.Id);
                }
                    
                    List<ContentDocumentLink> cdl1 = [Select Id,
                                                 LinkedEntityId,
                                                 ContentDocumentId
                                                 FROM ContentDocumentLink
                                                 WHERE LinkedEntityId = :parentEvtId
                                                 WITH SECURITY_ENFORCED];
                List<ContentNote> cnt1 = new List<ContentNote>();
                if(cdl1.size() >0 && cdl1 != null){
                    for(ContentDocumentLink con : cdl1){
                        contentDocumentId1.add(con.ContentDocumentId);
                    }
                    cnt1 = [Select Id,
                           Content
                           From ContentNote
                           Where Id IN :contentDocumentId1
                           WITH SECURITY_ENFORCED];
                }
                    
                
                List<ContentDocumentLink> cdl = [Select Id,
                                                 LinkedEntityId,
                                                 ContentDocumentId
                                                 FROM ContentDocumentLink
                                                 WHERE LinkedEntityId IN :lstEvId
                                                 WITH SECURITY_ENFORCED];
                List<ContentNote> cnt = new List<ContentNote>();
                if(cdl.size() >0 && cdl != null){
                    for(ContentDocumentLink con : cdl){
                        contentDocumentId.add(con.ContentDocumentId);
                    }
                    cnt = [Select Id,
                           Content
                           From ContentNote
                           Where Id IN :contentDocumentId
                           WITH SECURITY_ENFORCED];
                }
                
                DMLManager.updateAsUser(lstEvent);
                    if(cnt.size() >0 && cnt != null){
                DMLManager.deleteAsUser(cnt);
                    }
                    if(cnt1.size() >0 && cnt1 != null){
                DMLManager.deleteAsUser(cnt1);
                    }
                    
                //End by Anmol for LX3-8548
            }
            }
        }
        return wrpr;
    }
    //changes added by utkarsh
    @AuraEnabled
    Public static list<String> getSearchForms(String searchKey,String category, String categorized){
        String name =  + searchKey + '%';
        list<String> formNames = new list<String>();
        List<Form_Object__mdt> metadata = [SELECT Id, QualifiedApiName, Object_Name__c FROM Form_Object__mdt WHERE Object_Name__c!=NULL AND DeveloperName='Object_Names' WITH SECURITY_ENFORCED LIMIT 1];//Getting metadata
        if(metadata!=null && metadata.size()>0){
            Set<String> metadataObjects = new Set<String>();
            metadataObjects = new Set<String>(metadata[0].Object_Name__c.split(';'));
            category = '%'+ (String.isNotBlank(category) ? category:'');
            List<RecordType> recordTypes;  //declared globally
            String form1 = '%'+'Form';
            String note1 = '%'+'Note';
            String nursing = '%'+'Nursing';
            if(String.isNotBlank(categorized)){
                recordTypes = [SELECT Id, Name, DeveloperName, NamespacePrefix, SobjectType, IsActive FROM RecordType
                               WHERE name LIKE :name AND IsActive = true AND SobjectType IN :metadataObjects AND DeveloperName LIKE'EHR%' AND DeveloperName LIKE '%Admission'  WITH SECURITY_ENFORCED ];
            }else{
                if(category.contains('Other')){
                    recordTypes = [SELECT Id, Name, DeveloperName, NamespacePrefix, SobjectType, IsActive FROM RecordType WHERE name LIKE :name AND IsActive = true AND SobjectType IN :metadataObjects AND DeveloperName LIKE'EHR%' AND (NOT DeveloperName LIKE '%Admission') AND  (NOT DeveloperName LIKE :form1) AND (NOT DeveloperName LIKE :note1) AND (NOT DeveloperName LIKE :nursing) WITH SECURITY_ENFORCED];
                }else if(category == '%'){
                    recordTypes = [SELECT Id, Name, DeveloperName, NamespacePrefix, SobjectType, IsActive FROM RecordType
                                   WHERE name LIKE :name AND IsActive = true AND SobjectType IN :metadataObjects AND DeveloperName LIKE'EHR%' AND (NOT DeveloperName LIKE '%Admission') WITH SECURITY_ENFORCED];
                }  
                else{
                    recordTypes = [SELECT Id, Name, DeveloperName, NamespacePrefix, SobjectType, IsActive FROM RecordType
                                   WHERE name LIKE :name AND IsActive = true AND SobjectType IN :metadataObjects AND DeveloperName LIKE'EHR%' AND (NOT DeveloperName LIKE '%Admission') AND  DeveloperName LIKE : category  WITH SECURITY_ENFORCED];
                }
            }
            if(recordTypes!=null && recordTypes.size()>0){
                for(RecordType form :recordTypes){
                    formNames.add(form.Name);
                }
            }
        }
        return formNames;
    }

    public static String concatenateFormCategories(Form_Category__c formCategoriesRecord) {
        List<String> formCategories = new List<String>();
        List<String> categoryApiNames = new List<String>{
            'Category__c', 
            'Category1__c', 'Category2__c', 'Category3__c', 'Category4__c', 'Category5__c', 
            'Category6__c', 'Category7__c', 'Category8__c', 'Category9__c', 'Category10__c', 
            'Category11__c', 'Category12__c', 'Category13__c', 'Category14__c', 'Category15__c', 
            'Category16__c', 'Category17__c', 'Category18__c', 'Category19__c'
        };

        for (string apiName : categoryApiNames) {
            Object categories = formCategoriesRecord.get(apiName);

            if (categories != null) {
                formCategories.add(String.valueOf(categories));
            }
        }
        
        return String.join(formCategories, ';');
    }

    //added changes by utkarsh
    @AuraEnabled
    Public static list<String> filterForms(String category){
        
        list<String> formNames = new list<String>();
        List<String> metadataObjects1 = new List<String>();
        List<Form_Category__c> metadata1 = [
            SELECT
                Id, Category__c,
                Category1__c, Category2__c, Category3__c, Category4__c, Category5__c, 
                Category6__c, Category7__c, Category8__c, Category9__c, Category10__c, 
                Category11__c, Category12__c, Category13__c, Category14__c, Category15__c, 
                Category16__c, Category17__c, Category18__c, Category19__c
            FROM
                Form_Category__c
            WHERE
                SetupOwnerId =:userinfo.getProfileId()
            WITH
                SECURITY_ENFORCED
        ];
        //Getting metadata

        if(metadata1!=null && metadata1.size()>0){
            String concatenatedFormCategories = concatenateFormCategories(metadata1[0]);
            metadataObjects1 = new List<String>(concatenatedFormCategories.split(';'));
        }
        for (Integer i = 0; i < metadataObjects1.size(); i++) {
            if (metadataObjects1.get(i) == 'Other'){
                metadataObjects1.remove(i);
                i--;
            }
        }
        
        List<Form_Object__mdt> metadata = [SELECT Id, QualifiedApiName, Object_Name__c FROM Form_Object__mdt WHERE Object_Name__c!=NULL AND DeveloperName='Object_Names'  WITH SECURITY_ENFORCED LIMIT 1];//Getting metadata
        if(metadata!=null && metadata.size()>0){
            Set<String> metadataObjects = new Set<String>();
            metadataObjects = new Set<String>(metadata[0].Object_Name__c.split(';'));
            category = '%'+category;
            
            List<RecordType> recordTypes = [SELECT Id, Name, DeveloperName, NamespacePrefix, SobjectType, IsActive FROM RecordType
                                            WHERE IsActive = true AND SobjectType IN :metadataObjects AND DeveloperName LIKE'EHR%' AND DeveloperName LIKE :category AND (NOT DeveloperName LIKE '%Admission') WITH SECURITY_ENFORCED ];
            
            // String query = 'SELECT Id, Name, DeveloperName, NamespacePrefix, SobjectType, IsActive FROM RecordType WHERE IsActive = true AND SobjectType IN :metadataObjects AND DeveloperName LIKE \'EHR%\' AND  (NOT DeveloperName LIKE \'%Admission\')';
            
            String query = 'SELECT Id, Name, DeveloperName, NamespacePrefix, SobjectType, IsActive FROM RecordType WHERE IsActive = true AND SobjectType IN :String.escapeSingleQuotes(metadataObjects) AND DeveloperName LIKE \'EHR%\' AND  (NOT DeveloperName LIKE \'%Admission\')';
            for(String str : metadataObjects1){
                String categ ='%'+str;
                query=query+' AND  (NOT DeveloperName LIKE :categ)';
            }
            
            if(category.contains('Other')){
                recordTypes = Database.query(query);
                // recordTypes = [SELECT Id, Name, DeveloperName, NamespacePrefix, SobjectType, IsActive FROM RecordType WHERE IsActive = true AND SobjectType IN :metadataObjects AND DeveloperName LIKE'EHR%' AND  (NOT DeveloperName LIKE :form1) AND (NOT DeveloperName LIKE :note1)];
            }
            if(recordTypes!=null && recordTypes.size()>0){
                for(RecordType form :recordTypes){
                    formNames.add(form.Name);
                }
            }
        }
        return formNames;
    }
    @AuraEnabled
    Public static InitWrapper getUserInstance(String[] category){
        InitWrapper obj = new InitWrapper();
        Id profileId=userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        if(profileName == 'Patient_Portal'){
            obj.isPatientPortalUser =  true;
        }
        else {
            obj.isPatientPortalUser =  false;
        }
        return obj;
    }
    public class InitWrapper {
        @AuraEnabled public Boolean isPatientPortalUser; 
        @AuraEnabled public List<String> categoryData;
        @AuraEnabled public String accountIdIfPortalUser;
    }
    @AuraEnabled
    Public static list<String> filterFormsIfUserDefinedCategoryGiven(String[] category){
        
        list<String> formNames = new list<String>();
        List<String> metadataObjects1 = new List<String>();
        List<Form_Category__c> metadata1 = [
            SELECT
                Id,Category__c,
                Category1__c, Category2__c, Category3__c, Category4__c, Category5__c, 
                Category6__c, Category7__c, Category8__c, Category9__c, Category10__c, 
                Category11__c, Category12__c, Category13__c, Category14__c, Category15__c, 
                Category16__c, Category17__c, Category18__c, Category19__c
            FROM
                Form_Category__c
            WHERE
                SetupOwnerId =:userinfo.getProfileId()
            WITH
                SECURITY_ENFORCED
        ];
        //Getting metadata

        if(metadata1!=null && metadata1.size()>0){
            String concatenatedFormCategories = concatenateFormCategories(metadata1[0]);
            metadataObjects1 = new List<String>(concatenatedFormCategories.split(';'));
        }
        for (Integer i = 0; i < metadataObjects1.size(); i++) {
            if (metadataObjects1.get(i) == 'Other'){
                metadataObjects1.remove(i);
                i--;
            }
        }
        
        List<Form_Object__mdt> metadata = [SELECT Id, QualifiedApiName, Object_Name__c FROM Form_Object__mdt WHERE Object_Name__c!=NULL AND DeveloperName='Object_Names'  WITH SECURITY_ENFORCED LIMIT 1];//Getting metadata
        if(metadata!=null && metadata.size()>0){
            Set<String> metadataObjects = new Set<String>();
            metadataObjects = new Set<String>(metadata[0].Object_Name__c.split(';'));
            List<RecordType> recordTypes = new List<RecordType>();
            for(String objCategory : category){
                objCategory = '%'+objCategory;
                recordTypes.addAll([SELECT Id, Name, DeveloperName, NamespacePrefix, SobjectType, IsActive FROM RecordType
                                    WHERE IsActive = true AND SobjectType IN :metadataObjects AND DeveloperName LIKE'EHR%' AND DeveloperName LIKE :objCategory AND (NOT DeveloperName LIKE '%Admission') WITH SECURITY_ENFORCED ]);
            }
            
            
            // String query = 'SELECT Id, Name, DeveloperName, NamespacePrefix, SobjectType, IsActive FROM RecordType WHERE IsActive = true AND SobjectType IN :metadataObjects AND DeveloperName LIKE \'EHR%\' AND  (NOT DeveloperName LIKE \'%Admission\')';
            
            String query = 'SELECT Id, Name, DeveloperName, NamespacePrefix, SobjectType, IsActive FROM RecordType WHERE IsActive = true AND SobjectType IN :String.escapeSingleQuotes(metadataObjects) AND DeveloperName LIKE \'EHR%\' AND  (NOT DeveloperName LIKE \'%Admission\')';
            for(String str : metadataObjects1){
                String categ ='%'+str;
                query=query+' AND  (NOT DeveloperName LIKE :categ)';
            }
            
            if(category.contains('Other')){
                recordTypes = Database.query(query);
                // recordTypes = [SELECT Id, Name, DeveloperName, NamespacePrefix, SobjectType, IsActive FROM RecordType WHERE IsActive = true AND SobjectType IN :metadataObjects AND DeveloperName LIKE'EHR%' AND  (NOT DeveloperName LIKE :form1) AND (NOT DeveloperName LIKE :note1)];
            }
            if(recordTypes!=null && recordTypes.size()>0){
                for(RecordType form :recordTypes){
                    formNames.add(form.Name);
                }
            }
        }
        return formNames;
    }
    public class wrapperForAccName{ 
        @AuraEnabled  public List<String> formNames;
        @AuraEnabled  public String accName;
        @AuraEnabled  public String passCode;        
        @AuraEnabled public Boolean isSendPortalButtonEnabled;
    }
    
    //nithin
    public class wrapperForCareStatusValue{ 
        @AuraEnabled  public String careValueStatus;
        @AuraEnabled  public Boolean lockValue;  
        @AuraEnabled  public Boolean formValue;
    }
    
    public class FormWrapper{
        @AuraEnabled public String formId;
        @AuraEnabled public String formName{get;set;}
        @AuraEnabled  public String recordTypeName;  
        @AuraEnabled  public Datetime CreatedDate{get;set;} 
        @AuraEnabled  public String recordTypeDeveloperName;  
        @AuraEnabled  public String CreatedBy{get;set;}  
        @AuraEnabled public String formCategory{get;set;} 
        @AuraEnabled public String status;
        @AuraEnabled public String careEpisodeId;//added by Anmol for LX3-7326
        @AuraEnabled public String careEpisodeName;//added by Anmol for LX3-7326
        @AuraEnabled public Integer approvedLevelsCount;
        @AuraEnabled public Integer defaultLevelCount;
        @AuraEnabled public List<String> columns;
        public FormWrapper(String formId, String formName, String recordTypeName, Datetime CreatedDate,String recordTypeDeveloperName,
                           String CreatedBy,String formCategory){
                               this.formId = formId;
                               this.formName = formName;
                               this.recordTypeName = recordTypeName;
                               this.CreatedDate = CreatedDate;
                               this.recordTypeDeveloperName = recordTypeDeveloperName;
                               this.CreatedBy = CreatedBy;
                               this.formCategory = formCategory ;
                           }
    }
    @AuraEnabled
    public static List<String> fetchCategory(){
        List<String> metadataObjects = new List<String>();
        List<Form_Category__c> metadata = [
            SELECT
                Id,Category__c,
                Category1__c, Category2__c, Category3__c, Category4__c, Category5__c, 
                Category6__c, Category7__c, Category8__c, Category9__c, Category10__c, 
                Category11__c, Category12__c, Category13__c, Category14__c, Category15__c, 
                Category16__c, Category17__c, Category18__c, Category19__c
            FROM
                Form_Category__c 
            WHERE
                SetupOwnerId =:userinfo.getProfileId()
            WITH
                SECURITY_ENFORCED
        ];
        //Getting metadata
        if(metadata!=null && metadata.size()>0){
            String concatenatedFormCategories = concatenateFormCategories(metadata[0]);
            metadataObjects = new List<String>(concatenatedFormCategories.split(';'));
        }
        return metadataObjects;
    }
    @AuraEnabled
    public static wrapperForCareStatusValue checkCareEpisode(String formUniqueID){
        wrapperForCareStatusValue wrpr = new wrapperForCareStatusValue();
        List <Form_Value__c> status = [Select ElixirSuite__Care_Episode__r.ElixirSuite__Status__c from ElixirSuite__Form_Value__c where ElixirSuite__Form_Id__c =:formUniqueID and Is_CareEpisode__c = true WITH SECURITY_ENFORCED];
        Elixir_Custom_Setting__c val = Elixir_Custom_Setting__c.getOrgDefaults();
        //Elixir_Custom_Setting__c preDef = [SELECT ElixirSuite__Lock_forms_on_closure_of_a_care_episode__c FROM Elixir_Custom_Setting__c WITH SECURITY_ENFORCED];
        //wrpr.careValueStatus = status.ElixirSuite__Care_Episode__r.ElixirSuite__Status__c;
        //wrpr.lockValue =  preDef.ElixirSuite__Lock_forms_on_closure_of_a_care_episode__c;
        if(status != null && status.size() > 0 && val!=null){
            wrpr.careValueStatus = status[0].ElixirSuite__Care_Episode__r.ElixirSuite__Status__c;
            wrpr.lockValue =  val.ElixirSuite__Lock_forms_on_closure_of_a_care_episode__c;
        }
        return wrpr;
    }
        @AuraEnabled
    public static String checkExistingForm(List<String> formsToSendOnPortal, String accountId) {
        String checkExistingFormNames = '';
        List<ElixirSuite__Form_Value__c> existingFormsLst =new List<ElixirSuite__Form_Value__c>();
         existingFormsLst = [SELECT ID, Name, ElixirSuite__Account__c, 
                            ElixirSuite__Status__c, ElixirSuite__Form_Name__c
                            FROM ElixirSuite__Form_Value__c
                            WHERE ElixirSuite__Account__c = :accountId
                            AND ElixirSuite__Status__c = 'Waiting For Patient'
                            AND ElixirSuite__Form_Name__c IN :formsToSendOnPortal
            				WITH SECURITY_ENFORCED];
    
        if (!existingFormsLst.isEmpty()) {
            // If there are existing forms with the status "Waiting For Patient" for the given forms and account ID
            // comma-separated list of existing form names
            List<String> existingFormNames = new List<String>();
            for (ElixirSuite__Form_Value__c existingForm : existingFormsLst) {
                existingFormNames.add(existingForm.ElixirSuite__Form_Name__c);
            }
            checkExistingFormNames = String.join(existingFormNames, ', ');
        }
    
        return checkExistingFormNames;
    }

    @AuraEnabled
    public static void sendFormsToPP(List<String> formsToSendOnPortal,String accountId){
        CreateFormForPortal.createForm(accountId, formsToSendOnPortal); 
    }
    @AuraEnabled
    public static InitWrapper portalInitPayload(){
        try{
            InitWrapper obj = new InitWrapper();
            sObject[] ur = new List<sObject>();
            String userId = userinfo.getUserId();
            ur = database.query('SELECT Id,AccountId,Name,Username,IsPortalEnabled FROM User where Id =:userId'); 
            if(ur!= Null && ur.size()>0){
                obj.accountIdIfPortalUser = String.valueOf(ur[0].get('AccountId'));
            } 
            return obj;
            
            
        }
        catch(Exception e){
            ExceptionLog.logError(e);
            return null;
        }
    }
    @AuraEnabled
    public static void submitSelectedFormsToEHRFromPortal(List<Map<String, String>> wrappedData){
        try{
            sObject[] ur = new List<sObject>();
            String userId = userinfo.getUserId();
            ur = database.query('SELECT Id,AccountId,Name,Username,IsPortalEnabled FROM User where Id =:userId'); 
            if(ur!= Null && ur.size()>0){
                List<UpdateFormForPortal.UpdateFormResponse> updateFormResponses = new List<UpdateFormForPortal.UpdateFormResponse>();
                for(Map<String, String> wrp : wrappedData){
                    UpdateFormForPortal.UpdateFormResponse updateFormResponse = UpdateFormForPortal.updateForm(String.valueOf(ur[0].get('AccountId')), wrp.get('formId'), wrp.get('formName'));
                    updateFormResponses.add(updateFormResponse);
                }
                List<sObject> formsToUpdate = new List<sObject>();
                List<ElixirSuite__Form_Value__c> formValLstToUpdate = new List<ElixirSuite__Form_Value__c>();
                
                for (UpdateFormForPortal.UpdateFormResponse response : updateFormResponses) {
                    formsToUpdate.addAll(response.formsToUpdate);
                    formValLstToUpdate.addAll(response.formValLst);
                }
                
                if (!formsToUpdate.isEmpty()) {
                    DMLManager.updateAsUser(formsToUpdate);
                }
                if (!formValLstToUpdate.isEmpty()) {
                    DMLManager.updateAsUser(formValLstToUpdate);
                }
            }
        }catch(Exception e){
            ExceptionLog.logError(e);
        }
    }
    @AuraEnabled
    public static Boolean getApprovalAndSignatureData(List<Map<String, String>> formsData){
        try{
            Boolean isDisabled = false;
            List<String> formIds = new List<String>();
            List<String> formNames = new List<String>();
            Map<String, String[]> objMap = new Map<String, String[]>();
            Map<String, String[]> formValueMap = new Map<String, String[]>();
            
            for (Map<String, String> wrp : formsData) {
                formIds.add(wrp.get('formId'));
                formNames.add(wrp.get('formName'));
            }
            List<ElixirSuite__Object_1_css__c> obj1List = new List<ElixirSuite__Object_1_css__c>();
            obj1List = [
                SELECT Id, ElixirSuite__Approval_Level__c, ElixirSuite__Form__c,ElixirSuite__Approval_Members__c 
                FROM ElixirSuite__Object_1_css__c 
                WHERE ElixirSuite__Form__c IN :formNames AND ElixirSuite__Approval_Level__c != NULL WITH SECURITY_ENFORCED
            ];
            if(obj1List.size()>0){
                for (ElixirSuite__Object_1_css__c css : obj1List) {
                    String formName = css.ElixirSuite__Form__c;
                    String[] levels = objMap.containsKey(formName) ? objMap.get(formName) : new List<String>();
                    levels.add(String.valueOf(css.ElixirSuite__Approval_Level__c));
                    objMap.put(formName, levels);
                }
                
                // Create objCountMap to store the size (count) of arrays for each key
                Map<String, String> objCountMap = new Map<String, String>();
                for (String key : objMap.keySet()) {
                    objCountMap.put(key,String.valueOf(objMap.get(key).size()));
                }
                
                for(String formNameobj : formNames){
                    if(!objCountMap.containsKey(formNameobj)){
                        objCountMap.put(formNameobj,String.valueOf(0));
                    } 
                }
                List<ElixirSuite__Form_Value__c> formValueList = new   List<ElixirSuite__Form_Value__c>();
                formValueList = [
                    SELECT Id, ElixirSuite__Is_Approver__c, ElixirSuite__Form_Id__c, ElixirSuite__Approval_Level__c, ElixirSuite__Form_Name__c, ElixirSuite__Is_old__c
                    FROM ElixirSuite__Form_Value__c 
                    WHERE ElixirSuite__Form_Id__c IN :formIds AND ElixirSuite__Approval_Level__c != NULL WITH SECURITY_ENFORCED
                ];
                if(formValueList.size()>0){
                    Map<String,String> uniqIdAndLabelAMp = new Map<String,String>();
                    
                    for (ElixirSuite__Form_Value__c fv : formValueList) {
                        uniqIdAndLabelAMp.put(fv.ElixirSuite__Form_Id__c,fv.ElixirSuite__Form_Name__c);
                        String formUniqueId = fv.ElixirSuite__Form_Id__c;
                        String[] levels = formValueMap.containsKey(formUniqueId) ? formValueMap.get(formUniqueId) : new List<String>();
                        levels.add(String.valueOf(fv.ElixirSuite__Approval_Level__c));
                        formValueMap.put(formUniqueId, levels);
                    }
                    
                    // Create formValueCountMap to store the size (count) of arrays for each key
                    Map<String, String> formValueCountMap = new Map<String, String>();
                    for (String key : formValueMap.keySet()) {
                        formValueCountMap.put(key, String.valueOf(formValueMap.get(key).size()));
                    }
                    ElixirSuite__Form_Value__c[] formIdNameLst = [SELECT Id, ElixirSuite__Is_Approver__c, ElixirSuite__Form_Id__c, ElixirSuite__Approval_Level__c, ElixirSuite__Form_Name__c, ElixirSuite__Is_old__c
                                                                  FROM ElixirSuite__Form_Value__c 
                                                                  WHERE ElixirSuite__Form_Id__c IN : formIds WITH SECURITY_ENFORCED];
                    Map<String,String> formIdNameMap = new   Map<String,String> ();
                    for(ElixirSuite__Form_Value__c obj : formIdNameLst){
                        formIdNameMap.put(obj.ElixirSuite__Form_Id__c,obj.ElixirSuite__Form_Name__c);
                    }
                    for(String str : formIds){
                        if(!formValueCountMap.containsKey(str)){
                            formValueCountMap.put(str,String.valueOf(0));
                            if(formIdNameMap.containskey(str)){
                                uniqIdAndLabelAMp.put(str,formIdNameMap.get(str));
                            }
                            
                        } 
                    }
                     
                    for (String fuq : formValueCountMap.keySet()) {
                        if (!formValueCountMap.get(fuq).equals(objCountMap.get(uniqIdAndLabelAMp.get(fuq)))) {
                            isDisabled = true;
                            break;
                        }
                    } 
                }
                else {
                    isDisabled = true;
                }
            }
            return isDisabled;   
        }catch(Exception e){
            ExceptionLog.logError(e);
            return NULL;
        }
    }

    
    public class DynamicFormColumnWrapper{ 
        @AuraEnabled  public String label;
        @AuraEnabled  public String fieldName;
        @AuraEnabled  public String type;
        @AuraEnabled  public String objectName;

        public DynamicFormColumnWrapper(String label, String fieldName, String type, String objectName) {
            this.label = label;
            this.fieldName = fieldName;
            this.type = type;
            this.objectName = objectName;
        }
    }
    
    @AuraEnabled
    public static List<DynamicFormColumnWrapper> queryDynamicFormColumns(){
        try {
            List<DynamicFormColumnWrapper> dynamicFormColumns = new List<DynamicFormColumnWrapper>();

            Id formColumnRecordTypeId = Schema.SObjectType.ElixirSuite__Master_Object__c.getRecordTypeInfosByName().get('Form Columns').getRecordTypeId();
            
            List<ElixirSuite__Master_Object__c> dynamicFormColumnRecords = [
                SELECT 
                    Id, Field_Label__c,Field_Api__c, Data_Type__c, Object_API_Name__c
                FROM 
                    ElixirSuite__Master_Object__c
                WHERE
                    RecordTypeId = :formColumnRecordTypeId
                AND
                    Field_Label__c != NULL
                AND 
                    Field_Api__c != NULL 
                AND 
                    Data_Type__c != NULL
                AND 
                    Object_API_Name__c != NULL
                AND 
                    Is_Dynamic_Column_Active__c = true
                    WITH SECURITY_ENFORCED
                ORDER BY
                    CreatedDate ASC
            ];

            for (ElixirSuite__Master_Object__c i : dynamicFormColumnRecords) {
                dynamicFormColumns.add(new DynamicFormColumnWrapper(i.Field_Label__c, i.Field_Api__c, i.Data_Type__c, i.Object_API_Name__c));
            }

            return dynamicFormColumns;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Map<String, Map<String, Object>> queryDynamicFormColumnData(Id accountId){
        try {
            // query dynamicFormColumns            
            List<DynamicFormColumnWrapper> dynamicFormColumns = queryDynamicFormColumns();
            Map<String, Set<String>> objectNameToFieldMap = new Map<String, Set<String>>();

            for (DynamicFormColumnWrapper i : dynamicFormColumns) {
                if (objectNameToFieldMap.containsKey(i.objectName)) {
                    objectNameToFieldMap.get(i.objectName).add(i.fieldName);
                }
                else {
                    objectNameToFieldMap.put(i.objectName, new Set<String>{i.fieldName});
                }
            }

            Map<String, Map<String, Object>> formUniqueIdToRecordMap = new Map<String, Map<String, Object>>();

            List<String> objectNames = new List<String>(objectNameToFieldMap.keySet());
            // due to logic below, incase of duplicate field api across 2 objects, the first encountered field value will persist
            // sorting the object names so that each time same object comes first
            objectNames.sort();
            Set<String> requiredFields = new Set<String>{'Id', 'Form_unique_id__c'};

            for (String objectName : objectNames) {
                if (Limits.getLimitQueries() > 0) {
                    // for each object, query mentioned fields
                    Set<String> dynamicFieldsToQuery = objectNameToFieldMap.get(objectName);
                    dynamicFieldsToQuery.addAll(requiredFields);
                    String fieldsToQuery = String.join(new List<String>(dynamicFieldsToQuery), ',');

                    String query = 'SELECT ' + String.escapeSingleQuotes(fieldsToQuery) +' FROM ' + String.escapeSingleQuotes(objectName) + ' WHERE AccountId__c = :accountId AND Form_unique_id__c != NULL';
                    List<SObject> objectNameRecords = Database.query(query); 

                    for (SObject i : objectNameRecords) {
                        String formUniqueId = String.valueOf(i.get('Form_unique_id__c'));

                        // using getPopulatedFieldsAsMap() to generate the map,
                        // so we can ignore the possibility that newRecordDetails will have any null value for any key
                        // which handles the requirement of only override the duplicate keys which don't have any value
                        Map<String, Object> newRecordDetails = new Map<String, Object>();
                        newRecordDetails.putAll(i.getPopulatedFieldsAsMap());
                        
                        if (formUniqueIdToRecordMap.containsKey(formUniqueId)) {
                            Map<String, Object> existingRecordDetails = formUniqueIdToRecordMap.get(formUniqueId);

                            // putting existingRecordDetails in newRecordDetails
                            // so that for duplicate keys value of exisitingRecordDetails overrides newRecordDetails value
                            newRecordDetails.putAll(existingRecordDetails);
                        }

                        formUniqueIdToRecordMap.put(formUniqueId, newRecordDetails);
                    }
                }
                else {
                    ExceptionLog.logError(new AuraHandledException('Query limit exceeded at ' + objectName + ' of ' + objectNames));
                    break;
                }
            }

             return formUniqueIdToRecordMap;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    
}
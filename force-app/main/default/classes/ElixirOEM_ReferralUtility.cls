/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-10-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class ElixirOEM_ReferralUtility {
    public static Map<String,String> labelApiEntityMap = chartSummaryEntityMap();
    public static List<String> entitiesToExclude = excludeEntitryLst();
    @AuraEnabled 
    public static void saveReferral(List<ElixirSuite__Referral__c> parentReferral1,String patientDiagnosisLst,
                                    String patientProcedureLst,String vobId,String chartSummaryOptions,String accountId,
                                    String emailReferredOut,String files){    
                                        try{
                                            List <ElixirSuite__Referral__c> parentReferral =  new List <ElixirSuite__Referral__c>();
                                        parentReferral.add(parentReferral1[0]);    
                                        Account[] accReferredOrg  = [SELECT ID,Name FROM Account WHERE
                                                                     Id = :parentReferral[0].ElixirSuite__Referred_Out_Organization__c WITH SECURITY_ENFORCED];
                                        String referentOrganization = '';

                                          //added by Anmol for LX3-7236
         Elixir_Custom_Setting__c customSetting = Elixir_Custom_Setting__c.getOrgDefaults();
         String careFilter = customSetting.ElixirSuite__Default_Active_Care_Episode_Filter__c;
         String careStatus = 'Active';
 
         string querystr = '';
         string accId = parentReferral[0].ElixirSuite__Account__c;
         querystr += 'Select Id,ElixirSuite__Account__c,ElixirSuite__Status__c from ElixirSuite__Visits__c where ElixirSuite__Status__c=:careStatus AND ElixirSuite__Account__c = : accId WITH SECURITY_ENFORCED order by ';
         querystr += careFilter ;
         ElixirSuite__Visits__c[] activeCP = database.query(querystr);
         //end by Anmol for LX3-7236

                                        System.debug('activeCP'+activeCP);
                                        System.debug('accountId'+accountId);
                                        if(accReferredOrg!=null && accReferredOrg.size()>0){
                                            referentOrganization = accReferredOrg[0].Name;
                                        }        
                                        System.debug('emailReferredOut  '+emailReferredOut);
                                       
                                            parentReferral[0].Name = 'Outbound Referral to '+referentOrganization;
                                            if(!activeCP.isEmpty()){
            										parentReferral[0].ElixirSuite__Care_Episode__c = activeCP[0].id;
             									} 
                                           // if(Schema.sObjectType.ElixirSuite__Referral__c.isCreateable() &&
                                              // Schema.sObjectType.ElixirSuite__Referral__c.fields.Name.isCreateable() &&
                                              // Schema.sObjectType.ElixirSuite__Referral__c.fields.ElixirSuite__Care_Episode__c.isCreateable()){
                                               System.debug('parentReferral.ElixirSuite__Care_Episode__c'+parentReferral[0].ElixirSuite__Care_Episode__c);

                                          //  insert parentReferral;
                                          DMLManager.insertAsUser(parentReferral);
                                    //}
                                        ElixirSuite__Referral_Data__c[] referralDataLst = new List<ElixirSuite__Referral_Data__c>();
                                        Set<Id> contentDocIds = new Set<Id>();
                                        if(String.isNotBlank(files)){ 
                                            contentDocIds = formulateFiles(files,referralDataLst,parentReferral[0]); 
                                        }
                                        formulateDiagnosis(patientDiagnosisLst,referralDataLst,parentReferral[0]);
                                        if(String.isNotBlank(patientProcedureLst)){  
                                            formulateProcedure(patientProcedureLst,referralDataLst,parentReferral[0]);
                                        }
                                        if(String.isNotBlank(vobId)){  
                                            formulateVOB(vobId,referralDataLst,parentReferral[0]);
                                        }
                                        if(String.isNotBlank(chartSummaryOptions)){                                                                                      
                                            formulateChartSummary(chartSummaryOptions,referralDataLst,parentReferral[0]);
                                        }
                                        //if(Schema.sObjectType.ElixirSuite__Referral_Data__c.isCreateable() &&
                                       // Schema.sObjectType.ElixirSuite__Referral_Data__c.fields.ElixirSuite__VOB__c.isCreateable() &&
                                       // Schema.sObjectType.ElixirSuite__Referral_Data__c.fields.Procedure_Codes__c.isCreateable() &&
                                        //Schema.sObjectType.ElixirSuite__Referral_Data__c.fields.ElixirSuite__Referral__c.isCreateable() &&
                                        //Schema.sObjectType.ElixirSuite__Referral_Data__c.fields.ElixirSuite__File_ContentDocumentId__c.isCreateable() &&
                                        //Schema.sObjectType.ElixirSuite__Referral_Data__c.fields.Template_Diagnosis_Code__c.isCreateable()){
                                            //insert referralDataLst;
                                            DMLManager.insertAsUser(referralDataLst);
                                        //}
                                        System.debug('contentDocIds '+contentDocIds);
                                        attachContentDocuments(contentDocIds,parentReferral[0].Id);                              
                                        attchAsPDF(parentReferral[0].Id,emailReferredOut);
                                        }
                                        catch(Exception e){
                    ExceptionLog.logError(e);
                }
                                    }
    public static void attachContentDocuments(Set<Id> documentIds,String parentReferralId){
        List<Contentversion> cvtestidset = [Select Id,VersionData,ContentDocument.Title from ContentVersion where ContentDocumentId in :documentIds];     
        for(Contentversion at : cvtestidset){
            Attachment attach = new Attachment();            
            attach.Body = at.VersionData;
            attach.Name = at.ContentDocument.Title+'.png';
            attach.IsPrivate = false;
            attach.ParentId = parentReferralId;
            //if(Schema.sObjectType.Attachment.isCreateable() &&
           // Schema.sObjectType.Attachment.fields.Body.isCreateable() &&
           // Schema.sObjectType.Attachment.fields.Name.isCreateable() &&
           // Schema.sObjectType.Attachment.fields.ParentId.isCreateable() &&
           // Schema.sObjectType.Attachment.fields.IsPrivate.isCreateable()){
            //insert attach;
            DMLManager.insertAsUser(attach);
          //  }
            
        }
    }
    @Future(callout=true)
    public static void attchAsPDF(Id parentReferralId,String emailReferredOut){
        
       
        System.debug('parentReferralId '+parentReferralId);
        PageReference PDf =  Page.ElixirOEM_ReferralFormPDF;
        PDf.getParameters().put('referralId',parentReferralId);
        PDf.setRedirect(true);
        Attachment attach = new Attachment();
        Blob b ;
        if(Test.isRunningTest()) { 
            b = blob.valueOf('Unit.Test');
        } else {
            b = PDf.getContentAsPDF();
        }        
        attach.Body = b;
        attach.Name = 'Referral Form.pdf';
        attach.IsPrivate = false;
        attach.ParentId = parentReferralId;
        //if(Schema.sObjectType.Attachment.isCreateable() &&
        //Schema.sObjectType.Attachment.fields.Body.isCreateable() &&
        //Schema.sObjectType.Attachment.fields.Name.isCreateable() &&
        //Schema.sObjectType.Attachment.fields.IsPrivate.isCreateable() &&
        //Schema.sObjectType.Attachment.fields.ParentId.isCreateable()){
       // insert attach;
        DMLManager.insertAsUser(attach);
       // }
        startFormPDFCircle(parentReferralId);
        
      
        }
    public static void startFormPDFCircle(Id referralId){
        try{
        ElixirSuite__Referral__c[] parentReferralRecordLst =  [SELECT ID,ElixirSuite__Account__c FROM ElixirSuite__Referral__c 
                                                               WHERE ID =:referralId WITH SECURITY_ENFORCED];
        Id accountId = parentReferralRecordLst[0].ElixirSuite__Account__c;
            system.debug('accountIdaccountId'+accountId);
        List<String> formIDs = new List<String>();
        ElixirSuite__Referral_Data__c[] referralDataLst = [SELECT ID,Name,ElixirSuite__Form_Unique_ID__c FROM ElixirSuite__Referral_Data__c WHERE ElixirSuite__Referral__c=:referralId  WITH SECURITY_ENFORCED];
        for(ElixirSuite__Referral_Data__c sObj : referralDataLst){          
            if(String.isNotBlank(sObj.ElixirSuite__Form_Unique_ID__c)){
                formIDs.add(sObj.ElixirSuite__Form_Unique_ID__c); 
            }
        }
        System.debug('formIDs '+formIDs);
        Id episodeId;
        ElixirOEM_ReferralAsyncPDFGenerator.getFormsDataForPDF(accountId, episodeId,'', formIDs,referralId,accountId);

        }//try end
        catch(Exception e){
            ExceptionLog.logError(e);
            ExceptionLog.logDebugString('Referal Utilty startFormPDFCircle() Exception');
            System.debug('Referal Utilty startFormPDFCircle() Exception '+e);
        }
    }

    public static void sendReferralFormAsAttachmentOnEmail(Set<Id> fileIds,String parentReferralId){
                
        try{
            System.debug('fileIds '+fileIds);
        System.debug('parentReferralId '+parentReferralId);
        String referralMailId = '';
        Messaging.EmailFileAttachment[] attachments = new List<Messaging.EmailFileAttachment>();
        
        List<Attachment> allAttachments = [SELECT Name,Body FROM Attachment WHERE  ParentId =: parentReferralId WITH SECURITY_ENFORCED];
        ElixirSuite__Referral__c[] recordParent = [SELECT ID,ElixirSuite__Email_Referred_To__c,ElixirSuite__Referred_Out_Organization__r.Name,ElixirSuite__Account__r.Name,ElixirSuite__Provider__r.Name FROM ElixirSuite__Referral__c WHERE ID = : parentReferralId  WITH SECURITY_ENFORCED];
        if(recordParent!=null && recordParent.size()>0){
            referralMailId = recordParent[0].ElixirSuite__Email_Referred_To__c;
            System.debug('Emial will send to '+referralMailId);
        }
        for(Attachment atc : allAttachments){
            Messaging.EmailFileAttachment attachForms = new Messaging.EmailFileAttachment();
            attachForms.setContentType('application/pdf');
            attachForms.setFileName(atc.Name); 
            attachForms.setInline(false);
            attachForms.Body = atc.Body; // Notes forms
            attachments.add(attachForms);
        }
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();      
        List<String> allEmailAdd = new List<String>();
        System.debug('referralMailId '+referralMailId);
        allEmailAdd.add(referralMailId);
       EmailTemplate emailTemplate = [SELECT Subject, HtmlValue,Body
                                       FROM EmailTemplate
                                       WHERE DeveloperName = 'Email_Template_for_Referal'
                                       WITH SECURITY_ENFORCED LIMIT 1];
            String emailBody = emailTemplate.HtmlValue;
            String emailSubject = emailTemplate.Subject;
            if(String.isNotBlank(recordParent[0].ElixirSuite__Referred_Out_Organization__r.Name)){
                emailBody = emailBody.replace('{!Referring_Contact_Referring_Organization}',recordParent[0].ElixirSuite__Referred_Out_Organization__r.Name);
            }
            if(String.isNotBlank(recordParent[0].ElixirSuite__Account__r.Name)){
                emailBody = emailBody.replace('{!Account.Name}', recordParent[0].ElixirSuite__Account__r.Name);
                emailSubject = emailSubject.replace('{!Account.Name}',recordParent[0].ElixirSuite__Account__r.Name);
            }
            if(String.isNotBlank(recordParent[0].ElixirSuite__Provider__r.Name)){
                emailBody = emailBody.replace('{!ElixirSuite__Provider__c.Name}',recordParent[0].ElixirSuite__Provider__r.Name);
                emailSubject = emailSubject.replace('{!ElixirSuite__Provider__c.Name}',recordParent[0].ElixirSuite__Provider__r.Name);
            }
            
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTargetObjectId( UserInfo.getUserId() );
        mail.setSaveAsActivity( false );
        mail.setUseSignature(false);
        mail.setToAddresses(allEmailAdd);
            mail.setSubject(emailSubject);
        mail.setHtmlBody(emailBody);
        mail.setFileAttachments(attachments); 
        emails.add(mail);
        Messaging.sendEmail(emails);
        }
		catch(Exception e){
                    ExceptionLog.logError(e);
                }        
    }
    public static void formulateChartSummary(String chartSummaryOptions,ElixirSuite__Referral_Data__c[] referralDataLst,ElixirSuite__Referral__c parentReferral){
        for(Object obj : ElixirOEM_AddEraHelper.utilityMapDeserialize(chartSummaryOptions,'key')){
            Map<String, Object> mapOfPatientCharSummaryData = (Map<String, Object>) obj;          
            Object[] entityLst = (List<Object>) mapOfPatientCharSummaryData.get('entityData');
            String fielApiAndObjectName = labelApiEntityMap.get(String.valueOf(mapOfPatientCharSummaryData.get('label'))); 
            if(!entitiesToExclude.contains(fielApiAndObjectName)){
                if(Boolean.valueOf(mapOfPatientCharSummaryData.get('isOpen'))){   
                    for(Object enitity : entityLst){
                        Map<String, Object> mapOfentityData = (Map<String, Object>) enitity;
                        System.debug('label '+mapOfPatientCharSummaryData.get('label'));
                        if(Boolean.valueOf(mapOfentityData.get('isSelected'))){          
                            ElixirSuite__Referral_Data__c obj_genericEntity = new ElixirSuite__Referral_Data__c();
                            if(fielApiAndObjectName == 'ElixirSuite__Template_Diagnosis_Code__c' || fielApiAndObjectName == 'ElixirSuite__Procedure_Codes__c'){
                            obj_genericEntity.page2__c=true;
                            }
                            obj_genericEntity.ElixirSuite__Referral__c = parentReferral.Id;
                            obj_genericEntity.put(fielApiAndObjectName,String.valueOf(mapOfentityData.get('Id')));                   
                            referralDataLst.add(obj_genericEntity);
                        } 
                    }   
                }
            }
        }  
    }
    public static void formulateDiagnosis(String patientDiagnosisLst, ElixirSuite__Referral_Data__c[] referralDataLst,ElixirSuite__Referral__c parentReferral){
        for(Object obj : ElixirOEM_AddEraHelper.utilityMapDeserialize(patientDiagnosisLst,'key')){
            Map<String, Object> mapOfPatientDiagnosisData = (Map<String, Object>) obj;
            if(Boolean.valueOf(mapOfPatientDiagnosisData.get('isSelected'))){
                ElixirSuite__Referral_Data__c obj_diagnosis = new ElixirSuite__Referral_Data__c();
                obj_diagnosis.ElixirSuite__Referral__c = parentReferral.Id;
                obj_diagnosis.Template_Diagnosis_Code__c = String.valueOf(mapOfPatientDiagnosisData.get('Id'));
                obj_diagnosis.Page1__c = true;
                referralDataLst.add(obj_diagnosis);
            }           
        }     
    } 
    public static  Set<Id> formulateFiles(String filesLst, ElixirSuite__Referral_Data__c[] referralDataLst,ElixirSuite__Referral__c parentReferral){
        Set<Id> contentDocIds = new Set<Id>();
        try{
        for(Object obj : ElixirOEM_AddEraHelper.utilityMapDeserialize(filesLst,'key')){
            Map<String, Object> mapOfFilesData = (Map<String, Object>) obj;
            if(Boolean.valueOf(mapOfFilesData.get('isSelected'))){
                ElixirSuite__Referral_Data__c obj_files = new ElixirSuite__Referral_Data__c();
                obj_files.ElixirSuite__Referral__c = parentReferral.Id;
                obj_files.ElixirSuite__File_ContentDocumentId__c = String.valueOf(mapOfFilesData.get('Id'));
                referralDataLst.add(obj_files);
                contentDocIds.add(String.valueOf(mapOfFilesData.get('Id')));
            }           
        }
        }
        catch(Exception e){
        ExceptionLog.logError(e);
        }
        return contentDocIds;
    } 
    public static void formulateProcedure(String patientProcedureLst, ElixirSuite__Referral_Data__c[] referralDataLst,ElixirSuite__Referral__c parentReferral){
        for(Object obj : ElixirOEM_AddEraHelper.utilityMapDeserialize(patientProcedureLst,'key')){
            Map<String, Object> mapOfPatientProcedureData = (Map<String, Object>) obj;
            if(Boolean.valueOf(mapOfPatientProcedureData.get('isSelected'))){
                ElixirSuite__Referral_Data__c obj_procedure = new ElixirSuite__Referral_Data__c();
                obj_procedure.ElixirSuite__Referral__c = parentReferral.Id;
                obj_procedure.Page1__c = true;
                obj_procedure.Procedure_Codes__c = String.valueOf(mapOfPatientProcedureData.get('Id'));
                referralDataLst.add(obj_procedure);
            }
        }     
    } 
    public static void formulateVOB(String vobId,ElixirSuite__Referral_Data__c[] referralDataLst,ElixirSuite__Referral__c parentReferral){
        ElixirSuite__Referral_Data__c obj_vob = new ElixirSuite__Referral_Data__c();
        obj_vob.ElixirSuite__Referral__c = parentReferral.Id;
        obj_vob.ElixirSuite__VOB__c = vobId;
        referralDataLst.add(obj_vob);
    }
    @AuraEnabled
    public static DetailsWrapper fetchPreviewInitDetails(String accountId,String contactId ){
        DetailsWrapper toRet = new DetailsWrapper();
        try{
        Account[] acctLst = [SELECT ID,Name FROM Account WHERE ID = : accountId  WITH SECURITY_ENFORCED];
        if(acctLst!=null && acctLst.size()>0){
            toRet.accountName = acctLst[0].Name;
        }
        Contact[] contLst = [SELECT ID,Name FROM Contact WHERE ID = :contactId  WITH SECURITY_ENFORCED];
        if(contLst!=null && contLst.size()>0){
            toRet.contactName = contLst[0].Name;
        }
        }
        catch(Exception e){
        ExceptionLog.logError(e);
        }
        return toRet;
    }
    public class DetailsWrapper{
        @AuraEnabled public String accountName;
        @AuraEnabled public String contactName;
    }
    
    
    public static Map<String,String> chartSummaryEntityMap(){
        Map<String,String> labelApiEntityMap = new Map<String,String>();
        labelApiEntityMap.put('Vitals' ,'ElixirSuite__Medical_Examination__c');
        labelApiEntityMap.put('Allergies' , 'ElixirSuite__Medical_Examination__c');
        labelApiEntityMap.put( 'Diagnosis Codes' , 'ElixirSuite__Template_Diagnosis_Code__c');
        labelApiEntityMap.put( 'Procedure Codes' , 'ElixirSuite__Procedure_Codes__c');
        labelApiEntityMap.put( 'Problems' , 'ElixirSuite__Patient_Problem__c');
        labelApiEntityMap.put( 'Medications' , 'ElixirSuite__Prescription_Order__c');
        labelApiEntityMap.put( 'Notes' , 'ElixirSuite__Form_Unique_ID__c');
        labelApiEntityMap.put( 'Lab Results' , 'ElixirSuite__UA_Sample_Details__c');
        return labelApiEntityMap;
    }
    public static List<String> excludeEntitryLst(){
        return new List<String>{'Diagnosis Codes','Procedure Codes'};
            }
}
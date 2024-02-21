public with sharing class ElixirOEM_ReferralPDFHelper { 
    public static ElixirSuite__Referral__c parentReferralRecord {get; set;} 
    public static Account patientInfo {get; set;}  
    public static ElixirSuite__ICD_Codes__c[] diagnosisLst {get; set;}
    public static ElixirSuite__ICD_Codes__c[] diagnosisLstChartSummary {get; set;}
    public static ElixirSuite__Medical_Examination__c[] allergyLst {get; set;}
    public static ElixirSuite__Medical_Examination__c[] vitalLst {get; set;}
    public static ElixirSuite__Procedure__c[] procedureLst {get; set;}
    public static ElixirSuite__Procedure__c[] procedureLstChartsummary {get; set;}
    public static ElixirSuite__Dataset1__c[] problemLst {get; set;} 
    public static ElixirSuite__UA_Sample_Details__c[] labOrderLst {get;set;}
    public static ElixirSuite__Prescription_Order__c[] prescriptionLst {get; set;}  
    public static ElixirSuite__VOB__c patientVOBDetails {get; set;}  
    public static  List<ChartSummary> chartSumLst {get; set;}  
    public static Boolean openForms {get;set;}
    public static List<Elixir_NewAccountAssociatedFormsApex.FormWrapper> referrealSelectedForms {get; set;}  
    public static ContentDocument[] fiels {get;set;}
    public ElixirOEM_ReferralPDFHelper(){
        //    try{
        //   String referralId = 'a1H5Y00000CnsfFUAR';  
        String referralId  = ApexPages.currentPage().getParameters().get('referralId').escapeHtml4();
        System.debug('referralId '+referralId);
        ElixirSuite__Referral__c[] parentReferralRecordLst =  [SELECT ID,Name,ElixirSuite__Email_CTM__c  ,ElixirSuite__Account__c, ElixirSuite__Email_Referred_To__c ,
                                                               ElixirSuite__Instructions__c , ElixirSuite__Phone_CTM__c , 
                                                               ElixirSuite__Phone_Referred_To__c  , ElixirSuite__Provider__r.Name  , 
                                                               ElixirSuite__Reasons_for_Referral__c  , ElixirSuite__Referred_Out_Organization__r.Name  ,
                                                               ElixirSuite__Referred_To__r.Name  , ElixirSuite__User__r.Name FROM ElixirSuite__Referral__c 
                                                               WHERE ID =:referralId WITH SECURITY_ENFORCED];
        System.debug('parentReferrallist in vf '+parentReferralRecord);
        if(parentReferralRecordLst!=null && parentReferralRecordLst.size()>0){
            parentReferralRecord = parentReferralRecordLst[0];
        }
        System.debug('parentReferralRecord in vf '+parentReferralRecord);
        patientDetails(parentReferralRecord.ElixirSuite__Account__c);
        insuranceDetails(parentReferralRecord.ElixirSuite__Account__c);
        defineEntities(referralId); 
        defineChartSummary(referralId,parentReferralRecord.ElixirSuite__Account__c);
        // }//try end 
        /*  catch(Exception e){
ExceptionLog.logError(e);
ExceptionLog.logDebugString('ElixirOEM_ReferralPDFHelper getFiles() Exception');
System.debug('ElixirOEM_ReferralPDFHelper getFiles() Exception '+e);
}*/
    }
    public static void getFiles(Set<Id> documentIds){ 
        // try{
        fiels= [SELECT Id,Title,FileType,CreatedDate FROM ContentDocument 
                WHERE id IN: documentIds WITH SECURITY_ENFORCED
                ORDER BY LastModifiedDate DESC];
        //}//try end 
        /*  catch(Exception e){
ExceptionLog.logError(e);
ExceptionLog.logDebugString('ElixirOEM_ReferralPDFHelper getFiles() Exception');
System.debug('ElixirOEM_ReferralPDFHelper getFiles() Exception '+e);
}*/
    } 
    public static void defineChartSummary(String referralId,String accountId){
        //   try{
        EntityWrapper obj = defineEntities(referralId);
        defineMedicalExamination(obj.medicalExamId);
        defineProcedure(obj.procedureId);
        defineDiagnosis(obj.diagnosisId);
        defineProblem(obj.problemId);
        fetchForms(accountId,obj.formUniqueIdLst);
        definePrescription(obj.prescriptionOrderId);
        defineLabResults(obj.labOrderId);
        getFiles(obj.contentDocId);
        defineDiagnosisChartSummary(obj.pageTwo_diagnosisId);
        System.debug('obj.pageTwo_procedureId '+obj.pageTwo_procedureId);
        defineProcedureChartSummary(obj.pageTwo_procedureId);
       
        
    }
    
    public static void fetchForms(String accountId,List<String> formUniqueIds){
        referrealSelectedForms =    Elixir_NewAccountAssociatedFormsApex.bringData(accountId, '', 'Assessment','referralSelectedForms',formUniqueIds);
        if(referrealSelectedForms!=null && referrealSelectedForms.size()>0){
            openForms = true;
        }
        else {
            openForms = false;
        }
        
    }
    public static void insuranceDetails(String accountId){
        try{
            ElixirSuite__VOB__c[] vobLst = ElixirOEM_NewReferralHelper.patientVOBDetails(accountId);
            if(vobLst!=null && vobLst.size()>0){
                patientVOBDetails  = vobLst[0];
            }
        }//try end 
        catch(Exception e){
            ExceptionLog.logError(e);
            ExceptionLog.logDebugString('ElixirOEM_ReferralPDFHelper insuranceDetails() Exception');
            System.debug('ElixirOEM_ReferralPDFHelper insuranceDetails() Exception '+e);
        }
    }
    public static void patientDetails(String accountId){
        try{
            Account[] acctLst = ElixirOEM_NewReferralHelper.patientDetails(accountId);
            if(acctLst!=null && acctLst.size()>0){
                patientInfo  = acctLst[0];
            }
        }//try end 
        catch(Exception e){
            ExceptionLog.logError(e);
            ExceptionLog.logDebugString('ElixirOEM_ReferralPDFHelper patientDetails() Exception');
            System.debug('ElixirOEM_ReferralPDFHelper patientDetails() Exception '+e);
        } 
    }
    
    /** Ref Pdf should maintain Procedures and Dignose codes disictly for NewRef_Screen1 ,RefInfo_Screen2.ThThese flags will be used for it.
**/
    //ElixirSuite__New_Ref_screen1__c,ElixirSuite__Ref_Info_screen2__c,
    public static EntityWrapper defineEntities(String referralId){
        ElixirSuite__Referral_Data__c[] referralDataLst = [SELECT ID,Name,
                                                           ElixirSuite__File_ContentDocumentId__c,ElixirSuite__Form_Unique_ID__c,
                                                           ElixirSuite__UA_Sample_Details__c,ElixirSuite__Prescription_Order__c,
                                                           ElixirSuite__Patient_Problem__c,ElixirSuite__Procedure_Codes__c,
                                                           ElixirSuite__Medical_Examination__c,ElixirSuite__Template_Diagnosis_Code__c ,Page1__c,Page2__c
                                                           FROM ElixirSuite__Referral_Data__c WHERE ElixirSuite__Referral__c=:referralId 
                                                           WITH SECURITY_ENFORCED];
        System.debug('defineEntities() referralDataLst - '+referralDataLst);
        EntityWrapper wrp = new EntityWrapper();
        //   try{
        for(ElixirSuite__Referral_Data__c sObj : referralDataLst){
            if(String.isNotBlank(sObj.ElixirSuite__Medical_Examination__c)){
                wrp.medicalExamId.add(sObj.ElixirSuite__Medical_Examination__c);
            }
            else if(String.isNotBlank(sObj.ElixirSuite__Template_Diagnosis_Code__c)){
                if(sObj.Page1__c == true){
                    wrp.diagnosisId.add(sObj.ElixirSuite__Template_Diagnosis_Code__c);
                }
                if(sObj.Page2__c == true){
                    wrp.pageTwo_diagnosisId.add(sObj.ElixirSuite__Template_Diagnosis_Code__c);
                }
            }
            else if(String.isNotBlank(sObj.ElixirSuite__Procedure_Codes__c)){
                if(sObj.Page1__c == true){
                    wrp.procedureId.add(sObj.ElixirSuite__Procedure_Codes__c); 
                }
                if(sObj.Page2__c == true){
                   wrp.pageTwo_procedureId.add(sObj.ElixirSuite__Procedure_Codes__c); // look what is happening
                }
                
            }
            else if(String.isNotBlank(sObj.ElixirSuite__Patient_Problem__c)){
                wrp.problemId.add(sObj.ElixirSuite__Patient_Problem__c); 
            }
            else if(String.isNotBlank(sObj.ElixirSuite__Prescription_Order__c)){
                wrp.prescriptionOrderId.add(sObj.ElixirSuite__Prescription_Order__c); 
            }
            else if(String.isNotBlank(sObj.ElixirSuite__UA_Sample_Details__c)){
                wrp.labOrderId.add(sObj.ElixirSuite__UA_Sample_Details__c); 
            }
            else if(String.isNotBlank(sObj.ElixirSuite__Form_Unique_ID__c)){
                wrp.formUniqueIdLst.add(sObj.ElixirSuite__Form_Unique_ID__c); 
            }
            else if(String.isNotBlank(sObj.ElixirSuite__File_ContentDocumentId__c)){
                wrp.contentDocId.add(sObj.ElixirSuite__File_ContentDocumentId__c); 
            }
        }    
        //  }
        //try end 
        /*   catch(Exception e){
ExceptionLog.logError(e);
ExceptionLog.logDebugString('ElixirOEM_ReferralPDFHelper defineEntities() Exception');
System.debug('ElixirOEM_ReferralPDFHelper defineEntities() Exception '+e);
}    */
        return wrp;
    }
    public class EntityWrapper{
        Set<Id> medicalExamId = new Set<Id>();
        Set<Id> diagnosisId = new Set<Id>();
        Set<Id> pageTwo_diagnosisId = new Set<Id>();
        Set<Id> procedureId = new Set<Id>();
        Set<Id> pageTwo_procedureId = new Set<Id>();
        Set<Id> problemId = new Set<Id>();
        Set<Id> prescriptionOrderId = new Set<Id>();
        List<String> formUniqueIdLst = new List<String>();// Form ID  here
        Set<Id> labOrderId = new Set<Id>();
        Set<Id> contentDocId = new Set<Id>();
    }
    public static void defineDiagnosis(Set<Id> diagnosisId){
        diagnosisLst = [SELECT ID,Name,ElixirSuite__Code_Description1__c FROM ElixirSuite__ICD_Codes__c
                        WHERE ID IN : diagnosisId with security_enforced];
    }
    public static void defineDiagnosisChartSummary(Set<Id> diagnosisId){
        diagnosisLstChartSummary = [SELECT ID,Name,ElixirSuite__Code_Description1__c,ElixirSuite__Version__c,ElixirSuite__Diagnosis_Code_and_Name__c FROM ElixirSuite__ICD_Codes__c
                                    WHERE ID IN : diagnosisId with security_enforced];
    }
      public static void defineProcedureChartSummary(Set<Id> procedureId){
        procedureLstChartsummary =[SELECT ID,Name,ElixirSuite__Code_Description__c,ElixirSuite__Code_Category__c FROM ElixirSuite__Procedure__c
                        WHERE ID IN : procedureId with security_enforced];
    }
    public static MedicalExaminationWrapper defineMedicalExamination(Set<Id> medicalExamId){
        System.debug('medicalExamId '+medicalExamId);
        Id Allergy = Schema.SObjectType.ElixirSuite__Medical_Examination__c.getRecordTypeInfosByDeveloperName().get('Allergy').getRecordTypeId();
        Id Vital_Sign = Schema.SObjectType.ElixirSuite__Medical_Examination__c.getRecordTypeInfosByDeveloperName().get('Vital_Sign').getRecordTypeId();
        allergyLst = [SELECT ID,Name,BMI__c,Allergy_Name__c,Reaction__c, Severity__c,Note__c,CreatedDate FROM ElixirSuite__Medical_Examination__c
                      WHERE ID IN : medicalExamId AND RecordTypeId =:Allergy  with security_enforced];
        vitalLst = [SELECT ID,Name,BMI__c, Temperature__c,Pulse__c,Blood_Pressure_Diasystolic__c,Blood_Pressure_Systolic__c,CreatedDate FROM ElixirSuite__Medical_Examination__c
                    WHERE ID IN : medicalExamId AND RecordTypeId =:Vital_Sign  with security_enforced];
        System.debug('vitalLst '+vitalLst.size());
        MedicalExaminationWrapper toRet = new MedicalExaminationWrapper();
        toRet.allergyLst = allergyLst;
        toRet.vitallst = allergyLst;
        return toRet;
    }
    public class MedicalExaminationWrapper{
        public ElixirSuite__Medical_Examination__c[] allergyLst;
        public  ElixirSuite__Medical_Examination__c[] vitallst;
    }
    public static void defineProcedure(Set<Id> procedureId){
        procedureLst = [SELECT ID,Name,ElixirSuite__Code_Description__c FROM ElixirSuite__Procedure__c
                        WHERE ID IN : procedureId with security_enforced]; 
    }
   
    public static void defineProblem(Set<Id> problemId){
        try{
            problemLst = [SELECT ID,Name,SNOMED_CT_Code__c,Problem_Type__c,CreatedDate ,Date_Onset__c FROM ElixirSuite__Dataset1__c
                          WHERE ID IN : problemId with security_enforced]; 
        }//try end 
        catch(Exception e){
            ExceptionLog.logError(e);
            ExceptionLog.logDebugString('RefPdfHelper defineProblem() Exception');
            System.debug('RefPdfHelper defineProblem() Exception '+e);
        }  
    }
    
    public static void definePrescription(Set<Id> prescriptionId){
        try{
            prescriptionLst = [SELECT ID,Name,Reason_new__c,Drug_Name__c,Route_New__c,Number_of_Times_Days_Weeks__c,CreatedDate FROM ElixirSuite__Prescription_Order__c 
                               WHERE ID IN : prescriptionId with security_enforced]; 
        }//try end 
        catch(Exception e){
            ExceptionLog.logError(e);
            ExceptionLog.logDebugString('RefPdfHelper definePrescription() Exception');
            System.debug('RefPdfHelper definePrescription() Exception '+e);
        } 
    }
    
    public static void defineLabResults(Set<Id> labOrderId){
        try{       
            labOrderLst = [SELECT ID,Name,Medical_Test__c,Status__c,CreatedDate FROM ElixirSuite__UA_Sample_Details__c 
                           WHERE ID IN : labOrderId with security_enforced];
        }//try end 
        catch(Exception e){
            ExceptionLog.logError(e);
            ExceptionLog.logDebugString('RefPdfHelper defineLabResults() Exception');
            System.debug('RefPdfHelper defineLabResults() Exception '+e);
        } 
    }
    
    public class ChartSummary{
        public String label {get; set;}	//Vitals
        public boolean isOpen {get; set;}
        public boolean disabled {get; set;}
        public sObject[] entityData {get; set;}
    }
    
}
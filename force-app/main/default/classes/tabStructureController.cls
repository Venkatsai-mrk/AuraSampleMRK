/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-15-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class tabStructureController {
    
    public static String pwdm {get;set;} 
    public static String oldCode {get;set;}
    public static String namespace {get;set;}
    
    @AuraEnabled
    public static String getAccess(){
        /*List<string> recordTypeList= new List<string>();
        List<string> recordTypeList1= new List<string>();
        List<string> recordTypeList2= new List<string>(); 
        Map<string, boolean> tabAccessibilityMap= new Map<string, boolean>(); */
        namespace = Elixir_Utility.getNamespace() ;
        //   system.debug('bam' + Elixir_Utility.getNamespace());
        //For Clinician, Nursing, Doctor, Case Management assessment tabs
        /*for(RecordTypeInfo info: Assessments__c.SObjectType.getDescribe().getRecordTypeInfos()) {
if(info.isAvailable()) {
recordTypeList.add(info.getName());
}
}*/
        
        /*    for(string rec : recordTypeList){
if(rec == 'Bio Psych Social'){
tabAccessibilityMap.put('Clinician', True);
}
if(rec == 'Nursing Assessment'){
tabAccessibilityMap.put('Nursing', True);
}
if(rec == 'H&P'){
tabAccessibilityMap.put('Doctor', True);
}
if(rec == 'Case Management assessment'){
tabAccessibilityMap.put('CaseManagement', True);
}
}

//For UR Notes and Dc and transfer tabs
for(RecordTypeInfo info: Notes__c.SObjectType.getDescribe().getRecordTypeInfos()) {
if(info.isAvailable()) {
recordTypeList1.add(info.getName());
}
}
for(string rec : recordTypeList1){
if(rec == 'UR Notes'){
tabAccessibilityMap.put('URNotes', True);
}
if(rec == 'DC/Transfer Notes'){
tabAccessibilityMap.put('DCTransfer', True);
}
}

//For Inventory Tab
Schema.DescribeSObjectResult InventoryDescribe = Inventory__c.sObjectType.getDescribe();
if(InventoryDescribe.accessible){
tabAccessibilityMap.put('Inventory', True);
}*/
        
        /*For condition tab
Schema.DescribeSObjectResult ehrcondition = HealthCloudGA__EhrCondition__c.sObjectType.getDescribe();
if(ehrcondition.accessible){
tabAccessibilityMap.put('EHRCondition', True);
}
Schema.DescribeSObjectResult ehrprocedure = HealthCloudGA__EHRProcedure__c.sObjectType.getDescribe();
if(ehrprocedure.accessible){
tabAccessibilityMap.put('EHRProcedure', True);
}*/
        
        //   return tabAccessibilityMap;   
        return namespace ;
    }
    
    /* @AuraEnabled
public static boolean generateClaimMethod(Id patientId){
boolean status;
Account patient = new Account();
List<HealthCloudGA__EhrCondition__c> condition = new List<HealthCloudGA__EhrCondition__c>();
List<HealthCloudGA__EhrProcedure__c> procedure = new List<HealthCloudGA__EhrProcedure__c>();
if(schema.sobjecttype.Account.isAccessible()
&& schema.sobjecttype.Account.fields.Treatment_Center__c.isAccessible()
&& schema.sobjecttype.Account.fields.Admit_Date__c.isAccessible()
&& schema.sobjecttype.Account.fields.Discharge_Date__c.isAccessible())
{
patient = [select Id,Gender__c, name, admit_date__c,treatment_center__r.treatment_center_name__c, discharge_date__c from account where Id=:patientId];
}
if(schema.sobjecttype.HealthCloudGA__EhrCondition__c.isAccessible()
&& schema.sobjecttype.HealthCloudGA__EhrCondition__c.fields.claim__c.isAccessible()
&& schema.sobjecttype.HealthCloudGA__EhrCondition__c.fields.HealthCloudGA__Account__c.isAccessible())
{
condition = [select Id, claim__c from HealthCloudGA__EhrCondition__c where HealthCloudGA__Account__c=:patientId and claim__c=null];
//procedure = [select Id, claim__c from HealthCloudGA__EhrProcedure__c where HealthCloudGA__Account__c=:patientId and claim__c=null];

}
if(condition.size()>0){
Claim__c claim = new Claim__c();
if(schema.sobjecttype.Claim__c.isCreateable()){
claim.admit_date__c =patient.admit_date__c;
claim.discharge_date__c= patient.discharge_date__c;
claim.Account__c=patientId;
claim.Treatment_Center_facility__c=patient.treatment_center__r.treatment_center_name__c;
claim.Type_Of_Bill__c='111';
claim.Patient__c= (patient.name).split(' ')[0];
claim.Patient_Last_Name__c = (patient.name).split(' ')[1];
claim.Gender__c = patient.Gender__c;
insert claim;

}
for(HealthCloudGA__EhrCondition__c cond: condition){
if(schema.sobjecttype.HealthCloudGA__EhrCondition__c.isAccessible()
&& schema.sobjecttype.HealthCloudGA__EhrCondition__c.fields.Claim__c.isAccessible()){
cond.Claim__c= claim.Id;
system.debug('condition----'+cond);
update condition;
}
return true;
}
/* for(HealthCloudGA__EhrProcedure__c proc: procedure){
if(schema.sobjecttype.HealthCloudGA__EhrProcedure__c.isAccessible()
&& schema.sobjecttype.HealthCloudGA__EhrProcedure__c.fields.Claim__c.isAccessible()){
//proc.Claim__c= claim.Id;
system.debug('condition----'+proc);
update procedure;
}
return true;
}
}

return false;

}*/
    @AuraEnabled
    public static TabClass tabPermission()
    { 
        Id profileId=userinfo.getProfileId();
        TabPermissionBasedOnProfiles__c cs = TabPermissionBasedOnProfiles__c.getInstance(profileId);
        TabClass wrap = new TabClass();
        try{
        
        wrap.isCaptureSignature = cs.Capture_Signature__c;
        wrap.isMedicalExamination = cs.Medical_Examination__c;
        wrap.isLabOrders = cs.Lab_Orders__c ;
        wrap.isPrescriptions =  cs.Prescriptions__c;
        wrap.isProcedure =  cs.Procedure__c;
        wrap.isProgressNotes =  cs.Progress_Notes__c;
        wrap.isNotesForms =  cs.Notes_Forms__c;
        wrap.isCareEpisode =  cs.Care_Episode__c;
        wrap.isDischargeForm =  cs.Discharge_Form__c;
        wrap.isTimeline =  cs.Timeline__c;
        wrap.isBillingSummary =  cs.ElixirSuite__Billing_Summary__c;
        wrap.isGenerateVerificationCode =  cs.Generate_Verification_Code__c;
        wrap.isAdmissionForms =  cs.Admission_Forms__c;
        wrap.isCarePlan =  cs.Care_Plan__c;
        wrap.isMessaging =  cs.Messaging__c;
        wrap.isNursingForms =  cs.Nursing_Forms__c;
        wrap.isMorMar =  cs.MOR_MAR__c;
        wrap.isFirstVisitNotes =  cs.First_Visit_Notes__c;
        wrap.isClinicalForms =  cs.Clinical_Forms__c;
        wrap.isReviewForms =  cs.Review_Forms__c;
        wrap.isSendDataForClaims =  cs.Send_Data_For_Claims__c;
        wrap.isMasterProblemList =  cs.Master_Problem_List__c;
        wrap.isTransportation = cs.Transportation__c;
        //below 5 lines added by Anmol
        wrap.costOfCare = cs.CostOfCare__c;
        wrap.paymentSchedule = cs.PaymentSchedule__c;
        wrap.claims = cs.Claims__c;
        wrap.payment = cs.Payment__c;
        wrap.patientStatement = cs.PatientStatement__c;
        wrap.medicalCoding = cs.MedicalCoding__c;
        // Below 5 lines added by Himanshu
        //wrap.isCHCPrescription = cs.CHC_Prescription_Order__c;
        wrap.isNewCropPrescription = cs.NewCrop_Prescription_Order__c;
        wrap.isIntegratedLabOrder = cs.Integrated_Lab_Order__c;
        wrap.isPrescriptionPrio = cs.ElixirSuite__Prescription_Priority__c;
        wrap.isLabOrderPrio = cs.ElixirSuite__LabOrder_Priority__c;        
        wrap.isImmunization = cs.Immunization__c;
        //Below two lines are added by Shubham
        wrap.dummyLabOrder = cs.ElixirSuite__LabOrder_Priority__c.contains('Dummy LabOrder'); 
        wrap.cHCLabOrder=cs.ElixirSuite__LabOrder_Priority__c.contains('CHC LabOrder');
        wrap.cs = cs;
        }
        catch(Exception e){
            
            ExceptionLog.logError(e);
        }
        return wrap;
    }
    public class TabClass{
        @AuraEnabled public Boolean isCaptureSignature;
        @AuraEnabled public Boolean isMedicalExamination;
        @AuraEnabled public Boolean isLabOrders;
        @AuraEnabled public Boolean isPrescriptions;
        @AuraEnabled public Boolean isProcedure;
        @AuraEnabled public Boolean isProgressNotes;
        @AuraEnabled public Boolean isNotesForms;
        @AuraEnabled public Boolean isCareEpisode;
        @AuraEnabled public Boolean isDischargeForm;
        @AuraEnabled public Boolean isTimeline;
        @AuraEnabled public Boolean isBillingSummary; //Added by Avani Jain
        @AuraEnabled public Boolean isGenerateVerificationCode;
        @AuraEnabled public Boolean isAdmissionForms;
        @AuraEnabled public Boolean isCarePlan;
        @AuraEnabled public Boolean isMessaging;//Added by Mahendta
        @AuraEnabled public Boolean isNursingForms;
        @AuraEnabled public Boolean isMorMar;
        @AuraEnabled public Boolean isFirstVisitNotes;
        @AuraEnabled public Boolean isClinicalForms;
        @AuraEnabled public Boolean isReviewForms;
        @AuraEnabled public Boolean isSendDataForClaims;
        @AuraEnabled public Boolean isMasterProblemList;
        @AuraEnabled public Boolean isTransportation;
         @AuraEnabled public Boolean costOfCare; //Added by Anmol
         @AuraEnabled public Boolean paymentSchedule; //Added by Anmol
         @AuraEnabled public Boolean claims; //Added by Anmol
         @AuraEnabled public Boolean payment; //Added by Anmol
         @AuraEnabled public Boolean patientStatement; //Added by Anmol
        @AuraEnabled public Boolean medicalCoding; //Added by Anmol
        @AuraEnabled public Boolean isCHCPrescription; //Added by Himanshu
        @AuraEnabled public Boolean isNewCropPrescription; //Added by Himanshu
        @AuraEnabled public Boolean isIntegratedLabOrder; //Added by Himanshu
        @AuraEnabled public String isPrescriptionPrio; //Added by Himanshu
        @AuraEnabled public String isLabOrderPrio; //Added by Himanshu
        @AuraEnabled public Boolean dummyLabOrder;//Added by Shubham 
        @AuraEnabled public Boolean cHCLabOrder;//Added by Shubham
        @AuraEnabled public Boolean isImmunization ; //Added by Nithin 
        @AuraEnabled public TabPermissionBasedOnProfiles__c cs;
    }
    
    @AuraEnabled
    public static License_Class licensBasdPermission()
    {
        Id currentUid = UserInfo.getUserId();
        String availLicense = [Select Id,ElixirSuite__License_Type__c,Username,Name from User 
        where Id =:currentUid WITH SECURITY_ENFORCED].ElixirSuite__License_Type__c;
        List<String> lstAvailLicense = new List<String>();
        lstAvailLicense = availLicense.split(';');
        License_Class lCls = new License_Class();
        try{
          //  lCls.labelApicombo =   ElixirOEM_FormConfigurationHelper.fetchFieldsForSelectedObject('ElixirSuite__TabPermissionBasedOnProfiles__c');
            lCls.subTabPicklistValue = ElixirOEM_FormConfigurationHelper.fetchPickListValue('ElixirSuite__Master_Object__c','ElixirSuite__TABSub_Tab_Label__c'); 
        for(String str : lstAvailLicense)
        {
            if(str == 'Elixir EHR')
            {
                lCls.isEhr = True;
                continue;
            }
           
            if(str == 'Elixir Contact Center')
            {
                lCls.isContactCenter = True;
                continue;
            }
            
            if(str == 'Elixir RCM')
            {
                lCls.isRcm = True;
                continue;
            }
            
        }
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        return lCls;
    }
    // Method (accountFieldValidation) added by Himanshu Tajne
    @AuraEnabled
    public static List<Boolean> accountFieldValidation(String accId){
        List<Boolean> finalToastToShow = new List<Boolean>();
        Account acc = [Select id, Name, ElixirSuite__DOB__c, Phone, BillingPostalCode from Account where Id =: accId WITH SECURITY_ENFORCED];
        Boolean dOB = false;
        Boolean ph = false;
        Boolean zipCode = false;
        //system.debug(acc.BillingPostalCode);
        //system.debug(acc.ElixirSuite__DOB__c);
        //system.debug(acc.Phone.length());
        //system.debug(acc.BillingPostalCode.length());
        if(acc.ElixirSuite__DOB__c > System.today()){
            dOB = true;
            //system.debug('if1');
        }
        else if(String.isBlank(acc.Phone) || acc.Phone.length() != 10){
			ph = true;
            //system.debug('if2');
        }
        else if(String.isBlank(acc.BillingPostalCode) || acc.BillingPostalCode.length() != 5 && acc.BillingPostalCode.length() != 9){
            zipCode = true;
            //system.debug('if3');
        }
        finalToastToShow.add(dOB);
        finalToastToShow.add(ph);
        finalToastToShow.add(zipCode);
        //system.debug(finalToastToShow);
        return finalToastToShow;
    }
    
    @AuraEnabled
    public static List<Boolean> vobValidation(String accId){
        ElixirSuite__VOB__c vobLst = [Select id, ElixirSuite__InsPhone__c, ElixirSuite__Patient_Relationship_With_Insured__c,  ElixirSuite__Insured_Zipcode__c, ElixirSuite__Insured_First_Name__c, ElixirSuite__Gender__c, ElixirSuite__Address_Same_as_Patient__c, ElixirSuite__Insured_City__c, ElixirSuite__Date_Of_Birth__c, ElixirSuite__Insured_State__c, ElixirSuite__Insured_Last_Name__c, ElixirSuite__Account__c, ElixirSuite__Group_Number__c, ElixirSuite__Insurance_Policy_ID__c, ElixirSuite__Insurance_Providers__c, ElixirSuite__Reason_for__c from ElixirSuite__VOB__C where ElixirSuite__Account__r.Id =: accId WITH SECURITY_ENFORCED];
        List<Boolean> finalToastToShow = new List<Boolean>();
        boolean phone = false;
        boolean gender = false;
        boolean zip = false;
        boolean frsName = false;
        boolean lstName = false;
        boolean forChild = false;
        boolean acc = false;
        boolean ins = false;
        boolean insPolicyId = false;
        boolean insProvider = false;
        
        if(vobLst != null){
            if(String.isBlank(vobLst.ElixirSuite__InsPhone__c) || vobLst.ElixirSuite__InsPhone__c.length() != 10){
                phone = true;
            }
            else if(String.isBlank(vobLst.ElixirSuite__Gender__c)){
                gender = true;
            }
            else if(String.isBlank(vobLst.ElixirSuite__Insured_Zipcode__c) || vobLst.ElixirSuite__Insured_Zipcode__c.length() != 5 && vobLst.ElixirSuite__Insured_Zipcode__c.length() != 9){
                zip = true;
            }
            else if(String.isBlank(vobLst.ElixirSuite__Insured_First_Name__c)){
                frsName = true;
            }
            else if(String.isBlank(vobLst.ElixirSuite__Insured_Last_Name__c)){
                lstName = true;
            }
            else if(vobLst.ElixirSuite__Patient_Relationship_With_Insured__c == '19' && String.isBlank(vobLst.ElixirSuite__Insured_City__c) && String.isBlank(vobLst.ElixirSuite__Insured_State__c)){
               
                forChild = true;
                
            }
        	else if(String.isBlank(vobLst.ElixirSuite__Account__c)){
                acc = true;
            }
            else if(String.isBlank(vobLst.ElixirSuite__Group_Number__c)){
                ins = true;
            }
            else if(String.isBlank(vobLst.ElixirSuite__Insurance_Policy_ID__c)){
                insPolicyId = true;
            }
            else if(String.isBlank(vobLst.ElixirSuite__Insurance_Provider_Sec__c)){
                insProvider = true;
            }
            
            finalToastToShow.add(phone);
            finalToastToShow.add(gender);
            finalToastToShow.add(zip);
        	finalToastToShow.add(frsName);
        	finalToastToShow.add(lstName);
            finalToastToShow.add(forChild); 
            finalToastToShow.add(acc);
            finalToastToShow.add(ins);
            finalToastToShow.add(insPolicyId);
            finalToastToShow.add(insProvider);
        }
        return finalToastToShow;
    }
    
    //newCrop Validation
    @AuraEnabled
    public static List<Boolean> accNewCropFieldValidation(String accId){
        List<Boolean> finalToastToShow = new List<Boolean>();
        Account acc = [select id, Name,ElixirSuite__First_Name__c, ElixirSuite__Last_Name__c, Phone, ElixirSuite__Gender__c, ElixirSuite__DOB__c, BillingCountry, BillingCity, BillingStreet, BillingState, BillingPostalCode from Account  where Id =: accId WITH SECURITY_ENFORCED] ;
        
        //Pluggable class
        List<ElixirSuite__Elixir_Pluggable_Classes__mdt> newCropPluggableData =[Select Id from ElixirSuite__Elixir_Pluggable_Classes__mdt where Label='NewCropPrescriptionCallout' WITH SECURITY_ENFORCED limit 1];

        Boolean fName = false;
        Boolean lName = false;
        Boolean gender = false;
        Boolean dOB = false;
        Boolean ph = false;
        Boolean zipCode = false;
        Boolean street = false;
        Boolean city = false;
        Boolean state = false;
        Boolean country = false;
        Boolean pluggableRecord = false;
       
    
        if(String.isBlank(String.ValueOf(acc.ElixirSuite__DOB__c)) ||  acc.ElixirSuite__DOB__c > System.today()){
            dOB = true;
           
        }
        else if(String.isBlank(acc.Phone) || acc.Phone.length() != 10){
			ph = true;
           
        }
        else if(String.isBlank(acc.BillingPostalCode) || acc.BillingPostalCode.length() != 5){
            zipCode = true;
           
        }
        else if(String.isBlank(acc.ElixirSuite__First_Name__c) ){
            fName = true;
            
        }
        else if(String.isBlank(acc.ElixirSuite__Last_Name__c) ){
            lName = true;
           
        }
        else if(String.isBlank(acc.ElixirSuite__Gender__c) ){
            gender = true;
            
        }
       
        else if(String.isBlank(acc.BillingStreet) ){
            street = true;
           
        }
        else if(String.isBlank(acc.BillingCity)){
            city = true;  
        }
        else if(String.isBlank(acc.BillingState) ){
            state = true;
           
        }
        else if(String.isBlank(acc.BillingCountry) || (acc.BillingCountry != 'US' && acc.BillingCountry != 'CA' && acc.BillingCountry!= 'MX' )){
            country = true;
           
        }
        else if(newCropPluggableData.size() ==0 && newCropPluggableData.isEmpty()){
            pluggableRecord =true;
        }
        
        finalToastToShow.add(dOB);
        finalToastToShow.add(ph);
        finalToastToShow.add(zipCode);
        finalToastToShow.add(fName);
        finalToastToShow.add(lName);
        finalToastToShow.add(gender);
        finalToastToShow.add(street);
        finalToastToShow.add(city);
         finalToastToShow.add(state);
         finalToastToShow.add(country);
         finalToastToShow.add(pluggableRecord);
        //system.debug(finalToastToShow);
        return finalToastToShow;
    }
    
    public class License_Class
    {
        @AuraEnabled public Boolean isEhr;
        @AuraEnabled public Boolean isRcm;
        @AuraEnabled public Boolean isContactCenter;
        @AuraEnabled public Map<String,String> labelApicombo = new Map<String,String>();
        @AuraEnabled public Map<String, String> subTabPicklistValue = new Map<String,String>();
    }  
    
    @AuraEnabled
    public static Sorted_List_Wrapper_For_Match sendEmail ( Id recordId) {
       
       Account acc = [SELECT id ,Email_Id__c FROM Account WHERE Id =: recordId WITH SECURITY_ENFORCED];
      //  List<Contact> con = [SELECT Id, Name , email FROM Contact WHERE Id =: acc.ContactId];
     //   System.debug('genrate ot[p '+con);
        if(acc.Email_Id__c != null){
            pwdm = generatePassword();
            // Send email to the account's email address  
           messaging.SingleEmailMessage email1=new messaging.SingleEmailMessage();
            string[]toAdd=new string[]{acc.Email_Id__c};
                email1.setToAddresses(toAdd);
            email1.setSubject('Verification Code For e-signing signatures');
            email1.setPlainTextBody('The verification code is' + ' ' + pwdm);
            email1.setSenderDisplayName('Treatment center');
           email1.setTargetObjectId(UserInfo.getUserId());
            email1.setTreatTargetObjectAsRecipient(false);
            email1.setSaveAsActivity(false);
            messaging.Email[] emails = new messaging.Email[]{email1};
                messaging.sendEmail(emails);
            
            List<Account> result = new List<Account>();
            result = [SELECT id , Verification_Code__c
                      FROM Account where id =: recordId 
                      WITH SECURITY_ENFORCED
                      limit 1];
            //system.debug('the lost is' + result);
            for(Account afv : result){
                afv.Verification_Code__c = pwdm ;      
            } 
            if(Schema.sObjectType.Account.isUpdateable() &&
            Schema.sObjectType.Account.fields.Verification_Code__c.isUpdateable()){
                update result ;
               // DMLManager.updateAsUser(result);
           // ExceptionLog.logDebugString('resultresult123' + result);
            }
        }
        oldCode = pwdm ;
        //System.debug('oldCode' + oldCode);
       // System.debug('con[0].email' + con[0].email);
        Sorted_List_Wrapper_For_Match obj = new Sorted_List_Wrapper_For_Match(acc.Email_Id__c , oldCode );
        return obj;
        
    }
    
    @AuraEnabled
    public static Sorted_List_Wrapper_For_Match sendEmailFromPortal(Id recordId) {
       
       Account acc = [SELECT id ,Email_Id__c FROM Account WHERE Id =: recordId WITH SECURITY_ENFORCED];
        if(acc.Email_Id__c != null){
            pwdm = generatePassword();
            List<OrgWideEmailAddress> lstEmailAddress=[select Id,Address,DisplayName from OrgWideEmailAddress WHERE DisplayName = 'Elixir Patient Portal'];
           messaging.SingleEmailMessage email1=new messaging.SingleEmailMessage();
            string[]toAdd=new string[]{acc.Email_Id__c};
                email1.setToAddresses(toAdd);
            if(lstEmailAddress != null && !lstEmailAddress.isEmpty()){
            email1.setOrgWideEmailAddressId(lstEmailAddress[0].Id);
            }
            email1.setSubject('Verification Code For e-signing signatures');
            email1.setPlainTextBody('The verification code is' + ' ' + pwdm);
            //email1.setSenderDisplayName('Treatment center');
           email1.setTargetObjectId(UserInfo.getUserId());
            email1.setTreatTargetObjectAsRecipient(false);
            email1.setSaveAsActivity(false);
            messaging.Email[] emails = new messaging.Email[]{email1};
                messaging.sendEmail(emails);
            
            List<Account> result = new List<Account>();
            result = [SELECT id , Verification_Code__c
                      FROM Account where id =: recordId 
                      WITH SECURITY_ENFORCED
                      limit 1];
            //system.debug('the lost is' + result);
            for(Account afv : result){
                afv.Verification_Code__c = pwdm ;      
            } 
            if(Schema.sObjectType.Account.isUpdateable() &&
            Schema.sObjectType.Account.fields.Verification_Code__c.isUpdateable()){
                update result ;
            }
        }
        oldCode = pwdm ;
        //System.debug('oldCode' + oldCode);
       // System.debug('con[0].email' + con[0].email);
        Sorted_List_Wrapper_For_Match obj = new Sorted_List_Wrapper_For_Match(acc.Email_Id__c , oldCode );
        return obj;
        
    }
    
    public static string generatePassword(){
        Integer len = 6;
        Blob blobKey = crypto.generateAesKey(128);
        String key = EncodingUtil.convertToHex(blobKey);
        String pwd = key.substring(0,len);
        return pwd ;
    }
    @AuraEnabled
    public static DynamicTabStructureWrapper fetchDynamicTabStructureData(string Recid){
        String recType =  Schema.SObjectType.ElixirSuite__Master_Object__c.getRecordTypeInfosByDeveloperName().get('EHR_Tab').getRecordTypeId();
        List<Master_Object__c> allObjectsToDisplayOnTimeline = [SELECT Name,ElixirSuite__Sort_Order__c,ElixirSuite__TABSub_Tab_Label__c,ElixirSuite__Pre_Launch_Validation__c,
        ElixirSuite__TAB_Event_Params__c,ElixirSuite__TAB_Icon_Name__c,ElixirSuite__TAB_Is_Direct_Tab_Launch__c,ElixirSuite__TAB_Component_Attributes__c,ElixirSuite__TAB_Component_Definition__c,
        ElixirSuite__TAB_Is_Sub_Tab_Allowed__c,ElixirSuite__Tab_Label__c,ElixirSuite__TAB_Method_Name_If_Any__c,ElixirSuite__TAB_Form_Categories__c,ElixirSuite__Enable_Session_Note__c,
        ElixirSuite__TAB_Navigation_Event__c,ElixirSuite__TAB_Type_Of_Launch__c,Id,RecordTypeId,ElixirSuite__App_Type__c,
        (SELECT ElixirSuite__Sort_Order__c,ElixirSuite__TABSub_Tab_Label__c,ElixirSuite__TAB_Component_Definition__c,ElixirSuite__TAB_Component_Attributes__c,
        ElixirSuite__TAB_Event_Params__c,ElixirSuite__TAB_Icon_Name__c,ElixirSuite__TAB_Is_Direct_Tab_Launch__c,ElixirSuite__Pre_Launch_Validation__c,
        ElixirSuite__TAB_Is_Sub_Tab_Allowed__c,ElixirSuite__Tab_Label__c,ElixirSuite__TAB_Method_Name_If_Any__c,
        ElixirSuite__TAB_Navigation_Event__c,ElixirSuite__TAB_Type_Of_Launch__c,Id,RecordTypeId,ElixirSuite__App_Type__c FROM Master_Objects__r)
        FROM ElixirSuite__Master_Object__c
        WHERE RecordTypeId =:recType AND ElixirSuite__Master_Object__c = null AND ElixirSuite__App_Type__c INCLUDES (:Recid)
                                                                WITH SECURITY_ENFORCED LIMIT 49999];
        DynamicTabStructureWrapper obj = new DynamicTabStructureWrapper();
      /*  for(ElixirSuite__Master_Object__c m : allObjectsToDisplayOnTimeline){
            for(ElixirSuite__Master_Object__c child : m.Master_Objects__r){
                 child.ElixirSuite__TAB_Component_Attributes__c = JSON.serialize(child.ElixirSuite__TAB_Component_Attributes__c);
            }
        }*/
        obj.allObjectsToDisplayOnTimeline = allObjectsToDisplayOnTimeline;
        return obj;
    }
    public class DynamicTabStructureWrapper {
        @AuraEnabled public List<Master_Object__c> allObjectsToDisplayOnTimeline; 
    }
     
    
    public class Sorted_List_Wrapper_For_Match{
        
        @AuraEnabled public String regEmail;
        @AuraEnabled public String code;
        
        public Sorted_List_Wrapper_For_Match(String regEmails , String codes){
            this.regEmail = regEmails ;
            this.code = codes ;
        }
    }
    @AuraEnabled
    public static boolean checkCareEpisodePrompt(string patientId){   
        list<ElixirSuite__Visits__c> listCareEpisode=[select id,ElixirSuite__Account__c,ElixirSuite__Status__c from ElixirSuite__Visits__c
                                                      Where ElixirSuite__Account__c=:patientId WITH SECURITY_ENFORCED];
        boolean checkAllStatus=true;
        Elixir_Custom_Setting__c mcs = Elixir_Custom_Setting__c.getOrgDefaults();
        
        for(ElixirSuite__Visits__c exVar:listCareEpisode){
            if(exVar.ElixirSuite__Status__c=='Active'){
               checkAllStatus=false;  
            }
        }
        if(checkAllStatus && mcs.ElixirSuite__CareEpisode__c){
            return true;
        }else{
            return false;
        }
    }
}
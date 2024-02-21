public with sharing class ElixirOEM_NewReferralHelper {
   
    public static Map<String,List<String>> mapOfColumnAndFields = mapOfApiAndFields();
  
    @AuraEnabled
    public static WrapperForNewScreen referralInitPayload(String accountId){
        WrapperForNewScreen toRet = new WrapperForNewScreen(); 
        toRet.patientICDs = fetchRelatedDiagnosis(accountId);
        toRet.patientProcedureLst = fetchRelatedProcedure(accountId);
        User[] usrLst = [SELECT ID,Name,Phone,Email FROM User WHERE ID =: Userinfo.getUserId() WITH SECURITY_ENFORCED];
        if(usrLst!=null && usrLst.size()>0){
            toret.loggedInUserDetail = usrLst[0]; 
        }
        return toRet;
    }
    
    @AuraEnabled
    public static WrapperForNewScreen getReferralLookupDetails(String accountId,String contactId , String userId){
        WrapperForNewScreen refRet = new WrapperForNewScreen();
        
        //Location =>  var action = component.get("c.fetchAccountProvider");  ElixirSuite__Provider__c
        refRet.accountProvider = fetchAccountProvider(accountId);
       
        //Referred To =>  var action = component.get("c.contactDetails");  ElixirSuite__Referred_To__c
        List<Contact> conList = contactDetails(contactId);
        refRet.referredToContact = conList;
        
        //Referred Out Organization =>   var action = component.get("c.accountDetails"); ElixirSuite__Referred_Out_Organization__c
        List<Account> accList =  accountDetails(accountId);
        refRet.referredOutOrganization = accList;
            
            
        
        //Care Team Member =>    var action = component.get("c.userDetails"); ElixirSuite__User__c
        refRet.careTeamMember = userDetails(userId);
           
        refRet.patientICDs = fetchRelatedDiagnosis(accountId);
        refRet.patientProcedureLst = fetchRelatedProcedure(accountId);
        User[] usrLst = [SELECT ID,Name,Phone,Email FROM User WHERE ID =: Userinfo.getUserId() WITH SECURITY_ENFORCED];
        if(usrLst!=null && usrLst.size()>0){
            refRet.loggedInUserDetail = usrLst[0]; 
        }
        return refRet;
    }
    
    public class WrapperForNewScreen{
        @AuraEnabled public ElixirSuite__Provider__c[] accountProvider;
        @AuraEnabled public ElixirSuite__VOB__c[] patientVOBDetails;
        @AuraEnabled public Account[] patientInfo;
        @AuraEnabled public ElixirSuite__ICD_Codes__c[] patientICDs;
        @AuraEnabled public ElixirSuite__Procedure__c[] patientProcedureLst;
        @AuraEnabled public ElixirSuite__Medical_Examination__c[] vitalData;
        @AuraEnabled public ElixirSuite__Medical_Examination__c[] allergyData;
        @AuraEnabled public ElixirSuite__Dataset1__c[] patientProblems; 
        @AuraEnabled public ElixirSuite__Prescription_Order__c[] patientMedicationOrder; 
        @AuraEnabled public List<ContentDocument> lstToReturn;
        @AuraEnabled public User loggedInUserDetail;
        //new added
        @AuraEnabled public Account[] referredOutOrganization;
        @AuraEnabled public Contact[] referredToContact;
        @AuraEnabled public User[] careTeamMember;
        
    }
    @AuraEnabled
    public static WrapperForNewScreen referralInfoInitPayload(String accountId){
        WrapperForNewScreen toRet = new WrapperForNewScreen();
        toRet.patientInfo = patientDetails(accountId);
        toRet.patientVOBDetails = patientVOBDetails(accountId);
        toRet.lstToReturn = getFiles(accountId);
        toRet.patientProcedureLst = fetchRelatedProcedure(accountId);
        toRet.vitalData = fetchVitalSigns(accountId);
        toRet.allergyData = fetchAllergy(accountId);
        toRet.patientICDs = fetchRelatedDiagnosis(accountId);
        toRet.patientProblems = fetchRelatedProblems(accountId);
        toRet.patientMedicationOrder = fetchRelatedMedication(accountId);
        return toRet;
    } 
    
    public static  ElixirSuite__Prescription_Order__c[] fetchRelatedMedication(String accountId){
       // Id devRecordTypeId_Medication = Schema.SObjectType.ElixirSuite__Prescription_Order__c.getRecordTypeInfosByDeveloperName().get('Medication').getRecordTypeId();
        return [SELECT ID,ElixirSuite__Drug_Name__c,ElixirSuite__Number_of_Times_Days_Weeks__c,ElixirSuite__Route__c,ElixirSuite__Reason_new__c,ElixirSuite__Prescription_Order__c FROM ElixirSuite__Prescription_Order__c 
                WHERE ElixirSuite__Account__c = : accountId WITH SECURITY_ENFORCED];
        
    }
    public static  ElixirSuite__Medical_Examination__c[] fetchVitalSigns(String accountId){
        Id devRecordTypeIdVitalSign = Schema.SObjectType.ElixirSuite__Medical_Examination__c.getRecordTypeInfosByDeveloperName().get('Vital_Sign').getRecordTypeId();           
        return [SELECT ID,Name,CreatedDate FROM ElixirSuite__Medical_Examination__c 
                WHERE ElixirSuite__Account__c = : accountId AND RecordTypeId =:devRecordTypeIdVitalSign WITH SECURITY_ENFORCED];
    }
    public static  ElixirSuite__Medical_Examination__c[] fetchAllergy(String accountId){
        Id devRecordTypeIdAllergy = Schema.SObjectType.ElixirSuite__Medical_Examination__c.getRecordTypeInfosByDeveloperName().get('Allergy').getRecordTypeId(); 
        return [SELECT ID,Name,CreatedDate FROM ElixirSuite__Medical_Examination__c 
                WHERE ElixirSuite__Account__c = : accountId AND RecordTypeId =:devRecordTypeIdAllergy WITH SECURITY_ENFORCED];
    }
    //   vitals, diagnosis codes, allergies, procedure codes, problems and medications
    public static List<ContentDocument> getFiles(string recordId){ 
        Set<Id> recordIds=new Set<Id>{recordId};
            Set<Id> documentIds = new Set<Id>(); 
        List<ContentDocument> lstToReturn = new List<ContentDocument>();
        List<ContentDocumentLink> cdl=[SELECT id,LinkedEntityId,ContentDocumentId FROM ContentDocumentLink
                                       WHERE LinkedEntityId IN:recordIds WITH SECURITY_ENFORCED];  
        for(ContentDocumentLink cdLink:cdl){  
            documentIds.add(cdLink.ContentDocumentId);  
        }  
        lstToReturn= [SELECT Id,Title,FileType,CreatedDate FROM ContentDocument 
                      WHERE id IN: documentIds WITH SECURITY_ENFORCED
                      ORDER BY LastModifiedDate DESC ];
        return lstToReturn;  
    } 
    public class EntityDataWrapper{
        @AuraEnabled public sObject[] dataToRet;
        @AuraEnabled public Elixir_NewAccountAssociatedFormsApex.FormWrapper[] formLst;
    }
    
    public static  Map<String,List<String>> mapOfApiAndFields(){
        return new Map<String,List<String>>{'Vitals' => new List<String>{'ElixirSuite__Temperature__c', 'ElixirSuite__Pulse__c', 'ElixirSuite__Blood_Pressure_Diasystolic__c,ElixirSuite__Blood_Pressure_Systolic__c', 'ElixirSuite__BMI__c'},
            'Allergies' => new List<String>{'ElixirSuite__Allergy_Name__c' , 'ElixirSuite__Reaction__c', 'ElixirSuite__Severity__c','ElixirSuite__Note__c'},
                'Diagnosis Codes' => new List<String>{'ElixirSuite__Diagnosis_Code_and_Name__c' , 'ElixirSuite__Code_Description1__c', 'ElixirSuite__Version__c'},
                    'Procedure Codes' => new List<String>{ 'ElixirSuite__Code_Description__c','ElixirSuite__Code_Category__c'},
                        'Problems' =>new List<String>{'ElixirSuite__SNOMED_CT_Code__c','ElixirSuite__Problem_Type__c','ElixirSuite__Date_Onset__c'},
                            'Medications' =>new List<String>{'ElixirSuite__Drug_Name__c','ElixirSuite__Reason_new__c','ElixirSuite__Route_New__c','ElixirSuite__Number_of_Times_Days_Weeks__c'},
                                'Lab Results' =>new List<String>{'ElixirSuite__Medical_Test__c','ElixirSuite__Status__c'}};
                                }
    @AuraEnabled
    public static EntityDataWrapper fetchEntityData(String enitity,String accountId,String objLabel){
        EntityDataWrapper toRet = new EntityDataWrapper();
        String objName = '';
        String recType = '';
        String[] fieldsArr  = mapOfColumnAndFields.get(objLabel);
        String fields = '';
        String filterField = '';
        String status = '';
        status = 'Active';
        if(enitity != 'Notes'){
            fields = String.join( fieldsArr, ',' );    
        }
          
        if(enitity.contains(';')){
            String[] arr = enitity.split(';'); 
            objName = arr[0];
            recType = arr[1];
            Id devRecordTypeId;
           
            if(objName == 'ElixirSuite__Medical_Examination__c'){
                filterField = 'ElixirSuite__Care_Episode__r.ElixirSuite__Status__c';
                devRecordTypeId = Schema.SObjectType.ElixirSuite__Medical_Examination__c.getRecordTypeInfosByDeveloperName().get(recType).getRecordTypeId(); 
            }
            else if(objName == 'ElixirSuite__UA_Sample_Details__c'){
                filterField = 'ElixirSuite__Care_Episode__r.ElixirSuite__Status__c';
                devRecordTypeId = Schema.SObjectType.ElixirSuite__UA_Sample_Details__c.getRecordTypeInfosByDeveloperName().get(recType).getRecordTypeId();  
            }
           
           String query = 'SELECT ID,Name,CreatedDate,'+ String.escapeSingleQuotes(fields) +' FROM '+String.escapeSingleQuotes(objName);
            query+=' WHERE RecordTypeId=:devRecordTypeId'+' AND ElixirSuite__Account__c=:accountId';
           query += ' AND ' + String.escapeSingleQuotes(filterField) + '=: status';
           String finalQuery = String.escapeSingleQuotes(query);
            toRet.dataToRet= Database.query(FinalQuery);
        } 
        else {
            objName = enitity;
            if(enitity == 'ElixirSuite__Diagnosis_Code__c'){
                toRet.dataToRet =  fetchRelatedDiagnosis(accountId);
            }
            else if(enitity == 'Notes'){
                Elixir_NewAccountAssociatedFormsApex.FormWrapper[] formFinalList = new List<Elixir_NewAccountAssociatedFormsApex.FormWrapper>();
                Set<String> formUniqueIdSet = new Set<String>();
                Set<String> finalFormUniqueIdSet = new Set<String>();
                Elixir_NewAccountAssociatedFormsApex.FormWrapper[] formList = Elixir_NewAccountAssociatedFormsApex.bringData(accountId, '', 'Assessment','',new List<String>());
                for(Elixir_NewAccountAssociatedFormsApex.FormWrapper form : formList){
                    formUniqueIdSet.add(form.formId);
                }
                List<Form_Value__c> formValueLst = [SELECT Id,ElixirSuite__Form_Id__c,ElixirSuite__Care_Episode__r.ElixirSuite__Status__c FROM ElixirSuite__Form_Value__c WHERE ElixirSuite__Form_Id__c IN:formUniqueIdSet AND ElixirSuite__Care_Episode__r.ElixirSuite__Status__c = 'Active' AND Account__c=:accountId WITH SECURITY_ENFORCED];
                for(Form_Value__c fv : formValueLst){
                    finalFormUniqueIdSet.add(fv.ElixirSuite__Form_Id__c);
                }
                for(Elixir_NewAccountAssociatedFormsApex.FormWrapper form : formList){
                    for(String formUniqueId : finalFormUniqueIdSet){
                        if(form.formId == formUniqueId){
                            formFinalList.add(form);
                        }
                    }
                }
                toRet.formLst = formFinalList;
            }
            else if(enitity == 'ElixirSuite__Prescription_Order__c') {
                Id prescriptionRecordTypeId;
                prescriptionRecordTypeId = Schema.SObjectType.ElixirSuite__Prescription_Order__c.getRecordTypeInfosByDeveloperName().get('Medication').getRecordTypeId();
                String query = 'SELECT ID,Name,CreatedDate,'+fields +' FROM '+objName+' WHERE ElixirSuite__Account__c=:accountId and RecordTypeId=:prescriptionRecordTypeId and ElixirSuite__Drug_Name__c!=null and ElixirSuite__Prescription_Order__c!=null AND ElixirSuite__Care_Episode__r.ElixirSuite__Status__c =:status';                 
                String finalQuery = String.escapeSingleQuotes(query);
            toRet.dataToRet= Database.query(FinalQuery);
            }else if(enitity == 'ElixirSuite__Procedure__c'){
                
                String query = 'SELECT ID,Name,CreatedDate,'+fields +' FROM '+objName+' WHERE ElixirSuite__Account__c=:accountId AND ElixirSuite__Visits__r.ElixirSuite__Status__c =:status';
                
                String finalQuery = String.escapeSingleQuotes(query);
                toRet.dataToRet= Database.query(FinalQuery);
                
            }else if(enitity == 'ElixirSuite__Dataset1__c'){
                String query = 'SELECT ID,Name,CreatedDate,'+fields +' FROM '+objName+' WHERE ElixirSuite__Account__c=:accountId AND ElixirSuite__Care_Episode__r.ElixirSuite__Status__c =:status';
                String finalQuery = String.escapeSingleQuotes(query);
                toRet.dataToRet= Database.query(FinalQuery);
            }
            else {
               String query = 'SELECT ID,Name,CreatedDate,'+fields +' FROM '+objName+' WHERE ElixirSuite__Account__c=:accountId';
                 String finalQuery = String.escapeSingleQuotes(query);
            toRet.dataToRet= Database.query(FinalQuery);
               // toRet.dataToRet= Database.query(query);
            }
        }
        return toRet ;
    }
    public static  ElixirSuite__Dataset1__c[] fetchRelatedProblems(String accountId){
        return [SELECT ID,Name,CreatedDate FROM ElixirSuite__Dataset1__c WHERE ElixirSuite__Account__c = : accountId WITH SECURITY_ENFORCED];
    }
    public static  ElixirSuite__Procedure__c[] fetchRelatedProcedure(String accountId){
        return [SELECT ID,Name,ElixirSuite__Code_Description__c,ElixirSuite__Code_Category__c,Visits__r.Status__c FROM ElixirSuite__Procedure__c 
                WHERE ElixirSuite__Account__c = : accountId AND Visits__r.Status__c = 'Active' WITH SECURITY_ENFORCED];
    }
    public static  ElixirSuite__ICD_Codes__c[] fetchRelatedDiagnosis(String accountId){
        Map<ID, ElixirSuite__Dataset1__c> accountProblemMap = new Map<ID, ElixirSuite__Dataset1__c>([SELECT ID FROM ElixirSuite__Dataset1__c WHERE ElixirSuite__Account__c = : accountId with security_enforced]);
        ElixirSuite__Diagnosis_Code__c[] probelmJunctionLst = [SELECT ID,ElixirSuite__Diagnosis_Code__c FROM ElixirSuite__Diagnosis_Code__c 
                                                               WHERE ElixirSuite__Problem__c IN : accountProblemMap.keySet() AND ElixirSuite__Care_Episode__r.ElixirSuite__Status__c = 'Active' WITH SECURITY_ENFORCED];
        Set<Id> daignosisIdSet = new Set<Id>();
        for(ElixirSuite__Diagnosis_Code__c sObj : probelmJunctionLst){
            daignosisIdSet.add(sObj.ElixirSuite__Diagnosis_Code__c);
        }
        return [SELECT ID,Name,ElixirSuite__Code_Description1__c,ElixirSuite__Diagnosis_Code_and_Name__c,ElixirSuite__Version__c,CreatedDate FROM ElixirSuite__ICD_Codes__c
                WHERE ID IN : daignosisIdSet WITH SECURITY_ENFORCED];
        
    }
    @AuraEnabled
    public static  ElixirSuite__Provider__c[] fetchAccountProvider(String accountId){
        return providerAcctQuery(accountId);
    }
    @AuraEnabled 
    public static  ElixirSuite__Provider__c[] providerList(String searchKeyWord,String accountId){
        String searchKey = '%' + searchKeyWord + '%';               
        return providerQuery(searchKeyWord,accountId,searchKey);
    }
    @AuraEnabled 
    public static  Contact[] contactList(String searchKeyWord,String accountId){
        return contactQuery('%' + searchKeyWord + '%',accountId);
    }
    @AuraEnabled 
    public static  Contact[] contactListWithoutAccount(String searchKeyWord){
        String searchKey = '%' + searchKeyWord + '%';   
        return [SELECT ID,Name,email,Phone,AccountId,Account.Name FROM Contact  where Account.RecordType.name = 'Referral Partner Account' and Name 
                LIKE: searchKey WITH SECURITY_ENFORCED]; 
    }
    @AuraEnabled 
    public static  Account[] accountList(String searchKeyWord){
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Referral_Partner_Account').getRecordTypeId(); 
        return accountQuery(devRecordTypeId,'%' + searchKeyWord + '%');
    }
     
    @AuraEnabled 
    public static  User[] userList(String searchKeyWord){
        String searchKey = '%' + searchKeyWord + '%'; 
        return userQuery(searchKey);
    }
    @AuraEnabled 
    public static  User[] userDetails(String userId){
        return [SELECT ID,Name,Phone,Email FROM USER WHERE ID = :userId WITH SECURITY_ENFORCED];
    }
    @AuraEnabled 
    public static  Account[] accountDetails(String accountId){
        return [SELECT ID,Name,ElixirSuite__Email_Id__c,Phone FROM Account where ID = : accountId WITH SECURITY_ENFORCED];
    }
    @AuraEnabled 
    public static  Contact[] contactDetails(String contactId){
        return [SELECT ID,Name,email,Phone,AccountId,Account.Name FROM Contact where Id = : contactId WITH SECURITY_ENFORCED];//with security_enforced
    }
    public static Account[] patientDetails(String accountId){
        return [SELECT ID,Name,ElixirSuite__DOB__c,ElixirSuite__Gender__c,Phone,ElixirSuite__Email_Id__c,
                ElixirSuite__SSN__c FROM Account where Id = : accountId
                WITH SECURITY_ENFORCED];
    } 
    public static ElixirSuite__VOB__c[] patientVOBDetails(String accountId){
        return [SELECT ID,Name,ElixirSuite__Insurance_Provider__c,ElixirSuite__Insurance_Provider__r.Name,ElixirSuite__Subscriber_Name__c,ElixirSuite__Insurance_Policy_ID__c,ElixirSuite__Insurance_Company_Phone__c,
                ElixirSuite__Group_Number__c FROM ElixirSuite__VOB__c where ElixirSuite__Account__c = : accountId
                WITH SECURITY_ENFORCED];
    } 
    public static User[] userQuery(String searchKey){
        return [SELECT ID,Name FROM User where Name 
                LIKE: searchKey 
                WITH SECURITY_ENFORCED];
    }
    public static Contact[] contactQuery(String searchKey,String accountId){
        return [SELECT ID,Name FROM Contact where Name 
                LIKE: searchKey AND AccountId = : accountId
                WITH SECURITY_ENFORCED];
    }
    public static ElixirSuite__Provider__c[] providerQuery(String searchKeyWord,String accountId,String searchKey){
        return [SELECT ID,Name FROM ElixirSuite__Provider__c where Name 
                LIKE: searchKey AND ElixirSuite__Account__c = :accountId
                WITH SECURITY_ENFORCED];
    }
    public static ElixirSuite__Provider__c[] providerAcctQuery(String accountId){
        return [SELECT ID,Name FROM ElixirSuite__Provider__c where ElixirSuite__Account__c = :accountId 
                WITH SECURITY_ENFORCED order by createdDate desc limit 1];
    }
    public static Account[] accountQuery(String recTypeId,String searchKey){
        return [SELECT ID,Name,ElixirSuite__Email_Id__c,Phone FROM Account where Name 
                LIKE: searchKey AND RecordTypeId = :recTypeId
                WITH SECURITY_ENFORCED];
    }
     @AuraEnabled 
     public static List<ContentDocument> handlingAfterUpload(Id accountId){
         
      
        try{
          
            if(accountId!=null){
                return  getFiles(accountId);
            }
            return null;
        }
        catch(Exception e)
        {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
}
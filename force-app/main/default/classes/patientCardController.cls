public with sharing class patientCardController {
    @AuraEnabled
    public static  Boolean  revertPatientDeceased(Id accountId){  
        Boolean flag = true;
        List<Account> lstAcct = [SELECT ID,ElixirSuite__Deceased_Date__c,ElixirSuite__Deceased__c,Preliminary_Cause_of_death__c FROM Account WHERE ID = :accountId with security_enforced];
        if(lstAcct!=null && lstAcct.size()>0){
            if(lstAcct[0].ElixirSuite__Deceased__c == false){
                flag = true;
            }
            else {
                flag = false;
                DeceasedGlobalStopRecursion.run = false;
                lstAcct[0].ElixirSuite__Deceased_Date__c = null;
                lstAcct[0].Preliminary_Cause_of_death__c = null;
                lstAcct[0].ElixirSuite__Deceased__c = false; 
                if(Schema.sObjectType.Account.isUpdateable()){
                    //update lstAcct;
                    DMLManager.updateAsUser(lstAcct);
                }
                /***UPDATE ALL RELATED OBJECT'S DECEASED CB***/
                Set<Id> oppId  = updateAllOpportunity(new Set<Id >{accountId}); // UPDATE OPPORTUNITY AND GET OPP ID IN RETURN FOR PRE ASSES
                updateAllPreAsses(oppId); // UPDATE PREASSES
                updateAllVOB(new Set<Id >{accountId},oppId);
                updateAllContact(new Set<Id >{accountId});
                updateAllAluminiCare(new Set<Id >{accountId},oppId);
                
            }
            
        }
        
        return flag;
    }
    public static Set<Id> updateAllOpportunity(Set<Id> acctId ){
        Map<Id,Opportunity> allRelatedopp = new Map<Id,Opportunity>([SELECT ID,ElixirSuite__Deceased__c FROM Opportunity WHERE AccountID IN : acctId]);
        Opportunity[] toUpdtopp = new List<Opportunity>();
        for(Opportunity oppObj : allRelatedopp.values()){
            oppObj.ElixirSuite__Deceased__c = false;
            toUpdtopp.add(oppObj);
        }
        if(Schema.sObjectType.Opportunity.isUpdateable()){
            // update toUpdtopp;
            DMLManager.updateAsUser(toUpdtopp);        
        }
        return allRelatedopp.keySet();
    }
    public static void updateAllPreAsses(Set<Id> oppId ){
        ElixirSuite__Pre_assessment__c[] allRelatedPreAss = [SELECT ID,ElixirSuite__Deceased__c FROM ElixirSuite__Pre_assessment__c WHERE 
                                                             ElixirSuite__Opportunity__c IN : oppId WITH SECURITY_ENFORCED]; 
        for(ElixirSuite__Pre_assessment__c preAssobj : allRelatedPreAss){
            preAssobj.ElixirSuite__Deceased__c = false;
        }
        if(Schema.sObjectType.ElixirSuite__Pre_assessment__c.isUpdateable()){
            // update allRelatedPreAss;
            DMLManager.updateAsUser(allRelatedPreAss);
        }
    }
    public static void updateAllVOB(Set<Id> acctId ,Set<Id> oppId ){
        ElixirSuite__VOB__c[] allRelatedVOBToAcc = [SELECT ID,ElixirSuite__Deceased__c FROM ElixirSuite__VOB__c WHERE 
                                                    ElixirSuite__Account__c IN : acctId WITH SECURITY_ENFORCED]; 
        ElixirSuite__VOB__c[] allRelatedVOBToOpp = [SELECT ID,ElixirSuite__Deceased__c FROM ElixirSuite__VOB__c WHERE 
                                                    ElixirSuite__Opportunity__c IN : acctId WITH SECURITY_ENFORCED];
        ElixirSuite__VOB__c[] toUpdtLst = new List<ElixirSuite__VOB__c>();
        allRelatedVOBToAcc.addAll(allRelatedVOBToopp);
        for(ElixirSuite__VOB__c sObj : allRelatedVOBToAcc){
            if(sObj.ElixirSuite__Deceased__c){
                sObj.ElixirSuite__Deceased__c = false;
                toUpdtLst.add(sObj);
            }
        }
        if(Schema.sObjectType.ElixirSuite__VOB__c.isUpdateable()){
            // update toUpdtLst;
            DMLManager.updateAsUser(toUpdtLst);
        }
    }
    public static void updateAllContact(Set<Id> acctId ){
        System.debug('cont update started'+acctId);
        Contact[] allRelatedCont = [SELECT ID,ElixirSuite__Deceased__c FROM Contact WHERE AccountID IN : acctId WITH SECURITY_ENFORCED];
        for(Contact ct : allRelatedCont){
            ct.ElixirSuite__Deceased__c = false;
        }
        if(Schema.sObjectType.Contact.isUpdateable()){
            // update allRelatedCont;
            DMLManager.updateAsUser(allRelatedCont);
            System.debug('cont update done');
        }
    }
    public static void updateAllAluminiCare(Set<Id> acctId ,Set<Id> oppId ){
        ElixirSuite__Alumni_Care_Services__c[] allRelatedAluminiToAcc = [SELECT ID,ElixirSuite__Deceased__c FROM ElixirSuite__Alumni_Care_Services__c WHERE 
                                                                         ElixirSuite__Patient_Account__c  IN : acctId WITH SECURITY_ENFORCED]; // RELATED TO ACC
        ElixirSuite__Alumni_Care_Services__c[] allRelatedAluminiToOpp = [SELECT ID,ElixirSuite__Deceased__c FROM ElixirSuite__Alumni_Care_Services__c WHERE 
                                                                         ElixirSuite__Patient_Name__c  IN : acctId WITH SECURITY_ENFORCED]; // RELATED TO OPP
        ElixirSuite__Alumni_Care_Services__c[] toUpdtLst = new List<ElixirSuite__Alumni_Care_Services__c>();
        allRelatedAluminiToAcc.addAll(allRelatedAluminiToOpp);
        for(ElixirSuite__Alumni_Care_Services__c sObj : allRelatedAluminiToAcc){
            if(sObj.ElixirSuite__Deceased__c){
                sObj.ElixirSuite__Deceased__c = false;
                toUpdtLst.add(sObj);
            }
        }
        if(Schema.sObjectType.ElixirSuite__Alumni_Care_Services__c.isUpdateable()){
            // update toUpdtLst;
            DMLManager.updateAsUser(toUpdtLst);
        }
    }
    
    
    @AuraEnabled
    public static  Account patientCardMethod(Id accountId){  
        system.debug('jk' + accountId);
        Account patient = new Account();
        if(schema.sobjecttype.Account.isAccessible()
           && schema.sobjecttype.Account.fields.Name.isAccessible())
        {
            patient=[select Name,Age__c,ElixirSuite__Gender__c,ElixirSuite__MRN_Number_New__c,DOB__c,Admit_Date__c,Discharge_Date__c,ElixirSuite__Deceased__c,ElixirSuite__Profile_Picture__c from Account 
                     where Id=:accountId limit 1];
            //patient=[select Name,Age__c,DOB__c,Bed__r.Name,HealthCloudGA__IndividualID__c,Bed__r.Formula_Name__c,Treatment_Center__r.Treatment_center_Name__c,Treatment_Center__r.Name,Admit_Date__c,Discharge_Date__c from Account where Id=:accountId limit 1];
        }
        
        return patient;       
    }
    @AuraEnabled
    public static user getUserInfo() {
        String userId = UserInfo.getUserId(); // current user
        String preQuery= 'SELECT ID, FirstName, LastName, Name, Title, Profile.Name,  Email,ContactId,Contact.AccountId,AccountId';
        return Database.query(Elixir_Utility.fetchUserQuery(preQuery) + ' From User WHERE ID =: userId LIMIT 1');
    }
    @AuraEnabled
    public static void handlingAfterUpload(Id accountId){
        Integer var = 0;
        var++;
        
        var ++;
        ContentVersion cv = new ContentVersion();
        try{
            User usr = [SELECT id, ContactId FROM User where Id = : Userinfo.getUserId() WITH SECURITY_ENFORCED];
            if(schema.sobjecttype.ContentVersion.isAccessible()
               && schema.sobjecttype.ContentVersion.fields.FIRSTPUBLISHLOCATIONID.isAccessible()
               && schema.sobjecttype.ContentVersion.fields.Title.isAccessible())
            {
                if(String.isNotBlank(usr.ContactId)){
                    cv = [select id,Title,ContentDocumentId from ContentVersion WHERE FIRSTPUBLISHLOCATIONID=:userInfo.getUserId() WITH SECURITY_ENFORCED order by createdDate desc limit 1];
                }
                else{
                    cv = [select id,Title,ContentDocumentId from ContentVersion WHERE FIRSTPUBLISHLOCATIONID=:accountId WITH SECURITY_ENFORCED order by createdDate desc limit 1];
                }
                if(cv.Id!=null){
                    cv.Title=cv.Title+'_profilePic';
                }
                account acc = new account();	
                acc =[select id,Profile_Picture__c from account where id =:accountId WITH SECURITY_ENFORCED];	
                acc.Profile_Picture__c = cv.id;
                if (Schema.sObjectType.account.fields.Profile_Picture__c.isUpdateable()) {
                    //update acc;
                    DMLManager.updateAsUser(acc);
                }
            }
            if (Schema.sObjectType.ContentVersion.fields.Title.isUpdateable())
                // update cv;
                DMLManager.updateAsUser(cv);
            
            Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
            
            List<ContentDocumentLink> existingLinks = [SELECT Id FROM ContentDocumentLink WHERE ContentDocumentId = :conDocId AND LinkedEntityId = :accountId LIMIT 1];
            if (existingLinks.size() > 0) {
                ContentDocumentLink cd = existingLinks[0];
                cd.ShareType = 'I';
                cd.Visibility = 'AllUsers';
               // update cd;
                DMLManager.updateAsUser(cd);
            } else {
                ContentDocumentLink cd = new ContentDocumentLink();
                cd.LinkedEntityId = accountId;
                cd.ContentDocumentId = conDocId;
                cd.ShareType = 'I';
                cd.Visibility = 'AllUsers';
                // insert cd;
                DMLManager.insertAsUser(cd);
                
            }
        }
        catch(Exception e)
        {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static License_Class LicensBasdPermission()
    {
        Id currentUid = UserInfo.getUserId();
        String AvailLicense = [Select Id,ElixirSuite__License_Type__c,Username,Name,ContactId,Contact.AccountId from User where Id =:currentUid].ElixirSuite__License_Type__c;
        List<String> lst_availLicense = new List<String>();
        lst_availLicense = AvailLicense.split(';');
        License_Class lCls = new License_Class();
        for(String str : lst_availLicense)
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
            if(str == 'Elixir Patient Portal')
            {
                lCls.isPatientPortal = True;
                continue;
            }
        }
        return lCls;
    }
    public class License_Class
    {
        @AuraEnabled public Boolean isEhr = false;
        @AuraEnabled public Boolean isRcm  = false;
        @AuraEnabled public Boolean isContactCenter  = false;
        @AuraEnabled public Boolean isPatientPortal  = false;
    }
    
    
    /*@AuraEnabled
public static boolean checkEMRLicense(){
return UpdateCustomSetting.checkLicenseKey();
}*/
    @AuraEnabled
    public static Account getTileConfigFieldsOrder(Id accountId){
        System.debug('*account id '+accountId);
        Account patient = new Account();
        try {
            if(schema.sobjecttype.Account.isAccessible()
               && schema.sobjecttype.Account.fields.Name.isAccessible())
            {
                List<ElixirSuite__Master_Object__c> masterRec = [SELECT ElixirSuite__Field_Label__c, 
                                                                 ElixirSuite__Field_Api__c, 
                                                                 ElixirSuite__Patient_Tile_Entity__c, 
                                                                 ElixirSuite__Patient_Tile_Order__c 
                                                                 FROM ElixirSuite__Master_Object__c 
                                                                 WHERE ElixirSuite__Patient_Tile_Entity__c ='Account' 
                                                                 AND RecordType.DeveloperName='Patient_Info_Card_Configuration' WITH SECURITY_ENFORCED
                                                                 ORDER BY ElixirSuite__Patient_Tile_Order__c];
                
               List<String> masterRecFields = new List<String>{'ElixirSuite__MRN_Number_New__c', 'ElixirSuite__Gender__c','ElixirSuite__Age__c'};
           
                    String finalQuery = '';
           /*     for(ElixirSuite__Master_Object__c itr : masterRec){       
                    String fieldapiname = itr.ElixirSuite__Field_Api__c;
                    if(!masterRecFields.contains(fieldapiname)){
                        masterRecFields.add(fieldapiname);
                    }
                }*/
                Map<String,String> apiAndLabelMap = new Map<String,String>();
                Map<String,Integer> apiOrderMap = new Map<String,Integer>();
                String[] queryFields = new List<String>();
                for(ElixirSuite__Master_Object__c sObj : masterRec){
                    apiAndLabelMap.put(sObj.ElixirSuite__Field_Api__c,sObj.ElixirSuite__Field_Label__c);
                    queryFields.add(sObj.ElixirSuite__Field_Api__c);
                    apiOrderMap.put(sObj.ElixirSuite__Field_Label__c,Integer.valueOf(sObj.ElixirSuite__Patient_Tile_Order__c));
                    System.debug('order fields '+sObj.ElixirSuite__Field_Api__c);
                } 
                finalQuery = 'SELECT ' + String.join(queryFields,',') +' FROM Account where Id=:accountId limit 1' ;
                String sanitisedQuery = String.escapeSingleQuotes(finalQuery);
                patient = Database.query(sanitisedQuery);
                
            }
            return patient;
            
            
        } 
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        
    }
    
    @AuraEnabled
    public static Map<String,String> getlabelsforFields(){
        Map<String, String> fieldLabelMap = new Map<String, String>();
        try {
            if(schema.sobjecttype.Account.isAccessible()
               && schema.sobjecttype.Account.fields.Name.isAccessible())
            {
                List<ElixirSuite__Master_Object__c> masterRec = [select ElixirSuite__Field_Label__c, ElixirSuite__Field_Api__c, ElixirSuite__Patient_Tile_Entity__c, ElixirSuite__Patient_Tile_Order__c FROM ElixirSuite__Master_Object__c where ElixirSuite__Patient_Tile_Entity__c ='Account' and RecordType.DeveloperName='Patient_Info_Card_Configuration' WITH SECURITY_ENFORCED order by ElixirSuite__Patient_Tile_Order__c];
                for(ElixirSuite__Master_Object__c itr : masterRec){
                    //masterRecFields.add(itr.ElixirSuite__Field_Label__c);
                    
                    fieldLabelMap.put(String.valueof(itr.ElixirSuite__Field_Api__c), String.valueof(itr.ElixirSuite__Field_Label__c));
                    
                }
                /* fieldLabelMap.put('Name','Name');
                 fieldLabelMap.put('ElixirSuite__MRN_Number_New__c','MRN #');
                fieldLabelMap.put('ElixirSuite__Gender__c','Gender');
                fieldLabelMap.put('ElixirSuite__Age__c','Age');
                fieldLabelMap.put('ElixirSuite__DOB__c','Birth Date');*/
            }
            
            System.debug('FiledLabelMap '+fieldLabelMap);
            return fieldLabelMap;
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        
    }
    
    public class PatientWrapper{
        @AuraEnabled public Account patient;
        @AuraEnabled public Account getTileConfigFieldsOrder;
        @AuraEnabled public Map<String,String> getlabelsforFields;
        
    }
    public class PatientWrapperNotifications{
        @AuraEnabled public list<ElixirSuite__UA_Sample_Details__c> UADetails;
        @AuraEnabled public list<ElixirSuite__Lab_Order__c> lo;
        @AuraEnabled public list<ElixirSuite__Form_Value__c> forms;
        @AuraEnabled public String baseURL;
        @AuraEnabled public list<ElixirSuite__Payment_Schedule__c> payments;
        
    }
    @AuraEnabled
    public static patientWrapper patientWrapperMethod(Id accountId){
        try {
            PatientWrapper pw = new PatientWrapper();
            pw.patient = patientCardMethod(accountId);
            pw.getTileConfigFieldsOrder =  getTileConfigFieldsOrder(accountId);
            pw.getlabelsforFields = getlabelsforFields();
            return pw;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static PatientWrapperNotifications fetchPortalNotifications(){ 
         try {
            PatientWrapperNotifications pwn = new PatientWrapperNotifications();
            pwn.UADetails = fetchDummyLabOrder();
            pwn.lo = fetchCHCLabOrder();
            pwn.forms = fetchPortalForms();
            pwn.baseURL = fetchbaseURl();
            pwn.payments = fetchPayments();
            return pwn;
         }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static String fetchbaseURl(){ 
        return String.valueOf(System.Url.getSalesforceBaseUrl().toExternalForm());
    }
    
    @AuraEnabled
    public static list<ElixirSuite__Form_Value__c> fetchPortalForms(){ 
        user currentUser = getUserInfo();
        list<ElixirSuite__Form_Value__c> lstofForms = new list<ElixirSuite__Form_Value__c>();
        if(currentUser != null){
            Id accId = currentUser.AccountId;
            list<ElixirSuite__Form_Value__c> formlst = [SELECT Id,Name,ElixirSuite__Form_Name__c,ElixirSuite__Account__c,CreatedDate,ElixirSuite__Form_Portal_Status__c 
                                                        FROM ElixirSuite__Form_Value__c 
                                                        WHERE ElixirSuite__Account__c =: accId
                                                        AND ElixirSuite__Form_Portal_Status__c = 'New'
                                                        WITH SECURITY_ENFORCED
                                                        ORDER BY CreatedDate DESC];
            
            for(ElixirSuite__Form_Value__c form : formlst){
                lstofForms.add(form);
            }
        }
        return lstofForms;
    }
    @AuraEnabled
    public static list<ElixirSuite__UA_Sample_Details__c> fetchDummyLabOrder(){
        List<ElixirSuite__TabPermissionBasedOnProfiles__c> tabCsList = [SELECT id,Name, ElixirSuite__LabOrder_Priority__c FROM ElixirSuite__TabPermissionBasedOnProfiles__c 
                                                                        where Name = 'TabPermissionBasedOnProfiles (Profile)' WITH SECURITY_ENFORCED limit 1];
        list<ElixirSuite__UA_Sample_Details__c> lstSampleDetails = new list<ElixirSuite__UA_Sample_Details__c>();
        if(tabCsList != null && !tabCsList.isEmpty()){
            If(tabCsList[0].ElixirSuite__LabOrder_Priority__c=='Dummy LabOrder'){
                user usr = getUserInfo();
                Set<String> UAIds = new Set<String>();
                Set<String> linkedIds = new Set<String>();
                
                if(usr != null){
                    Id accId = usr.AccountId;
                    list<ElixirSuite__UA_Sample_Details__c> UA = [SELECT Id,Name,ElixirSuite__Medical_Test__c,ElixirSuite__Account__c,CreatedDate FROM ElixirSuite__UA_Sample_Details__c WHERE ElixirSuite__Account__c =: accId WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC];
                    for(ElixirSuite__UA_Sample_Details__c detail : UA){
                        UAIds.add(detail.Id);
                    }
                    list<ContentDocumentLink> cdl = [select Id, LinkedEntity.Name, LinkedEntityId, SystemModstamp from ContentDocumentLink where LinkedEntityId IN : UAIds order by SystemModstamp desc];
                    for(ContentDocumentLink cd : cdl){
                        linkedIds.add(cd.LinkedEntityId);
                    }
                }
                if(linkedIds != null && !linkedIds.isEmpty()){
                    lstSampleDetails = [SELECT Id,Name,ElixirSuite__Medical_Test__c,ElixirSuite__Account__c,CreatedDate FROM ElixirSuite__UA_Sample_Details__c WHERE Id IN : linkedIds WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC];
                }
            }
        }
        return lstSampleDetails;
    }
    @AuraEnabled
    public static list<ElixirSuite__Lab_Order__c> fetchCHCLabOrder(){
        List<ElixirSuite__TabPermissionBasedOnProfiles__c> tabCsList = [SELECT id,Name, ElixirSuite__LabOrder_Priority__c FROM ElixirSuite__TabPermissionBasedOnProfiles__c 
                                                                        where Name = 'TabPermissionBasedOnProfiles (Profile)' WITH SECURITY_ENFORCED limit 1];
        list<ElixirSuite__Lab_Order__c> chcLo = new list<ElixirSuite__Lab_Order__c>();
        if(tabCsList != null && !tabCsList.isEmpty()){
            If(tabCsList[0].ElixirSuite__LabOrder_Priority__c=='CHC LabOrder') {
                user usr = getUserInfo();
                if(usr != null){
                    Id accId = usr.AccountId;
                    chcLo = [SELECT Id,Name,ElixirSuite__Test_Name__c,CreatedDate,ElixirSuite__Account_Id__c from ElixirSuite__Lab_Order__c WHERE ElixirSuite__Account_Id__c =: accId WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC];
                }
            }
        }
        return chcLo;
    }
    
    @AuraEnabled
    public static list<ElixirSuite__Payment_Schedule__c> fetchPayments(){ 
        Date overDue = Date.today();
        Date dueDate = Date.today().addDays(1);
        user currentUser = getUserInfo();
        list<ElixirSuite__Payment_Schedule__c> paymentList = new list<ElixirSuite__Payment_Schedule__c>();
        if(currentUser != null){
            Id accId = currentUser.AccountId;
            list<ElixirSuite__Payment_Schedule__c> payment = [SELECT id,ElixirSuite__Account__c,ElixirSuite__Due_Date__c,ElixirSuite__Installment_Amount__c,ElixirSuite__Payment_Status__c,CreatedDate,ElixirSuite__Pay_Frequency__c
                                                              FROM ElixirSuite__Payment_Schedule__c
                                                              WHERE ElixirSuite__Account__c =: accId AND ElixirSuite__Balance_Due1__c != 0 
                                                              AND ElixirSuite__Due_Date__c !=null AND ElixirSuite__Payment_Status__c!='Paid'
                                                              AND (ElixirSuite__Due_Date__c <= :overDue OR ElixirSuite__Due_Date__c =:dueDate)
                                                              WITH SECURITY_ENFORCED
                                                              ORDER BY ElixirSuite__Due_Date__c Asc];
            
            for(ElixirSuite__Payment_Schedule__c payments : payment){
                paymentList.add(payments);
            }
        }
        return paymentList;
    }
}
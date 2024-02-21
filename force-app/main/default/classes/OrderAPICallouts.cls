/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-14-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class OrderAPICallouts {
    
    @AuraEnabled(Cacheable=true)
    public static sObject getCredentials(){
        /*if(!Test.isRunningTest()){
            CHCCredentials__mdt getcrd;
             return [SELECT Id, Password__c, Number_of_Tests_at_a_time__c, Label, UserName__c, Facility_ObjId__c FROM CHCCredentials__mdt where label = 'MirketaChcCrdentials' WITH SECURITY_ENFORCED];
            
        }
        return null;*/
        /* return [SELECT Id, Password__c, Name, UserName__c, Integration_Key__c, ElixirSuite__Callout_Limit__c
                    FROM Integration_Credentials__c 
                    WHERE Name = 'MirketaChcCrdentials' 
                    WITH SECURITY_ENFORCED];*/
                    if(!Test.isRunningTest()){
                        String name='MirketaChcCrdentials';
                        String query='SELECT Id, Password__c, Name, UserName__c, Integration_Key__c, ElixirSuite__Callout_Limit__c FROM Integration_Credentials__c WHERE Name = \'' + name + '\' WITH SECURITY_ENFORCED';
                        List<sObject> credentialsList = Database.query(query);
            
                    if (credentialsList != null && !credentialsList.isEmpty()) {
                        return credentialsList[0];
                    }
                    }
                    return null;
                
    }
    
    @AuraEnabled
    public static List<VOB__c> getVOBList(String accountid){
        try {
            List<VOB__c> vobList = [SELECT Id,Name,RecordTypeId,Account__c,Date_Of_Birth__c,Gender__c,Insurance_Group_Number__c,Patient_Relationship_With_Insured__c,Insurance_Policy_ID__c,Insurance_Providers__c,Insurance__c,Insured_Address__c,Insured_City__c,Insured_First_Name__c,Insured_Last_Name__c,Insured_State__c,Insured_Zipcode__c FROM VOB__c where Account__c=:accountid WITH SECURITY_ENFORCED];
            return vobList;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static Account getAccountDetails(string accountid) {
        try{
            
            String person='';
            Account accDetail = [SELECT   Id, Name,First_Name__c,Last_name__c,Phone,SSN__c,age__c,DOB__c, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, Gender__c FROM Account where id=: accountid WITH SECURITY_ENFORCED limit 1 ];
            return accDetail;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static VOB__c  getVOBDetail(String accountid,String parentid)
    {
        try{
            VOB__c vobDetail = [SELECT Id, Name, RecordTypeId,Account__c, Date_Of_Birth__c,  Gender__c,Insurance_Group_Number__c,Patient_Relationship_With_Insured__c, Insurance_Provider_Sec__c,  Insurance_Policy_ID__c, ElixirSuite__Payer__r.ElixirSuite__Payer_Code__c, Insurance__c, Insured_Address__c, Insured_City__c, Insured_First_Name__c, Insured_Last_Name__c, Insured_State__c, Insured_Zipcode__c,InsPhone__c FROM VOB__c where account__c=:accountid AND Id=:parentid WITH SECURITY_ENFORCED limit 1];
            System.debug('vob Data '+vobDetail);
            return vobDetail;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static Payor__c getPayorDetail(){
        try {
            Payor__c getData =[SELECT Id, Address__c, Name, City__c, Payer_Code__c, PhoneNumber__c, State__c, Zip_Code__c FROM Payor__c WITH SECURITY_ENFORCED limit 1];
            return getData; 
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static AccountContactRelation getGuarantorDetailsPicklist(string accId ,string guarantorRecordId){
        try{
            Elixir_Custom_Setting__c val = Elixir_Custom_Setting__c.getOrgDefaults();
            String contactRecType = val.ElixirSuite__Practitioner_Contact_Recordtype__c;
            Id practitionerRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(contactRecType).getRecordTypeId();
            AccountContactRelation acr = [Select Id,tolabel(ElixirSuite__Relationship__c),Contact.FirstName,Contact.LastName,Contact.ElixirSuite__Gender__c,Contact.Phone,Contact.Birthdate FROM AccountContactRelation WHERE AccountId =:accId AND ContactId =:guarantorRecordId AND Contact.ElixirSuite__Type__c = 'Guarantor' AND Contact.RecordTypeId !=:practitionerRecTypeId WITH SECURITY_ENFORCED limit 1];
            return acr;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static list<Contact> getGuarantorList(string accId){
        try {
            Elixir_Custom_Setting__c val = Elixir_Custom_Setting__c.getOrgDefaults();
            String contactRecType = val.ElixirSuite__Practitioner_Contact_Recordtype__c;
            Id practitionerRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(contactRecType).getRecordTypeId();
            list<Contact> record =[select Id,Name, FirstName,LastName,ElixirSuite__Gender__c,Phone,Birthdate from Contact where AccountId =:accId AND ElixirSuite__Type__c = 'Guarantor' AND RecordTypeId !=:practitionerRecTypeId WITH SECURITY_ENFORCED];
            return record;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
   
    
    //Create Order in the CHC Database based on values selected in the UI Form
    @AuraEnabled
    public static List<String> addOrder (string ordertypevalue,string accountid,string billtype,string labId, string facilityId, string physiciasnName,string selectedEnteredBy,string selectedVerifiedBy,String physicianId,String enteredById,string verifiedById, list<string> tests, list<string> ICDs,string collectionDateTime,DateTime DateTimeCollection, String expectedDateTime,DateTime dateTimeExpected,string code,string policy,string groupvalue,String parentInsuranceID, string guarantorRecordId,String orderId){
        List<String>  placer_order_number ;
        List<ElixirSuite__Lab__c> lstLab = [SELECT Id,ElixirSuite__Lab_Id__c,ElixirSuite__Lab_Type__c FROM ElixirSuite__Lab__c WHERE ElixirSuite__Lab_Id__c =: labId WITH SECURITY_ENFORCED LIMIT 1];
        if(lstLab != null && !lstLab.isEmpty())
        {
           if(lstLab[0].ElixirSuite__Lab_Type__c == 'eLab'){
               Map<String, Object> args = new Map<String, Object>{
                'ordertypevalue'=>ordertypevalue,
                'accountid'=>accountid,
                'billtype'=>billtype,
                'labId'=>labId,
                'facilityId'=>facilityId,
                'physiciasnName'=>physiciasnName,
                'physicianId'=>physicianId,
                'selectedEnteredBy'=>selectedEnteredBy,
                'enteredById'=>enteredById,
                'selectedVerifiedBy'=>selectedVerifiedBy,
                'verifiedById'=>verifiedById,
                'tests'=>tests,
                'ICDs'=>ICDs,
                'collectionDateTime'=>collectionDateTime,
                'DateTimeCollection'=>DateTimeCollection,
                'expectedDateTime'=>expectedDateTime,
                'dateTimeExpected'=>dateTimeExpected,
                'code'=>code,
                'policy'=>policy,
                'groupvalue'=>groupvalue,
                'parentInsuranceID'=>parentInsuranceID,
                'guarantorRecordId'=>guarantorRecordId,
                'orderId'=>orderId
                }; 
                String virtualClassName = 'LabOrder_OrderAPI';
                List<Elixir_Pluggable_Classes__mdt> pluggableClass = new List<Elixir_Pluggable_Classes__mdt>();
                pluggableClass = [SELECT
                          DeveloperName,
                          Virtual_Class__c
                          FROM Elixir_Pluggable_Classes__mdt
                          WHERE DeveloperName='OrderAPICallouts_addOrder'
                          WITH SECURITY_ENFORCED];
        
                if(!pluggableClass.isEmpty()){
                    virtualClassName = pluggableClass[0].Virtual_Class__c;
                }
                Type t = Type.forName(virtualClassName);
                Callable createLabOrder = (Callable) t.newInstance();

                placer_order_number = (List<string>)createLabOrder.call('',args);
                //placer_order_number = createLabOrder.addOrder(ordertypevalue, accountid, billtype, labId,  facilityId, physiciasnName, tests, ICDs, collectionDateTime, DateTimeCollection, expectedDateTime, dateTimeExpected, code, policy, groupvalue, parentInsuranceID, guarantorRecordId);
                
            }
            else{
                //call InHouse class to do saving for manual lab order...
                placer_order_number =InHouseLabOrder.addInHouseLabOrder(ordertypevalue,accountid,billtype,labId,facilityId,physiciasnName,selectedEnteredBy,selectedVerifiedBy,physicianId,enteredById,verifiedById,tests,ICDs,collectionDateTime,DateTimeCollection,expectedDateTime,dateTimeExpected,code,policy,groupvalue,parentInsuranceID,guarantorRecordId,orderId);
            } 
        }
        
        return placer_order_number;  
    }
    @AuraEnabled 
    public static List<String> updateOrder(string ordertypevalue,string accountid,string billtype,string labId, string facilityId, string physiciasnName,string selectedEnteredBy,string selectedVerifiedBy,String physicianId,String enteredById,string verifiedById, list<string> tests, list<string> ICDs,string collectionDateTime,DateTime DateTimeCollection, String expectedDateTime,DateTime dateTimeExpected,string code,string policy,string groupvalue,String parentInsuranceID, string guarantorRecordId,string labOrderId,List<String> removedTests){
        List<ElixirSuite__Lab__c> lstLab = [SELECT Id,ElixirSuite__Lab_Id__c,ElixirSuite__Lab_Type__c FROM ElixirSuite__Lab__c WHERE ElixirSuite__Lab_Id__c =: labId WITH SECURITY_ENFORCED LIMIT 1];
       List<string> LabTestIds;
        if(lstLab != null && !lstLab.isEmpty())
        {
            if(lstLab[0].ElixirSuite__Lab_Type__c == 'eLab'){
                Map<String, Object> args = new Map<String, Object>{
                            'ordertypevalue'=>ordertypevalue,
                            'accountid'=>accountid,
                            'billtype'=>billtype,
                            'labId'=>labId,
                            'facilityId'=>facilityId,
                            'physicianId'=>physicianId,
                            'enteredById'=>enteredById,
                            'verifiedById'=>verifiedById,
                            'ICDs'=>ICDs,
                            'collectionDateTime'=>collectionDateTime,
                            'expectedDateTime'=>expectedDateTime,
                            'parentInsuranceID'=>parentInsuranceID,
                            'guarantorRecordId'=>guarantorRecordId,
                            'labOrderId'=>labOrderId,
                            'removedTests'=>removedTests
                            };

                String virtualClassName = 'LabOrder_OrderAPI_Update';
                List<Elixir_Pluggable_Classes__mdt> pluggableClass = new List<Elixir_Pluggable_Classes__mdt>();
                pluggableClass = [SELECT
                          DeveloperName,
                          Virtual_Class__c
                          FROM Elixir_Pluggable_Classes__mdt
                          WHERE DeveloperName='OrderAPICallouts_UpdateLabOrder'
                          WITH SECURITY_ENFORCED];
                if(!pluggableClass.isEmpty()){
                    virtualClassName = pluggableClass[0].Virtual_Class__c;
                }
                Type t = Type.forName(virtualClassName);
                Callable updateLabOrder = (Callable) t.newInstance();
                LabTestIds= (List<string>)updateLabOrder.call('',args);
            }
            else{
                //call InHouse class to do saving for manual lab order...
                LabTestIds=  InHouseLabOrder.updateInHouseLabOrder(ordertypevalue,accountid,billtype,labId,facilityId,physicianId,enteredById,verifiedById,ICDs,collectionDateTime,expectedDateTime,parentInsuranceID,guarantorRecordId,labOrderId,removedTests);
            }
        }  
        return LabTestIds;           
    }
    
    
    
    @AuraEnabled
    public static string dateTimeNow(){
        try{
            //string x = String.ValueofGmt(datetime.now());
            string x =  '' + datetime.now();
            System.debug('dateTimeNow :' + x);
            return x; 
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<lab__c> getLabs(){
        try{
            return [SELECT Id, lab_id__c, name , ElixirSuite__Lab_Type__c FROM lab__c where Is_Active__c=TRUE And ElixirSuite__Lab_Type__c IN ('Manual','elab')  WITH SECURITY_ENFORCED order by  name];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<facility__c> getFacilities(string labId){
        try{
            return [SELECT Id, Lab_ID__c, Facility_Id__c, name FROM facility__c where Lab_ID__c=:labId AND Is_Active__c=TRUE WITH SECURITY_ENFORCED order by name];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Contact> getPhysicians(){
        try{
            Elixir_Custom_Setting__c val = Elixir_Custom_Setting__c.getOrgDefaults();
            String contactRecType = val.ElixirSuite__Practitioner_Contact_Recordtype__c;
            Id practitionerRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(contactRecType).getRecordTypeId();
            return [SELECT Id, FirstName, LastName,Name FROM Contact where ElixirSuite__Is_Active__c=TRUE AND RecordTypeId=:practitionerRecTypeId WITH SECURITY_ENFORCED order by LastName];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Test__c> getTests(string labId){
        try{
            Id chcRecordTypeId = Schema.SObjectType.Test__c.getRecordTypeInfosByDeveloperName().get('CHC_Test').getRecordTypeId();
            return [SELECT Id, Test_Id__c, Test_Name__c, Test_Description__c, Lab_Id__c FROM Test__c where Lab_Id__c=:labId and IsPreferred__c = true and RecordTypeId = :chcRecordTypeId WITH SECURITY_ENFORCED order by Test_Name__c];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }   
    }

    @AuraEnabled(cacheable=true)
    public static List<Test__c> getInHouseTests(){
        try {
            Id manualRecordTypeId = Schema.SObjectType.Test__c.getRecordTypeInfosByDeveloperName().get('Manual_Test').getRecordTypeId();
            Id packageRecordTypeId = Schema.SObjectType.Test__c.getRecordTypeInfosByDeveloperName().get('Package').getRecordTypeId();
    
            return [SELECT Id, Test_Id__c,Test_Name__c,ElixirSuite__Test__c, CreatedDate FROM Test__c WHERE (RecordTypeId = :manualRecordTypeId OR RecordTypeId = :packageRecordTypeId)  AND ElixirSuite__Test__c=null WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC LIMIT 30];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }  
    }
    
    @AuraEnabled(cacheable=true)
    public static List<ICD_Codes__c> getICDs(String accId){
        try{
            Id recordTypeId = Schema.SObjectType.ElixirSuite__ICD_Codes__c.getRecordTypeInfosByDeveloperName().get('Patient_Diagnosis_Code').getRecordTypeId();
            //return [SELECT Id, ICD_Id__c, Name FROM ICD__c where IsPreferred__c = true WITH SECURITY_ENFORCED order by Name];
            return [SELECT Id, Name, Code_Description1__c FROM ICD_Codes__c WHERE Account__c =: accId AND recordTypeId =:recordTypeId WITH SECURITY_ENFORCED  ORDER BY Name];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    public class LabOrderDataWrapper {
        @AuraEnabled public List<ElixirSuite__Lab_Order__c> labOrderList{ get; set; }
        @AuraEnabled public List<ElixirSuite__Facility__c> labFacilityList{ get; set; }
        @AuraEnabled public List<sObject> labTestsList{ get; set; }
        @AuraEnabled public List<ElixirSuite__lab__c> labsList{ get; set; }
        @AuraEnabled public List<PicklistHelper.PicklistOptionWrapper> billTypeOptions{ get; set; }
    }
    @AuraEnabled(cacheable=true)
    public static List<LabOrderDataWrapper> getLabOrderWrapperDataOnEdit(String labOrderId,String cacheBuster) {
        List<LabOrderDataWrapper> labOrderDataList = new List<LabOrderDataWrapper>();
        String labId = '';
        LabOrderDataWrapper labOrderData = new LabOrderDataWrapper();
        List<ElixirSuite__Lab_Order__c> labOrderLst = getLabOrderDataOnEdit(labOrderId);
        String parentOrderId = labOrderLst[0].ElixirSuite__Order__c;
        String labReqId = labOrderLst[0].ElixirSuite__Lab_Order_Req__c;
        List<PicklistHelper.PicklistOptionWrapper> billTypeOptions = PicklistHelper.getPicklistOptions('ElixirSuite__Lab_Order__c','ElixirSuite__Bill_Type__c');
        if(!labOrderLst.isEmpty()){
            labOrderData.labOrderList = labOrderLst;
            labId = labOrderLst[0].ElixirSuite__Lab_Id__c;
        }
        if(!billTypeOptions.isEmpty()){
            labOrderData.billTypeOptions = billTypeOptions;
        }
        List<ElixirSuite__Facility__c> facilityLst = getFacilitiesOnEdit(labId);
        List<ElixirSuite__Test__c> testsLst = new List<ElixirSuite__Test__c>();
        List<ElixirSuite__Test__c> inhouseLabTestsList = new List<ElixirSuite__Test__c>();
        if(labOrderLst[0].ElixirSuite__Lab_Type__c == 'eLab'){
            testsLst = getTestsOnEdit(parentOrderId,labReqId);
        }
        else{
            //fetch test for manual lab order
            inhouseLabTestsList = getInhouseTestsOnEdit(parentOrderId);
        }
        
        List<ElixirSuite__lab__c> labLst = getLabsOnEdit(labId);
        if(!labLst.isEmpty()){
            labOrderData.labsList = labLst;
        }
        if(!facilityLst.isEmpty()){
            labOrderData.labFacilityList = facilityLst;
        }
        if(!testsLst.isEmpty()){
            labOrderData.labTestsList = testsLst;
        }
        if(!inhouseLabTestsList.isEmpty()){
            labOrderData.labTestsList = inhouseLabTestsList;
        }

        
        labOrderDataList.add(labOrderData);
        if(labOrderDataList != NULL && labOrderDataList.size() > 0){
            return labOrderDataList;
        }else{
            return NULL;
        }
    }
    public static List<ElixirSuite__Lab_Order__c> getLabOrderDataOnEdit(String labOrderId){
        List<ElixirSuite__Lab_Order__c> labOrderList = [SELECT Id,ElixirSuite__Lab_Type__c,ElixirSuite__Lab_Id__c,ElixirSuite__Order__r.Name,ElixirSuite__Insurance__c,ElixirSuite__Contact__c,ElixirSuite__Bill_Type__c,ElixirSuite__Lab_Order_Req__c,ElixirSuite__Status__c,ElixirSuite__Order_Type__c,ElixirSuite__Order__c,ElixirSuite__Ordering_Provider__r.LastName,ElixirSuite__Ordering_Provider__r.FirstName, ElixirSuite__Entered_By__r.LastName,ElixirSuite__Entered_By__r.FirstName, ElixirSuite__Verified_By__r.LastName,ElixirSuite__Verified_By__r.FirstName,ElixirSuite__Collection_Date_Time__c,ElixirSuite__Expected_Date_Time__c,ElixirSuite__Facility_Id__c,ElixirSuite__Test_Id__c,ElixirSuite__ICD_Id__c FROM ElixirSuite__Lab_Order__c WHERE Id=:labOrderId WITH SECURITY_ENFORCED LIMIT 1];
        return labOrderList;
    }
    @AuraEnabled(cacheable=true)
    public static List<ElixirSuite__Facility__c> getFacilitiesOnEdit(String labId){
        List<ElixirSuite__Facility__c> labFacilityList = [SELECT Id, ElixirSuite__Lab_ID__c, ElixirSuite__Facility_Id__c, Name FROM ElixirSuite__Facility__c where ElixirSuite__Lab_ID__c=:labId WITH SECURITY_ENFORCED];
        return labFacilityList;
    }
    public static List<ElixirSuite__Test__c> getTestsOnEdit(String parentOrderId,String labReqId){
        List<ElixirSuite__Order__c> orderlist = [Select Id,(SELECT Id,ElixirSuite__Test_Id__c,ElixirSuite__Status__c FROM ElixirSuite__Lab_Orders__r) from ElixirSuite__Order__c WHERE Id=:parentOrderId WITH SECURITY_ENFORCED];
        Set<String> testIdSet = new Set<String>();
        for (ElixirSuite__Lab_Order__c labOrder : orderlist[0].ElixirSuite__Lab_Orders__r) {
            if(String.isNotBlank(labOrder.ElixirSuite__Test_Id__c) && labOrder.ElixirSuite__Status__c != 'C'){
                testIdSet.add(labOrder.ElixirSuite__Test_Id__c);
            }
        }
        List<ElixirSuite__Test__c> labTestsList = [SELECT Id, ElixirSuite__Test_Id__c, ElixirSuite__Test_Name__c, ElixirSuite__Test_Description__c, ElixirSuite__Lab_Id__c FROM ElixirSuite__Test__c where ElixirSuite__Test_Id__c IN:testIdSet and ElixirSuite__IsPreferred__c = true WITH SECURITY_ENFORCED order by ElixirSuite__Test_Name__c];
        return labTestsList;
    }
    public static List<ElixirSuite__Test__c> getInhouseTestsOnEdit(String parentOrderId){
        List<ElixirSuite__Order__c> orderlist = [Select Id,(SELECT Id,ElixirSuite__Test_Id__c,ElixirSuite__Status__c,ElixirSuite__Test__r.ElixirSuite__Test_Id__c FROM ElixirSuite__Lab_Orders__r) from ElixirSuite__Order__c WHERE Id=:parentOrderId WITH SECURITY_ENFORCED];
        Set<String> testIdSet = new Set<String>();
        for (ElixirSuite__Lab_Order__c labOrder : orderlist[0].ElixirSuite__Lab_Orders__r) {
            if(String.isNotBlank(labOrder.ElixirSuite__Test__r.ElixirSuite__Test_Id__c) && labOrder.ElixirSuite__Status__c != 'C'){
                testIdSet.add(labOrder.ElixirSuite__Test__r.ElixirSuite__Test_Id__c);
            }
        }
        List<ElixirSuite__Test__c> labTestsList = [SELECT Id, ElixirSuite__Test_Id__c, ElixirSuite__Test_Name__c, ElixirSuite__Test_Description__c, ElixirSuite__Lab_Id__c FROM ElixirSuite__Test__c where ElixirSuite__Test_Id__c IN:testIdSet WITH SECURITY_ENFORCED order by ElixirSuite__Test_Name__c];
        return labTestsList;
    }
    public static List<ElixirSuite__lab__c> getLabsOnEdit(String labId){
        List<ElixirSuite__lab__c> labsList = [SELECT Id, ElixirSuite__Lab_Id__c, Name FROM ElixirSuite__lab__c where ElixirSuite__Is_Active__c=TRUE AND ElixirSuite__Lab_Id__c=:labId WITH SECURITY_ENFORCED order by Name];
        return labsList;
    }

    @AuraEnabled(cacheable=true)
    public static List<Test__c> getTestList(String searchKey, String labId, String startRecordId, Integer batchSize) {
        try {
            Id chcRecordTypeId = Schema.SObjectType.Test__c.getRecordTypeInfosByDeveloperName().get('CHC_Test').getRecordTypeId();
            String query = 'SELECT Test_Id__c, Test_Name__c, Test_Description__c FROM Test__c';
    
            if (!String.isBlank(labId)) {
                query += ' WHERE Lab_Id__c = :labId';
    
                if (!String.isBlank(searchKey)) {
                    String key = '%' + String.escapeSingleQuotes(searchKey) + '%';
                    query += ' AND (Test_Id__c LIKE :key OR Test_Name__c LIKE :key OR Test_Description__c LIKE :key)';
                }
    
                if (chcRecordTypeId != null) {
                    query += ' AND RecordTypeId = :chcRecordTypeId';
                }
    
                if (!String.isBlank(startRecordId)) {
                    query += ' AND Id > :startRecordId';
                }
            }
    
            query += ' ORDER BY CreatedDate ASC LIMIT :batchSize';
            
            System.debug('Find Test Query: ' + query);
    
            return Database.query(query);
        } catch (Exception e) {
            ExceptionLog.logError(e);
            return new List<Test__c>();  // Return an empty list or handle the error as needed.
        }
    }
    


   
    //inhouse test
    @AuraEnabled(cacheable=true)
public static List<Test__c> getInhouseTestList(String searchKey, String startRecordId, Integer batchSize) {
    try {
        // Retrieve the Record Type Id
        Id manualRecordTypeId = Schema.SObjectType.Test__c.getRecordTypeInfosByDeveloperName().get('Manual_Test').getRecordTypeId();
        Id packageRecordTypeId = Schema.SObjectType.Test__c.getRecordTypeInfosByDeveloperName().get('Package').getRecordTypeId();

        String query = 'SELECT Test_Id__c, Test_Name__c, ElixirSuite__Test__c,Test_Description__c FROM Test__c';

        // Construct the WHERE clause based on conditions
        List<String> conditions = new List<String>();

        if (manualRecordTypeId != null && packageRecordTypeId != null) {
            conditions.add('(RecordTypeId = :manualRecordTypeId OR RecordTypeId = :packageRecordTypeId) and ElixirSuite__Test__c=null');
        }

        if (String.isNotBlank(searchKey)) {
            String key = '%' + String.escapeSingleQuotes(searchKey) + '%';
            conditions.add('(Name LIKE :key)');
        }

        if (String.isNotBlank(startRecordId)) {
            conditions.add('Id > :startRecordId');
        }

        if (!conditions.isEmpty()) {
            query += ' WHERE ' + String.join(conditions, ' AND ');
        }

        query += ' ORDER BY CreatedDate ASC LIMIT :batchSize';

        // Debug the constructed query
        System.debug('Find Test Query: ' + query);

        // Execute the query and return the results
        return Database.query(query);
    } catch (Exception e) {
        ExceptionLog.logError(e); // Ensure you have an appropriate error handling mechanism
        return new List<Test__c>(); // Return an empty list on error
    }
}


    @AuraEnabled(cacheable=true)
public static List<ElixirSuite__ICD_Codes__c> getICDList(String searchKey, String startRecordId, Integer batchSize) {
    try {
        Id recordTypeId = Schema.SObjectType.ElixirSuite__ICD_Codes__c.getRecordTypeInfosByDeveloperName().get('Template_Diagnosis_Code').getRecordTypeId();
        String query = 'SELECT Id, Name, ElixirSuite__Code_Description1__c FROM ElixirSuite__ICD_Codes__c WHERE RecordTypeId = :recordTypeId';

        if (searchKey != null && searchKey!='') {
            String key = '%' + String.escapeSingleQuotes(searchKey) + '%';
            query += ' AND (ElixirSuite__Code_Description1__c LIKE :key OR Name LIKE :key)';
        }

        if (String.isNotBlank(startRecordId)) {
            query += ' AND Id > :startRecordId';
        }

        query += ' ORDER BY CreatedDate ASC LIMIT :batchSize';
        System.debug('Query: ' + query);

        return Database.query(query);
    } catch (Exception e) {
        ExceptionLog.logError(e); // Make sure to define the ExceptionLog.logError method.
        return new List<ElixirSuite__ICD_Codes__c>();
    }
}


    @AuraEnabled
    public static List<String> updateOrderStatus(List<String> orderidvalue,List<String> labOrderIds){
        List<String> OrderUpdateIds;
        Map<String, Object> args = new Map<String, Object>{
            'orderidvalue'=>orderidvalue,
            'labOrderIds'=>labOrderIds
        };
        
        String virtualClassName = 'LabOrder_Transmit';
        List<Elixir_Pluggable_Classes__mdt> pluggableClass = new List<Elixir_Pluggable_Classes__mdt>();
        pluggableClass = [SELECT
                          DeveloperName,
                          Virtual_Class__c
                          FROM Elixir_Pluggable_Classes__mdt
                          WHERE DeveloperName='OrderAPICallouts_updateOrderStatus'
                          WITH SECURITY_ENFORCED];
        if(!pluggableClass.isEmpty()){
            virtualClassName = pluggableClass[0].Virtual_Class__c;
        }
        Type t = Type.forName(virtualClassName);
        if(!test.isRunningTest()){
            Callable transmitOrder = (Callable) t.newInstance();
            OrderUpdateIds= (List<String>)transmitOrder.call('',args);  
        }
    return orderUpdateIds;
    }
}
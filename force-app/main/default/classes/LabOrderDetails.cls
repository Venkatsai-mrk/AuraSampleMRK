public with sharing class LabOrderDetails {

    @AuraEnabled(cacheable=true)
    public static String getPatientId() {
        String patientId='';
        String uId = UserInfo.getUserId();
        List<User> userRecs = Database.query('SELECT id,ContactId,AccountId FROM User WHERE Id =:uId');
        if(userRecs!=null && userRecs.size()>0){
            patientId = (String)userRecs[0].get('AccountId');
        }
        return patientId;
    }
    //method to fetch the details of selected lab order
    @AuraEnabled(cacheable=true)
    public static Lab_Order__c getLabOrderDetails(String recordId) {
     
        try{return [SELECT Id, ElixirSuite__Account_Id__c, Lab_Order_Req__c , Doctors_Note__c, Expected_Date_Time__c, Order_Type__c,ElixirSuite__Ordering_Provider__c, ElixirSuite__Ordering_Provider__r.Name,ElixirSuite__Ordering_Provider__r.FirstName,ElixirSuite__Ordering_Provider__r.LastName, Physician_Name__c ,ICD_Id__c,  Facility_Id__c , Test_Id__c, Collection_Date_Time__c,Lab_Id__c  FROM Lab_Order__c where id =: recordId WITH SECURITY_ENFORCED];}
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
       
    }

    //method to update doctor's note in the lab order records
    @AuraEnabled
    public static void addNote(String recordId, string doctorNote ){
        try{Lab_Order__c l = [SELECT Id, Doctors_Note__c FROM Lab_Order__c where id =: recordId WITH SECURITY_ENFORCED];

          
            l.Doctors_Note__c = doctorNote;
            //Database.update(l);
            DMLManagerV2.updateAsUser(l);
        
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
 
           
    }
    
    //method to get Tests list
    @AuraEnabled(cacheable=true)
    public static List<Test__c> getTests(string OrderId){
       try{list<Lab_Order__c> orders = [Select Id, Test_Id__c from Lab_Order__c where Lab_Order_Req__c =: OrderId WITH SECURITY_ENFORCED];
       list<string> ids = new list<string>();
       for(Lab_Order__c l : Orders){
            ids.add(l.Test_Id__c);
       }

        return [SELECT Id, Test_Id__c, Test_Name__c, Lab_Id__c FROM Test__c where Test_Id__c IN :ids WITH SECURITY_ENFORCED order by Test_Name__c];}
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    //method to get ICD list
    @AuraEnabled(cacheable=true)
    public static List<ElixirSuite__ICD_Codes__c> getICDs(list<string> ICD_Id, String accountId){
        try {
        String queryWithAccount = 'SELECT Id, Name, ElixirSuite__Code_Description1__c FROM ElixirSuite__ICD_Codes__c WHERE Name IN :ICD_Id AND ElixirSuite__Account__c = :accountId WITH SECURITY_ENFORCED ORDER BY Name';

        List<ElixirSuite__ICD_Codes__c> resultWithAccount = Database.query(queryWithAccount);
List<ElixirSuite__ICD_Codes__c> filteredResult = new List<ElixirSuite__ICD_Codes__c>();

// Populate filteredResult with unique records from resultWithAccount
        Set<String> uniqueNamesSet = new Set<String>();
for (ElixirSuite__ICD_Codes__c record : resultWithAccount) {
    // Check if the Name value is unique
    if (!uniqueNamesSet.contains(record.Name)) {
        // Add the record to the filtered result
        filteredResult.add(record);
uniqueNamesSet.add(record.Name); // Add the Name to the set to track uniqueness
    }
}

            String queryWithoutAccount = 'SELECT Id, Name, ElixirSuite__Code_Description1__c FROM ElixirSuite__ICD_Codes__c WHERE Name IN :ICD_Id WITH SECURITY_ENFORCED ORDER BY Name';

            List<ElixirSuite__ICD_Codes__c> resultWithoutAccount = Database.query(queryWithoutAccount);
            
// Populate filteredResult with unique records from resultWithoutAccount
            for (ElixirSuite__ICD_Codes__c record : resultWithoutAccount) {
                // Use the Name field as the key in the map to ensure uniqueness
                if (!uniqueNamesSet.contains(record.Name)) {
        filteredResult.add(record);
        uniqueNamesSet.add(record.Name);
    }
            }

            return filteredResult;


           
        
    } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
        }
    }
    
    //method to get physician list
    @AuraEnabled(cacheable=true)
    public static List<Contact> getPhysicians(){
        try{
            Elixir_Custom_Setting__c val = Elixir_Custom_Setting__c.getOrgDefaults();
        String contactRecType = val.ElixirSuite__Practitioner_Contact_Recordtype__c;
        Id practitionerRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(contactRecType).getRecordTypeId();
            return [SELECT Id, FirstName, LastName,Name FROM Contact where ElixirSuite__Is_Active__c=TRUE AND RecordTypeId=:practitionerRecTypeId WITH SECURITY_ENFORCED order by LastName];
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
   
    //method use in lwc component to fetch obx details
    /* @AuraEnabled(cacheable=true)
    public static list<Lab_Order__c> getTestResultsLWC(string r_id){
        try{
            // Lab_Order__c l = [select Test_Name__c from Lab_Order__c where Id =: r_id WITH SECURITY_ENFORCED];
            // HL7__c hl7 = [select Id from HL7__c where Order_ID__c =: r_id WITH SECURITY_ENFORCED Limit 1];
            // list<LabOrder_Hl7_Results_Tests_Info__c> ObrList = [select Id from LabOrder_Hl7_Results_Tests_Info__c where LabOrder_HL7_Results_ID__c =: hl7.Id and Test_Result_Name__c =: l.Test_Name__c WITH SECURITY_ENFORCED];
            // list<string> ObrIds = new list<string>();
            // for(LabOrder_Hl7_Results_Tests_Info__c o : ObrList){
            //     ObrIds.add(o.Id);
            // }
        list<Test_Result_Detail__c> testresults = [select id, Test_Result_Detail_Name__c, Notes__c, DataforTrends__c  , References_Range__c, Units__c, Observation_Value__c, Observation_Value_type__c from Test_Result_Detail__c where Test_ResultId__c =: r_id AND Test_Result_Detail_Name__c != 'NOTE' AND Observation_Value_type__c IN ('NM', 'ST') AND DataforTrends__c != null WITH SECURITY_ENFORCED];
        
        return testresults;}
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
      

    }*/
     public class LabOrderTestResultWrapper {
        @AuraEnabled
        public List<Test_Result_Detail__c> testResults;
        
        @AuraEnabled
        public List<Lab_Order__c> labOrders;

        public LabOrderTestResultWrapper(List<Test_Result_Detail__c> testResults, List<Lab_Order__c> labOrders) {
            this.testResults = testResults;
            this.labOrders = labOrders;
        }
    }

    @AuraEnabled(cacheable=true)
    public static LabOrderTestResultWrapper getTestResultsLWC(String r_id) {
        LabOrderTestResultWrapper resultWrapper = new LabOrderTestResultWrapper(new List<Test_Result_Detail__c>(), new List<Lab_Order__c>());

        try {
            List<Test_Result_Detail__c> testResults= new List<Test_Result_Detail__c>();
            testResults = [SELECT Id, Test_Result_Detail_Name__c, Notes__c, ElixirSuite__Test_ResultId__c, DataforTrends__c, References_Range__c, Units__c, Observation_Value__c, Observation_Value_type__c FROM Test_Result_Detail__c WHERE Test_ResultId__c = :r_id AND Test_Result_Detail_Name__c != 'NOTE' AND Observation_Value_type__c IN ('NM', 'ST') AND DataforTrends__c != null WITH SECURITY_ENFORCED];

            if (!testResults.isEmpty()) {
                List<Lab_Order__c> labOrders = new List<Lab_Order__c>();
                labOrders = [SELECT Id, Name, (SELECT Id FROM LabOrder_HL7_Results__r), (SELECT Id, Name FROM Attachments), ElixirSuite__Result_Status__c, LastModifiedDate, Physician_Name__c, LabName__c, Facility_Name__c, Test_Name__c, Lab_Order_Req__c, Lab_Order_Number__c, Order__c, ElixirSuite__Order__r.Name, Account_Id__c, toLabel(Status__c), CreatedDate, ElixirSuite__Lab_Type__c FROM Lab_Order__c WHERE Id = :testResults[0].ElixirSuite__Test_ResultId__c WITH SECURITY_ENFORCED LIMIT 1];

                resultWrapper = new LabOrderTestResultWrapper(testResults, labOrders);
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        return resultWrapper;
    }
    //method use in lwc component to fetch obx details
    @AuraEnabled(cacheable=true)
    public static list<Test_Result_Detail__c> getTestResultsTextLWC(string r_id){
        try{
            // Lab_Order__c l = [select Test_Name__c from Lab_Order__c where Id =: r_id WITH SECURITY_ENFORCED];
            // HL7__c hl7 = [select Id from HL7__c where Order_ID__c =: r_id WITH SECURITY_ENFORCED Limit 1];
            // list<LabOrder_Hl7_Results_Tests_Info__c> ObrList = [select Id from LabOrder_Hl7_Results_Tests_Info__c where LabOrder_HL7_Results_ID__c =: hl7.Id and Test_Result_Name__c =: l.Test_Name__c WITH SECURITY_ENFORCED];
            // list<string> ObrIds = new list<string>();
            // for(LabOrder_Hl7_Results_Tests_Info__c o : ObrList){
            //     ObrIds.add(o.Id);
            // }
        list<Test_Result_Detail__c> testresults = [select id, Test_Result_Detail_Name__c, Observation_Value_Text__c,  Observation_Value__c, Observation_Value_type__c from Test_Result_Detail__c where Test_ResultId__c =: r_id AND Test_Result_Detail_Name__c != 'NOTE' AND Observation_Value_type__c IN ('TX', 'ST') AND DataforTrends__c = null WITH SECURITY_ENFORCED];
        
        return testresults;}
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
      

    }

    
    public static string rid{ get; set; }
    //method to fetch requisition pdf 
    public static Attachment getAttachment(){
     try{if(rid== null || rid == ''){
        rid = Apexpages.currentPage().getParameters().get('id');
    }
         Lab_Order__c l = [Select Id, Lab_Order_Req__c, Account_Id__c from Lab_Order__c where Id =:rid WITH SECURITY_ENFORCED Limit 1];
     string pdfName = l.Lab_Order_Req__c+'.pdf';
     Attachment a = [Select Id from Attachment where ParentId =: l.Account_Id__c AND name =: pdfName WITH SECURITY_ENFORCED Limit 1 ];
     return a;}
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
     //method to fetch requisition label 
    public static Attachment getAttachmentLabel(){
     try{if(rid== null || rid == ''){
        rid = Apexpages.currentPage().getParameters().get('id');
    }
         Lab_Order__c l = [Select Id, Lab_Order_Req__c, Account_Id__c from Lab_Order__c where Id =:rid WITH SECURITY_ENFORCED Limit 1];
     string pdfName = 'Label'+l.Lab_Order_Req__c+'.pdf';
     Attachment a = [Select Id from Attachment where ParentId =: l.Account_Id__c AND name =: pdfName WITH SECURITY_ENFORCED Limit 1 ];
     return a;}
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }

    //method to fetch pdf report
    public static Attachment getPdfReport(){
        try{if(rid== null || rid == ''){
           rid = Apexpages.currentPage().getParameters().get('id');
       }
            
        string pdfName = 'PdfReport.pdf';
        Attachment a = [Select Id from Attachment where ParentId =: rid AND name =: pdfName WITH SECURITY_ENFORCED Limit 1 ];
        return a;}
           catch(Exception e){
               throw new AuraHandledException(e.getMessage());
           }
       }
    

}
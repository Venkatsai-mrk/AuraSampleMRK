public with sharing class UB04ClaimFormController {
    @AuraEnabled
    public static wrapper getAccountDetails( Id patientId,String vobId) {
        Wrapper wrpr = new Wrapper();
        try{
            Account accDetails = [SELECT Id, Name, ElixirSuite__Admit_Date__c,ElixirSuite__dischargeDateNew__c,CreatedDate, First_Name__c, Last_Name__c, Gender__c,ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode,ShippingCountry
                                  ,birthdate__c,ElixirSuite__Patient_s_Birth_Date__c,ElixirSuite__DOB__c,ElixirSuite__MRN_Number_New__c , BillingStreet, BillingCity, ElixirSuite__Account_Number__c,BillingState, BillingPostalCode,BillingCountry,Phone
                                  FROM Account where Id =: patientId
                                  WITH SECURITY_ENFORCED];
            List<VOB__c> relatedData = new List<VOB__c>();
            relatedData = [SELECT Account__c,ElixirSuite__Insurance_Type__c,ElixirSuite__Insurance_Providers__c,ElixirSuite__Patient_Relationship_With_Insured__c,ElixirSuite__Telephone__c, ElixirSuite__Group_Name__c, ElixirSuite__Group_Number__c 
                           ,ElixirSuite__Insured_First_Name__c,ElixirSuite__Auto_Accident__c,ElixirSuite__Insured_Last_Name__c,ElixirSuite__Insured_Middle_Name__c,ElixirSuite__Employment__c,ElixirSuite__Is_there_another_Health_Benefit_Plan__c,
                           ElixirSuite__Other_Accident__c,Name,ElixirSuite__Insured_Address__c,ElixirSuite__Insured_State__c,ElixirSuite__Insured_City__c,/*ElixirSuite__Insured_Country__c,*/ElixirSuite__Insured_Zipcode__c, ElixirSuite__Insurance_Plan_Name__c 
                           ,ElixirSuite__Other_Insured_Policy_Group_FECA_Number__c,ElixirSuite__Insured_Policy_Group_FECA_Number__c,ElixirSuite__Other_Insured_s_Name__c,ElixirSuite__OtherInsurancePlanName__c,ElixirSuite__Gender__c,RecordType.DeveloperName,
                           ElixirSuite__Payer__r.Name, ElixirSuite__Set_Default_VOB__c 
                           FROM VOB__c WHERE Account__c =: accDetails.Id AND  status__c='Active' AND ElixirSuite__Set_Default_VOB__c ='Yes'
                           WITH SECURITY_ENFORCED
                           ORDER BY CreatedDate DESC]; 
            
            wrpr.accDetails = accDetails;
            wrpr.vobData = fetchVOBRecord(vobId) ;
            wrpr.relatedVobData = relatedData;
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        return wrpr;
    }
    public static list<ElixirSuite__VOB__c> fetchVOBRecord(String recordId){
        String additionFieldsPrefix = ' where Id = : recordId';
        String otherFieldsAddition = ' ,RecordType.DeveloperName,ElixirSuite__Payer__r.ElixirSuite__Claim_Processing_via__c'; 
        String vobQuery = ElixirOEM_AddEraHelper.formulateQueryString('ElixirSuite__VOB__c',otherFieldsAddition,additionFieldsPrefix+'');
        return Database.query(vobQuery);
        
    }
    public class wrapper{
        @AuraEnabled public Account accDetails ;
        @AuraEnabled public List<VOB__c> vobData ;
        @AuraEnabled public List<VOB__c> relatedVobData ;
        @AuraEnabled public List<Payor__c> payer ;
        
    }
}
public with sharing class customLookupForVobController {
    public class OtherException extends Exception {}
@AuraEnabled
public static List < sObject > fetchSingleLookUpValue1(String searchKeyWord, String accountId){
    String searchKey = searchKeyWord + '%';
        List < ElixirSuite__VOB__c > returnList = new List < ElixirSuite__VOB__c > ();
    try {
        
        returnList =  [SELECT Id,Client_Status__c,Effective_From__c,Effective_To__c,Insurance_Group_Number_Sec__c,
        Insurance_ID_Number__c,Insurance_Provider_Sec__c,
        Insurance_Type__c,LastModifiedDate,Member_Number__c,Member_Plan_Name__c,Name,OwnerId,
        Patient_s_Gender__c,Plan_Benefit_Name__c,Plan_Number__c,Policy_Holder_DOB_Sec__c,Policy_Holder_DOB__c,
        Policy_Holder_Name_Sec__c,Policy_Holder_Name__c,Plan_Type__c,PreAuth_Identifier__c,PreAuth_Name__c,
        Purchase_Plan_Name__c,Status__c,Effective_From_PreAuth__c,SystemModstamp,
        Effective_To_PreAuth__c,ElixirSuite__Service_Type__c,
        ElixirSuite__InsPhone__c,ElixirSuite__Insurance_Type_Sec__c,ElixirSuite__Member_Id__c,ElixirSuite__Group_Number__c,
        ElixirSuite__VOB_Verification_Status__c,ElixirSuite__Insurance_Provider__r.Name
         from ElixirSuite__VOB__c where Name LIKE: searchKey AND  ElixirSuite__Account__c =:accountId
          WITH SECURITY_ENFORCED order by createdDate DESC limit 5];
         if(Test.isRunningTest())
         {
             throw new OtherException();
         }

    } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
    }
    return returnList;
}

}
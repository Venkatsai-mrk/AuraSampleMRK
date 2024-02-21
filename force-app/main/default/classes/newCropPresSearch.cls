/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-08-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class newCropPresSearch {
@AuraEnabled(Cacheable=true)
    public static List<Prescription_Order__c> getPrescriptionBySearch(String keySearch, string accId){
        
        keySearch = '%' + keySearch + '%'; 

        return [Select id,Name,  ElixirSuite__Prescription_Guid__c,ElixirSuite__Drug_Name__c,ElixirSuite__Reason_new__c,ElixirSuite__Patient_SIG__c,ElixirSuite__Refills__c,
           ElixirSuite__Archive_Status_NC__c, ElixirSuite__Status_NC__c,ElixirSuite__SubStatus_NC__c,ElixirSuite__Pharmacy_NC__c,ElixirSuite__Dispense_NC__c,
            ElixirSuite__Direction__c,ElixirSuite__IsEditButtonActive__c from ElixirSuite__Prescription_Order__c  where ( (Name LIKE : keySearch )OR (ElixirSuite__Drug_Name__c LIKE : keySearch)) AND ElixirSuite__Account__c =: accId WITH SECURITY_ENFORCED];
    }
    
    @AuraEnabled(Cacheable=true)
    public static List<Prescription_Order__c> getPrescriptionByStatus(String status, string accId){
        
        status = '%' + status + '%'; 

        return [Select id,Name,  ElixirSuite__Prescription_Guid__c,ElixirSuite__Drug_Name__c,ElixirSuite__Reason_new__c,ElixirSuite__Patient_SIG__c,ElixirSuite__Refills__c,
           ElixirSuite__Archive_Status_NC__c, ElixirSuite__Status_NC__c,ElixirSuite__SubStatus_NC__c,ElixirSuite__Pharmacy_NC__c,ElixirSuite__Dispense_NC__c,
            ElixirSuite__Direction__c,ElixirSuite__IsEditButtonActive__c from ElixirSuite__Prescription_Order__c  where(( ElixirSuite__Status_NC__c LIKE : status) OR (ElixirSuite__Archive_Status_NC__c LIKE : status ))AND ElixirSuite__Account__c =: accId WITH SECURITY_ENFORCED];
    }
   /* @AuraEnabled(Cacheable=true)
    public static string getUserInfo(){
        string flag;
         List<user> Userdata  = [select id, FirstName, MiddleName,LastName,Phone , Fax ,City, State, PostalCode, Street, Country,ElixirSuite__License__c ,ElixirSuite__User_Type__c,ElixirSuite__Role_Type__c,ElixirSuite__siteId__c from user  WHERE Id =:UserInfo.getUserId() WITH SECURITY_ENFORCED limit 1];  
        if(Userdata[0].ElixirSuite__Role_Type__c == null || Userdata[0].ElixirSuite__User_Type__c == null || Userdata[0].ElixirSuite__siteId__c == null || 
           Userdata[0].Phone == null || Userdata[0].Fax == null || Userdata[0].ElixirSuite__License__c == null || Userdata[0].City == null|| Userdata[0].PostalCode == null|| Userdata[0].State == null|| Userdata[0].Street == null|| Userdata[0].Country == null){
           flag='1'; 
        }
        else{
            flag='0';
        }
        return flag;
    }*/
    @AuraEnabled(Cacheable=true)
public static String getUserInfo() {
    String flag = '0'; // Default flag value
    

    // Fetch the user data
    List<User> userData = [SELECT Id, FirstName, MiddleName, LastName, Phone, Fax, City, State, PostalCode, Street, Country, ElixirSuite__License__c, ElixirSuite__User_Type__c, ElixirSuite__Role_Type__c, ElixirSuite__siteId__c FROM User WHERE Id = :UserInfo.getUserId() WITH SECURITY_ENFORCED LIMIT 1];

    if (!userData.isEmpty()) {
        User userRecord = userData[0];
        
        if(String.isBlank(userRecord.ElixirSuite__Role_Type__c) || String.isBlank(userRecord.ElixirSuite__User_Type__c) ){
             flag = '1';
        }
		else if (userRecord.ElixirSuite__User_Type__c == 'LicensedPrescriber') {
        if (String.isBlank(userRecord.ElixirSuite__siteId__c) ||
            String.isBlank(userRecord.Phone) || String.isBlank(userRecord.Fax) || String.isBlank(userRecord.City) || String.isBlank(userRecord.PostalCode) ||
            String.isBlank(userRecord.State) || String.isBlank(userRecord.Street) || String.isBlank(userRecord.Country) || String.isBlank(userRecord.ElixirSuite__License__c)) {
            
               
                    flag = '2';
               
            }
        }else if (userRecord.ElixirSuite__User_Type__c == 'Staff') {
            if (String.isBlank(userRecord.ElixirSuite__siteId__c) ||
            String.isBlank(userRecord.Phone) || String.isBlank(userRecord.Fax) || String.isBlank(userRecord.City) || String.isBlank(userRecord.PostalCode) ||
            String.isBlank(userRecord.State) || String.isBlank(userRecord.Street) || String.isBlank(userRecord.Country)) {
            
                flag = '3';
            }
        }
    
    }
    return flag;

}

    @AuraEnabled(Cacheable=true)
    public static Boolean getUserType(){
        Boolean flag;
         List<user> Userdata  = [select id, FirstName, MiddleName,LastName,ElixirSuite__User_Type__c,ElixirSuite__Role_Type__c,ElixirSuite__siteId__c from user  WHERE Id =:UserInfo.getUserId() WITH SECURITY_ENFORCED limit 1];  
        if(Userdata[0].ElixirSuite__User_Type__c == 'Staff' ){
           flag=true; 
        }
        else{
            flag=false;
        }
        return flag;
    }
        
        
}
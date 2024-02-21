/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-03-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/

public with sharing class ElixirEHR_Square_Utility {
    public static String fetchSquareCreds(){
        String baseURL = '';
        
        return baseURL;
    }
    public static String fetchSquareVersion(){
        String baseURL = '';
        
        return baseURL;
    }
    public static String fetchSquareToken(){
        String baseURL = '';
        
        return baseURL;
    }
    public static String fetchLocation(){
        String baseURL = '';
        
        return baseURL;
    }
    public static String fetchCustomerApi(){
        String baseURL = '';
        
        return baseURL;
    }
    public static String fetchClientId(){
        String baseURL = '';
        
        return baseURL;
    }
    public static String fetchSecretKey(){
        String baseURL = '';
        
        return baseURL;
    }
    public static String fetchCustomerId(String accountId){
        String apiName = fetchCustomerApi();
        String squareCustomerId = '';
        List<Account> accounts = [SELECT Id FROM Account WHERE Id= :accountId WITH SECURITY_ENFORCED];
        if(accounts!=null && accounts.size()>0 && apiName!=''){
            squareCustomerId = (String) accounts[0].get(apiName);
            return squareCustomerId;
        }
        return '';
    }
    public static void fetchCustomerDetails(String accountId){
        
    }
    //{"amount":12,"currencyType":"CAD"}
    public class payment_Info{
        public Decimal amount;
        public String currencyType;
    }
    
}
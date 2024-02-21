global with sharing class claimValidationHelper {
    @deprecated
    global static Boolean verifyDev = false;
    public static Boolean verifyDev1 = false;
    global static Boolean byPass = true;
    global claimValidationHelper() {}
    @deprecated
    global static String validateClaim(Claim__c claimData) { return null ;}
    @deprecated
    global static String validate(Claim__c claimData,List<Claim_Line_Items__c> lineItems) { return null ;}
    @deprecated
    global static Boolean getVerifyDev() {
        Boolean verDevice = verifyDev1;
        return verifyDev1;
    }
    @deprecated
    global static void setVerifyDev(Boolean value) {
        verifyDev1 = value;
    }
    public static Boolean getVerifyDev1() {
        Boolean verDevice = verifyDev1;
        return verifyDev1;
    }
    public static void setVerifyDev1(Boolean value) {
        verifyDev1 = value;
    }
    global static String validate1(List<Claim__c> claimRecData,List<Claim_Line_Items__c> lineItems) {
        
        
        return null;
    }
   global static wrap validateClaims(ElixirSuite__Claim__c claimData){
       
       return null;
       
   }
   global static wrap validateClaimLineItem(ElixirSuite__Claim_Line_Items__c lineItem){
       
       return null;
   }
    global class wrap{
        public String key;
        public List<errors> value;
    }
    global class errors{
        @AuraEnabled public String errorMessage;
        @AuraEnabled public String errorField;
        public errors(String errorField, String errorMessage){
            this.errorField = errorField;
            this.errorMessage = errorMessage;
        }
    }
    global static List<String> splitNames1(String incomingText){
        
            return null;
    }
    global static List<String> splitNames(String incomingText){
        
            return null;
    }
}
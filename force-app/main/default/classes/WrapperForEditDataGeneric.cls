public class WrapperForEditDataGeneric {
 @AuraEnabled public List<Form__c> allForms{get;set;}
 @AuraEnabled public wrapperForAccName accName {get;set;}
     public class wrapperForAccName{
        @AuraEnabled  public List<Form__c> forms;
        @AuraEnabled  public String accName;
        @AuraEnabled  public String dob;
        @AuraEnabled  public String passCode;
        @AuraEnabled  public String parentAccount;
        
    }
    public class arrForFormFields {
        public List<List<Form_Field__c>> arrFormFields {get;set;}
    }
}
public with sharing class ElixirHC_UAanalysisApexConroller {
    @AuraEnabled
    public static Wrapper getAccountDetails(String accountId) {
        //Medical Record Number is Removed because it is Health Cloud field
        List<Account> listOfAccount = [SELECT Id, Name, Age__c, DOB__c, Gender__c,Blood_Group__c,elixirsuite__mrn_number_new__c 
                                       FROM Account WHERE Id= :accountId WITH SECURITY_ENFORCED];
        Contact con=[select Id,name,birthdate from contact where AccountId=:listOfAccount[0].id WITH SECURITY_ENFORCED limit 1];
                                       Wrapper wrpr = new Wrapper();
        Integer age ;
        try{
          if(con.birthdate!=null){
                Date birthdate1=con.birthdate;
                Integer days = birthdate1.daysBetween(Date.Today());
                age = Integer.valueOf(days/365);
          }
        
        List<User> listOfUsers = [SELECT Id, Name FROM User WITH SECURITY_ENFORCED];
        wrpr.accountRec = listOfAccount[0];
        wrpr.listOfUsers = listOfUsers;
        wrpr.patientAge = age ;
        wrpr.patientBirthdate = con.Birthdate ;
        wrpr.nameSpace = Elixir_Utility.getNamespace();
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        return wrpr;
    }
    @AuraEnabled
    public static Boolean savePhysicalDetail(UA_Sample_Details__c dataToSave) {
        Id recordTypeIdAsFetched = Schema.SObjectType.UA_Sample_Details__c.getRecordTypeInfosByName().get('Urine Analysis').getRecordTypeId();
        dataToSave.RecordTypeId = recordTypeIdAsFetched;
        mDebugUntruncated(String.valueOf(dataToSave));
        Boolean getEmailValidationValue = false;
        try{
        if(dataToSave != null){           
            DMLManager.upsertAsUser(dataToSave);
             getEmailValidationValue  =  ElixirHC_UAListViewController.sendEmailNotificationToUAMember(dataToSave.Order_to__c,dataToSave.id);
        }
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        return getEmailValidationValue;
    }
    public static void mDebugUntruncated(String sMsg) {
    for (Integer i = 0; i < sMsg.length(); i=i+300) {
        Integer iEffectiveEnd = (i+300 > (sMsg.length()-1) ? sMsg.length()-1 : i+300);
        
    }
}
    public class Wrapper{
        @AuraEnabled public Account accountRec;
        @AuraEnabled public List<User> listOfUsers;
        @AuraEnabled public integer patientAge ;
        @AuraEnabled public date patientBirthdate ;
        @AuraEnabled public String nameSpace;
    }
}
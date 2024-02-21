public with sharing class EditPrescriptionController {
    
    @AuraEnabled
    public static wrapper buildPresc(String accountId, String formUniqueId){
        
         list<ElixirSuite__Prescription_Order__c> prescRec = new list<ElixirSuite__Prescription_Order__c>();
        try{
        System.debug('account:'+accountId);
        System.debug('formUniqueId:'+formUniqueId);
        
     
            prescRec = [select ElixirSuite__Drug_Name__c,ElixirSuite__Reason_new__c,ElixirSuite__Number_of_Times_Days_Weeks__c,ElixirSuite__Route_New__c,ElixirSuite__Dosage_Form__c,CreatedBy.name,CreatedDate,LastModifiedDate from ElixirSuite__Prescription_Order__c 
                        where ElixirSuite__Account__c=:accountId and ElixirSuite__Drug_Name__c!=null and Form_Unique_Id__c =:formUniqueId
                       and Prescription_Order__c!= null WITH SECURITY_ENFORCED];
            System.debug('care episode is not there:');
     //   }
    }
         catch(Exception e){
            ExceptionLog.logError(e);
        }
        List<ElixirSuite__Prescription_Order__c> listOfencounter = prescRec;
        system.debug('listOfencounter'+listOfencounter);
        //String namespace = Elixir_utility.getNameSpace();
        Wrapper wrpr = new Wrapper();
        wrpr.lstOfAllProblemPerAccount = listOfencounter;
        wrpr.columns = EditPrescriptionConfiguration.getPresColumns();
        System.debug('columns'+wrpr.columns);
        System.debug('lstOfAllProblemPerAccount'+wrpr.lstOfAllProblemPerAccount);
        System.debug('wrapper'+wrpr);
        return wrpr;
      // return prescRec;
        
    }

    @AuraEnabled
    public static wrapper fetchEPresc(String accountId){

        list<ElixirSuite__Prescription_Order__c> prescRec = new list<ElixirSuite__Prescription_Order__c>();
        try{
        System.debug('account:'+accountId);
      //  System.debug('formUniqueId:'+formUniqueId);
    
            prescRec = [Select id,Name,  ElixirSuite__Prescription_Guid__c,ElixirSuite__Drug_Name__c,ElixirSuite__Reason_new__c,ElixirSuite__Patient_SIG__c,ElixirSuite__Refills__c,
            ElixirSuite__Archive_Status_NC__c, ElixirSuite__Status_NC__c,ElixirSuite__SubStatus_NC__c,ElixirSuite__Pharmacy_NC__c,ElixirSuite__Dispense_NC__c,
             ElixirSuite__Direction__c ,ElixirSuite__IsEditButtonActive__c   from ElixirSuite__Prescription_Order__c where ElixirSuite__Account__c =:accountId And ElixirSuite__Prescription_Guid__c != ''  WITH SECURITY_ENFORCED];
            System.debug('care episode is not there:');
     
    }
         catch(Exception e){
            ExceptionLog.logError(e);
        }
        List<ElixirSuite__Prescription_Order__c> listOfencounter = prescRec;
        system.debug('listOfencounter'+listOfencounter);
        //String namespace = Elixir_utility.getNameSpace();
        Wrapper wrpr = new Wrapper();
        wrpr.lstOfAllProblemPerAccount = listOfencounter;
        wrpr.columns = EditPrescriptionConfiguration.getPresColumns();
        System.debug('columns'+wrpr.columns);
        System.debug('lstOfAllProblemPerAccount'+wrpr.lstOfAllProblemPerAccount);
        System.debug('wrapper'+wrpr);
        return wrpr;
      // return prescRec;

    }

    public class Wrapper{
        @AuraEnabled public String columns;
        @AuraEnabled public String namespace;
        @AuraEnabled public List<ElixirSuite__Prescription_Order__c> lstOfAllProblemPerAccount;
        @AuraEnabled public List<ElixirSuite__Dataset1__c> lstOfAllProblemPerAccountdup;
    }
    
}
public with sharing class VaccineStatementController {
@AuraEnabled
    public static Data_Wrapper getMORDetails(String accountId){
        Data_Wrapper obj ;
        try{
        if(schema.sobjecttype.MAR_MOR__c.isAccessible()
           && schema.sobjecttype.MAR_MOR__c.fields.Name.isAccessible()
           && schema.sobjecttype.MAR_MOR__c.fields.CreatedDate.isAccessible()
           && schema.sobjecttype.MAR_MOR__c.fields.Scheduled_Time__c.isAccessible()
           && schema.sobjecttype.MAR_MOR__c.fields.Account__c.isAccessible()
           && schema.sobjecttype.MAR_MOR__c.fields.Drug_Name__c.isAccessible()
           && schema.sobjecttype.MAR_MOR__c.fields.Administered_By__c.isAccessible()
           && schema.sobjecttype.MAR_MOR__c.fields.Dosage_Time__c.isAccessible()
           && schema.sobjecttype.MAR_MOR__c.fields.Status__c.isAccessible()
           && schema.sobjecttype.MAR_MOR__c.fields.Medication_Name__c.isAccessible()
           && schema.sobjecttype.MAR_MOR__c.fields.Reasons__c.isAccessible()
           && schema.sobjecttype.MAR_MOR__c.fields.Medication_Quantity__c.isAccessible()){
               List<MAR_MOR__c> marState = [SELECT Id, Name, CreatedDate,Scheduled_Time__c, Account__c, Drug_Name__c,
                                            Administered_By__c, Dosage_Time__c, Status__c,Medication_Name__c, Reasons__c, Medication_Quantity__c
                                            FROM MAR_MOR__c where Account__c=: accountId WITH SECURITY_ENFORCED];
               string nameSpace = Elixir_Utility.getNamespace();
               obj = new Data_Wrapper(marState,nameSpace);
               
           }
        }
        catch(Exception e){
        ExceptionLog.logError(e);
        }
        return obj;
    }
    
    @AuraEnabled
    public static Data_Wrapper getMARForRangeApex(String fromDate, String toDate, String recordVal){
        system.debug('new val' + fromDate);
        Date fDate = Date.valueOf(fromDate);
        Date tDate = Date.valueOf(toDate);
        Data_Wrapper obj ; 
        try{
        if(schema.sobjecttype.MAR_MOR__c.isAccessible()
           && schema.sobjecttype.MAR_MOR__c.fields.Name.isAccessible()
           && schema.sobjecttype.MAR_MOR__c.fields.CreatedDate.isAccessible()
           && schema.sobjecttype.MAR_MOR__c.fields.Scheduled_Time__c.isAccessible()
           && schema.sobjecttype.MAR_MOR__c.fields.Account__c.isAccessible()
           && schema.sobjecttype.MAR_MOR__c.fields.Drug_Name__c.isAccessible()
           && schema.sobjecttype.MAR_MOR__c.fields.Administered_By__c.isAccessible()
           && schema.sobjecttype.MAR_MOR__c.fields.Dosage_Time__c.isAccessible()
           && schema.sobjecttype.MAR_MOR__c.fields.Status__c.isAccessible()
           && schema.sobjecttype.MAR_MOR__c.fields.Medication_Name__c.isAccessible()
           && schema.sobjecttype.MAR_MOR__c.fields.Reasons__c.isAccessible()
           && schema.sobjecttype.MAR_MOR__c.fields.Medication_Quantity__c.isAccessible()
           && schema.sobjecttype.MAR_MOR__c.fields.Was_Missed__c.isAccessible()){
        List<MAR_MOR__c> marStatement = [SELECT Id, Name, CreatedDate,Scheduled_Time__c, Account__c,Was_Missed__c, Drug_Name__c,Administered_By__c,Medication_Name__c, Dosage_Time__c, Status__c, Reasons__c, Medication_Quantity__c
                                         ,ElixirSuite__Administered_Date__c,ElixirSuite__Vaccine_Route__c,ElixirSuite__Vaccine_Site__c
                                                                       FROM MAR_MOR__c
                                                                      WHERE DAY_ONLY(CreatedDate) >= :fDate AND DAY_ONLY(CreatedDate) <= :tDate AND Account__c=: recordVal AND type__c = 'Vaccine' WITH SECURITY_ENFORCED];
        
        string nameSpace = Elixir_Utility.getNamespace();
        obj = new Data_Wrapper(marStatement,nameSpace );
         }
        }
        catch(Exception e){
        ExceptionLog.logError(e);
        }
        return obj;
      //commented  
    }
    
    public class Data_Wrapper{
        @AuraEnabled public List<MAR_MOR__c> statList;
         @AuraEnabled public string nameSpace;
        
        public Data_Wrapper(List<MAR_MOR__c> statLists, string NameSpace ){
            this.statList = statLists.clone();
            this.nameSpace = NameSpace;
        }
    }
}
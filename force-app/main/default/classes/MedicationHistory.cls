public with sharing class MedicationHistory {

@AuraEnabled
    public static void saveMedicationHistoryRecords(List<Medication_History__c> Records){
        DMLManager.insertAsUser(Records);
      
    }
     
   @AuraEnabled       
    public static List<List<String>> PicklistFromMH()
    {
         List<List<string>> masterList = new List<List<string>>();
         List<string> options = new List<string>();
        Schema.DescribeFieldResult fieldResult;
        try{
       if(Schema.sobjecttype.Medication_History__c.isAccessible() 
                          && Schema.sObjectType.Medication_History__c.fields.Frequency__c.isAccessible())
       {
            fieldResult = Medication_History__c.Frequency__c.getDescribe();
       }
        
         
               
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple)
        { 
            options.add( f.getValue());
      
        }    
        masterList.add(options);
        }
        catch(Exception e){
        ExceptionLog.logError(e);
        }

       return masterList;
  }
    
    @AuraEnabled
    public static License_Class LicensBasdPermission()
    {
        Id currentUid = UserInfo.getUserId();
        String AvailLicense = [Select Id,ElixirSuite__License_Type__c,Username,Name from User
         where Id =:currentUid WITH SECURITY_ENFORCED].ElixirSuite__License_Type__c;
        List<String> lst_availLicense = new List<String>();
        lst_availLicense = AvailLicense.split(';');
        License_Class lCls = new License_Class();
        try{
        for(String str : lst_availLicense)
        {
            if(str == 'Elixir EHR')
            {
                lCls.isEhr = True;
                continue;
            }
           
            if(str == 'Elixir Contact Center')
            {
                lCls.isContactCenter = True;
                continue;
            }
            
            if(str == 'Elixir RCM')
            {
                lCls.isRcm = True;
                continue;
            }
        }
        }
        catch(Exception e){
        ExceptionLog.logError(e);
        }

        return lCls;
    }
    public class License_Class
    {
        @AuraEnabled public Boolean isEhr;
        @AuraEnabled public Boolean isRcm;
        @AuraEnabled public Boolean isContactCenter;
    }
    
}
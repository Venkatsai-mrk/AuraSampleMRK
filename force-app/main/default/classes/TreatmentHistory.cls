public with sharing class TreatmentHistory {

    @AuraEnabled
    public static void saveTreatmentHistoryRecords(List<Treatment_History__c> records){      
        if(Schema.sObjectType.Treatment_History__c.isCreateable()){  
            insert records;
        }
    }
    
   @AuraEnabled       
    public static List<List<String>> PicklistFromTH()
    {
         List<List<string>> masterList = new List<List<string>>();
        try{
         List<string> options = new List<string>();
           Schema.DescribeFieldResult fieldResult;
        if(Schema.sobjecttype.Treatment_History__c.isAccessible() 
                          && Schema.sObjectType.Treatment_History__c.fields.Level_of_Care__c.isAccessible()){
            fieldResult = Treatment_History__c.Level_of_Care__c.getDescribe();
        }     
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){ 
            options.add( f.getValue());
        }    
        system.debug(options);
        masterList.add(options);
        }
        catch(Exception e){
        ExceptionLog.logError(e);
        }
       return masterList;
  }
    @AuraEnabled
    public static License_Class LicensBasdPermission(){
        Id currentUid = UserInfo.getUserId();
        String AvailLicense = [Select Id,ElixirSuite__License_Type__c,Username,Name FROM User 
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
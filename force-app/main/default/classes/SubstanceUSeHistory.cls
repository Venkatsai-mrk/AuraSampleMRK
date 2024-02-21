public with sharing class SubstanceUSeHistory{

@AuraEnabled
    public static void saveSubsanceUseHistoryRecords(List<Substance_Use_History__c> Records){
        if(Substance_Use_History__c.sObjectType.getDescribe().isCreateable()){
            insert records;
        }       
    }
    
   @AuraEnabled       
    public static List<List<String>> PicklistFromSUH()
    {
         List<List<string>> masterList = new List<List<string>>();
         List<string> options = new List<string>();
         List<string> options2 = new List<string>();
       Schema.DescribeFieldResult fieldResult;
       Schema.DescribeFieldResult fieldResultsub;
        //tring a= 'Primary_Drug_Type__c';
        try{
        if(Schema.sObjectType.Substance_Use_History__c.isAccessible() && Schema.sObjectType.Substance_Use_History__c.fields.Substance__c.isAccessible())
        
        {
            fieldResult = Substance_Use_History__c.Substance__c.getDescribe();
        }
          if(Schema.sObjectType.Substance_Use_History__c.isAccessible() && Schema.sObjectType.Substance_Use_History__c.fields.Frequency__c.isAccessible())
          {
              fieldResultsub= Substance_Use_History__c.Frequency__c.getDescribe();
          }
               
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple)
        { 
            options.add( f.getValue());
      
        }    
        masterList.add(options);
        
          List<Schema.PicklistEntry> plesub = fieldResultsub.getPicklistValues();
        for( Schema.PicklistEntry fsub : plesub)
        {
            
            options2.add( fsub.getValue());
           
        }     
       masterList.add(options2);
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
        String AvailLicense = [Select Id,ElixirSuite__License_Type__c,Username,Name FROM User 
        WHERE Id =:currentUid WITH SECURITY_ENFORCED].ElixirSuite__License_Type__c;
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
    //Comminted
    public class License_Class
    {
        @AuraEnabled public Boolean isEhr;
        @AuraEnabled public Boolean isRcm;
        @AuraEnabled public Boolean isContactCenter;
    }
    
}
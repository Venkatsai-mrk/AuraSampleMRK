public with sharing class GroupObjectCustomTabCtrl {

    @AuraEnabled
    public static String  getURL(){
        String url =system.URL.getSalesforceBaseUrl().toExternalForm() ;
        
       //String accGroupId = [Select id, Name, ElixirSuite__Criteria_Filter__c from ElixirSuite__Account_Group__c limit 1].Id;
        string accGroupId = '';
        List<ElixirSuite__Account_Group__c> accGroupIds = [Select id, Name, ElixirSuite__Criteria_Filter__c from ElixirSuite__Account_Group__c WITH SECURITY_ENFORCED limit 1];
        if(accGroupIds != null && accGroupIds.size() > 0){
            accGroupId = accGroupIds[0].id;
            accGroupId = accGroupId.substring(0, 3);
        }
       
        try{
            if(UserInfo.getUiTheme() == 'Theme3'){
                url = url + '/'+accGroupId;
                
            }else if(UserInfo.getUiTheme() == 'Theme4d'){
                url = url + '/'+'lightning/o/ElixirSuite__Account_Group__c/list';
            }
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }  
   
        return url;
    }
}
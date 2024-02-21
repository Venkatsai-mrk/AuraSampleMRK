public with sharing class ReferralListViewHelper {
    //Added by Ashwini
    @AuraEnabled
    public static string fetchAccountName(string accountId){
        List<Account> acc=[SELECT Id, name FROM Account WHERE Id= :accountId WITH SECURITY_ENFORCED];
        string accName = acc[0].name;
        return accName;
    }
    @AuraEnabled 
    public static ElixirSuite__Referral__c[] refeerralRecords(String accountId){
        String additionFieldsPrefix = ' WHERE ElixirSuite__Account__c =: accountId ';
        String otherFieldsAddition = ' ,(Select name,Id FROM Attachments LIMIT 1),ElixirSuite__Provider__r.Name,ElixirSuite__Referred_Out_Organization__r.Name,ElixirSuite__User__r.Name,CreatedBy.Name,'+
            'ElixirSuite__Referred_To__r.Name';
        String referralQuery = ElixirOEM_AddEraHelper.formulateQueryString('ElixirSuite__Referral__c',otherFieldsAddition,additionFieldsPrefix+' order by createdDate desc ');
        ElixirOEM_TimelineHelper.mDebugUntruncated(referralQuery);
        return Database.query(referralQuery);
    }
    @AuraEnabled
    public static wrapper initpayloadForReferralListView(String accountId ){
        Wrapper toRet = new Wrapper();
        toRet.refeerralRecords = refeerralRecords(accountId);
        toRet.columns = ReferralColumnConfiguration.getProblemColumns();
        return toRet;
    }
    public class Wrapper{   
        @AuraEnabled public List<ElixirSuite__Referral__c> refeerralRecords;
        @AuraEnabled public String columns;
    }
    @AuraEnabled
    public static void deleteAllReferral(String[] parentId ){
        try{
        if(Schema.sObjectType.ElixirSuite__Referral__c.isDeletable()) {
            delete[SELECT ID FROM ElixirSuite__Referral__c WHERE ID IN : parentId WITH SECURITY_ENFORCED];
        }
    }
        catch(Exception e){
        ExceptionLog.logError(e);
        }
    }
    @AuraEnabled
    public static void deleteRecord(String recId){
        try{
        if(Schema.sObjectType.ElixirSuite__Referral__c.isDeletable()) {
            delete[SELECT ID FROM ElixirSuite__Referral__c WHERE ID =: recId WITH SECURITY_ENFORCED];
        }
    }
        catch(Exception e){
        ExceptionLog.logError(e);
        }
    }
    
    @AuraEnabled
    public static boolean checkCareEpisode(string patientId){      
        
        list<ElixirSuite__Visits__c> listCareEpisode=[select id,ElixirSuite__Account__c,ElixirSuite__Status__c from ElixirSuite__Visits__c
                                                      Where ElixirSuite__Account__c=:patientId WITH SECURITY_ENFORCED];
        
        boolean checkAllStatus=true;
        Elixir_Custom_Setting__c mcs = Elixir_Custom_Setting__c.getOrgDefaults();
        
        for(ElixirSuite__Visits__c exVar:listCareEpisode){
            if(exVar.ElixirSuite__Status__c=='Active'){
               checkAllStatus=false;  
            }
        }
        if(checkAllStatus && mcs.ElixirSuite__CareEpisode__c){
            return true;
        }else{
            return false;
        }
       
    }
}
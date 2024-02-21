/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-01-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class Elixir_ViewEditERAEOBRecs { /*
  
     @AuraEnabled
    public static List<ElixirSuite__Recommendation__c> fetchRecs(String rec1Id){ 
       List<ElixirSuite__Recommendation__c> recList= [Select Id,ElixirSuite__Elixir_Recommendation__c,ElixirSuite__Elixir_Assign_To__c from ElixirSuite__Recommendation__c where ElixirSuite__Elixir_ERA__c =: rec1Id WITH SECURITY_ENFORCED];
       
       return recList;
    }
    
     @AuraEnabled
    public static void saveRecList(List<ElixirSuite__Recommendation__c> recommendationList, List<ElixirSuite__Recommendation__c> delRecList) 
    {   
       System.debug('recommendationList '+recommendationList);
        System.debug('delRecList '+delRecList);
        RecordType rt = [select id,name from RecordType where sobjecttype = 'ElixirSuite__Recommendation__c' and name='Adjustment Codes' WITH SECURITY_ENFORCED limit 1];
        List<ElixirSuite__Recommendation__c> recommendationsToInsert = new List<ElixirSuite__Recommendation__c>();//List to insert Recommendation
        List<ElixirSuite__Recommendation__c> recommendationsToUpdate = new List<ElixirSuite__Recommendation__c>();//List to update Recommendation
        for(ElixirSuite__Recommendation__c recommendation : recommendationList){
            if(recommendation.Id == null){
                if(recommendation.ElixirSuite__Elixir_Recommendation__c != ''){
                recommendation.RecordTypeId = rt.Id;
                recommendationsToInsert.add(recommendation);  
                }
            }
            else
            { 
                recommendationsToUpdate.add(recommendation);   
            }
        }
        try{
        if(ElixirSuite__Recommendation__c.sObjectType.getDescribe().isCreateable() && recommendationsToInsert != null){
            if(Schema.sObjectType.ElixirSuite__Recommendation__c.isCreateable() &&
            Schema.sObjectType.ElixirSuite__Recommendation__c.fields.ElixirSuite__Elixir_Recommendation__c.isCreateable() &&
            Schema.sObjectType.ElixirSuite__Recommendation__c.fields.RecordTypeId.isCreateable()){
            insert recommendationsToInsert;
        }
    }
       }
        catch(Exception e){
        ExceptionLog.logError(e);
           }
        try{
        if(ElixirSuite__Recommendation__c.sObjectType.getDescribe().isUpdateable() && recommendationsToUpdate != null){
            update recommendationsToUpdate;
        }
        }
        catch(Exception e){
        ExceptionLog.logError(e);
           }
        try{
        if(delRecList != null  && ElixirSuite__Recommendation__c.sObjectType.getDescribe().isDeletable()){
          delete  delRecList; 
        }
        }
        catch(Exception e){
        ExceptionLog.logError(e);
           }
    } */
    
}
/*
Created By - Akanksha Singh
Created Date - 2-Aug-2022
Description - Controller class of Elixir_AddNotesClaimERRecommendation
Test Class : Elixir_ViewEditERAEOBRecNotesTest
Lightning Component - Elixir_AddNotesClaimERRecommendation
*/
public with sharing class Elixir_ViewEditERAEOBRecNotes{  
    //To fetch FollowUp Notes
    @AuraEnabled
    public static List<ElixirSuite__Notes__c> fetchNotes(String recId){
        List<ElixirSuite__Notes__c> followupNoteList= [Select id,ElixirSuite__Follow_Up_Notes__c,ElixirSuite__Elixir_Follow_up_Date__c,ElixirSuite__Elixir_Assigned_To__c,ElixirSuite__ERA_Notes__c from ElixirSuite__Notes__c where ElixirSuite__ERA_Notes__c =: recId AND ElixirSuite__ERA_Notes__c != null WITH SECURITY_ENFORCED];
        return followupNoteList;
    }
    
     //To fetch Recommendation  
    @AuraEnabled
    public static List<ElixirSuite__Recommendation__c> fetchRecommendations(String recId){
        List<ElixirSuite__Recommendation__c> RecommendationList= [Select id,ElixirSuite__Elixir_Recommendation__c,ElixirSuite__Elixir_Assign_To__c,ElixirSuite__Elixir_ERA__c,ElixirSuite__Elixir_ERA__r.ElixirSuite__Claim__r.Name from ElixirSuite__Recommendation__c where ElixirSuite__Elixir_ERA__c =: recId AND ElixirSuite__Elixir_ERA__c != null WITH SECURITY_ENFORCED];
        return RecommendationList;
    }
    
    
    //To save and update FollowUp Notes
   /* @AuraEnabled
    public static void saveNoteList(List<ElixirSuite__Notes__c> noteList,List<ElixirSuite__Notes__c> delNoteList) 
    {    
        System.debug('noteList '+noteList);
        System.debug('delNoteList '+delNoteList);
        RecordType rt = [select id,name from RecordType where sobjecttype = 'ElixirSuite__Notes__c' and name='Claim ERA' limit 1];
        List<ElixirSuite__Notes__c> notesToInsert = new List<ElixirSuite__Notes__c>();//List to insert Followup Notes
        List<ElixirSuite__Notes__c> notesToUpdate = new List<ElixirSuite__Notes__c>();//List to update Followup Notes
        for(ElixirSuite__Notes__c notes : noteList){
            if(notes.Id == null){
                if(notes.ElixirSuite__Elixir_Assigned_To__c != null && notes.ElixirSuite__Elixir_Follow_up_Date__c != null && notes.ElixirSuite__Follow_Up_Notes__c != null){
                notes.RecordTypeId = rt.Id;
                notesToInsert.add(notes);
                }
            }
            else
            { 
                notesToUpdate.add(notes);   
            }
        }
        if(ElixirSuite__Notes__c.sObjectType.getDescribe().isCreateable() && notesToInsert != null){
            insert notesToInsert;
        }
        if(ElixirSuite__Notes__c.sObjectType.getDescribe().isUpdateable() && notesToUpdate != null){
            update notesToUpdate;
        }
        System.debug('HEllo '+delNoteList);
        if(delNoteList != null  && ElixirSuite__Notes__c.sObjectType.getDescribe().isDeletable()){
            System.debug('HEllo 1'+delNoteList);
          delete  delNoteList; 
        }
    }
   */
   
    //to save and update Recommendations
    /*@AuraEnabled
    public static void saveRecommendationsList(List<ElixirSuite__Recommendation__c> recommendationList,List<ElixirSuite__Recommendation__c> delRecList,List<ElixirSuite__Notes__c> noteList,List<ElixirSuite__Notes__c> delNoteList) 
    {   
        System.debug('recommendationList '+recommendationList);
        System.debug('delRecList '+delRecList);
        System.debug('noteList '+noteList);
        System.debug('delNoteList '+delNoteList);
        RecordType rt = [select id,name from RecordType where sobjecttype = 'ElixirSuite__Recommendation__c' and name='Adjustment Codes' limit 1];
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
        if(ElixirSuite__Recommendation__c.sObjectType.getDescribe().isCreateable() && recommendationsToInsert != null){
            insert recommendationsToInsert;
        }
        if(ElixirSuite__Recommendation__c.sObjectType.getDescribe().isUpdateable() && recommendationsToUpdate != null){
            update recommendationsToUpdate;
        }
        if(delRecList != null  && ElixirSuite__Recommendation__c.sObjectType.getDescribe().isDeletable()){
          delete  delRecList; 
        }
        
        System.debug('noteList '+noteList);
        System.debug('delNoteList '+delNoteList);
        RecordType ret = [select id,name from RecordType where sobjecttype = 'ElixirSuite__Notes__c' and name='Claim ERA' limit 1];
        List<ElixirSuite__Notes__c> notesToInsert = new List<ElixirSuite__Notes__c>();//List to insert Followup Notes
        List<ElixirSuite__Notes__c> notesToUpdate = new List<ElixirSuite__Notes__c>();//List to update Followup Notes
        for(ElixirSuite__Notes__c notes : noteList){
            if(notes.Id == null){
                if(notes.ElixirSuite__Elixir_Assigned_To__c != null && notes.ElixirSuite__Elixir_Follow_up_Date__c != null && notes.ElixirSuite__Follow_Up_Notes__c != null){
                notes.RecordTypeId = ret.Id;
                notesToInsert.add(notes);
                }
            }
            else
            { 
                notesToUpdate.add(notes);   
            }
        }
        if(ElixirSuite__Notes__c.sObjectType.getDescribe().isCreateable() && notesToInsert != null){
            insert notesToInsert;
        }
        if(ElixirSuite__Notes__c.sObjectType.getDescribe().isUpdateable() && notesToUpdate != null){
            update notesToUpdate;
        }
        if(delNoteList != null  && ElixirSuite__Notes__c.sObjectType.getDescribe().isDeletable()){
          delete  delNoteList; 
        }
    }*/
    
}
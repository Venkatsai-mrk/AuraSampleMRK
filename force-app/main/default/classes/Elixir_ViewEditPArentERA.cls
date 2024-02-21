/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-01-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class Elixir_ViewEditPArentERA {
    /* @AuraEnabled
    public static List<ElixirSuite__Notes__c> fetchNotes(String recId){
        List<ElixirSuite__Notes__c> followupNoteList= [Select id,ElixirSuite__Follow_Up_Notes__c,ElixirSuite__Elixir_Follow_up_Date__c,ElixirSuite__Elixir_Assigned_To__c from ElixirSuite__Notes__c where ElixirSuite__ERA_Notes__c =: recId WITH SECURITY_ENFORCED];
        return followupNoteList;
    }
    //To save and update FollowUp Notes
    @AuraEnabled
    public static void saveNoteList(List<ElixirSuite__Notes__c> noteList,List<ElixirSuite__Notes__c> delNoteList) 
    {    
        RecordType rt = [select id,name from RecordType where sobjecttype = 'ElixirSuite__Notes__c' and name='Claim ERA' WITH SECURITY_ENFORCED limit 1];
        List<ElixirSuite__Notes__c> notesToInsert = new List<ElixirSuite__Notes__c>();//List to insert Followup Notes
        List<ElixirSuite__Notes__c> notesToUpdate = new List<ElixirSuite__Notes__c>();//List to update Followup Notes
        for(ElixirSuite__Notes__c notes : noteList){
            if(notes.Id == null){
                notes.RecordTypeId = rt.Id;
                notesToInsert.add(notes);
            }
            else
            { 
                notesToUpdate.add(notes);   
            }
        }
        if(ElixirSuite__Notes__c.sObjectType.getDescribe().isCreateable() && notesToInsert != null){
            if(Schema.sObjectType.ElixirSuite__Notes__c.isCreateable() &&
            Schema.sObjectType.ElixirSuite__Notes__c.fields.RecordTypeId.isCreateable()){
            insert notesToInsert;
        }
    }
        if(ElixirSuite__Notes__c.sObjectType.getDescribe().isUpdateable() && notesToUpdate != null){
        update notesToUpdate;
        
    }
        System.debug('HEllo '+delNoteList);
        if(delNoteList != null  && ElixirSuite__Notes__c.sObjectType.getDescribe().isDeletable()){
        System.debug('HEllo 1'+delNoteList);
            delete  delNoteList; 
     }
    }*/
} 
/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-25-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
global with sharing class AppointmentCompletionBatch implements Database.Batchable<sObject>{

    global Database.QueryLocator start(Database.BatchableContext BC){
        datetime requiredDate = Date.today();
        String noShowStatus = 'No Show';
        String query='Select id,Subject,EndDateTime,ElixirSuite__Status__c from Event where EndDateTime <=: requiredDate AND ElixirSuite__Status__c !=: noShowStatus AND IsChild=false' ;
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Event> scope){
        
        if(scope.size() >0){
            for(Event ev: scope){
                ev.ElixirSuite__Status__c =  'Completed';
            }
        }
        
        if(scope.size() >0 && Schema.sObjectType.Event.isUpdateable()){
            update scope;
        }
    }
    global void finish(Database.BatchableContext BC){
    }
}
/*Author name           :  Sonal Agarwal
* Purpose               :  To automatically create Integration data records to store ERA Id for specific claims (Set 1 as batch size)
* Schedule              :  Scheduling on daily basis
* Test Class            :  
* Schedular class       :  
* Created Date          :  20-Oct-2020
* Last Modified By      :  Rohit Singh Bora
*/
global with sharing class GetERAIDBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{    
    global Database.QueryLocator start(Database.BatchableContext bc){       
        String query;
        return Database.getQueryLocator(query);
    }       
    global void execute(Database.BatchableContext BC, List<Integration_Data__c> scope){
    }
   
    global void finish(Database.BatchableContext BC){        
    }
  
}
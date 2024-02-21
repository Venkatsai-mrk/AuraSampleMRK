/* Test Class = createAttendanceRecordTest
*/
public with sharing class createAttendanceRecord {
       public static Boolean preventEditIfDeceasedCheckedOnAccount(Event[] lstRecord){
        Boolean flag = false;  
           try{
        if(DeceasedGlobalStopRecursion.run){
            Map<Id,Event> acctEventMap = new Map<Id,Event>();
            for(Event ct : lstRecord){
                acctEventMap.put(ct.WhatId ,ct);               
            }
            Event[] recordsToBlock = new List<Event>();
            Account[] acctLst = [SELECT ID,Name,ElixirSuite__Deceased__c from Account WHERE ID IN : acctEventMap.keySet() WITH SECURITY_ENFORCED];
            for(Account acc : acctLst){
                if(acc.ElixirSuite__Deceased__c){
                    flag = true;
                    recordsToBlock.add(acctEventMap.get(acc.Id));
                }
            }
            for(Event contsObj : recordsToBlock){
                contsObj.addError('This patient is deceased. You can not edit this patient record!');
            }
        }
           }
           catch(Exception e){
            ExceptionLog.logError(e);
        }
        return flag;
    }
        public class attend{
        
        public string accountId;
        public string accountName;
        public boolean attended;
        public String profilePic;
    }   
    
    public static void createRecord(List<Event> eventList){
        List<JsonData__c> attendanceRecords = new List<JsonData__c>();
        List<attend> attendList= new List<attend>();
        List<EventWhoRelation> ehr = [SELECT Id, RelationId, EventId, AccountId FROM EventWhoRelation where eventId =: eventList[0].id WITH SECURITY_ENFORCED];
        JsonData__c newAttendance = new JsonData__c();
        newAttendance.Event_Id__c=eventList[0].Id;
        system.debug('yyy'+ ehr);
        try{
        if(ehr!= null && ehr.size() >0){
        for(EventWhoRelation eh : ehr){
            Contact[] con = [Select id , name , AccountId,account.name from Contact where id =: eh.RelationId
            WITH SECURITY_ENFORCED];    
            newAttendance.Event_Id__c=eh.EventId;
            newAttendance.isChecked__c = true ;
            attend att = new attend();
            if(con.size()>0){
            att.accountId=con[0].AccountId;
            att.accountName=con[0].account.name;
            }
            att.attended=true;
            att.profilePic = ' ' ;
            attendList.add(att);
        }
        
        newAttendance.JsonData__c=JSON.serialize(attendList);
        if(Schema.sObjectType.JsonData__c.isCreateable() &&
        Schema.sObjectType.JsonData__c.fields.Event_Id__c.isCreateable() &&
        Schema.sObjectType.JsonData__c.fields.JsonData__c.isCreateable() &&
        Schema.sObjectType.JsonData__c.fields.isChecked__c.isCreateable()){
            
            insert newAttendance;
            }
        }
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
    }
    public static void updateRecord(List<Event> eventList){
        List<JsonData__c> attendanceRecords = new List<JsonData__c>();
        List<attend> attendList= new List<attend>();
        List<EventWhoRelation> ehr = [SELECT Id, RelationId, EventId, AccountId FROM EventWhoRelation where eventId =: eventList[0].id WITH SECURITY_ENFORCED];
      //  JsonData__c oldAttendace = new JsonData__c();
       JsonData__c[] oldAttendace = [SELECT id , Name , JsonData__c , Event_Id__c FROM JsonData__c WHERE Event_Id__c =: eventList[0].id WITH SECURITY_ENFORCED LIMIT 1];
        try{
        if(oldAttendace!=null && oldAttendace.size()>0){
        List<attend> attList = (List<attend>)JSON.deserialize(oldAttendace[0].JsonData__c,List<attend>.class);
        system.debug('the attliats is' + attList);
        for(EventWhoRelation eh : ehr){
            Contact[] con = [Select id , name , AccountId,account.name from Contact where id =: eh.RelationId
            WITH SECURITY_ENFORCED]; 
            attend att = new attend();
            if(con.size()>0){
            att.accountId=con[0].AccountId;
            att.accountName=con[0].account.name;
            }
            att.attended=true;
            att.profilePic = ' ';
            attendList.add(att); 
        } 
            oldAttendace[0].JsonData__c = JSON.serialize(attendList);
            if(Schema.sObjectType.JsonData__c.fields.JsonData__c.isUpdateable()){
                update oldAttendace ;
            }
        }   
        else{
            JsonData__c newAttendance1 = new JsonData__c();
        newAttendance1.Event_Id__c=eventList[0].Id;
        for(EventWhoRelation eh : ehr){
            Contact[] con = [Select id , name , AccountId,account.name from Contact where id =: eh.RelationId WITH SECURITY_ENFORCED];    
            newAttendance1.Event_Id__c=eh.EventId;
            newAttendance1.isChecked__c = true ;
            attend att = new attend();
            if(con.size()>0){
            att.accountId=con[0].AccountId;
            att.accountName=con[0].account.name;
            }
            att.attended=true;
            att.profilePic = ' ' ;
            attendList.add(att);
        }
        newAttendance1.JsonData__c=JSON.serialize(attendList);
            if(Schema.sObjectType.JsonData__c.isCreateable() && 
            Schema.sObjectType.JsonData__c.fields.Event_Id__c.isCreateable() &&
            Schema.sObjectType.JsonData__c.fields.JsonData__c.isCreateable() &&
            Schema.sObjectType.JsonData__c.fields.isChecked__c.isCreateable()){
            insert newAttendance1;
                }
            }
        }
        
        catch(Exception e){
            ExceptionLog.logError(e);
        }
    }
   
    /*public static void createRecord(List<Event> eventList){
        List<JsonData__c> attendanceRecords = new List<JsonData__c>();
        List<attend> attendList= new List<attend>();
        List<EventWhoRelation> ehr = [SELECT Id, RelationId, EventId, AccountId FROM EventWhoRelation where eventId =: eventList[0].id];
        JsonData__c newAttendance = new JsonData__c();
        newAttendance.Event_Id__c=eventList[0].Id;
        for(EventWhoRelation eh : ehr){
            Contact con = [Select id , name , AccountId,account.name from Contact where id =: eh.RelationId];    
            newAttendance.Event_Id__c=eh.EventId;
            newAttendance.isChecked__c = true ;
            attend att = new attend();
            att.accountId=con.AccountId;
            att.accountName=con.account.name;
            att.attended=False;
            attendList.add(att);
        }
        newAttendance.JsonData__c=JSON.serialize(attendList);
        insert newAttendance;
        
    }
    public static void updateRecord(List<Event> eventList){
        List<JsonData__c> attendanceRecords = new List<JsonData__c>();
        List<attend> attendList= new List<attend>();
        List<EventWhoRelation> ehr = [SELECT Id, RelationId, EventId, AccountId FROM EventWhoRelation where eventId =: eventList[0].id];
        JsonData__c oldAttendace = [SELECT id , Name , JsonData__c , Event_Id__c FROM JsonData__c WHERE Event_Id__c =: eventList[0].id LIMIT 1];
        List<attend> attList = (List<attend>)JSON.deserialize(oldAttendace.JsonData__c,List<attend>.class);
        system.debug('the attliats is' + attList);
        for(EventWhoRelation eh : ehr){
            Contact con = [Select id , name , AccountId,account.name from Contact where id =: eh.RelationId]; 
            attend att = new attend();
            att.accountId=con.AccountId;
            att.accountName=con.account.name;
            att.attended=False;
            attendList.add(att); 
        } 
        oldAttendace.JsonData__c = JSON.serialize(attendList);
        update oldAttendace ;
    }*/
}
public with sharing class scheduleVitalsCheckupApex {
    
    
    @AuraEnabled
    public static list<User> getUserNames(){
        list<User> userList=[select Id,Name From User where IsActive =true WITH SECURITY_ENFORCED];
        return userList;
    }
    
     @AuraEnabled
    public static string getURL(String accountId){
        
        String url =system.URL.getSalesforceBaseUrl().toExternalForm() ;
        
        url = url + '/'+'lightning/r/'+accountId+'/'+'related/ElixirSuite__Medical_Examinations__r/view';
        
        return url;

    }
    @AuraEnabled
    public static void saveTask(string stringifiedExaminationLst){
        
        List<Task> taskLst = new List<Task>();
        
         for(Object obj : utilityMapDeserialize(stringifiedExaminationLst,'key')){
             Map<String, Object> mapOfExaminationData = (Map<String, Object>) obj;
             Task record = new Task();
             record.OwnerId =  String.valueOf(mapOfExaminationData.get('Assignee'));
             record.WhatId = String.valueOf(mapOfExaminationData.get('AccountId'));
             record.Description = String.valueOf(mapOfExaminationData.get('Notes'));
             record.Subject = 'Scheduled '+String.valueOf(mapOfExaminationData.get('ExaminationType'));
             if(String.valueOf(mapOfExaminationData.get('ExaminationType')) =='Vital Signs'){
                 record.Subject = 'Vital Sign Checkup';
                 record.IsRecurrence = true;
                 string st = String.valueOf(mapOfExaminationData.get('StartTime'));
                 Datetime start =   (DateTime)JSON.deserialize('"' + st + '"', DateTime.class);
                 string et = String.valueOf(mapOfExaminationData.get('EndTime'));
                 Datetime endtime =  (DateTime)JSON.deserialize('"' + et + '"', DateTime.class);
                 
                 record.RecurrenceStartDateOnly = start.date();
                 record.RecurrenceEndDateOnly = endtime.date();
                 record.RecurrenceInterval =1;
                 if(String.valueOf(mapOfExaminationData.get('Frequency')) =='Once Daily'){
                     record.RecurrenceType = 'RecursDaily';
                 }
                 
             }else{
                 string et = String.valueOf(mapOfExaminationData.get('EndTime'));
                 if(et != ''){
                 Datetime endtime =  (DateTime)JSON.deserialize('"' + et + '"', DateTime.class);
                 
                 record.ActivityDate = endtime.date();
             }
             }
            taskLst.add(record); 
         } 
        system.debug('taskLst'+taskLst.size());
        if(taskLst.size() >0 && Schema.sObjectType.Task.iscreateable()){
            insert taskLst;
        }
    }

    public static  List<Object>  utilityMapDeserialize(String stringifiedJSON,String keyToGet){         
        Map<String, Object> tableLstJSON =(Map<String, Object>) JSON.deserializeUntyped(stringifiedJSON);
        return  (List<Object>) tableLstJSON.get(keyToGet);
    }  
    
   
    
}
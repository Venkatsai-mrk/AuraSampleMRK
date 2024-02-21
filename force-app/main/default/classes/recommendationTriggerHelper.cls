/*
 * Class Name  : masterObjectTriggerHelper.apxc
 * Description :Helper class for Recommendation object trigger
 * Author      :Anusha Reddy
 * 
 * */
public with sharing class recommendationTriggerHelper {
    /*
     * Method Name :updateTaskOwner
     * Params      :newMap - Holds the list of new recommendations with key as its id
     * Description :Helper method for Recommendation object trigger which handles to update owner on related task
     * Author      :Anusha Reddy
     * Story#      :LX3-5263
     * 
     * */
    public static void updateTaskOwner(Map<id,ElixirSuite__Recommendation__c> newMap,Map<id,ElixirSuite__Recommendation__c> oldMap){
        system.debug ('newMap '+newMap);
        Map<id,ElixirSuite__Recommendation__c> recommendationMap = new Map<id,ElixirSuite__Recommendation__c>([select id,ElixirSuite__Elixir_Recommendation__c,ElixirSuite__Elixir_Assign_To__c,ElixirSuite__Elixir_ERA__r.Name,ElixirSuite__Elixir_ERA__r.ElixirSuite__Claim__r.Name from ElixirSuite__Recommendation__c where id in :newMap.keySet()]); 
        List<Task> taskList =[select id,OwnerId,WhatId from task where whatId in :newMap.keySet() WITH SECURITY_ENFORCED];
        List<Task> taskToUpdate = new List<Task>();
        List<Task> taskToUpdateRecSub = new List<Task>();
        List<Task> taskTodelete=new List<Task>();
        try{
        if(taskList.size()>0){
            Map<id,Task> taskMap = new Map<id,Task>();
            for(Task eachRec:taskList){
                taskMap.put(eachRec.whatId,eachRec);
            }
            for(ElixirSuite__Recommendation__c eachRec : recommendationMap.values()){
                if(eachRec.ElixirSuite__Elixir_Assign_To__c!=null && taskMap.containsKey(eachRec.id))
                    if(taskMap!=null)
                {
                    taskMap.get(eachRec.id).OwnerId=eachRec.ElixirSuite__Elixir_Assign_To__c;
                 	system.debug('eachRec'+taskMap.get(eachRec.id).OwnerId);
                    taskToUpdate.add(taskMap.get(eachRec.id));
                }
                else{
                    taskTodelete.add(taskMap.get(eachRec.id));
                }
              String ERAName =eachRec.ElixirSuite__Elixir_ERA__r.Name; 
              System.debug('ERAName '+ERAName);  
              String ERAClaimName =eachRec.ElixirSuite__Elixir_ERA__r.ElixirSuite__Claim__r.Name;
              Integer maxSize =255;  
              String Subject = ERAName+' '+ERAClaimName+'-'+eachRec.ElixirSuite__Elixir_Recommendation__c;
                if(eachRec.ElixirSuite__Elixir_Recommendation__c !=null && eachRec.ElixirSuite__Elixir_Recommendation__c!= (oldMap.get(eachRec.id)).ElixirSuite__Elixir_Recommendation__c && taskMap.containsKey(eachRec.id)) {
                if(Subject.length() > maxSize){
                taskMap.get(eachRec.id).Subject=Subject.substring(0,255);
                }else{
                taskMap.get(eachRec.id).Subject=Subject;    
                }
                taskToUpdateRecSub.add(taskMap.get(eachRec.id));    
                } 
            }
        }
        else{
            createTask(newMap);
        }
        if(taskToUpdate.size()>0){
            if (Schema.sObjectType.Task.isUpdateable() &&

            Schema.sObjectType.Task.isCreateable()){
            upsert taskToUpdate;
        }
    }
         if(taskToUpdateRecSub.size()>0){
            if (Schema.sObjectType.Task.isUpdateable() &&

            Schema.sObjectType.Task.isCreateable()){
            upsert taskToUpdateRecSub;
        }
        if(taskTodelete.size()>0){
            //if(Schema.sObjectType.Task.isDeletable()){
                DMLManager.deleteAsUser(taskTodelete);
          //  delete taskTodelete;
       // }
        }
    }
}
        catch(Exception e){
            ExceptionLog.logError(e);
        }
    }
    public static void createTask(Map<id,ElixirSuite__Recommendation__c> newMap){
        List<Task> tasks=new List<Task>();
        Map<id,ElixirSuite__Recommendation__c> recommendationMap = new Map<id,ElixirSuite__Recommendation__c>([select id,ElixirSuite__Elixir_ERA__r.Name,ElixirSuite__Elixir_ERA__r.ElixirSuite__Claim__r.Name from ElixirSuite__Recommendation__c where id in :newMap.keySet() WITH SECURITY_ENFORCED]); 
        try{
        for(ElixirSuite__Recommendation__c r:newMap.values()){
            if(r.ElixirSuite__Elixir_Assign_To__c!=null){
				String ERAName = recommendationMap.get(r.id).ElixirSuite__Elixir_ERA__r.Name!=null?recommendationMap.get(r.id).ElixirSuite__Elixir_ERA__r.Name:'';
                String ERAClaimName = recommendationMap.get(r.id).ElixirSuite__Elixir_ERA__r.ElixirSuite__Claim__r.Name!=null?recommendationMap.get(r.id).ElixirSuite__Elixir_ERA__r.ElixirSuite__Claim__r.Name:'';
                Task t=new Task();
                Integer maxSize =255;
                String Subject = ERAName+' '+ERAClaimName+'-'+r.ElixirSuite__Elixir_Recommendation__c;
                //t.subject=ERAName+' '+ERAClaimName+'- Recommendation';
                if(Subject.length() > maxSize){
                t.subject = Subject.substring(0,255);
                }else{
                t.subject = Subject;  
                }
                t.OwnerId=r.ElixirSuite__Elixir_Assign_To__c;
                t.WhatId=r.id;
                tasks.add(t);
            }   
        }
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        if(tasks.size()>0){
            if(Schema.sObjectType.Task.isCreateable() &&
            Schema.sObjectType.Task.fields.subject.isCreateable() &&
            Schema.sObjectType.Task.fields.OwnerId.isCreateable() &&
            Schema.sObjectType.Task.fields.WhatId.isCreateable()){
            insert tasks; 
            }
        } 
    } 
}
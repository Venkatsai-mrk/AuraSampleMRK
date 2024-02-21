public with sharing class CriteriaAssignmentDeletionHelper {
    
    public static void handleSNoAfterCriteriaAssignmentDeletion(List<ElixirSuite__Criteria_Assignment__c> listofdeletedCriteriaRecord){
        Set<Id> setOfGroupId = new set<Id>();
        
        List<ElixirSuite__Criteria_Assignment__c> listOfCriteriaAssignmentToUpdate = new List<ElixirSuite__Criteria_Assignment__c>();
        for(ElixirSuite__Criteria_Assignment__c deletedRecord: listofdeletedCriteriaRecord){
            try{
            if(deletedRecord.ElixirSuite__Account_Group__c!=null){
                setOfGroupId.add(deletedRecord.ElixirSuite__Account_Group__c);
            }
        } 
        
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        }
        try{
        if(setOfGroupId!=null && setOfGroupId.size() >0){
            List<ElixirSuite__Account_Group__c> listOfParentGroup = [SELECT Id, Name, ElixirSuite__Is_Active__c,(select id,name,ElixirSuite__S_No__c from ElixirSuite__Criteria_Assignments__r order by createdDate asc) FROM ElixirSuite__Account_Group__c WITH SECURITY_ENFORCED];
            
            if(listOfParentGroup.size() >0){
                for(ElixirSuite__Account_Group__c parentRecord: listOfParentGroup){
                    if(parentRecord.ElixirSuite__Criteria_Assignments__r.size() >0){
                        integer count =1;
                        for(ElixirSuite__Criteria_Assignment__c childRecord: parentRecord.ElixirSuite__Criteria_Assignments__r){
                            childRecord.ElixirSuite__S_No__c = count;
                            
                            listOfCriteriaAssignmentToUpdate.add(childRecord);
                            count++;
                        }
                    }
                }
            }
        }
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        if(listOfCriteriaAssignmentToUpdate.size() >0){
        if(Schema.sObjectType.ElixirSuite__Criteria_Assignment__c.isUpdateable() &&
        Schema.sObjectType.ElixirSuite__Criteria_Assignment__c.fields.ElixirSuite__S_No__c.isUpdateable()){   
            update listOfCriteriaAssignmentToUpdate;
            }
        }
    }
}
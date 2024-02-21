Global with sharing virtual class GlobalCriteriaAssignmentDeletionHelper {
    global virtual void afterDelete(List<ElixirSuite__Criteria_Assignment__c> listofdeletedRecords){
         CriteriaAssignmentDeletionHelper.handleSNoAfterCriteriaAssignmentDeletion(listofdeletedRecords);

    }
}
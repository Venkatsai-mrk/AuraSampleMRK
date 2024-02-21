trigger CriteriaAssignmentDeletionTrigger on ElixirSuite__Criteria_Assignment__c (after delete) {
    if(System.FeatureManagement.checkPermission('DataMigration')) return;  //LX3-6835 - Bypass the trigger execution during data migration
    
   // CriteriaAssignmentDeletionHelper.handleSNoAfterCriteriaAssignmentDeletion(trigger.old);
   String virtualClassName = 'GlobalCriteriaAssignmentDeletionHelper';// Added in Review
    List<Elixir_Pluggable_Classes__mdt> pluggableClass = new List<Elixir_Pluggable_Classes__mdt>();
    pluggableClass = [SELECT
                    DeveloperName,
                    Virtual_Class__c
                    FROM Elixir_Pluggable_Classes__mdt
                    WHERE DeveloperName='CriteriaAssignmentDeletionTrigger'
                    WITH SECURITY_ENFORCED];
    if(!pluggableClass.isEmpty()){
        virtualClassName = pluggableClass[0].Virtual_Class__c;
    }
    Type t = Type.forName(virtualClassName);
    GlobalCriteriaAssignmentDeletionHelper criteriaAssignment = (GlobalCriteriaAssignmentDeletionHelper) t.newInstance(); 
    criteriaAssignment.afterDelete(trigger.old);
}
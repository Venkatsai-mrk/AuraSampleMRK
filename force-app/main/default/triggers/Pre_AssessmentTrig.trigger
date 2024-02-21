trigger Pre_AssessmentTrig on Pre_Assessment__c (after insert,after update,before insert,before update,before delete) {
    if(System.FeatureManagement.checkPermission('DataMigration')) return;  //LX3-6835 - Bypass the trigger execution during data migration
    
    String virtualClassName = 'GlobalVirtualPre_AssessmentTrig';// Added in Review
    List<Elixir_Pluggable_Classes__mdt> pluggableClass = new List<Elixir_Pluggable_Classes__mdt>();
    pluggableClass = [SELECT
                    DeveloperName,
                    Virtual_Class__c
                    FROM Elixir_Pluggable_Classes__mdt
                    WHERE DeveloperName='Pre_AssessmentTrig'
                    WITH SECURITY_ENFORCED];
    if(!pluggableClass.isEmpty()){
        virtualClassName = pluggableClass[0].Virtual_Class__c;
                }
    Type t = Type.forName(virtualClassName);
    GlobalVirtualPre_AssessmentTrig pre_AssessmentObj = (GlobalVirtualPre_AssessmentTrig) t.newInstance(); 
    
    if(trigger.isBefore && trigger.isInsert){
        pre_AssessmentObj.beforeInsert(trigger.new);//beforeInsert new
            }
    if(trigger.isBefore && trigger.isUpdate){
        pre_AssessmentObj.beforeUpdate(trigger.new);//beforeUpdate new
            }
    if(trigger.isBefore && Trigger.isDelete){ 
        pre_AssessmentObj.beforeDelete(trigger.old);//beforeDelete old 
            }
    if(trigger.isAfter && trigger.isInsert){
        pre_AssessmentObj.afterInsert(trigger.new);
        }
    if(trigger.isAfter && trigger.isUpdate){
        pre_AssessmentObj.afterUpdate(trigger.new, trigger.oldMap);
    }
}
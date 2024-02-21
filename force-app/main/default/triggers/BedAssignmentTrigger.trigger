trigger BedAssignmentTrigger on ElixirSuite__Reservation_Line_Item__c (before insert, before Update, after Update) {
     if(System.FeatureManagement.checkPermission('DataMigration')) return; //LX3-6835 - Bypass the trigger execution during data migration
 String virtualClassName = 'GlobalBedAssignmentHelper';
    List<Elixir_Pluggable_Classes__mdt> pluggableClass = new List<Elixir_Pluggable_Classes__mdt>();
    pluggableClass = [SELECT
                    DeveloperName,
                    Virtual_Class__c
                    FROM Elixir_Pluggable_Classes__mdt
                    WHERE DeveloperName='BedAssignmentTrigger'
                    WITH SECURITY_ENFORCED];
    if(!pluggableClass.isEmpty()){
        virtualClassName = pluggableClass[0].Virtual_Class__c;
    }
    Type t = Type.forName(virtualClassName);
    GlobalBedAssignmentHelper assignBedsHelper = (GlobalBedAssignmentHelper) t.newInstance(); 
    if(Trigger.isBefore && Trigger.isUpdate){ 
        assignBedsHelper.beforeUpdate(Trigger.new, Trigger.oldMap);
    }
    if(trigger.isAfter && trigger.isUpdate){
        assignBedsHelper.afterUpdate(trigger.old, trigger.new);
     }
}
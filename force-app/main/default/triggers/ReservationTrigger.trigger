trigger ReservationTrigger on ElixirSuite__Reservation__c (before insert, before Update, after insert, after update) {
if(System.FeatureManagement.checkPermission('DataMigration')) return; //LX3-6835 - Bypass the trigger execution during data migration
 String virtualClassName = 'GlobalReservationTrigger';
    List<Elixir_Pluggable_Classes__mdt> pluggableClass = new List<Elixir_Pluggable_Classes__mdt>();
    pluggableClass = [SELECT
                    DeveloperName,
                    Virtual_Class__c
                    FROM Elixir_Pluggable_Classes__mdt
                    WHERE DeveloperName='ReservationTrigger'
                    WITH SECURITY_ENFORCED];
    if(!pluggableClass.isEmpty()){
        virtualClassName = pluggableClass[0].Virtual_Class__c;
    }
    Type t = Type.forName(virtualClassName);
    GlobalReservationTrigger reservation = (GlobalReservationTrigger) t.newInstance(); 
    if(Trigger.isBefore && Trigger.isUpdate){ 
        reservation.beforeUpdate(Trigger.new, Trigger.oldMap);
    }
    if(trigger.isAfter && trigger.isUpdate){
        reservation.afterUpdate(trigger.old, trigger.new);
     }
}
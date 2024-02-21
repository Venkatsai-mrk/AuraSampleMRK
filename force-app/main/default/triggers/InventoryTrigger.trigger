trigger InventoryTrigger on ElixirSuite__Inventory__c (after insert) {
    if(System.FeatureManagement.checkPermission('DataMigration')) return; //LX3-6835 - Bypass the trigger execution during data migration
   /* if(trigger.isAfter && trigger.isInsert){
        ProcedureCodeClass.insertProcedureCode(Trigger.New);
    }*/
    String virtualClassName = 'GlobalProcedureCodeClass';// Added in Review
    List<Elixir_Pluggable_Classes__mdt> pluggableClass = new List<Elixir_Pluggable_Classes__mdt>();
    pluggableClass = [SELECT
                    DeveloperName,
                    Virtual_Class__c
                    FROM Elixir_Pluggable_Classes__mdt
                    WHERE DeveloperName='InventoryTrigger'
                    WITH SECURITY_ENFORCED];
    if(!pluggableClass.isEmpty()){
        virtualClassName = pluggableClass[0].Virtual_Class__c;
    }
    Type t = Type.forName(virtualClassName);
    GlobalProcedureCodeClass procedureCode = (GlobalProcedureCodeClass) t.newInstance(); 
    
    if(trigger.isAfter && trigger.isInsert){ //Code Added By Rohit
        procedureCode.afterInsert(trigger.new);
    }
    
    
}
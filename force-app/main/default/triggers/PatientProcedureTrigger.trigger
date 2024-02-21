trigger PatientProcedureTrigger on Procedure__c (before insert, before update, after insert, after update) {
    if(System.FeatureManagement.checkPermission('DataMigration')) return; //LX3-6835 - Bypass the trigger execution during data migration
    
    String virtualClassName = 'GlobalPatientProcedureTriggerHelper';// Added by Himanshu
    List<Elixir_Pluggable_Classes__mdt> pluggableClass = new List<Elixir_Pluggable_Classes__mdt>();
    pluggableClass = [SELECT
                    DeveloperName,
                    Virtual_Class__c
                    FROM Elixir_Pluggable_Classes__mdt
                    WHERE DeveloperName='PatientProcedureTrigger'
                    WITH SECURITY_ENFORCED];
    if(!pluggableClass.isEmpty()){
        virtualClassName = pluggableClass[0].Virtual_Class__c;	
    }
    Type t = Type.forName(virtualClassName);
    GlobalPatientProcedureTriggerHelper patientProcedureObj = (GlobalPatientProcedureTriggerHelper) t.newInstance();
    
    if(trigger.isBefore && trigger.isInsert){
        patientProcedureObj.beforeInsert(trigger.new);
    }
    if(trigger.isBefore && trigger.isUpdate){
        patientProcedureObj.beforeUpdate(trigger.new, trigger.oldMap);
    }
    if(trigger.isAfter && trigger.isInsert){
        patientProcedureObj.afterInsert(trigger.new);
    }
    if(trigger.isAfter && trigger.isUpdate){
        patientProcedureObj.afterUpdate(trigger.new);
    }
    
    
    
    
    
    /*if(trigger.isBefore){//These 2 events will update the charge field on procedure
        if(trigger.isInsert){
            CreatePaymentTransaction.updateCharges(trigger.new,null,true, false);
        }
        if( trigger.isUpdate){
         CreatePaymentTransaction.updateCharges(trigger.new,trigger.oldMap,false, true);   
        }
    }  
    if(trigger.isAfter){
        if(trigger.isInsert){
            CreatePaymentTransaction.afterProcedureInsertCharges(trigger.new);
        }else if(trigger.isUpdate){
            CreatePaymentTransaction.afterProcedureupdation(trigger.new);
        }
    }*/   
}
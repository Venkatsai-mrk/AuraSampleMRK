trigger MedExamintion_trg on ElixirSuite__Medical_Examination__c (after insert,after update,before insert,before update) 
{
    if(System.FeatureManagement.checkPermission('DataMigration')) return;  //LX3-6835 - Bypass the trigger execution during data migration
   /* if(Trigger.IsInsert)
    {
        MedExam_Handler.createProcMed(Trigger.new);
    }
    if(Trigger.IsUpdate)
    {
        MedExam_Handler.updateProcMed(Trigger.new);
    }
    if((Trigger.isBefore && Trigger.isInsert) || (Trigger.isBefore && Trigger.isUpdate)){
        
        MedExam_Handler.populateCareEpisode(Trigger.new);
       // MedicalExaminationTriggerUtility.populateRecordType(Trigger.new);
      //  MedicalExaminationTriggerUtility.populateVitalUnits(Trigger.new);
      //  MedicalExaminationTriggerUtility.preventEndDateLessThanStartDate(Trigger.new);
    }*/
    String virtualClassName = 'GlobalMedicalExaminationHelper';
    List<Elixir_Pluggable_Classes__mdt> pluggableClass = new List<Elixir_Pluggable_Classes__mdt>();
    pluggableClass = [SELECT
                    DeveloperName,
                    Virtual_Class__c
                    FROM Elixir_Pluggable_Classes__mdt
                    WHERE DeveloperName='MedExamintion_trg'
                    WITH SECURITY_ENFORCED];
    if(!pluggableClass.isEmpty()){
        virtualClassName = pluggableClass[0].Virtual_Class__c;
    }
    Type t = Type.forName(virtualClassName);
    GlobalMedicalExaminationHelper medExamination = (GlobalMedicalExaminationHelper) t.newInstance(); 
    
    if(trigger.isAfter && trigger.isInsert){
        medExamination.medExaminationInsert(trigger.new);
    }
    if(trigger.isAfter && trigger.isUpdate){
        medExamination.medExaminationUpdate(trigger.new);
    }
    if(Trigger.isBefore && Trigger.isInsert){ 
        medExamination.medExaminationModify(trigger.new);
    }
    if(Trigger.isBefore && Trigger.isUpdate){ 
        medExamination.medExaminationModify(trigger.new);
    }
    
}
trigger SavePdfReport on Test_Result_Detail__c (after insert, before insert , before update) {
    if(System.FeatureManagement.checkPermission('DataMigration')) return; //LX3-6835 - Bypass the trigger execution during data migration
           
    if(trigger.isAfter && trigger.isInsert){
    String virtualClassName = 'GlobalSavePdfReport';
    List<Elixir_Pluggable_Classes__mdt> pluggableClass = new List<Elixir_Pluggable_Classes__mdt>();
    pluggableClass = [SELECT
                      DeveloperName,
                      Virtual_Class__c
                      FROM Elixir_Pluggable_Classes__mdt
                      WHERE DeveloperName='SavePdfReport'
                      WITH SECURITY_ENFORCED];
    if(!pluggableClass.isEmpty()){
        virtualClassName = pluggableClass[0].Virtual_Class__c;
        }
    Type t = Type.forName(virtualClassName);
    GlobalSavePdfReport savePdfReportCls = (GlobalSavePdfReport) t.newInstance(); 
    savePdfReportCls.afterInsert(Trigger.New);
    }

     if (Trigger.isBefore) {
        if (Trigger.isInsert || Trigger.isUpdate) {
            List<ElixirSuite__Test_Result_Detail__c> testResult= new List<ElixirSuite__Test_Result_Detail__c>();
            for(ElixirSuite__Test_Result_Detail__c d: Trigger.new){
                testResult.add(d);
            }
            ApplyScaleOnInsertAndUpdateHelper.applyScale(testResult);
        }
    }
}
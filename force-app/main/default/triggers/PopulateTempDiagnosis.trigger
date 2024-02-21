trigger PopulateTempDiagnosis on ElixirSuite__ICD_Codes__c (before insert, before update) {

   // PopulateTempDiagnosisHelper.updateTemplateDiagnosisInfo(Trigger.New);
    String virtualClassName = 'GlobalTempDiagnosisHelper';// Added in Review
    List<Elixir_Pluggable_Classes__mdt> pluggableClass = new List<Elixir_Pluggable_Classes__mdt>();
    pluggableClass = [SELECT
                    DeveloperName,
                    Virtual_Class__c
                    FROM Elixir_Pluggable_Classes__mdt
                    WHERE DeveloperName='PopulateTempDiagnosis'
                    WITH SECURITY_ENFORCED];
    if(!pluggableClass.isEmpty()){
        virtualClassName = pluggableClass[0].Virtual_Class__c;
    }
    Type t = Type.forName(virtualClassName);
    GlobalTempDiagnosisHelper tempDiagnosisLst = (GlobalTempDiagnosisHelper) t.newInstance(); 
    
    tempDiagnosisLst.beforeModifications(trigger.new);
}
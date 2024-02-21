trigger PopulateInfoInPatientProblem on ElixirSuite__Dataset1__c (before insert) {
    
  //  PopulateInfoInPatientProblemHelper.updateTemplateProblemInfo(Trigger.New);
   String virtualClassName = 'GlobalPopulateInfoHelper';// Added in Review
    List<Elixir_Pluggable_Classes__mdt> pluggableClass = new List<Elixir_Pluggable_Classes__mdt>();
    pluggableClass = [SELECT
                    DeveloperName,
                    Virtual_Class__c
                    FROM Elixir_Pluggable_Classes__mdt
                    WHERE DeveloperName='PopulateInfoInPatientProblem'
                    WITH SECURITY_ENFORCED];
    if(!pluggableClass.isEmpty()){
        virtualClassName = pluggableClass[0].Virtual_Class__c;
    }
    Type t = Type.forName(virtualClassName);
    GlobalPopulateInfoHelper patientProblemLst = (GlobalPopulateInfoHelper) t.newInstance(); 
    
    patientProblemLst.beforeInsert(trigger.new);
    
}
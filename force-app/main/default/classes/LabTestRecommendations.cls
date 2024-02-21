public with sharing class LabTestRecommendations {
    
    @AuraEnabled(cacheable=true)
    public static List<Test__c> testsBasedOnDiagnosis(String accountid, String labId)
    {
        //Fetch patient diagnosis codes associated to an account
        Id recordTypeId =   Schema.SObjectType.ElixirSuite__ICD_Codes__c.getRecordTypeInfosByDeveloperName().get('Patient_Diagnosis_Code').getRecordTypeId();
        List<ElixirSuite__ICD_Codes__c> diagnosisCode = [Select id, Name from ElixirSuite__ICD_Codes__c where Account__c =:accountid AND recordTypeId = :recordTypeId WITH SECURITY_ENFORCED];
        
        //Set to store Code label
        Set<String> diagnosisNames = new Set<String>();
        for(ElixirSuite__ICD_Codes__c patientDiannosis : diagnosisCode)
        {
            diagnosisNames.add(patientDiannosis.Name);
        }
        
        //Fetch Template diagnosis codes with same code label 
        Id recordTypeId2 =   Schema.SObjectType.ElixirSuite__ICD_Codes__c.getRecordTypeInfosByDeveloperName().get('Template_Diagnosis_Code').getRecordTypeId();
        List<ElixirSuite__ICD_Codes__c> tempDiagnosis = [Select id from ElixirSuite__ICD_Codes__c where Name IN:diagnosisNames AND recordTypeId = :recordTypeId2 WITH SECURITY_ENFORCED];
        
        //Set for storing Template diagnosis codes Ids
        Set<String> dId = new Set<string>();
        for(ElixirSuite__ICD_Codes__c dCode : tempDiagnosis){
            dId.add(dCode.Id);
        }
        system.debug(dId);
        
        /*Id recordTypeId2 = Schema.SObjectType.ElixirSuite__Procedure__c.getRecordTypeInfosByDeveloperName().get('Template_Procedure').getRecordTypeId();
        List<ElixirSuite__Procedure__c> procedureCodes = [SELECT ID,ElixirSuite__ICD_Codes__c  FROM ElixirSuite__Procedure__c WHERE Account__c =:accountid AND ElixirSuite__ICD_Codes__c IN:dId AND recordTypeId =:recordTypeId2 WITH SECURITY_ENFORCED];
        
        for(ElixirSuite__Procedure__c pCode : procedureCodes){
            //pId.add(pCode.ElixirSuite__ICD_Codes__c);
        }*/
        
        //Lab Test Bundles related to selected LAB
        List<ElixirSuite__Lab_Test_Bundle__c> labBundles = [Select id, ElixirSuite__Procedure_Codes_SF_Ids__c, ElixirSuite__Diagnosis_Codes_SF_Ids__c,ElixirSuite__Lab_Tests_SF_Ids__c, Name 
                                                            from ElixirSuite__Lab_Test_Bundle__c 
                                                            where Lab__r.Lab_Id__c =:labId WITH SECURITY_ENFORCED];
        system.debug(labBundles);
        system.debug(labBundles.size());
        Set<String> dvalue = new Set<String>();
        
        //Comparing diagnosis codes and getting the test ids 
        
        if(labBundles.size()>0){
            for(ElixirSuite__Lab_Test_Bundle__c lCode :labBundles){

                List<String> diagValues = new List<String>();
               // List<String> procValues = new List<String>();
                
                diagValues = lCode.ElixirSuite__Diagnosis_Codes_SF_Ids__c.split(';');
                //procValues = lCode.ElixirSuite__Procedure_Codes_SF_Ids__c.split(';');
                
                system.debug('After Split    '+diagValues);
                for(String s : diagValues){
                    if(dId.contains(s)){
                        
                        dvalue.addAll(lCode.ElixirSuite__Lab_Tests_SF_Ids__c.split(';'));
                        
                        system.debug(lCode.Id);
                        break;
                    }   
                }
                
            }
            system.debug(dvalue.size());
        }
        
        //Getting tests needed to configure on screen
        List<Test__c> tests2 = [SELECT Id, Test_Id__c, Test_Name__c, Test_Description__c, Lab_Id__c FROM Test__c where ID IN:dvalue AND Lab_Id__c =:labId WITH SECURITY_ENFORCED];
    	system.debug(tests2);
        return tests2;
        
    }
}
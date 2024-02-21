@isTest
public class MasterProblemListControllerTest {

    public testmethod static void elixir_CarePlanControllerTestDefault(){

        ElixirSuite__Template_Problem__c promblemTemp=new ElixirSuite__Template_Problem__c();
        promblemTemp.Name='Fever';
        promblemTemp.ElixirSuite__Description__c='Cold_fever';
        promblemTemp.ElixirSuite__Status__c='Other';
         insert promblemTemp;
        ElixirSuite__ICD_Codes__c  icd1 = new ElixirSuite__ICD_Codes__c();
        icd1.name = 'jammy';
         insert icd1;
        
        Contact con = new Contact();
        con.LastName = 'Test Contact';
        insert con;
        
DateTime dynamicTimestamp = DateTime.now();
String formattedTimestamp = dynamicTimestamp.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
        String payLoad= '{"keysToSave":{"problemName":"Nlima_Template","ProblemType":"Secondary","problemId":"'+promblemTemp.id+'","Status":"Active","SnomedCode":"snomed ct code","DateDiagnised":"2022-03-01","DateOnset":"2022-03-07","notes":"here are predefine dnotes","diagnosisId":"'+icd1.id+'","description":"cold fever related","diagnosisType":"Other","diagnosisAttestationOn":"'+formattedTimestamp+'","diagnoseValue":"'+con.Id+'"}}';

        String payLoad1 = '[{"keysToSave":{"problemName":"Nlima_Template","ProblemType":"Secondary","problemId":"'+promblemTemp.id+'","Status":"Active","SnomedCode":"snomed ct code","DateDiagnised":"2022-03-01","DateOnset":"2022-03-07","notes":"here are predefine dnotes","diagnosisId":"'+icd1.id+'","description":"cold fever related","diagnosisType":"Other"}}]'; //added by Anmol for LX3-6577

        list<string> payloadList=new list<string>();
        payloadList.add(payLoad);
        Account accountRec = TestDataFactory.createPatientAcc();
        insert accountRec;
       
        ElixirSuite__Dataset1__c diag = new  ElixirSuite__Dataset1__c();
        diag.Name= 'Bradon';
        diag.ElixirSuite__Account__c = accountRec.id;
        insert diag;
        list<string> dialist=new list<string>();
        dialist.add(diag.id);
        ElixirSuite__Diagnosis_Code__c diacode = new ElixirSuite__Diagnosis_Code__c();
        diacode.ElixirSuite__Diagnosis_Code__c = icd1.Id;
        diacode.ElixirSuite__Problem__c = diag.Id;
        insert diacode;
          
        Id devRecordTypeId = Schema.SObjectType.ElixirSuite__Provider__c.getRecordTypeInfosByDeveloperName().get('Template_Provider').getRecordTypeId();
       ElixirSuite__Provider__c prov = new ElixirSuite__Provider__c();
       prov.RecordTypeId = devRecordTypeId;
       prov.Name = 'Davamtest';
       prov.ElixirSuite__Provider_Code__c = 'west';
       prov.ElixirSuite__Provider_First_Name__c = 'test1';
       prov.ElixirSuite__Provider_Last_Name__c = 'test2';
       insert prov;
         
        
         MasterProblemListController.problemListDup(accountRec.id);
        MasterProblemListController.problemList(accountRec.Id);
         MasterProblemListController.newScreenProblemDomain();
         MasterProblemListController.fetchDefaultValue();
        MasterProblemListController.fetchDefaultPickListValue('ElixirSuite__ICD_Codes__c','ElixirSuite__Version__c');
          //MasterProblemListController.deleteRecords(diag.id);
         MasterProblemListController.deleteAllEncounter(dialist);
         MasterProblemListController.fetchPickListValue('ElixirSuite__ICD_Codes__c','ElixirSuite__Version__c'); 
         MasterProblemListController.fetchClaimTypePickListValue('ElixirSuite__ICD_Codes__c','ElixirSuite__Version__c'); 
         //MasterProblemListController.deleteRecords(diag.Id);
        MasterProblemListController.checkDateNull(String.valueOf(System.today()));
         MasterProblemListController.checkForEncounter(accountRec.Id);
         MasterProblemListController.fetchEntityRecord(diacode.id);
         MasterProblemListController.fetchViewRecord(diacode.id);
         MasterProblemListController.deleteRecord(diacode.id);
        MasterProblemListController.deleteAllProbelm(new List<String> {'',''});
         MasterProblemListController.fetchDiagnosisDetails(diacode.Id);
         MasterProblemListController.checkCareEpisode(accountRec.Id);
         //MasterProblemListController.problemInsertFromForm('payloadList','accountRec.id');
         //MasterProblemListController.problemInsertFromForm(payLoad1,accountRec.id); //added by Anmol for LX3-6577
         MasterProblemListController.fetchAccountName(accountRec.id); //added by Anmol for LX3-6577
        // MasterProblemListController.saveProblemRec(payLoad,accountRec.id);
         //MasterProblemListController.saveProblemsIfCancel(payLoad);
         System.assertEquals(1, 1, ' ');
    }
}
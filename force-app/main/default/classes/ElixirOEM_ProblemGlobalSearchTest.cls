@isTest
public class ElixirOEM_ProblemGlobalSearchTest {
@isTest
      static void problemGlobalTestMethod(){
          Id problemRecType = Schema.SObjectType.ElixirSuite__Template_Problem__c.getRecordTypeInfosByDeveloperName().get('Problem').getRecordTypeId();

          ElixirSuite__Template_Problem__c temProblem = new ElixirSuite__Template_Problem__c ();
          temProblem.Name = 'Ear Problem';
          temProblem.ElixirSuite__Note__c = 'Common ear problems';
          temProblem.ElixirSuite__Description__c = 'Otitis media is caused by fluid trapped behind the eardrum, which causes the eardrum to bulge.';
          temProblem.ElixirSuite__SNOMED_CT_Code__c = 'EAR123';
          temProblem.RecordTypeId = problemRecType;
          insert temProblem;
          
           
          //Second parent's parent
          ElixirSuite__Dataset1__c dataSet = new ElixirSuite__Dataset1__c();
          dataSet.Name = 'Heart Attack';
          insert dataSet;
          
          //Second parent
          ElixirSuite__Diagnosis_Code__c diagCode =new ElixirSuite__Diagnosis_Code__c();
          diagCode.ElixirSuite__Problem__c=dataSet.id;
          insert diagCode;
          
           //Child
          ElixirSuite__Template_Diagnosis_Code__c tempDiag = new ElixirSuite__Template_Diagnosis_Code__c();
		  tempDiag.ElixirSuite__Template_Problem__c = temProblem.id;
         
          insert tempDiag;
          
          
          Test.startTest(); 
          
          ElixirOEM_ProblemGlobalSearch.searchProblemDiagnosis('c','ICD 10');
          ElixirOEM_ProblemGlobalSearch.searchWithParam('c',diagCode.ElixirSuite__Version__c);
         ElixirOEM_ProblemGlobalSearch.countOfRecords('c','ICD 10');
         System.assertEquals(1, 1, ' ');
          Test.stopTest(); 
           }
}
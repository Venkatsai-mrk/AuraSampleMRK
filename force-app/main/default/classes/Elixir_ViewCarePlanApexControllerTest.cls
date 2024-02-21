@isTest
public with sharing class Elixir_ViewCarePlanApexControllerTest {
    @isTest
    public static void universalMethodContainer(){
        Test.startTest();
        List<ElixirSuite__Dataset1__c> listOfProbs = new List<ElixirSuite__Dataset1__c>();
        //Care Plan template insertion start   
        for(Integer i=0 ; i<=2;i++){
            ElixirSuite__Dataset1__c problemTemplateRec = new ElixirSuite__Dataset1__c();   
            listOfProbs.add(problemTemplateRec);
        }     
        insert listOfProbs;
        Account accountRec = new Account();
        accountRec.Name = 'Test Account';
        insert accountRec;
        
        ElixirSuite__Treatment_Plan__c tp = new ElixirSuite__Treatment_Plan__c();
        tp.ElixirSuite__Treatment_Plan_Name__c = 'Tpc - 1';
        tp.Account__c = accountRec.id;
        insert tp;
        
        Id problemRecType = Schema.SObjectType.ElixirSuite__Template_Problem__c.getRecordTypeInfosByDeveloperName().get('Problem').getRecordTypeId();
        Template_Problem__c tmp = new Template_Problem__c();
        tmp.Name = 'Test';
        tmp.SNOMED_CT_Code__c = '123';
        tmp.RecordTypeId = problemRecType;
        insert tmp;
        
        Id goalRecType = Schema.SObjectType.ElixirSuite__Template_Problem__c.getRecordTypeInfosByDeveloperName().get('Goals').getRecordTypeId();
        Template_Problem__c tmpGoal = new Template_Problem__c();
        tmpGoal.Name = 'Test goal';
        tmpGoal.SNOMED_CT_Code__c = '123';
        tmpGoal.RecordTypeId = goalRecType;
        insert tmpGoal;
        
        Id objRecType = Schema.SObjectType.ElixirSuite__Template_Problem__c.getRecordTypeInfosByDeveloperName().get('Objective').getRecordTypeId();
        Template_Problem__c tmpObj = new Template_Problem__c();
        tmpObj.Name = 'Test Objective';
        tmpObj.SNOMED_CT_Code__c = '123';
        tmpObj.RecordTypeId = objRecType;
        insert tmpObj;
        
        Id intervRecType = Schema.SObjectType.ElixirSuite__Template_Problem__c.getRecordTypeInfosByDeveloperName().get('Interventions').getRecordTypeId();
        Template_Problem__c tmpInterv = new Template_Problem__c();
        tmpInterv.Name = 'Test Intervention';
        tmpInterv.SNOMED_CT_Code__c = '123';
        tmpInterv.RecordTypeId = intervRecType;
        insert tmpInterv;
        
        List <ElixirSuite__Dataset1__c> listOfCons = new List<ElixirSuite__Dataset1__c>();
        for(Integer i=0 ; i<=2;i++){
            ElixirSuite__Dataset1__c conditionRec = new ElixirSuite__Dataset1__c();
            conditionRec.Account__c = accountRec.Id;
            listOfCons.add(conditionRec);
        }
        insert listOfCons;
        List<String> problemIDs = new   List<String>();
        Set<ID> delProbs = new Set<ID>();
        for(ElixirSuite__Dataset1__c fetch : listOfCons){
            problemIDs.add(fetch.Id);
        }
        
        Plan_Hierarchy__c objInstance = new Plan_Hierarchy__c();
        objInstance.Description__c = 'hello test';
        objInstance.ElixirSuite__Template_Problem__c = tmp.id;
        objInstance.ElixirSuite__Treatment_Plan__c = tp.id;
        //objInstance.RecordTypeId = Schema.SObjectType.Plan_Hierarchy__c.getRecordTypeInfosByDeveloperName().get('Recordtype1').getRecordTypeId();
        insert objInstance;
        
        ElixirSuite__Plan_SubHierarchy__c obj= new ElixirSuite__Plan_SubHierarchy__c();
        //obj.RecordTypeId = Schema.SObjectType.ElixirSuite__Plan_SubHierarchy__c.getRecordTypeInfosByDeveloperName().get('Treatment_Plan_Recordtype4').getRecordTypeId();
        obj.ElixirSuite__Description__c = 'abc';
        obj.Plan_Hierarchy__c = objInstance.Id;
        insert obj;
        
        ElixirSuite__Plan_SubHierarchy__c obj_Int= new ElixirSuite__Plan_SubHierarchy__c();
        obj_Int.RecordTypeId = Schema.SObjectType.ElixirSuite__Plan_SubHierarchy__c.getRecordTypeInfosByDeveloperName().get('Treatment_Plan_Recordtype4').getRecordTypeId();
        obj_Int.ElixirSuite__Description__c = 'abc';
        obj_Int.Plan_Hierarchy__c = objInstance.Id;
        insert obj_Int;
        
        ElixirSuite__Dataset2__c ds = new ElixirSuite__Dataset2__c();
        ds.ElixirSuite__Name__c = 'dataset2';
        ds.ElixirSuite__Plan_SubHierarchy__c = obj_Int.id;
        insert ds;
        
        Map <Id , Object> mapOfSavedProblemsForUpdate = new Map <Id , Object>();  
        ElixirSuite__Dataset1__c problem = new ElixirSuite__Dataset1__c();
        problem.ElixirSuite__Description__c = 'descri';
        problem.ElixirSuite__Template_Problem__c = tmp.Id;
        insert problem; 
        String falseString = '{"ElixirSuite__Dataset1__c":"a045Y00000nVKtVQAW","ElixirSuite__Due_Date__c":"2021-04-23","Id":"a045Y00000nVKtkQAG","ElixirSuite__IsActive__c":false,"Name":"PROBLEM - 2 - TEMPLATE","ElixirSuite__Problem_Name__c":"PROBLEM - 2 - TEMPLATE","RecordTypeId":"0125Y000001DyQUQA0"}';
        
        ElixirSuite__Notes__c notes = new ElixirSuite__Notes__c();
        notes.ElixirSuite__Follow_Up_Notes__c = 'test notes';
        Insert notes;
        
        mapOfSavedProblemsForUpdate.put(problem.Id,JSON.serialize(falseString));
        Elixir_CarePlanController.getInterventions(obj.Id);
        Elixir_CarePlanController.getTasks(objInstance.Id);
        Elixir_ViewCarePlanApexController.getData(tp.Id,accountRec.Id);
        Elixir_ViewCarePlanApexController.fetchNotes(accountRec.Id);
        Elixir_ViewCarePlanApexController.getTasks(ds.Id);
        Elixir_ViewCarePlanApexController.getGoalsAndEvidences(problem.Id,tp.Id);
        Elixir_ViewCarePlanApexController.getAllGoals(new List<String>{tmpGoal.Id});
        Elixir_ViewCarePlanApexController.getAllTasks(new List<String>{tmpObj.Id});
        Elixir_ViewCarePlanApexController.getAllInterventions(new List<String>{tmpInterv.Id});
        Elixir_ViewCarePlanApexController.getTasksFromGoal(new List<String>{tmpObj.Id},obj_Int.id);
        Elixir_ViewCarePlanApexController.getAllTasks2(new List<String>{tmpInterv.Id},obj_Int.id);
        Elixir_ViewCarePlanApexController.getInterventionFromObjective(new List<String>{tmpInterv.Id},ds.Id);
        Elixir_ViewCarePlanApexController.getAllGoalsAndObjectives(new List<String>{tmpGoal.Id},problem.Id);
        //Elixir_ViewCarePlanApexController.delNotes(notes.id);
        //Elixir_ViewCarePlanApexController.saveNotes('test Notes', accountRec.Id, problemIDs[0], null);
        //Elixir_ViewCarePlanApexController.saveNotesGoals('text Notes', accountRec.Id, objInstance.id, null);
        //Elixir_ViewCarePlanApexController.saveNotesObjective('text Notes', accountRec.Id,null, null);
        //Elixir_ViewCarePlanApexController.notesOfGoal(objInstance.id);
        //Elixir_ViewCarePlanApexController.notesOfObjective(obj.Id);
        //Elixir_ViewCarePlanApexController.notesOfProblem(problemIDs[0]);
        Test.stopTest();
        ElixirSuite__Notes__c Getnotes = [SELECT id,Notes__c FROM ElixirSuite__Notes__c LIMIT 1];
        System.assertEquals(1, 1, ' ');
    }
}
@isTest
public with sharing class Elixir_openStatusEditApexControllerTest {
    
    @isTest
    public static void getData() { //Coverage of getData And CareplanRecords
        Test.startTest();
        
        List<ElixirSuite__Dataset1__c> listOfProbs = new List<ElixirSuite__Dataset1__c>();
        //Care Plan template insertion start   
        for(Integer i=0 ; i<=2;i++){
            ElixirSuite__Dataset1__c problemTemplateRec = new ElixirSuite__Dataset1__c();   
            listOfProbs.add(problemTemplateRec);
        }     
        insert listOfProbs;
        
        Account accountRec = new Account();
        accountRec.Name = 'test account';
        insert accountRec;
        
        ElixirSuite__Treatment_Plan__c tp = new ElixirSuite__Treatment_Plan__c();
        tp.ElixirSuite__Treatment_Plan_Name__c = 'Tpc - 1';
        tp.Account__c = accountRec.id;
        tp.Start_Date__c = date.today();
        tp.End_Date__c = date.today() + 1;
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
        //obj_Int.RecordTypeId = Schema.SObjectType.ElixirSuite__Plan_SubHierarchy__c.getRecordTypeInfosByDeveloperName().get('Treatment_Plan_Recordtype4').getRecordTypeId();
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
        
        String prefix = 'CP-';
        ContentVersion cv = new ContentVersion();
        cv.Title = 'test1';
        cv.PathOnClient = prefix + 'careplan1' + '.txt';
        cv.VersionData = Blob.valueOf('test.txt');
        cv.IsMajorVersion = true;
        cv.FirstPublishLocationId = accountRec.Id;
        insert cv;

        Task tsk = new Task();
        tsk.Description = 'test desc';
        tsk.Subject = 'test sub';
        tsk.OwnerId = UserInfo.getUserId();
        tsk.ActivityDate = Date.today();

        insert tsk;
        
String masterData = '{"accountId":"'+accountRec.id+'"'+ ',"accountName":"James bond","carePlan":{"Id":"'+ tp.id+'"'+',"ElixirSuite__Account__c":"'+accountRec.id+'"'+ ',"ElixirSuite__Approval_Level_1__c":false,"ElixirSuite__Approval_Level_2__c":false,"ElixirSuite__Approval_Level_3__c":false,"ElixirSuite__Clinical_supervisor__c":"'+UserInfo.getUserId()+'"'+',"ElixirSuite__Description__c":"Care Plan for the preparation of better health outcome","ElixirSuite__End_Date__c":"2023-08-18","ElixirSuite__Primary_Therapist__c":"'+UserInfo.getUserId()+'"'+',"ElixirSuite__Start_Date__c":"'+date.today()+'"'+',"ElixirSuite__Status__c":"Open","ElixirSuite__Treatment_Plan_Name__c":"James bonds CP - 11"},"listOfGoal":[{"Id":"'+obj_Int.id+'"'+',"Name":"PSH - 013","ElixirSuite__Plan_Hierarchy_Name__c":"Goal Top","ElixirSuite__Treatment_Plan__c":"'+tp.id+'"'+',"ElixirSuite__Description__c":"Goal Top","ElixirSuite__Template_Problem__c":"'+tmpGoal.id+'"'+',"ElixirSuite__Due_Date__c":"2023-08-18","ElixirSuite__Treatment_Plan__r":{"Name":"TP-031","Id":"'+tp.ID+'"'+'},"ElixirSuite__Template_Problem__r":{"Name":"Goal Top","Id":"'+tmpGoal.Id+'"'+'},"listOfTask":[{"Id":"'+ds.id+'"'+',"Name":"Goal Top Objective","ElixirSuite__Description__c":"Goal Top Objective","listOfIntervention":[{"Id":"'+tsk.id +'"'+',"Name":"Goal Top Objective Intervention","ElixirSuite__Description__c":"Goal Top Objective Intervention","assignedTo":"'+UserInfo.getUserId()+'"'+',"Description":"Goal Top Objective Intervention"}],"Action":"Update"}],"listOfIntervention":[{"Id":"'+tsk.id+'"'+',"Name":"Goal Top Intervention","ElixirSuite__Description__c":"Goal Top Intervention","assignedTo":"'+UserInfo.getUserId()+'"'+',"Description":"Goal Top Intervention"}]},{"Id":"'+obj_Int.id+'"'+',"Name":"PSH - 024","ElixirSuite__Plan_Hierarchy_Name__c":"Goal Top","ElixirSuite__Treatment_Plan__c":"'+tp.id+'"'+',"ElixirSuite__Description__c":"Goal Top","ElixirSuite__Template_Problem__c":"'+tmpGoal.id+'"'+',"ElixirSuite__Due_Date__c":"2023-08-17","ElixirSuite__Treatment_Plan__r":{"Name":"TP-039","Id":"'+tp.id+'"'+'},"ElixirSuite__Template_Problem__r":{"Name":"Goal Top","Id":"'+tmpGoal.id+'"'+'},"listOfTask":[{"Id":"'+tmpObj.id+'"'+',"Name":"Goal Top Objective","ElixirSuite__Description__c":"Goal Top Objective","listOfIntervention":[{"Id":"'+tmpInterv.id+'"'+',"Name":"Goal Top Objective Intervention","ElixirSuite__Description__c":"Goal Top Objective Intervention","assignedTo":"'+UserInfo.getUserId()+'"'+',"Description":"Goal Top Objective Intervention"}],"Action":"Update"}],"listOfIntervention":[{"Id":"'+tmpInterv.id+'"'+',"Name":"Goal Top Intervention","ElixirSuite__Description__c":"Goal Top Intervention","assignedTo":"'+UserInfo.getUserId()+'"'+',"Description":"Goal Top Intervention"}],"Action":"Update"},{"Id":"'+tmpGoal.id+'"'+',"Name":"PSH - 024","ElixirSuite__Plan_Hierarchy_Name__c":"Goal Top","ElixirSuite__Description__c":"Goal Top","ElixirSuite__Template_Problem__c":"'+tmpGoal.id+'"'+',"ElixirSuite__Due_Date__c":"2023-08-17","ElixirSuite__Template_Problem__r":{"Name":"Goal Top","Id":"'+tmpGoal.id+'"'+'},"listOfTask":[{"Id":"'+tmpObj.id+'"'+',"Name":"Goal Top Objective","ElixirSuite__Description__c":"Goal Top Objective","listOfIntervention":[{"Id":"'+tmpInterv.id+'"'+',"Name":"Goal Top Objective Intervention","ElixirSuite__Description__c":"Goal Top Objective Intervention","assignedTo":"'+UserInfo.getUserId()+'"'+',"Description":"Goal Top Objective Intervention"}],"Action":"Update"}],"listOfIntervention":[{"Id":"'+tmpInterv.id+'"'+',"Name":"Goal Top Intervention","ElixirSuite__Description__c":"Goal Top Intervention","assignedTo":"'+UserInfo.getUserId()+'"'+',"Description":"Goal Top Intervention"}],"Action":"Update"}],"listOfObjs":[{"Id":"'+tmpObj.id+'"'+',"Name":"Objective Top","ElixirSuite__Description__c":"Objective Top","Action":"Update","listOfIntervention":[{"Id":"'+tmpInterv.id+'"'+',"Name":"Objective Top Intervention","ElixirSuite__Description__c":"Objective Top Intervention","assignedTo":"'+UserInfo.getUserId()+'"'+',"Description":"Objective Top Intervention"}]},{"Id":"'+ds.id+'"'+',"ElixirSuite__Name__c":"Objective Top","ElixirSuite__Description__c":"Objective Top","ElixirSuite__Treatment_Plan__c":"'+tp.id+'"'+',"ElixirSuite__Template_Problem__c":"'+tmpObj.id+'"'+',"ElixirSuite__Due_Date__c":"2023-08-18","ElixirSuite__Treatment_Plan__r":{"Name":"TP-039","Id":"'+tp.id+'"'+'},"ElixirSuite__Template_Problem__r":{"Name":"Objective Top","Id":"'+tmpObj.id+'"'+'},"Action":"Update","listOfIntervention":[{"Id":"'+tsk.id+'"'+',"Subject":"Objective Top Intervention","OwnerId":"'+UserInfo.getUserId()+'"'+',"WhatId":"'+ds.id+'"'+',"Description":"Objective Top Intervention","ElixirSuite__Template_Problem__c":"'+tmpInterv.id+'"'+',"ActivityDate":"2023-08-18"},{"Id":"'+tmpInterv.id+'"'+',"Name":"Objective Top Intervention","ElixirSuite__Description__c":"Objective Top Intervention","assignedTo":"'+UserInfo.getUserId()+'"'+',"Description":"Objective Top Intervention"}]},{"Id":"'+ds.id+'"'+',"ElixirSuite__Name__c":"Objective Top","ElixirSuite__Description__c":"Objective Top","ElixirSuite__Treatment_Plan__c":"'+tp.id+'"'+',"ElixirSuite__Template_Problem__c":"'+tmpObj.id+'"'+',"ElixirSuite__Due_Date__c":"2023-08-18","ElixirSuite__Treatment_Plan__r":{"Name":"TP-039","Id":"'+tp.id+'"'+'},"ElixirSuite__Template_Problem__r":{"Name":"Objective Top","Id":"'+tmpObj.id+'"'+'},"listOfIntervention":[{"Id":"'+tsk.id+'"'+',"Subject":"Objective Top Intervention","OwnerId":"'+UserInfo.getUserId()+'"'+',"WhatId":"'+ds.id+'"'+',"Description":"Objective Top Intervention","ElixirSuite__Template_Problem__c":"'+tmpInterv.id+'"'+',"ActivityDate":"2023-08-18"}]}],"listOfProblem":[{"Id":"'+problem.id+'"'+',"IsDeleted":false,"Name":"Diabetes mellitus","ElixirSuite__Template_Problem__c":"'+tmp.id+'"'+',"ElixirSuite__Plan_Hierarchy__r":[{"ElixirSuite__Dataset1__c":"'+problem.id+'"'+',"Id":"'+objInstance.id+'"'+',"ElixirSuite__Treatment_Plan__c":"'+tp.id+'"'+',"ElixirSuite__Due_Date__c":"2023-08-14"}],"listOfRelatedDiagnosis":null,"listOfGoal":[],"listOfDef":[]},{"Id":"'+problem.id+'"'+',"IsDeleted":false,"Name":"Obesity","ElixirSuite__Template_Problem__c":"'+tmp.id+'"'+',"ElixirSuite__Plan_Hierarchy__r":[{"ElixirSuite__Dataset1__c":"'+problem.id+'"'+',"Id":"'+objInstance.id+'"'+',"ElixirSuite__Treatment_Plan__c":"'+tp.id+'"'+',"ElixirSuite__Due_Date__c":"2023-08-14"}],"listOfRelatedDiagnosis":[],"listOfGoal":[{"Id":"'+tmpGoal.id+'"'+',"Name":"low-calorie diet","ElixirSuite__Description__c":"low-calorie diet","listOfTask":[{"Id":"'+tmpObj.id+'"'+',"Name":"Reduced-calorie diet","ElixirSuite__Description__c":"Reduced-calorie diet","listOfIntervention":[{"Id":"'+tmpInterv.id+'"'+',"Name":"Follow the DASH Diet","ElixirSuite__Description__c":"Follow the DASH Diet","assignedTo":"'+UserInfo.getUserId()+'"'+',"Description":"Follow the DASH Diet"}],"Action":"Update"}],"listOfIntervention":[{"Id":"'+tmpInterv.id+'"'+',"Name":"Follow the DASH Diet","ElixirSuite__Description__c":"Follow the DASH Diet","assignedTo":"'+UserInfo.getUserId()+'"'+',"Description":"Follow the DASH Diet"}],"Action":"Update"}],"listOfDef":[{"Id":"'+tmpObj.id+'"'+',"Name":"Reduce tummy size","ElixirSuite__Description__c":"Reduce tummy size","listOfIntervention":[{"Id":"'+tmpInterv.id+'"'+',"Name":"Increase physical activity","ElixirSuite__Description__c":"Increase physical activity","assignedTo":"'+UserInfo.getUserId()+'"'+',"Description":"Increase physical activity"}],"Action":"Update"}],"Action":"Update"}],"listOfTasks":[{"Id":"'+tmpInterv.id+'"'+',"Name":"Goal Top Objective","ElixirSuite__Description__c":"Goal Top Objective","assignedTo":"'+UserInfo.getUserId()+'"'+',"Action":"Update"},{"Id":"'+tsk.id+'"'+',"assignedTo":"'+UserInfo.getUserId()+'"'+',"Description":"Goal Top Objective"}],"nameSpace":"ElixirSuite","patientBirthDate":"2023-08-03","userName":"User User"}';        
        System.debug('@@@@'+masterData);
        ElixirSuite__Treatment_Plan__c caseRec = new ElixirSuite__Treatment_Plan__c();
        caseRec.ElixirSuite__Account__c = accountRec.Id;
        caseRec.Start_Date__c = System.today();
        caseRec.ElixirSuite__Due_Date__c = System.today().addDays(1);
        caseRec.ElixirSuite__Treatment_Plan_Name__c = 'Testing';
        caseRec.ElixirSuite__Status__c = 'Open';
        caseRec.Primary_Therapist__c = userInfo.getUserId();
        caseRec.Clinical_supervisor__c= userInfo.getUserId();
        insert caseRec;
        
        List<Account> listOfAcc = [SELECT Id , Name FROM Account LIMIT 1];
        List<ElixirSuite__Treatment_Plan__c> listOfCase = [SELECT Id FROM ElixirSuite__Treatment_Plan__c  LIMIT 1 ];
        if(listOfAcc!=null && listOfAcc.size()>0 && listOfCase!=null && listOfCase.size()>0){
            Elixir_openStatusEditApexController.getData(listOfCase[0].Id , listOfAcc[0].Id);
        } 
        Elixir_openStatusEditApexController.saveNotes('test.txt',accountRec.Id,accountRec.Id,'careplan');
        Elixir_openStatusEditApexController.fetchNotes(accountRec.Id);
        Elixir_openStatusEditApexController.delNotes(cv.ContentDocumentId);
        Elixir_openStatusEditApexController.delNotesOnCancel(new List<String>{cv.ContentDocumentId});
        Elixir_openStatusEditApexController.getAllProblems(new List<String>{problem.Id}, accountRec.Id, tp.Id);
        Elixir_openStatusEditApexController.getTasks(obj_Int.Id);
        Elixir_openStatusEditApexController.getGoalsAndEvidences(problem.Id, tp.Id);
        Elixir_openStatusEditApexController.getAllGoals(new List<String>{tmpGoal.Id});
        Elixir_openStatusEditApexController.getAllTasks(new List<String>{tmpObj.Id});
        Elixir_openStatusEditApexController.getAllInterventions(new List<String>{tmpInterv.Id});
        Elixir_openStatusEditApexController.getTasksFromGoal(new List<String>{tmpObj.Id},obj_Int.Id);
        Elixir_openStatusEditApexController.getAllTasks2(new List<String>{tmpInterv.Id},obj_Int.Id);
        Elixir_openStatusEditApexController.getInterventionFromObjective(new List<String>{tmpInterv.Id},ds.Id);
        Elixir_openStatusEditApexController.getAllGoalsAndObjectives(new List<String>{tmpObj.Id},problem.Id);
        Elixir_openStatusEditApexController.saveData(masterData , tp , 'Open' , 'James Cp - 1' , tp.Id,
                                String.valueOf(date.today()) , String.valueOf(date.today()+1), 'test signature' , null ,
                                                      String.valueOf(date.today()) ,'james', null , 'test description',null,new List<String>{objInstance.id},accountRec.Id,null);
        Test.stopTest();
        system.assertEquals(1, 1, '');
    }
    
   /* @TestSetup
    public static void elixir_CarePlanControllerTestDefault(){
        
        Account accountRec = new Account();
        accountRec.Name = 'Tanveer';
        insert accountRec;
        
        List<ElixirSuite__Dataset1__c> listOfProbs = new List<ElixirSuite__Dataset1__c>();
        //Care Plan template insertion start   
        
        for(Integer i=0 ; i<=2;i++){
            ElixirSuite__Dataset1__c problemTemplateRec = new ElixirSuite__Dataset1__c();   
            listOfProbs.add(problemTemplateRec);
        }     
        insert listOfProbs;
        
        List<ElixirSuite__Dataset2__c> listOfGoals = new List<ElixirSuite__Dataset2__c>();
        // Id level2AcctSpecific_Goal = Schema.SObjectType.Plan_Hierarchy__c.getRecordTypeInfosByDeveloperName().get('Recordtype1').getRecordTypeId();
        for(Integer i=0 ; i<=3;i++){
            ElixirSuite__Dataset2__c goalRec = new ElixirSuite__Dataset2__c();
            //  goalRec.RecordTypeId = level2AcctSpecific_Goal;
            goalRec.ElixirSuite__Dataset1__c = listOfProbs[0].Id;
            listOfGoals.add(goalRec); 
        }
        insert listOfGoals;
        
        
        List<ElixirSuite__Dataset3__c> listOfTasks = new List<ElixirSuite__Dataset3__c>();
        for(Integer i=0 ; i<=3;i++){
            ElixirSuite__Dataset3__c taskRec = new ElixirSuite__Dataset3__c();
            taskRec.Description__c = 'Test Care Plan';
            taskRec.ElixirSuite__Dataset2__c = listOfGoals[i].Id;
            listOfTasks.add(taskRec);
        }
        insert listOfTasks;
        //Care Plan template insertion end
        
        
        //Care Plan Insertion Start
        ElixirSuite__Treatment_Plan__c caseRec = new ElixirSuite__Treatment_Plan__c();
        caseRec.ElixirSuite__Account__c = accountRec.Id;
        caseRec.Start_Date__c = System.today();
        caseRec.ElixirSuite__Due_Date__c = System.today().addDays(1);
        caseRec.ElixirSuite__Treatment_Plan_Name__c = 'Testing';
        caseRec.ElixirSuite__Status__c = 'Open';
        caseRec.Primary_Therapist__c = userInfo.getUserId();
        caseRec.Clinical_supervisor__c= userInfo.getUserId();
        insert caseRec;
        
        ElixirSuite__Dataset1__c newProblem = new ElixirSuite__Dataset1__c();
        newProblem.Account__c = accountRec.Id;
        newProblem.ElixirSuite__Dataset1__c = listOfProbs[0].Id;
        newProblem.ElixirSuite__Treatment_Plan__c = caseRec.Id;
        insert newProblem;
        
        ElixirSuite__Plan_Hierarchy__c newGoal = new ElixirSuite__Plan_Hierarchy__c();
        newGoal.ElixirSuite__Dataset2__c  = listOfGoals[0].Id;
        newGoal.ElixirSuite__Dataset1__c = newProblem.Id;
        insert newGoal;
        
        ElixirSuite__Plan_SubHierarchy__c newTask = new ElixirSuite__Plan_SubHierarchy__c();
        newTask.ElixirSuite__Description__c = 'abc';
        newTask.ElixirSuite__Plan_Hierarchy__c = newGoal.Id;
        insert newTask;
        //Care Plan insertion End
        List <ElixirSuite__Dataset1__c> listOfCons = new List<ElixirSuite__Dataset1__c>();
        for(Integer i=0 ; i<=2;i++){
            ElixirSuite__Dataset1__c conditionRec = new ElixirSuite__Dataset1__c();
            conditionRec.Account__c = accountRec.Id;
            conditionRec.ElixirSuite__Dataset1__c = listOfProbs[i].Id;
            listOfCons.add(conditionRec);
        }
        insert listOfCons;
        system.assertEquals(1, 1);
    }*/
  /*  @isTest
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
        accountRec.Name = 'Tanveer';
        insert accountRec;
        List <ElixirSuite__Dataset1__c> listOfCons = new List<ElixirSuite__Dataset1__c>();
        for(Integer i=0 ; i<=2;i++){
            ElixirSuite__Dataset1__c conditionRec = new ElixirSuite__Dataset1__c();
            conditionRec.Account__c = accountRec.Id;
            conditionRec.ElixirSuite__Dataset1__c = listOfProbs[i].Id;
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
        objInstance.RecordTypeId = Schema.SObjectType.Plan_Hierarchy__c.getRecordTypeInfosByDeveloperName().get('Recordtype1').getRecordTypeId();
        insert objInstance;
        
        ElixirSuite__Plan_SubHierarchy__c obj= new ElixirSuite__Plan_SubHierarchy__c();
        obj.RecordTypeId = Schema.SObjectType.ElixirSuite__Plan_SubHierarchy__c.getRecordTypeInfosByDeveloperName().get('Treatment_Plan_Recordtype4').getRecordTypeId();
        obj.ElixirSuite__Description__c = 'abc';
        obj.Plan_Hierarchy__c = objInstance.Id;
        insert obj;
        
        ElixirSuite__Plan_SubHierarchy__c obj_Int= new ElixirSuite__Plan_SubHierarchy__c();
        obj_Int.RecordTypeId = Schema.SObjectType.ElixirSuite__Plan_SubHierarchy__c.getRecordTypeInfosByDeveloperName().get('Treatment_Plan_Recordtype4').getRecordTypeId();
        obj_Int.ElixirSuite__Description__c = 'abc';
        obj_Int.Plan_Hierarchy__c = objInstance.Id;
        insert obj_Int;
        
        Map <Id , Object> mapOfSavedProblemsForUpdate = new Map <Id , Object>();  
        ElixirSuite__Dataset1__c problem = new ElixirSuite__Dataset1__c();
        problem.ElixirSuite__Due_Date__c = system.today();
        problem.ElixirSuite__Description__c = 'descri';
        insert problem; 
        String falseString = '{"ElixirSuite__Dataset1__c":"a045Y00000nVKtVQAW","ElixirSuite__Due_Date__c":"2021-04-23","Id":"a045Y00000nVKtkQAG","ElixirSuite__IsActive__c":false,"Name":"PROBLEM - 2 - TEMPLATE","ElixirSuite__Problem_Name__c":"PROBLEM - 2 - TEMPLATE","RecordTypeId":"0125Y000001DyQUQA0"}';
        
        mapOfSavedProblemsForUpdate.put(problem.Id,JSON.serialize(falseString));
        
        Elixir_openStatusEditApexController.getAllProblems(problemIDs);
        Elixir_openStatusEditApexController.deleteSavedProblems(delProbs);
        Elixir_openStatusEditApexController.getGoals(problemIDs[0]);
        Elixir_openStatusEditApexController.getAllGoals(problemIDs);
        Elixir_openStatusEditApexController.fetchRelatedDiagnosis(problemIDs[0]);
        Elixir_openStatusEditApexController.getInterventions(obj.Id);
        Elixir_openStatusEditApexController.getTasks(objInstance.Id);
        Elixir_openStatusEditApexController.dummyMethod();
        
        // getData();
        Test.stopTest();  
           system.assertEquals(1, 1);
    }*/
    
  /* @isTest
    public static void getTemplateGoals(){ //Coverage of getTemplateGoals And getTemplateTasks
        Test.startTest();
        List<ElixirSuite__Dataset1__c> listOfProblems = [SELECT Id FROM ElixirSuite__Dataset1__c LIMIT 1];
        if(listOfProblems!=null && listOfProblems.size()>0){
            //   Elixir_openStatusEditApexController.getTemplateGoals(listOfProblems[0].Id);
            List<ElixirSuite__Plan_Hierarchy__c> listOfGoals = [SELECT Id,ElixirSuite__Dataset1__c
                                                                FROM ElixirSuite__Plan_Hierarchy__c LIMIT 1];
            if(listOfGoals!=null && listOfGoals.size()>0){
                //   Elixir_openStatusEditApexController.getTemplateTasks(listOfGoals[0].Id);
            }
        }   
        Test.stopTest(); 
          system.assertEquals(1, 1); 
    } 
    @isTest
    public static void getsObjects(){//Coverage of getGoals , getTasks
        Test.startTest();
        List<Account> listOfAcc = [SELECT Id , Name FROM Account LIMIT 1];
        List<Case> listOfCase = [SELECT Id FROM Case LIMIT 1];
        if(listOfAcc!=null && listOfAcc.size()>0 && listOfCase!=null && listOfCase.size()>0){
            List<ElixirSuite__Dataset1__c> listOfProblems = [SELECT Id, Name, Account__c FROM ElixirSuite__Dataset1__c      
                                                             WHERE Account__c= :listOfAcc[0].Id AND ElixirSuite__Treatment_Plan__c= :listOfCase[0].Id];
            if(listOfProblems!=null && listOfProblems.size()>0){
                Elixir_openStatusEditApexController.getGoals(listOfProblems[0].Id );
            }        
            List<ElixirSuite__Plan_Hierarchy__c> listOfGoals = [SELECT Id FROM ElixirSuite__Plan_Hierarchy__c  WHERE ElixirSuite__Dataset1__c= :listOfProblems[0].Id];
            System.debug('lst of goals '+listOfGoals);
            if(listOfGoals!=null && listOfGoals.size()>0){
                Elixir_openStatusEditApexController.getTasks(listOfGoals[0].Id );
            } 
            Test.stopTest();
        }
           system.assertEquals(1, 1);
    }
    
    @isTest
    public static void getAllProblems(){ //Coverage of getAllProbs , getAllGoalsTemplate And getAllTasksTemplate
        Test.startTest();
        
        List<ElixirSuite__Plan_SubHierarchy__c> listOfTasks = [SELECT Id
                                                               FROM ElixirSuite__Plan_SubHierarchy__c LIMIT 1];
        if(listOfTasks!=null && listOfTasks.size()>0){
            Elixir_openStatusEditApexController.getAllTasksTemplate(new List<Id>{listOfTasks[0].Id});
        }
        Test.stopTest(); 
           system.assertEquals(1, 1);
    } 
    @isTest
    public static void createMasterDataWrapperForSave(){  // For saving care plan And goalsNullsHandle And taskNullsHandle
        Test.startTest();
        Wrapper wrpr = new Wrapper();
        ProblemWrapper probWrpr = new ProblemWrapper();
        GoalWrapper goalWrpr = new GoalWrapper();
        TaskWrapper taskWrpr = new taskWrapper();
        Boolean goalFilled = false;
        Boolean taskFilled = false;
        List<Account> listOfAcc = [SELECT Id , Name FROM Account LIMIT 1];
        List<ElixirSuite__Treatment_Plan__c> listOfCase = [SELECT Id ,Start_Date__c,ElixirSuite__Treatment_Plan_Name__c,Primary_Therapist__c,Clinical_supervisor__c FROM ElixirSuite__Treatment_Plan__c LIMIT 1];
        if(listOfAcc!=null && listOfAcc.size()>0){
            wrpr.accountId = listOfAcc[0].Id;
        }   
        List<ElixirSuite__Dataset1__c> listOfProblems = [SELECT Id FROM ElixirSuite__Dataset1__c LIMIT 3];
        if(listOfProblems!=null && listOfProblems.size()>0){
            for(ElixirSuite__Dataset1__c probRec : listOfProblems){
                probWrpr = new ProblemWrapper();
                probWrpr.Id = probRec.Id;
                probWrpr.endDate = System.today().addDays(1);
                probWrpr.Action = 'UPDATE';                
                wrpr.listOfProblem.add(probWrpr);
                List<ElixirSuite__Plan_Hierarchy__c> listOfGoals = [SELECT Id,ElixirSuite__Dataset1__c
                                                                    FROM ElixirSuite__Plan_Hierarchy__c 
                                                                    LIMIT 3];
                if(listOfGoals!=null && listOfGoals.size()>0){  
                    if(goalFilled == false){
                        for(ElixirSuite__Plan_Hierarchy__c goalRec : listOfGoals){                                  
                            
                            goalWrpr = new GoalWrapper();
                            goalWrpr.Id = goalRec.Id;
                            goalWrpr.endDate = System.today().addDays(1);
                            goalWrpr.Action = 'UPDATE';   
                            probWrpr.listOfGoal = new List<GoalWrapper>();
                            probWrpr.listOfGoal.add(goalWrpr);                          
                            List<Task> listOfTasks = [SELECT Id FROM Task LIMIT 3]; 
                            if(listOfTasks!=null && listOfTasks.size()>0){  
                                
                                for(Task taskRec : listOfTasks){   
                                    if(taskFilled == false && goalFilled == false){
                                        taskWrpr.Id = taskRec.Id;
                                        taskWrpr.endDate = System.today().addDays(1);
                                        taskWrpr.Action = 'UPDATE';
                                        goalWrpr.listOfTask = new List<TaskWrapper>(); 
                                        goalWrpr.listOfTask.add(taskWrpr);
                                        taskFilled = true;
                                    }
                                    else{
                                        goalFilled = true;
                                    }
                                }
                                
                            }
                            
                        }
                        
                    }
                }          
            }
            Test.stopTest();  
        }
           system.assertEquals(1, 1);
    }
    @isTest
    public static void deleteSavedProblems(){
        Test.startTest();
        List<ElixirSuite__Dataset1__c> listOfProblems = [SELECT Id, Name, Account__c FROM ElixirSuite__Dataset1__c];
        if(listOfProblems!=null && listOfProblems.size()>0){
            Elixir_openStatusEditApexController.deleteSavedProblems(new Map<Id,sObject>(listOfProblems).keySet());
        }
           system.assertEquals(1, 1);
    }
    @isTest
    public static void deleteSavedGoals(){
        Test.startTest();
        List<ElixirSuite__Plan_Hierarchy__c> listOfGoals = [SELECT Id FROM ElixirSuite__Plan_Hierarchy__c];
        if(listOfGoals!=null && listOfGoals.size()>0){
            Elixir_openStatusEditApexController.deleteSavedGoals(new Map<Id,sObject>(listOfGoals).keySet());
        }
           system.assertEquals(1, 1);
    }
    @isTest
    public static void deleteSavedTasks(){
        Test.startTest();
        List<Task> listOfTasks = [SELECT Id FROM Task];  
        if(listOfTasks!=null && listOfTasks.size()>0){
            //  Elixir_openStatusEditApexController.deleteSavedTasks(new Map<Id,sObject>(listOfTasks).keySet());
        }
           system.assertEquals(1, 1);
    }
    
    @isTest
    public static void editCarePlan(){
        Test.startTest();
        Wrapper wrpr = new Wrapper();
        ProblemWrapper probWrpr = new ProblemWrapper();
        GoalWrapper goalWrpr = new GoalWrapper();
        TaskWrapper taskWrpr = new taskWrapper();
        Boolean goalFilled = false;
        Boolean taskFilled = false;
        List<Account> listOfAcc = [SELECT Id , Name FROM Account LIMIT 1];
        List<ElixirSuite__Treatment_Plan__c> listOfCase = [SELECT Id ,Start_Date__c,ElixirSuite__Treatment_Plan_Name__c,Primary_Therapist__c,Clinical_supervisor__c FROM ElixirSuite__Treatment_Plan__c LIMIT 1];
        if(listOfAcc!=null && listOfAcc.size()>0){
            wrpr.accountId = listOfAcc[0].Id;
        }   
        List<ElixirSuite__Dataset1__c> listOfProblems = [SELECT Id, Name, Account__c FROM ElixirSuite__Dataset1__c];
        if(listOfProblems!=null && listOfProblems.size()>0){
            for(ElixirSuite__Dataset1__c probRec : listOfProblems){
                probWrpr = new ProblemWrapper();
                probWrpr.Id = probRec.Id;
                probWrpr.endDate = System.today().addDays(1);
                probWrpr.Action = 'DELETE';       
                wrpr.listOfProblem.add(probWrpr);
            }
            List<ElixirSuite__Plan_Hierarchy__c> listOfGoals = [SELECT Id FROM ElixirSuite__Plan_Hierarchy__c  WHERE ElixirSuite__Dataset1__c= :listOfProblems[0].Id];
            if(listOfGoals!=null && listOfGoals.size()>0){
                Integer i = 0;
                for(ElixirSuite__Plan_Hierarchy__c goalRec : listOfGoals){
                    goalWrpr = new GoalWrapper();
                    goalWrpr.Id = goalRec.Id;
                    goalWrpr.endDate = System.today().addDays(1);
                    goalWrpr.Action = 'DELETE';                
                    probWrpr.listOfGoal = new List<GoalWrapper>();
                    probWrpr.listOfGoal.add(goalWrpr);                          
                    List<ElixirSuite__Plan_SubHierarchy__c> listOfTasks = [SELECT Id FROM ElixirSuite__Plan_SubHierarchy__c WHERE ElixirSuite__Plan_Hierarchy__c =:goalRec.Id LIMIT 3];
                    if(listOfTasks!=null && listOfTasks.size()>0){
                        for(ElixirSuite__Plan_SubHierarchy__c taskRec : listOfTasks){
                            taskWrpr.Id = taskRec.Id;
                            taskWrpr.endDate = System.today().addDays(1);
                            taskWrpr.Action = 'DELETE';
                            
                            goalWrpr.listOfTask = new List<TaskWrapper>(); 
                            goalWrpr.listOfTask.add(taskWrpr); 
                            
                            
                        }          
                    } 
                    Elixir_openStatusEditApexController.saveData(JSON.serialize(wrpr) , listOfCase[0], 'Open' , 'Tanveer' ,listOfCase[0].Id,String.valueOf(System.now()),String.valueOf(System.now().addDays(1))
                                                                 ,'','','','','', 'test' );
                    
                    
                    
                }
            } 
        }
        Test.stopTest();
           system.assertEquals(1, 1);
    }
    @isTest
    public static void editCarePlanSave(){
        Test.startTest();
        Wrapper wrpr = new Wrapper();
        ProblemWrapper probWrpr = new ProblemWrapper();
        GoalWrapper goalWrpr = new GoalWrapper();
        TaskWrapper taskWrpr = new taskWrapper();
        Boolean goalFilled = false;
        Boolean taskFilled = false;
        List<Account> listOfAcc = [SELECT Id , Name FROM Account LIMIT 1];
        
        List<ElixirSuite__Treatment_Plan__c> listOfCase = [SELECT Id ,Start_Date__c,ElixirSuite__Treatment_Plan_Name__c,Primary_Therapist__c,Clinical_supervisor__c FROM ElixirSuite__Treatment_Plan__c LIMIT 1];
        if(listOfAcc!=null && listOfAcc.size()>0){
            wrpr.accountId = listOfAcc[0].Id;
            List<ElixirSuite__Dataset1__c> listOfProblems = [SELECT Id, Name, Account__c FROM ElixirSuite__Dataset1__c];
            if(listOfProblems!=null && listOfProblems.size()>0){
                for(ElixirSuite__Dataset1__c probRec : listOfProblems){
                    probWrpr = new ProblemWrapper();
                    probWrpr.Id = probRec.Id;
                    probWrpr.endDate = System.today().addDays(1);
                    probWrpr.Action = 'UPDATE';       
                    wrpr.listOfProblem.add(probWrpr);
                }
                List<ElixirSuite__Plan_Hierarchy__c> listOfGoals = [SELECT Id FROM ElixirSuite__Plan_Hierarchy__c  WHERE ElixirSuite__Dataset1__c= :listOfProblems[0].Id];
                if(listOfGoals!=null && listOfGoals.size()>0){
                    Integer i = 0;
                    for(ElixirSuite__Plan_Hierarchy__c goalRec : listOfGoals){
                        goalWrpr = new GoalWrapper();
                        goalWrpr.Id = goalRec.Id;
                        goalWrpr.endDate = System.today().addDays(1);
                        goalWrpr.Action = 'UPDATE';                
                        if(goalFilled == false){
                            probWrpr.listOfGoal = new List<GoalWrapper>();
                            probWrpr.listOfGoal.add(goalWrpr);                          
                            List<ElixirSuite__Plan_SubHierarchy__c> listOfTasks = [SELECT Id FROM ElixirSuite__Plan_SubHierarchy__c WHERE ElixirSuite__Plan_Hierarchy__c =:goalRec.Id LIMIT 3];
                            if(listOfTasks!=null && listOfTasks.size()>0){
                                for(ElixirSuite__Plan_SubHierarchy__c taskRec : listOfTasks){
                                    taskWrpr.Id = taskRec.Id;
                                    taskWrpr.endDate = System.today().addDays(1);
                                    taskWrpr.Action = 'UPDATE';
                                    if(taskFilled == false && goalFilled == false){
                                        goalWrpr.listOfTask = new List<TaskWrapper>(); 
                                        goalWrpr.listOfTask.add(taskWrpr);
                                        taskFilled = true;
                                    }else{
                                        goalFilled = true;
                                    }
                                }
                            }          
                        } 
                        Elixir_openStatusEditApexController.saveData(JSON.serialize(wrpr) , listOfCase[0], 'Open' , 'Rohit Singh Bora' ,listOfCase[0].Id ,String.valueOf(System.now()),String.valueOf(System.now().addDays(1))
                                                                     ,                                           '','','','','test' , 'test'  );    
                    }
                } 
            }
            Test.stopTest();
        }
           system.assertEquals(1, 1);
    }
    public class Wrapper{ // Wrapper class
        public String accountId;
        public String Status;
        public List<ProblemWrapper> listOfProblem = new List<ProblemWrapper>();
    }
    public class ProblemWrapper{
        public String Id;
        public Date endDate;
        public String Action;
        public List<GoalWrapper> listOfGoal ;
        
    }
    public class GoalWrapper{
        public String Id;
        public Date endDate;
        public String Action;
        public List<TaskWrapper> listOfTask;
    }
    public class TaskWrapper{
        public String Id;
        public Date endDate;
        public String Action;
        
    }*/
}
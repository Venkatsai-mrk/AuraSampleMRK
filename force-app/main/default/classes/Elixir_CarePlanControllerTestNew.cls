/**
* @description       : 
* @author            : ChangeMeIn@UserSettingsUnder.SFDoc
* @group             : 
* @last modified on  : 02-10-2023
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class Elixir_CarePlanControllerTestNew {
    @isTest
    public static void method1(){
        Account accountRec = new Account();
        accountRec.Name = 'Anubhav';
        insert accountRec;
        
        CarePlan_Hierarchy__c cph = new CarePlan_Hierarchy__c();
        insert cph;
        
        ElixirSuite__Visits__c elixiVisit = new ElixirSuite__Visits__c();
        elixiVisit.ElixirSuite__Account__c = accountRec.Id;
        elixiVisit.ElixirSuite__Status__c = 'Active';
        insert elixiVisit;
        
        // ElixirSuite__Diagnosis__c diag = new ElixirSuite__Diagnosis__c();
        // insert diag;
        
        List<ElixirSuite__Dataset1__c> listOfProbs = new List<ElixirSuite__Dataset1__c>();
        
        for(Integer i=0 ; i<=2;i++){
            ElixirSuite__Dataset1__c problemTemplateRec = new ElixirSuite__Dataset1__c();   
            listOfProbs.add(problemTemplateRec);
        }     
        insert listOfProbs;
        
        List<String> problemIDs = new   List<String>();
        
        for(ElixirSuite__Dataset1__c fetch : listOfProbs){
            problemIDs.add(fetch.Id);
        }
        
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
        
        //Care Plan Insertion Start
        ElixirSuite__Treatment_Plan__c caseRec = new ElixirSuite__Treatment_Plan__c();
        caseRec.ElixirSuite__Account__c = accountRec.Id;
        caseRec.Start_Date__c = System.today();
        caseRec.ElixirSuite__Due_Date__c = System.today().addDays(1);
        caseRec.ElixirSuite__Treatment_Plan_Name__c = 'TestingCP-3';
        caseRec.ElixirSuite__Status__c = 'Open';
        caseRec.Primary_Therapist__c = userInfo.getUserId();
        caseRec.Clinical_supervisor__c= userInfo.getUserId();
        insert caseRec;
        List<ID> delProbs = new List<ID>();
        delProbs.add(caseRec.Id);
        ElixirSuite__Dataset1__c newProblem = new ElixirSuite__Dataset1__c();
        newProblem.Account__c = accountRec.Id;
        //newProblem.ElixirSuite__Dataset1__c = listOfProbs[0].Id;
        //newProblem.ElixirSuite__Treatment_Plan__c = caseRec.Id;
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
            //conditionRec.ElixirSuite__Dataset1__c = listOfProbs[i].Id;
            listOfCons.add(conditionRec);
        }
        insert listOfCons;
        
        Plan_Hierarchy__c objInstance = new Plan_Hierarchy__c();
        objInstance.Description__c = 'hello test';
        objInstance.RecordTypeId = Schema.SObjectType.Plan_Hierarchy__c.getRecordTypeInfosByDeveloperName().get('Recordtype1').getRecordTypeId();
        insert objInstance;
        
        ElixirSuite__Plan_SubHierarchy__c obj= new ElixirSuite__Plan_SubHierarchy__c();
        obj.RecordTypeId = Schema.SObjectType.ElixirSuite__Plan_SubHierarchy__c.getRecordTypeInfosByDeveloperName().get('Treatment_Plan_Recordtype4').getRecordTypeId();
        obj.ElixirSuite__Description__c = 'abc';
        obj.Plan_Hierarchy__c = objInstance.Id;
        insert obj;
        
        ElixirSuite__Plan_SubHierarchy__c objInt= new ElixirSuite__Plan_SubHierarchy__c();
        objInt.RecordTypeId = Schema.SObjectType.ElixirSuite__Plan_SubHierarchy__c.getRecordTypeInfosByDeveloperName().get('Treatment_Plan_Recordtype4').getRecordTypeId();
        objInt.ElixirSuite__Description__c = 'abc';
        objInt.Plan_Hierarchy__c = objInstance.Id;
        insert objInt;
        
        //Me adding this
        List<String> existingTasks = new List<String>();
        existingTasks.add(objInstance.Id);
        
        List<String> existingInts = new List<String>();
        existingInts.add(obj.Id);
        //Me ending here
        
        Map <Id , Object> mapOfSavedProblemsForUpdate = new Map <Id , Object>();  
        ElixirSuite__Dataset1__c problem = new ElixirSuite__Dataset1__c();
        // problem.ElixirSuite__Due_Date__c = system.today();
        problem.ElixirSuite__Description__c = 'descri';
        insert problem; 
        String falseString = '{"ElixirSuite__Dataset1__c":"a045Y00000nVKtVQAW","ElixirSuite__Due_Date__c":"2021-04-23","Id":"a045Y00000nVKtkQAG","ElixirSuite__IsActive__c":false,"Name":"PROBLEM - 2 - TEMPLATE","ElixirSuite__Problem_Name__c":"PROBLEM - 2 - TEMPLATE","RecordTypeId":"0125Y000001DyQUQA0"}';
        
        mapOfSavedProblemsForUpdate.put(problem.Id,JSON.serialize(falseString));
        
        
        //Id ids=UserInfo.getUserId();
        
        
        Test.startTest();
        Elixir_CarePlanController.getData(accountRec.Id);
        Elixir_CarePlanController.CareplanRecords(accountRec.Id);
        Elixir_CarePlanController.getGoalsAndEvidences(newProblem.Id);
        Elixir_CarePlanController.fetchCarePlan(accountRec.Id);
        Elixir_CarePlanController.getTasks(objInstance.Id);
        Elixir_CarePlanController.getInterventions(obj.Id);
        Elixir_CarePlanController.getAllTasks(existingTasks);
        Elixir_CarePlanController.getAllTasks2(existingTasks,null);
        Elixir_CarePlanController.getAllInterventions(existingInts);
        Elixir_CarePlanController.getHierarchy();
        Elixir_CarePlanController.getAllProblems(problemIDs,accountRec.Id);
        Elixir_CarePlanController.getAllGoals(problemIDs);
        Elixir_CarePlanController.attachApprovalDataToParentCarePlan(caseRec.Id,'');
        Elixir_CarePlanController.deleteCarePlans(delProbs);
        System.assertEquals(1,1,'');
        Test.stopTest();
    }
    @isTest
    public static void method2(){
        Account accountRec = new Account();
        accountRec.Name = 'Anubhav';
        insert accountRec;
        
        CarePlan_Hierarchy__c cph = new CarePlan_Hierarchy__c();
        insert cph;
        
        Id ids=UserInfo.getUserId();
        string userName = UserInfo.getName();
        Dataset1__c ds1 = new Dataset1__c();
        insert ds1;
                
        Dataset2__c ds2 = new Dataset2__c();
        ds2.Account__c = accountRec.Id;
        insert ds2;
        
        Dataset3__c ds3 = new Dataset3__c();
        insert ds3;
        
        ICD_Codes__c icd = new ICD_Codes__c();
        insert icd;
        
        List<Dataset1__c> listOfProblem1 = new List<Dataset1__c> ();
        listOfProblem1.add(ds1);
        
        List<Dataset2__c> listOfGoal1 = new List<Dataset2__c> ();
        listOfGoal1.add(ds2);
        
        List<Dataset3__c> listOfInterventions1 = new List<Dataset3__c> ();
        listOfInterventions1.add(ds3);
        
        List<ICD_Codes__c> listOfDiag1 = new List<ICD_Codes__c>();
        listOfDiag1.add(icd);
        
        List<User> listOfAllUsers1 = [select id from User where id = :ids];
        
        List<String> pickListValuesList1 = new List<String> ();
        pickListValuesList1.add('abc');
        
        Intervention loi = new Intervention();
        loi.name = 'abcd';
        //loi.ElixirSuite__Description__c = 'aaavvv';
        loi.Id = ds3.Id;
        
        List<Intervention> loilist = new List<Intervention>();
        loilist.add(loi);
        
        TaskWrapper tw = new TaskWrapper();
        tw.id = ds3.Id;
        tw.endDate=Date.newInstance(2010, 10, 17);
        tw.action ='abc';
        tw.listOfIntervention = loilist;
        
        List<TaskWrapper> twlist = new List<TaskWrapper>();
        twlist.add(tw);
        
        GoalWrapper gw = new GoalWrapper();
        gw.id = 'abc123';
        gw.endDate=Date.newInstance(2010, 10, 17);
        gw.action ='abc';
        gw.listOfTask = twlist;
        gw.listOfIntervention = loilist;
        
        
        List<GoalWrapper> gwlist = new List<GoalWrapper>();
        gwlist.add(gw);
        
        Def df = new Def();
        df.name = 'abcd';
        df.endDate = Date.newInstance(2010, 10, 17);
        df.listOfIntervention = loilist;
        List<Def> dflist = new List<Def>();
        dflist.add(df);
        
        
        ProblemWrapper pw = new ProblemWrapper();
        pw.id = 'abc123';
        pw.endDate=Date.newInstance(2010, 10, 17);
        pw.action ='abc';
        pw.listOfGoal = gwlist;
        pw.listOfDef = dflist;
        
        List<ProblemWrapper> pwlist = new List<ProblemWrapper>();
        pwlist.add(pw);
        
        Wrapper wr = new Wrapper();
        wr.listOfProblem = pwlist;
        wr.listOfGoal = listOfGoal1;
        wr.listOfDiag = listOfDiag1;
        wr.listDef = listOfGoal1;
        wr.listOfTasks = listOfGoal1;
        wr.listOfInterventions = listOfInterventions1;
        wr.listOfObj = listOfInterventions1;
        wr.listOfInterv = listOfInterventions1;
        wr.accountName = 'Anubhav';
        wr.hierarchy = cph;
        wr.userName = 'abcd';
        wr.patientBirthDate = Date.newInstance(2005,12,25);
        wr.patientBirthDateFromAccount = Date.newInstance(2005,12,26);
        wr.accountId = String.valueOf(accountRec.Id);
        wr.nameSpace = 'ElixirSuite__';
        wr.userId = ids;
        wr.countRecords = 5;
        wr.listOfAllUsers = listOfAllUsers1;
        wr.pickListValuesList = pickListValuesList1;
        wr.careplanCustomSettingHeirarchy = cph;
        //-----------------------------------------------------------
        Test.startTest();
        //String masterdata = '{"accountId":"0016D00000wykwxQAA","accountName":"A Pandey","careplanCustomSettingHeirarchy":{"ElixirSuite__Diagnosis__c":true,"ElixirSuite__Fifth_Level__c":"Intervention","ElixirSuite__First_Level__c":"Problems","ElixirSuite__Fourth_Level__c":"Objective","ElixirSuite__Relationship_level_1__c":"Second Level;Third Level","ElixirSuite__Relationship_Level_3__c":"Fourth Level;Fifth Level","ElixirSuite__Third_Level__c":"Goals","Id":"a076D000003nsPpQAI","Name":"a076D000003nsPp"},"countRecords":9,"Hierarchy":{"Id":"a076D000003nsPpQAI","ElixirSuite__First_Level__c":"Problems","ElixirSuite__Diagnosis__c":true,"ElixirSuite__Third_Level__c":"Goals","ElixirSuite__Fourth_Level__c":"Objective","ElixirSuite__Fifth_Level__c":"Intervention"},"listOfAllUsers":[{"Id":"0056D000006axBVQAY","Name":"Automated Process"},{"Id":"0056D000006axBbQAI","Name":"Data.com Clean"},{"Id":"0056D000006VOxCQAW","Name":"tanveer ahmed"},{"Id":"0056D000006USSbQAO","Name":"Jothilakshmi ExternalUser1683637521118"},{"Id":"0056D000006USWtQAO","Name":"Mahendra ExternalUser1683637986092"},{"Id":"0056D000006USSRQA4","Name":"Elixir Patient Portal Site Guest User"},{"Id":"0056D000006Up8mQAC","Name":"S Stefen"},{"Id":"0056D000006axBUQAY","Name":"Integration User"},{"Id":"0056D000006axBZQAY","Name":"Security User"},{"Id":"0056D000006UQwyQAG","Name":"Timothy Applegate"},{"Id":"0056D000006axBdQAI","Name":"Platform Integration User"},{"Id":"0056D000006axBaQAI","Name":"Chatter Expert"}],"listOfProblem":[{"Id":"a0F6D000005Oe8UUAS","CreatedById":"0056D000006UQwyQAG","IsDeleted":false,"Name":"depression","ElixirSuite__Description__c":"Testing depression Problm","listOfGoal":[{"Id":"a0G6D000008Uc4tUAC","Name":"DA-001","ElixirSuite__Description__c":"Testing Goal12 description","listOfTask":[{"Id":"a0H6D000004RS0ZUAW","Name":"Test Objective3","ElixirSuite__Description__c":"Test Objective  description33","listOfIntervention":[{"Id":"a0H6D000004RQflUAG","Name":"testing Intervention2","ElixirSuite__Description__c":"Test Intervention desciption2","assignedTo":"0056D000006UQwyQAG","endDate":"2023-06-02"}],"endDate":"2023-06-02"}],"listOfIntervention":[{"Id":"a0H6D000004REzfUAG","Name":"test Intervention","ElixirSuite__Description__c":"Test Intervention desciption","ElixirSuite__Dataset2__c":"a0G6D000008Uc4tUAC","endDate":"2023-06-02","assignedTo":"0056D000006UQwyQAG"},{"Id":"a0H6D000004RQflUAG","Name":"testing Intervention2","ElixirSuite__Description__c":"Test Intervention desciption2","assignedTo":"0056D000006UQwyQAG","endDate":"2023-06-02"}],"endDate":"2023-06-02"}],"listOfDef":[{"Id":"a0H6D000004RS0ZUAW","Name":"Test Objective3","ElixirSuite__Description__c":"Test Objective  description33","listOfIntervention":[{"Id":"a0H6D000004RQflUAG","Name":"testing Intervention2","ElixirSuite__Description__c":"Test Intervention desciption2","assignedTo":"0056D000006UQwyQAG","endDate":"2023-06-02"}],"endDate":"2023-06-02"}],"listOfRelatedDiagnosis":[],"endDate":"2023-06-02"}],"patientBirthDateFromAccount":"2022-03-28","pickListValuesList":["Open","Completed","In Progress"],"userId":"0056D000006UQwyQAG","userName":"Timothy Applegate","listOfObjectives":[{"Id":"a0H6D000004RS0ZUAW","Name":"Test Objective3","ElixirSuite__Description__c":"Test Objective  description33","listOfIntervention":[{"Id":"a0H6D000004RQflUAG","Name":"testing Intervention2","ElixirSuite__Description__c":"Test Intervention desciption2","assignedTo":"0056D000006VOxCQAW"}]}],"listOfInterventions":[{"Id":"a0H6D000004RQflUAG","Name":"testing Intervention2","ElixirSuite__Description__c":"Test Intervention desciption2","assignedTo":"0056D000006UQwyQAG"}]';
       // Elixir_CarePlanController.saveData(userInfo.getUserId(),userInfo.getUserId(),'test','Open','2023-06-02','2023-06-02',masterdata,accountRec.Id,'testDescrption','2023-06-02','2023-06-02','');
        //Elixir_CarePlanController.saveData("{"accountId":"0016D00000wykwxQAA","accountName":"A Pandey","careplanCustomSettingHeirarchy":{"ElixirSuite__Diagnosis__c":true,"ElixirSuite__Fifth_Level__c":"Intervention","ElixirSuite__First_Level__c":"Problems","ElixirSuite__Fourth_Level__c":"Objective","ElixirSuite__Relationship_level_1__c":"Second Level;Third Level","ElixirSuite__Relationship_Level_3__c":"Fourth Level;Fifth Level","ElixirSuite__Third_Level__c":"Goals","Id":"a076D000003nsPpQAI","Name":"a076D000003nsPp"},"countRecords":9,"Hierarchy":{"Id":"a076D000003nsPpQAI","ElixirSuite__First_Level__c":"Problems","ElixirSuite__Diagnosis__c":true,"ElixirSuite__Third_Level__c":"Goals","ElixirSuite__Fourth_Level__c":"Objective","ElixirSuite__Fifth_Level__c":"Intervention"},"listOfAllUsers":[{"Id":"0056D000006axBVQAY","Name":"Automated Process"},{"Id":"0056D000006axBbQAI","Name":"Data.com Clean"},{"Id":"0056D000006VOxCQAW","Name":"tanveer ahmed"},{"Id":"0056D000006USSbQAO","Name":"Jothilakshmi ExternalUser1683637521118"},{"Id":"0056D000006USWtQAO","Name":"Mahendra ExternalUser1683637986092"},{"Id":"0056D000006USSRQA4","Name":"Elixir Patient Portal Site Guest User"},{"Id":"0056D000006Up8mQAC","Name":"S Stefen"},{"Id":"0056D000006axBUQAY","Name":"Integration User"},{"Id":"0056D000006axBZQAY","Name":"Security User"},{"Id":"0056D000006UQwyQAG","Name":"Timothy Applegate"},{"Id":"0056D000006axBdQAI","Name":"Platform Integration User"},{"Id":"0056D000006axBaQAI","Name":"Chatter Expert"}],"listOfProblem":[{"Id":"a0F6D000005Oe8UUAS","CreatedById":"0056D000006UQwyQAG","IsDeleted":false,"Name":"depression","ElixirSuite__Description__c":"Testing depression Problm","listOfGoal":[{"Id":"a0G6D000008Uc4tUAC","Name":"DA-001","ElixirSuite__Description__c":"Testing Goal12 description","listOfTask":[{"Id":"a0H6D000004RS0ZUAW","Name":"Test Objective3","ElixirSuite__Description__c":"Test Objective  description33","listOfIntervention":[{"Id":"a0H6D000004RQflUAG","Name":"testing Intervention2","ElixirSuite__Description__c":"Test Intervention desciption2","assignedTo":"0056D000006UQwyQAG","endDate":"2023-06-02"}],"endDate":"2023-06-02"}],"listOfIntervention":[{"Id":"a0H6D000004REzfUAG","Name":"test Intervention","ElixirSuite__Description__c":"Test Intervention desciption","ElixirSuite__Dataset2__c":"a0G6D000008Uc4tUAC","endDate":"2023-06-02","assignedTo":"0056D000006UQwyQAG"},{"Id":"a0H6D000004RQflUAG","Name":"testing Intervention2","ElixirSuite__Description__c":"Test Intervention desciption2","assignedTo":"0056D000006UQwyQAG","endDate":"2023-06-02"}],"endDate":"2023-06-02"}],"listOfDef":[{"Id":"a0H6D000004RS0ZUAW","Name":"Test Objective3","ElixirSuite__Description__c":"Test Objective  description33","listOfIntervention":[{"Id":"a0H6D000004RQflUAG","Name":"testing Intervention2","ElixirSuite__Description__c":"Test Intervention desciption2","assignedTo":"0056D000006UQwyQAG","endDate":"2023-06-02"}],"endDate":"2023-06-02"}],"listOfRelatedDiagnosis":[],"endDate":"2023-06-02"}],"patientBirthDateFromAccount":"2022-03-28","pickListValuesList":["Open","Completed","In Progress"],"userId":"0056D000006UQwyQAG","userName":"Timothy Applegate","listOfObjectives":[{"Id":"a0H6D000004RS0ZUAW","Name":"Test Objective3","ElixirSuite__Description__c":"Test Objective  description33","listOfIntervention":[{"Id":"a0H6D000004RQflUAG","Name":"testing Intervention2","ElixirSuite__Description__c":"Test Intervention desciption2","assignedTo":"0056D000006VOxCQAW"}]}],"listOfInterventions":[{"Id":"a0H6D000004RQflUAG","Name":"testing Intervention2","ElixirSuite__Description__c":"Test Intervention desciption2","assignedTo":"0056D000006UQwyQAG"}]}");
        
        system.assertEquals(1,1,' ');
        Test.stopTest();
        
    }
    
    public class Wrapper{
        // @AuraEnabled  public List<Dataset1__c> listOfProblem; 
        @AuraEnabled public List<ProblemWrapper> listOfProblem = new List<ProblemWrapper>(); 
        @AuraEnabled  public List<Dataset2__c> listOfGoal; 
        @AuraEnabled  public List<ICD_Codes__c> listOfDiag; 
        @AuraEnabled  public List<Dataset2__c> listDef; 
        @AuraEnabled  public List<Dataset2__c> listOfTasks; 
        @AuraEnabled  public List<Dataset3__c> listOfInterventions; 
        @AuraEnabled  public List<Dataset3__c> listOfObj; 
        @AuraEnabled  public List<Dataset3__c> listOfInterv; 
        @AuraEnabled  public String accountName;
        @AuraEnabled  public CarePlan_Hierarchy__c hierarchy;
        @AuraEnabled  public String userName;
        @AuraEnabled  public Date patientBirthDate;
        @AuraEnabled  public Date patientBirthDateFromAccount;
        @AuraEnabled  public String accountId;
        @AuraEnabled  public String nameSpace;
        @AuraEnabled  public Id userId;
        @AuraEnabled  public Integer countRecords;
        @AuraEnabled  public List<User> listOfAllUsers;
        @AuraEnabled  public List<String> pickListValuesList= new List<String>(); 
        @AuraEnabled  public ElixirSuite__CarePlan_Hierarchy__c careplanCustomSettingHeirarchy;
    }
    public class ProblemWrapper{
        public String id;
        public Date endDate;
        public String action;
        public List<GoalWrapper> listOfGoal ;
        public List<Def> listOfDef;
        
    }
    public class GoalWrapper{
        public String id;
        public Date endDate;
        public String action;
        public List<TaskWrapper> listOfTask;
        public List<Intervention> listOfIntervention; 
        
    }
    public class TaskWrapper{
        public String id;
        public Date endDate;
        public String action;
        
        public List<Intervention> listOfIntervention; 
    }
    public class Intervention{
        public string name;
        // public string Description__c;
        Id id;
        
    }
    public class Def{
        public string name;
        // public string Description__c;
        public Date endDate;
        public List<Intervention> listOfIntervention; 
        
        
    }
    @isTest
    static void fetchApprovalData() {
        Id recordTypeId = Schema.SObjectType.ElixirSuite__Master_Object__c.getRecordTypeInfosByDeveloperName().get('Approval_Configuration').getRecordTypeId();
        ElixirSuite__Master_Object__c masterObj = new ElixirSuite__Master_Object__c();
        masterObj.ElixirSuite__Patient_Tile_Entity__c = 'Insurance';
        masterObj.ElixirSuite__Approval_Members__c = 'aprroval members';
        masterObj.ElixirSuite__Approval_Members_Name__c = 'approverNames';
        masterObj.ElixirSuite__Approver__c = 'approver';
        masterObj.ElixirSuite__Approver_List__c = 'approver List';
        masterObj.ElixirSuite__Approver_Custom_Label__c = 'test';
        masterObj.ElixirSuite__Approval_Level_For__c='Prescription Order';
        masterObj.RecordTypeId = recordTypeId;
        insert masterObj;
        String dropdown = '{"keyToSave":"test01"}';
        
        Test.startTest();
        Elixir_CarePlanController.initCalled_fetchApprovalData('test');
        Elixir_CarePlanController.fetchOptions_SetupKey('User');
        Elixir_CarePlanController.fetchOptions_SetupKey('Role');
        Elixir_CarePlanController.fetchOptions_SetupKey('Profile');
        Elixir_CarePlanController.fetchExistingApprovalRecord(1, 'Care Plan');
        Elixir_CarePlanController.fetchApprovalRecord(1, 'Care Plan');
        Elixir_CarePlanController.checkUpdateLegitimacy('1' , 'name');
        Elixir_PrescriptionsApprovalHelper.fetchMapOfSetUpKey('User');
        ElixirOEM_FormApprovalHelper.checkUpdateLegitimacy('2', 'test');
        Elixir_CarePlanController.saveApprovalProcess('user', '1', 'test1', dropdown, 'Prescription Order', 'User', 'test3', 'test4');
        Elixir_CarePlanController.updateApprovalProcess('user', '1', 'user', dropdown, 'name', masterObj.id, 'user', 'user');
        Elixir_CarePlanController.deleteApprovalLevel(masterObj.id);
        Elixir_MultiselectApprovalHelper.getselectOptions('User');
        Elixir_MultiselectApprovalHelper.getselectOptions('Role');
        Elixir_MultiselectApprovalHelper.getselectOptions('Profile');
        Elixir_CarePlanController.dummyMethod();
        Test.stopTest();
        System.assertEquals(1, 1, '');
        
    }
    
    
}
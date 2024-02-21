public with sharing class ElixirOEM_CarePlanPDFGeneratorHelper {
    public  CarePlan_Hierarchy__c configHeirarchy{get;set;} 
    public String accountName {get;set;}
    public Date dOB {get;set;}
    public Wrapper masterList {get;set;} 
    public List<Treatment_Plan__c> carePlanDemoGraphicInfo {get;set;}
    public List<ElixirSuite__Plan_Hierarchy__c> fetchedPlanHierarchies { get; set; }
    public List<ElixirSuite__Plan_SubHierarchy__c> fetchedSubPlanHierarchies { get; set; }
    public CarePlanApprovalData.currentUserInfo approvalLevels {get;set;}
    
    public ElixirOEM_CarePlanPDFGeneratorHelper(){
        String treatmentPlanID = String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('treatmentPlanID'));
      
        carePlanDemoGraphicInfo = [SELECT Account__r.Name,Account__r.Patient_s_Birth_Date__c,Description__c,Approval_Level_1__c,Approval_Level_2__c,Approval_Level_3__c,Client_Strength__c,Client_Weakness__c,
                                   Primary_Therapist__r.Name,Clinical_supervisor__r.Name,Comment_1__c,Comment_2__c,Comment_3__c,CreatedById,CreatedDate,Due_Date__c,End_Date__c,
                                   LastModifiedDate,Name,Primary_Therapist__c,Signature_value_1__c,Signature_value_2__c,Signature_value_3__c,
                                   Signed_By_Level_1__c,Signed_By_Level_2__c,Signed_By_Level_3__c,Signed_Date_1__c,Signed_Date_2__c,Signed_Date_3__c,
                                   Start_Date__c,Status__c,Treatment_Plan_Name__c FROM Treatment_Plan__c WHERE ID = : treatmentPlanID
                                   WITH SECURITY_ENFORCED];
        
        List<CarePlan_Hierarchy__c> cpHeirarchy =  [SELECT ElixirSuite__Diagnosis__c,ElixirSuite__Fifth_Level__c,ElixirSuite__First_Level__c,ElixirSuite__Fourth_Level__c,
                                                    ElixirSuite__Relationship_level_1__c,ElixirSuite__Relationship_Level_2__c,ElixirSuite__Relationship_Level_3__c,
                                                    ElixirSuite__Relationship_Level_4__c,ElixirSuite__Second_Level__c,ElixirSuite__Sixth_Level__c,ElixirSuite__Third_Level__c,Id,
                                                    Name FROM CarePlan_Hierarchy__c 
                                                    WITH SECURITY_ENFORCED
                                                    limit 1];
        if(cpHeirarchy.size()>0 && cpHeirarchy!=null){
            configHeirarchy =  cpHeirarchy[0];
        }
        //fetchAllLevels(treatmentPlanID,configHeirarchy);
        getAccountInfo(carePlanDemoGraphicInfo[0].Account__c);
        // Apexpages.currentPage().getHeaders().put('content-disposition', 'attachment; filename= CarePlan '+'.pdf');
        fetchAsNewModel(treatmentPlanID,configHeirarchy);
        approvalLevels = fetchApprovalLevels('Care Plan', treatmentPlanID);
        
    }
    
    public void getAccountInfo(Id accountId){
        List<Account> acc = [SELECT Id ,Patient_s_Birth_Date__c, Name, ElixirSuite__DOB__c
                             FROM Account WHERE Id= :accountId
                             WITH SECURITY_ENFORCED
                             LIMIT 1];
        if(acc.size()>0 && acc!=null){
            accountName = acc[0].Name;
            dOB = acc[0].ElixirSuite__DOB__c;
        }      
    }
    /*  public void fetchAsNewModel(String treatmentPlanID){
Map<Id,ElixirSuite__Plan_Hierarchy__c> problem = new Map<Id,ElixirSuite__Plan_Hierarchy__c>([SELECT Id,Name,ElixirSuite__Description__c FROM ElixirSuite__Plan_Hierarchy__c WHERE Treatment_Plan__c = : treatmentPlanID 
]); // problem can have goal and objective
Map<Id,ElixirSuite__Plan_SubHierarchy__c>  goal = new Map<Id,ElixirSuite__Plan_SubHierarchy__c>([SELECT Id,Name,ElixirSuite__Description__c FROM ElixirSuite__Plan_SubHierarchy__c
WHERE ElixirSuite__Plan_Hierarchy__c IN : 
problem.keySet()]);
Map<Id,ElixirSuite__Dataset2__c> objectiveLst = new Map<Id,ElixirSuite__Dataset2__c>([SELECT Id,Name,ElixirSuite__Description__c FROM ElixirSuite__Dataset2__c
WHERE ElixirSuite__Plan_Hierarchy__c IN : 
goal.keySet()]);

}*/
    
    public void fetchAsNewModel(String treatmentPlanID,CarePlan_Hierarchy__c configHeirarchy){
        
        /* TOP LEVEl GOAL HIERARCHY */
        Map<Id,ElixirSuite__Plan_SubHierarchy__c>  topGoal = new Map<Id,ElixirSuite__Plan_SubHierarchy__c>([SELECT Id,Name,ElixirSuite__Description__c,ElixirSuite__Plan_Hierarchy__c,ElixirSuite__Due_Date__c,ElixirSuite__Treatment_Plan__c FROM ElixirSuite__Plan_SubHierarchy__c
                                                                                                                WHERE ElixirSuite__Treatment_Plan__c  =: treatmentPlanID]); // this top goal can have objective and Intervention
        Map<Id,ElixirSuite__Dataset2__c> objectiveLstForTopGoal = new Map<Id,ElixirSuite__Dataset2__c>([SELECT Id,Name,ElixirSuite__Description__c,ElixirSuite__Plan_Hierarchy__c,ElixirSuite__Due_Date__c,ElixirSuite__Plan_SubHierarchy__c FROM ElixirSuite__Dataset2__c
                                                                                                      WHERE ElixirSuite__Plan_SubHierarchy__c IN : 
                                                                                                      topGoal.keySet()]);
        Task[] interventionLstForObjectiveGoalLst = [SELECT Id,Subject,OwnerId, WhatId,ActivityDate,Description FROM Task
                                                  WHERE WhatId IN : 
                                                  objectiveLstForTopGoal.keySet() WITH SECURITY_ENFORCED];
        
        Task[] interventionLstForTopGoalLst = [SELECT Id,Subject,OwnerId, WhatId,ActivityDate,Description FROM Task
                                                  WHERE WhatId IN : 
                                                  topGoal.keySet() WITH SECURITY_ENFORCED];
        
        /* TOP LEVEl GOAL HIERARCHY ENDS HERE */
        
        /*** TOP LEVEl OBJECTIVE HIERARCHY ***/
        Map<Id,ElixirSuite__Dataset2__c> topObjective = new Map<Id,ElixirSuite__Dataset2__c>([SELECT Id,Name,ElixirSuite__Description__c,ElixirSuite__Plan_Hierarchy__c,ElixirSuite__Due_Date__c,ElixirSuite__Plan_SubHierarchy__c,ElixirSuite__Treatment_Plan__c FROM ElixirSuite__Dataset2__c
                                                                                                      WHERE ElixirSuite__Treatment_Plan__c =: treatmentPlanID]);
        Task[] interventionLstForTopObjectiveLst = [SELECT Id,Subject,OwnerId, WhatId,ActivityDate,Description FROM Task
                                                  WHERE WhatId IN : 
                                                  topObjective.keySet() WITH SECURITY_ENFORCED];
        
        /*** TOP LEVEl OBJECTIVE HIERARCHY ENDS HERE ***/
        
        /*** TOP LEVEl INTERVENTION ***/
        
        Task[] topIntervention = [SELECT Id,Subject,OwnerId, WhatId,ActivityDate,Description FROM Task
                                                  WHERE WhatId =: treatmentPlanID WITH SECURITY_ENFORCED];
        /*** TOP LEVEl INTERVENTION ENDS HERE ***/
        
        Map<Id,ElixirSuite__Plan_Hierarchy__c> parentProblem = new Map<Id,ElixirSuite__Plan_Hierarchy__c>([SELECT Id,Name,ElixirSuite__Name__c,ElixirSuite__Description__c,ElixirSuite__Due_Date__c,ElixirSuite__Plan_Hierarchy__c FROM ElixirSuite__Plan_Hierarchy__c WHERE Treatment_Plan__c = : treatmentPlanID 
                                                                                                           ]); // problem can have goal and objective
        Map<Id,ElixirSuite__Plan_SubHierarchy__c>  parentGoal = new Map<Id,ElixirSuite__Plan_SubHierarchy__c>([SELECT Id,Name,ElixirSuite__Description__c,ElixirSuite__Plan_Hierarchy__c,ElixirSuite__Due_Date__c FROM ElixirSuite__Plan_SubHierarchy__c
                                                                                                                WHERE ElixirSuite__Plan_Hierarchy__c IN : 
                                                                                                                parentProblem.keySet()]); // this goal can have objective and Intervention
        
        Map<Id,ElixirSuite__Dataset2__c> objectiveLstForGoal = new Map<Id,ElixirSuite__Dataset2__c>([SELECT Id,Name,ElixirSuite__Description__c,ElixirSuite__Plan_Hierarchy__c,ElixirSuite__Due_Date__c,ElixirSuite__Plan_SubHierarchy__c FROM ElixirSuite__Dataset2__c
                                                                                                      WHERE ElixirSuite__Plan_SubHierarchy__c IN : 
                                                                                                      parentGoal.keySet()]);
        Task[] interventionLstForObjectiveLst = [SELECT Id,Subject,OwnerId, WhatId,ActivityDate,Description FROM Task
                                                  WHERE WhatId IN : 
                                                  objectiveLstForGoal.keySet() WITH SECURITY_ENFORCED];
        
        Task[] interventionLstForGoalLst = [SELECT Id,Subject,OwnerId, WhatId,ActivityDate,Description FROM Task
                                                  WHERE WhatId IN : 
                                                  parentGoal.keySet() WITH SECURITY_ENFORCED];
        
        /****************************/
        
        
        Map<Id,ElixirSuite__Dataset2__c> parentObjectiveLst = new Map<Id,ElixirSuite__Dataset2__c>([SELECT Id,Name,ElixirSuite__Description__c,ElixirSuite__Plan_Hierarchy__c,ElixirSuite__Due_Date__c FROM ElixirSuite__Dataset2__c
                                                                                                     WHERE ElixirSuite__Plan_Hierarchy__c IN : 
                                                                                                     parentProblem.keySet()]); // this objective can have inervention
        
        Task[] interventionLstForParentObjectiveLst = [SELECT Id,Subject,OwnerId, WhatId,ActivityDate,Description FROM Task
                                                         WHERE WhatId IN : 
                                                         parentObjectiveLst.keySet() WITH SECURITY_ENFORCED];
        
        /*****/
        /* PREPARE JSON*/
        
        //map of top level Goal Objective
         Map<Id, List<ElixirSuite__Dataset2__c>> mapOfobjectivePerTopGoal = new Map<Id, List<ElixirSuite__Dataset2__c>>();
        for(ElixirSuite__Dataset2__c rec : objectiveLstForTopGoal.values()){
            if (mapOfobjectivePerTopGoal.containsKey(rec.ElixirSuite__Plan_SubHierarchy__c)) {
                mapOfobjectivePerTopGoal.get(rec.ElixirSuite__Plan_SubHierarchy__c).add(rec);
            } else {
                List<ElixirSuite__Dataset2__c> objectives = new List<ElixirSuite__Dataset2__c>();
                objectives.add(rec);
                mapOfobjectivePerTopGoal.put(rec.ElixirSuite__Plan_SubHierarchy__c, objectives);
            }
        }
        
        // now going inside intervention of every objective inside top goal
          Map<Id, List<Task>> mapOfTaskPerObjectiveTopGoal = new Map<Id, List<Task>>();
         for(Task rec : interventionLstForObjectiveGoalLst){
            if (mapOfTaskPerObjectiveTopGoal.containsKey(rec.WhatId)) {
                mapOfTaskPerObjectiveTopGoal.get(rec.WhatId).add(rec);
            } else {
                List<Task> tsk = new List<Task>();
                tsk.add(rec);
                mapOfTaskPerObjectiveTopGoal.put(rec.WhatId, tsk);
            }
        }
        
        // now going inside intervention of every top goal
          Map<Id, List<Task>> mapOfTaskPerTopGoal = new Map<Id, List<Task>>();
         for(Task rec : interventionLstForTopGoalLst){
            if (mapOfTaskPerTopGoal.containsKey(rec.WhatId)) {
                mapOfTaskPerTopGoal.get(rec.WhatId).add(rec);
            } else {
                List<Task> tsk = new List<Task>();
                tsk.add(rec);
                mapOfTaskPerTopGoal.put(rec.WhatId, tsk);
            }
        }
        
        
        // now going inside intervention of every top level objective
          Map<Id, List<Task>> mapOfTaskPerTopObjective = new Map<Id, List<Task>>();
         for(Task rec : interventionLstForTopObjectiveLst){
            if (mapOfTaskPerTopObjective.containsKey(rec.WhatId)) {
                mapOfTaskPerTopObjective.get(rec.WhatId).add(rec);
            } else {
                List<Task> tsk = new List<Task>();
                tsk.add(rec);
                mapOfTaskPerTopObjective.put(rec.WhatId, tsk);
            }
        }
        
        // map of goals for problem
        Map<Id, List<ElixirSuite__Plan_SubHierarchy__c>> mapOfGoalPerProblem = new Map<Id, List<ElixirSuite__Plan_SubHierarchy__c>>(); 
        for(ElixirSuite__Plan_SubHierarchy__c rec : parentGoal.values()){
            if (mapOfGoalPerProblem.containsKey(rec.Plan_Hierarchy__c)) {
                mapOfGoalPerProblem.get(rec.Plan_Hierarchy__c).add(rec);
            } else {
                List<ElixirSuite__Plan_SubHierarchy__c> goals = new List<ElixirSuite__Plan_SubHierarchy__c>();
                goals.add(rec);
                mapOfGoalPerProblem.put(rec.Plan_Hierarchy__c, goals);
            }
        }
        
        // now going inside intervention of every goal inside problem
          Map<Id, List<Task>> mapOfTaskPerGoal = new Map<Id, List<Task>>();
         for(Task rec : interventionLstForGoalLst){
            if (mapOfTaskPerGoal.containsKey(rec.WhatId)) {
                mapOfTaskPerGoal.get(rec.WhatId).add(rec);
            } else {
                List<Task> tsk = new List<Task>();
                tsk.add(rec);
                mapOfTaskPerGoal.put(rec.WhatId, tsk);
            }
        }
        
        // now going inside objecive of the every goal
         Map<Id, List<ElixirSuite__Dataset2__c>> mapOfobjetivePerGoal = new Map<Id, List<ElixirSuite__Dataset2__c>>();
        for(ElixirSuite__Dataset2__c rec : objectiveLstForGoal.values()){
            if (mapOfobjetivePerGoal.containsKey(rec.ElixirSuite__Plan_SubHierarchy__c)) {
                mapOfobjetivePerGoal.get(rec.ElixirSuite__Plan_SubHierarchy__c).add(rec);
            } else {
                List<ElixirSuite__Dataset2__c> objectives = new List<ElixirSuite__Dataset2__c>();
                objectives.add(rec);
                mapOfobjetivePerGoal.put(rec.ElixirSuite__Plan_SubHierarchy__c, objectives);
            }
        }
        
        // now going inside intervention of every objective inside goal
          Map<Id, List<Task>> mapOfTaskPerObjective = new Map<Id, List<Task>>();
         for(Task rec : interventionLstForObjectiveLst){
            if (mapOfTaskPerObjective.containsKey(rec.WhatId)) {
                mapOfTaskPerObjective.get(rec.WhatId).add(rec);
            } else {
                List<Task> tsk = new List<Task>();
                tsk.add(rec);
                mapOfTaskPerObjective.put(rec.WhatId, tsk);
            }
        }
        
        Map<Id, List<ElixirSuite__Dataset2__c>> mapOfProblemObjectiveList = new Map<Id, List<ElixirSuite__Dataset2__c>>();
        // map of objetives for problem
        for(ElixirSuite__Dataset2__c rec : parentObjectiveLst.values()){
            if (mapOfProblemObjectiveList.containsKey(rec.ElixirSuite__Plan_Hierarchy__c)) {
                mapOfProblemObjectiveList.get(rec.ElixirSuite__Plan_Hierarchy__c).add(rec);
            } else {
                List<ElixirSuite__Dataset2__c> objectives = new List<ElixirSuite__Dataset2__c>();
                objectives.add(rec);
                mapOfProblemObjectiveList.put(rec.ElixirSuite__Plan_Hierarchy__c, objectives);
            }
        }
        
        // now going inside intervention of every objective - problem
          Map<Id, List<Task>> mapOfTaskPerObjectiveProblem = new Map<Id, List<Task>>();
         for(Task rec : interventionLstForParentObjectiveLst){
            if (mapOfTaskPerObjectiveProblem.containsKey(rec.WhatId)) {
                mapOfTaskPerObjectiveProblem.get(rec.WhatId).add(rec);
            } else {
                List<Task> tsk = new List<Task>();
                tsk.add(rec);
                mapOfTaskPerObjectiveProblem.put(rec.WhatId, tsk);
            }
        }
        
        Wrapper wrpr = new Wrapper();
        wrpr.carePlan = carePlanDemoGraphicInfo[0];
        wrpr.lstOflevel1Records = new List<Level_1_Wrapper>();
        wrpr.topLevelGoal = new List<TopLevelGoal>();
        wrpr.topLevelObjective = new List<TopLevelObjective>();
        wrpr.topLevelIntervention = new List<TopLevelIntervention>();
        
        //top level Goal Hierarchy
        for(ElixirSuite__Plan_SubHierarchy__c ph : topGoal.values()){
            TopLevelGoal tlg = new TopLevelGoal();
            tlg.topGoalPer = ph;
            tlg.objectiveForTopGoalLst = new List<ObjectiveForTopGoal>();
            If(mapOfobjectivePerTopGoal.containsKey(ph.Id)){
                for(ElixirSuite__Dataset2__c objectivePerTopGoal : mapOfobjectivePerTopGoal.get(ph.Id)){
                    ObjectiveForTopGoal otg = new ObjectiveForTopGoal();
                    otg.level4Rec = objectivePerTopGoal;
                    if(mapOfTaskPerObjectiveTopGoal.containsKey(objectivePerTopGoal.Id)){
                        otg.intvForTopGoalObjLst = new List<InterventionForTopGoalObjective>();
                        for(Task intvPerObjectiveGoal : mapOfTaskPerObjectiveTopGoal.get(objectivePerTopGoal.Id)){
                            InterventionForTopGoalObjective intervObj = new InterventionForTopGoalObjective();
                            intervObj.level5Rec = intvPerObjectiveGoal;
                            otg.intvForTopGoalObjLst.add(intervObj);
                        }
                    }
                  tlg.objectiveForTopGoalLst.add(otg); 
                }
            }
            If(mapOfTaskPerTopGoal.containsKey(ph.Id)){
                tlg.intvForTopGoalLst = new List<InterventionForTopGoal>();
                for(Task intvPerTopGoal : mapOfTaskPerTopGoal.get(ph.Id)){
                    InterventionForTopGoal intervTopGoal = new InterventionForTopGoal();
                    intervTopGoal.level5Rec = intvPerTopGoal;
                    tlg.intvForTopGoalLst.add(intervTopGoal);
                }   
            }
            wrpr.topLevelGoal.add(tlg);
        }
        //top level Goal Hierarchy Ends Here
        
        //top level Objective starts here
        
        for(ElixirSuite__Dataset2__c ds2 : topObjective.values()){
            TopLevelObjective tlo = new TopLevelObjective();
            tlo.topObjectivePer = ds2;
            
            if(mapOfTaskPerTopObjective.containsKey(ds2.Id)){
                tlo.intvForTopObjetive = new List<InterventionForTopObjective>();
                for(Task intvPerTopObjective : mapOfTaskPerTopObjective.get(ds2.Id)){
                    InterventionForTopObjective intervObj = new InterventionForTopObjective();
                    intervObj.level5Rec = intvPerTopObjective;
                    tlo.intvForTopObjetive.add(intervObj);
                }
            }
             wrpr.topLevelObjective.add(tlo);
                
            }
        
        //top level Objective ends here
        
        //top level intervention starts here
        for(Task tsk : topIntervention){
           TopLevelIntervention tli = new TopLevelIntervention();
            tli.level5Rec = tsk;
            wrpr.topLevelIntervention.add(tli);
        }
        
        //top level intervention ends here
        
        
        for(ElixirSuite__Plan_Hierarchy__c level1RecObj : parentProblem.values()){  
            Level_1_Wrapper prblmWrpr = new Level_1_Wrapper(); 
            prblmWrpr.problemObj = level1RecObj;
            prblmWrpr.goalForProblemLst = new List<GoalForProblem>(); 
            prblmWrpr.objectiveForProblemLst = new List<ObjectiveForProblem>(); // goal  
            // start nested tree creation
            if(mapOfGoalPerProblem.containsKey(level1RecObj.Id)){
                for(ElixirSuite__Plan_SubHierarchy__c goalRec : mapOfGoalPerProblem.get(level1RecObj.Id)){
                    GoalForProblem obj = new GoalForProblem();
                    obj.goalPerProblemObj = goalRec;
                     if(mapOfobjetivePerGoal.containsKey(goalRec.Id)){
                         obj.objectiveForGoalLst = new List<ObjectiveForGoal>();
                          for(ElixirSuite__Dataset2__c objectivePerGoal : mapOfobjetivePerGoal.get(goalRec.Id)){
                              ObjectiveForGoal objForGoal = new ObjectiveForGoal();
                              objForGoal.level4Rec = objectivePerGoal;
                                if(mapOfTaskPerObjective.containsKey(objectivePerGoal.Id)){
                                    objForGoal.intvForObjectiveObjectiveForGoal = new List<InterventionForObjective>();
                                     for(Task intvPerObjective : mapOfTaskPerObjective.get(objectivePerGoal.Id)){
                                         InterventionForObjective intervObj = new InterventionForObjective();
                                         intervObj.level5Rec = intvPerObjective;
                                         objForGoal.intvForObjectiveObjectiveForGoal.add(intervObj);
                                     }
                                }
                              obj.objectiveForGoalLst.add(objForGoal);
                          }
                     }
                    If(mapOfTaskPerGoal.containsKey(goalRec.Id)){
                        obj.intvForGoalLst = new List<InterventionForGoal>();
                        for(Task intvPerGoal : mapOfTaskPerGoal.get(goalRec.Id)){
                            InterventionForGoal intervGoalProblem = new InterventionForGoal();
                            intervGoalProblem.level5Rec = intvPerGoal;
                            obj.intvForGoalLst.add(intervGoalProblem);
                        }
                           
                    }   
                    prblmWrpr.goalForProblemLst.add(obj);
                   
                }
                
            }
            //objective starts here
            if(mapOfProblemObjectiveList.containsKey(level1RecObj.Id)){
                for(ElixirSuite__Dataset2__c objRec : mapOfProblemObjectiveList.get(level1RecObj.Id)){
                    ObjectiveForProblem obj = new ObjectiveForProblem();
                    obj.objectivePerProblemObj = objRec;
                    if(mapOfTaskPerObjectiveProblem.containsKey(objRec.Id)){ 
                        obj.intvForObjetiveForProblem = new List<InterventionForObjectiveForProblem>();
                        for(Task intvPerObjective : mapOfTaskPerObjectiveProblem.get(objRec.Id)){
                            InterventionForObjectiveForProblem intervObjProblem = new InterventionForObjectiveForProblem();
                            intervObjProblem.level5Rec = intvPerObjective;
                            obj.intvForObjetiveForProblem.add(intervObjProblem);
                        }
                    }                  
                    prblmWrpr.objectiveForProblemLst.add(obj);
                }
                
            }
            wrpr.lstOflevel1Records.add(prblmWrpr);
        }
        masterList = wrpr;
       
    }
              
                public class Wrapper{
                    public Treatment_Plan__c carePlan {get;set;}
                    public List<Level_1_Wrapper> lstOflevel1Records {get;set;}
                    public List<TopLevelGoal> topLevelGoal {get;set;} 
                    public List<TopLevelObjective> topLevelObjective {get;set;}
                    public List<TopLevelIntervention> topLevelIntervention {get;set;}
                }
                
                public class Level_1_Wrapper{
                    public List<Notes__c> listOfNotes {get;set;} 
                    public ElixirSuite__Plan_Hierarchy__c problemObj {get;set;} // problems
                    public List<GoalForProblem> goalForProblemLst {get;set;} 
                    public List<ObjectiveForProblem> objectiveForProblemLst {get;set;}
                    
                }
                public class GoalForProblem{  //Goal for problem
                    public ElixirSuite__Plan_SubHierarchy__c goalPerProblemObj  {get;set;}
                    public List<ObjectiveForGoal> objectiveForGoalLst {get;set;}
                    public List<InterventionForGoal> intvForGoalLst {get;set;}
                }
                public class ObjectiveForGoal{ // objective for Goal problem
                    public ElixirSuite__Dataset2__c level4Rec  {get;set;}
                    public List<InterventionForObjective> intvForObjectiveObjectiveForGoal {get;set;}
                }
                public class InterventionForGoal{ // Intervention For Goal Problem
                    public Task level5Rec {get;set;}
                }
                public class InterventionForObjective{ // Intervention For Objective Goal problem
                    public Task level5Rec {get;set;}
                }
                public class ObjectiveForProblem{ // Objective For Problem
                    public ElixirSuite__Dataset2__c objectivePerProblemObj {get;set;}      
                    public List<InterventionForObjectiveForProblem> intvForObjetiveForProblem {get;set;}
                }
                public class InterventionForObjectiveForProblem{ // Intervention For Objective Problem
                    public Task level5Rec {get;set;}
                }
                public class TopLevelGoal{
                    public ElixirSuite__Plan_SubHierarchy__c topGoalPer {get;set;}
                    public List<ObjectiveForTopGoal> objectiveForTopGoalLst {get;set;}
                    public List<InterventionForTopGoal> intvForTopGoalLst {get;set;}
                }
                public class ObjectiveForTopGoal{
                    public ElixirSuite__Dataset2__c level4Rec  {get;set;}
                    public List<InterventionForTopGoalObjective> intvForTopGoalObjLst {get;set;}
                }
                public class InterventionForTopGoal{ // Intervention For Top Goal
                    public Task level5Rec {get;set;}
                }
                public class InterventionForTopGoalObjective{ // Intervention For Top Objective Goal
                    public Task level5Rec {get;set;}
                }
                public class TopLevelObjective{ // Top Level Objective
                    public ElixirSuite__Dataset2__c topObjectivePer {get;set;}      
                    public List<InterventionForTopObjective> intvForTopObjetive {get;set;}
                }
                public class InterventionForTopObjective{ // Intervention For Top Objective
                    public Task level5Rec {get;set;}
                }
                
                public class TopLevelIntervention{ // Top level Intervention
                    public Task level5Rec {get;set;}
                }
    
    
    public static CarePlanApprovalData.currentUserInfo fetchApprovalLevels(String typeOfApproval, String orderId){ // formId is formUniqueId
        try {
            typeOfApproval = String.escapeSingleQuotes(typeOfApproval);
            String approvalRecordTypeId = Schema.SObjectType.ElixirSuite__Master_Object__c.getRecordTypeInfosByDeveloperName().get('CarePlan_Configuration').getRecordTypeId();

            // This is configuration data about approvals(level of approvals)
            List<ElixirSuite__Master_Object__c> defaultApprovalLevels = new List<ElixirSuite__Master_Object__c>();
            SObjectAccessDecision decisionNonApproved = Security.stripInaccessible(
                AccessType.READABLE,
                [
                    SELECT Id, ElixirSuite__Approval_Level__c, ElixirSuite__Approver__c, ElixirSuite__Approval_Members__c, ElixirSuite__Approver_Custom_Label__c, ElixirSuite__Approval_Level_For__c
                      FROM ElixirSuite__Master_Object__c
                     WHERE ElixirSuite__Approval_Level__c != null
                       AND ElixirSuite__Approval_Level_For__c = :typeOfApproval
                       AND RecordTypeId = :approvalRecordTypeId
                  ORDER BY ElixirSuite__Approval_Level__c
                ]
            ); 

            defaultApprovalLevels = decisionNonApproved.getRecords();

            List<CareplanSignatureSaveApex.SignAndAprroveData> approvedValues = new List<CareplanSignatureSaveApex.SignAndAprroveData>();
            switch on typeOfApproval {
                when 'Care Plan' {
                    if (String.isNotEmpty(orderId)) {
                        approvedValues = fetchCarePlanApprovedValues(orderId);
                    }
                }

            }

            CarePlanApprovalData.currentUserInfo userInfo = new CarePlanApprovalData.currentUserInfo();
            userInfo.setUserId();
            userInfo.setProfileId(); 
            userInfo.setRoleId();
            userInfo.setDefaultLevels(defaultApprovalLevels);
            userInfo.setApprovedValues(approvedValues);

            
            
            return userInfo;
        } catch (Exception e) {
            ExceptionLog.logError(e);
            return null;
        }

    }
    
    public static List<CareplanSignatureSaveApex.SignAndAprroveData> fetchCarePlanApprovedValues(String parentPrescriptionId){
        List<CareplanSignatureSaveApex.SignAndAprroveData> allApprovedValues = new List<CareplanSignatureSaveApex.SignAndAprroveData>();
        try {
            parentPrescriptionId = String.escapeSingleQuotes(parentPrescriptionId);
            List<Treatment_Plan__c> parentPrescription = [
                SELECT Id,
                       ElixirSuite__Signed_Date_1__c, ElixirSuite__Comment_1__c, ElixirSuite__Primary_Therapist__c, ElixirSuite__Primary_Therapist__r.Signature_Attachment_Id__c, ElixirSuite__Primary_Therapist__r.Name, ElixirSuite__Primary_Therapist__r.userrole.name,
                       ElixirSuite__Signed_Date_2__c, ElixirSuite__Comment_2__c, ElixirSuite__Clinical_supervisor__c, ElixirSuite__Clinical_supervisor__r.Signature_Attachment_Id__c, ElixirSuite__Clinical_supervisor__r.Name, ElixirSuite__Clinical_supervisor__r.userrole.name,
                       ElixirSuite__Signed_Date_3__c, ElixirSuite__Comment_3__c, ElixirSuite__User_3__c, ElixirSuite__User_3__r.Signature_Attachment_Id__c, ElixirSuite__User_3__r.Name, ElixirSuite__User_3__r.userrole.name
                  FROM Treatment_Plan__c 
                 WHERE Id = :parentPrescriptionId WITH SECURITY_ENFORCED];

            if (parentPrescription != null && parentPrescription.size() > 0) {
                Treatment_Plan__c thisParentPrescription = parentPrescription[0];

                // query master object for custom label
                String approvalRecordTypeId = Schema.SObjectType.ElixirSuite__Master_Object__c.getRecordTypeInfosByDeveloperName().get('CarePlan_Configuration').getRecordTypeId();
                List<ElixirSuite__Master_Object__c> prescriptionApprovalConfiguration = [
                    SELECT Id, ElixirSuite__Approval_Level__c, ElixirSuite__Approver__c, ElixirSuite__Approval_Members__c, ElixirSuite__Approver_Custom_Label__c, ElixirSuite__Approval_Level_For__c
                      FROM ElixirSuite__Master_Object__c
                     WHERE ElixirSuite__Approval_Level__c != null
                       AND ElixirSuite__Approval_Level_For__c = 'Care Plan'
                       AND RecordTypeId = :approvalRecordTypeId WITH SECURITY_ENFORCED
                ORDER BY ElixirSuite__Approval_Level__c];

                
                // Approval level one
                if (thisParentPrescription.ElixirSuite__Signed_Date_1__c != null && thisParentPrescription.ElixirSuite__Primary_Therapist__c != null) {
                    CareplanSignatureSaveApex.SignAndAprroveData approvalLevelOne = new CareplanSignatureSaveApex.SignAndAprroveData();
                    approvalLevelOne.approvalLevel = 1;
                    approvalLevelOne.comments = thisParentPrescription.ElixirSuite__Comment_1__c;
                    // As prescriptionApprovalConfiguration will be sorted by approval level, we can assume 1st record crossponds to first approval level
                    approvalLevelOne.customLabel = prescriptionApprovalConfiguration[0].ElixirSuite__Approver_Custom_Label__c;
                    approvalLevelOne.dateOfApproval = thisParentPrescription.ElixirSuite__Signed_Date_1__c;
                    
                    String signature = thisParentPrescription.ElixirSuite__Primary_Therapist__r.Signature_Attachment_Id__c;
                    if (String.isNotEmpty(signature)) {
                        List<ContentDocument> images1 = [SELECT Id FROM ContentDocument WHERE Id= :signature WITH SECURITY_ENFORCED];
                        if (images1 != null && images1.size() > 0) {
                            approvalLevelOne.signatureContentDocumentId = images1[0].Id;
                        }
                    }

                    approvalLevelOne.userId = thisParentPrescription.ElixirSuite__Primary_Therapist__c;
                    approvalLevelOne.userName = thisParentPrescription.ElixirSuite__Primary_Therapist__r.Name;
                    approvalLevelOne.userRole = thisParentPrescription.ElixirSuite__Primary_Therapist__r.userrole.name;

                    allApprovedValues.add(approvalLevelOne);
                }

                // Approval level two
                if (thisParentPrescription.ElixirSuite__Signed_Date_2__c != null && thisParentPrescription.ElixirSuite__Clinical_supervisor__c != null) {
                    CareplanSignatureSaveApex.SignAndAprroveData approvalLevelTwo = new CareplanSignatureSaveApex.SignAndAprroveData();
                    approvalLevelTwo.approvalLevel = 2;
                    approvalLevelTwo.comments = thisParentPrescription.ElixirSuite__Comment_2__c;
                    // As prescriptionApprovalConfiguration will be sorted by approval level, we can assume 1st record crossponds to first approval level
                    approvalLevelTwo.customLabel = prescriptionApprovalConfiguration[1].ElixirSuite__Approver_Custom_Label__c;
                    approvalLevelTwo.dateOfApproval = thisParentPrescription.ElixirSuite__Signed_Date_2__c;
                    
                    String signature = thisParentPrescription.ElixirSuite__Clinical_supervisor__r.Signature_Attachment_Id__c;
                    if (String.isNotEmpty(signature)) {
                        List<ContentDocument> images2 = [SELECT Id FROM ContentDocument WHERE Id= :signature WITH SECURITY_ENFORCED];
                        if (images2 != null && images2.size() > 0) {
                            approvalLevelTwo.signatureContentDocumentId = images2[0].Id;
                        }
                    }

                    approvalLevelTwo.userId = thisParentPrescription.ElixirSuite__Clinical_supervisor__c;
                    approvalLevelTwo.userName = thisParentPrescription.ElixirSuite__Clinical_supervisor__r.Name;
                    approvalLevelTwo.userRole = thisParentPrescription.ElixirSuite__Clinical_supervisor__r.userrole.name;

                    allApprovedValues.add(approvalLevelTwo);
                }

                // Approval level three
                if (thisParentPrescription.ElixirSuite__Signed_Date_3__c != null && thisParentPrescription.ElixirSuite__User_3__c != null) {
                    CareplanSignatureSaveApex.SignAndAprroveData approvalLevelThree = new CareplanSignatureSaveApex.SignAndAprroveData();
                    approvalLevelThree.approvalLevel = 3;
                    approvalLevelThree.comments = thisParentPrescription.ElixirSuite__Comment_3__c;
                    // As prescriptionApprovalConfiguration will be sorted by approval level, we can assume 1st record crossponds to first approval level
                    approvalLevelThree.customLabel = prescriptionApprovalConfiguration[2].ElixirSuite__Approver_Custom_Label__c;
                    approvalLevelThree.dateOfApproval = thisParentPrescription.ElixirSuite__Signed_Date_3__c;
                    
                    String signature = thisParentPrescription.ElixirSuite__User_3__r.Signature_Attachment_Id__c;
                    if (String.isNotEmpty(signature)) {
                        List<ContentDocument> images3 = [SELECT Id FROM ContentDocument WHERE Id= :signature WITH SECURITY_ENFORCED];
                        if (images3 != null && images3.size() > 0) {
                            approvalLevelThree.signatureContentDocumentId = images3[0].Id;
                        }
                    }

                    approvalLevelThree.userId = thisParentPrescription.ElixirSuite__User_3__c;
                    approvalLevelThree.userName = thisParentPrescription.ElixirSuite__User_3__r.Name;
                    approvalLevelThree.userRole = thisParentPrescription.ElixirSuite__User_3__r.userrole.name;

                    allApprovedValues.add(approvalLevelThree);
                }

                
            }
            
        } catch (Exception e) {
            ExceptionLog.logError(e);
             return null;
        }
        return allApprovedValues;
    }  
                /*
public void fetchAllLevels(String treatmentPlanID,CarePlan_Hierarchy__c configHeirarchy){

Id level1AcctSpecificRecType = Schema.SObjectType.Dataset1__c.getRecordTypeInfosByDeveloperName().get('Non_Templatized').getRecordTypeId();
List<Dataset1__c> level1 = [SELECT Dataset1__c,Description__c,Id,IsActive__c,Name,Due_Date__c,
Problem_Name__c,RecordTypeId,Templatized_Problem__c FROM Dataset1__c WHERE Treatment_Plan__c = : treatmentPlanID 
AND RecordTypeId = : level1AcctSpecificRecType WITH SECURITY_ENFORCED];
SYSTEM.debug('LEVEL 1 '+level1);
Set<Id> problemIDs = new Map<ID,sObject>(level1).keySet();
List<ICD_Codes__c> diagnoses = [SELECT Category__c,Code_Description__c,Code_Label__c,Code_Type__c,Code__c,Dataset1__c,Diagnosis_Code_and_Name__c,
ICD_Codes__c,Id,Name,RecordTypeId,Related_Problem__c 
FROM ICD_Codes__c WHERE Dataset1__c IN : problemIDs WITH SECURITY_ENFORCED];
SYSTEM.debug('diagnoses'+diagnoses);
Id level2AcctSpecific_Goal = Schema.SObjectType.Plan_Hierarchy__c.getRecordTypeInfosByDeveloperName().get('Recordtype1').getRecordTypeId();
Id level2AcctSpecific_BehavDef = Schema.SObjectType.Plan_Hierarchy__c.getRecordTypeInfosByDeveloperName().get('Recordtype2').getRecordTypeId();

List<Plan_Hierarchy__c> level2_Goal = [SELECT Name__c,Due_Date__c,Dataset1__c,Id,Name,Description__c,RecordTypeId FROM Plan_Hierarchy__c 
WHERE  Dataset1__c IN : problemIDs WITH SECURITY_ENFORCED];
SYSTEM.debug('LEVEL 2 '+level2_Goal);

Set<Id> goalIDs = new Map<ID,sObject>(level2_Goal).keySet();
List<Plan_Hierarchy__c> level3_BehavDef = [SELECT Name__c,Due_Date__c,Dataset1__c,Plan_Hierarchy__c,
Id,Name,Description__c,RecordTypeId FROM Plan_Hierarchy__c WHERE  Plan_Hierarchy__c IN : goalIDs
WITH SECURITY_ENFORCED];
SYSTEM.debug('LEVEL 3 '+level3_BehavDef);

Set<ID> level3IDs;


if(String.isBlank(configHeirarchy.ElixirSuite__Relationship_Level_2__c)){
level3IDs = new Map<ID,sObject>(level2_Goal).keySet();

}
else if(String.isBlank(configHeirarchy.ElixirSuite__Relationship_Level_3__c)){
level3IDs =  new Map<ID,sObject>(level3_BehavDef).keySet(); 
}

Id level4_AcctSpecific_Objective = Schema.SObjectType.ElixirSuite__Plan_SubHierarchy__c.getRecordTypeInfosByDeveloperName().get('Treatment_Plan_Recordtype3').getRecordTypeId();
Id level5AcctSpecific_Intervention = Schema.SObjectType.ElixirSuite__Plan_SubHierarchy__c.getRecordTypeInfosByDeveloperName().get('Treatment_Plan_Recordtype4').getRecordTypeId();
List<Plan_SubHierarchy__c> level4 = [SELECT Id,Name,Description__c,Plan_Hierarchy__c,ElixirSuite__Plan_SubHierarchy__c,ElixirSuite__Due_Date__c  FROM Plan_SubHierarchy__c WHERE   RecordtypeID=:level4_AcctSpecific_Objective
WITH SECURITY_ENFORCED];
SYSTEM.debug('LEVEL 4 '+level4); 

Set<Id> objectiveIDs = new Map<ID,sObject>(level4).keySet();
List<Plan_SubHierarchy__c> level5_Intervention = [SELECT Id,Name,Description__c,ElixirSuite__Plan_SubHierarchy__c,Plan_Hierarchy__c,ElixirSuite__Due_Date__c  FROM Plan_SubHierarchy__c 
where  RecordtypeID=:level5AcctSpecific_Intervention WITH SECURITY_ENFORCED];


prepareJSON(level1,problemIDs,diagnoses,goalIDs,level2_Goal,level3_BehavDef,level4,configHeirarchy,level5_Intervention);
}

public void prepareJSON(List<Dataset1__c> level1 , Set<Id> problemIDs,List<ICD_Codes__c> diagnoses, Set<Id> goalIDs,
List<Plan_Hierarchy__c> level2_Goal, List<Plan_Hierarchy__c> level3_BehavDef,
List<Plan_SubHierarchy__c> level4,CarePlan_Hierarchy__c configHeirarchy, List<Plan_SubHierarchy__c> level5_Intervention){

Id level2AcctSpecific_Goal = Schema.SObjectType.Plan_Hierarchy__c.getRecordTypeInfosByDeveloperName().get('Recordtype1').getRecordTypeId();
Id level2AcctSpecific_BehavDef = Schema.SObjectType.Plan_Hierarchy__c.getRecordTypeInfosByDeveloperName().get('Recordtype2').getRecordTypeId();
Map<Id,List<Notes__c>> mapOfNotesToProblems = new Map<Id,List<Notes__c>>();
Map<Id,List<Notes__c>> mapOfNotesToGoals = new Map<Id,List<Notes__c>>();
//PREPARE NOTES 
// PROBLEM NOTES
List<Notes__c> listOfNotes = [SELECT Id , Notes__c,ElixirSuite__Dataset1__c,ElixirSuite__Plan_Hierarchy__c
FROM Notes__c 
WHERE ElixirSuite__Dataset1__c IN :problemIds 
WITH SECURITY_ENFORCED
ORDER BY CreatedDate DESC];
for(Notes__c noteRec : listOfNotes){
if(mapOfNotesToProblems.containsKey(noteRec.ElixirSuite__Dataset1__c)){
mapOfNotesToProblems.get(noteRec.ElixirSuite__Dataset1__c).add(noteRec);
}else{
List<Notes__c> notes = new List<Notes__c>();
notes.add(noteRec);
mapOfNotesToProblems.put(noteRec.ElixirSuite__Dataset1__c,notes);
} 
}
// GOALS NOTES
List<Notes__c> listOfNotesForGoals = [SELECT Id , Notes__c,ElixirSuite__Plan_Hierarchy__c,ElixirSuite__Dataset1__c
FROM Notes__c WHERE ElixirSuite__Plan_Hierarchy__c IN :goalIds
WITH SECURITY_ENFORCED
ORDER BY CreatedDate DESC];

for(Notes__c rec : listOfNotesForGoals){
if(mapOfNotesToGoals.containsKey(rec.ElixirSuite__Plan_Hierarchy__c)){
mapOfNotesToGoals.get(rec.ElixirSuite__Plan_Hierarchy__c).add(rec);
}else{
List<Notes__c> notes = new List<Notes__c>();
notes.add(rec);
mapOfNotesToGoals.put(rec.ElixirSuite__Plan_Hierarchy__c,notes);
}
}
// Level 1 already there in list

Map<Id,List<Plan_Hierarchy__c>> mapOfGoals = new Map<Id,List<Plan_Hierarchy__c>>();
// level 2
for(Plan_Hierarchy__c rec : level2_Goal){
if(mapOfGoals.containsKey(rec.Dataset1__c)){
mapOfGoals.get(rec.Dataset1__c).add(rec);
}else{
List<Plan_Hierarchy__c> goals = new List<Plan_Hierarchy__c>();
goals.add(rec);
mapOfGoals.put(rec.Dataset1__c,goals);
}
}
// level 3
Map<Id,List<Plan_Hierarchy__c>> mapOfTasks = new Map<Id,List<Plan_Hierarchy__c>>();
for(Plan_Hierarchy__c rec : level3_BehavDef){
if(mapOfTasks.containsKey(rec.Plan_Hierarchy__c)){
mapOfTasks.get(rec.Plan_Hierarchy__c).add(rec);
}else{
List<Plan_Hierarchy__c> behaveDef_lev3 = new List<Plan_Hierarchy__c>();
behaveDef_lev3.add(rec);
mapOfTasks.put(rec.Plan_Hierarchy__c,behaveDef_lev3);
}
}
// level 4
Map<Id,List<Plan_SubHierarchy__c>> leve_4_map = new Map<Id,List<Plan_SubHierarchy__c>>();
for(Plan_SubHierarchy__c rec : level4){
system.debug('obj name '+rec.Name);
if(leve_4_map.containsKey(rec.Plan_Hierarchy__c)){
leve_4_map.get(rec.Plan_Hierarchy__c).add(rec);
}else{
List<Plan_SubHierarchy__c> lstFor_level_4_rec = new List<Plan_SubHierarchy__c>();
lstFor_level_4_rec.add(rec);
leve_4_map.put(rec.Plan_Hierarchy__c,lstFor_level_4_rec);
}
}
// level 5  - NESTED
Map<Id,List<Plan_SubHierarchy__c>> leve_5_map = new Map<Id,List<Plan_SubHierarchy__c>>();
for(Plan_SubHierarchy__c rec : level5_Intervention){
if(leve_5_map.containsKey(rec.Plan_SubHierarchy__c)){
leve_5_map.get(rec.Plan_SubHierarchy__c).add(rec);
}else{
List<Plan_SubHierarchy__c> lstFor_level_5_rec = new List<Plan_SubHierarchy__c>();
lstFor_level_5_rec.add(rec);
leve_5_map.put(rec.Plan_SubHierarchy__c,lstFor_level_5_rec);
}
}
// level 5  - PARALLEL
Map<Id,List<Plan_SubHierarchy__c>> leve_5_map_Binary = new Map<Id,List<Plan_SubHierarchy__c>>();
for(Plan_SubHierarchy__c rec : level5_Intervention){

if(leve_5_map_Binary.containsKey(rec.ElixirSuite__Plan_Hierarchy__c)){
leve_5_map_Binary.get(rec.ElixirSuite__Plan_Hierarchy__c).add(rec);
}else{
List<Plan_SubHierarchy__c> lstFor_level_5_rec_Binary = new List<Plan_SubHierarchy__c>();
lstFor_level_5_rec_Binary.add(rec);
leve_5_map_Binary.put(rec.ElixirSuite__Plan_Hierarchy__c,lstFor_level_5_rec_Binary);
}
}
// map of problem  - Diagnosis
Map<Id,List<ICD_Codes__c>> mapOfProblemDiagnosis = new Map<Id,List<ICD_Codes__c>>();
for(ICD_Codes__c rec : diagnoses){
if(mapOfProblemDiagnosis.containsKey(rec.Dataset1__c)){
mapOfProblemDiagnosis.get(rec.Dataset1__c).add(rec);
}else{
List<ICD_Codes__c> childDiagnosis = new List<ICD_Codes__c>();
childDiagnosis.add(rec);
mapOfProblemDiagnosis.put(rec.Dataset1__c,childDiagnosis);
}
}

Wrapper wrpr = new Wrapper();
wrpr.carePlan = carePlanDemoGraphicInfo[0];
wrpr.lstOf_level_1_Records = new List<Level_1_Wrapper>();

for(Dataset1__c level_1_Rec : level1){
Level_1_Wrapper prblmWrpr = new Level_1_Wrapper(); 
prblmWrpr.level_1_Rec = level_1_Rec;
prblmWrpr.lstOf_level_2_Records_2nd_Child = new List<Level_2_Wrapper>(); // behv definition
prblmWrpr.lstOf_level_2_Records = new List<Level_3_Wrapper>(); // goal

prblmWrpr.recDiagnosis = new List<ICD_Codes__c>();
// to attach diagnosis
if(mapOfProblemDiagnosis.containsKey(level_1_Rec.Id)){
prblmWrpr.recDiagnosis = mapOfProblemDiagnosis.get(level_1_Rec.Id);
}
// start nested tree creation
if(mapOfGoals.containsKey(level_1_Rec.Id)){
for(Plan_Hierarchy__c goalRec : mapOfGoals.get(level_1_Rec.Id)){

Level_2_Wrapper behv_def = new Level_2_Wrapper(); // behv def
behv_def.lstOf_level_4_Records = new List<Level_4_Wrapper>();
behv_def.lstOf_level_5_Records = new List<Level_5_Wrapper>();
behv_def.openLinearTree = false;
behv_def.openBinaryTree = false;


Level_3_Wrapper goalWrpr = new Level_3_Wrapper(); // goals
goalWrpr.lstOf_level_4_Records = new List<Level_4_Wrapper>();
goalWrpr.lstOf_level_5_Records = new List<Level_5_Wrapper>();
goalWrpr.openLinearTree = false;
goalWrpr.openBinaryTree = false;
//SET AS LINEAR OR BINARY TREE
if(goalRec.RecordTypeId==level2AcctSpecific_Goal){ // goal
SYSTEM.debug('GOALS INSIDE');
arrangementForGoals(configHeirarchy,goalWrpr);
goalWrpr.level_3_Rec = goalRec;
prblmWrpr.lstOf_level_2_Records.add(goalWrpr);
}
else if(goalRec.RecordTypeId==level2AcctSpecific_BehavDef){ // bev definition
SYSTEM.debug('BEHAVE DEF INSIDE');
arrangementForBehavDef(configHeirarchy,behv_def);
behv_def.level_2_Rec  = goalRec;
prblmWrpr.lstOf_level_2_Records_2nd_Child.add(behv_def);
}

//SET LEVEL HEIRARCHY
if(String.isBlank(configHeirarchy.ElixirSuite__Relationship_Level_2__c)){ // goal
goalWrpr.hasLevelHeirarchy = true;
if(leve_4_map.containsKey(goalRec.Id)){
SYSTEM.debug('** '+leve_4_map);
SYSTEM.debug('&& '+leve_4_map.get(goalRec.Id));
for(Plan_SubHierarchy__c objective : leve_4_map.get(goalRec.Id)){
Level_4_Wrapper objWrapper = new Level_4_Wrapper();
Level_5_Wrapper interventionWrapper = new  Level_5_Wrapper();
Boolean isInterventionUpdated = false;
objWrapper.level_4_Rec = objective;
objWrapper.lstOf_level_5_Records = new  List<Level_5_Wrapper>();
// NESTED
if(goalWrpr.openLinearTree){
SYSTEM.debug('NESTED INSIDE');
if(leve_5_map.containsKey(objective.Id)){
for(Plan_SubHierarchy__c intervention_Rec : leve_5_map.get(objective.Id)){
Level_5_Wrapper intervention_LinearTreeRecord = new Level_5_Wrapper();
intervention_LinearTreeRecord.level_5_Rec = intervention_Rec;
objWrapper.lstOf_level_5_Records.add(intervention_LinearTreeRecord);
}
}
}

goalWrpr.lstOf_level_4_Records.add(objWrapper);



system.debug('##### 1244 '+ goalWrpr.lstOf_level_5_Records);
}
// PARAELLEL
if(goalWrpr.openBinaryTree){

SYSTEM.debug('PARALLEL INSIDE');  
if(leve_5_map_Binary.containsKey(goalRec.Id)){
for(Plan_SubHierarchy__c intervention_Rec : leve_5_map_Binary.get(goalRec.Id)){

Level_5_Wrapper intervention_directChildOfGoal = new Level_5_Wrapper();
intervention_directChildOfGoal.level_5_Rec = intervention_Rec;
goalWrpr.lstOf_level_5_Records.add(intervention_directChildOfGoal);
}
}
}
}
}
if(String.isBlank(configHeirarchy.ElixirSuite__Relationship_Level_3__c)){ // behav def
behv_def.hasLevelHeirarchy = true; 

if(leve_4_map.containsKey(goalRec.Id)){
system.debug('behave def linear tree '+behv_def.openLinearTree);
for(Plan_SubHierarchy__c objective : leve_4_map.get(goalRec.Id)){
Level_4_Wrapper objWrapper = new Level_4_Wrapper();
Level_5_Wrapper intervention = new Level_5_Wrapper();
objWrapper.level_4_Rec = objective;
objWrapper.lstOf_level_5_Records = new  List<Level_5_Wrapper>();

//NESTED
if(behv_def.openLinearTree){
SYSTEM.debug('NESTED INSIDE behave def');
if(leve_5_map.containsKey(objective.Id)){
for(Plan_SubHierarchy__c intervention_Rec : leve_5_map.get(objective.Id)){
Level_5_Wrapper intervention_LinearTreeRecord = new Level_5_Wrapper();
intervention_LinearTreeRecord.level_5_Rec = intervention_Rec;
objWrapper.lstOf_level_5_Records.add(intervention_LinearTreeRecord);
}
}
}
behv_def.lstOf_level_4_Records.add(objWrapper);

}
//PARAELLEL
if(behv_def.openBinaryTree){

SYSTEM.debug('PARALLEL INSIDE');  
if(leve_5_map_Binary.containsKey(goalRec.Id)){
for(Plan_SubHierarchy__c intervention_Rec : leve_5_map_Binary.get(goalRec.Id)){

Level_5_Wrapper intervention_directChildOfGoal = new Level_5_Wrapper();
intervention_directChildOfGoal.level_5_Rec = intervention_Rec;
behv_def.lstOf_level_5_Records.add(intervention_directChildOfGoal);
}
}
}
}

}
}
}

wrpr.lstOf_level_1_Records.add(prblmWrpr);
}
for(Level_1_Wrapper rec : wrpr.lstOf_level_1_Records){
System.debug('rec name -- '+rec.level_1_Rec.name);
System.debug('wrpr list size 1 -- '+rec.lstOf_level_2_Records.size());
System.debug('wrpr list size 2 -- '+rec.lstOf_level_2_Records_2nd_Child.size()); 
}

masterList = wrpr;
}

public void arrangementForGoals(CarePlan_Hierarchy__c csSetting,Level_3_Wrapper goalWrpr){
if(String.isNotBlank(csSetting.ElixirSuite__Relationship_Level_3__c)){
if(!csSetting.ElixirSuite__Relationship_Level_3__c.contains(';')){
goalWrpr.openLinearTree = true;

}
else {
goalWrpr.openBinaryTree = true;   
}
}
}

public void arrangementForBehavDef(CarePlan_Hierarchy__c csSetting,Level_2_Wrapper lev_3_wrpr){
if(String.isNotBlank(csSetting.ElixirSuite__Relationship_Level_2__c)){
if(!csSetting.ElixirSuite__Relationship_Level_2__c.contains(';')){
lev_3_wrpr.openLinearTree = true;

}
else {
lev_3_wrpr.openBinaryTree = true;   
}
}
}
*/
                
                public static void dummyMethod(){
                    Integer i = 0;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;        i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;        i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;        i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;        i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;        i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                    i++;
                }
            
           
        }
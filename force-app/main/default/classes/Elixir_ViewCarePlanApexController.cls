/* Developer Name -  Rohit Singh Bora
*  Test Class - Elixir_ViewCarePlanApexControllerTest
*  Purpose - To show Care plan in 'In Use' Status and add Notes 
*/

public with sharing class Elixir_ViewCarePlanApexController {
    /*@AuraEnabled
    public static wrapper getData(String caseId , String patientId) {
        ElixirSuite__CarePlan_Hierarchy__c careplanCustomSettingHeirarchy;
        Map <Id , List<Notes__c>> mapOfProblemToRec = new Map<Id , List<Notes__c>>();
        Map<String,String> labelApicombo_CustomSetting = new  Map<String,String>();
        String accountName = [SELECT Id , Name FROM Account WHERE Id= :patientId WITH SECURITY_ENFORCED LIMIT 1].Name;
        String accountVerifyCode = [SELECT Id , Name,Verification_Code__c FROM Account
                                    WHERE Id= :patientId WITH SECURITY_ENFORCED LIMIT 1].Verification_Code__c;
        Date patientBirthDate = [SELECT Id , Name, ElixirSuite__Patient_s_Birth_Date__c FROM Account 
                                 WHERE Id= :patientId WITH SECURITY_ENFORCED LIMIT 1].ElixirSuite__Patient_s_Birth_Date__c;         
        List<User> usersList = [SELECT Id , Name FROM USER LIMIT 5000];
        String userName = UserInfo.getName();
        wrapper wrpr = new wrapper();
        if(String.isNotBlank(patientId)){
            List<Treatment_Plan__c> caseRecord = [SELECT ElixirSuite__Account__c,ElixirSuite__Approval_Level_1__c,ElixirSuite__Approval_Level_2__c,ElixirSuite__Approval_Level_3__c,ElixirSuite__Approval_Level_4__c,
                                                  ElixirSuite__Approval_Level_5__c,ElixirSuite__Client_Strength__c,ElixirSuite__Client_Weakness__c,ElixirSuite__Clinical_supervisor__c,
                                                  ElixirSuite__Comment_1__c,ElixirSuite__Comment_2__c,ElixirSuite__Comment_3__c,ElixirSuite__Comment_4__c,ElixirSuite__Comment_5__c,
                                                  ElixirSuite__Description__c,ElixirSuite__Due_Date__c,ElixirSuite__End_Date__c,ElixirSuite__Primary_Therapist__c,
                                                  ElixirSuite__Signature_value_1__c,ElixirSuite__Signature_value_2__c,ElixirSuite__Signature_value_3__c,LastModifiedDate,
                                                  ElixirSuite__Signature_value_4__c,ElixirSuite__Signature_value_5__c,ElixirSuite__Signed_By_Level_1__c,
                                                  ElixirSuite__Signed_By_Level_2__c,ElixirSuite__Signed_By_Level_3__c,ElixirSuite__Signed_By_Level_4__c,
                                                  ElixirSuite__Signed_By_Level_5__c,ElixirSuite__Signed_Date_1__c,ElixirSuite__Signed_Date_2__c,
                                                  ElixirSuite__Signed_Date_3__c,ElixirSuite__Signed_Date_4__c,ElixirSuite__Signed_Date_5__c,ElixirSuite__Clinical_supervisor__r.Name,
                                                  ElixirSuite__Start_Date__c,ElixirSuite__Status__c,ElixirSuite__Treatment_Plan_Name__c,Id,Name,ElixirSuite__Primary_Therapist__r.Name
                                                  FROM ElixirSuite__Treatment_Plan__c where Id= :caseId WITH SECURITY_ENFORCED ];
            
            if(caseRecord!=null && caseRecord.size()>0){
                Id level1AcctSpecificRecType = Schema.SObjectType.Dataset1__c.getRecordTypeInfosByDeveloperName().get('Non_Templatized').getRecordTypeId();
                List<Dataset1__c> listOfProblems = [SELECT ElixirSuite__Dataset1__c,ElixirSuite__Due_Date__c,ElixirSuite__Description__c,Id,ElixirSuite__IsActive__c,Name,
                                                    ElixirSuite__Problem_Name__c,RecordTypeId,ElixirSuite__Templatized_Problem__c FROM ElixirSuite__Dataset1__c WHERE ElixirSuite__Treatment_Plan__c = : caseId 
                                                    AND RecordTypeId = : level1AcctSpecificRecType WITH SECURITY_ENFORCED];
                wrpr.listOfProblem = listOfProblems;
                wrpr.carePlan = caseRecord[0];   
                Set<Id> setOfIds = (new Map<Id,sObject>(listOfProblems)).keySet();
                if(setOfIds!=null && setOfIds.size()>0){
                    List<Notes__c> listOfNotes = [SELECT CreatedById,CreatedDate,ElixirSuite__Account__c,ElixirSuite__Dataset1__c,ElixirSuite__EventId__c,ElixirSuite__Event_End_Date__c,
                                                  ElixirSuite__Event_Start_Date__c,ElixirSuite__Event_subject__c,ElixirSuite__Form__c,ElixirSuite__Highly_Engaged__c,
                                                  ElixirSuite__High_Engagement__c,ElixirSuite__Low_Engagement__c,ElixirSuite__Moderate_Engagement__c,ElixirSuite__Notes__c,
                                                  ElixirSuite__Note__c,ElixirSuite__Plan_Hierarchy__c,ElixirSuite__Treatment_Plan__c,Id,
                                                  IsDeleted,LastModifiedById,LastModifiedDate,Name,RecordTypeId 
                                                  FROM ElixirSuite__Notes__c 
                                                  WHERE ElixirSuite__Dataset1__c IN : setOfIds 
                                                  WITH SECURITY_ENFORCED
                                                  ORDER BY CreatedDate DESC];
                    System.debug(listOfNotes);
                    for(Notes__c noteRec : listOfNotes){
                        if(mapOfProblemToRec.containsKey(noteRec.ElixirSuite__Dataset1__c)){
                            mapOfProblemToRec.get(noteRec.ElixirSuite__Dataset1__c).add(noteRec);
                        }else{
                            List<Notes__c> notes = new List<Notes__c>();
                            notes.add(noteRec);
                            mapOfProblemToRec.put(noteRec.ElixirSuite__Dataset1__c , notes);
                        }
                    }
                }
            }
            
            List<ElixirSuite__CarePlan_Hierarchy__c> csHeirarchy = [SELECT ElixirSuite__Diagnosis__c,ElixirSuite__Fifth_Level__c,ElixirSuite__First_Level__c,ElixirSuite__Fourth_Level__c,
                                                                    ElixirSuite__Relationship_level_1__c,ElixirSuite__Relationship_Level_2__c,ElixirSuite__Relationship_Level_3__c,
                                                                    ElixirSuite__Relationship_Level_4__c,ElixirSuite__Second_Level__c,ElixirSuite__Sixth_Level__c,ElixirSuite__Third_Level__c,Id,
                                                                    Name FROM ElixirSuite__CarePlan_Hierarchy__c WITH SECURITY_ENFORCED];
            if(csHeirarchy.size()>0 && csHeirarchy!=null){
                careplanCustomSettingHeirarchy = csHeirarchy[0];
            }
            
            Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Map <String, Schema.SObjectField> fieldMap = schemaMap.get('ElixirSuite__CarePlan_Hierarchy__c').getDescribe().fields.getMap();
            for(Schema.SObjectField sfield : fieldMap.Values())
            {
                schema.describefieldresult dfield = sfield.getDescribe();
                labelApicombo_CustomSetting.put(String.valueOf(dfield.getLabel()),String.valueOf(dfield.getname()));
                
            }
            
        }   
        wrpr.labelApicombo_CustomSetting = labelApicombo_CustomSetting;
        wrpr.mapOfProblemToNotes = mapOfProblemToRec;
        wrpr.listOfAllUsers = usersList;
        wrpr.accountId = patientId;
        wrpr.userName = userName;
        wrpr.accountName = accountName;
        wrpr.VerficationCode  = accountVerifyCode ; 
        wrpr.patientBirthDate = patientBirthDate;
        wrpr.careplanCustomSettingHeirarchy = careplanCustomSettingHeirarchy; 
        wrpr.nameSpace = Elixir_utility.getNameSpace();
        return wrpr;
    }*/
    
    public class Wrapper{
        @AuraEnabled  public List<Dataset1__c> listOfProblem;  
        @AuraEnabled  public List<ElixirSuite__Plan_SubHierarchy__c> listOfGoal;
        @AuraEnabled  public List<ElixirSuite__Dataset2__c> listOfObjs;
        @AuraEnabled  public List<Task> listOfTasks;
        @AuraEnabled  public List<Plan_Hierarchy__c> listOfEvidence; 
        @AuraEnabled  public List<Plan_Hierarchy__c> level2_Goal_bhevDef; 
        @AuraEnabled  public String accountName;
        @AuraEnabled  public String userName;
        @AuraEnabled  public String accountId;
        @AuraEnabled  public Date patientBirthDate;
        @AuraEnabled  public Treatment_Plan__c carePlan;
        @AuraEnabled  public List<User> listOfAllUsers;
        @AuraEnabled  public String nameSpace;
        @AuraEnabled  public String VerficationCode; 
        @AuraEnabled  public ElixirSuite__Plan_SubHierarchy__c[] listOfIntervention;
        @AuraEnabled  public ElixirSuite__CarePlan_Hierarchy__c careplanCustomSettingHeirarchy;
        @AuraEnabled  public List<ICD_Codes__c> listOfDaignosis;
        @AuraEnabled  public List<ElixirSuite__Template_Problem__c> listOfTemplateProblemGoal;
        @AuraEnabled  public List<ElixirSuite__Template_Problem__c> listOfTemplateProblemObj; 
        @AuraEnabled  public List<ElixirSuite__Template_Problem__c> listOfTemplateProblemInterv;
    }
      @AuraEnabled
    public static Wrapper getData(String caseId , String patientId) { 
        //initialize variable
        ElixirSuite__CarePlan_Hierarchy__c careplanCustomSettingHeirarchy;
        List<ElixirSuite__Plan_SubHierarchy__c> listOfTopLevelGoals;
        List<ElixirSuite__Dataset2__c> listOfTopLevelObjectives;
        List<Task> listOfTopLevelTasks;
        
        String accountName = [SELECT Id , Name FROM Account WHERE Id= :patientId WITH SECURITY_ENFORCED LIMIT 1].Name;
        String accountVerifyCode = [SELECT Id , Name,Verification_Code__c FROM Account 
        WHERE Id= :patientId WITH SECURITY_ENFORCED LIMIT 1].Verification_Code__c;
        Date patientBirthDate = [SELECT Id , Name, ElixirSuite__Patient_s_Birth_Date__c,ElixirSuite__DOB__c FROM Account 
        WHERE Id= :patientId WITH SECURITY_ENFORCED LIMIT 1].ElixirSuite__DOB__c;
        List<User> usersList = [SELECT Id , Name FROM USER WITH SECURITY_ENFORCED LIMIT 5000]; 
        String userName = UserInfo.getName();
        Wrapper wrpr = new Wrapper();
        try{
        if(String.isNotBlank(patientId)){
            List<Treatment_Plan__c> caseRecord = [SELECT Id, Account__c,Approval_Level_1__c,Approval_Level_2__c,Approval_Level_3__c ,Client_Strength__c,Client_Weakness__c,
                                                  Clinical_supervisor__c,Comment_1__c,Comment_2__c,Comment_3__c,Description__c,Due_Date__c,End_Date__c,
                                                  Primary_Therapist__c, Start_Date__c, ElixirSuite__Status__c  ,Treatment_Plan_Name__c  ,LastModifiedDate      
                                                  FROM Treatment_Plan__c where Id= :caseId WITH SECURITY_ENFORCED];
            
            if(caseRecord!=null && caseRecord.size()>0){
                List<Dataset1__c> level1Heirarchy = new list<Dataset1__c>();
             //   Id level1AcctSpecificRecType = Schema.SObjectType.Dataset1__c.getRecordTypeInfosByDeveloperName().get('Non_Templatized').getRecordTypeId();
                Elixir_Custom_Setting__c customSetting = Elixir_Custom_Setting__c.getOrgDefaults();
                String careFilter = customSetting.ElixirSuite__Default_Active_Care_Episode_Filter__c;
                if(string.isBlank(careFilter)){
                    careFilter = 'createddate desc';
                }
                String careStatus = 'Active';
                
                string querystr = '';
                querystr += 'Select Id,ElixirSuite__Account__c,ElixirSuite__Status__c from ElixirSuite__Visits__c where ElixirSuite__Status__c=:careStatus AND ElixirSuite__Account__c =: patientId WITH SECURITY_ENFORCED order by ';
                querystr += careFilter ;
                List<ElixirSuite__Visits__c> lstVisits = database.query(querystr);
                if(lstVisits != null && !lstVisits.isEmpty()){
                    level1Heirarchy = [SELECT Id, CreatedById, IsDeleted,Name,
                                            ElixirSuite__Description__c,ElixirSuite__Template_Problem__c,(select Id,ElixirSuite__Treatment_Plan__c,ElixirSuite__Due_Date__c from ElixirSuite__Plan_Hierarchy__r where ElixirSuite__Treatment_Plan__c =: caseId)
                                            FROM Dataset1__c WHERE Account__c = :patientId and ElixirSuite__Care_Episode__c = :lstVisits[0].Id WITH SECURITY_ENFORCED ORDER BY CreatedDate Desc];
                }
                /** commented by vishal
                List<Dataset1__c> level1_heirarchy = [SELECT Id,Name,ElixirSuite__Description__c
                                                      FROM Dataset1__c WITH SECURITY_ENFORCED];**/
               /* List<Dataset1__c> level1_heirarchy = [SELECT Dataset1__c,Due_Date__c,Description__c,Id,IsActive__c,Name,
                                                      Problem_Name__c,RecordTypeId,Templatized_Problem__c FROM Dataset1__c WHERE Treatment_Plan__c = : caseId 
                                                      AND RecordTypeId = : level1AcctSpecificRecType WITH SECURITY_ENFORCED];*/
                wrpr.listOfProblem = level1Heirarchy;
                wrpr.carePlan = caseRecord[0];                                     
            }
            
            listOfTopLevelGoals = [SELECT Id,Name, ElixirSuite__Plan_Hierarchy_Name__c,ElixirSuite__Treatment_Plan__c,
                                                                           ElixirSuite__Treatment_Plan__r.Name, ElixirSuite__Description__c,
                                                                           ElixirSuite__Template_Problem__c, ElixirSuite__Template_Problem__r.Name,ElixirSuite__Due_Date__c 
                                                                           FROM ElixirSuite__Plan_SubHierarchy__c WHERE ElixirSuite__Treatment_Plan__c =: caseId WITH SECURITY_ENFORCED];
            
            listOfTopLevelObjectives = [SELECT Id,ElixirSuite__Name__c,ElixirSuite__Description__c,
                                                                       ElixirSuite__Plan_SubHierarchy__c,ElixirSuite__Treatment_Plan__c, 
                                                                       ElixirSuite__Treatment_Plan__r.Name, ElixirSuite__Template_Problem__c, 
                                                                       ElixirSuite__Template_Problem__r.Name, ElixirSuite__Plan_Hierarchy__c, 
                                                                       ElixirSuite__Plan_Hierarchy__r.Name,ElixirSuite__Due_Date__c from ElixirSuite__Dataset2__c 
                                                                       WHERE ElixirSuite__Treatment_Plan__c =: caseId WITH SECURITY_ENFORCED];
            listOfTopLevelTasks = [SELECT Id,Subject,OwnerId, WhatId, Description, ElixirSuite__Template_Problem__c,ActivityDate FROM Task WHERE WhatId =: caseId WITH SECURITY_ENFORCED];
            
            List<ElixirSuite__CarePlan_Hierarchy__c> csHeirarchy = [SELECT ElixirSuite__Diagnosis__c,ElixirSuite__Fifth_Level__c,ElixirSuite__First_Level__c,ElixirSuite__Fourth_Level__c,
                                                                    ElixirSuite__Relationship_level_1__c,ElixirSuite__Relationship_Level_2__c,ElixirSuite__Relationship_Level_3__c,
                                                                    ElixirSuite__Relationship_Level_4__c,ElixirSuite__Second_Level__c,ElixirSuite__Sixth_Level__c,ElixirSuite__Third_Level__c,Id,
                                                                    Name FROM ElixirSuite__CarePlan_Hierarchy__c WITH SECURITY_ENFORCED];
            if(csHeirarchy.size()>0 && csHeirarchy!=null){
                careplanCustomSettingHeirarchy = csHeirarchy[0];
            }
        }
        wrpr.listOfGoal = listOfTopLevelGoals;
        wrpr.listOfObjs = listOfTopLevelObjectives;
        wrpr.listOfTasks = listOfTopLevelTasks; 
        wrpr.listOfAllUsers = usersList;
        wrpr.accountId = patientId;
        wrpr.userName = userName;
        wrpr.accountName = accountName;
        wrpr.VerficationCode  = accountVerifyCode ; 
        wrpr.patientBirthDate = patientBirthDate;
        wrpr.nameSpace = Elixir_utility.getNameSpace();
        wrpr.careplanCustomSettingHeirarchy = careplanCustomSettingHeirarchy;
        }
        catch(Exception e){
        ExceptionLog.logError(e);
        }
        return wrpr;
    }
    
    @AuraEnabled
    public static List<ContentVersion> fetchNotes(String recordId){
        List<ContentVersion> listOfCV = [SELECT Id,ContentBodyId,CreatedDate,ContentDocumentId,Title,TextPreview, VersionData,
                                         ElixirSuite__File_Name__c,FirstPublishLocationId from ContentVersion 
                                         where FirstPublishLocationId =: recordId WITH SECURITY_ENFORCED
                                         ORDER BY CreatedDate DESC];
       
        if(listOfCV!=null && !listOfCV.isEmpty()){
            for(ContentVersion cv : listOfCV){
                cv.ElixirSuite__File_Name__c = cv.VersionData.toString();
            }
            return listOfCV;
        }
        return null;
    }
    
    @AuraEnabled
    public static   List<ICD_Codes__c> fetchRelatedDiagnosis(String problemId ){
        /**Id nonTemplatizedDiagnosisRecTypeID = Schema.SObjectType.ICD_Codes__c.getRecordTypeInfosByDeveloperName().get('Non_Templatized').getRecordTypeId();
        return [SELECT Category__c,Code_Description__c,Code_Label__c,Code_Type__c,Code__c,Dataset1__c,Diagnosis_Code_and_Name__c,
                ICD_Codes__c,Id,Name,RecordTypeId FROM ICD_Codes__c WHERE Dataset1__c =: problemId
                AND recordTypeId = : nonTemplatizedDiagnosisRecTypeID WITH SECURITY_ENFORCED];**/
        return null;
    }
    
    @AuraEnabled
    public static Wrapper getTasks(String goalId){
       
        //initialize variable
        List<ElixirSuite__Dataset2__c> goalListOfObjectives;
        List<Task> goalListOfIntervs;
        
        goalListOfObjectives = [SELECT Id,ElixirSuite__Name__c,ElixirSuite__Description__c,
                                    ElixirSuite__Plan_SubHierarchy__c,ElixirSuite__Treatment_Plan__c, 
                                    ElixirSuite__Treatment_Plan__r.Name, ElixirSuite__Template_Problem__c, 
                                    ElixirSuite__Template_Problem__r.Name, ElixirSuite__Plan_Hierarchy__c, 
                                    ElixirSuite__Plan_Hierarchy__r.Name, ElixirSuite__Due_Date__c from ElixirSuite__Dataset2__c 
                                    WHERE ElixirSuite__Plan_SubHierarchy__c =: goalId WITH SECURITY_ENFORCED];
        goalListOfIntervs = [SELECT Id,Subject,OwnerId, WhatId, Description, ElixirSuite__Template_Problem__c, ActivityDate FROM Task WHERE WhatId =: goalId WITH SECURITY_ENFORCED];
        
        Wrapper wrpr = new Wrapper();
        wrpr.listOfObjs = goalListOfObjectives;
        wrpr.listOfTasks=goalListOfIntervs;
        return wrpr;
    }
    
    @AuraEnabled
    public static List<Task> getInterventions(String taskId){
              
        List<Task> objListOfIntervs = [SELECT Id,Subject,OwnerId, WhatId, Description, ElixirSuite__Template_Problem__c, ActivityDate FROM Task WHERE WhatId =: taskId WITH SECURITY_ENFORCED];
        return objListOfIntervs;
    }
    
    @AuraEnabled
    public static Wrapper getGoalsAndEvidences(String problemId, String treatmentPlanId){
        
        //initialize variable
        List<ElixirSuite__Plan_SubHierarchy__c> problemlistOfGoals;
        List<ElixirSuite__Dataset2__c> problemlistOfObjectives;
        string tempProblemId;
        
        List<Dataset1__c> listOfProblems =  [SELECT Id, CreatedById, IsDeleted,Name ,ElixirSuite__Description__c,ElixirSuite__Template_Problem__c FROM ElixirSuite__Dataset1__c WHERE Id =: problemId WITH SECURITY_ENFORCED];
        
        If(listOfProblems != null && !listOfProblems.isEmpty()){
            tempProblemId = listOfProblems[0].ElixirSuite__Template_Problem__c;
        }
        
        List <ElixirSuite__Plan_Hierarchy__c> treatmentPlanProblem = [SELECT Id,Name, ElixirSuite__Name__c, ElixirSuite__Description__c,ElixirSuite__Treatment_Plan__c, ElixirSuite__Template_Problem__c from ElixirSuite__Plan_Hierarchy__c WHERE ElixirSuite__Template_Problem__c =: tempProblemId AND ElixirSuite__Treatment_Plan__c =:treatmentPlanId WITH SECURITY_ENFORCED]; 
        
        If(treatmentPlanProblem != null && !treatmentPlanProblem.isEmpty()){
        problemlistOfGoals = [SELECT Id,Name, ElixirSuite__Plan_Hierarchy_Name__c,ElixirSuite__Treatment_Plan__c,
                               ElixirSuite__Treatment_Plan__r.Name, ElixirSuite__Description__c,ElixirSuite__Plan_Hierarchy__c,
                               ElixirSuite__Template_Problem__c, ElixirSuite__Template_Problem__r.Name, ElixirSuite__Due_Date__c 
                               FROM ElixirSuite__Plan_SubHierarchy__c WHERE ElixirSuite__Plan_Hierarchy__c =: treatmentPlanProblem[0].Id WITH SECURITY_ENFORCED];
        
        problemlistOfObjectives = [SELECT Id,ElixirSuite__Name__c,ElixirSuite__Description__c,
                                    ElixirSuite__Plan_SubHierarchy__c,ElixirSuite__Treatment_Plan__c, 
                                    ElixirSuite__Treatment_Plan__r.Name, ElixirSuite__Template_Problem__c, 
                                    ElixirSuite__Template_Problem__r.Name, ElixirSuite__Plan_Hierarchy__c, 
                                    ElixirSuite__Plan_Hierarchy__r.Name, ElixirSuite__Due_Date__c from ElixirSuite__Dataset2__c 
                                    WHERE ElixirSuite__Plan_Hierarchy__c =: treatmentPlanProblem[0].Id WITH SECURITY_ENFORCED];
        }
        // List<ICD_Codes__c> listOfDiagnosis = [SELECT Id, Name,Diagnosis_Code_and_Name__c
        //                              FROM ICD_Codes__c WHERE RecordTypeId =:RecType3 WITH SECURITY_ENFORCED];
        List<ICD_Codes__c> listOfDiagnosis = new List<ICD_Codes__c>();
        //Diagnosis_Code_and_Name__c
        Wrapper wrpr = new Wrapper();
        wrpr.listOfGoal = problemlistOfGoals ;
        wrpr.listOfObjs = problemlistOfObjectives ;
        wrpr.listOfDaignosis = listOfDiagnosis ;
        return wrpr ;
    }
    
    @AuraEnabled
    public static Wrapper getAllGoals(List<String> existingGoals){
        
        Id goalRecId = Schema.SObjectType.ElixirSuite__Template_Problem__c.getRecordTypeInfosByDeveloperName().get('Goals').getRecordTypeId();
        Set<String> setOfIds = new Set<String>(existingGoals);
        List<ElixirSuite__Template_Problem__c> listOfGoals =  [SELECT Id,Name,ElixirSuite__Description__c,ElixirSuite__Status__c FROM ElixirSuite__Template_Problem__c  WHERE Id NOT IN : setOfIds AND RecordTypeId =: goalRecId 
                                                               WITH SECURITY_ENFORCED LIMIT 49000];
        Wrapper wrpr = new Wrapper();
        wrpr.listOfTemplateProblemGoal = listOfGoals;
        
        return wrpr;
    }
    
    @AuraEnabled
    public static Wrapper getAllTasks(List<String> existingTasks){
        Id objRecId = Schema.SObjectType.ElixirSuite__Template_Problem__c.getRecordTypeInfosByDeveloperName().get('Objective').getRecordTypeId();
        Set<String> setOfIds = new Set<String>(existingTasks);
        List<ElixirSuite__Template_Problem__c> listOfTasks =  [SELECT Id,Name,ElixirSuite__Description__c,ElixirSuite__Status__c FROM ElixirSuite__Template_Problem__c  WHERE Id NOT IN : setOfIds AND RecordTypeId =: objRecId 
                                                               WITH SECURITY_ENFORCED LIMIT 49000];
        Wrapper wrpr = new Wrapper();
        wrpr.listOfTemplateProblemObj = listOfTasks;
        return wrpr;
        
    }
    
    @AuraEnabled
    public static Wrapper getAllInterventions(List<String> existingInts){
        
        Id intRecId = Schema.SObjectType.ElixirSuite__Template_Problem__c.getRecordTypeInfosByDeveloperName().get('Interventions').getRecordTypeId();
        Set<String> setOfIds = new Set<String>(existingInts);
        List<ElixirSuite__Template_Problem__c> listOfInts =  [SELECT Id,Name,ElixirSuite__Description__c,ElixirSuite__Status__c FROM ElixirSuite__Template_Problem__c  WHERE Id NOT IN : setOfIds AND RecordTypeId =: intRecId 
                                                              WITH SECURITY_ENFORCED LIMIT 49000];
        Wrapper wrpr = new Wrapper();
        wrpr.listOfTemplateProblemInterv = listOfInts;
        return wrpr;
        
    } 
    
    @AuraEnabled
    public static Wrapper getTasksFromGoal(List<String> existingTasks,String goalId){
        List<ElixirSuite__Template_Problem__c> listOfTasks;
        Id objRecId = Schema.SObjectType.ElixirSuite__Template_Problem__c.getRecordTypeInfosByDeveloperName().get('Objective').getRecordTypeId();
        if(existingTasks != null && !existingTasks.isEmpty()){
            String templateID = [SELECT Id,Name, ElixirSuite__Plan_Hierarchy_Name__c,ElixirSuite__Treatment_Plan__c,
                                 ElixirSuite__Treatment_Plan__r.Name, ElixirSuite__Description__c,ElixirSuite__Plan_Hierarchy__c,
                                 ElixirSuite__Template_Problem__c, ElixirSuite__Template_Problem__r.Name, ElixirSuite__Due_Date__c 
                                 FROM ElixirSuite__Plan_SubHierarchy__c WHERE Id =: goalId WITH SECURITY_ENFORCED].ElixirSuite__Template_Problem__c;
            
            Set<String> setOfIds = new Set<String>(existingTasks);
            listOfTasks =  [SELECT Id,Name,ElixirSuite__Description__c,ElixirSuite__Status__c FROM ElixirSuite__Template_Problem__c  WHERE Id NOT IN : setOfIds AND RecordTypeId =: objRecId AND ElixirSuite__Goal__c =: templateID
                            WITH SECURITY_ENFORCED LIMIT 49000];
        }
        else{
            Set<String> setOfIds = new Set<String>(existingTasks);
            listOfTasks =  [SELECT Id,Name,ElixirSuite__Description__c,ElixirSuite__Status__c FROM ElixirSuite__Template_Problem__c  WHERE Id NOT IN : setOfIds AND RecordTypeId =: objRecId AND ElixirSuite__Goal__c =: goalId
                            WITH SECURITY_ENFORCED LIMIT 49000];
        }
        Wrapper wrpr = new Wrapper();
        wrpr.listOfTemplateProblemObj = listOfTasks;
        return wrpr;
        
    }
    
    @AuraEnabled
    public static Wrapper getAllTasks2(List<String> existingTasks,String goalId){
        List<ElixirSuite__Template_Problem__c> listOfInts;
        Id intRecId = Schema.SObjectType.ElixirSuite__Template_Problem__c.getRecordTypeInfosByDeveloperName().get('Interventions').getRecordTypeId();
        
        if(existingTasks != null && !existingTasks.isEmpty()){
            String templateID = [SELECT Id,Name, ElixirSuite__Plan_Hierarchy_Name__c,ElixirSuite__Treatment_Plan__c,
                                 ElixirSuite__Treatment_Plan__r.Name, ElixirSuite__Description__c,ElixirSuite__Plan_Hierarchy__c,
                                 ElixirSuite__Template_Problem__c, ElixirSuite__Template_Problem__r.Name 
                                 FROM ElixirSuite__Plan_SubHierarchy__c WHERE Id =: goalId WITH SECURITY_ENFORCED].ElixirSuite__Template_Problem__c;
            
            Set<String> setOfIds = new Set<String>(existingTasks);
            listOfInts =  [SELECT Id,Name,ElixirSuite__Description__c,ElixirSuite__Status__c FROM ElixirSuite__Template_Problem__c  WHERE Id NOT IN : setOfIds  AND RecordTypeId =: intRecId AND ElixirSuite__Goal__c =: templateID 
                           WITH SECURITY_ENFORCED LIMIT 49000];
        }
        else{
            Set<String> setOfIds = new Set<String>(existingTasks);
            listOfInts =  [SELECT Id,Name,ElixirSuite__Description__c,ElixirSuite__Status__c FROM ElixirSuite__Template_Problem__c  WHERE Id NOT IN : setOfIds  AND RecordTypeId =: intRecId AND ElixirSuite__Goal__c =: goalId 
                           WITH SECURITY_ENFORCED LIMIT 49000];
        }
        Wrapper wrpr = new Wrapper();
        wrpr.listOfTemplateProblemInterv = listOfInts;
        return wrpr;
        
    }
    
    @AuraEnabled
    public static Wrapper getInterventionFromObjective(List<String> existingInts,String objectiveId){
        List<ElixirSuite__Template_Problem__c> listOfInts;
        Id intRecId = Schema.SObjectType.ElixirSuite__Template_Problem__c.getRecordTypeInfosByDeveloperName().get('Interventions').getRecordTypeId();
        
        If(existingInts != null && !existingInts.isEmpty()){
            String templateID = [SELECT Id,ElixirSuite__Name__c,ElixirSuite__Description__c,
                                 ElixirSuite__Plan_SubHierarchy__c,ElixirSuite__Treatment_Plan__c, 
                                 ElixirSuite__Treatment_Plan__r.Name, ElixirSuite__Template_Problem__c, 
                                 ElixirSuite__Template_Problem__r.Name, ElixirSuite__Plan_Hierarchy__c, 
                                 ElixirSuite__Plan_Hierarchy__r.Name from ElixirSuite__Dataset2__c 
                                 WHERE Id =: objectiveId WITH SECURITY_ENFORCED].ElixirSuite__Template_Problem__c;
            
            Set<String> setOfIds = new Set<String>(existingInts);
            listOfInts =  [SELECT Id,Name,ElixirSuite__Description__c,ElixirSuite__Status__c FROM ElixirSuite__Template_Problem__c  WHERE Id NOT IN : setOfIds  AND RecordTypeId =: intRecId AND ElixirSuite__Objective__c =: templateID 
                                                                  WITH SECURITY_ENFORCED LIMIT 49000];
        }
        else{
            Set<String> setOfIds = new Set<String>(existingInts);
            listOfInts =  [SELECT Id,Name,ElixirSuite__Description__c,ElixirSuite__Status__c FROM ElixirSuite__Template_Problem__c  WHERE Id NOT IN : setOfIds  AND RecordTypeId =: intRecId AND ElixirSuite__Objective__c =: objectiveId 
                                                                  WITH SECURITY_ENFORCED LIMIT 49000];

        }
        Wrapper wrpr = new Wrapper();
        wrpr.listOfTemplateProblemInterv = listOfInts;
        return wrpr;
        
    }
    
    //added by vishal
    @AuraEnabled
    public static Wrapper getAllGoalsAndObjectives(List<String> existingGoals,String problemId){
        Id goalRecId = Schema.SObjectType.ElixirSuite__Template_Problem__c.getRecordTypeInfosByDeveloperName().get('Goals').getRecordTypeId();
        Id objRecId = Schema.SObjectType.ElixirSuite__Template_Problem__c.getRecordTypeInfosByDeveloperName().get('Objective').getRecordTypeId();
        
        List<Dataset1__c> listOfProblems =  [SELECT Id, CreatedById, IsDeleted,Name ,Description__c,ElixirSuite__Template_Problem__c
                                             FROM Dataset1__c WHERE Id =:problemId WITH SECURITY_ENFORCED];
        Set<String> setOfIds = new Set<String>(existingGoals);
        List<ElixirSuite__Template_Problem__c> listOfGoals =  [SELECT Id,Name,ElixirSuite__Description__c,ElixirSuite__Status__c,ElixirSuite__Goal__c FROM ElixirSuite__Template_Problem__c  WHERE Id NOT IN : setOfIds  AND RecordTypeId =: goalRecId AND ElixirSuite__Problem__c =: listOfProblems[0].ElixirSuite__Template_Problem__c 
                                                               WITH SECURITY_ENFORCED LIMIT 49000];
        List<ElixirSuite__Template_Problem__c> listOfTasks =  [SELECT Id,Name,ElixirSuite__Description__c,ElixirSuite__Status__c,ElixirSuite__Objective__c FROM ElixirSuite__Template_Problem__c  WHERE Id NOT IN : setOfIds  AND RecordTypeId =: objRecId AND ElixirSuite__Problem__c =: listOfProblems[0].ElixirSuite__Template_Problem__c
                                                               WITH SECURITY_ENFORCED LIMIT 49000];
        Wrapper wrpr = new Wrapper();
        wrpr.listOfTemplateProblemGoal = listOfGoals;
        wrpr.listOfTemplateProblemObj = listOfTasks;
        return wrpr;
    }
    
    /*
    @AuraEnabled
    public static void delNotes(String noteId){
        List<Notes__c> listOfNotes= [SELECT Id FROM Notes__c WHERE Id =:noteId];
        if(listOfNotes!=null && listOfNotes.size()>0){
            delete listOfNotes;
        }
    }
    @AuraEnabled
    public static void saveNotes(String text , String patientId , String problemId){
        System.debug(text+patientId+problemId);
        Notes__c newNote = new Notes__c();
        newNote.Notes__c = text;
        newNote.Account__c = patientId;
        newNote.ElixirSuite__Dataset1__c = problemId;
        //newNote.ElixirSuite__Treatment_Plan__c = caseId;
        if(Schema.sObjectType.Notes__c.fields.Notes__c.isCreateable() &&
           Schema.sObjectType.Notes__c.fields.Account__c.isCreateable() &&
           Schema.sObjectType.Notes__c.fields.ElixirSuite__Dataset1__c.isCreateable()
          )
        {   
            DMLManager.insertAsUser(newNote);
        }
    }
    @AuraEnabled
    public static void saveNotesGoals(String text , String patientId , String goalId){
        
        Notes__c newNote = new Notes__c();
        newNote.Notes__c = text;
        newNote.Account__c = patientId;
        newNote.ElixirSuite__Goal_Notes__c = goalId;
        if(Schema.sObjectType.Notes__c.fields.Notes__c.isCreateable() &&
           Schema.sObjectType.Notes__c.fields.Account__c.isCreateable() &&
           Schema.sObjectType.Notes__c.fields.ElixirSuite__Goal_Notes__c.isCreateable()
          )
        {  
            DMLManager.insertAsUser(newNote);
        } 
    }
    @AuraEnabled
    public static void saveNotesObjective(String text , String patientId , String goalId){ 
        
        Notes__c newNote = new Notes__c();
        newNote.Notes__c = text;
        newNote.Account__c = patientId;
        newNote.ElixirSuite__Objective_Notes__c = goalId;
        if(Schema.sObjectType.Notes__c.fields.Notes__c.isCreateable() &&
           Schema.sObjectType.Notes__c.fields.Account__c.isCreateable() &&
           Schema.sObjectType.Notes__c.fields.ElixirSuite__Objective_Notes__c.isCreateable()
          )
        {  
            DMLManager.insertAsUser(newNote);
        }
        System.debug(newNote);    
    }
    @AuraEnabled
    public static void saveNotesIntervention(String text , String patientId , String intervId){ 
        
        Notes__c newNote = new Notes__c();
        newNote.Notes__c = text;
        newNote.Account__c = patientId;
        newNote.ElixirSuite__Intervention_Notes__c = intervId;
        if(Schema.sObjectType.Notes__c.fields.Notes__c.isCreateable() &&
           Schema.sObjectType.Notes__c.fields.Account__c.isCreateable() &&
           Schema.sObjectType.Notes__c.fields.ElixirSuite__Intervention_Notes__c.isCreateable()
          )
        {  
            DMLManager.insertAsUser(newNote);
        }
        System.debug(newNote);    
    }
    @AuraEnabled
    public static List<Notes__c> notesOfGoal(String goalId){
        List<Notes__c> listOfNotes = [SELECT CreatedById,CreatedDate,ElixirSuite__Account__c,ElixirSuite__Goal_Notes__c,ElixirSuite__Dataset1__c,ElixirSuite__EventId__c,ElixirSuite__Event_End_Date__c,
                                      ElixirSuite__Event_Start_Date__c,ElixirSuite__Event_subject__c,ElixirSuite__Form__c,ElixirSuite__Highly_Engaged__c,
                                      ElixirSuite__High_Engagement__c,ElixirSuite__Low_Engagement__c,ElixirSuite__Moderate_Engagement__c,ElixirSuite__Notes__c,
                                      ElixirSuite__Note__c,ElixirSuite__Plan_Hierarchy__c,ElixirSuite__Treatment_Plan__c,Id,
                                      IsDeleted,LastModifiedById,LastModifiedDate,Name,RecordTypeId 
                                      FROM ElixirSuite__Notes__c WHERE ElixirSuite__Goal_Notes__c =:goalId WITH SECURITY_ENFORCED
                                      ORDER BY CreatedDate DESC];
        system.debug('listOfNotes '+listOfNotes);
        if(listOfNotes!=null && listOfNotes.size()>0){
            system.debug(listOfNotes);
            return listOfNotes;
        }
        return null;
    }
    @AuraEnabled
    public static List<Notes__c> notesOfObjective(String goalId){
        List<Notes__c> listOfNotes = [SELECT CreatedById,CreatedDate,ElixirSuite__Account__c,ElixirSuite__Objective_Notes__c,ElixirSuite__Dataset1__c,ElixirSuite__EventId__c,ElixirSuite__Event_End_Date__c,
                                      ElixirSuite__Event_Start_Date__c,ElixirSuite__Event_subject__c,ElixirSuite__Form__c,ElixirSuite__Highly_Engaged__c,
                                      ElixirSuite__High_Engagement__c,ElixirSuite__Low_Engagement__c,ElixirSuite__Moderate_Engagement__c,ElixirSuite__Notes__c,
                                      ElixirSuite__Note__c,ElixirSuite__Plan_Hierarchy__c,ElixirSuite__Treatment_Plan__c,Id,
                                      IsDeleted,LastModifiedById,LastModifiedDate,Name,RecordTypeId 
                                      FROM ElixirSuite__Notes__c 
                                      WHERE ElixirSuite__Objective_Notes__c =:goalId 
                                      WITH SECURITY_ENFORCED
                                      ORDER BY CreatedDate DESC];
        if(listOfNotes!=null && listOfNotes.size()>0){
            system.debug(listOfNotes);
            return listOfNotes;
        }
        return null;
    } 
    @AuraEnabled
    public static List<Notes__c> notesOfIntervention(String intervId){
        List<Notes__c> listOfNotes = [SELECT CreatedById,CreatedDate,ElixirSuite__Account__c,ElixirSuite__Intervention_Notes__c,ElixirSuite__Dataset1__c,ElixirSuite__EventId__c,ElixirSuite__Event_End_Date__c,
                                      ElixirSuite__Event_Start_Date__c,ElixirSuite__Event_subject__c,ElixirSuite__Form__c,ElixirSuite__Highly_Engaged__c,
                                      ElixirSuite__High_Engagement__c,ElixirSuite__Low_Engagement__c,ElixirSuite__Moderate_Engagement__c,ElixirSuite__Notes__c,
                                      ElixirSuite__Note__c,ElixirSuite__Plan_Hierarchy__c,ElixirSuite__Treatment_Plan__c,Id,
                                      IsDeleted,LastModifiedById,LastModifiedDate,Name,RecordTypeId 
                                      FROM ElixirSuite__Notes__c 
                                      WHERE ElixirSuite__Intervention_Notes__c =:intervId 
                                      WITH SECURITY_ENFORCED
                                      ORDER BY CreatedDate DESC];
        if(listOfNotes!=null && listOfNotes.size()>0){
            system.debug(listOfNotes);
            return listOfNotes;
        }
        return null;
    } 
    @AuraEnabled
    public static List<Notes__c> notesOfProblem(String problemId){
        List<Notes__c> listOfNotes = [SELECT CreatedById,CreatedDate,ElixirSuite__Account__c,ElixirSuite__Dataset1__c,ElixirSuite__EventId__c,ElixirSuite__Event_End_Date__c,
                                      ElixirSuite__Event_Start_Date__c,ElixirSuite__Event_subject__c,ElixirSuite__Form__c,ElixirSuite__Highly_Engaged__c,
                                      ElixirSuite__High_Engagement__c,ElixirSuite__Low_Engagement__c,ElixirSuite__Moderate_Engagement__c,ElixirSuite__Notes__c,
                                      ElixirSuite__Note__c,ElixirSuite__Plan_Hierarchy__c,ElixirSuite__Treatment_Plan__c,Id,
                                      IsDeleted,LastModifiedById,LastModifiedDate,Name,RecordTypeId 
                                      FROM ElixirSuite__Notes__c 
                                      WHERE ElixirSuite__Dataset1__c =:problemId
                                      WITH SECURITY_ENFORCED 
                                      ORDER BY CreatedDate DESC];
        if(listOfNotes!=null && listOfNotes.size()>0){
            system.debug(listOfNotes);
            return listOfNotes;
        }
        return null;
    }*/
}
    // Objective
    /*@AuraEnabled
    public static wrapper getTasks(String goalId){
        Id objectiveRecType = Schema.SObjectType.ElixirSuite__Plan_SubHierarchy__c.getRecordTypeInfosByDeveloperName().get('Treatment_Plan_Recordtype3').getRecordTypeId();
        Id interventionRecType = Schema.SObjectType.ElixirSuite__Plan_SubHierarchy__c.getRecordTypeInfosByDeveloperName().get('Treatment_Plan_Recordtype4').getRecordTypeId();
        Map <Id , List<Notes__c>> mapOfProblemToRec = new Map<Id , List<Notes__c>>();
        Map <Id , List<taskNoteWrapper>> finalmap = new Map<Id , List<taskNoteWrapper>>();
        List<ElixirSuite__Plan_SubHierarchy__c> listOfTasks = [SELECT CreatedById,CreatedDate,ElixirSuite__Dataset3__c,ElixirSuite__Description__c,Due_Date__c,
                                                               ElixirSuite__Plan_Hierarchy_Name__c,ElixirSuite__Plan_Hierarchy__c,Id,
                                                               IsDeleted,LastModifiedById,LastModifiedDate,
                                                               Name,OwnerId,RecordTypeId FROM ElixirSuite__Plan_SubHierarchy__c
                                                               where ElixirSuite__Plan_Hierarchy__c = : goalId AND RecordTypeID = :objectiveRecType
                                                               WITH SECURITY_ENFORCED];
        List<ElixirSuite__Plan_SubHierarchy__c> listOfIntervention = [SELECT CreatedById,CreatedDate,ElixirSuite__Dataset3__c,ElixirSuite__Description__c,Due_Date__c,
                                                                      ElixirSuite__Plan_Hierarchy_Name__c,ElixirSuite__Plan_Hierarchy__c,Id,
                                                                      IsDeleted,LastModifiedById,LastModifiedDate,
                                                                      Name,OwnerId,RecordTypeId FROM ElixirSuite__Plan_SubHierarchy__c
                                                                      where ElixirSuite__Plan_Hierarchy__c = : goalId AND RecordTypeID = :interventionRecType
                                                                      WITH SECURITY_ENFORCED];
        
        wrapper wrpr = new wrapper();
        Set<Id> setOfIds = (new Map<Id,sObject>(listOfTasks)).keySet();
        Set<Id> setOfContentIds = new Set<Id>();
        if(listOfTasks!=null && listOfTasks.size()>0){
            
            if(setOfIds!=null && setOfIds.size()>0){
                List<Notes__c> listOfNotes = [SELECT CreatedById,CreatedDate,ElixirSuite__Plan_SubHierarchy__c,ElixirSuite__Account__c,ElixirSuite__Dataset1__c,ElixirSuite__EventId__c,ElixirSuite__Event_End_Date__c,
                                              ElixirSuite__Event_Start_Date__c,ElixirSuite__Event_subject__c,ElixirSuite__Form__c,ElixirSuite__Highly_Engaged__c,
                                              ElixirSuite__High_Engagement__c,ElixirSuite__Low_Engagement__c,ElixirSuite__Moderate_Engagement__c,ElixirSuite__Notes__c,
                                              ElixirSuite__Note__c,ElixirSuite__Plan_Hierarchy__c,ElixirSuite__Treatment_Plan__c,Id,
                                              IsDeleted,LastModifiedById,LastModifiedDate,Name,RecordTypeId 
                                              FROM ElixirSuite__Notes__c WHERE ElixirSuite__Plan_SubHierarchy__c IN :setOfIds 
                                              WITH SECURITY_ENFORCED
                                              ORDER BY CreatedDate DESC];
                
                System.debug(listOfNotes);
                for(Notes__c noteRec : listOfNotes){
                    if(mapOfProblemToRec.containsKey(noteRec.ElixirSuite__Plan_Hierarchy__c)){
                        mapOfProblemToRec.get(noteRec.ElixirSuite__Plan_SubHierarchy__c).add(noteRec);
                    }else{
                        List<Notes__c> notes = new List<Notes__c>();
                        notes.add(noteRec);
                        mapOfProblemToRec.put(noteRec.ElixirSuite__Plan_SubHierarchy__c , notes);
                    }
                }
            }
            
            
        }
        system.debug(finalMap);                            
        wrpr.mapOfTaskToNotes = finalMap;    
        wrpr.listOfObjs = listOfTasks;
        wrpr.listOfIntervention = listOfIntervention;
        wrpr.mapOfProblemToRec = mapOfProblemToRec;
        return wrpr;
        
    }*/
    
    //@AuraEnabled
    /*public static   List<ICD_Codes__c> fetchRelatedDiagnosis(String problemId ){
        System.debug('insode diagnosois '+problemId);
        Id nonTemplatizedDiagnosisRecTypeID = Schema.SObjectType.ICD_Codes__c.getRecordTypeInfosByDeveloperName().get('Non_Templatized').getRecordTypeId();
        return [SELECT ElixirSuite__Category__c,ElixirSuite__Code_Description__c,ElixirSuite__Code_Label__c,ElixirSuite__Code_Type__c,ElixirSuite__Code__cElixirSuite__,Dataset1__c,ElixirSuite__Diagnosis_Code_and_Name__c,
                ElixirSuite__ICD_Codes__c,Id,Name,RecordTypeId FROM ICD_Codes__c WHERE ElixirSuite__Dataset1__c =: problemId
                AND recordTypeId = : nonTemplatizedDiagnosisRecTypeID WITH SECURITY_ENFORCED];
    }
    @AuraEnabled
    public static Object getGoals(String problemId ){
        Map <Id , List<Notes__c>> mapOfProblemToRec = new Map<Id , List<Notes__c>>();
        Map <Id , List<Notes__c>> mapOfProblemToRec_2 = new Map<Id , List<Notes__c>>();
        Id level2AcctSpecific_Goal = Schema.SObjectType.Plan_Hierarchy__c.getRecordTypeInfosByDeveloperName().get('Recordtype1').getRecordTypeId();
        Id level2AcctSpecific_BehavDef = Schema.SObjectType.Plan_Hierarchy__c.getRecordTypeInfosByDeveloperName().get('Recordtype2').getRecordTypeId();
        
        List<Plan_Hierarchy__c> level2_Goal = [SELECT Name__c,Due_Date__c,Dataset1__c,Dataset2__c,Id,Name,Description__c,RecordTypeId FROM Plan_Hierarchy__c WHERE  Dataset1__c =: problemID
                                               AND RecordTypEId=:level2AcctSpecific_Goal WITH SECURITY_ENFORCED
                                               ORDER BY CreatedDate];
        
        List<Plan_Hierarchy__c> level2_Goal_bhevDef = [SELECT Name__c,Due_Date__c,Dataset1__c,Dataset2__c,Id,Name,Description__c,RecordTypeId FROM Plan_Hierarchy__c WHERE  Dataset1__c =: problemID
                                                       AND RecordTypeId=:level2AcctSpecific_BehavDef WITH SECURITY_ENFORCED
                                                       ORDER BY CreatedDate ];
        List<Plan_Hierarchy__c> listofGoals = level2_Goal;
        if(listofGoals!=null && listOfGoals.size()>0){
            Set<Id> setOfIds = (new Map<Id,sObject>(listOfGoals)).keySet();
            if(setOfIds!=null && setOfIds.size()>0){
                List<Notes__c> listOfNotes = [SELECT CreatedById,CreatedDate,ElixirSuite__Account__c,ElixirSuite__Dataset1__c,ElixirSuite__EventId__c,ElixirSuite__Event_End_Date__c,
                                              ElixirSuite__Event_Start_Date__c,ElixirSuite__Event_subject__c,ElixirSuite__Form__c,ElixirSuite__Highly_Engaged__c,
                                              ElixirSuite__High_Engagement__c,ElixirSuite__Low_Engagement__c,ElixirSuite__Moderate_Engagement__c,ElixirSuite__Notes__c,
                                              ElixirSuite__Note__c,ElixirSuite__Plan_Hierarchy__c,ElixirSuite__Treatment_Plan__c,Id,
                                              IsDeleted,LastModifiedById,LastModifiedDate,Name,RecordTypeId 
                                              FROM ElixirSuite__Notes__c WHERE ElixirSuite__Plan_Hierarchy__c IN :setOfIds 
                                              WITH SECURITY_ENFORCED
                                              ORDER BY CreatedDate DESC];
                
                System.debug(listOfNotes);
                for(Notes__c noteRec : listOfNotes){
                    if(mapOfProblemToRec.containsKey(noteRec.ElixirSuite__Plan_Hierarchy__c)){
                        mapOfProblemToRec.get(noteRec.ElixirSuite__Plan_Hierarchy__c).add(noteRec);
                    }else{
                        List<Notes__c> notes = new List<Notes__c>();
                        notes.add(noteRec);
                        mapOfProblemToRec.put(noteRec.ElixirSuite__Plan_Hierarchy__c , notes);
                    }
                }
            }
            
            
        }
        if(level2_Goal_bhevDef!=null && level2_Goal_bhevDef.size()>0){
            Set<Id> setOfIds = (new Map<Id,sObject>(level2_Goal_bhevDef)).keySet();
            if(setOfIds!=null && setOfIds.size()>0){
                List<Notes__c> listOfNotes = [SELECT CreatedById,CreatedDate,ElixirSuite__Account__c,ElixirSuite__Dataset1__c,ElixirSuite__EventId__c,ElixirSuite__Event_End_Date__c,
                                              ElixirSuite__Event_Start_Date__c,ElixirSuite__Event_subject__c,ElixirSuite__Form__c,ElixirSuite__Highly_Engaged__c,
                                              ElixirSuite__High_Engagement__c,ElixirSuite__Low_Engagement__c,ElixirSuite__Moderate_Engagement__c,ElixirSuite__Notes__c,
                                              ElixirSuite__Note__c,ElixirSuite__Plan_Hierarchy__c,ElixirSuite__Treatment_Plan__c,Id,
                                              IsDeleted,LastModifiedById,LastModifiedDate,Name,RecordTypeId 
                                              FROM ElixirSuite__Notes__c 
                                              WHERE ElixirSuite__Plan_Hierarchy__c IN :setOfIds 
                                              WITH SECURITY_ENFORCED
                                              ORDER BY CreatedDate DESC];
                
                System.debug(listOfNotes);
                for(Notes__c noteRec : listOfNotes){
                    if(mapOfProblemToRec_2.containsKey(noteRec.ElixirSuite__Plan_Hierarchy__c)){
                        mapOfProblemToRec_2.get(noteRec.ElixirSuite__Plan_Hierarchy__c).add(noteRec);
                    }else{
                        List<Notes__c> notes = new List<Notes__c>();
                        notes.add(noteRec);
                        mapOfProblemToRec_2.put(noteRec.ElixirSuite__Plan_Hierarchy__c , notes);
                    }
                }
            } 
        }
        wrapper wrpr = new wrapper();  
        wrpr.mapOfProblemToNotes = mapOfProblemToRec;
        wrpr.mapOfProblemToNotes_2 = mapOfProblemToRec_2;
        wrpr.listOfGoal = level2_Goal;   
        wrpr.level2_Goal_bhevDef = level2_Goal_bhevDef;
        wrpr.listOfEvidence = level2_Goal ;
        return wrpr;
        
        
    }
    @AuraEnabled
    public static wrapper getInterventions(String taskId){
        Map <Id , List<Notes__c>> mapOfProblemToRec = new Map<Id , List<Notes__c>>();
        system.debug(taskId);       
        List<ElixirSuite__Plan_SubHierarchy__c> listOfTask = [SELECT CreatedById,CreatedDate,ElixirSuite__Dataset3__c,ElixirSuite__Description__c,Due_Date__c,
                                                              ElixirSuite__Plan_Hierarchy_Name__c,ElixirSuite__Plan_Hierarchy__c,Id,
                                                              IsDeleted,LastModifiedById,LastModifiedDate,
                                                              Name,OwnerId,RecordTypeId FROM ElixirSuite__Plan_SubHierarchy__c
                                                              where ElixirSuite__Plan_SubHierarchy__c = : taskId WITH SECURITY_ENFORCED];
        system.debug(listOfTask);
        if(listOfTask!=null && listOfTask.size()>0){
            Set<Id> setOfIds = (new Map<Id,sObject>(listOfTask)).keySet();
            if(setOfIds!=null && setOfIds.size()>0){
                List<Notes__c> listOfNotes = [SELECT CreatedById,CreatedDate,ElixirSuite__Account__c,ElixirSuite__Dataset1__c,ElixirSuite__EventId__c,ElixirSuite__Event_End_Date__c,
                                              ElixirSuite__Event_Start_Date__c,ElixirSuite__Event_subject__c,ElixirSuite__Form__c,ElixirSuite__Highly_Engaged__c,
                                              ElixirSuite__High_Engagement__c,ElixirSuite__Low_Engagement__c,ElixirSuite__Moderate_Engagement__c,ElixirSuite__Notes__c,
                                              ElixirSuite__Note__c,ElixirSuite__Plan_Hierarchy__c,ElixirSuite__Treatment_Plan__c,Id,
                                              IsDeleted,ElixirSuite__Plan_SubHierarchy__c,LastModifiedById,LastModifiedDate,Name,RecordTypeId 
                                              FROM ElixirSuite__Notes__c WHERE ElixirSuite__Plan_SubHierarchy__c IN :setOfIds 
                                              WITH SECURITY_ENFORCED
                                              ORDER BY CreatedDate DESC];
                
                System.debug(listOfNotes);
                for(Notes__c noteRec : listOfNotes){
                    if(mapOfProblemToRec.containsKey(noteRec.ElixirSuite__Plan_Hierarchy__c)){
                        mapOfProblemToRec.get(noteRec.ElixirSuite__Plan_SubHierarchy__c).add(noteRec);
                    }else{
                        List<Notes__c> notes = new List<Notes__c>();
                        notes.add(noteRec);
                        mapOfProblemToRec.put(noteRec.ElixirSuite__Plan_SubHierarchy__c , notes);
                    }
                }
            }
            
            
        }
        wrapper wrpr = new wrapper();
        wrpr.mapOfProblemToNotes = mapOfProblemToRec;
        wrpr.listOfTasks = listOfTask;                   
        return wrpr;
    }

    @AuraEnabled
    public static ApprovalWrapper checkLoggedInUserApprovalAuthority(String levelOfApproval){
        ApprovalWrapper obj  = new ApprovalWrapper();
        Boolean alloWProceed = false;
        String setUpEntity = '';
        String devRecordTypeId = Schema.SObjectType.ElixirSuite__Master_Object__c.getRecordTypeInfosByDeveloperName().get('CarePlan_Configuration').getRecordTypeId();
        ElixirSuite__Master_Object__c[] allApprovalMasterRecord = [Select Id,ElixirSuite__Approval_Level__c, ElixirSuite__Approval_Members__c,ElixirSuite__Approver__c,
                                                                   ElixirSuite__Approver_List__c,ElixirSuite__Approval_Members_Name__c from ElixirSuite__Master_Object__c  where 
                                                                   RecordTypeId=:devRecordTypeId AND ElixirSuite__Approval_Level__c =: Decimal.valueOf(levelOfApproval) WITH SECURITY_ENFORCED];
        if(allApprovalMasterRecord!=null && allApprovalMasterRecord.size()>0){
            String selectedApprovalUnit =  allApprovalMasterRecord[0].ElixirSuite__Approver__c;
            switch on selectedApprovalUnit {
                when 'Profile' {  
                    setUpEntity = 'Profile';
                    alloWProceed = matchApprovalUnitUtility(userinfo.getProfileId(),allApprovalMasterRecord);
                    
                }when 'Role' {
                    setUpEntity = 'Role';
                    alloWProceed = matchApprovalUnitUtility(UserInfo.getUserRoleId(),allApprovalMasterRecord);
                }
                when 'User' {
                    setUpEntity = 'User';
                    alloWProceed = matchApprovalUnitUtility(UserInfo.getUserId(),allApprovalMasterRecord);
                    
                }
                when 'Patient' {
                    setUpEntity = 'Patient';
                    alloWProceed = true;
                }
                when else {
                    System.Debug('Error');
                }
            }  
            
        }
        obj.verficationCode = [SELECT ID,ElixirSuite__Verification_Code__c,ElixirSuite__Verification_Code_New__c FROM USER 
                               WHERE ID=:UserInfo.getUserId() WITH SECURITY_ENFORCED].ElixirSuite__Verification_Code_New__c;
        obj.alloWProceed = alloWProceed;
        obj.setUpEntity = setUpEntity;
        return obj;
    }
    public static Boolean matchApprovalUnitUtility(String unitID, ElixirSuite__Master_Object__c[] allApprovalMasterRecord){
        Boolean returnUnit = false;
        String[] allProfileIDs = allApprovalMasterRecord[0].ElixirSuite__Approval_Members__c.split(';');
        if(allProfileIDs.contains(unitID)){
            returnUnit = true;
        }
        return returnUnit;
    }
    public class approvalWrapper{
        @AuraEnabled  public Boolean alloWProceed;  
        @AuraEnabled  public String setUpEntity; 
        @AuraEnabled  public String verficationCode;  
    }
    @AuraEnabled
    public static void saveProcedure(List<sObject> carePlan,Id caseId, String accountId, String starttimeProcedure , String endtimeProcedure,
                                     String signatureComment ,String signatureImage , String signatureDate ,
                                     String signatureComment3 ,String signatureImage3 , String signatureDate3 ,
                                     String signeeName , String signeeName3 , String approvalLevel,
                                     String signatureComment4 ,String signatureImage4 , String signatureDate4,String signeeName4,
                                     String signatureComment5 ,String signatureImage5 , String signatureDate5,String signeeName5){ 
                                         update carePlan;
                                         Id exisProcedure;
                                         Id accId = Id.valueof(accountId);
                                         //fetch master procedure
                                    
                                         //update on case record
                                         Treatment_Plan__c caseRecord = [SELECT Id,Primary_Therapist__c,Clinical_supervisor__c, End_Date__c, Start_Date__c,
                                                                         Treatment_Plan_Name__c ,Status__c 
                                                                         FROM Treatment_Plan__c where Id= :caseId 
                                                                         WITH SECURITY_ENFORCED
                                                                         limit 1];
                                         Decimal countOfMaxApproval = [SELECT ElixirSuite__Care_Plan_Approval_Level_Count__c 
                                                                       FROM ElixirSuite__ApprovalLevelForForms__c 
                                                                       WITH SECURITY_ENFORCED
                                                                       limit 1].ElixirSuite__Care_Plan_Approval_Level_Count__c;
                                         system.debug(approvalLevel);
                                         if(approvalLevel == 'Level2'){
                                             caseRecord.Signature_value_2__c = signatureImage;
                                             caseRecord.Comment_2__c = signatureComment;
                                             caseRecord.Approval_Level_2__c = true ;
                                             caseRecord.Signed_By_Level_2__c = signeeName ;    
                                             caseRecord.Signed_Date_2__c = date.parse(signatureDate);
                                             if(countOfMaxApproval == 2){
                                                 caseRecord.Status__c = 'Completed';   
                                             }
                                             else {
                                                 caseRecord.Status__c = 'In Progress';   
                                             }
                                             if( Schema.sObjectType.Treatment_Plan__c.fields.Comment_2__c.isUpdateable() &&
                                                Schema.sObjectType.Treatment_Plan__c.fields.Approval_Level_2__c.isUpdateable() &&
                                                Schema.sObjectType.Treatment_Plan__c.fields.Signed_By_Level_2__c.isUpdateable() &&
                                                Schema.sObjectType.Treatment_Plan__c.fields.Status__c.isUpdateable() &&
                                                Schema.sObjectType.Treatment_Plan__c.fields.Signed_Date_2__c.isUpdateable() ){
                                                    update caseRecord ;
                                                }
                                         }
                                         if(approvalLevel == 'Level3'){
                                             caseRecord.Signature_value_3__c = signatureImage3;
                                             caseRecord.Comment_3__c = signatureComment3;
                                             caseRecord.Approval_Level_3__c = true ;
                                             caseRecord.Signed_By_Level_3__c = signeeName3 ;               
                                             
                                             caseRecord.Signed_Date_3__c = date.parse(signatureDate3);
                                             if(countOfMaxApproval == 3){
                                                 caseRecord.Status__c = 'Completed';   
                                             }
                                             else {
                                                 caseRecord.Status__c = 'In Progress';   
                                             }
                                             if( Schema.sObjectType.Treatment_Plan__c.fields.Comment_3__c.isUpdateable() &&
                                                Schema.sObjectType.Treatment_Plan__c.fields.Approval_Level_3__c.isUpdateable() &&
                                                Schema.sObjectType.Treatment_Plan__c.fields.Signed_By_Level_3__c.isUpdateable() &&
                                                Schema.sObjectType.Treatment_Plan__c.fields.Status__c.isUpdateable() &&
                                                Schema.sObjectType.Treatment_Plan__c.fields.Signed_Date_3__c.isUpdateable() ){
                                                    update caseRecord ;
                                                }
                                         }
                                         if(approvalLevel == 'Level4'){
                                             caseRecord.Signature_value_4__c = signatureImage4;
                                             caseRecord.Comment_4__c = signatureComment4;
                                             caseRecord.Approval_Level_4__c = true ;
                                             caseRecord.Signed_By_Level_4__c = signeeName4 ;               
                                             
                                             caseRecord.Signed_Date_4__c = date.parse(signatureDate4);
                                             if(countOfMaxApproval == 4){
                                                 caseRecord.Status__c = 'Completed';   
                                             }
                                             else {
                                                 caseRecord.Status__c = 'In Progress';   
                                             }
                                             
                                             if( Schema.sObjectType.Treatment_Plan__c.fields.Comment_4__c.isUpdateable() &&
                                                Schema.sObjectType.Treatment_Plan__c.fields.Approval_Level_4__c.isUpdateable() &&
                                                Schema.sObjectType.Treatment_Plan__c.fields.Signed_By_Level_4__c.isUpdateable() &&
                                                Schema.sObjectType.Treatment_Plan__c.fields.Status__c.isUpdateable() &&
                                                Schema.sObjectType.Treatment_Plan__c.fields.Signed_Date_4__c.isUpdateable()){
                                                    update caseRecord ;
                                                }
                                         }
                                         if(approvalLevel == 'Level5'){
                                             caseRecord.Signature_value_5__c = signatureImage5;
                                             caseRecord.Comment_5__c = signatureComment5;
                                             caseRecord.Approval_Level_5__c = true ;
                                             caseRecord.Signed_By_Level_5__c = signeeName5 ;               
                                             caseRecord.Status__c = 'Completed'; 
                                             caseRecord.Signed_Date_5__c = date.parse(signatureDate5);
                                             if(Schema.sObjectType.Treatment_Plan__c.fields.Signature_value_5__c.isUpdateable() &&
                                                Schema.sObjectType.Treatment_Plan__c.fields.Comment_5__c.isUpdateable() &&
                                                Schema.sObjectType.Treatment_Plan__c.fields.Approval_Level_5__c.isUpdateable() &&
                                                Schema.sObjectType.Treatment_Plan__c.fields.Signed_By_Level_5__c.isUpdateable() &&
                                                Schema.sObjectType.Treatment_Plan__c.fields.Status__c.isUpdateable() &&
                                                Schema.sObjectType.Treatment_Plan__c.fields.Signed_Date_5__c.isUpdateable() ){
                                                    update caseRecord ;
                                                }
                                         }
                                         
                                         
                                     }
    
    // TANVEER  
    @AuraEnabled
    public static void updtCarePlanRecordAsClosed(Id caseId){
        if(caseId!=null){
            Treatment_Plan__c recordToUpdt = [select id,Status__c from Treatment_Plan__c 
                                              where Id= :caseId WITH SECURITY_ENFORCED limit 1];
            recordToUpdt.Status__c = 'In Progress';
            update recordToUpdt;
            System.debug('updated record '+recordToUpdt.Id);
        }
        
    }
    
    
    public class wrapper{
        @AuraEnabled  public List<Dataset1__c> listOfProblem;  
        @AuraEnabled  public List<Plan_Hierarchy__c> listOfGoal;   
        @AuraEnabled  public List<Plan_Hierarchy__c> listOfEvidence; 
        @AuraEnabled  public List<Plan_Hierarchy__c> level2_Goal_bhevDef; 
        @AuraEnabled  public String accountName;
        @AuraEnabled  public String userName;
        @AuraEnabled  public String accountId;
        @AuraEnabled  public Date patientBirthDate;
        @AuraEnabled  public Treatment_Plan__c carePlan;
        @AuraEnabled  public List<User> listOfAllUsers;
        @AuraEnabled  public String nameSpace;
        @AuraEnabled  public String VerficationCode; 
        @AuraEnabled  public ElixirSuite__Plan_SubHierarchy__c[] listOfObjs; 
        @AuraEnabled  public ElixirSuite__Plan_SubHierarchy__c[] listOfTasks; 
        @AuraEnabled  public ElixirSuite__Plan_SubHierarchy__c[] listOfIntervention;
        @AuraEnabled  public Map<Id,List<taskNoteWrapper>> mapOfTaskToNotes;
        @AuraEnabled  public Map<Id,List<Notes__c>> mapOfProblemToNotes;
        @AuraEnabled  public Map<Id,List<Notes__c>> mapOfProblemToRec;
        @AuraEnabled  public Map<Id,List<Notes__c>> mapOfProblemToNotes_2; 
        @AuraEnabled  public ElixirSuite__CarePlan_Hierarchy__c careplanCustomSettingHeirarchy; 
        @AuraEnabled  public Map<String,String> labelApicombo_CustomSetting;
    }
    public class taskNoteWrapper{
        @AuraEnabled  public String Id;
        @AuraEnabled  public String Content;
        @AuraEnabled  public Datetime CreatedDate;
    }*/

/*
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
        i++;        i++;
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
        i++;        i++;
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
        i++;        i++;
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
        i++;        i++;
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
        i++;        i++;
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
        i++;        i++;
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
    }*/
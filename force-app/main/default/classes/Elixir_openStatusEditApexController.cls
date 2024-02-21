/* Developer Name - Rohit singh Bora
*  Test Class - Elixir_openStatusEditApexControllerTest
*  Purpose - To edit care plan in 'Open Status'
*/

public with sharing class Elixir_openStatusEditApexController {
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
                                                      Primary_Therapist__c, Start_Date__c, Status__c  ,Treatment_Plan_Name__c  ,LastModifiedDate      
                                                      FROM Treatment_Plan__c where Id= :caseId WITH SECURITY_ENFORCED];
                
                if(caseRecord!=null && caseRecord.size()>0){
                    List<Dataset1__c> level1Heirarchy = new list<Dataset1__c>();
                    //Map<Id,Dataset1__c> level1Map = new Map<Id,Dataset1__c>();
                    
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
                                            FROM Dataset1__c WHERE Account__c = :patientId and ElixirSuite__Care_Episode__c = :lstVisits[0].Id WITH SECURITY_ENFORCED ORDER BY createddate desc];
                    }
                    /** commented by vishal
List<Dataset1__c> level1_heirarchy = [SELECT Id,Name,ElixirSuite__Description__c
FROM Dataset1__c WITH SECURITY_ENFORCED];**/
                    /* List<Dataset1__c> level1_heirarchy = [SELECT Dataset1__c,Due_Date__c,Description__c,Id,IsActive__c,Name,
Problem_Name__c,RecordTypeId,Templatized_Problem__c FROM Dataset1__c WHERE Treatment_Plan__c = : caseId 
AND RecordTypeId = : level1AcctSpecificRecType WITH SECURITY_ENFORCED];*/
                    /*If(level1_heirarchy != null && !level1_heirarchy.isEmpty()){
                        List<ElixirSuite__Plan_Hierarchy__c> ph = [SELECT Id,Name, ElixirSuite__Name__c, ElixirSuite__Description__c,ElixirSuite__Template_Problem__c, ElixirSuite__Template_Problem__r.Name,ElixirSuite__Due_Date__c,ElixirSuite__Treatment_Plan__c from ElixirSuite__Plan_Hierarchy__c WITH SECURITY_ENFORCED];
                        for(Dataset1__c ds : level1_heirarchy){
                            for(ElixirSuite__Plan_Hierarchy__c planH : ph){
                                if((planH.ElixirSuite__Template_Problem__c == ds.ElixirSuite__Template_Problem__c) && (planH.ElixirSuite__Treatment_Plan__c == caseId)){
                                    ds.ElixirSuite__Date_Onset__c = planH.ElixirSuite__Due_Date__c;
                                    ds.ElixirSuite__Template_Problem__r.Name = (String) planH.Id;
                                }
                            }
                        }
                        
                    }*/
                    wrpr.listOfProblem = level1Heirarchy;
                    wrpr.carePlan = caseRecord[0];                                    
                }
                
                listOfTopLevelGoals = [SELECT Id,Name, ElixirSuite__Plan_Hierarchy_Name__c,ElixirSuite__Treatment_Plan__c,
                                       ElixirSuite__Treatment_Plan__r.Name, ElixirSuite__Description__c,
                                       ElixirSuite__Template_Problem__c, ElixirSuite__Template_Problem__r.Name,ElixirSuite__Due_Date__c 
                                       FROM ElixirSuite__Plan_SubHierarchy__c WHERE ElixirSuite__Treatment_Plan__c =: caseId WITH SECURITY_ENFORCED ORDER BY createddate desc];
                
                listOfTopLevelObjectives = [SELECT Id,ElixirSuite__Name__c,ElixirSuite__Description__c,
                                            ElixirSuite__Plan_SubHierarchy__c,ElixirSuite__Treatment_Plan__c, 
                                            ElixirSuite__Treatment_Plan__r.Name, ElixirSuite__Template_Problem__c, 
                                            ElixirSuite__Template_Problem__r.Name, ElixirSuite__Plan_Hierarchy__c, 
                                            ElixirSuite__Plan_Hierarchy__r.Name,ElixirSuite__Due_Date__c from ElixirSuite__Dataset2__c 
                                            WHERE ElixirSuite__Treatment_Plan__c =: caseId WITH SECURITY_ENFORCED ORDER BY createddate desc];
                listOfTopLevelTasks = [SELECT Id,Subject,OwnerId, WhatId, Description, ElixirSuite__Template_Problem__c,ActivityDate FROM Task WHERE WhatId =: caseId WITH SECURITY_ENFORCED ORDER BY createddate desc];
                
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
    public static void delNotes(String noteId){
        List<ContentDocument> listOfNotes= [SELECT Id,Description from ContentDocument WHERE Id =:noteId WITH SECURITY_ENFORCED];
        if(listOfNotes!=null && !listOfNotes.isEmpty()){
            DMLManager.deleteAsUser(listOfNotes);
        }
    }
    @AuraEnabled
    public static void delNotesOnCancel(List<String> noteId){
        List<ContentDocument> listOfNotes= [SELECT Id,Description from ContentDocument WHERE Id IN : noteId WITH SECURITY_ENFORCED];
        if(listOfNotes!=null && !listOfNotes.isEmpty()){
         DMLManager.deleteAsUser(listOfNotes);
        }
    }
    
    @AuraEnabled
    public static String saveNotes(String text , String patientId , String recordId, String recordName){
        String conDocumentId='';
        String prefix = 'CP-';
        ContentVersion cv = new ContentVersion();
        cv.Title = prefix + recordName;
        cv.PathOnClient = prefix + recordName + '.txt';
        cv.VersionData = Blob.valueOf(text);
        cv.IsMajorVersion = true;
        cv.FirstPublishLocationId = recordId;
        if(Schema.sObjectType.ContentVersion.isCreateable() && 
           Schema.sObjectType.ContentVersion.fields.Title.isCreateable() &&
           Schema.sObjectType.ContentVersion.fields.PathOnClient.isCreateable() &&
           Schema.sObjectType.ContentVersion.fields.VersionData.isCreateable() &&
           Schema.sObjectType.ContentVersion.fields.IsMajorVersion.isCreateable()){
               Insert cv;
           }    
        //After saved the Content Verison, get the ContentDocumentId
        Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id WITH SECURITY_ENFORCED].ContentDocumentId;
        conDocumentId = conDocument;
        /*Insert ContentDocumentLink
ContentDocumentLink cDocLink = new ContentDocumentLink();
cDocLink.ContentDocumentId = conDocument;//Add ContentDocumentId
cDocLink.LinkedEntityId = goalId;//Attach goal Id.
cDocLink.ShareType = 'V';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
cDocLink.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
if(Schema.sObjectType.ContentDocumentLink.isCreateable() && 
Schema.sObjectType.ContentDocumentLink.fields.ContentDocumentId.isCreateable() &&
Schema.sObjectType.ContentDocumentLink.fields.LinkedEntityId.isCreateable() &&
Schema.sObjectType.ContentDocumentLink.fields.ShareType.isCreateable() &&
Schema.sObjectType.ContentDocumentLink.fields.Visibility.isCreateable()){
Insert cDocLink;
}*/
        return conDocumentId;
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
    public static Wrapper getAllProblems(List<String> existingProblems, String accountId, String caseId){
        //Map<Id,sObject> mapOfExistingProbs = new  Map<Id,sObject>(existingProblems);
        // Id RecType3 = Schema.SObjectType.Dataset1__c.getRecordTypeInfosByDeveloperName().get('Templatized').getRecordTypeId();  
        //List<Dataset1__c> listOfProblems =  [SELECT Id, CreatedById, IsDeleted,Name ,Description__c
        //  FROM Dataset1__c WHERE Id NOT IN : setOfIds  AND RecordTypeId =:RecType3 WITH SECURITY_ENFORCED LIMIT 49000];
        
        Set<String> setOfIds = new Set<String>(existingProblems);
        Wrapper wrpr = new Wrapper();
        Elixir_Custom_Setting__c customSetting = Elixir_Custom_Setting__c.getOrgDefaults();
        String careFilter = customSetting.ElixirSuite__Default_Active_Care_Episode_Filter__c;
        if(string.isBlank(careFilter)){
            careFilter = 'createddate desc';
        }
        String careStatus = 'Active';
        
        string querystr = '';
        querystr += 'Select Id,ElixirSuite__Account__c,ElixirSuite__Status__c from ElixirSuite__Visits__c where ElixirSuite__Status__c=:careStatus AND ElixirSuite__Account__c =: accountId WITH SECURITY_ENFORCED order by ';
        querystr += careFilter ;
        List<ElixirSuite__Visits__c> lstVisits = database.query(querystr);
        if(lstVisits != null && !lstVisits.isEmpty()){
            List<Dataset1__c> listOfProblems =  [SELECT Id, CreatedById, IsDeleted,Name ,ElixirSuite__Description__c,ElixirSuite__Template_Problem__c,(select Id,ElixirSuite__Treatment_Plan__c,ElixirSuite__Due_Date__c from ElixirSuite__Plan_Hierarchy__r where ElixirSuite__Treatment_Plan__c =: caseId) 
                                                 FROM Dataset1__c WHERE Id NOT IN : setOfIds AND ElixirSuite__Care_Episode__c = :lstVisits[0].Id AND Account__c =: accountId WITH SECURITY_ENFORCED LIMIT 49000];
            wrpr.listOfProblem = listOfProblems;
        }
        
        return wrpr;
        
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
            List<ElixirSuite__Plan_SubHierarchy__c> ps = [SELECT Id,Name, ElixirSuite__Plan_Hierarchy_Name__c,ElixirSuite__Treatment_Plan__c,
                                 ElixirSuite__Treatment_Plan__r.Name, ElixirSuite__Description__c,ElixirSuite__Plan_Hierarchy__c,
                                 ElixirSuite__Template_Problem__c, ElixirSuite__Template_Problem__r.Name 
                                 FROM ElixirSuite__Plan_SubHierarchy__c WHERE Id =: goalId WITH SECURITY_ENFORCED];
            If(ps != null && !ps.isEmpty()){
                String templateID = ps[0].ElixirSuite__Template_Problem__c;
                Set<String> setOfIds = new Set<String>(existingTasks);
                listOfTasks =  [SELECT Id,Name,ElixirSuite__Description__c,ElixirSuite__Status__c FROM ElixirSuite__Template_Problem__c  WHERE Id NOT IN : setOfIds AND RecordTypeId =: objRecId AND ElixirSuite__Goal__c =: templateID
                                WITH SECURITY_ENFORCED LIMIT 49000]; 
            }
            else{
                Set<String> setOfIds = new Set<String>(existingTasks);
                listOfTasks =  [SELECT Id,Name,ElixirSuite__Description__c,ElixirSuite__Status__c FROM ElixirSuite__Template_Problem__c  WHERE Id NOT IN : setOfIds AND RecordTypeId =: objRecId AND ElixirSuite__Goal__c =: goalId
                                WITH SECURITY_ENFORCED LIMIT 49000];
            }
            
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
            List<ElixirSuite__Plan_SubHierarchy__c> ps = [SELECT Id,Name, ElixirSuite__Plan_Hierarchy_Name__c,ElixirSuite__Treatment_Plan__c,
                                 ElixirSuite__Treatment_Plan__r.Name, ElixirSuite__Description__c,ElixirSuite__Plan_Hierarchy__c,
                                 ElixirSuite__Template_Problem__c, ElixirSuite__Template_Problem__r.Name 
                                 FROM ElixirSuite__Plan_SubHierarchy__c WHERE Id =: goalId WITH SECURITY_ENFORCED];
            If(ps != null && !ps.isEmpty()){
                String templateID = ps[0].ElixirSuite__Template_Problem__c;
                Set<String> setOfIds = new Set<String>(existingTasks);
                listOfInts =  [SELECT Id,Name,ElixirSuite__Description__c,ElixirSuite__Status__c FROM ElixirSuite__Template_Problem__c  WHERE Id NOT IN : setOfIds  AND RecordTypeId =: intRecId AND ElixirSuite__Goal__c =: templateID 
                               WITH SECURITY_ENFORCED LIMIT 49000];
            }
            else{
                Set<String> setOfIds = new Set<String>(existingTasks);
                listOfInts =  [SELECT Id,Name,ElixirSuite__Description__c,ElixirSuite__Status__c FROM ElixirSuite__Template_Problem__c  WHERE Id NOT IN : setOfIds  AND RecordTypeId =: intRecId AND ElixirSuite__Goal__c =: goalId 
                               WITH SECURITY_ENFORCED LIMIT 49000];
            }
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
            List<ElixirSuite__Dataset2__c> ds2 = [SELECT Id,ElixirSuite__Name__c,ElixirSuite__Description__c,
                                 ElixirSuite__Plan_SubHierarchy__c,ElixirSuite__Treatment_Plan__c, 
                                 ElixirSuite__Treatment_Plan__r.Name, ElixirSuite__Template_Problem__c, 
                                 ElixirSuite__Template_Problem__r.Name, ElixirSuite__Plan_Hierarchy__c, 
                                 ElixirSuite__Plan_Hierarchy__r.Name from ElixirSuite__Dataset2__c 
                                 WHERE Id =: objectiveId WITH SECURITY_ENFORCED];
            If(ds2 != null && !ds2.isEmpty()){
                String templateID = ds2[0].ElixirSuite__Template_Problem__c;
                Set<String> setOfIds = new Set<String>(existingInts);
                listOfInts =  [SELECT Id,Name,ElixirSuite__Description__c,ElixirSuite__Status__c FROM ElixirSuite__Template_Problem__c  WHERE Id NOT IN : setOfIds  AND RecordTypeId =: intRecId AND ElixirSuite__Objective__c =: templateID 
                               WITH SECURITY_ENFORCED LIMIT 49000];
            }
            else{
                Set<String> setOfIds = new Set<String>(existingInts);
                listOfInts =  [SELECT Id,Name,ElixirSuite__Description__c,ElixirSuite__Status__c FROM ElixirSuite__Template_Problem__c  WHERE Id NOT IN : setOfIds  AND RecordTypeId =: intRecId AND ElixirSuite__Objective__c =: objectiveId 
                               WITH SECURITY_ENFORCED LIMIT 49000];
            }
            
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
    
    // For Saving Care plan
    @AuraEnabled
    public static void saveData(String masterData , Treatment_Plan__c caseRec , String status , String carePlanName , String caseId,
                                String starttimeProcedure , String endtimeProcedure, String signatureComment ,String signatureImage ,
                                String signatureDate ,String signeeName, String approvalLevel , String Description,String approvedValues,List<String> removedProblem,String accountId,List<String> removedIntervention){
                                   
                                    String startDate = String.valueOf(caseRec.Start_Date__c);
                                    String endDate = String.valueOf(caseRec.End_Date__c);
                                    
                                    fflib_ISObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
                                        new List<Schema.SObjectType>{
                                            ElixirSuite__Treatment_Plan__c.sObjectType,
                                                ElixirSuite__Procedure__c.sObjectType,
                                                ElixirSuite__Plan_Hierarchy__c.sObjectType, 
                                                ElixirSuite__Plan_SubHierarchy__c.sObjectType,
                                                ElixirSuite__Dataset2__c.sObjectType,
                                                Task.sObjectType
                                                }
                                    );
                                    //master data
                                    Map<String, Object> mainJson =(Map<String, Object>) JSON.deserializeUntyped(masterData);
                                    
                                    //initialize variable
                                    Treatment_Plan__c newTP = new Treatment_Plan__c();
                                    //List<ElixirSuite__Dataset2__c> objUpdateDesDateList = new List<ElixirSuite__Dataset2__c>();
                                    //List<Task> tskUpdateDesDate = new List<Task>();
                                    //Set<Id> deleteDataSet2Ids = new Set<Id>();
                                    //Set<Id> deleteTaskIds = new Set<Id>();
                                    Set<Id> deleteGoalTopNode = new Set<Id>();
                                    Set<id> deleteProblemNode = new Set<Id>();
                                    
                                    // update treatment plan
                                    Map<String, Object> listOfTP = (Map<String, Object>)mainJson.get('carePlan');
                                    if(listOfTP != null && !listOfTP.isEmpty()){
                                        Map<String, Object> mapOfTP = (Map<String, Object>) listOfTP;
                                        newTP.Id = caseId;
                                        newTP.Treatment_Plan_Name__c = carePlanName;
                                        newTP.Status__c = String.valueOf(mapOfTP.get('ElixirSuite__Status__c'));
                                        newTP.Start_Date__c = Date.valueOf(startDate);
                                        newTP.End_Date__c  = Date.valueOf(endDate);
                                        newTP.Primary_Therapist__c = (Id) mapOfTP.get('ElixirSuite__Primary_Therapist__c');
                                        newTP.Description__c = Description;                           
                                        newTP.Clinical_supervisor__c = (Id) mapOfTP.get('ElixirSuite__Clinical_supervisor__c');
                                        
                                        if(Schema.sObjectType.Treatment_Plan__c.fields.Treatment_Plan_Name__c.isUpdateable() &&
                                           Schema.sObjectType.Treatment_Plan__c.fields.Status__c.isUpdateable() &&
                                           Schema.sObjectType.Treatment_Plan__c.fields.Start_Date__c.isUpdateable() &&
                                           Schema.sObjectType.Treatment_Plan__c.fields.End_Date__c.isUpdateable() &&
                                           Schema.sObjectType.Treatment_Plan__c.fields.Primary_Therapist__c.isUpdateable() &&
                                           Schema.sObjectType.Treatment_Plan__c.fields.Description__c.isUpdateable() &&
                                           Schema.sObjectType.Treatment_Plan__c.fields.Clinical_supervisor__c.isUpdateable() 
                                          ){  
                                              uow.registerDirty(newTP);
                                          }
                                    }
                                    
                                    //added by Anmol for LX3-7236
                                    Elixir_Custom_Setting__c customSetting = Elixir_Custom_Setting__c.getOrgDefaults();
                                    String careFilter = customSetting.ElixirSuite__Default_Active_Care_Episode_Filter__c;
                                    if(string.isBlank(careFilter)){
                                        careFilter = 'createddate desc';
                                    }
                                    String careStatus = 'Active';
                                    
                                    string querystr = '';
                                    querystr += 'Select Id,ElixirSuite__Account__c,ElixirSuite__Status__c from ElixirSuite__Visits__c where ElixirSuite__Status__c=:careStatus AND ElixirSuite__Account__c =: accountId WITH SECURITY_ENFORCED order by ';
                                    querystr += careFilter ;
                                    List<ElixirSuite__Visits__c> lstVisits = database.query(querystr);
                                    //end by Anmol for LX3-7236
                                    
                                    Id devRecordTypeId = Schema.SObjectType.Procedure__c.getRecordTypeInfosByName().get('Patient Procedure').getRecordTypeId();
                                    Procedure__c newProcedure = new Procedure__c();
                                    //Map<String, Object> mapforProcedure = (Map<String, Object>) listOfTP;
                                    newProcedure.Account__c= accountId; 
                                    newProcedure.Name = carePlanName;
                                    newProcedure.RecordTypeId = devRecordTypeId;
                                    
                                    newProcedure.From_Date__c = date.valueOf(starttimeProcedure) ;
                                    newProcedure.Start_Time__c = date.valueOf(starttimeProcedure) ;
                                    newProcedure.To_Date__c = date.valueOf(endtimeProcedure) ;
                                    newProcedure.End_Time__c = date.valueOf(endtimeProcedure) ;
                                    
                                    if(Elixir_utility.dateTimeConversion(endtimeProcedure) <= Elixir_utility.dateTimeConversion(starttimeProcedure))
                                    {
                                        newProcedure.put('ElixirSuite__End_Time__c' , Elixir_utility.dateTimeConversion(starttimeProcedure).addMinutes(1));
                                    }
                                    else
                                    {
                                        newProcedure.put('ElixirSuite__End_Time__c' , Elixir_utility.dateTimeConversion(endtimeProcedure));
                                    }
                                    
                                    newProcedure.put('ElixirSuite__Start_Time__c' , Elixir_utility.dateTimeConversion(starttimeProcedure));
                                    
                                    newProcedure.Name = 'Care Plan-'+carePlanName;
                                    if(!lstVisits.isEmpty())
                                    {
                                        newProcedure.ElixirSuite__Visits__c =lstVisits[0].Id;
                                    }
                                    
                                    if(Schema.sObjectType.Procedure__c.fields.ElixirSuite__Visits__c.isCreateable() &&
                                       Schema.sObjectType.Procedure__c.fields.From_Date__c.isCreateable() &&
                                       Schema.sObjectType.Procedure__c.fields.Start_Time__c.isCreateable() &&
                                       Schema.sObjectType.Procedure__c.fields.To_Date__c.isCreateable() &&
                                       Schema.sObjectType.Procedure__c.fields.End_Time__c.isCreateable() &&
                                       Schema.sObjectType.Procedure__c.fields.Account__c.isCreateable() &&
                                       Schema.sObjectType.Procedure__c.fields.RecordTypeId.isCreateable() 
                                      ){ 
                                          uow.registerNew(newProcedure);
                                      }
                                    
                                    // update existing/insert new objective from top level hierarchy
                                    List<Object> listOfObjectives= (List<Object>) mainJson.get('listOfObjs');
                                    If(listOfObjectives != null && !listOfObjectives.isEmpty()){
                                        for(Object objRec : listOfObjectives){
                                            Map<String, Object> mapOfObj = (Map<String, Object>) objRec;
                                            if(mapOfObj.containsKey('Action')){
                                                If(String.valueOf(mapOfObj.get('Action')) == 'Update'){
                                                    if(!mapOfObj.containsKey('ElixirSuite__Treatment_Plan__c')){
                                                        // means new objective is added
                                                        ElixirSuite__Dataset2__c obj = new ElixirSuite__Dataset2__c();
                                                        obj.ElixirSuite__Name__c=String.valueOf(mapOfObj.get('Name'));
                                                        obj.ElixirSuite__Description__c=String.valueOf(mapOfObj.get('ElixirSuite__Description__c'));
                                                        obj.ElixirSuite__Template_Problem__c = (Id) mapOfObj.get('Id');
                                                        obj.ElixirSuite__Treatment_Plan__c = newTP.Id;
                                                        if(mapOfObj.containsKey('endDate')){
                                                            obj.ElixirSuite__Due_Date__c = Date.valueOf(String.valueOf(mapOfObj.get('endDate')));
                                                        }else{
                                                            obj.ElixirSuite__Due_Date__c = Date.valueOf(endDate);
                                                        }
                                                        
                                                        if(Schema.sObjectType.ElixirSuite__Dataset2__c.fields.ElixirSuite__Name__c.isCreateable() &&
                                                           Schema.sObjectType.ElixirSuite__Dataset2__c.fields.ElixirSuite__Description__c.isCreateable() &&
                                                           Schema.sObjectType.ElixirSuite__Dataset2__c.fields.ElixirSuite__Plan_Hierarchy__c.isCreateable() && 
                                                           Schema.sObjectType.ElixirSuite__Dataset2__c.fields.ElixirSuite__Template_Problem__c.isCreateable() 
                                                          ){ 
                                                             
                                                              uow.registerNew(obj, ElixirSuite__Dataset2__c.ElixirSuite__Treatment_Plan__c, newTP);
                                                          }
                                                        
                                                        //Add intervention into newly added Objective if any ---
                                                        List<Object> listOfInterv = (List<Object>) mapOfObj.get('listOfIntervention'); 
                                                       
                                                        if(listOfInterv!=null && listOfInterv.size()>0){
                                                            for(Object objRec1 : listOfInterv){
                                                                Map<String, Object> mapOfInt = (Map<String, Object>) objRec1; 
                                                               /* If(mapOfInt.containsKey('Action')){
                                                                    If(String.valueOf(mapOfInt.get('Action')) == 'Delete')
                                                                    {
                                                                        //do nothing
                                                                    }
                                                                }*/ //if (!mapOfInt.containsKey('Action') || !String.valueOf(mapOfInt.get('Action')).equals('Delete')) {
                                                                if (!(mapOfInt.containsKey('Action') && String.valueOf(mapOfInt.get('Action')) == 'Delete')){
                                                                    Task tsk = new Task();
                                                                    tsk.Description = String.valueOf(mapOfInt.get('ElixirSuite__Description__c'));
                                                                    tsk.Subject = String.valueOf(mapOfInt.get('Name'));
                                                                    tsk.Status = 'In Progress';
                                                                    tsk.OwnerId = mapOfInt.containsKey('assignedTo') ? String.valueOf(mapOfInt.get('assignedTo')) : String.valueOf(mapOfInt.get('OwnerId'));
                                                                    tsk.WhatId = obj.id;
                                                                    tsk.ElixirSuite__Template_Problem__c = (Id) mapOfInt.get('Id');
                                                                    if(mapOfInt.containsKey('endDate')){
                                                                        tsk.ActivityDate = Date.valueOf(String.valueOf(mapOfInt.get('endDate')));
                                                                    }else{
                                                                        tsk.ActivityDate = Date.valueOf(endDate);
                                                                    }
                                                                    if(Schema.sObjectType.Task.fields.Description.isCreateable() &&
                                                                       Schema.sObjectType.Task.fields.Subject.isCreateable() &&
                                                                       Schema.sObjectType.Task.fields.OwnerId.isCreateable() &&
                                                                       Schema.sObjectType.Task.fields.ActivityDate.isCreateable()                                       
                                                                      ){  
                                                                         
                                                                          uow.registerNew(tsk, Task.WhatId, obj);
                                                                      }
                                                                }
                                                            }
                                                        }
                                                    }
                                                    else{
                                                        //means there is possibility that in existing objective new intervention added
                                                        
                                                        ElixirSuite__Dataset2__c objUpdateDesDate = new ElixirSuite__Dataset2__c();
                                                        if(mapOfObj.containsKey('endDate')){
                                                            objUpdateDesDate.ElixirSuite__Due_Date__c = Date.valueOf(String.valueOf(mapOfObj.get('endDate')));
                                                        }
                                                        objUpdateDesDate.ElixirSuite__Description__c = String.valueOf(mapOfObj.get('ElixirSuite__Description__c'));
                                                        objUpdateDesDate.ElixirSuite__Name__c = String.valueOf(mapOfObj.get('ElixirSuite__Description__c'));
                                                        objUpdateDesDate.Id = (Id) mapOfObj.get('Id');
                                                        //objUpdateDesDateList.add(objUpdateDesDate); //check value changes or not for existing dataset2 
                                                        uow.registerDirty(objUpdateDesDate);
                                                        
                                                        // insert intervention into existing Objective if any ---
                                                        List<Object> listOfInterv = (List<Object>) mapOfObj.get('listOfIntervention'); 
                                                      
                                                        if(listOfInterv!=null && listOfInterv.size()>0){
                                                            for(Object objRec1 : listOfInterv){
                                                                Map<String, Object> mapOfInt = (Map<String, Object>) objRec1; 
                                                                Task tsk = new Task();
                                                                if(mapOfInt.containsKey('WhatId')){
                                                                    // existing intervention
                                                                    If(mapOfInt.containsKey('Action')){
                                                                        If(String.valueOf(mapOfInt.containsKey('Action')) == 'Delete'){
                                                                            tsk.Id = (Id) mapOfInt.get('Id');
                                                                            uow.registerDeleted(tsk);
                                                                        }
                                                                    }
                                                                    else{
                                                                        if(mapOfInt.containsKey('endDate')){
                                                                            tsk.ActivityDate = Date.valueOf(String.valueOf(mapOfInt.get('endDate')));
                                                                        }
                                                                        tsk.Description = String.valueOf(mapOfInt.get('Description'));
                                                                        tsk.Id = (Id) mapOfInt.get('Id');
                                                                        tsk.OwnerId = mapOfInt.containsKey('assignedTo') ? String.valueOf(mapOfInt.get('assignedTo')) : String.valueOf(mapOfInt.get('OwnerId'));
                                                                        uow.registerDirty(tsk);
                                                                        //tskUpdateDesDate.add(tsk);
                                                                    }
                                                                    
                                                                }
                                                                else{
                                                                    //new intervention added in existing objective
                                                                   /* If(mapOfInt.containsKey('Action')){
                                                                        If(String.valueOf(mapOfInt.containsKey('Action')) == 'Delete'){
                                                                            //do nothing
                                                                        }
                                                                    }*/
                                                                    if (!mapOfInt.containsKey('Action') || !String.valueOf(mapOfInt.get('Action')).equals('Delete')){
                                                                        tsk.Description = String.valueOf(mapOfInt.get('ElixirSuite__Description__c'));
                                                                        tsk.Subject = String.valueOf(mapOfInt.get('Name'));
                                                                        tsk.Status = 'In Progress';
                                                                        tsk.OwnerId = mapOfInt.containsKey('assignedTo') ? String.valueOf(mapOfInt.get('assignedTo')) : String.valueOf(mapOfInt.get('OwnerId'));
                                                                        tsk.WhatId = (Id) mapOfObj.get('Id');
                                                                        tsk.ElixirSuite__Template_Problem__c = (Id) mapOfInt.get('Id');
                                                                        if(mapOfInt.containsKey('endDate')){
                                                                            tsk.ActivityDate = Date.valueOf(String.valueOf(mapOfInt.get('endDate')));
                                                                        }else{
                                                                            tsk.ActivityDate = Date.valueOf(endDate);
                                                                        }
                                                                        if(Schema.sObjectType.Task.fields.Description.isCreateable() &&
                                                                           Schema.sObjectType.Task.fields.Subject.isCreateable() &&
                                                                           Schema.sObjectType.Task.fields.OwnerId.isCreateable() &&
                                                                           Schema.sObjectType.Task.fields.ActivityDate.isCreateable()                                       
                                                                          ){  
                                                                              
                                                                              uow.registerNew(tsk, Task.WhatId, objUpdateDesDate);
                                                                          }
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                                else{
                                                    // for deletion of objective and its related intervention
                                                    if(mapOfObj.containsKey('ElixirSuite__Treatment_Plan__c')){//delete only the existing one - old one
                                                        //deleteDataSet2Ids.add((Id) mapOfObj.get('Id'));
                                                        ElixirSuite__Dataset2__c obj = new ElixirSuite__Dataset2__c();
                                                        obj.Id = (Id) mapOfObj.get('Id');
                                                        List<Object> listOfInterv = (List<Object>) mapOfObj.get('listOfIntervention'); 
                                                        
                                                        if(listOfInterv!=null && listOfInterv.size()>0){
                                                            Task tsk = new Task();
                                                            for(Object objRec1 : listOfInterv){
                                                                Map<String, Object> mapOfInt = (Map<String, Object>) objRec1;
                                                                tsk.Id = (Id) mapOfInt.get('Id');
                                                                uow.registerDeleted(tsk);
                                                            }
                                                        }
                                                        
                                                        uow.registerDeleted(obj);
                                                    }
                                                }
                                            }
                                            else{
                                                //to update due date, description and assign to 
                                                if(mapOfObj.containsKey('ElixirSuite__Treatment_Plan__c')){
                                                    ElixirSuite__Dataset2__c objUpdateDesDate = new ElixirSuite__Dataset2__c();
                                                    if(mapOfObj.containsKey('endDate')){
                                                        objUpdateDesDate.ElixirSuite__Due_Date__c = Date.valueOf(String.valueOf(mapOfObj.get('endDate')));
                                                    }
                                                    objUpdateDesDate.ElixirSuite__Description__c = String.valueOf(mapOfObj.get('ElixirSuite__Description__c'));
                                                    objUpdateDesDate.ElixirSuite__Name__c = String.valueOf(mapOfObj.get('ElixirSuite__Description__c'));
                                                    objUpdateDesDate.Id = (Id) mapOfObj.get('Id');
                                                    uow.registerDirty(objUpdateDesDate);
                                                    //objUpdateDesDateList.add(objUpdateDesDate); //check value changes or not for existing dataset2
                                                    
                                                    // for intervention if any updates in description, due date, assign to
                                                    
                                                    List<Object> listOfInterv = (List<Object>) mapOfObj.get('listOfIntervention'); 
                                                   
                                                    if(listOfInterv!=null && !listOfInterv.isEmpty()){ 
                                                        for(Object objRec1 : listOfInterv){
                                                            Task tsk = new Task();
                                                            Map<String, Object> mapOfInt = (Map<String, Object>) objRec1;
                                                            If(mapOfInt.containsKey('Action'))
                                                            {
                                                                If(String.valueOf(mapOfInt.get('Action')) == 'Delete')
                                                                {
                                                                    tsk.Id = (Id) mapOfInt.get('Id');
                                                                    uow.registerDeleted(tsk);
                                                                }
                                                            }
                                                            else{
                                                                if(mapOfInt.containsKey('endDate')){
                                                                    tsk.ActivityDate = Date.valueOf(String.valueOf(mapOfInt.get('endDate')));
                                                                }
                                                                tsk.Description = String.valueOf(mapOfInt.get('Description'));
                                                                tsk.Subject = String.valueOf(mapOfInt.get('Description'));
                                                                tsk.Id = (Id) mapOfInt.get('Id');
                                                                tsk.OwnerId = mapOfInt.containsKey('assignedTo') ? String.valueOf(mapOfInt.get('assignedTo')) : String.valueOf(mapOfInt.get('OwnerId'));
                                                                uow.registerDirty(tsk);
                                                                //tskUpdateDesDate.add(tsk); // check to update intervention 
                                                            }
                                                        }
                                                    }
                                                }  
                                            }
                                        } 
                                    }
                                    
                                    
                                    //update existing/insert new Intervention from Top level hierarchy
                                    List<Object> listOfInterventions = (List<Object>) mainJson.get('listOfTasks');
                                    If(listOfInterventions != null && !listOfInterventions.isEmpty()){
                                        for(Object taskRec : listOfInterventions ){
                                            Map<String, Object> mapOfInt = (Map<String, Object>) taskRec;
                                            If(mapOfInt.containsKey('Action')){
                                                Task tsks = new task();
                                                If(String.valueOf(mapOfInt.get('Action')) == 'Update'){
                                                    //means new intervention is coming to insert
                                                    
                                                    tsks.Description = mapOfInt.containsKey('Description') ? String.valueOf(mapOfInt.get('Description')) : String.valueOf(mapOfInt.get('ElixirSuite__Description__c'));
                                                    tsks.Subject = mapOfInt.containsKey('Description') ? String.valueOf(mapOfInt.get('Description')) : String.valueOf(mapOfInt.get('Name'));
                                                    tsks.Status = 'In Progress';
                                                    tsks.OwnerId = mapOfInt.containsKey('assignedTo') ? String.valueOf(mapOfInt.get('assignedTo')) : String.valueOf(mapOfInt.get('OwnerId'));
                                                    tsks.WhatId = newTP.id;
                                                    tsks.ElixirSuite__Template_Problem__c = (Id) mapOfInt.get('Id');
                                                    
                                                    if(mapOfInt.containsKey('endDate')){
                                                        tsks.ActivityDate = Date.valueOf(String.valueOf(mapOfInt.get('endDate')));
                                                    }else{
                                                        tsks.ActivityDate = Date.valueOf(endDate);
                                                    }
                                                    if(Schema.sObjectType.Task.fields.Description.isCreateable() &&
                                                       Schema.sObjectType.Task.fields.Subject.isCreateable() &&
                                                       Schema.sObjectType.Task.fields.OwnerId.isCreateable() &&
                                                       Schema.sObjectType.Task.fields.ActivityDate.isCreateable()                                       
                                                      ){  
                                                          
                                                          uow.registerNew(tsks,Task.WhatId, newTP);
                                                      }
                                                }
                                                else{
                                                    //there is possibility interventions are removed both newly added and existing one
                                                    if(mapOfInt.containsKey('WhatId')){
                                                        //existing intervention removed
                                                        tsks.Id = (Id) mapOfInt.get('Id');
                                                        uow.registerDeleted(tsks);
                                                    }
                                                   /* else{
                                                        //do nothing as newly added intervention removed again..
                                                    }*/
                                                    
                                                    
                                                }
                                            }
                                            else{
                                                //update existing intervention
                                                Task tsk = new Task();
                                                tsk.Id = (Id) mapOfInt.get('Id');
                                                tsk.OwnerId = mapOfInt.containsKey('assignedTo') ? String.valueOf(mapOfInt.get('assignedTo')) : String.valueOf(mapOfInt.get('OwnerId'));
                                                if(mapOfInt.containsKey('endDate')){
                                                    tsk.ActivityDate = Date.valueOf(String.valueOf(mapOfInt.get('endDate')));
                                                }else{
                                                    tsk.ActivityDate = Date.valueOf(endDate);
                                                }
                                                tsk.Description = String.valueOf(mapOfInt.get('Description'));
                                                tsk.Subject = String.valueOf(mapOfInt.get('Description'));
                                                uow.registerDirty(tsk);
                                            }
                                            
                                        }
                                    }
                                     
                                    
                                    //update existing/insert new goal from top level hierarchy and its child..
                                    List<Object> listOfTopGoals = (List<Object>) mainJson.get('listOfGoal'); 
                                    
                                    if(listOfTopGoals!=null && !listOfTopGoals.isEmpty()){
                                        for(Object goalRec : listOfTopGoals){
                                            Map<String, Object> mapOfGoal = (Map<String, Object>) goalRec;
                                            If(mapOfGoal.containsKey('Action')){
                                                If(String.valueOf(mapOfGoal.get('Action')) == 'Update'){
                                                    //means new goals and its child inserted or in existing goal any new child inserted
                                                    If(mapOfGoal.containsKey('ElixirSuite__Treatment_Plan__c')){
                                                        //in existing goal any new child inserted or any values changes
                                                        ElixirSuite__Plan_SubHierarchy__c newGoal = new ElixirSuite__Plan_SubHierarchy__c();
                                                        newGoal.Id = (Id) mapOfGoal.get('Id');
                                                        
                                                        //Adding objective from existing goal
                                                        List<Object> listOfObj = (List<Object>) mapOfGoal.get('listOfTask'); 
                                                        
                                                        if(listOfObj!=null && !listOfObj.isEmpty()){
                                                            for(Object objRec : listOfObj){
                                                                Map<String, Object> mapOfobj = (Map<String, Object>) objRec;
                                                                If(!mapOfobj.containsKey('ElixirSuite__Plan_SubHierarchy__c')){
                                                                    //new objective added in existing one
                                                                    /*If(mapOfobj.containsKey('Action') && String.valueOf(mapOfobj.get('Action')) == 'Delete'){
                                                                        //do nothing
                                                                    }*/
                                                                    if (!(mapOfobj.containsKey('Action') && String.valueOf(mapOfobj.get('Action')) == 'Delete')){
                                                                        ElixirSuite__Dataset2__c ob = new ElixirSuite__Dataset2__c();
                                                                        ob.ElixirSuite__Name__c=String.valueOf(mapOfobj.get('ElixirSuite__Description__c'));
                                                                        ob.ElixirSuite__Description__c=String.valueOf(mapOfobj.get('ElixirSuite__Description__c'));
                                                                        ob.ElixirSuite__Plan_SubHierarchy__c=(Id) mapOfGoal.get('Id');
                                                                        ob.ElixirSuite__Template_Problem__c = (Id) mapOfobj.get('Id');
                                                                        
                                                                        if(mapOfobj.containsKey('endDate')){
                                                                            ob.ElixirSuite__Due_Date__c = Date.valueOf(String.valueOf(mapOfobj.get('endDate')));
                                                                        }else{
                                                                            ob.ElixirSuite__Due_Date__c = Date.valueOf(endDate);
                                                                        }                                                           
                                                                        if(Schema.sObjectType.ElixirSuite__Dataset2__c.fields.ElixirSuite__Name__c.isCreateable() &&
                                                                           Schema.sObjectType.ElixirSuite__Dataset2__c.fields.ElixirSuite__Description__c.isCreateable() &&
                                                                           Schema.sObjectType.ElixirSuite__Dataset2__c.fields.ElixirSuite__Plan_SubHierarchy__c.isCreateable() && 
                                                                           Schema.sObjectType.ElixirSuite__Dataset2__c.fields.ElixirSuite__Template_Problem__c.isCreateable()
                                                                          ){ 
                                                                             
                                                                              uow.registerNew(ob, ElixirSuite__Dataset2__c.ElixirSuite__Plan_SubHierarchy__c, newGoal);
                                                                          }
                                                                        
                                                                        //Adding intervention from objective if any
                                                                        List<Object> listOfInterv = (List<Object>) mapOfobj.get('listOfIntervention'); 
                                                                       
                                                                        if(listOfInterv!=null && !listOfInterv.isEmpty()){
                                                                            for(Object objRec1 : listOfInterv){
                                                                                Map<String, Object> mapOfInt = (Map<String, Object>) objRec1;  
                                                                                Task tsk = new task();
                                                                                tsk.Description = String.valueOf(mapOfInt.get('ElixirSuite__Description__c'));
                                                                                tsk.Subject = String.valueOf(mapOfInt.get('Name'));
                                                                                tsk.Status = 'In Progress';
                                                                                tsk.OwnerId = mapOfInt.containsKey('assignedTo') ? String.valueOf(mapOfInt.get('assignedTo')) : String.valueOf(mapOfInt.get('OwnerId'));
                                                                                tsk.WhatId = ob.id;
                                                                                tsk.ElixirSuite__Template_Problem__c = (Id) mapOfInt.get('Id');
                                                                                
                                                                                if(mapOfInt.containsKey('endDate')){
                                                                                    tsk.ActivityDate = Date.valueOf(String.valueOf(mapOfInt.get('endDate')));
                                                                                }else{
                                                                                    tsk.ActivityDate = Date.valueOf(endDate);
                                                                                }
                                                                                
                                                                                if(Schema.sObjectType.Task.fields.Description.isCreateable() &&
                                                                                   Schema.sObjectType.Task.fields.Subject.isCreateable() &&
                                                                                   Schema.sObjectType.Task.fields.OwnerId.isCreateable() &&
                                                                                   Schema.sObjectType.Task.fields.ActivityDate.isCreateable()   
                                                                                  ){ 
                                                                                      
                                                                                      uow.registerNew(tsk, Task.WhatId, ob);
                                                                                  }
                                                                            }
                                                                        }
                                                                    }
                                                                }
                                                                else{
                                                                    //there could be possibility that some changes in objective and its intervention
                                                                    If(mapOfobj.containsKey('Action') && String.valueOf(mapOfobj.get('Action')) == 'Delete'){
                                                                        ElixirSuite__Dataset2__c ob = new ElixirSuite__Dataset2__c();
                                                                        ob.Id = (Id) mapOfobj.get('Id');
                                                                        
                                                                        List<Object> listOfInterv = (List<Object>) mapOfobj.get('listOfIntervention'); 
                                                                        
                                                                        if(listOfInterv!=null && !listOfInterv.isEmpty()){
                                                                            for(Object taskRec : listOfInterventions ){
                                                                                Map<String, Object> mapOfInt = (Map<String, Object>) taskRec;
                                                                                Task tsk = new Task();
                                                                                tsk.Id = (Id) mapOfInt.get('Id');
                                                                                uow.registerDeleted(tsk);
                                                                            }
                                                                        }
                                                                        
                                                                        uow.registerDeleted(ob);
                                                                    }
                                                                    else{
                                                                        ElixirSuite__Dataset2__c ob = new ElixirSuite__Dataset2__c();
                                                                        ob.Id = (Id) mapOfobj.get('Id');
                                                                        if(mapOfobj.containsKey('endDate')){
                                                                            ob.ElixirSuite__Due_Date__c = Date.valueOf(String.valueOf(mapOfobj.get('endDate')));
                                                                        }
                                                                        ob.ElixirSuite__Description__c=String.valueOf(mapOfobj.get('ElixirSuite__Description__c'));
                                                                        ob.ElixirSuite__Name__c = String.valueOf(mapOfobj.get('ElixirSuite__Description__c'));
                                                                        uow.registerDirty(ob);
                                                                        
                                                                        //update intervention from objective
                                                                        List<Object> listOfInterv = (List<Object>) mapOfobj.get('listOfIntervention'); 
                                                                        
                                                                        if(listOfInterv!=null && !listOfInterv.isEmpty()){
                                                                            for(Object taskRec : listOfInterventions ){
                                                                                Map<String, Object> mapOfInt = (Map<String, Object>) taskRec;
                                                                                Task tsk = new Task();
                                                                                tsk.Id = (Id) mapOfInt.get('Id');
                                                                                tsk.OwnerId = mapOfInt.containsKey('assignedTo') ? String.valueOf(mapOfInt.get('assignedTo')) : String.valueOf(mapOfInt.get('OwnerId'));
                                                                                if(mapOfInt.containsKey('endDate')){
                                                                                    tsk.ActivityDate = Date.valueOf(String.valueOf(mapOfInt.get('endDate')));
                                                                                }
                                                                                tsk.Description = String.valueOf(mapOfInt.get('Description'));
                                                                                tsk.Subject = String.valueOf(mapOfInt.get('Description'));
                                                                                uow.registerDirty(tsk);
                                                                            }
                                                                        }
                                                                    } 
                                                                }
                                                            }
                                                        }
                                                        
                                                        //Adding intervention from existing goal
                                                        List<Object> listOfIntervention = (List<Object>) mapOfGoal.get('listOfIntervention'); 
                                                        if(listOfIntervention!=null && !listOfIntervention.isEmpty()){
                                                            for(Object objRec : listOfIntervention){
                                                                Map<String, Object> mapOfInt = (Map<String, Object>) objRec;
                                                                If(!mapOfInt.containsKey('WhatId')){
                                                                    //means new intervention added in existing goal
                                                                   /* If(mapOfInt.containsKey('Action') && String.valueOf(mapOfInt.get('Action')) == 'Delete'){
                                                                        //do nothing
                                                                    }*/
                                                                    if (!(mapOfInt.containsKey('Action') && String.valueOf(mapOfInt.get('Action')) == 'Delete')){
                                                                        Task tsk = new task();
                                                                        tsk.Description = String.valueOf(mapOfInt.get('ElixirSuite__Description__c'));
                                                                        tsk.Subject = String.valueOf(mapOfInt.get('Name'));
                                                                        tsk.Status = 'In Progress';
                                                                        tsk.OwnerId = mapOfInt.containsKey('assignedTo') ? String.valueOf(mapOfInt.get('assignedTo')) : String.valueOf(mapOfInt.get('OwnerId'));
                                                                        tsk.WhatId = newGoal.id;
                                                                        tsk.ElixirSuite__Template_Problem__c = (Id) mapOfInt.get('Id');
                                                                        if(mapOfInt.containsKey('endDate')){
                                                                            tsk.ActivityDate = Date.valueOf(String.valueOf(mapOfInt.get('endDate')));
                                                                        }else{
                                                                            tsk.ActivityDate = Date.valueOf(endDate);
                                                                        }
                                                                        
                                                                        if(Schema.sObjectType.Task.fields.Description.isCreateable() &&
                                                                           Schema.sObjectType.Task.fields.Subject.isCreateable() &&
                                                                           Schema.sObjectType.Task.fields.OwnerId.isCreateable() &&
                                                                           Schema.sObjectType.Task.fields.ActivityDate.isCreateable()   
                                                                          ){  
                                                                              uow.registerNew(tsk, Task.WhatId, newGoal);
                                                                          }
                                                                    }
                                                                }
                                                                else{
                                                                    Task tsk = new Task();
                                                                    If(mapOfInt.containsKey('Action') && String.valueOf(mapOfInt.get('Action')) == 'Delete'){
                                                                        tsk.Id = (Id) mapOfInt.get('Id');
                                                                        uow.registerDeleted(tsk);
                                                                    }
                                                                    else{
                                                                        //there could be possibility some changes in intervention
                                                                        tsk.Id = (Id) mapOfInt.get('Id');
                                                                        tsk.OwnerId = mapOfInt.containsKey('assignedTo') ? String.valueOf(mapOfInt.get('assignedTo')) : String.valueOf(mapOfInt.get('OwnerId'));
                                                                        if(mapOfInt.containsKey('endDate')){
                                                                            tsk.ActivityDate = Date.valueOf(String.valueOf(mapOfInt.get('endDate')));
                                                                        }
                                                                        tsk.Description = String.valueOf(mapOfInt.get('Description'));
                                                                        tsk.Subject = String.valueOf(mapOfInt.get('Description'));
                                                                        uow.registerDirty(tsk);
                                                                    }
                                                                }
                                                                
                                                            }
                                                        }
                                                    }
                                                    else{
                                                        //new goals and its child inserted
                                                       /* If(mapOfGoal.containsKey('Action') && String.valueOf(mapOfGoal.get('Action')) == 'Delete'){
                                                            //do nothing
                                                        }*/
                                                        if (!(mapOfGoal.containsKey('Action') && String.valueOf(mapOfGoal.get('Action')) == 'Delete')){
                                                            ElixirSuite__Plan_SubHierarchy__c newGoal = new ElixirSuite__Plan_SubHierarchy__c();
                                                            newGoal.ElixirSuite__Plan_Hierarchy_Name__c =  String.valueOf(mapOfGoal.get('Name'));
                                                            newGoal.ElixirSuite__Description__c =  String.valueOf(mapOfGoal.get('ElixirSuite__Description__c'));
                                                            newGoal.ElixirSuite__Template_Problem__c = (Id) mapOfGoal.get('Id');
                                                            newGoal.ElixirSuite__Treatment_Plan__c = newTP.id;
                                                            if(mapOfGoal.containsKey('endDate')){
                                                                newGoal.ElixirSuite__Due_Date__c = Date.valueOf(String.valueOf(mapOfGoal.get('endDate')));
                                                            }else{
                                                                newGoal.ElixirSuite__Due_Date__c = Date.valueOf(endDate);
                                                            }
                                                            if(Schema.sObjectType.ElixirSuite__Plan_SubHierarchy__c.fields.ElixirSuite__Plan_Hierarchy_Name__c.isCreateable() &&
                                                               Schema.sObjectType.ElixirSuite__Plan_SubHierarchy__c.fields.ElixirSuite__Description__c.isCreateable() &&
                                                               Schema.sObjectType.ElixirSuite__Plan_SubHierarchy__c.fields.ElixirSuite__Template_Problem__c.isCreateable()
                                                              ){
                                                                 
                                                                  uow.registerNew(newGoal, ElixirSuite__Plan_SubHierarchy__c.ElixirSuite__Treatment_Plan__c, newTP);
                                                              }
                                                            //Adding objective from goal
                                                            List<Object> listOfObj = (List<Object>) mapOfGoal.get('listOfTask'); 
                                                            
                                                            if(listOfObj!=null && !listOfObj.isEmpty()){
                                                                for(Object objRec : listOfObj){
                                                                    Map<String, Object> mapOfobj = (Map<String, Object>) objRec;
                                                                   /* If(mapOfobj.containsKey('Action') && String.valueOf(mapOfobj.get('Action')) == 'Delete'){
                                                                        //do nothing
                                                                    }*/
                                                                    if (!(mapOfobj.containsKey('Action') && String.valueOf(mapOfobj.get('Action')) == 'Delete')){
                                                                        ElixirSuite__Dataset2__c ob = new ElixirSuite__Dataset2__c();
                                                                        ob.ElixirSuite__Name__c=String.valueOf(mapOfobj.get('Name'));
                                                                        ob.ElixirSuite__Description__c=String.valueOf(mapOfobj.get('ElixirSuite__Description__c'));
                                                                        ob.ElixirSuite__Plan_SubHierarchy__c=newGoal.id;
                                                                        ob.ElixirSuite__Template_Problem__c = (Id) mapOfobj.get('Id');
                                                                        
                                                                        if(mapOfobj.containsKey('endDate')){
                                                                            ob.ElixirSuite__Due_Date__c = Date.valueOf(String.valueOf(mapOfobj.get('endDate')));
                                                                        }else{
                                                                            ob.ElixirSuite__Due_Date__c = Date.valueOf(endDate);
                                                                        }                                                           
                                                                        if(Schema.sObjectType.ElixirSuite__Dataset2__c.fields.ElixirSuite__Name__c.isCreateable() &&
                                                                           Schema.sObjectType.ElixirSuite__Dataset2__c.fields.ElixirSuite__Description__c.isCreateable() &&
                                                                           Schema.sObjectType.ElixirSuite__Dataset2__c.fields.ElixirSuite__Plan_SubHierarchy__c.isCreateable() && 
                                                                           Schema.sObjectType.ElixirSuite__Dataset2__c.fields.ElixirSuite__Template_Problem__c.isCreateable()
                                                                          ){ 
                                                                              
                                                                              uow.registerNew(ob, ElixirSuite__Dataset2__c.ElixirSuite__Plan_SubHierarchy__c, newGoal);
                                                                          }
                                                                        
                                                                        //Adding intervention from objective
                                                                        List<Object> listOfInterv = (List<Object>) mapOfobj.get('listOfIntervention'); 
                                                                       
                                                                        if(listOfInterv!=null && !listOfInterv.isEmpty()){
                                                                            for(Object objRec1 : listOfInterv){
                                                                                Map<String, Object> mapOfInt = (Map<String, Object>) objRec1;
                                                                                /*If(mapOfInt.containsKey('Action') && String.valueOf(mapOfInt.get('Action')) == 'Delete'){
                                                                                    //do nothing
                                                                                }*/
                                                                                 if (!(mapOfInt.containsKey('Action') && String.valueOf(mapOfInt.get('Action')) == 'Delete')){
                                                                                    Task tsk = new task();
                                                                                    tsk.Description = String.valueOf(mapOfInt.get('ElixirSuite__Description__c'));
                                                                                    tsk.Subject = String.valueOf(mapOfInt.get('Name'));
                                                                                    tsk.Status = 'In Progress';
                                                                                    tsk.OwnerId = mapOfInt.containsKey('assignedTo') ? String.valueOf(mapOfInt.get('assignedTo')) : String.valueOf(mapOfInt.get('OwnerId'));
                                                                                    tsk.WhatId = ob.id;
                                                                                    tsk.ElixirSuite__Template_Problem__c = (Id) mapOfInt.get('Id');
                                                                                    
                                                                                    if(mapOfInt.containsKey('endDate')){
                                                                                        tsk.ActivityDate = Date.valueOf(String.valueOf(mapOfInt.get('endDate')));
                                                                                    }else{
                                                                                        tsk.ActivityDate = Date.valueOf(endDate);
                                                                                    }
                                                                                    
                                                                                    if(Schema.sObjectType.Task.fields.Description.isCreateable() &&
                                                                                       Schema.sObjectType.Task.fields.Subject.isCreateable() &&
                                                                                       Schema.sObjectType.Task.fields.OwnerId.isCreateable() &&
                                                                                       Schema.sObjectType.Task.fields.ActivityDate.isCreateable()   
                                                                                      ){ 
                                                                                          
                                                                                          uow.registerNew(tsk, Task.WhatId, ob);
                                                                                      } 
                                                                                }
                                                                            }
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                            // Adding intervention from Goal
                                                            
                                                            List<Object> listOfIntervention = (List<Object>) mapOfGoal.get('listOfIntervention'); 
                                                            if(listOfIntervention!=null && !listOfIntervention.isEmpty()){
                                                                for(Object objRec : listOfIntervention){
                                                                    Map<String, Object> mapOfInt = (Map<String, Object>) objRec;
                                                                    /*If(mapOfInt.containsKey('Action') && String.valueOf(mapOfInt.get('Action')) == 'Delete'){
                                                                        //do nothing
                                                                    }*/
                                                                    if (!(mapOfInt.containsKey('Action') && String.valueOf(mapOfInt.get('Action')) == 'Delete')){
                                                                        Task tsk = new task();
                                                                        tsk.Description = String.valueOf(mapOfInt.get('ElixirSuite__Description__c'));
                                                                        tsk.Subject = String.valueOf(mapOfInt.get('Name'));
                                                                        tsk.Status = 'In Progress';
                                                                        tsk.OwnerId = mapOfInt.containsKey('assignedTo') ? String.valueOf(mapOfInt.get('assignedTo')) : String.valueOf(mapOfInt.get('OwnerId'));
                                                                        tsk.WhatId = newGoal.id;
                                                                        tsk.ElixirSuite__Template_Problem__c = (Id) mapOfInt.get('Id');
                                                                        if(mapOfInt.containsKey('endDate')){
                                                                            tsk.ActivityDate = Date.valueOf(String.valueOf(mapOfInt.get('endDate')));
                                                                        }else{
                                                                            tsk.ActivityDate = Date.valueOf(endDate);
                                                                        }
                                                                        
                                                                        if(Schema.sObjectType.Task.fields.Description.isCreateable() &&
                                                                           Schema.sObjectType.Task.fields.Subject.isCreateable() &&
                                                                           Schema.sObjectType.Task.fields.OwnerId.isCreateable() &&
                                                                           Schema.sObjectType.Task.fields.ActivityDate.isCreateable()   
                                                                          ){  
                                                                              uow.registerNew(tsk, Task.WhatId, newGoal);
                                                                          }
                                                                    }
                                                                }
                                                            }
                                                        }  
                                                    }//new goals and its child inserted else ends here 
                                                }//update end here
                                                else{
                                                    //delete goal node
                                                    deleteGoalTopNode.add((Id) mapOfGoal.get('Id'));
                                                }
                                            }
                                            else{
                                                //update due date and description of goal and its associated child
                                                ElixirSuite__Plan_SubHierarchy__c newGoal = new ElixirSuite__Plan_SubHierarchy__c();
                                                newGoal.Id =  (Id) mapOfGoal.get('Id');
                                                newGoal.ElixirSuite__Plan_Hierarchy_Name__c =  String.valueOf(mapOfGoal.get('ElixirSuite__Description__c'));
                                                newGoal.ElixirSuite__Description__c =  String.valueOf(mapOfGoal.get('ElixirSuite__Description__c'));
                                                if(mapOfGoal.containsKey('endDate')){
                                                    newGoal.ElixirSuite__Due_Date__c = Date.valueOf(String.valueOf(mapOfGoal.get('endDate')));
                                                }
                                                uow.registerDirty(newGoal);
                                                
                                                //objective and its interventions
                                                List<Object> listOfObj = (List<Object>) mapOfGoal.get('listOfTask'); 
                                                
                                                if(listOfObj!=null && !listOfObj.isEmpty()){
                                                    for(Object objRec : listOfObj){
                                                        ElixirSuite__Dataset2__c ob = new ElixirSuite__Dataset2__c();
                                                        Map<String, Object> mapOfobj = (Map<String, Object>) objRec;
                                                        If(mapOfobj.containsKey('Action') && String.valueOf(mapOfobj.get('Action')) == 'Delete'){
                                                            ob.Id = (Id) mapOfobj.get('Id');
                                                            uow.registerDeleted(ob);
                                                        }
                                                        else{
                                                            ob.Id = (Id) mapOfobj.get('Id');
                                                            if(mapOfobj.containsKey('endDate')){
                                                                ob.ElixirSuite__Due_Date__c = Date.valueOf(String.valueOf(mapOfobj.get('endDate')));
                                                            }
                                                            ob.ElixirSuite__Description__c=String.valueOf(mapOfobj.get('ElixirSuite__Description__c'));
                                                            ob.ElixirSuite__Name__c = String.valueOf(mapOfobj.get('ElixirSuite__Description__c'));
                                                            uow.registerDirty(ob);
                                                            
                                                            //update intervention from objective
                                                            List<Object> listOfInterv = (List<Object>) mapOfobj.get('listOfIntervention'); 
                                                           
                                                            if(listOfInterv!=null && !listOfInterv.isEmpty()){
                                                                for(Object taskRec : listOfInterv ){
                                                                    Map<String, Object> mapOfInt = (Map<String, Object>) taskRec;
                                                                    Task tsk = new Task();
                                                                    If(mapOfInt.containsKey('Action') && String.valueOf(mapOfInt.get('Action')) == 'Delete'){
                                                                        tsk.Id = (Id) mapOfInt.get('Id');
                                                                        uow.registerDeleted(tsk);
                                                                    }
                                                                    else{
                                                                        tsk.Id = (Id) mapOfInt.get('Id');
                                                                        tsk.OwnerId = mapOfInt.containsKey('assignedTo') ? String.valueOf(mapOfInt.get('assignedTo')) : String.valueOf(mapOfInt.get('OwnerId'));
                                                                        if(mapOfInt.containsKey('endDate')){
                                                                            tsk.ActivityDate = Date.valueOf(String.valueOf(mapOfInt.get('endDate')));
                                                                        }
                                                                        tsk.Description = String.valueOf(mapOfInt.get('Description'));
                                                                        tsk.Subject = String.valueOf(mapOfInt.get('Description'));
                                                                        uow.registerDirty(tsk);
                                                                    }
                                                                }
                                                            }
                                                        } 
                                                    }
                                                }
                                                //intervention of existing goal
                                                List<Object> listOfIntervention = (List<Object>) mapOfGoal.get('listOfIntervention'); 
                                                if(listOfIntervention!=null && !listOfIntervention.isEmpty()){
                                                    for(Object objRec : listOfIntervention){
                                                        Map<String, Object> mapOfInt = (Map<String, Object>) objRec;
                                                        Task tsk = new Task();
                                                        If(mapOfInt.containsKey('Action') && String.valueOf(mapOfInt.get('Action')) == 'Delete'){
                                                            tsk.Id = (Id) mapOfInt.get('Id');
                                                            uow.registerDeleted(tsk); 
                                                        }
                                                        else{
                                                            tsk.Id = (Id) mapOfInt.get('Id');
                                                            tsk.OwnerId = mapOfInt.containsKey('assignedTo') ? String.valueOf(mapOfInt.get('assignedTo')) : String.valueOf(mapOfInt.get('OwnerId'));
                                                            if(mapOfInt.containsKey('endDate')){
                                                                tsk.ActivityDate = Date.valueOf(String.valueOf(mapOfInt.get('endDate')));
                                                            }
                                                            tsk.Description = String.valueOf(mapOfInt.get('Description'));
                                                            tsk.Subject = String.valueOf(mapOfInt.get('Description'));
                                                            uow.registerDirty(tsk); 
                                                        } 
                                                    }
                                                }
                                            }
                                        } 
                                    }
                                    
                                    //problem starts here
                                    List<Object> listOfProblems = (List<Object>) mainJson.get('listOfProblem');
                                    If(listOfProblems != null && !listOfProblems.isEmpty()){
                                        for(Object problemRec : listOfProblems){
                                             Boolean isPlanHierarchy = false;
                                            Map<String, Object> mapOfProblem = (Map<String, Object>) problemRec;
                                            Map<String, Object> mapOfpHierarchy = new Map<String, Object>();
                                            If(mapOfProblem.containsKey('ElixirSuite__Plan_Hierarchy__r')){
                                                List<Object> pHierarchy = (List<Object>) mapOfProblem.get('ElixirSuite__Plan_Hierarchy__r'); 
                                                for(Object pHierarchyRec : pHierarchy){
                                                    mapOfpHierarchy = (Map<String, Object>) pHierarchyRec;
                                                    If(mapOfpHierarchy.containsKey('Id')){
                                                        isPlanHierarchy = true;
                                                        mapOfProblem.put('pHierarchy',mapOfpHierarchy.get('Id'));
                                                    } 
                                                }
                                            }
                                            Plan_Hierarchy__c newProblem = new Plan_Hierarchy__c();
                                            If(isPlanHierarchy){
                                                newProblem.Id = (Id) mapOfProblem.get('pHierarchy');
                                            }
                                            else{
                                                List<Object> checkListOfGoals = (List<Object>) mapOfProblem.get('listOfGoal');
                                                List<Object> checkListOfObj = (List<Object>) mapOfProblem.get('listOfDef');
                                                newProblem.ElixirSuite__Name__c = String.valueOf(mapOfProblem.get('Name'));
                                                newProblem.ElixirSuite__Description__c = String.valueOf(mapOfProblem.get('ElixirSuite__Description__c'));
                                                newProblem.ElixirSuite__Template_Problem__c = (Id) mapOfProblem.get('ElixirSuite__Template_Problem__c');
                                                newProblem.ElixirSuite__Treatment_Plan__c = newTP.Id;
                                                newProblem.ElixirSuite__Dataset1__c = (Id) mapOfProblem.get('Id');
                                                if(mapOfProblem.containsKey('ElixirSuite__Due_Date__c')){
                                                    newProblem.ElixirSuite__Due_Date__c = Date.valueOf(String.valueOf(mapOfProblem.get('ElixirSuite__Due_Date__c')));
                                                }else{
                                                    newProblem.ElixirSuite__Due_Date__c = Date.valueOf(endDate);
                                                }
                                                if(Schema.sObjectType.Plan_Hierarchy__c.fields.ElixirSuite__Name__c.isCreateable() &&
                                                   Schema.sObjectType.Plan_Hierarchy__c.fields.ElixirSuite__Description__c.isCreateable() &&
                                                   Schema.sObjectType.Plan_Hierarchy__c.fields.ElixirSuite__Template_Problem__c.isCreateable() && ((
                                                       checkListOfGoals!=null && !checkListOfGoals.isEmpty()) || (checkListOfObj!=null && !checkListOfObj.isEmpty())) )
                                                {   
                                                    uow.registerNew(newProblem, Plan_Hierarchy__c.ElixirSuite__Treatment_Plan__c, newTP);
                                                }
                                            }
                                            try{
                                            If(mapOfProblem.containsKey('Action')){
                                                
                                                If(String.valueOf(mapOfProblem.get('Action')) == 'Update'){
                                                    //update existing/insert new goal from problem level hierarchy and its child..
                                                    List<Object> listOfProblemGoals = (List<Object>) mapOfProblem.get('listOfGoal'); 
                                                    
                                                    if(listOfProblemGoals!=null && !listOfProblemGoals.isEmpty()){
                                                        for(Object goalRec : listOfProblemGoals){
                                                            Map<String, Object> mapOfGoal = (Map<String, Object>) goalRec;
                                                            //means new goals and its child inserted or in existing problem any new child inserted
                                                            If(mapOfGoal.containsKey('ElixirSuite__Plan_Hierarchy__c')){
                                                                If(mapOfGoal.containsKey('Action') && String.valueOf(mapOfGoal.get('Action')) == 'Delete'){
                                                                    deleteGoalTopNode.add((Id) mapOfGoal.get('Id'));
                                                                }
                                                                else{
                                                                    //in existing goal any new child inserted or any values changes
                                                                    ElixirSuite__Plan_SubHierarchy__c newGoal = new ElixirSuite__Plan_SubHierarchy__c();
                                                                    newGoal.Id = (Id) mapOfGoal.get('Id');
                                                                    newGoal.ElixirSuite__Plan_Hierarchy_Name__c =  String.valueOf(mapOfGoal.get('ElixirSuite__Description__c'));
                                                                    newGoal.ElixirSuite__Description__c =  String.valueOf(mapOfGoal.get('ElixirSuite__Description__c'));
                                                                    if(mapOfGoal.containsKey('endDate')){
                                                                        newGoal.ElixirSuite__Due_Date__c = Date.valueOf(String.valueOf(mapOfGoal.get('endDate')));
                                                                    }
                                                                    uow.registerDirty(newGoal);
                                                                    
                                                                    //Adding objective from existing goal
                                                                    List<Object> listOfObj = (List<Object>) mapOfGoal.get('listOfTask'); 

                                                                    if(listOfObj!=null && !listOfObj.isEmpty()){
                                                                        for(Object objRec : listOfObj){
                                                                            Map<String, Object> mapOfobj = (Map<String, Object>) objRec;
                                                                            If(!mapOfobj.containsKey('ElixirSuite__Plan_SubHierarchy__c')){
                                                                                //new objective added in existing one
                                                                               /* If(mapOfobj.containsKey('Action') && String.valueOf(mapOfobj.get('Action')) == 'Delete'){
                                                                                    //do nothing
                                                                                }*/
                                                                                if (!(mapOfobj.containsKey('Action') && String.valueOf(mapOfobj.get('Action')) == 'Delete')){
                                                                                    ElixirSuite__Dataset2__c ob = new ElixirSuite__Dataset2__c();
                                                                                    ob.ElixirSuite__Name__c=String.valueOf(mapOfobj.get('ElixirSuite__Description__c'));
                                                                                    ob.ElixirSuite__Description__c=String.valueOf(mapOfobj.get('ElixirSuite__Description__c'));
                                                                                    ob.ElixirSuite__Plan_SubHierarchy__c=(Id) mapOfGoal.get('Id');
                                                                                    ob.ElixirSuite__Template_Problem__c = (Id) mapOfobj.get('Id');
                                                                                    
                                                                                    if(mapOfobj.containsKey('endDate')){
                                                                                        ob.ElixirSuite__Due_Date__c = Date.valueOf(String.valueOf(mapOfobj.get('endDate')));
                                                                                    }else{
                                                                                        ob.ElixirSuite__Due_Date__c = Date.valueOf(endDate);
                                                                                    }                                                           
                                                                                    if(Schema.sObjectType.ElixirSuite__Dataset2__c.fields.ElixirSuite__Name__c.isCreateable() &&
                                                                                       Schema.sObjectType.ElixirSuite__Dataset2__c.fields.ElixirSuite__Description__c.isCreateable() &&
                                                                                       Schema.sObjectType.ElixirSuite__Dataset2__c.fields.ElixirSuite__Plan_SubHierarchy__c.isCreateable() && 
                                                                                       Schema.sObjectType.ElixirSuite__Dataset2__c.fields.ElixirSuite__Template_Problem__c.isCreateable()
                                                                                      ){ 
                                                                                          
                                                                                          uow.registerNew(ob, ElixirSuite__Dataset2__c.ElixirSuite__Plan_SubHierarchy__c, newGoal);
                                                                                      }
                                                                                    
                                                                                    //Adding intervention from objective if any
                                                                                    List<Object> listOfInterv = (List<Object>) mapOfobj.get('listOfIntervention'); 
                                                                                    
                                                                                    if(listOfInterv!=null && !listOfInterv.isEmpty()){
                                                                                        for(Object objRec1 : listOfInterv){
                                                                                            Map<String, Object> mapOfInt = (Map<String, Object>) objRec1;
                                                                                           /* If(mapOfInt.containsKey('Action') && String.valueOf(mapOfInt.get('Action')) == 'Delete'){
                                                                                                //do nothing
                                                                                            }*/
                                                                                           if (!(mapOfInt.containsKey('Action') && String.valueOf(mapOfInt.get('Action')) == 'Delete')){
                                                                                                Task tsk = new task();
                                                                                                tsk.Description = String.valueOf(mapOfInt.get('ElixirSuite__Description__c'));
                                                                                                tsk.Subject = String.valueOf(mapOfInt.get('Name'));
                                                                                                tsk.Status = 'In Progress';
                                                                                                tsk.OwnerId = mapOfInt.containsKey('assignedTo') ? String.valueOf(mapOfInt.get('assignedTo')) : String.valueOf(mapOfInt.get('OwnerId'));
                                                                                                tsk.WhatId = ob.id;
                                                                                                tsk.ElixirSuite__Template_Problem__c = (Id) mapOfInt.get('Id');
                                                                                                
                                                                                                if(mapOfInt.containsKey('endDate')){
                                                                                                    tsk.ActivityDate = Date.valueOf(String.valueOf(mapOfInt.get('endDate')));
                                                                                                }else{
                                                                                                    tsk.ActivityDate = Date.valueOf(endDate);
                                                                                                }
                                                                                                
                                                                                                if(Schema.sObjectType.Task.fields.Description.isCreateable() &&
                                                                                                   Schema.sObjectType.Task.fields.Subject.isCreateable() &&
                                                                                                   Schema.sObjectType.Task.fields.OwnerId.isCreateable() &&
                                                                                                   Schema.sObjectType.Task.fields.ActivityDate.isCreateable()   
                                                                                                  ){ 
                                                                                                      
                                                                                                      uow.registerNew(tsk, Task.WhatId, ob);
                                                                                                  }
                                                                                            }
                                                                                        }
                                                                                    }
                                                                                }
                                                                            }
                                                                            else{
                                                                                //there could be possibility that some changes in objective and its intervention
                                                                                If(mapOfobj.containsKey('Action') && String.valueOf(mapOfobj.get('Action')) == 'Delete'){
                                                                                    ElixirSuite__Dataset2__c ob = new ElixirSuite__Dataset2__c();
                                                                                    ob.Id = (Id) mapOfobj.get('Id');
                                                                                    
                                                                                    List<Object> listOfInterv = (List<Object>) mapOfobj.get('listOfIntervention'); 
                                                                                   
                                                                                    if(listOfInterv!=null && !listOfInterv.isEmpty()){
                                                                                        for(Object taskRec : listOfInterventions ){
                                                                                            Map<String, Object> mapOfInt = (Map<String, Object>) taskRec;
                                                                                            Task tsk = new Task();
                                                                                            tsk.Id = (Id) mapOfInt.get('Id');
                                                                                            uow.registerDeleted(tsk);
                                                                                        }
                                                                                    }
                                                                                    
                                                                                    uow.registerDeleted(ob);
                                                                                }
                                                                                else{
                                                                                    ElixirSuite__Dataset2__c ob = new ElixirSuite__Dataset2__c();
                                                                                    ob.Id = (Id) mapOfobj.get('Id');
                                                                                    if(mapOfobj.containsKey('endDate')){
                                                                                        ob.ElixirSuite__Due_Date__c = Date.valueOf(String.valueOf(mapOfobj.get('endDate')));
                                                                                    }
                                                                                    ob.ElixirSuite__Description__c=String.valueOf(mapOfobj.get('ElixirSuite__Description__c'));
                                                                                    ob.ElixirSuite__Name__c = String.valueOf(mapOfobj.get('ElixirSuite__Description__c'));
                                                                                    uow.registerDirty(ob);
                                                                                    
                                                                                    //update intervention from objective
                                                                                    List<Object> listOfInterv = (List<Object>) mapOfobj.get('listOfIntervention'); 
                                                                                    
                                                                                    if(listOfInterv!=null && !listOfInterv.isEmpty()){
                                                                                        for(Object taskRec : listOfInterventions ){
                                                                                            Map<String, Object> mapOfInt = (Map<String, Object>) taskRec;
                                                                                            Task tsk = new Task();
                                                                                            tsk.Id = (Id) mapOfInt.get('Id');
                                                                                            tsk.OwnerId = mapOfInt.containsKey('assignedTo') ? String.valueOf(mapOfInt.get('assignedTo')) : String.valueOf(mapOfInt.get('OwnerId'));
                                                                                            if(mapOfInt.containsKey('endDate')){
                                                                                                tsk.ActivityDate = Date.valueOf(String.valueOf(mapOfInt.get('endDate')));
                                                                                            }
                                                                                            tsk.Description = String.valueOf(mapOfInt.get('Description'));
                                                                                            tsk.Subject = String.valueOf(mapOfInt.get('Description'));
                                                                                            uow.registerDirty(tsk);
                                                                                        }
                                                                                    }
                                                                                } 
                                                                            }
                                                                        }
                                                                    }
                                                                    
                                                                    //Adding intervention from existing goal
                                                                    List<Object> listOfIntervention = (List<Object>) mapOfGoal.get('listOfIntervention'); 
                                                                    if(listOfIntervention!=null && !listOfIntervention.isEmpty()){
                                                                        for(Object objRec : listOfIntervention){
                                                                            Map<String, Object> mapOfInt = (Map<String, Object>) objRec;
                                                                            If(!mapOfInt.containsKey('WhatId')){
                                                                                //means new intervention added in existing goal
                                                                               /* If(mapOfInt.containsKey('Action') && String.valueOf(mapOfInt.get('Action')) == 'Delete'){
                                                                                    //do nothing
                                                                                }*/
                                                                                if (!(mapOfInt.containsKey('Action') && String.valueOf(mapOfInt.get('Action')) == 'Delete')){
                                                                                    Task tsk = new task();
                                                                                    tsk.Description = String.valueOf(mapOfInt.get('ElixirSuite__Description__c'));
                                                                                    tsk.Subject = String.valueOf(mapOfInt.get('Name'));
                                                                                    tsk.Status = 'In Progress';
                                                                                    tsk.OwnerId = mapOfInt.containsKey('assignedTo') ? String.valueOf(mapOfInt.get('assignedTo')) : String.valueOf(mapOfInt.get('OwnerId'));
                                                                                    tsk.WhatId = newGoal.id;
                                                                                    tsk.ElixirSuite__Template_Problem__c = (Id) mapOfInt.get('Id');
                                                                                    if(mapOfInt.containsKey('endDate')){
                                                                                        tsk.ActivityDate = Date.valueOf(String.valueOf(mapOfInt.get('endDate')));
                                                                                    }else{
                                                                                        tsk.ActivityDate = Date.valueOf(endDate);
                                                                                    }
                                                                                    
                                                                                    if(Schema.sObjectType.Task.fields.Description.isCreateable() &&
                                                                                       Schema.sObjectType.Task.fields.Subject.isCreateable() &&
                                                                                       Schema.sObjectType.Task.fields.OwnerId.isCreateable() &&
                                                                                       Schema.sObjectType.Task.fields.ActivityDate.isCreateable()   
                                                                                      ){  
                                                                                          uow.registerNew(tsk, Task.WhatId, newGoal);
                                                                                      }
                                                                                }
                                                                            }
                                                                            else{
                                                                                Task tsk = new Task();
                                                                                If(mapOfInt.containsKey('Action') && String.valueOf(mapOfInt.get('Action')) == 'Delete'){
                                                                                    tsk.Id = (Id) mapOfInt.get('Id');
                                                                                    uow.registerDeleted(tsk);
                                                                                }
                                                                                else{
                                                                                    //there could be possibility some changes in intervention
                                                                                    tsk.Id = (Id) mapOfInt.get('Id');
                                                                                    tsk.OwnerId = mapOfInt.containsKey('assignedTo') ? String.valueOf(mapOfInt.get('assignedTo')) : String.valueOf(mapOfInt.get('OwnerId'));
                                                                                    if(mapOfInt.containsKey('endDate')){
                                                                                        tsk.ActivityDate = Date.valueOf(String.valueOf(mapOfInt.get('endDate')));
                                                                                    }
                                                                                    tsk.Description = String.valueOf(mapOfInt.get('Description'));
                                                                                    tsk.Subject = String.valueOf(mapOfInt.get('Description'));
                                                                                    uow.registerDirty(tsk);
                                                                                }
                                                                            }
                                                                            
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                            else{
                                                                //new goals and its child inserted
                                                               /* If(mapOfGoal.containsKey('Action') && String.valueOf(mapOfGoal.get('Action')) == 'Delete'){
                                                                    //do nothing
                                                                }*/
                                                                if (!(mapOfGoal.containsKey('Action') && String.valueOf(mapOfGoal.get('Action')) == 'Delete')){
                                                                    ElixirSuite__Plan_SubHierarchy__c newGoal = new ElixirSuite__Plan_SubHierarchy__c();
                                                                    newGoal.ElixirSuite__Plan_Hierarchy_Name__c =  String.valueOf(mapOfGoal.get('Name'));
                                                                    newGoal.ElixirSuite__Description__c =  String.valueOf(mapOfGoal.get('ElixirSuite__Description__c'));
                                                                    newGoal.ElixirSuite__Template_Problem__c = (Id) mapOfGoal.get('Id');
                                                                    newGoal.ElixirSuite__Plan_Hierarchy__c  = isPlanHierarchy == true ? (Id)mapOfProblem.get('pHierarchy') : newProblem.id;
                                                                    if(mapOfGoal.containsKey('endDate')){
                                                                        newGoal.ElixirSuite__Due_Date__c = Date.valueOf(String.valueOf(mapOfGoal.get('endDate')));
                                                                    }else{
                                                                        newGoal.ElixirSuite__Due_Date__c = Date.valueOf(endDate);
                                                                    }
                                                                    if(Schema.sObjectType.ElixirSuite__Plan_SubHierarchy__c.fields.ElixirSuite__Plan_Hierarchy_Name__c.isCreateable() &&
                                                                       Schema.sObjectType.ElixirSuite__Plan_SubHierarchy__c.fields.ElixirSuite__Description__c.isCreateable() &&
                                                                       Schema.sObjectType.ElixirSuite__Plan_SubHierarchy__c.fields.ElixirSuite__Template_Problem__c.isCreateable()
                                                                      ){
                                                                          
                                                                          uow.registerNew(newGoal, ElixirSuite__Plan_SubHierarchy__c.ElixirSuite__Plan_Hierarchy__c, newProblem);
                                                                      }
                                                                    //Adding objective from goal
                                                                    List<Object> listOfObj = (List<Object>) mapOfGoal.get('listOfTask'); 
                                                                    
                                                                    if(listOfObj!=null && !listOfObj.isEmpty()){
                                                                        for(Object objRec : listOfObj){
                                                                            Map<String, Object> mapOfobj = (Map<String, Object>) objRec;
                                                                           /*If(mapOfobj.containsKey('Action') && String.valueOf(mapOfobj.get('Action')) == 'Delete'){
                                                                                //do nothing
                                                                            }*/
                                                                            if (!(mapOfobj.containsKey('Action') && String.valueOf(mapOfobj.get('Action')) == 'Delete')){
                                                                                ElixirSuite__Dataset2__c ob = new ElixirSuite__Dataset2__c();
                                                                                ob.ElixirSuite__Name__c=String.valueOf(mapOfobj.get('Name'));
                                                                                ob.ElixirSuite__Description__c=String.valueOf(mapOfobj.get('ElixirSuite__Description__c'));
                                                                                ob.ElixirSuite__Plan_SubHierarchy__c=newGoal.id;
                                                                                ob.ElixirSuite__Template_Problem__c = (Id) mapOfobj.get('Id');
                                                                                
                                                                                if(mapOfobj.containsKey('endDate')){
                                                                                    ob.ElixirSuite__Due_Date__c = Date.valueOf(String.valueOf(mapOfobj.get('endDate')));
                                                                                }else{
                                                                                    ob.ElixirSuite__Due_Date__c = Date.valueOf(endDate);
                                                                                }                                                           
                                                                                if(Schema.sObjectType.ElixirSuite__Dataset2__c.fields.ElixirSuite__Name__c.isCreateable() &&
                                                                                   Schema.sObjectType.ElixirSuite__Dataset2__c.fields.ElixirSuite__Description__c.isCreateable() &&
                                                                                   Schema.sObjectType.ElixirSuite__Dataset2__c.fields.ElixirSuite__Plan_SubHierarchy__c.isCreateable() && 
                                                                                   Schema.sObjectType.ElixirSuite__Dataset2__c.fields.ElixirSuite__Template_Problem__c.isCreateable()
                                                                                  ){ 
                                                                                      
                                                                                      uow.registerNew(ob, ElixirSuite__Dataset2__c.ElixirSuite__Plan_SubHierarchy__c, newGoal);
                                                                                  }
                                                                                
                                                                                //Adding intervention from objective
                                                                                List<Object> listOfInterv = (List<Object>) mapOfobj.get('listOfIntervention'); 
                                                                               
                                                                                if(listOfInterv!=null && !listOfInterv.isEmpty()){
                                                                                    for(Object objRec1 : listOfInterv){
                                                                                        Map<String, Object> mapOfInt = (Map<String, Object>) objRec1;
                                                                                        If(mapOfInt.containsKey('Action') && String.valueOf(mapOfInt.get('Action')) == 'Delete'){
                                                                                            //do nothing
                                                                                        }
                                                                                        else{
                                                                                            Task tsk = new task();
                                                                                            tsk.Description = String.valueOf(mapOfInt.get('ElixirSuite__Description__c'));
                                                                                            tsk.Subject = String.valueOf(mapOfInt.get('Name'));
                                                                                            tsk.Status = 'In Progress';
                                                                                            tsk.OwnerId = mapOfInt.containsKey('assignedTo') ? String.valueOf(mapOfInt.get('assignedTo')) : String.valueOf(mapOfInt.get('OwnerId'));
                                                                                            tsk.WhatId = ob.id;
                                                                                            tsk.ElixirSuite__Template_Problem__c = (Id) mapOfInt.get('Id');
                                                                                            
                                                                                            if(mapOfInt.containsKey('endDate')){
                                                                                                tsk.ActivityDate = Date.valueOf(String.valueOf(mapOfInt.get('endDate')));
                                                                                            }else{
                                                                                                tsk.ActivityDate = Date.valueOf(endDate);
                                                                                            }
                                                                                            
                                                                                            if(Schema.sObjectType.Task.fields.Description.isCreateable() &&
                                                                                               Schema.sObjectType.Task.fields.Subject.isCreateable() &&
                                                                                               Schema.sObjectType.Task.fields.OwnerId.isCreateable() &&
                                                                                               Schema.sObjectType.Task.fields.ActivityDate.isCreateable()   
                                                                                              ){ 
                                                                                                 
                                                                                                  uow.registerNew(tsk, Task.WhatId, ob);
                                                                                              } 
                                                                                        }
                                                                                    }
                                                                                }
                                                                            }
                                                                        }
                                                                    }
                                                                    // Adding intervention from Goal
                                                                    
                                                                    List<Object> listOfIntervention = (List<Object>) mapOfGoal.get('listOfIntervention'); 
                                                                    if(listOfIntervention!=null && !listOfIntervention.isEmpty()){
                                                                        for(Object objRec : listOfIntervention){
                                                                            Map<String, Object> mapOfInt = (Map<String, Object>) objRec;
                                                                            /*If(mapOfInt.containsKey('Action') && String.valueOf(mapOfInt.get('Action')) == 'Delete'){
                                                                                //do nothing
                                                                            }*/
                                                                            if (!(mapOfInt.containsKey('Action') && String.valueOf(mapOfInt.get('Action')) == 'Delete')){
                                                                                Task tsk = new task();
                                                                                tsk.Description = String.valueOf(mapOfInt.get('ElixirSuite__Description__c'));
                                                                                tsk.Subject = String.valueOf(mapOfInt.get('Name'));
                                                                                tsk.Status = 'In Progress';
                                                                                tsk.OwnerId = mapOfInt.containsKey('assignedTo') ? String.valueOf(mapOfInt.get('assignedTo')) : String.valueOf(mapOfInt.get('OwnerId'));
                                                                                tsk.WhatId = newGoal.id;
                                                                                tsk.ElixirSuite__Template_Problem__c = (Id) mapOfInt.get('Id');
                                                                                if(mapOfInt.containsKey('endDate')){
                                                                                    tsk.ActivityDate = Date.valueOf(String.valueOf(mapOfInt.get('endDate')));
                                                                                }else{
                                                                                    tsk.ActivityDate = Date.valueOf(endDate);
                                                                                }
                                                                                
                                                                                if(Schema.sObjectType.Task.fields.Description.isCreateable() &&
                                                                                   Schema.sObjectType.Task.fields.Subject.isCreateable() &&
                                                                                   Schema.sObjectType.Task.fields.OwnerId.isCreateable() &&
                                                                                   Schema.sObjectType.Task.fields.ActivityDate.isCreateable()   
                                                                                  ){  
                                                                                      uow.registerNew(tsk, Task.WhatId, newGoal);
                                                                                  }
                                                                            }
                                                                        }
                                                                    }
                                                                }  
                                                            }//new goals and its child inserted else ends here 
                                                            
                                                        }//for loop of problem goal ends here
                                                    }
                                                    
                                                    // update existing/insert new objective from top level hierarchy
                                                    List<Object> listOfProblemObjectives= (List<Object>) mapOfProblem.get('listOfDef');
                                                    If(listOfProblemObjectives != null && !listOfProblemObjectives.isEmpty()){
                                                        for(Object objRec : listOfProblemObjectives){
                                                            Map<String, Object> mapOfObj = (Map<String, Object>) objRec;
                                                            if(!mapOfObj.containsKey('ElixirSuite__Plan_Hierarchy__c')){
                                                                // means new objective is added
                                                                /*If(mapOfObj.containsKey('Action') && String.valueOf(mapOfObj.get('Action')) == 'Delete'){
                                                                    //do nothing
                                                                }*/
                                                                if (!(mapOfObj.containsKey('Action') && String.valueOf(mapOfObj.get('Action')) == 'Delete')){
                                                                    ElixirSuite__Dataset2__c obj = new ElixirSuite__Dataset2__c();
                                                                    obj.ElixirSuite__Name__c=String.valueOf(mapOfObj.get('Name'));
                                                                    obj.ElixirSuite__Description__c=String.valueOf(mapOfObj.get('ElixirSuite__Description__c'));
                                                                    obj.ElixirSuite__Template_Problem__c = (Id) mapOfObj.get('Id');
                                                                    obj.ElixirSuite__Plan_Hierarchy__c = isPlanHierarchy == true ? (Id)mapOfProblem.get('pHierarchy') : newProblem.id;
                                                                    if(mapOfObj.containsKey('endDate')){
                                                                        obj.ElixirSuite__Due_Date__c = Date.valueOf(String.valueOf(mapOfObj.get('endDate')));
                                                                    }else{
                                                                        obj.ElixirSuite__Due_Date__c = Date.valueOf(endDate);
                                                                    }
                                                                    
                                                                    if(Schema.sObjectType.ElixirSuite__Dataset2__c.fields.ElixirSuite__Name__c.isCreateable() &&
                                                                       Schema.sObjectType.ElixirSuite__Dataset2__c.fields.ElixirSuite__Description__c.isCreateable() &&
                                                                       Schema.sObjectType.ElixirSuite__Dataset2__c.fields.ElixirSuite__Plan_Hierarchy__c.isCreateable() && 
                                                                       Schema.sObjectType.ElixirSuite__Dataset2__c.fields.ElixirSuite__Template_Problem__c.isCreateable() 
                                                                      ){ 
                                                                          
                                                                          uow.registerNew(obj, ElixirSuite__Dataset2__c.ElixirSuite__Plan_Hierarchy__c, newProblem);
                                                                      }
                                                                    
                                                                    //Add intervention into newly added Objective if any ---
                                                                    List<Object> listOfInterv = (List<Object>) mapOfObj.get('listOfIntervention'); 
                                                                  
                                                                    if(listOfInterv!=null && listOfInterv.size()>0){
                                                                        for(Object objRec1 : listOfInterv){
                                                                            Map<String, Object> mapOfInt = (Map<String, Object>) objRec1; 
                                                                            /*If(mapOfInt.containsKey('Action')){
                                                                                If(String.valueOf(mapOfInt.get('Action')) == 'Delete')
                                                                                {
                                                                                    //do nothing
                                                                                }
                                                                            }*/
                                                                            if (!(mapOfInt.containsKey('Action') && String.valueOf(mapOfInt.get('Action')) == 'Delete')){
                                                                                Task tsk = new Task();
                                                                                tsk.Description = String.valueOf(mapOfInt.get('ElixirSuite__Description__c'));
                                                                                tsk.Subject = String.valueOf(mapOfInt.get('Name'));
                                                                                tsk.Status = 'In Progress';
                                                                                tsk.OwnerId = mapOfInt.containsKey('assignedTo') ? String.valueOf(mapOfInt.get('assignedTo')) : String.valueOf(mapOfInt.get('OwnerId'));
                                                                                tsk.WhatId = obj.id;
                                                                                tsk.ElixirSuite__Template_Problem__c = (Id) mapOfInt.get('Id');
                                                                                if(mapOfInt.containsKey('endDate')){
                                                                                    tsk.ActivityDate = Date.valueOf(String.valueOf(mapOfInt.get('endDate')));
                                                                                }else{
                                                                                    tsk.ActivityDate = Date.valueOf(endDate);
                                                                                }
                                                                                if(Schema.sObjectType.Task.fields.Description.isCreateable() &&
                                                                                   Schema.sObjectType.Task.fields.Subject.isCreateable() &&
                                                                                   Schema.sObjectType.Task.fields.OwnerId.isCreateable() &&
                                                                                   Schema.sObjectType.Task.fields.ActivityDate.isCreateable()                                       
                                                                                  ){  
                                                                                     
                                                                                      uow.registerNew(tsk, Task.WhatId, obj);
                                                                                  }
                                                                            }
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                            else{
                                                                ElixirSuite__Dataset2__c objUpdateDesDate = new ElixirSuite__Dataset2__c();
                                                                If(mapOfObj.containsKey('Action') && String.valueOf(mapOfObj.get('Action')) == 'Delete'){
                                                                    objUpdateDesDate.Id = (Id) mapOfObj.get('Id');
                                                                    uow.registerDeleted(objUpdateDesDate);
                                                                }
                                                                else{
                                                                    //means there is possibility that in existing objective new intervention added
                                                                    
                                                                    if(mapOfObj.containsKey('endDate')){
                                                                        objUpdateDesDate.ElixirSuite__Due_Date__c = Date.valueOf(String.valueOf(mapOfObj.get('endDate')));
                                                                    }
                                                                    objUpdateDesDate.ElixirSuite__Description__c = String.valueOf(mapOfObj.get('ElixirSuite__Description__c'));
                                                                    objUpdateDesDate.ElixirSuite__Name__c = String.valueOf(mapOfObj.get('ElixirSuite__Description__c'));
                                                                    objUpdateDesDate.Id = (Id) mapOfObj.get('Id');
                                                                    //objUpdateDesDateList.add(objUpdateDesDate); //check value changes or not for existing dataset2 
                                                                    uow.registerDirty(objUpdateDesDate);
                                                                    
                                                                    // insert intervention into existing Objective if any ---
                                                                    List<Object> listOfInterv = (List<Object>) mapOfObj.get('listOfIntervention'); 
                                                                   
                                                                    if(listOfInterv!=null && listOfInterv.size()>0){
                                                                        for(Object objRec1 : listOfInterv){
                                                                            Map<String, Object> mapOfInt = (Map<String, Object>) objRec1; 
                                                                            Task tsk = new Task();
                                                                            if(mapOfInt.containsKey('WhatId')){
                                                                                // existing intervention
                                                                                If(mapOfInt.containsKey('Action')){
                                                                                    If(String.valueOf(mapOfInt.containsKey('Action')) == 'Delete'){
                                                                                        tsk.Id = (Id) mapOfInt.get('Id');
                                                                                        uow.registerDeleted(tsk);
                                                                                    }
                                                                                }
                                                                                else{
                                                                                    if(mapOfInt.containsKey('endDate')){
                                                                                        tsk.ActivityDate = Date.valueOf(String.valueOf(mapOfInt.get('endDate')));
                                                                                    }
                                                                                    tsk.Description = String.valueOf(mapOfInt.get('Description'));
                                                                                    tsk.Id = (Id) mapOfInt.get('Id');
                                                                                    tsk.OwnerId = mapOfInt.containsKey('assignedTo') ? String.valueOf(mapOfInt.get('assignedTo')) : String.valueOf(mapOfInt.get('OwnerId'));
                                                                                    uow.registerDirty(tsk);
                                                                                    //tskUpdateDesDate.add(tsk);
                                                                                }
                                                                                
                                                                            }
                                                                            else{
                                                                                //new intervention added in existing objective
                                                                               /* If(mapOfInt.containsKey('Action')){
                                                                                    If(String.valueOf(mapOfInt.containsKey('Action')) == 'Delete'){
                                                                                        //do nothing
                                                                                    }
                                                                                }*/
                                                                                if (!(mapOfInt.containsKey('Action') && String.valueOf(mapOfInt.get('Action')) == 'Delete')){
                                                                                    tsk.Description = String.valueOf(mapOfInt.get('ElixirSuite__Description__c'));
                                                                                    tsk.Subject = String.valueOf(mapOfInt.get('Name'));
                                                                                    tsk.Status = 'In Progress';
                                                                                    tsk.OwnerId = mapOfInt.containsKey('assignedTo') ? String.valueOf(mapOfInt.get('assignedTo')) : String.valueOf(mapOfInt.get('OwnerId'));
                                                                                    tsk.WhatId = (Id) mapOfObj.get('Id');
                                                                                    tsk.ElixirSuite__Template_Problem__c = (Id) mapOfInt.get('Id');
                                                                                    if(mapOfInt.containsKey('endDate')){
                                                                                        tsk.ActivityDate = Date.valueOf(String.valueOf(mapOfInt.get('endDate')));
                                                                                    }else{
                                                                                        tsk.ActivityDate = Date.valueOf(endDate);
                                                                                    }
                                                                                    if(Schema.sObjectType.Task.fields.Description.isCreateable() &&
                                                                                       Schema.sObjectType.Task.fields.Subject.isCreateable() &&
                                                                                       Schema.sObjectType.Task.fields.OwnerId.isCreateable() &&
                                                                                       Schema.sObjectType.Task.fields.ActivityDate.isCreateable()                                       
                                                                                      ){  
                                                                                         
                                                                                          uow.registerNew(tsk, Task.WhatId, objUpdateDesDate);
                                                                                      }
                                                                                }
                                                                            }
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                        }//for loop of problem objs ends here
                                                    }//if block of problem obj ends here
                                                }//problem update ends here
                                                else{
                                                    //delete problem node
                                                    if(isPlanHierarchy && mapOfProblem.containsKey('pHierarchy')){
                                                        deleteProblemNode.add((Id)mapOfProblem.get('pHierarchy'));
                                                    }
                                                    
                                                }
                                            } 
                                            else{
                                                //there could be some changes in due date and description of problem and its child node..
                                                Plan_Hierarchy__c newProblems = new Plan_Hierarchy__c();
                                                If(isPlanHierarchy && mapOfProblem.containsKey('pHierarchy')){
                                                    
                                                    newProblems.Id = (Id)mapOfProblem.get('pHierarchy');
                                                    newProblems.ElixirSuite__Description__c = String.valueOf(mapOfProblem.get('ElixirSuite__Description__c'));
                                                    newProblems.ElixirSuite__Due_Date__c = mapOfProblem.containsKey('ElixirSuite__Due_Date__c') ? Date.valueOf(String.valueOf(mapOfProblem.get('ElixirSuite__Due_Date__c'))) : Date.valueOf(endDate);
                                                    uow.registerDirty(newProblems);
                                                    
                                                    List<Object> listOfProblemGoals = (List<Object>) mapOfProblem.get('listOfGoal');
                                                    If(listOfProblemGoals!=null && !listOfProblemGoals.isEmpty()){
                                                        for(Object goalRec : listOfProblemGoals){
                                                            Map<String, Object> mapOfGoal = (Map<String, Object>) goalRec;
                                                            ElixirSuite__Plan_SubHierarchy__c newGoal = new ElixirSuite__Plan_SubHierarchy__c();
                                                            If(mapOfGoal.containsKey('Action') && String.valueOf(mapOfGoal.get('Action')) == 'Delete'){
                                                                deleteGoalTopNode.add((Id) mapOfGoal.get('Id'));
                                                            }
                                                            else{
                                                                newGoal.Id =  (Id) mapOfGoal.get('Id');
                                                                newGoal.ElixirSuite__Plan_Hierarchy_Name__c =  String.valueOf(mapOfGoal.get('ElixirSuite__Description__c'));
                                                                newGoal.ElixirSuite__Description__c =  String.valueOf(mapOfGoal.get('ElixirSuite__Description__c'));
                                                                if(mapOfGoal.containsKey('endDate')){
                                                                    newGoal.ElixirSuite__Due_Date__c = Date.valueOf(String.valueOf(mapOfGoal.get('endDate')));
                                                                }
                                                                uow.registerDirty(newGoal);
                                                                
                                                                //objective and its interventions
                                                                List<Object> listOfObj = (List<Object>) mapOfGoal.get('listOfTask'); 
                                                               
                                                                if(listOfObj!=null && !listOfObj.isEmpty()){
                                                                    for(Object objRec : listOfObj){
                                                                        Map<String, Object> mapOfobj = (Map<String, Object>) objRec;
                                                                        if(!mapOfobj.containsKey('ElixirSuite__Plan_SubHierarchy__c')){
                                                                           /* If(mapOfobj.containsKey('Action') && String.valueOf(mapOfobj.get('Action')) == 'Delete'){
                                                                                //do nothing
                                                                            }*/
                                                                            if (!(mapOfobj.containsKey('Action') && String.valueOf(mapOfobj.get('Action')) == 'Delete')){
                                                                                ElixirSuite__Dataset2__c ob = new ElixirSuite__Dataset2__c();
                                                                                ob.ElixirSuite__Name__c=String.valueOf(mapOfobj.get('Name'));
                                                                                ob.ElixirSuite__Description__c=String.valueOf(mapOfobj.get('ElixirSuite__Description__c'));
                                                                                ob.ElixirSuite__Plan_SubHierarchy__c=newGoal.Id;
                                                                                ob.ElixirSuite__Template_Problem__c = (Id) mapOfobj.get('Id');
                                                                                
                                                                                if(mapOfobj.containsKey('endDate')){
                                                                                    ob.ElixirSuite__Due_Date__c = Date.valueOf(String.valueOf(mapOfobj.get('endDate')));
                                                                                }else{
                                                                                    ob.ElixirSuite__Due_Date__c = Date.valueOf(endDate);
                                                                                }                                                           
                                                                                if(Schema.sObjectType.ElixirSuite__Dataset2__c.fields.ElixirSuite__Name__c.isCreateable() &&
                                                                                   Schema.sObjectType.ElixirSuite__Dataset2__c.fields.ElixirSuite__Description__c.isCreateable() &&
                                                                                   Schema.sObjectType.ElixirSuite__Dataset2__c.fields.ElixirSuite__Plan_SubHierarchy__c.isCreateable() && 
                                                                                   Schema.sObjectType.ElixirSuite__Dataset2__c.fields.ElixirSuite__Template_Problem__c.isCreateable()
                                                                                  ){ 
                                                                                      
                                                                                      uow.registerNew(ob, ElixirSuite__Dataset2__c.ElixirSuite__Plan_SubHierarchy__c, newGoal);
                                                                                  }
                                                                                
                                                                                //Adding intervention from objective
                                                                                List<Object> listOfInterv = (List<Object>) mapOfobj.get('listOfIntervention'); 
                                                                               
                                                                                if(listOfInterv!=null && !listOfInterv.isEmpty()){
                                                                                    for(Object objRec1 : listOfInterv){
                                                                                        Map<String, Object> mapOfInt = (Map<String, Object>) objRec1;
                                                                                       /* If(mapOfInt.containsKey('Action') && String.valueOf(mapOfInt.get('Action')) == 'Delete'){
                                                                                            //do nothing
                                                                                        }*/
                                                                                        if (!(mapOfInt.containsKey('Action') && String.valueOf(mapOfInt.get('Action')) == 'Delete')){
                                                                                            Task tsk = new task();
                                                                                            tsk.Description = String.valueOf(mapOfInt.get('ElixirSuite__Description__c'));
                                                                                            tsk.Subject = String.valueOf(mapOfInt.get('Name'));
                                                                                            tsk.Status = 'In Progress';
                                                                                            tsk.OwnerId = mapOfInt.containsKey('assignedTo') ? String.valueOf(mapOfInt.get('assignedTo')) : String.valueOf(mapOfInt.get('OwnerId'));
                                                                                            tsk.WhatId = ob.id;
                                                                                            tsk.ElixirSuite__Template_Problem__c = (Id) mapOfInt.get('Id');
                                                                                            
                                                                                            if(mapOfInt.containsKey('endDate')){
                                                                                                tsk.ActivityDate = Date.valueOf(String.valueOf(mapOfInt.get('endDate')));
                                                                                            }else{
                                                                                                tsk.ActivityDate = Date.valueOf(endDate);
                                                                                            }
                                                                                            
                                                                                            if(Schema.sObjectType.Task.fields.Description.isCreateable() &&
                                                                                               Schema.sObjectType.Task.fields.Subject.isCreateable() &&
                                                                                               Schema.sObjectType.Task.fields.OwnerId.isCreateable() &&
                                                                                               Schema.sObjectType.Task.fields.ActivityDate.isCreateable()   
                                                                                              ){ 
                                                                                                 
                                                                                                  uow.registerNew(tsk, Task.WhatId, ob);
                                                                                              } 
                                                                                        }
                                                                                    }
                                                                                }
                                                                            } 
                                                                        }
                                                                        else{
                                                                            ElixirSuite__Dataset2__c ob = new ElixirSuite__Dataset2__c();
                                                                            If(mapOfobj.containsKey('Action') && String.valueOf(mapOfobj.get('Action')) == 'Delete'){
                                                                                ob.Id = (Id) mapOfobj.get('Id');
                                                                                uow.registerDeleted(ob);
                                                                            }
                                                                            else{
                                                                                ob.Id = (Id) mapOfobj.get('Id');
                                                                                if(mapOfobj.containsKey('endDate')){
                                                                                    ob.ElixirSuite__Due_Date__c = Date.valueOf(String.valueOf(mapOfobj.get('endDate')));
                                                                                }
                                                                                ob.ElixirSuite__Description__c=String.valueOf(mapOfobj.get('ElixirSuite__Description__c'));
                                                                                ob.ElixirSuite__Name__c = String.valueOf(mapOfobj.get('ElixirSuite__Description__c'));
                                                                                uow.registerDirty(ob);
                                                                                
                                                                                //update intervention from objective
                                                                                List<Object> listOfInterv = (List<Object>) mapOfobj.get('listOfIntervention'); 
                                                                               
                                                                                if(listOfInterv!=null && !listOfInterv.isEmpty()){
                                                                                    for(Object taskRec : listOfInterv ){
                                                                                        Map<String, Object> mapOfInt = (Map<String, Object>) taskRec;
                                                                                        Task tsk = new Task();
                                                                                        If(mapOfInt.containsKey('Action') && String.valueOf(mapOfInt.get('Action')) == 'Delete'){
                                                                                           /* If(!mapOfInt.containsKey('WhatId')){
                                                                                                //do nothing as new record removed
                                                                                            }*/
                                                                                            If(mapOfInt.containsKey('WhatId')){
                                                                                                tsk.Id = (Id) mapOfInt.get('Id');
                                                                                                uow.registerDeleted(tsk);
                                                                                            }   
                                                                                        }
                                                                                        else{
                                                                                            If(!mapOfInt.containsKey('WhatId')){
                                                                                                tsk.Description = String.valueOf(mapOfInt.get('ElixirSuite__Description__c'));
                                                                                                tsk.Subject = String.valueOf(mapOfInt.get('ElixirSuite__Description__c'));
                                                                                                tsk.Status = 'In Progress';
                                                                                                tsk.OwnerId = mapOfInt.containsKey('assignedTo') ? String.valueOf(mapOfInt.get('assignedTo')) : String.valueOf(mapOfInt.get('OwnerId'));
                                                                                                tsk.WhatId = (Id) mapOfobj.get('Id');
                                                                                                tsk.ElixirSuite__Template_Problem__c = (Id) mapOfInt.get('Id');
                                                                                                if(mapOfInt.containsKey('endDate')){
                                                                                                    tsk.ActivityDate = Date.valueOf(String.valueOf(mapOfInt.get('endDate')));
                                                                                                }else{
                                                                                                    tsk.ActivityDate = Date.valueOf(endDate);
                                                                                                }
                                                                                                if(Schema.sObjectType.Task.fields.Description.isCreateable() &&
                                                                                                   Schema.sObjectType.Task.fields.Subject.isCreateable() &&
                                                                                                   Schema.sObjectType.Task.fields.OwnerId.isCreateable() &&
                                                                                                   Schema.sObjectType.Task.fields.ActivityDate.isCreateable()                                       
                                                                                                  ){  
                                                                                                      
                                                                                                      uow.registerNew(tsk, Task.WhatId, ob);
                                                                                                  } 
                                                                                            }
                                                                                            else{
                                                                                                tsk.Id = (Id) mapOfInt.get('Id');
                                                                                                tsk.OwnerId = mapOfInt.containsKey('assignedTo') ? String.valueOf(mapOfInt.get('assignedTo')) : String.valueOf(mapOfInt.get('OwnerId'));
                                                                                                if(mapOfInt.containsKey('endDate')){
                                                                                                    tsk.ActivityDate = Date.valueOf(String.valueOf(mapOfInt.get('endDate')));
                                                                                                }
                                                                                                tsk.Description = String.valueOf(mapOfInt.get('Description'));
                                                                                                tsk.Subject = String.valueOf(mapOfInt.get('Description'));
                                                                                                uow.registerDirty(tsk);
                                                                                            }  
                                                                                        }
                                                                                    }
                                                                                }
                                                                            }
                                                                        }    
                                                                    }
                                                                }
                                                                //intervention of existing goal
                                                                List<Object> listOfIntervention = (List<Object>) mapOfGoal.get('listOfIntervention'); 
                                                                if(listOfIntervention!=null && !listOfIntervention.isEmpty()){
                                                                    for(Object objRec : listOfIntervention){
                                                                        Map<String, Object> mapOfInt = (Map<String, Object>) objRec;
                                                                        If(!mapOfInt.containsKey('WhatId')){
                                                                            //means new intervention added in existing goal
                                                                            /*If(mapOfInt.containsKey('Action') && String.valueOf(mapOfInt.get('Action')) == 'Delete'){
                                                                                //do nothing
                                                                            }*/
                                                                            if (!(mapOfInt.containsKey('Action') && String.valueOf(mapOfInt.get('Action')) == 'Delete')){
                                                                                Task tsk = new task();
                                                                                tsk.Description = String.valueOf(mapOfInt.get('ElixirSuite__Description__c'));
                                                                                tsk.Subject = String.valueOf(mapOfInt.get('Name'));
                                                                                tsk.Status = 'In Progress';
                                                                                tsk.OwnerId = mapOfInt.containsKey('assignedTo') ? String.valueOf(mapOfInt.get('assignedTo')) : String.valueOf(mapOfInt.get('OwnerId'));
                                                                                tsk.WhatId = newGoal.id;
                                                                                tsk.ElixirSuite__Template_Problem__c = (Id) mapOfInt.get('Id');
                                                                                if(mapOfInt.containsKey('endDate')){
                                                                                    tsk.ActivityDate = Date.valueOf(String.valueOf(mapOfInt.get('endDate')));
                                                                                }else{
                                                                                    tsk.ActivityDate = Date.valueOf(endDate);
                                                                                }
                                                                                
                                                                                if(Schema.sObjectType.Task.fields.Description.isCreateable() &&
                                                                                   Schema.sObjectType.Task.fields.Subject.isCreateable() &&
                                                                                   Schema.sObjectType.Task.fields.OwnerId.isCreateable() &&
                                                                                   Schema.sObjectType.Task.fields.ActivityDate.isCreateable()   
                                                                                  ){  
                                                                                      uow.registerNew(tsk, Task.WhatId, newGoal);
                                                                                  }
                                                                            }
                                                                        }
                                                                        else{
                                                                            Task tsk = new Task();
                                                                            If(mapOfInt.containsKey('Action') && String.valueOf(mapOfInt.get('Action')) == 'Delete'){
                                                                                tsk.Id = (Id) mapOfInt.get('Id');
                                                                                uow.registerDeleted(tsk);
                                                                            }
                                                                            else{
                                                                                tsk.Id = (Id) mapOfInt.get('Id');
                                                                                tsk.OwnerId = mapOfInt.containsKey('assignedTo') ? String.valueOf(mapOfInt.get('assignedTo')) : String.valueOf(mapOfInt.get('OwnerId'));
                                                                                if(mapOfInt.containsKey('endDate')){
                                                                                    tsk.ActivityDate = Date.valueOf(String.valueOf(mapOfInt.get('endDate')));
                                                                                }
                                                                                tsk.Description = String.valueOf(mapOfInt.get('Description'));
                                                                                tsk.Subject = String.valueOf(mapOfInt.get('Description'));
                                                                                uow.registerDirty(tsk); 
                                                                            }  
                                                                        }  
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                    
                                                    
                                                    List<Object> listOfProblemObjectives= (List<Object>) mapOfProblem.get('listOfDef');
                                                    If(listOfProblemObjectives != null && !listOfProblemObjectives.isEmpty()){
                                                        for(Object objRec : listOfProblemObjectives){
                                                            Map<String, Object> mapOfObj = (Map<String, Object>) objRec;
                                                            
                                                            If(!mapOfObj.containsKey('ElixirSuite__Plan_Hierarchy__c')){ 
                                                                //new objective
                                                               /* If(mapOfObj.containsKey('Action') && String.valueOf(mapOfObj.get('Action')) == 'Delete'){
                                                                    //do nothing
                                                                }*/
                                                                if (!(mapOfObj.containsKey('Action') && String.valueOf(mapOfObj.get('Action')) == 'Delete')){
                                                                    ElixirSuite__Dataset2__c obj = new ElixirSuite__Dataset2__c();
                                                                    obj.ElixirSuite__Name__c=String.valueOf(mapOfObj.get('Name'));
                                                                    obj.ElixirSuite__Description__c=String.valueOf(mapOfObj.get('ElixirSuite__Description__c'));
                                                                    obj.ElixirSuite__Template_Problem__c = (Id) mapOfObj.get('Id');
                                                                    obj.ElixirSuite__Plan_Hierarchy__c = isPlanHierarchy == true ? (Id)mapOfProblem.get('pHierarchy') : newProblem.id;
                                                                    if(mapOfObj.containsKey('endDate')){
                                                                        obj.ElixirSuite__Due_Date__c = Date.valueOf(String.valueOf(mapOfObj.get('endDate')));
                                                                    }else{
                                                                        obj.ElixirSuite__Due_Date__c = Date.valueOf(endDate);
                                                                    }
                                                                    
                                                                    if(Schema.sObjectType.ElixirSuite__Dataset2__c.fields.ElixirSuite__Name__c.isCreateable() &&
                                                                       Schema.sObjectType.ElixirSuite__Dataset2__c.fields.ElixirSuite__Description__c.isCreateable() &&
                                                                       Schema.sObjectType.ElixirSuite__Dataset2__c.fields.ElixirSuite__Plan_Hierarchy__c.isCreateable() && 
                                                                       Schema.sObjectType.ElixirSuite__Dataset2__c.fields.ElixirSuite__Template_Problem__c.isCreateable() 
                                                                      ){ 
                                                                        
                                                                          uow.registerNew(obj, ElixirSuite__Dataset2__c.ElixirSuite__Plan_Hierarchy__c, newProblem);
                                                                      }
                                                                    
                                                                    //Add intervention into newly added Objective if any ---
                                                                    List<Object> listOfInterv = (List<Object>) mapOfObj.get('listOfIntervention'); 
                                                                   
                                                                    if(listOfInterv!=null && listOfInterv.size()>0){
                                                                        for(Object objRec1 : listOfInterv){
                                                                            Map<String, Object> mapOfInt = (Map<String, Object>) objRec1; 
                                                                           /* If(mapOfInt.containsKey('Action')){
                                                                                If(String.valueOf(mapOfInt.get('Action')) == 'Delete')
                                                                                {
                                                                                    //do nothing
                                                                                }
                                                                            }*/
                                                                            if (!(mapOfInt.containsKey('Action') && String.valueOf(mapOfInt.get('Action')) == 'Delete')){
                                                                                Task tsk = new Task();
                                                                                tsk.Description = String.valueOf(mapOfInt.get('ElixirSuite__Description__c'));
                                                                                tsk.Subject = String.valueOf(mapOfInt.get('Name'));
                                                                                tsk.Status = 'In Progress';
                                                                                tsk.OwnerId = mapOfInt.containsKey('assignedTo') ? String.valueOf(mapOfInt.get('assignedTo')) : String.valueOf(mapOfInt.get('OwnerId'));
                                                                                tsk.WhatId = obj.id;
                                                                                tsk.ElixirSuite__Template_Problem__c = (Id) mapOfInt.get('Id');
                                                                                if(mapOfInt.containsKey('endDate')){
                                                                                    tsk.ActivityDate = Date.valueOf(String.valueOf(mapOfInt.get('endDate')));
                                                                                }else{
                                                                                    tsk.ActivityDate = Date.valueOf(endDate);
                                                                                }
                                                                                if(Schema.sObjectType.Task.fields.Description.isCreateable() &&
                                                                                   Schema.sObjectType.Task.fields.Subject.isCreateable() &&
                                                                                   Schema.sObjectType.Task.fields.OwnerId.isCreateable() &&
                                                                                   Schema.sObjectType.Task.fields.ActivityDate.isCreateable()                                       
                                                                                  ){  
                                                                                      
                                                                                      uow.registerNew(tsk, Task.WhatId, obj);
                                                                                  }
                                                                            }
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                            else{
                                                                ElixirSuite__Dataset2__c objUpdateDesDate = new ElixirSuite__Dataset2__c();
                                                                
                                                                If(mapOfObj.containsKey('Action') && String.valueOf(mapOfObj.get('Action')) == 'Delete'){
                                                                    objUpdateDesDate.Id = (Id) mapOfObj.get('Id');
                                                                    uow.registerDeleted(objUpdateDesDate);
                                                                }
                                                                else{
                                                                    if(mapOfObj.containsKey('endDate')){
                                                                        objUpdateDesDate.ElixirSuite__Due_Date__c = Date.valueOf(String.valueOf(mapOfObj.get('endDate')));
                                                                    }
                                                                    objUpdateDesDate.ElixirSuite__Description__c = String.valueOf(mapOfObj.get('ElixirSuite__Description__c'));
                                                                    objUpdateDesDate.ElixirSuite__Name__c = String.valueOf(mapOfObj.get('ElixirSuite__Description__c'));
                                                                    objUpdateDesDate.Id = (Id) mapOfObj.get('Id');
                                                                    uow.registerDirty(objUpdateDesDate);
                                                                    
                                                                    // for intervention if any updates in description, due date, assign to
                                                                    
                                                                    List<Object> listOfInterv = (List<Object>) mapOfObj.get('listOfIntervention'); 
                                                                   
                                                                    if(listOfInterv!=null && listOfInterv.size()>0){
                                                                        for(Object objRec1 : listOfInterv){
                                                                            Map<String, Object> mapOfInt = (Map<String, Object>) objRec1;
                                                                            Task tsk = new Task();
                                                                            If(mapOfInt.containsKey('Action'))
                                                                            {
                                                                                If(String.valueOf(mapOfInt.get('Action')) == 'Delete')
                                                                                {
                                                                                    tsk.Id = (Id) mapOfInt.get('Id');
                                                                                    uow.registerDeleted(tsk);
                                                                                }
                                                                                
                                                                            }
                                                                            else{
                                                                                If(!mapOfInt.containsKey('WhatId')){
                                                                                    tsk.Description = String.valueOf(mapOfInt.get('ElixirSuite__Description__c'));
                                                                                    tsk.Subject = String.valueOf(mapOfInt.get('ElixirSuite__Description__c'));
                                                                                    tsk.Status = 'In Progress';
                                                                                    tsk.OwnerId = mapOfInt.containsKey('assignedTo') ? String.valueOf(mapOfInt.get('assignedTo')) : String.valueOf(mapOfInt.get('OwnerId'));
                                                                                    tsk.WhatId = (Id) mapOfObj.get('Id');
                                                                                    tsk.ElixirSuite__Template_Problem__c = (Id) mapOfInt.get('Id');
                                                                                    if(mapOfInt.containsKey('endDate')){
                                                                                        tsk.ActivityDate = Date.valueOf(String.valueOf(mapOfInt.get('endDate')));
                                                                                    }else{
                                                                                        tsk.ActivityDate = Date.valueOf(endDate);
                                                                                    }
                                                                                    if(Schema.sObjectType.Task.fields.Description.isCreateable() &&
                                                                                       Schema.sObjectType.Task.fields.Subject.isCreateable() &&
                                                                                       Schema.sObjectType.Task.fields.OwnerId.isCreateable() &&
                                                                                       Schema.sObjectType.Task.fields.ActivityDate.isCreateable()                                       
                                                                                      ){  
                                                                                         
                                                                                          uow.registerNew(tsk, Task.WhatId, objUpdateDesDate);
                                                                                      } 
                                                                                }
                                                                                else{
                                                                                    if(mapOfInt.containsKey('endDate')){
                                                                                        tsk.ActivityDate = Date.valueOf(String.valueOf(mapOfInt.get('endDate')));
                                                                                    }
                                                                                    tsk.Description = String.valueOf(mapOfInt.get('Description'));
                                                                                    tsk.Subject = String.valueOf(mapOfInt.get('Description'));
                                                                                    tsk.Id = (Id) mapOfInt.get('Id');
                                                                                    tsk.OwnerId = mapOfInt.containsKey('assignedTo') ? String.valueOf(mapOfInt.get('assignedTo')) : String.valueOf(mapOfInt.get('OwnerId'));
                                                                                    uow.registerDirty(tsk);
                                                                                } 
                                                                            }
                                                                        }
                                                                    } 
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                            }
                                            catch(Exception e){
                                                ExceptionLog.logError(e);
                                            }
                                        }
                                    }
                                    //check if goal node has to be delete or not
                                    If(deleteGoalTopNode != null && !deleteGoalTopNode.isEmpty()){
                                        List<ElixirSuite__Plan_SubHierarchy__c> ps = [SELECT Id FROM ElixirSuite__Plan_SubHierarchy__c WHERE Id In :deleteGoalTopNode];
                                        List<ElixirSuite__Dataset2__c> ds2 = [SELECT Id,ElixirSuite__Plan_SubHierarchy__c FROM ElixirSuite__Dataset2__c WHERE ElixirSuite__Plan_SubHierarchy__c IN : deleteGoalTopNode];
                                        If(ds2 != null && !ds2.isEmpty()){
                                            uow.registerDeleted(ds2);
                                        }
                                        If(ps != null && !ps.isEmpty()){
                                            uow.registerDeleted(ps);
                                        }
                                    }
                                    //check if problem node has to be delete or not
                                    If(deleteProblemNode != null && !deleteProblemNode.isEmpty()){
                                        List<ElixirSuite__Plan_Hierarchy__c> ph = [SELECT Id from ElixirSuite__Plan_Hierarchy__c WHERE Id In : deleteProblemNode WITH SECURITY_ENFORCED];
                                        List<ElixirSuite__Plan_SubHierarchy__c> ps = [SELECT Id,ElixirSuite__Plan_Hierarchy__c FROM ElixirSuite__Plan_SubHierarchy__c WHERE ElixirSuite__Plan_Hierarchy__c In :deleteProblemNode WITH SECURITY_ENFORCED];
                                        List<ElixirSuite__Dataset2__c> ds2 = [SELECT Id,ElixirSuite__Plan_Hierarchy__c FROM ElixirSuite__Dataset2__c WHERE ElixirSuite__Plan_Hierarchy__c IN : deleteProblemNode WITH SECURITY_ENFORCED];
                                        
                                        If(ds2 != null && !ds2.isEmpty()){
                                            uow.registerDeleted(ds2);
                                        }
                                        If(ps != null && !ps.isEmpty()){
                                            uow.registerDeleted(ps);
                                        }
                                        If(ph != null && !ph.isEmpty()){
                                            uow.registerDeleted(ph);
                                        }
                                    }
                                    
                                    //check if we have ids in removed problem or not
                                    if(removedProblem != null && !removedProblem.isEmpty()){
                                        List<ElixirSuite__Plan_Hierarchy__c> ph = [SELECT Id from ElixirSuite__Plan_Hierarchy__c WHERE Id In : removedProblem WITH SECURITY_ENFORCED];
                                        List<ElixirSuite__Plan_SubHierarchy__c> ps = [SELECT Id,ElixirSuite__Plan_Hierarchy__c FROM ElixirSuite__Plan_SubHierarchy__c WHERE ElixirSuite__Plan_Hierarchy__c In :removedProblem WITH SECURITY_ENFORCED];
                                        List<ElixirSuite__Dataset2__c> ds2 = [SELECT Id,ElixirSuite__Plan_Hierarchy__c FROM ElixirSuite__Dataset2__c WHERE ElixirSuite__Plan_Hierarchy__c IN : removedProblem WITH SECURITY_ENFORCED];
                                        
                                        If(ds2 != null && !ds2.isEmpty()){
                                            uow.registerDeleted(ds2);
                                        }
                                        If(ps != null && !ps.isEmpty()){
                                            uow.registerDeleted(ps);
                                        }
                                        If(ph != null && !ph.isEmpty()){
                                            uow.registerDeleted(ph);
                                        }
                                    }
                                    
                                    //check if we have ids in removed intervention or not
                                    if(removedIntervention != null && !removedIntervention.isEmpty()){
                                        List<Task> tsk = [SELECT Id from Task WHERE Id In : removedIntervention];
                                       
                                        If(tsk != null && !tsk.isEmpty()){
                                            uow.registerDeleted(tsk);
                                        }
                                    }
                                    
                                    uow.commitWork(); //finally commit
                                    Elixir_CarePlanController.attachApprovalDataToParentCarePlan(newTP.id,approvedValues); 
                                }
    
}
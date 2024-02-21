public with sharing class SearchBarController {
    
    @AuraEnabled
    public static List<LookupWrapperClass> getMenuItems(String searchKeyWord, String recId, String typeOfNote)
    {
        String searchKey = '%' + searchKeyWord + '%';
        String sQuery;
        
        
        ElixirSuite__TabExclusionSettings__c[] lstSettings = ElixirSuite__TabExclusionSettings__c.getall().values();
        
        List<String> finalValues = new List<String>();
        for(ElixirSuite__TabExclusionSettings__c tab : lstSettings)
        {
            finalValues = tab.ElixirSuite__Tab__c.split(';');
        }
        
        sQuery =  'select id, DeveloperName,ElixirSuite__Item_1__c from Tab_Structure_Items__mdt where ElixirSuite__Item_1__c LIKE: searchKey AND ElixirSuite__Item_1__c NOT IN : finalValues limit 100';
        

        
    
        List<ElixirSuite__Template_Problem__c> listOfProblems = new List<ElixirSuite__Template_Problem__c>();
        List<ElixirSuite__ICD_Codes__c> listOfDiagnosis = new List<ElixirSuite__ICD_Codes__c>(); 
        List<ElixirSuite__Procedure__c> listOfProcedure = new List<ElixirSuite__Procedure__c>();
        List<ElixirSuite__Prescription_Order__c> medicines = new List<ElixirSuite__Prescription_Order__c>();
        Id recordTypePro = Schema.SObjectType.ElixirSuite__Procedure__c.getRecordTypeInfosByDeveloperName().get('Template_Procedure').getRecordTypeId();
        Id recordTypeIdDiag = Schema.SObjectType.ElixirSuite__ICD_Codes__c .getRecordTypeInfosByDeveloperName().get('Template_Diagnosis_Code').getRecordTypeId();
        
        Id problemRecType = Schema.SObjectType.ElixirSuite__Template_Problem__c.getRecordTypeInfosByDeveloperName().get('Problem').getRecordTypeId();

        if(typeOfNote == 'Problem'){
        listOfProblems = [SELECT Id,Name,Description__c , Note__c,Status__c,SNOMED_CT_Code__c 
        FROM ElixirSuite__Template_Problem__c WHERE Name LIKE: searchKey AND RecordTypeId =:problemRecType
        WITH SECURITY_ENFORCED 
        LIMIT 10];
        }
        else if(typeOfNote == 'Diagnosis') {
        listOfDiagnosis = [SELECT Id,Name,ElixirSuite__Diagnosis_Code_and_Name__c,ElixirSuite__Active__c,ElixirSuite__Code_Description1__c
        FROM ElixirSuite__ICD_Codes__c WHERE Name LIKE: searchKey AND RecordTypeId =:recordTypeIdDiag
        WITH SECURITY_ENFORCED 
        LIMIT 10];
        }
        else if(typeOfNote == 'Medication'){
        medicines = [SELECT Id, 
                            ElixirSuite__Drug_Name__c,
                            ElixirSuite__Ferquency__c,
                            ElixirSuite__Route_New__c,
                            ElixirSuite__Notes__c
                            FROM ElixirSuite__Prescription_Order__c
                            WHERE ElixirSuite__Drug_Name__c LIKE: searchKey 
                            AND ElixirSuite__Account__c = NULL
                            WITH SECURITY_ENFORCED 
                            LIMIT 10];
        }
        else{
        listOfProcedure = [SELECT Id,Name,ElixirSuite__Account__c,ElixirSuite__Active__c,ElixirSuite__Code_Description__c
        FROM ElixirSuite__Procedure__c WHERE Name LIKE: searchKey AND ElixirSuite__Account__c = null AND RecordTypeId =:recordTypePro
        WITH SECURITY_ENFORCED 
        LIMIT 10];
        }
      
        List<LookupWrapperClass> menuItemsWrapper = new List<LookupWrapperClass>();

        for(ElixirSuite__Template_Problem__c problem :listOfProblems){
            LookupWrapperClass wrapObj = new LookupWrapperClass(problem.Id, problem.Name ,problem.Description__c, 'problems', false );
            menuItemsWrapper.add(wrapObj);
        }
        for(ElixirSuite__ICD_Codes__c diagnosis :listOfDiagnosis){
            LookupWrapperClass wrapObj = new LookupWrapperClass(diagnosis.Id, diagnosis.Name ,diagnosis.ElixirSuite__Code_Description1__c, 'diagnosis', false );
            menuItemsWrapper.add(wrapObj);
        }
        for(ElixirSuite__Procedure__c procedure :listOfProcedure){
            LookupWrapperClass wrapObj = new LookupWrapperClass(procedure.Id, procedure.Name ,procedure.ElixirSuite__Code_Description__c, 'procedure', false );
            menuItemsWrapper.add(wrapObj);
        }
        for(ElixirSuite__Prescription_Order__c medicine :medicines){
            LookupWrapperClass wrapObj = new LookupWrapperClass(medicine);
            menuItemsWrapper.add(wrapObj);
        }
        return menuItemsWrapper;
    }
    
    @AuraEnabled
    public static List<ICD_Codes__c> getDiagnosisItems(String searchKeyWord)
    {
        String searchKey = '%' + searchKeyWord + '%';
        List < ICD_Codes__c > lstIcds = [select id, Name,RecordType.Name from ICD_Codes__c 
        where Name LIKE: searchKey
        WITH SECURITY_ENFORCED];
        return lstIcds;
    }

    public class LookupWrapperClass
    {
        @AuraEnabled
        public String id;
        @AuraEnabled
        public String fieldName;
        @AuraEnabled
        public String description;
        @AuraEnabled
        public String type;
        @AuraEnabled
        public Boolean isNew;  
        @AuraEnabled
        public ElixirSuite__Prescription_Order__c medicine;        
        public LookupWrapperClass(String id, String fieldName,String description, String type, Boolean isNew){
            this.id = id;
            this.fieldName = fieldName;
            this.description = description;
            this.type = type;
            this.isNew = isNew;
           // this.innerWrap= innerWrap;
        }
        public LookupWrapperClass(ElixirSuite__Prescription_Order__c medicine){
            this.medicine = medicine;
        }
    }
    
    public class InnerWrapperCls
    {	
        @AuraEnabled  public String forms;
        @AuraEnabled  public String accName;
        @AuraEnabled  public String dob;
        @AuraEnabled  public String passCode;
        @AuraEnabled  public String parentAccount;
        
        public InnerWrapperCls( String forms,String accName ,String dob ,String passCode ,  String parentAccount)
        {
            this.forms = forms  ;
            this.accName = accName  ;
            this.dob = dob  ;
            this.passCode = passCode  ;
            this.parentAccount = parentAccount  ;
        }
    }
}
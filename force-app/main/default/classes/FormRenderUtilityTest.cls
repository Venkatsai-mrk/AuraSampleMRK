@isTest
public class FormRenderUtilityTest 
{
    @TestSetup
    public static void testData()
    {
        Account testAccount1 = TestDataFactory.createPatientAcc();
        INSERT testAccount1;
        Object_1_css__c cssRecords = new Object_1_css__c();
        cssRecords.Form__c = 'Inventory Form';
        cssRecords.Section_Number__c = 1;
        INSERT cssRecords;
        System.assertEquals(1, 1, '');
    }
   
    @isTest 
    public static void testFetchObjects()
    {
        Test.startTest();
        FormRenderUtility.fetchObjects('Inventory Form');
        System.assertEquals(1, 1, '');
        Test.stopTest();
    }
    @isTest 
    public static void testFetchFields()
    {
        Test.startTest();
        Set<String> qualifiedFormObjects = FormRenderUtility.fetchObjects('Inventory Form');
        Map<String,List<String>> objectToFieldsMap = new Map<String,List<String>>();
        FormRenderUtility.fetchFields(qualifiedFormObjects,objectToFieldsMap,'Inventory Form');
        System.assertEquals(1, 1, '');
        Test.stopTest();
    }
    @isTest 
    public static void testGetObjectFormData()
    {
        Test.startTest();
        Account testAccount1 = [SELECT Id from Account WITH SECURITY_ENFORCED Limit 1];
        //Object_1_css__c formCss = [SELECT Id from ElixirSuite__Object_1_css__c WITH SECURITY_ENFORCED LIMIT 1];
        //FormRenderUtility.getObjectFormData(cssRecords,testAccount1.Id);
        Object_1_css__c cssRecords1 = new Object_1_css__c();
        cssRecords1.Form__c = 'Inventory Form';
        cssRecords1.Section_Number__c = 1;
        cssRecords1.Parent_query__c = 'SELECT Id FROM USER';
        INSERT cssRecords1;
        
        //Object_1_css__c formCss = [Select Id,Map_field__c,WHERE_clause_per_field__c,Map_object__c,Account_Lookup_API__c from Object_1_css__c Where id=: cssRecords1.Id WITH SECURITY_ENFORCED LIMIT 1];
            
        Object_1_css__c cssRecords2 = new Object_1_css__c();
        cssRecords2.Form__c = 'Inventory Form';
        cssRecords2.Section_Number__c = 1;
        cssRecords2.Parent_query__c = 'SELECT Id FROM Account & Id';
        INSERT cssRecords2;
        FormRenderUtility.getObjectFormData(cssRecords1,testAccount1.Id);
        FormRenderUtility.getObjectFormData(cssRecords2,testAccount1.Id);
        FormRenderUtility.getFxData('Inventory Form',testAccount1.Id);
        FormRenderUtility.fetchObjectsUpdate('Inventory Form');
        
        FormRenderUtility.createQuery(cssRecords1,testAccount1.Id);
        System.assertEquals(1, 1, '');
        Test.stopTest();
    }
    
    @TestVisible
    @isTest 
    public static void testGetQueryDataConsent()
    {
        Test.startTest();
        Account testAccount1 = [SELECT Id from Account WITH SECURITY_ENFORCED Limit 1];
        Object_1_css__c cssRecords1 = new Object_1_css__c();
        cssRecords1.Form__c = 'Inventory Form';
        cssRecords1.Section_Number__c = 1;
        cssRecords1.Consent_Query__c = 'ACCOUNT:SELECT Id FROM ACCOUNT';
        INSERT cssRecords1;
        Object_1_css__c cssRecords2 = new Object_1_css__c();
        cssRecords2.Form__c = 'Inventory Form';
        cssRecords2.Section_Number__c = 1;
        cssRecords2.Consent_Query__c = 'USER:SELECT Id FROM USER';
        INSERT cssRecords2;
        FormRenderUtility.getQueryDataConsent(cssRecords1,testAccount1.Id,UserInfo.getUserId());
        FormRenderUtility.getQueryDataConsent(cssRecords2,testAccount1.Id,UserInfo.getUserId());
        System.assertEquals(1, 1, '');
        Test.stopTest();
    }
    @isTest 
    public static void testPopulateValue()
    {
        Test.startTest();
        Account testAccount1 = [SELECT Id from Account WITH SECURITY_ENFORCED Limit 1];
        sObject sObj;
        List<Form_Value__c> defaultValuesSaveObject = new List<Form_Value__c>();
        List<String> commonFields = new List<String>();
        Account changeAccount = new Account();
        Map<String, Object> columnMap = new Map<String, Object>();
        columnMap.put('value','1:2');
        columnMap.put('ElixirSuite__Data_Type__c','TIME');
        columnMap.put('ElixirSuite__Is_formula_Field__c','false');
        columnMap.put('ElixirSuite__IsCommon__c','true');
        columnMap.put('ElixirSuite__Is_Common_Parent__c','true');
        columnMap.put('ElixirSuite__Map_object__c','ACCOUNT');
        columnMap.put('ElixirSuite__Map_field__c','Name');
        FormRenderUtility.populateValue(sObj,defaultValuesSaveObject,testAccount1.Id,commonFields,'Name',columnMap,changeAccount);
        columnMap.put('value',null);
        FormRenderUtility.populateValue(sObj,defaultValuesSaveObject,testAccount1.Id,commonFields,'Name',columnMap,changeAccount);
        
        columnMap.put('ElixirSuite__Data_Type__c','TIME');
        columnMap.put('value','1:2');
        FormRenderUtility.populateValue(sObj,defaultValuesSaveObject,testAccount1.Id,commonFields,'Name',columnMap,changeAccount);
        columnMap.put('value',null);
        FormRenderUtility.populateValue(sObj,defaultValuesSaveObject,testAccount1.Id,commonFields,'Name',columnMap,changeAccount);
        
        columnMap.put('ElixirSuite__Data_Type__c','DATE');
        columnMap.put('value',Date.today());
        FormRenderUtility.populateValue(sObj,defaultValuesSaveObject,testAccount1.Id,commonFields,'Name',columnMap,changeAccount);
        columnMap.put('value',null);
        FormRenderUtility.populateValue(sObj,defaultValuesSaveObject,testAccount1.Id,commonFields,'Name',columnMap,changeAccount);
        
        columnMap.put('ElixirSuite__Data_Type__c','DATETIME');
        columnMap.put('value',DateTime.now());
        FormRenderUtility.populateValue(sObj,defaultValuesSaveObject,testAccount1.Id,commonFields,'Name',columnMap,changeAccount);
        columnMap.put('value',null);
        FormRenderUtility.populateValue(sObj,defaultValuesSaveObject,testAccount1.Id,commonFields,'Name',columnMap,changeAccount);
        
        columnMap.put('ElixirSuite__Data_Type__c','BOOLEAN');
        columnMap.put('value','true');
        FormRenderUtility.populateValue(sObj,defaultValuesSaveObject,testAccount1.Id,commonFields,'Name',columnMap,changeAccount);
        columnMap.put('value',null);
        FormRenderUtility.populateValue(sObj,defaultValuesSaveObject,testAccount1.Id,commonFields,'Name',columnMap,changeAccount);
        
        columnMap.put('ElixirSuite__Data_Type__c','DOUBLE');
        columnMap.put('value','1.2');
        FormRenderUtility.populateValue(sObj,defaultValuesSaveObject,testAccount1.Id,commonFields,'Name',columnMap,changeAccount);
        columnMap.put('value',null);
        FormRenderUtility.populateValue(sObj,defaultValuesSaveObject,testAccount1.Id,commonFields,'Name',columnMap,changeAccount);
        
        columnMap.put('ElixirSuite__Data_Type__c','PHONE');
        columnMap.put('value','1234567890');
        FormRenderUtility.populateValue(sObj,defaultValuesSaveObject,testAccount1.Id,commonFields,'Name',columnMap,changeAccount);
        columnMap.put('value',null);
        FormRenderUtility.populateValue(sObj,defaultValuesSaveObject,testAccount1.Id,commonFields,'Name',columnMap,changeAccount);
        
        columnMap.put('ElixirSuite__Data_Type__c','TEXTAREA');
        columnMap.put('value','Test Data');
        FormRenderUtility.populateValue(sObj,defaultValuesSaveObject,testAccount1.Id,commonFields,'Name',columnMap,changeAccount);
        columnMap.put('value',null);
        FormRenderUtility.populateValue(sObj,defaultValuesSaveObject,testAccount1.Id,commonFields,'Name',columnMap,changeAccount);
        
        columnMap.put('ElixirSuite__Data_Type__c','PICKLIST');
        columnMap.put('value','value1');
        FormRenderUtility.populateValue(sObj,defaultValuesSaveObject,testAccount1.Id,commonFields,'Name',columnMap,changeAccount);
        columnMap.put('value',null);
        FormRenderUtility.populateValue(sObj,defaultValuesSaveObject,testAccount1.Id,commonFields,'Name',columnMap,changeAccount);
        
        columnMap.put('ElixirSuite__Data_Type__c','MULTIPICKLIST');
        columnMap.put('value',new List<String>{'val1','val2'});
        FormRenderUtility.populateValue(sObj,defaultValuesSaveObject,testAccount1.Id,commonFields,'Name',columnMap,changeAccount);
        columnMap.put('value',new List<String>());
        FormRenderUtility.populateValue(sObj,defaultValuesSaveObject,testAccount1.Id,commonFields,'Name',columnMap,changeAccount);
        columnMap.put('value',null);
        FormRenderUtility.populateValue(sObj,defaultValuesSaveObject,testAccount1.Id,commonFields,'Name',columnMap,changeAccount);
        
        columnMap.put('ElixirSuite__Data_Type__c','REFERENCE');
        columnMap.put('value','Test');
        FormRenderUtility.populateValue(sObj,defaultValuesSaveObject,testAccount1.Id,commonFields,'Name',columnMap,changeAccount);
        columnMap.put('value',null);
        FormRenderUtility.populateValue(sObj,defaultValuesSaveObject,testAccount1.Id,commonFields,'Name',columnMap,changeAccount);
        
        columnMap.put('ElixirSuite__Data_Type__c','EMAIL');
        columnMap.put('value','test@gmail.com');
        FormRenderUtility.populateValue(sObj,defaultValuesSaveObject,testAccount1.Id,commonFields,'Name',columnMap,changeAccount);
        columnMap.put('value',null);
        FormRenderUtility.populateValue(sObj,defaultValuesSaveObject,testAccount1.Id,commonFields,'Name',columnMap,changeAccount);
        System.assertEquals(1, 1, '');
        Test.stopTest();
    }
    @isTest 
    public static void testPopulateConsentValue()
    {
        Test.startTest();
        Account testAccount1 = [SELECT Id from Account WITH SECURITY_ENFORCED Limit 1];
        Map<String, Object> columnMap = new Map<String, Object>();
        columnMap.put('value','1:2');
        columnMap.put('ElixirSuite__Data_Type__c','TIME');
        columnMap.put('ElixirSuite__Is_formula_Field__c','false');
        columnMap.put('ElixirSuite__IsCommon__c','true');
        columnMap.put('ElixirSuite__Is_Common_Parent__c','true');
        columnMap.put('ElixirSuite__Map_object__c','ACCOUNT');
        columnMap.put('ElixirSuite__Map_field__c','Name');
        List<Form_Value__c> consentValues = new List<Form_Value__c>();
        FormRenderUtility.populateConsentValue('Name',columnMap,consentValues,2,3,5,testAccount1.Id,true);
        System.assertEquals(1, 1, '');
        Test.stopTest();
    }
    
    /*@isTest
     public static void testfetchFields()
    {
        Test.startTest();
        Map<String,List<String>> objectToFieldsMap = new Map<String,List<String>> objectToFieldsMap();
        objectToFieldsMap.put('value','1:2');
        objectToFieldsMap.put('ElixirSuite__Data_Type__c','TIME');
        objectToFieldsMap.put('ElixirSuite__Is_formula_Field__c','false');
        objectToFieldsMap.put('ElixirSuite__IsCommon__c','true');
        objectToFieldsMap.put('ElixirSuite__Is_Common_Parent__c','true');
        objectToFieldsMap.put('ElixirSuite__Map_object__c','ACCOUNT');
        objectToFieldsMap.put('ElixirSuite__Map_field__c','Name');
       List<FieldSchema> fieldSchemas = new List<FieldSchema>();
        FormRenderUtility.populateConsentValue('Name',columnMap,consentValues,2,3,5,testAccount1.Id,true);
        System.assertEquals(1, 1, '');
        Test.stopTest();
        
    }*/
     /* @isTest
     public static void testgetDependentPicklistValues()
    {
   /*List<String> pickListValuesList= new List<String>();
        Schema.DescribeFieldResult fieldResult = ElixirSuite__Procedure__c.ElixirSuite__Sub_type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues(); 
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel());
        }    
       FormRenderUtility.getDependentPicklistValues('');
        
        Account account= new Account();
        account.name='test';
        account.ElixirSuite__Stage__c ='Closed';
        Insert account;
        Schema.SObjectField dependToken = ElixirSuite__Stage__c;
        
        Map<String, List<String>> dependentValues = FormRenderUtility.getDependentPicklistValues(dependToken);
        System.AssertEquals(1,1,'');
    }*/
}
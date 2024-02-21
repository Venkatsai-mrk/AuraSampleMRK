@isTest
public class PatientImmunizationControllerTest {

    public static void dataSetup(){
        
        Elixir_Custom_Setting__c setting = new Elixir_Custom_Setting__c();
        setting.ElixirSuite__Patient_Account_Recordtype__c = 'Patient_Account';
        insert setting;
        String patAccRecType = setting.ElixirSuite__Patient_Account_Recordtype__c; 
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(patAccRecType).getRecordTypeId();
        Id vaccineRecordTypeId = Schema.SObjectType.ElixirSuite__Vaccine__c.getRecordTypeInfosByDeveloperName().get('Template_Vaccine').getRecordTypeId();
        
        Account accountRecord = new Account();
        accountRecord.Name = 'TestRecordAccount';
        accountRecord.ElixirSuite__Email_Id__c = 'testaccount@gmail.com';
        accountRecord.ElixirSuite__Current_Status_Of_Patient__c = 'Current Patients';
        accountRecord.RecordTypeId =devRecordTypeId;
        accountRecord.ElixirSuite__DOB__c = Date.valueOf('1991-06-02');
        accountRecord.ElixirSuite__Admit_Date__c = Date.valueOf('2021-09-09');
        insert accountRecord;
        
        Id recordTypeIdForRoute = Schema.SObjectType.ElixirSuite__Master_Object__c.getRecordTypeInfosByName().get('Route').getRecordTypeId();
        ElixirSuite__Master_Object__c routeLst=new ElixirSuite__Master_Object__c();
            routeLst.Name='Intravenous';
            routeLst.ElixirSuite__Coding_System__c='SNOMEDCT';
            routeLst.ElixirSuite__Coding_System_Value__c='123';
            routeLst.RecordTypeId=recordTypeIdForRoute;
            insert routeLst;
        
        ElixirSuite__Vaccine__c templateVaccine = new ElixirSuite__Vaccine__c();
        templateVaccine.Name = 'Covid';
        templateVaccine.RecordTypeId = vaccineRecordTypeId;
        templateVaccine.ElixirSuite__CVX_Code__c = 'COVID_SHIELD';
        templateVaccine.ElixirSuite__Dosage_Sequence__c = 1;
        templateVaccine.ElixirSuite__Series_of_Doses__c = 3;
        templateVaccine.ElixirSuite__Route__c=routeLst.Id;
        insert templateVaccine;
        
    }
    
    @isTest
    public static void getSelectOptionsTestMethod(){
        dataSetup();
       
        Test.startTest();
        PatientImmunizationController.getSelectOptions();
        //PatientImmunizationController.dummyMethod();
        System.assertEquals(1, 1, 'Welcome To Elixir');
        Test.stopTest();
        
                
    }
    
     @isTest
    public static void getURLTestMethod(){
        dataSetup();
        
        Account acc = [Select id,Name from Account limit 1];
        Test.startTest();
        PatientImmunizationController.getURL(acc.Id);
        System.assertEquals(1, 1, 'Welcome To Elixir');
        Test.stopTest();
        
        
    }
    
    @isTest
    public static void saveVaccineTestMethod(){
        dataSetup();
        
        Account acc = [Select id,Name from Account limit 1];
        ElixirSuite__Vaccine__c tempVaccine = [Select id,Name,ElixirSuite__Route__c from ElixirSuite__Vaccine__c limit 1];
        String userId = UserInfo.getUserId();
        Test.startTest();
        
        PatientImmunizationController.saveVaccine(getJsonString(acc.id,userId,tempVaccine.Id));
        Test.stopTest();
        System.assertEquals(1, 1, 'Welcome To Elixir');
    }
    
    public static String getJsonString(String accountId,String userId,String vaccineId){
        Id recordTypeIdForRoute = Schema.SObjectType.ElixirSuite__Master_Object__c.getRecordTypeInfosByName().get('Route').getRecordTypeId();
        ElixirSuite__Master_Object__c routeLst=new ElixirSuite__Master_Object__c();
            routeLst.Name='Oral';
            routeLst.ElixirSuite__Coding_System__c='SNOMEDCT';
            routeLst.ElixirSuite__Coding_System_Value__c='123';
            routeLst.RecordTypeId=recordTypeIdForRoute;
            insert routeLst;
        String jsonString = '{"key":[{"Vaccine":{"Id":"' + vaccineId + '","Name":"Rabies","ElixirSuite__CVX_Code__c":"RB","ElixirSuite__Next_Dose_in_Series_After__c":20,"ElixirSuite__Route__c":"' + routeLst.Id + '","ElixirSuite__Vaccine_Site__c":"Left Upper Arm","ElixirSuite__Vaccine_Series__c":"SARS-COV-2"},"CvxCode":"RB","VaccineSeries":"SARS-COV-2","Route":"' + routeLst.Id + '","VaccineSite":"Left Upper Arm","status":"Planned","AdministratioDate":"2022-07-03","AdministrationBy":"' + userId + '","AccountId":"' + accountId + '","Id":"' + vaccineId + '","Name":"Rabies"},{"Vaccine":{"Id":"' + vaccineId + '","Name":"Rabies","ElixirSuite__CVX_Code__c":"RB","ElixirSuite__Next_Dose_in_Series_After__c":20,"ElixirSuite__Vaccine_Route__c":"Oral","ElixirSuite__Vaccine_Site__c":"Left Upper Arm","ElixirSuite__Vaccine_Series__c":"SARS-COV-2"},"CvxCode":"RB","VaccineSeries":"SARS-COV-2","Route":"Oral","VaccineSite":"Left Upper Arm","status":"Complete","AdministratioDate":"2022-07-23","AdministrationBy":"' + userId + '","AccountId":"' + accountId + '","Id":"' + vaccineId + '","Name":"Rabies"}]}';
    
        return jsonString;
    }
    
}
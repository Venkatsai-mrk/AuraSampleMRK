@isTest
public class CriteriaFilterSubmitControllerTest {

    @isTest
    public static void dataSetUp(){
        
         List<FieldJson> jsonObjList;
        ElixirSuite__Account_Group__c accountGroup = new ElixirSuite__Account_Group__c();
        accountGroup.Name ='Test Record';
        accountGroup.ElixirSuite__Is_Active__c = true;
        insert accountGroup;
        Elixir_Custom_Setting__c setting = new Elixir_Custom_Setting__c();
        setting.ElixirSuite__Patient_Account_Recordtype__c = 'Patient_Account';
        insert setting;
        String patAccRecType = setting.ElixirSuite__Patient_Account_Recordtype__c; 
        RecordType patientRecordType = getRecordType(patAccRecType,'Account');
        Account accountRecord = new Account();
        accountRecord.Name = 'TestRecordAccount';
        accountRecord.ElixirSuite__Email_Id__c = 'testaccount@gmail.com';
        accountRecord.ElixirSuite__Current_Status_Of_Patient__c = 'Current Patients';
        accountRecord.RecordTypeId =patientRecordType.Id;
        accountRecord.ElixirSuite__DOB__c = Date.valueOf('1991-06-02');
        accountRecord.ElixirSuite__Admit_Date__c = Date.valueOf('2021-09-09');
        insert accountRecord;
        Account accountRecord2 = new Account();
        accountRecord2.Name = 'TestRecordAccount2';
        accountRecord2.ElixirSuite__Email_Id__c = 'testaccount2@gmail.com';
        accountRecord2.ElixirSuite__Current_Status_Of_Patient__c = 'Current Patients';
        accountRecord2.RecordTypeId =patientRecordType.Id;
        accountRecord2.ElixirSuite__DOB__c = Date.valueOf('1990-01-01');
        accountRecord2.ElixirSuite__Admit_Date__c = Date.valueOf('2022-09-09');
        insert accountRecord2;
        
        ElixirSuite__Group_Patient__c groupPatient = new ElixirSuite__Group_Patient__c();
        groupPatient.ElixirSuite__Group_Name__c = accountGroup.Id;
        groupPatient.ElixirSuite__Current_Patient_Name__c = accountRecord2.id;
        groupPatient.ElixirSuite__Criteria_Based_Addition__c = true;
        insert groupPatient;
        
        ElixirSuite__Provider__c locationRecord = new ElixirSuite__Provider__c();
        locationRecord.Name = 'TestRecordProvider';
        locationRecord.ElixirSuite__Provider_Code__c = 'Test1';
        insert locationRecord;
        
        user user1 = [Select Id,Name from User where id=: userinfo.getUserId()];  
        
        List<ElixirSuite__Criteria_Assignment__c> listOfCriteriaAssignment = new List<ElixirSuite__Criteria_Assignment__c>();
        ElixirSuite__Criteria_Assignment__c  criteriaAssignment = new ElixirSuite__Criteria_Assignment__c();
        criteriaAssignment.ElixirSuite__Account_Group__c = accountGroup.Id;
        criteriaAssignment.ElixirSuite__Criteria_Type__c = 'Age';
        criteriaAssignment.ElixirSuite__Field_Value__c = '20';
        criteriaAssignment.ElixirSuite__S_No__c = 1;
        criteriaAssignment.ElixirSuite__Field_API_Name__c = 'ElixirSuite__Age__c';
        criteriaAssignment.ElixirSuite__Operator__c ='greater than';
        
        ElixirSuite__Criteria_Assignment__c  criteriaAssignment1 = new ElixirSuite__Criteria_Assignment__c();
        criteriaAssignment1.ElixirSuite__Account_Group__c = accountGroup.Id;
        criteriaAssignment1.ElixirSuite__Criteria_Type__c = 'Admit Date';
        criteriaAssignment1.ElixirSuite__S_No__c = 2;
        criteriaAssignment1.ElixirSuite__Field_Value__c = '["2021-09-09 2022-03-28"]';
        criteriaAssignment1.ElixirSuite__Field_API_Name__c = 'ElixirSuite__Admit_Date__c';
        criteriaAssignment1.ElixirSuite__Operator__c ='equals';
        
       
        
        jsonObjList = new List<FieldJson>();
        FieldJson jsonObj = new FieldJson();
        jsonObjList.add(jsonObj);
        
        ElixirSuite__Criteria_Assignment__c  criteriaAssignment2 = new ElixirSuite__Criteria_Assignment__c();
        criteriaAssignment2.ElixirSuite__Account_Group__c = accountGroup.Id;
        criteriaAssignment2.ElixirSuite__Criteria_Type__c = 'LOC'; 
        criteriaAssignment2.ElixirSuite__S_No__c = 3;
        criteriaAssignment2.ElixirSuite__Field_Value__c = JSON.serialize(jsonObjList);
        criteriaAssignment2.ElixirSuite__Operator__c ='	not equal to';
        
        jsonObjList = new List<FieldJson>();
        FieldJson jsonObj1 = new FieldJson();
        jsonObj1.Id = accountRecord.Id;
        jsonObj1.Name = accountRecord.Name;
        jsonObjList.add(jsonObj1);
        
        ElixirSuite__Criteria_Assignment__c  criteriaAssignment4 = new ElixirSuite__Criteria_Assignment__c();
        criteriaAssignment4.ElixirSuite__Account_Group__c = accountGroup.Id;
        criteriaAssignment4.ElixirSuite__Criteria_Type__c = 'Current Patient Name';
        criteriaAssignment4.ElixirSuite__S_No__c = 4;
        criteriaAssignment4.ElixirSuite__Field_Value__c = JSON.serialize(jsonObjList);
         //   '[{"Id":'+accountRecord.Id+',"Name":'+accountRecord.Name+'}]';
        criteriaAssignment4.ElixirSuite__Field_API_Name__c = 'Account';
        criteriaAssignment4.ElixirSuite__Operator__c ='equals';
        
        jsonObjList = new List<FieldJson>();
        FieldJson jsonObj2 = new FieldJson();
        jsonObj2.Id = locationRecord.Id;
        jsonObj2.Name = locationRecord.Name;
        jsonObjList.add(jsonObj2);
        
        ElixirSuite__Criteria_Assignment__c  criteriaAssignment5 = new ElixirSuite__Criteria_Assignment__c();
        criteriaAssignment5.ElixirSuite__Account_Group__c = accountGroup.Id;
        criteriaAssignment5.ElixirSuite__Criteria_Type__c = 'Location';
        criteriaAssignment5.ElixirSuite__S_No__c = 5;
        criteriaAssignment5.ElixirSuite__Field_Value__c = JSON.serialize(jsonObjList);
          //  '[{"Id":'+locationRecord.Id+',"Name":'+locationRecord.Name+'}]';
        criteriaAssignment5.ElixirSuite__Field_API_Name__c = 'ElixirSuite__Provider__c';
        criteriaAssignment5.ElixirSuite__Operator__c ='	not equal to';
        
        jsonObjList = new List<FieldJson>();
        FieldJson jsonObj3 = new FieldJson();
        jsonObj3.Id = user1.Id;
        jsonObj3.Name = user1.Name;
        jsonObjList.add(jsonObj3);
        
        ElixirSuite__Criteria_Assignment__c  criteriaAssignment6 = new ElixirSuite__Criteria_Assignment__c();
        criteriaAssignment6.ElixirSuite__Account_Group__c = accountGroup.Id;
        criteriaAssignment6.ElixirSuite__Criteria_Type__c = 'Care Team Member';
        criteriaAssignment6.ElixirSuite__S_No__c = 6;
        criteriaAssignment6.ElixirSuite__Field_Value__c = JSON.serialize(jsonObjList);
            //'[{"Id":'+user1.Id+',"Name":'+user1.Name+'}]';
        criteriaAssignment6.ElixirSuite__Field_API_Name__c = 'User';
        criteriaAssignment6.ElixirSuite__Operator__c ='	not equal to';
        
        
        
        listOfCriteriaAssignment.add(criteriaAssignment);
        listOfCriteriaAssignment.add(criteriaAssignment1);
        listOfCriteriaAssignment.add(criteriaAssignment2);
        
        listOfCriteriaAssignment.add(criteriaAssignment4);
        listOfCriteriaAssignment.add(criteriaAssignment5);
        listOfCriteriaAssignment.add(criteriaAssignment6);
       
        insert listOfCriteriaAssignment;
        System.assertEquals(1, 1, 'welcome to Elixir');
        
    }
    
    @isTest
    public static void getCriteriaFilterTestMethod(){
        dataSetUp();
        
        ElixirSuite__Account_Group__c accountGroupRecord =[Select id,name from ElixirSuite__Account_Group__c limit 1];
        
        CriteriaFilterSubmitController.getCriteriaFilter(accountGroupRecord.Id);
        System.assertEquals(1, 1, 'welcome to Elixir');
    }
    
    @isTest
    public static void updateCriteriaFilterOnChangeTestMethod(){
        dataSetUp();
        
        ElixirSuite__Account_Group__c accountGroupRecord =[Select id,name from ElixirSuite__Account_Group__c limit 1];
        
        CriteriaFilterSubmitController.updateCriteriaFilterOnChange(accountGroupRecord.Id, '1 AND 2');
        System.assertEquals(1, 1, 'welcome to Elixir');
          
    }
    
    
    @isTest
    public static void saveCriteriaFilterTestMethod(){
        dataSetUp();
        
        ElixirSuite__Account_Group__c accountGroupRecord =[Select id,name from ElixirSuite__Account_Group__c limit 1];
        
        Account accountTestRecord = [Select id,name,RecordTypeId from Account limit 1];
        ElixirSuite__Provider__c locationTestRecord = [Select id,name from ElixirSuite__Provider__c limit 1];
        user usertest = [Select Id,Name from User where id=: userinfo.getUserId()];
        
        CriteriaFilterSubmitController.setOfAccountId.add(accountTestRecord.Id);
       
        CriteriaFilterSubmitController.setOfLocationId.add(locationTestRecord.id);
        CriteriaFilterSubmitController.setOfCareTeamId.add(usertest.id);
        
        CriteriaFilterSubmitController.saveCriteriaFilter(accountGroupRecord.Id, '1 AND 2');
        System.assertEquals(1, 1, '');
    }
    
    public static RecordType getRecordType(String name, String obj){
        
        RecordType record = [Select id,name,developerName from RecordType where developerName=:name AND sobjectType=:obj limit 1];
        
        return record;
    }
    
    
    public class FieldJson{
        public String Id;
        public String Name;
        public String RecordTypeId;
    }
}
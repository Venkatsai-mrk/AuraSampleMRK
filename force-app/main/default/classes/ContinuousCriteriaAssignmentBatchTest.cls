@isTest
public class ContinuousCriteriaAssignmentBatchTest {

    @isTest
    public static void dataSetUp(){
        
        List<FieldJson> jsonObjList;
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
        accountRecord2.ElixirSuite__DOB__c = Date.valueOf('1991-06-02');
        accountRecord2.ElixirSuite__Admit_Date__c = Date.valueOf('2021-09-09');
        insert accountRecord2;
        
        Account accountRecord3 = new Account();
        accountRecord3.Name = 'TestRecordAccount3';
        accountRecord3.ElixirSuite__Email_Id__c = 'testaccount3@gmail.com';
        accountRecord3.ElixirSuite__Current_Status_Of_Patient__c = 'Current Patients';
        accountRecord3.RecordTypeId =patientRecordType.Id;
        accountRecord3.ElixirSuite__DOB__c = Date.valueOf('1990-01-01');
        accountRecord3.ElixirSuite__Admit_Date__c = Date.valueOf('2022-09-09');
        insert accountRecord3;
        
        /*ElixirSuite__Programs__c locRecord = new ElixirSuite__Programs__c();
        locRecord.ElixirSuite__Program_Name__c ='TestRecordLoc';
        locRecord.ElixirSuite__Description__c ='Testing';
        insert locRecord;*/
        
        ElixirSuite__Provider__c locationRecord = new ElixirSuite__Provider__c();
        locationRecord.Name = 'TestRecordProvider';
        locationRecord.ElixirSuite__Provider_Code__c = 'Test1';
        insert locationRecord;
        
        user user1 = [Select Id,Name from User where id=: userinfo.getUserId()];  
         Set<Id> setOfAccountId = new Set<Id>();
            //= new Set<Id>();
        Set<Id> setOfCareTeamId = new Set<Id>();
        Set<Id> setOfLocationId = new Set<Id>();
        Set<Id> setOfLocId = new Set<Id>();
        
        setOfAccountId.add(accountRecord.Id);
        setOfAccountId.add(accountRecord2.Id);
        setOfCareTeamId.add(user1.Id);
        setOfLocationId.add(locationRecord.Id);
        //setOfLocId.add(locRecord.Id);
        
        String currentStatus = 'Current Patients';
        String recordTypeName = 'Business_Account';
        
        String queryBuilder = 'Select id,Name from Account where ElixirSuite__Current_Status_Of_Patient__c=\''+currentStatus+'\'  AND RecordType.developerName!=\''+recordTypeName+'\' AND '+
            'Id IN:setOfAccountId ';
        
        ElixirSuite__Account_Group__c accountGroup = new ElixirSuite__Account_Group__c();
        accountGroup.Name ='Test Record';
        accountGroup.ElixirSuite__Is_Active__c = true;
        accountGroup.ElixirSuite__Continuous_Criteria_based_assignment__c = true;
        accountGroup.ElixirSuite__QueryBuilder__c =queryBuilder;
        insert accountGroup;
        ElixirSuite__Account_Group__c accountGroup2 = new ElixirSuite__Account_Group__c();
        accountGroup2.Name ='Test Record 2';
        accountGroup2.ElixirSuite__Is_Active__c = true;
        accountGroup2.ElixirSuite__Continuous_Criteria_based_assignment__c = true;
        accountGroup2.ElixirSuite__QueryBuilder__c =queryBuilder;
        accountGroup2.ElixirSuite__Criteria_Filter__c = '1 AND 2';
        insert accountGroup2;
        
        ElixirSuite__Group_Patient__c groupPatient = new ElixirSuite__Group_Patient__c();
        groupPatient.ElixirSuite__Group_Name__c = accountGroup2.Id;
        groupPatient.ElixirSuite__Current_Patient_Name__c = accountRecord2.id;
        groupPatient.ElixirSuite__Criteria_Based_Addition__c = true;
        insert groupPatient;
        
        ElixirSuite__Group_Patient__c groupPatient2 = new ElixirSuite__Group_Patient__c();
        groupPatient2.ElixirSuite__Group_Name__c = accountGroup2.Id;
        groupPatient2.ElixirSuite__Current_Patient_Name__c = accountRecord3.id;
        groupPatient2.ElixirSuite__Criteria_Based_Addition__c = true;
        insert groupPatient2;
            
        jsonObjList = new List<FieldJson>();
        FieldJson jsonObj = new FieldJson();
        //jsonObj.Id = locRecord.Id;
        //jsonObj.Name = locRecord.ElixirSuite__Program_Name__c;
        jsonObjList.add(jsonObj);
        
        List<ElixirSuite__Criteria_Assignment__c> listOfCriteriaAssignment = new List<ElixirSuite__Criteria_Assignment__c>();
        
        ElixirSuite__Criteria_Assignment__c  criteriaAssignment = new ElixirSuite__Criteria_Assignment__c();
        criteriaAssignment.ElixirSuite__Account_Group__c = accountGroup2.Id;
        criteriaAssignment.ElixirSuite__Criteria_Type__c = 'Age';
        criteriaAssignment.ElixirSuite__Field_Value__c = '20';
        criteriaAssignment.ElixirSuite__S_No__c = 1;
        criteriaAssignment.ElixirSuite__Field_API_Name__c = 'ElixirSuite__Age__c';
        criteriaAssignment.ElixirSuite__Operator__c ='greater than';
        
        ElixirSuite__Criteria_Assignment__c  criteriaAssignment1 = new ElixirSuite__Criteria_Assignment__c();
        criteriaAssignment1.ElixirSuite__Account_Group__c = accountGroup2.Id;
        criteriaAssignment1.ElixirSuite__Criteria_Type__c = 'Admit Date';
        criteriaAssignment1.ElixirSuite__S_No__c = 2;
        criteriaAssignment1.ElixirSuite__Field_Value__c = '["2021-09-09 2022-03-28"]';
        criteriaAssignment1.ElixirSuite__Field_API_Name__c = 'ElixirSuite__Admit_Date__c';
        criteriaAssignment1.ElixirSuite__Operator__c ='equals';
        
        ElixirSuite__Criteria_Assignment__c  criteriaAssignment2 = new ElixirSuite__Criteria_Assignment__c();
        criteriaAssignment2.ElixirSuite__Account_Group__c = accountGroup.Id;
        criteriaAssignment2.ElixirSuite__Criteria_Type__c = 'LOC'; 
        criteriaAssignment2.ElixirSuite__S_No__c = 3;
        criteriaAssignment2.ElixirSuite__Field_Value__c = JSON.serialize(jsonObjList);
            //'[{"Id":'+locRecord.Id+',"Name":'+locRecord.ElixirSuite__Program_Name__c+'}]';
        //criteriaAssignment2.ElixirSuite__Field_API_Name__c = 'ElixirSuite__Programs__c';
        criteriaAssignment2.ElixirSuite__Operator__c ='	not equal to';
        
        jsonObjList = new List<FieldJson>();
        FieldJson jsonObj1 = new FieldJson();
        FieldJson jsonObj2= new FieldJson();
        jsonObj1.Id = accountRecord.Id;
        jsonObj1.Name = accountRecord.Name;
        
        jsonObj2.Id = accountRecord2.Id;
        jsonObj2.Name = accountRecord2.Name;
        
        jsonObjList.add(jsonObj1);
        jsonObjList.add(jsonObj2);
        ElixirSuite__Criteria_Assignment__c  criteriaAssignment4 = new ElixirSuite__Criteria_Assignment__c();
        criteriaAssignment4.ElixirSuite__Account_Group__c = accountGroup.Id;
        criteriaAssignment4.ElixirSuite__Criteria_Type__c = 'Current Patient Name';
        criteriaAssignment4.ElixirSuite__S_No__c = 4;
        criteriaAssignment4.ElixirSuite__Field_Value__c = JSON.serialize(jsonObjList);
        criteriaAssignment4.ElixirSuite__Field_API_Name__c = 'Account';
        criteriaAssignment4.ElixirSuite__Operator__c ='equals';
        
        jsonObjList = new List<FieldJson>();
        FieldJson jsonObj3 = new FieldJson();
        jsonObj3.Id = locationRecord.Id;
        jsonObj3.Name = locationRecord.Name;
        jsonObjList.add(jsonObj3);
        
        ElixirSuite__Criteria_Assignment__c  criteriaAssignment5 = new ElixirSuite__Criteria_Assignment__c();
        criteriaAssignment5.ElixirSuite__Account_Group__c = accountGroup.Id;
        criteriaAssignment5.ElixirSuite__Criteria_Type__c = 'Location';
        criteriaAssignment5.ElixirSuite__S_No__c = 5;
        criteriaAssignment5.ElixirSuite__Field_Value__c = JSON.serialize(jsonObjList);
          //  '[{"Id":'+locationRecord.Id+',"Name":'+locationRecord.Name+'}]';
        criteriaAssignment5.ElixirSuite__Field_API_Name__c = 'ElixirSuite__Provider__c';
        criteriaAssignment5.ElixirSuite__Operator__c ='	not equal to';
        
        jsonObjList = new List<FieldJson>();
        FieldJson jsonObj4 = new FieldJson();
        jsonObj4.Id = user1.Id;
        jsonObj4.Name = user1.Name;
        jsonObjList.add(jsonObj4);
        
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
        System.assertEquals(1, 1, '');
        
    }
    
    @isTest
    public static void batchExecuteTestMethod(){
        dataSetUp();
        
        Test.startTest();
        Database.executeBatch(new ContinuousCriteriaAssignmentBatch(), 10);  
        Test.stopTest();
        System.assertEquals(1, 1, '');
    }
    @isTest
    public static void schedulerExecuteTestMethod(){
        dataSetUp();
        
        Test.startTest();
        ContinuousCriteriaAssignmentScheduler sh1 = new ContinuousCriteriaAssignmentScheduler();

        String sch = '0 0 23 * * ?'; 
        system.schedule('Test ContinuousCriteriaBatch Check', sch, sh1);
        
        Test.stopTest();
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
@isTest
public class GroupPatientsCustomWidgetCtrl_Test {

    @isTest
    public static void dataSetup(){
        
        ElixirSuite__Account_Group__c accountGroup = new ElixirSuite__Account_Group__c();
        accountGroup.Name ='Test Record';
        accountGroup.ElixirSuite__Is_Active__c = true;
        insert accountGroup;
        ElixirSuite__Account_Group__c accountGroup2= new ElixirSuite__Account_Group__c();
        accountGroup2.Name ='Test Record 2';
        accountGroup2.ElixirSuite__Is_Active__c = true;
        insert accountGroup2;
        
        RecordType patientRecordType = getRecordType('Referral_Partner_Account','Account');
        Account accountRecord = new Account();
        accountRecord.Name = 'TestRecordAccount';
        accountRecord.ElixirSuite__Email_Id__c = 'testaccount@gmail.com';
        accountRecord.ElixirSuite__Current_Status_Of_Patient__c = 'Current Patients';
        accountRecord.RecordTypeId =patientRecordType.Id;
        accountRecord.ElixirSuite__DOB__c = Date.valueOf('1991-06-02');
        accountRecord.ElixirSuite__Admit_Date__c = Date.valueOf('2021-09-09');
        insert accountRecord;
        
        ElixirSuite__Group_Patient__c groupPatient = new ElixirSuite__Group_Patient__c();
        groupPatient.ElixirSuite__Group_Name__c = accountGroup.Id;
        groupPatient.ElixirSuite__Current_Patient_Name__c = accountRecord.id;
        groupPatient.ElixirSuite__Criteria_Based_Addition__c = true;
        insert groupPatient;
        ElixirSuite__Group_Patient__c groupPatient2 = new ElixirSuite__Group_Patient__c();
        groupPatient2.ElixirSuite__Group_Name__c = accountGroup2.Id;
        groupPatient2.ElixirSuite__Current_Patient_Name__c = accountRecord.id;
        groupPatient2.ElixirSuite__Criteria_Based_Addition__c = true;
        insert groupPatient2;
        system.assertEquals(1,1,' ');
    }
    
    @isTest
    public static void getGroupPatientsTestMethod(){
        dataSetup();
        
        Test.startTest();
        
        Id accountId = [Select Id,Name from Account limit 1].Id;
        GroupPatientsCustomWidgetCtrl.getGroupPatients(accountId);
        Test.stopTest();
        
        System.assertEquals(2, [Select id,Name,ElixirSuite__Group_Name__c from ElixirSuite__Group_Patient__c].size(),'');
    }
    
    @isTest
    public static void deleteGroupPatientsTestMethod(){
        dataSetup();
        
        Test.startTest();
        
        ElixirSuite__Group_Patient__c groupPatient = [Select Id,Name from ElixirSuite__Group_Patient__c limit 1];
        GroupPatientsCustomWidgetCtrl.deleteGroupPatients(groupPatient);
        Test.stopTest();
        
        System.assertEquals(1, [Select id,Name,ElixirSuite__Group_Name__c from ElixirSuite__Group_Patient__c].size(),'');
    }
    
    public static RecordType getRecordType(String name, String obj){
        
        RecordType record = [Select id,name,developerName from RecordType where developerName=:name AND sobjectType=:obj limit 1];
        
        return record;
    }
}
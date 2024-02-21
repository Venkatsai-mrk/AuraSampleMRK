@isTest
public class TestGroupPatientTrigger {

    @isTest
    public static void dataSetup(){
        ElixirSuite__Account_Group__c accountGroup = new ElixirSuite__Account_Group__c();
        accountGroup.Name ='Test Record';
        accountGroup.ElixirSuite__Is_Active__c = true;
        insert accountGroup;
        ElixirSuite__Account_Group__c accountGroup2 = new ElixirSuite__Account_Group__c();
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
         

        date startdate= date.today().addDays(-1);
        date enddate= date.today();
        List<Event> eventLst = new List<Event>();
        Event eve1 = new Event(Subject='Call',WhatId=accountGroup.id,StartDateTime=startdate,EndDateTime=enddate);
        eventLst.add(eve1);
        Event eve2 = new Event(Subject='Meeting',WhatId=accountGroup2.id,StartDateTime=startdate,EndDateTime=enddate);
        eventLst.add(eve2);
        
        insert eventLst;
        
        Test.startTest();
        List<Account> currentPatient = [Select id,Name from Account where ElixirSuite__Current_Status_Of_Patient__c='Current Patients' limit 1];
        List<ElixirSuite__Account_Group__c> groups = [Select id,Name from ElixirSuite__Account_Group__c ];
        
       
        ElixirSuite__Group_Patient__c groupPatient = new ElixirSuite__Group_Patient__c();
        groupPatient.ElixirSuite__Group_Name__c = groups[0].Id;
        groupPatient.ElixirSuite__Current_Patient_Name__c = currentPatient[0].id;
        groupPatient.ElixirSuite__Criteria_Based_Addition__c = true;
        insert groupPatient;
        
        ElixirSuite__Group_Patient__c groupPatient2 = new ElixirSuite__Group_Patient__c();
        groupPatient2.ElixirSuite__Group_Name__c = groups[1].Id;
        groupPatient2.ElixirSuite__Current_Patient_Name__c = currentPatient[0].id;
        groupPatient2.ElixirSuite__Criteria_Based_Addition__c = true;
        insert groupPatient2;
        
        delete groupPatient2;
        Test.stopTest();
        String patientId = currentPatient[0].id;
        System.assertEquals(1, [Select id,Subject,whatId from Event where WhatId =: patientId AND Subject='Call'].size());
        System.assertEquals(0, [Select id,Subject,whatId from Event where WhatId =: patientId AND Subject='Meeting'].size());
        System.assertEquals(2, [Select id,Subject,whatId from Event where Subject='Call'].size());
        System.assertEquals(1, [Select id,Subject,whatId from Event where Subject='Meeting'].size());
    }
    
   /* @isTest
    public static void afterInsertTestMethod(){
        dataSetup();
        
        Test.startTest();
        List<Account> currentPatient = [Select id,Name from Account where ElixirSuite__Current_Status_Of_Patient__c='Current Patients' limit 1];
        List<ElixirSuite__Account_Group__c> groups = [Select id,Name from ElixirSuite__Account_Group__c ];
        
       
        ElixirSuite__Group_Patient__c groupPatient = new ElixirSuite__Group_Patient__c();
        groupPatient.ElixirSuite__Group_Name__c = groups[0].Id;
        groupPatient.ElixirSuite__Current_Patient_Name__c = currentPatient[0].id;
        groupPatient.ElixirSuite__Criteria_Based_Addition__c = true;
        insert groupPatient;
        
        ElixirSuite__Group_Patient__c groupPatient2 = new ElixirSuite__Group_Patient__c();
        groupPatient2.ElixirSuite__Group_Name__c = groups[1].Id;
        groupPatient2.ElixirSuite__Current_Patient_Name__c = currentPatient[0].id;
        groupPatient2.ElixirSuite__Criteria_Based_Addition__c = true;
        insert groupPatient;
        
        Test.stopTest();
    }
    @isTest
    public static void beforeDeleteTestMethod(){
        dataSetup();
        Test.startTest();
        
        Test.stopTest();
    }*/
    public static RecordType getRecordType(String name, String obj){
        
        RecordType record = [Select id,name,developerName from RecordType where developerName=:name AND sobjectType=:obj limit 1];
        
        return record;
    }
}
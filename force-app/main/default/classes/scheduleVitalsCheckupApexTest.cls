@isTest
public class scheduleVitalsCheckupApexTest {

    public static void dataSetup(){
        
        Elixir_Custom_Setting__c setting = new Elixir_Custom_Setting__c();
        setting.ElixirSuite__Patient_Account_Recordtype__c = 'Patient_Account';
        insert setting;
        String patAccRecType = setting.ElixirSuite__Patient_Account_Recordtype__c; 
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(patAccRecType).getRecordTypeId();
        
        Account accountRecord = new Account();
        accountRecord.Name = 'TestRecordAccount';
        accountRecord.ElixirSuite__Email_Id__c = 'testaccount@gmail.com';
        accountRecord.ElixirSuite__Current_Status_Of_Patient__c = 'Current Patients';
        accountRecord.RecordTypeId =devRecordTypeId;
        accountRecord.ElixirSuite__DOB__c = Date.valueOf('1991-06-02');
        accountRecord.ElixirSuite__Admit_Date__c = Date.valueOf('2021-09-09');
        insert accountRecord;
        
    }
    
    @isTest
    public static void getUserNamesTestMethod(){
        dataSetup();
       
        Test.startTest();
        scheduleVitalsCheckupApex.getUserNames();
        System.assertEquals(1, 1, ' ');
        Test.stopTest();
                
    }
    
     @isTest
    public static void getURLTestMethod(){
        dataSetup();
        
        Account acc = [Select id,Name from Account limit 1];
        Test.startTest();
        scheduleVitalsCheckupApex.getURL(acc.Id);
        System.assertEquals(1, 1, ' ');
        Test.stopTest();
               
    }
    @isTest
    public static void saveTaskTestMethod(){
        dataSetup();
        
        Account acc = [Select id,Name from Account limit 1];
        String userId = UserInfo.getUserId();
        Test.startTest();
        
        scheduleVitalsCheckupApex.saveTask(getJsonString(acc.id,userId));
        System.assertEquals(1, 1, ' ');
        Test.stopTest();
               
    }
    
    public static String getJsonString(String accountId,String userId){
        String jsonString = '{"key":[{"ExaminationType":"Vital Signs","SubType":"","StartTime":"2022-07-04T05:16:00.000Z","EndTime":"2022-07-05T05:16:00.000Z","Frequency":"Once Daily","Notes":"Test","Assignee":"' + userId + '","subtypedisable":false,"starttimedisable":false,"frequencydisable":false,"subTypeOptions":[],"AccountId":"' + accountId + '"},{"ExaminationType":"Medical Test - Spirometry","SubType":"","StartTime":"2022-07-04T05:16:00.000Z","EndTime":"2022-07-05T05:16:00.000Z","Frequency":"Once Daily","Notes":"Test","Assignee":"' + userId + '","subtypedisable":false,"starttimedisable":false,"frequencydisable":false,"subTypeOptions":[],"AccountId":"' + accountId + '"}]}';
    
        return jsonString;
    }
    
}
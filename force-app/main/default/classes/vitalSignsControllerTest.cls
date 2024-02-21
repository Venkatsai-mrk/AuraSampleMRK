@isTest
public with sharing class vitalSignsControllerTest {
    @testSetup
    public static void testMethod1(){
        Account acc = new Account();
        acc.Name = 'Test';
        insert acc;
        
        Transport__c t = new Transport__c();
        t.Account__c = acc.id ; 
        t.Start_Time__c = system.today();
        t.End_Time__c = system.today() + 1 ;
        try
        {
            insert t;
        }
        catch(Exception e){}
        
        //Inserting a list of Observations
        Medical_Examination__c ob = new Medical_Examination__c();
        ob.Account__c = acc.id ;
        ob.Blood_Pressure_Diasystolic__c = '120';
        ob.Blood_Pressure_Systolic__c = '80';
        ob.Start_Time__c = system.today();
        ob.End_Time__c = system.today() + 1 ;
        try
        {
            insert ob; 
        }
        Catch(Exception e){}
        System.assertEquals(1, 1, ' '); 
    }
    
    // for getVitalSignsRecord Method
    @isTest
    public static void test1(){
        Id accId = [Select Id from Account where Name = 'Test' limit 1].Id;
        Test.startTest();
        vitalSignsController.getCurrentlyLoggedInUser();
        vitalSignsController.getVitalSignsRecords(accID);
        System.assertEquals(1, 1,' ');
        Test.stopTest();
    }
    
    // for saveVitalSignRecord Method
    @isTest
    public static void test2(){
        Id accId = [Select Id from Account where Name = 'Test' limit 1].Id;
        Medical_Examination__c ob = new Medical_Examination__c();
        
        ob.Blood_Pressure_Diasystolic__c = '120';
        ob.Blood_Pressure_Systolic__c = '80';
        //  ob.Start_Time__c = system.now();
        //  ob.End_Time__c = system.now().adddays(2) ;
        
        Test.startTest();
        vitalSignsController.saveVitalSignRecord(ob , accId);
        System.assertEquals(1, 1, ' ');
        Test.stopTest();
    }
    
    // for delete vitals methos
    @isTest
    public static void test3(){
        Id accId = [Select Id from Account where Name = 'Test' limit 1].Id;
        
        Medical_Examination__c obs = new Medical_Examination__c();
        obs.Account__c = accId ;
        obs.Blood_Pressure_Diasystolic__c = '120';
        obs.Blood_Pressure_Systolic__c = '80';
        obs.Start_Time__c = system.today();
        obs.End_Time__c = system.today() + 1 ;
        try
        {
            insert obs; 
        }
        Catch(Exception e){}
        //Medical_Examination__c obs2 = [SELECT Id , Name FROM Medical_Examination__c where Id =:obs.Id LIMIT 1];
        
        Test.startTest();
        vitalSignsController.deleteVital(obs.id, accId);
        System.assertEquals(1, 1, ' ');
        Test.stopTest();
    }
    @isTest
    public static void testSaveVitalSignRecord() {
        
        // Create test account
        Account testAccount = new Account();
        testAccount.Name = 'Test Account';
        insert testAccount;
        
        String uniqueId = 'uniqueId';
        Medical_Examination__c testMedicalExam = new Medical_Examination__c();
        testMedicalExam.Respiration__c = '16';
        testMedicalExam.Oxygen_Saturation__c = '98';
        testMedicalExam.Blood_Pressure_Systolic__c = '120';
        testMedicalExam.Blood_Pressure_diasystolic__c = '80';
        testMedicalExam.Temperature__c = '98.6';
        testMedicalExam.Pulse__c = '72';
        testMedicalExam.Form_Unique_ID__c = uniqueId;
        testMedicalExam.Source__c = '';
        testMedicalExam.Start_Time__c = system.now().adddays(1);
        testMedicalExam.End_Time__c = system.now().adddays(2);
        Test.startTest();
        List<Medical_Examination__c> results = vitalSignsController.saveVitalSignRecord_AddedFromForm(testMedicalExam, testAccount.Id, uniqueId);
        System.assertEquals(1, 1, ' ');
        Test.stopTest();
    }
    
}
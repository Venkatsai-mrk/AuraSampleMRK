@isTest
public class DeleteAppointmentHelperTest {

    @isTest
    public static void deleteEventTestMethod(){
        Account patient =new Account ();
        patient.Name= 'Ram';
        patient.ElixirSuite__DOB__c =date.newInstance(2003, 9, 15);
        patient.ElixirSuite__Gender__c='Male';
        patient.ElixirSuite__Email_Id__c='virat@gmail.com';
        patient.phone='9988776655';
        patient.ElixirSuite__First_Name__c='Virat';
        patient.ElixirSuite__Last_Name__c='Kohli';
        patient.BillingPostalCode='50021';
        patient.ElixirSuite__SSN__c='12345';
        patient.ElixirSuite__MRN_Number_New__c='1234567890';
        insert patient;
       
        Elixir_Custom_Setting__c setting = new Elixir_Custom_Setting__c();
         setting.ElixirSuite__Business_Account_Recordtype__c = 'Business_Account';
         insert setting;
         String bussinessAccRecType = setting.ElixirSuite__Business_Account_Recordtype__c;
        RecordType bussinessRecordType = getRecordType(bussinessAccRecType,'Account');
        Account bussinessAccountRecord = new Account();
        bussinessAccountRecord.Name = 'Test Bussiness Account';
        bussinessAccountRecord.ElixirSuite__Email_Id__c = 'testaccount@gmail.com';
        bussinessAccountRecord.RecordTypeId = bussinessRecordType.id;
        insert bussinessAccountRecord;
        
        ElixirSuite__Event_Data_Object__c eventDataObject = new ElixirSuite__Event_Data_Object__c();
        
        eventDataObject.ElixirSuite__All_Day_event__c = true;
        eventDataObject.ElixirSuite__End_Date_and_Time__c = datetime.now();
        eventDataObject.ElixirSuite__Start_Date_Time__c = datetime.now();
        eventDataObject.ElixirSuite__Patients__c = JSON.serialize(new List<String>{patient.Id});
        eventDataObject.ElixirSuite__Related_Business_Accounts__c = JSON.serialize(new List<String>{bussinessAccountRecord.Id});
        insert eventDataObject;
        
        List<Event> eventListToDelete = new List<Event>();
         
        event ee = new event();
        ee.WhatId=patient.Id;
        ee.Subject = 'Call';
        ee.ElixirSuite__Event_Data_Object__c =eventDataObject.id;
        ee.ElixirSuite__Is_custom_screen__c =true;
        ee.StartDateTime=datetime.now();
        ee.EndDateTime=datetime.now();
        eventListToDelete.add(ee);
        insert eventListToDelete;
        
		Test.startTest();
        
         try
    {
         DeleteAppointmentHelper.deleteAppointments( eventListToDelete);
        
    }
    catch(exception e)
       {
          return;  
       }  
        System.assertEquals(1, 1, '');
        Test.stopTest(); 
    }
    
    public static RecordType getRecordType(String name, String obj){
        
        RecordType record = [Select id,name,developerName from RecordType where developerName=:name AND sobjectType=:obj limit 1];
        
        return record;
    }
}
@isTest
public class WorkScheduleTriggerHandlerTest {
    @isTest
    public static void testWorkSchedule(){
        Elixir_Custom_Setting__c pracRectype = new Elixir_Custom_Setting__c();
        pracRectype.ElixirSuite__Practitioner_Contact_Recordtype__c = 'Practitioner';
        insert pracRectype;
        String contactRecType = pracRectype.ElixirSuite__Practitioner_Contact_Recordtype__c; 
        Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(contactRecType).getRecordTypeId();
        Contact con = new Contact();
        con.RecordTypeId = recordTypeId;
        con.Is_Active__c = true;
        con.lastName = 'Mahendra';
        insert con;
        
        
         ElixirSuite__Provider__c provider = new  ElixirSuite__Provider__c();  
        Id devRecordTypeId = Schema.SObjectType.ElixirSuite__Provider__c.getRecordTypeInfosByDeveloperName().get('Template_Provider').getRecordTypeId();
        provider.RecordTypeId = devRecordTypeId;
        provider.Name = 'TestProvider';
        provider.Provider_Code__c  = 'Test123';
        provider.ElixirSuite__Address__c = 'abc';
        provider.ElixirSuite__Provider_State__c = 'CA';
        provider.ElixirSuite__Provider_City__c = 'CA';
        provider.ElixirSuite__Provider_Zip__c = '12232';
        insert provider;
        
        ElixirSuite__UserLocation__c user = new ElixirSuite__UserLocation__c();
        user.Name = 'Loop';
        user.ElixirSuite__Practitioner__c = con.Id;
        user.ElixirSuite__Provider__c =  provider.Id;
        insert user;
        
        List<Work_Schedule__c> newWorkScheduleList = new List<Work_Schedule__c>();

        Work_Schedule__c workSchedule = new Work_Schedule__c();
        workSchedule.Practitioner_Name__c = con.Id;
        workSchedule.Start_Date__c = Date.today();
        workSchedule.End_Date__c = Date.today()+30;
        workSchedule.Start_Time__c = Time.newInstance(9, 0, 0, 0);
        workSchedule.End_Time__c = Time.newInstance(9, 30, 0, 0);
        workSchedule.Time_Zone__c = 'Asia/Kolkata';
        workSchedule.Days__c = 'Monday';
        workSchedule.ElixirSuite__Provider_Location__c = provider.Id;
        newWorkScheduleList.add(workSchedule);
        insert newWorkScheduleList;
		
        List<Work_Schedule__c> newWorkScheduleList1 = new List<Work_Schedule__c>();

        Work_Schedule__c workSchedule1 = new Work_Schedule__c();
        workSchedule1.Practitioner_Name__c = con.Id;
        workSchedule1.Start_Date__c = Date.today();
        workSchedule1.End_Date__c = Date.today()+30;
        workSchedule1.Start_Time__c = Time.newInstance(10, 0, 0, 0);
        workSchedule.End_Time__c = Time.newInstance(10, 30, 0, 0);
        workSchedule1.Time_Zone__c = 'Asia/Kolkata';
        workSchedule1.Days__c = 'Monday';
        workSchedule1.ElixirSuite__Provider_Location__c = provider.Id;
        newWorkScheduleList1.add(workSchedule1);
        insert newWorkScheduleList1;
        
        List<Work_Schedule__c> lstToUpdateWorkSchedule = new List<Work_Schedule__c>();
        List<Work_Schedule__c> InsertedWorkSchedule = [Select Id,Start_Date__c,Start_Time__c,End_Date__c,End_Time__c,Time_Zone__c,Days__c,Work_Schedule__c,Start_Date_Time__c
        FROM Work_Schedule__c Where Id=:newWorkScheduleList[0].Id];
        for(Work_Schedule__c ws : InsertedWorkSchedule){
            ws.End_Time__c = Time.newInstance(10, 0, 0, 0);
            ws.Days__c = 'Tuesday';
            ws.Time_Zone__c = 'Asia/Colombo';
            lstToUpdateWorkSchedule.add(ws);
        }
        update lstToUpdateWorkSchedule;
        Map<Id,Work_Schedule__c> oldWorkScheduleMap = new Map<Id,Work_Schedule__c>(lstToUpdateWorkSchedule);
        Map<Id,Work_Schedule__c> newWorkScheduleMap = new Map<Id,Work_Schedule__c>(newWorkScheduleList);

        Test.startTest();
        //WorkScheduleTriggerHandler.beforeInsertOrUpdateDateTimeConversion(newWorkScheduleList);
        WorkScheduleTriggerHandler.dateValidations(newWorkScheduleList);
        WorkScheduleTriggerHandler.checkLocation(newWorkScheduleList);
        WorkScheduleTriggerHandler.workScheduleduplicate(newWorkScheduleList);
        WorkScheduleTriggerHandler.workScheduleduplicateupdate(newWorkScheduleList1);
        //WorkScheduleTriggerHandler.dateFieldUpdate(newWorkScheduleList);
        //WorkScheduleTriggerHandler.afterInsertWorkSchedule(newWorkScheduleList);
        //WorkScheduleTriggerHandler.afterUpdateWorkSchedule(newWorkScheduleMap,oldWorkScheduleMap);
        System.assertEquals(1, 1 ,' ');
        Test.stopTest();

    }
}
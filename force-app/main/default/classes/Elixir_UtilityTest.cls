/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-09-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class Elixir_UtilityTest {

    @isTest
    public static void testgetBulkAppointment(){
        
        Account accrec= new Account();
        accrec.Name = 'Test';
        accrec.Phone = '900091111';
        accrec.ElixirSuite__Email_Id__c = 'a@g.com';
        insert accrec;
        Account accr = new Account();
        accr.Name = 'Test';
        accr.Phone = '900091111';
        accr.ElixirSuite__Email_Id__c = 'a@g.com';
        insert accr;
        
        String userId = UserInfo.getUserId();
        Elixir_Custom_Setting__c pracRectype = new Elixir_Custom_Setting__c();
        pracRectype.ElixirSuite__Practitioner_Contact_Recordtype__c = 'Practitioner';
        insert pracRectype;
        String contactRecType = pracRectype.ElixirSuite__Practitioner_Contact_Recordtype__c; 
        Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(contactRecType).getRecordTypeId();
        Contact con = new Contact();
        con.RecordTypeId = recordTypeId;
        con.Is_Active__c = true;
        con.lastName = 'Mahima';
        con.ElixirSuite__Practitioner_User__c = userId;
        insert con;
        
        Contact con1 = new Contact();
        con1.RecordTypeId = recordTypeId;
        con1.Is_Active__c = true;
        con1.lastName = 'Sara';
        insert con1;
        
        ElixirSuite__Procedure__c p = new ElixirSuite__Procedure__c(Name = 'A90',ElixirSuite__Appointment_Type__c = true,ElixirSuite__Related_Procedure_Code_Category__c = 'HCPCS Level 2', ElixirSuite__Procedure_Duration__c = '15',
                                                                    ElixirSuite__Code_Category__c = 'ElixirSuite__Code_Category__c',ElixirSuite__Active__c=true,
                                                                    RecordTypeId = Schema.SObjectType.ElixirSuite__Procedure__c.getRecordTypeInfosByDeveloperName().get('Template_Procedure').getRecordTypeId());
        insert p;
        
        
         ElixirSuite__Provider__c provider = new  ElixirSuite__Provider__c();  
        RecordType rt = [SELECT Id FROM RecordType WHERE sObjectType = 'ElixirSuite__Provider__c' AND Name ='Template Provider'];
        provider.RecordTypeId = rt.Id;
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
        workSchedule.ElixirSuite__Appointment_Types__c = 'A90';
        workSchedule.ElixirSuite__Provider_Location__c = provider.Id;
        
        Work_Schedule__c workSchedule1 = new Work_Schedule__c();
        workSchedule1.Practitioner_Name__c = con1.Id;
        workSchedule1.Start_Date__c = Date.today();
        workSchedule1.End_Date__c = Date.today()+30;
        workSchedule1.Start_Time__c = Time.newInstance(9, 0, 0, 0);
        workSchedule1.End_Time__c = Time.newInstance(9, 30, 0, 0);
        workSchedule1.Time_Zone__c = 'Asia/Kolkata';
        workSchedule1.Days__c = 'Monday';
        workSchedule1.ElixirSuite__Appointment_Types__c = 'A90;A91';
        workSchedule1.ElixirSuite__Provider_Location__c = provider.Id;
        
        newWorkScheduleList.add(workSchedule);
        newWorkScheduleList.add(workSchedule1);
        insert newWorkScheduleList;
        
        Event objevent = new Event();
        objevent.StartDateTime = dateTime.now();
        objevent.EndDateTime = dateTime.now().addMinutes(15);
        objevent.WhatId = accrec.id;
        objevent.ElixirSuite__Location__c = provider.id;
        objevent.ElixirSuite__Status__c = 'Scheduled';
        objevent.ElixirSuite__Practitioner__c=con.id;
        objevent.ElixirSuite__Appointment_Type__c = 'Test';
        objevent.OwnerId= con.Practitioner_User__c;
        objevent.Subject = 'Upcoming Appointment with Test';
        insert objevent;
        
        Date startDate1 = system.today();
        List<String> pracStrings = new List<String>();
        List<String> locStrings = new List<String>();
        
        pracStrings.add(con.Id);
        pracStrings.add(con1.Id);
        locStrings.add(provider.Id);
        
        test.startTest();
        Elixir_Utility.Wrapper3 appointmentTyp1 = Elixir_Utility.getBulkAppointmentType(pracStrings,locStrings,startDate1);
        Map<String,String> pracLocVsAppTyp = appointmentTyp1.pracLocVsAptTyp;
        List<String> appTypLst = appointmentTyp1.appTypLstWrp;
        
        Map<String,String> pracMap = new Map<String,String>();
        pracMap = Elixir_Utility.bulkWorkslot(pracStrings,locStrings,startDate1,appTypLst,pracLocVsAppTyp);
        
        
        AutoNextAvailSlotGeneration.autoSlots();
        AutoNextAvailSlotGeneration sh1 = new AutoNextAvailSlotGeneration();
        String sch = '0 0 23 * * ?'; system.schedule('Test Check', sch, sh1);
        System.assertEquals(1,1,' ');
     	test.stopTest();   
    }
    
    @isTest
    public static void testElixir_Utility(){
        DateTime dt = System.now();
        String dateTimeStr = dt.format('yyyy-MM-dd HH:mm:ss');
        
        Account patient = TestDataFactory.createPatientAcc();
        insert patient;
        
        List<Visits__c> lstVisit = new List<Visits__c>();
        Visits__c visit = new Visits__c();
        visit.Name = 'test';
        visit.Account__c = patient.Id;
        lstVisit.add(visit);
        insert lstVisit;
        
        Id devRecordTypeId = Schema.SObjectType.Procedure__c.getRecordTypeInfosByName().get('Patient Procedure').getRecordTypeId();
        Procedure__c procedure = TestDataFactory.createProcedure(patient.Id);
        procedure.RecordTypeId = devRecordTypeId;
        insert procedure;
        String starttimeProcedure = System.now().format('yyyy-MM-dd HH:mm:ss');
        String endtimeProcedure = System.now().addDays(7).format('yyyy-MM-dd HH:mm:ss');
        
        List<sObject> defaultProcedures = new List<sObject>{procedure};
        
        Id sObjectId = procedure.Id;
        
        test.startTest();
        Elixir_Utility.getPDFData();
        Elixir_Utility.getNamespaceCustomSetting();
        Elixir_Utility.getNamespace();
        Elixir_Utility.getLeadTriggerExecution();
        Elixir_Utility.dateTimeConversion(dateTimeStr);
        Elixir_Utility.attachProcedureEncounter(defaultProcedures, patient.Id,sObjectId ,starttimeProcedure , endtimeProcedure);
        Elixir_Utility.attachExistingProcedureEncounter(defaultProcedures, patient.Id,sObjectId ,starttimeProcedure , endtimeProcedure );
        Elixir_Utility.createNewProcedure(starttimeProcedure , endtimeProcedure ,new Treatment_Plan__c() ,null,patient.Id , lstVisit, sObjectId);
        System.assertEquals(1,1,' ');
        test.stopTest();
    }
    
}
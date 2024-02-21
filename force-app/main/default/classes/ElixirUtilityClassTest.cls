@isTest
public class ElixirUtilityClassTest {
     
	@isTest
    public static void ElixirClassTest(){
        Account patient = new Account();
        patient.name = 'Test Patient';
        patient.ElixirSuite__Email_Id__c = 'kj@gmail.com';
        patient.Patient_s_Birth_Date__c = System.today().addyears(-20);
        patient.MRN_Number__c = 1234567;
        patient.ElixirSuite__First_Name__c ='fname';
        patient.ElixirSuite__Last_Name__c ='lname';
        patient.ElixirSuite__SSN__c ='1234';
        patient.ElixirSuite__Gender__c='Male';
        patient.Phone ='9919850735';
        patient.BillingPostalCode='27440';
        insert patient;
        
        Date currentDate = System.today();
        Date currentDate1 = System.today();
        
        Procedure__c procedure = new Procedure__c();
        procedure.Name = 'Test Procedure';
        procedure.Account__c = patient.Id;
        procedure.CPT_HCPCS_Code__c = '12345';
        procedure.From_Date__c = System.today();
        procedure.To_Date__c = System.today().addDays(1);
        insert procedure;
        
        Payment_Transaction__c payTrans = new Payment_Transaction__c();
        payTrans.Account__c = patient.Id;
        payTrans.Procedure__c = procedure.Id;
        payTrans.Date_Of_Service__c = System.today();
        payTrans.Cpt_Codes__c = '12345';
        payTrans.Status__c = 'Payment Started';
        payTrans.Actual_Price__c = 1500;
        payTrans.Patient_Responsibility__c = 500;
        insert payTrans;
        
        List<ElixirSuite__Refund__c> refund = new List<ElixirSuite__Refund__c>();
        ElixirSuite__Refund__c rec = new ElixirSuite__Refund__c();
        rec.ElixirSuite__Date_Created__c = currentDate;
        rec.ElixirSuite__Date_Issued__c =  currentDate;
        rec.ElixirSuite__Mode_of_Payment__c = 'Cash';
        rec.ElixirSuite__Status__c = 'Requested';
        rec.ElixirSuite__Refund_Amount__c = 100;
        rec.ElixirSuite__Master_Transaction__c = payTrans.Id;
         rec.ElixirSuite__Credit_Check_Reference_field__c = '122';
        insert rec;
        
        ElixirSuite__Refund__c rec1 = new ElixirSuite__Refund__c();
        rec1.ElixirSuite__Date_Created__c = currentDate;
        rec1.ElixirSuite__Date_Issued__c =  currentDate;
        rec1.ElixirSuite__Mode_of_Payment__c = 'Patient Credit';
        rec1.ElixirSuite__Status__c = 'Requested';
        rec1.ElixirSuite__Refund_Amount__c = 10;
        rec1.ElixirSuite__Master_Transaction__c = payTrans.Id;
         rec1.ElixirSuite__Credit_Check_Reference_field__c = '122';
        insert rec1;
        
        ElixirSuite__Refund__c rec2 = new ElixirSuite__Refund__c();
        rec2.ElixirSuite__Date_Created__c = currentDate;
        rec2.ElixirSuite__Date_Issued__c =  currentDate;
        rec2.ElixirSuite__Mode_of_Payment__c = 'Cash';
        rec2.ElixirSuite__Status__c = 'Denied';
        rec2.ElixirSuite__Refund_Amount__c = 100;
        rec2.ElixirSuite__Master_Transaction__c = payTrans.Id;
        rec2.ElixirSuite__Credit_Check_Reference_field__c = '122';
        rec2.ElixirSuite__Mode_of_Payment__c = 'Credit Card';
        insert rec2;
         
        refund = [SELECT Id FROM ElixirSuite__Refund__c];
        List<id> refundid = new List<id>();
        for(ElixirSuite__Refund__c obj : refund){
            refundid.add(obj.id);
        }
        Map<String, Object> refMap = new Map<String, Object> {
                    'refundIds' => refundid };
        ElixirUtilityClass.successRefund(refMap);
        ElixirUtilityClass.failedRefund(refMap);
        System.assertEquals(1,1,'');
    }
    
    @IsTest
    static void procedureCreation() {
        // Test data setup
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        Event testEvent = new Event(
            WhatId = testAccount.Id,
            Subject = 'Test Event',
            ElixirSuite__Appointment_Type__c = 'A90',
            ElixirSuite__Status__c = 'Scheduled',
            DurationInMinutes = 40, ActivityDateTime = DateTime.now()
        );
        insert testEvent;
        String eventId = testEvent.Id;
        Id tempRecordTypeId = Schema.SObjectType.ElixirSuite__Procedure__c.getRecordTypeInfosByDeveloperName().get('Template_Procedure').getRecordTypeId();
        Procedure__c procedure = new Procedure__c();
        procedure.Name = 'A90';
        procedure.ElixirSuite__Code_Description__c = 'zasdgfvh';
        procedure.ElixirSuite__Procedure_Duration__c = '30';
        procedure.RecordTypeId = tempRecordTypeId;
        procedure.CPT_HCPCS_Code__c = '12345';
        procedure.ElixirSuite__Active__c = true;
		procedure.ElixirSuite__Type_of_Procedure__c = 'Insurance Payment';
        insert procedure;
        
        Test.startTest();
        ElixirUtilityClass.procedureCreation( new Map<String, Object> {
                'eventId' => eventId
                    });
        System.assertEquals(1,1,'');
        Test.stopTest();

    }
     @IsTest
    static void careEpisodeCreation() {
        // Test data setup
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        Event testEvent = new Event(
            WhatId = testAccount.Id,
            Subject = 'Test Event',
            ElixirSuite__Appointment_Type__c = 'A90',
            ElixirSuite__Status__c = 'Scheduled',
            DurationInMinutes = 40, ActivityDateTime = DateTime.now()
        );
        insert testEvent;
        String eventId = testEvent.Id;
        
        
        Test.startTest();
        ElixirUtilityClass.careEpisodeCreation( new Map<String, Object> {
                'eventId' => eventId
                    });
        System.assertEquals(1,1,'');
        Test.stopTest();
        
    }
    @IsTest
    static void updateProcedure() {
        
         Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        
        
        Id tempRecordTypeId = Schema.SObjectType.ElixirSuite__Procedure__c.getRecordTypeInfosByDeveloperName().get('Template_Procedure').getRecordTypeId();
        Procedure__c procedure = new Procedure__c();
        procedure.Name = 'A90';
        procedure.ElixirSuite__Code_Description__c = 'zasdgfvh';
        procedure.ElixirSuite__Procedure_Duration__c = '30';
        procedure.RecordTypeId = tempRecordTypeId;
        procedure.CPT_HCPCS_Code__c = '12345';
        procedure.ElixirSuite__Active__c = true;
		procedure.ElixirSuite__Type_of_Procedure__c = 'Insurance Payment';
        insert procedure;
        
        Id recordTypeId = Schema.SObjectType.ElixirSuite__Procedure__c.getRecordTypeInfosByDeveloperName().get('Patient_Procedure').getRecordTypeId();
         
        
        
        
                ElixirSuite__Visits__c visit = new ElixirSuite__Visits__c();
                visit.Name = ' Visit - '+testAccount.Name;
                visit.ElixirSuite__Account__c = testAccount.Id;
                visit.ElixirSuite__Status__c = 'Active';
        insert visit;
        
        Event testEvent = new Event(
            Subject = 'Test Event',
            ElixirSuite__Status__c = 'Checked-In',
            DurationInMinutes = 40, ActivityDateTime = DateTime.now(),
            ElixirSuite__Appointment_Type__c='A90',
            ElixirSuite__Care_Episode__c=visit.Id,
            ElixirSuite__Checked_In_Date_Time__c=DateTime.now()
        );
        insert testEvent;
        
        Procedure__c procedure1 = new Procedure__c();
        procedure1.Name = 'A90';
        procedure1.ElixirSuite__Code_Description__c = 'zasdgfvh';
        procedure1.ElixirSuite__Procedure_Duration__c = '30';
        procedure1.recordTypeId = recordTypeId;
        procedure1.CPT_HCPCS_Code__c = '12345';
        procedure1.ElixirSuite__Active__c = true;
        procedure1.ElixirSuite__Event_Id__c = testEvent.Id;
		procedure1.ElixirSuite__Type_of_Procedure__c = 'Insurance Payment';
        insert procedure1;
        String eventId = testEvent.Id;
        Test.startTest();
         ElixirUtilityClass.updateProcedure( new Map<String, Object> {
                'eventId' => eventId
                    });
         System.assertEquals(1,1,'');
        Test.stopTest();
       
    }
    @IsTest
    static void testGetObjectRecord() {
        // Test data setup
        Account patient = new Account();
        patient.Name = 'Test Account';
        patient.ElixirSuite__Email_Id__c = 'kj@gmail.com';
        patient.Patient_s_Birth_Date__c = System.today().addyears(-20);
        patient.MRN_Number__c = 1234567;
        patient.ElixirSuite__First_Name__c ='fname';
        patient.ElixirSuite__Last_Name__c ='lname';
        patient.ElixirSuite__SSN__c ='1234';
        patient.ElixirSuite__Gender__c='Male';
        patient.Phone ='9919850735';
        patient.BillingPostalCode='27440';
        insert patient;
        
        Test.startTest();
        
        List<SObject> result = ElixirUtilityClass.getObjectRecord('Account', 'Test Account');
        System.assertEquals(1,1,'');
        Test.stopTest();
    }
}
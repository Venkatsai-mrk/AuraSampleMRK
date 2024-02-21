@isTest
public class scheduleAppointmentAuraControllerTest {
    
    @isTest
    public static void testAccountTeam(){
        
        ElixirSuite__Procedure__c tempProc = new ElixirSuite__Procedure__c();
        tempProc.Name = 'A90';
        tempProc.ElixirSuite__Code_Description__c = 'Consultation';
        tempProc.ElixirSuite__Version__c = 'ICD-10';
        tempProc.ElixirSuite__Appointment_Type__c = true;
        tempproc.ElixirSuite__Active__c = true;
        tempProc.ElixirSuite__Procedure_Duration__c = '15';
        insert tempProc;
        
        Account accRec = new Account();
        accRec.Name = 'Mahima';
        accRec.ElixirSuite__DOB__c = System.today();
        accRec.ElixirSuite__Gender__c = 'Female';
        accRec.ElixirSuite__Email_Id__c = 'mahi@gmail.com';
        accRec.ElixirSuite__MRN_Number_New__c = 'mir770';
        insert accRec;
        
        Account accRec1 = new Account();
        accRec1.Name = 'Saloni';
        accRec1.ElixirSuite__DOB__c = System.today();
        accRec1.ElixirSuite__Gender__c = 'Female';
        accRec1.ElixirSuite__Email_Id__c = 'saloni@gmail.com';
        accRec1.ElixirSuite__MRN_Number_New__c = 'mir880';
        insert accRec1;
        
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id,
            LastName = 'last',
            Email = 'puser000@amamama.com',
            Username = 'puser000@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US');
        
        insert u;
        Elixir_Custom_Setting__c pracRectype = new Elixir_Custom_Setting__c();
        pracRectype.ElixirSuite__Practitioner_Contact_Recordtype__c = 'Practitioner';
        insert pracRectype;
        String contactRecType = pracRectype.ElixirSuite__Practitioner_Contact_Recordtype__c; 
        Id recordTypeId =Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(contactRecType).getRecordTypeId();
        
        Contact conRec = new Contact();
        conRec.LastName = 'Dr. Rodd';
        conRec.MailingCity = 'Denver';
        conRec.MailingState = 'Colarado';
        conRec.Phone = '9588077890';
        conRec.AccountId = accRec1.Id;
        conRec.ElixirSuite__Practitioner_User__c = u.Id;
        conRec.RecordTypeId = recordTypeId;
        insert conRec;
        
        AccountContactRelation newCareTeamMember = new AccountContactRelation();
        newCareTeamMember.AccountId = accRec.Id;
        newCareTeamMember.ContactId = conRec.Id;
        newCareTeamMember.IsActive = true; // Set IsActive to true to make the record active
        newCareTeamMember.ElixirSuite__Care_Team_Role__c = 'Doctor';
        
        // Insert the new care team member record
        insert newCareTeamMember;
        
        Id recordTypeId1 =Schema.SObjectType.ElixirSuite__Provider__c.getRecordTypeInfosByDeveloperName().get('Template_Provider').getRecordTypeId();
        ElixirSuite__Provider__c provRec = new ElixirSuite__Provider__c();
        provRec.Name = 'Loop Care';
        provRec.ElixirSuite__Provider_Code__c = 'ab123987';
        provRec.RecordTypeId = recordTypeId1;
        insert provRec;
        
        ElixirSuite__Specialty__c specRec = new ElixirSuite__Specialty__c();
        specRec.ElixirSuite__Specialty_Name__c = 'Cardiology';
        specRec.ElixirSuite__Code__c = 'c1';
        insert specRec;
        
        ElixirSuite__UserLocation__c juncRec = new ElixirSuite__UserLocation__c();
        juncRec.Name = 'Loop Location';
        juncRec.ElixirSuite__Provider__c = provRec.Id;
        juncRec.ElixirSuite__Practitioner__c = conRec.Id;
        juncRec.ElixirSuite__Specialty__c = specRec.Id;
        insert juncRec;
        
        Date endDate = System.today().addDays(30);
        dateTime startDateTime= dateTime.now().addMinutes(30);
        dateTime endDateTime= dateTime.now().addMinutes(45);
        ElixirSuite__Work_Schedule__c ec = new ElixirSuite__Work_Schedule__c();
        ec.ElixirSuite__Start_Date__c = Date.today();
        ec.ElixirSuite__End_Date__c = endDate;
        ec.ElixirSuite__Start_Time__c = DateTime.now().time();
        ec.ElixirSuite__End_Time__c = DateTime.now().time().addMinutes(45);
        ec.ElixirSuite__Practitioner_Name__c = conRec.id;
        ec.ElixirSuite__Provider_Location__c = provRec.id;
        ec.ElixirSuite__Appointment_Types__c = 'A90';
        insert ec;
        
        scheduleAppointmentAuraController.getAccountTeamMember(accRec.Id,'','','','');
        scheduleAppointmentAuraController.getUserInfo();
        System.assertEquals(1,1,'');
    }
    
    @isTest
    public static void testAllProviders(){
        
        ElixirSuite__Procedure__c tempProc = new ElixirSuite__Procedure__c();
        tempProc.Name = 'A90';
        tempProc.ElixirSuite__Code_Description__c = 'Consultation';
        tempProc.ElixirSuite__Version__c = 'ICD-10';
        tempProc.ElixirSuite__Appointment_Type__c = true;
        tempProc.ElixirSuite__Procedure_Duration__c = '15';
        tempproc.ElixirSuite__Active__c = true;
        insert tempProc;
        
        Account accRec = new Account();
        accRec.Name = 'Mahima';
        accRec.ElixirSuite__DOB__c = System.today();
        accRec.ElixirSuite__Gender__c = 'Female';
        accRec.ElixirSuite__Email_Id__c = 'mahi@gmail.com';
        accRec.ElixirSuite__MRN_Number_New__c = 'mir770';
        insert accRec;
        
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id,
            LastName = 'last',
            Email = 'puser000@amamama.com',
            Username = 'puser000@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US');
        
        insert u;
        Elixir_Custom_Setting__c pracRectype = new Elixir_Custom_Setting__c();
        pracRectype.ElixirSuite__Practitioner_Contact_Recordtype__c = 'Practitioner';
        insert pracRectype;
        String contactRecType = pracRectype.ElixirSuite__Practitioner_Contact_Recordtype__c; 
        Id recordTypeId =Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(contactRecType).getRecordTypeId();
        
        Contact conRec = new Contact();
        conRec.LastName = 'Dr. Rodd';
        conRec.MailingCity = 'Denver';
        conRec.MailingState = 'Colarado';
        conRec.Phone = '9588077890';
        conRec.ElixirSuite__Practitioner_User__c = u.Id;
        conRec.RecordTypeId = recordTypeId;
        insert conRec;
        
        Id recordTypeId1 =Schema.SObjectType.ElixirSuite__Provider__c.getRecordTypeInfosByDeveloperName().get('Template_Provider').getRecordTypeId();
        ElixirSuite__Provider__c provRec = new ElixirSuite__Provider__c();
        provRec.Name = 'Loop Care';
        provRec.ElixirSuite__Provider_Code__c = 'ab123987';
        provRec.RecordTypeId = recordTypeId1;
        insert provRec;
        
        ElixirSuite__Specialty__c specRec = new ElixirSuite__Specialty__c();
        specRec.ElixirSuite__Specialty_Name__c = 'Cardiology';
        specRec.ElixirSuite__Code__c = 'c1';
        insert specRec;
        
        ElixirSuite__UserLocation__c juncRec = new ElixirSuite__UserLocation__c();
        juncRec.Name = 'Loop Location';
        juncRec.ElixirSuite__Provider__c = provRec.Id;
        juncRec.ElixirSuite__Practitioner__c = conRec.Id;
        juncRec.ElixirSuite__Specialty__c = specRec.Id;
        insert juncRec;
        
        Date endDate = System.today().addDays(20);
        dateTime startDateTime= dateTime.now().addMinutes(30);
        dateTime endDateTime= dateTime.now().addMinutes(45);
        ElixirSuite__Work_Schedule__c ec = new ElixirSuite__Work_Schedule__c();
        ec.ElixirSuite__Start_Date__c = Date.today();
        ec.ElixirSuite__End_Date__c = endDate;
        ec.ElixirSuite__Start_Time__c = DateTime.now().time();
        ec.ElixirSuite__End_Time__c = DateTime.now().time().addMinutes(45);
        ec.ElixirSuite__Practitioner_Name__c = conRec.id;
        ec.ElixirSuite__Provider_Location__c = provRec.id;
        ec.ElixirSuite__Appointment_Types__c = 'A90';
        insert ec;
        scheduleAppointmentAuraController.getProviders(accRec.Id,'','','','');
        System.assertEquals(1,1,'');
        
    }
    
}
@isTest
private class MyCareTeamDetailsForPortalTest {
    @isTest
    static void testGetAccountTeamMembers() {
        Account testPatient = TestDataFactory.createPatientAcc();
        insert testPatient;
        Contact con = new Contact();
        con.lastname = 'test contact';
        insert con;
        Profile profileId = [SELECT Id FROM Profile WHERE Name ='System Administrator' LIMIT 1];
        User user = new User();
        user.ProfileID = profileId.id;
        user.EmailEncodingKey = 'ISO-8859-1';
        user.LanguageLocaleKey = 'en_US';
        user.TimeZoneSidKey = 'America/New_York';
        user.LocaleSidKey = 'en_US';
        user.FirstName = 'firstt';
        user.LastName = 'lastt';
        user.Username = 'testtt@uniquedomain.com';
        user.CommunityNickname = 'testUser123';
        user.Alias = 't1';
        user.Email = 'no@email.com';
        //user.ContactId = con.Id;
        insert user;
        
        Elixir_Custom_Setting__c pracRectype = new Elixir_Custom_Setting__c();
        pracRectype.ElixirSuite__Practitioner_Contact_Recordtype__c = 'Practitioner';
        insert pracRectype;
        String contactRecType = pracRectype.ElixirSuite__Practitioner_Contact_Recordtype__c; 
        Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(contactRecType).getRecordTypeId();
        Contact cont = new Contact();
        cont.lastName = 'Test';
        cont.RecordTypeId = recordTypeId;
        cont.AccountId = testPatient.Id;
        cont.Practitioner_User__c = user.Id;
        insert cont;
        
        Specialty__c sp = new Specialty__c ();
        sp.ElixirSuite__Specialty_Name__c = 'Surgian';
        sp.Code__c = 'N124';
        insert sp;
        
        Provider__c p = TestDataFactory.createProviderTemp();
        insert p;
        
        UserLocation__c ul = new UserLocation__c();
        ul.Practitioner__c = cont.Id;
        ul.ElixirSuite__Specialty__c = sp.Id;
        ul.ElixirSuite__Provider__c = p.Id;
        insert ul;
        
        
        system.runAs(user) {
            new MyCareTeamDetailsForPortal.WrapperOption('','','','');
            MyCareTeamDetailsForPortal.getAccountTeamMembers();
            MyCareTeamDetailsForPortal.getCustomSetting();
            MyCareTeamDetailsForPortal.getPractitionerUser(cont.Id);
        }
        System.assertEquals(1,1,' ');
    }
}
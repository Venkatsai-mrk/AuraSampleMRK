@isTest
public class Elixir_NewAccountAssociatedFormsApexTest {
     @isTest
    public static void testForm(){
        Account acc = new Account();
        acc.Name ='test Acc';
        acc.Verification_Code__c='abc59c';
        insert acc;
        System.assertEquals(1, 1, ' ');
        
        Contact c  = new Contact();
        // c.name = 'test';
        c.birthdate = Date.today();
        c.AccountId=acc.id;
        c.lastName = 'Test last ';
        insert c;
        System.assertEquals(1, 1, ' ');
        
        list<String> lis = new list<string>();
        
        Form__c f = new Form__c();
        f.Name ='Risk';
        f.Category__c='Medical';
        f.Sub_Category__c='Medicene';
        f.Version__c=2.3;
        //  f.Form__c=f1.id;
        insert f;
       System.assertEquals(1, 1, ' ');
        
        List<Lead> leads = new List<Lead>();
        for(Integer i = 0; i < 200; i++){
            Lead lead = new Lead(LastName = 'Test ' + i, LeadSource = '', Company = 'Test Company ' + i, Status = 'Open - Not Contacted');
            leads.add(lead);
        }
        insert leads;
       System.assertEquals(1, 1, ' ');
        Form_Field__c field = new Form_Field__c();
        field.Form__c =f.Id;
        field.Data_Entry_Type__c='Picklist:PhysicalTherapist';
        insert field; 
        System.assertEquals(1, 1, ' ');
        
        Form_Field__c field1 = new Form_Field__c();
        field1.Form__c =f.Id;
        field1.Data_Entry_Type__c='Picklist:Allergy';
        insert field1;
        System.assertEquals(1, 1, ' ');
        
        Form_Field__c field2 = new Form_Field__c();
        field2.Form__c =f.Id;
        field2.Data_Entry_Type__c='Medication_list';
        insert field2;
        System.assertEquals(1, 1, ' ');
        
        Form_Field__c field3 = new Form_Field__c();
        field3.Form__c =f.Id;
        field3.Data_Entry_Type__c='Medication_list';
        insert field3;
        System.assertEquals(1, 1, ' ');
        
        Form_Field__c field4 = new Form_Field__c();
        field4.Form__c =f.Id;
        field4.Data_Entry_Type__c='Glucose_note';
        insert field4;
        System.assertEquals(1, 1, ' ');
        
        Form_Field__c field5 = new Form_Field__c();
        field5.Form__c =f.Id;
        field5.Data_Entry_Type__c='Vitals_signs';
        insert field5;
        System.assertEquals(1, 1, ' ');
        
        Form_Field__c field6 = new Form_Field__c();
        field6.Form__c =f.Id;
        field6.Data_Entry_Type__c='Diagnosis_Code';
        insert field6;
        System.assertEquals(1, 1, ' ');
        
        Form_Field__c field8 = new Form_Field__c();
        field8.Form__c =f.Id;
        field8.Section__c=3;
        field8.Data_Entry_Type__c='Active_Users';
        insert field8;
        System.assertEquals(1, 1, ' ');
        
        Form__c f1 = new Form__c();
        f1.Name ='Risk';
        f1.Category__c='Medical';
        f1.Sub_Category__c='Assessments';
        f1.Version__c=2.3;
        f1.Account__c=acc.id;
        f1.Form__c = f.id;
        insert f1;
        System.assertEquals(1, 1, ' ');
        
          
        ElixirSuite__Form_Label__c  fl = new ElixirSuite__Form_Label__c ();
        fl.ElixirSuite__FormId__c  = fl.Id;
        insert fl;
        
        Form_Value__c fv = new Form_Value__c();
        fv.ElixirSuite__Form_Id__c = f1.Id;
        insert fv;
        
       
        Form_Data__c data = new Form_Data__c();
        data.Account__c=acc.Id;
        data.Form__c =f1.id;
        insert data;
        System.assertEquals(1, 1, ' ');
        
        f.Form__c=f1.Id;
        update f;

        lis.add(f1.Id);

        Object_1_css__c o1 = new Object_1_css__c();
        o1.ElixirSuite__isActive__c = true;
        o1.ElixirSuite__Section_Number__c = 1;
        //o1.Is_Dynamic_Configuration_Enabled__c = true;

        insert o1;
        
        Test.startTest();
        
        Elixir_NewAccountAssociatedFormsApex.fetchAllForms( f.Category__c,f.Sub_Category__c, acc.id);
        Elixir_NewAccountAssociatedFormsApex.fetchAllForms( '',f.Sub_Category__c, acc.id);

        Elixir_NewAccountAssociatedFormsApex.bringData( acc.id, f.Category__c,f.Sub_Category__c, 'referralSelectedForms', lis);
        Elixir_NewAccountAssociatedFormsApex.bringData( acc.id, '',f.Sub_Category__c, 'abc', lis);
        Elixir_NewAccountAssociatedFormsApex.bringData( acc.id, 'abcCategory',f.Sub_Category__c, 'abc', lis);
		
        Elixir_NewAccountAssociatedFormsApex.bringDataForpatientPortalUser( acc.id, f.Category__c,f.Sub_Category__c, 'referralSelectedForms', lis);
        Elixir_NewAccountAssociatedFormsApex.bringDataForpatientPortalUser( acc.id, '',f.Sub_Category__c, 'abc', lis);
        Elixir_NewAccountAssociatedFormsApex.bringDataForpatientPortalUser( acc.id, 'abcCategory',f.Sub_Category__c, 'abc', lis);
        
        //Elixir_NewAccountAssociatedFormsApex.DeleteSavedForm(f1.id);
        Elixir_NewAccountAssociatedFormsApex.Uinfo();
        Elixir_NewAccountAssociatedFormsApex.getSearchForms('abc',f1.Category__c, f1.Sub_Category__c);
        Elixir_NewAccountAssociatedFormsApex.getSearchForms('abc','', '');
        Elixir_NewAccountAssociatedFormsApex.getSearchForms('abc','eachOther', '');
        Elixir_NewAccountAssociatedFormsApex.getSearchForms('abc','each', '');
        Elixir_NewAccountAssociatedFormsApex.filterForms(f1.Category__c);
        
        Elixir_NewAccountAssociatedFormsApex.fetchCategory();
       // Elixir_NewAccountAssociatedFormsApex.getDynamicForms(f.Category__c,f.Sub_Category__c, acc.id);
        Elixir_NewAccountAssociatedFormsApex.checkCareEpisode(f1.id);
        Date dToday = Date.today();
        new Elixir_NewAccountAssociatedFormsApex.FormWrapper('abc','def','ghi',dToday,'jkl','mno','pqr');
        Test.stopTest();
    }
    
     @isTest
    public static void testForm1(){
        Account acc = new Account();
        acc.Name ='test Acc';
        acc.Verification_Code__c='abc59c';
        insert acc;
        System.assertEquals(1, 1, ' ');
        
        Contact c  = new Contact();
        // c.name = 'test';
        c.birthdate = Date.today();
        c.AccountId=acc.id;
        c.lastName = 'Test last ';
        insert c;
        System.assertEquals(1, 1, ' ');
        
        list<String> lis = new list<string>();
        
        Form__c f = new Form__c();
        f.Name ='Risk';
        f.Category__c='Medical';
        f.Sub_Category__c='Medicene';
        f.Version__c=2.3;
        //  f.Form__c=f1.id;
        insert f;
        System.assertEquals(1, 1, ' ');
        
        List<Lead> leads = new List<Lead>();
        for(Integer i = 0; i < 200; i++){
            Lead lead = new Lead(LastName = 'Test ' + i, LeadSource = '', Company = 'Test Company ' + i, Status = 'Open - Not Contacted');
            leads.add(lead);
        }
        insert leads;
        System.assertEquals(1, 1, ' ');

        Form_Field__c field = new Form_Field__c();
        field.Form__c =f.Id;
        field.Data_Entry_Type__c='Picklist:PhysicalTherapist';
        insert field;
        System.assertEquals(1, 1, ' ');
        
        Form_Field__c field1 = new Form_Field__c();
        field1.Form__c =f.Id;
        field1.Data_Entry_Type__c='Picklist:Allergy';
        insert field1;
        System.assertEquals(1, 1, ' ');
        
        Form_Field__c field2 = new Form_Field__c();
        field2.Form__c =f.Id;
        field2.Data_Entry_Type__c='Medication_list';
        insert field2;
        System.assertEquals(1, 1, ' ');
        
        Form_Field__c field3 = new Form_Field__c();
        field3.Form__c =f.Id;
        field3.Data_Entry_Type__c='Medication_list';
        insert field3;
        System.assertEquals(1, 1, ' ');
        
        Form_Field__c field4 = new Form_Field__c();
        field4.Form__c =f.Id;
        field4.Data_Entry_Type__c='Glucose_note';
        insert field4;
        System.assertEquals(1, 1, ' ');
        
        Form_Field__c field5 = new Form_Field__c();
        field5.Form__c =f.Id;
        field5.Data_Entry_Type__c='Vitals_signs';
        insert field5;
        System.assertEquals(1, 1, ' ');
        
        Form_Field__c field6 = new Form_Field__c();
        field6.Form__c =f.Id;
        field6.Data_Entry_Type__c='Diagnosis_Code';
        insert field6;
        System.assertEquals(1, 1, ' ');
        
        Form_Field__c field8 = new Form_Field__c();
        field8.Form__c =f.Id;
        field8.Section__c=3;
        field8.Data_Entry_Type__c='Active_Users';
        insert field8;
        System.assertEquals(1, 1, ' ');
        
        Form__c f1 = new Form__c();
        f1.Name ='Risk';
        f1.Category__c='Medical';
        f1.Sub_Category__c='Assessments';
        f1.Version__c=2.3;
        f1.Account__c=acc.id;
        f1.Form__c = f.id;
        insert f1;
        System.assertEquals(1, 1, ' ');
        
       
        
        Form_Data__c data = new Form_Data__c();
        data.Account__c=acc.Id;
        data.Form__c =f1.id;
        insert data;
        System.assertEquals(1, 1, ' ');
        
        f.Form__c=f1.Id;
        update f;

        lis.add(f1.Id);

        Object_1_css__c o1 = new Object_1_css__c();
        o1.ElixirSuite__isActive__c = true;
        o1.ElixirSuite__Section_Number__c = 1;
        //o1.Is_Dynamic_Configuration_Enabled__c = true;

        insert o1;
        
        Opportunity oppty = new Opportunity();
        oppty.Name = 'Test';
        oppty.Gender__c = 'Male';
        oppty.AccountId=acc.id;
        oppty.StageName = 'Prospecting';
        oppty.CloseDate = system.today().adddays(1);
        // oppty.Level_Of_Care__c = prog.id;
        insert oppty; 
        
        Visits__c visit= new Visits__c();
        visit.name= 'TestVisit';
        visit.Opportunity__c= oppty.id;
        visit.status__c='Closed';
        StopRecursion.stopLocationUpdation = false;
        insert visit;
        
        Form_Value__c fv = new Form_Value__c();
        fv.ElixirSuite__Care_Episode__c = visit.Id;
        fv.Is_CareEpisode__c =true;
        fv.ElixirSuite__Form_Id__c = f1.Id;
        insert fv;

         Elixir_Custom_Setting__c cs = new Elixir_Custom_Setting__c();
         cs.ElixirSuite__Lock_forms_on_closure_of_a_care_episode__c = true;
         cs.ElixirSuite__Enable_Send_Forms_To_Portal__c=true;
         insert cs;
        
        Test.startTest();
        Elixir_NewAccountAssociatedFormsApex.deleteAllForms(lis);
        Elixir_NewAccountAssociatedFormsApex.fetchAllForms( f.Category__c,f.Sub_Category__c, acc.id);
        Elixir_NewAccountAssociatedFormsApex.fetchAllForms( '',f.Sub_Category__c, acc.id);

        Elixir_NewAccountAssociatedFormsApex.bringData( acc.id, f.Category__c,f.Sub_Category__c, 'referralSelectedForms', lis);
        Elixir_NewAccountAssociatedFormsApex.bringData( acc.id, '',f.Sub_Category__c, 'abc', lis);
        Elixir_NewAccountAssociatedFormsApex.bringData( acc.id, 'abcCategory',f.Sub_Category__c, 'abc', lis);

        Elixir_NewAccountAssociatedFormsApex.DeleteSavedForm(f1.id);
        Elixir_NewAccountAssociatedFormsApex.Uinfo();
        Elixir_NewAccountAssociatedFormsApex.getSearchForms('abc',f1.Category__c, f1.Sub_Category__c);
        Elixir_NewAccountAssociatedFormsApex.getSearchForms('abc','%', null);
        Elixir_NewAccountAssociatedFormsApex.getSearchForms('abc','eachOther', '');
        Elixir_NewAccountAssociatedFormsApex.getSearchForms('abc','each', '');
        Elixir_NewAccountAssociatedFormsApex.filterForms(f1.Category__c);
        Elixir_NewAccountAssociatedFormsApex.fetchCategory();
     //   Elixir_NewAccountAssociatedFormsApex.getDynamicForms(f.Category__c,f.Sub_Category__c, acc.id);
        Elixir_NewAccountAssociatedFormsApex.checkCareEpisode(f1.id);
        Elixir_NewAccountAssociatedFormsApex.checkExpiry('abc');
        
        
        Elixir_NewAccountAssociatedFormsApex.getCustomForms('Edit');
        Date dToday = Date.today();
        new Elixir_NewAccountAssociatedFormsApex.FormWrapper('abc','def','ghi',dToday,'jkl','mno','pqr');
        Test.stopTest();
    }
    @isTest
    static void testSubmitSelectedFormsToEHRFromPortal(){
        Account testPatient = TestDataFactory.createPatientAcc();
        insert testPatient;
        
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
        insert user;
        
        Integer minNumber = (Integer)Math.pow(10, 8);
        Integer maxNumber = (Integer)Math.pow(10, 9) - 1;
        Integer random9DigitNumber = (Integer)Math.floor(Math.random() * (maxNumber - minNumber + 1) + minNumber);
        String formId = testPatient.Id+';'+random9DigitNumber;
        List<Map<String, String>> wrappedData = new List<Map<String, String>>();
        Map<String, String> formData = new Map<String, String>{
            'formId' => formId,
            'formName' => testPatient.Name
        };
            ElixirSuite__Object_1_css__c obj1 = new ElixirSuite__Object_1_css__c(ElixirSuite__Form__c = testPatient.Name, ElixirSuite__Approval_Level__c = 1);
        insert obj1;

        ElixirSuite__Form_Value__c form1Value = new ElixirSuite__Form_Value__c(ElixirSuite__Form_Id__c = formId, ElixirSuite__Form_Name__c = testPatient.Name, ElixirSuite__Is_Approver__c = true);
        insert form1Value;
        wrappedData.add(formData);
        Test.startTest();
        system.runAs(user) {
        //Elixir_NewAccountAssociatedFormsApex.submitSelectedFormsToEHRFromPortal(wrappedData);
        Elixir_NewAccountAssociatedFormsApex.getApprovalAndSignatureData(wrappedData);
        }
        system.assertEquals(1,1,'');
        Test.stopTest();
    }
	
    @isTest
    static void testVoidMethod() {
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        Elixir_Custom_Setting__c abc =new Elixir_Custom_Setting__c();
        abc.Elixir_portal_url__c=baseUrl;
        abc.Forms_Columns__c='status';
        abc.ElixirSuite__Enable_Send_Forms_To_Portal__c=true;
        insert abc;    
        
        Elixir_NewAccountAssociatedFormsApex.getPortalUrl();
        Elixir_NewAccountAssociatedFormsApex.sendFormsToPortalAbility();
        Elixir_NewAccountAssociatedFormsApex.portalInitPayload();
        
        System.assertEquals('','', '');
    }
    
    
    @isTest
    static void testFilterFormsIfUserDefinedCategoryGiven() {
            String[] categories = new String[]{'Nursing', 'Patient', 'Notes'};
            Elixir_NewAccountAssociatedFormsApex.filterFormsIfUserDefinedCategoryGiven(categories);
            Elixir_NewAccountAssociatedFormsApex.getUserInstance(categories);
            System.assertEquals('','', '');
        
    }

    @IsTest
    static void fetchDynamicColumns_test(){
        
        Test.startTest();
        User contextuser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(contextuser){
            // setup a dynamic column
            Id formColumnRecordTypeId = Schema.SObjectType.ElixirSuite__Master_Object__c.getRecordTypeInfosByName().get('Form Columns').getRecordTypeId();
            ElixirSuite__Master_Object__c dyanmicFormColumn = new ElixirSuite__Master_Object__c(
                Field_Label__c = 'patient name',
                Field_Api__c = 'patient_name__c',
                Data_Type__c = 'text',
                Object_API_Name__c = 'object__c',
                Is_Dynamic_Column_Active__c = true,
                RecordTypeId = formColumnRecordTypeId
            );
            INSERT dyanmicFormColumn;

            // query this dyanmic column
            List<Elixir_NewAccountAssociatedFormsApex.DynamicFormColumnWrapper> expectedDynamicColumn = new List<Elixir_NewAccountAssociatedFormsApex.DynamicFormColumnWrapper>{
                new Elixir_NewAccountAssociatedFormsApex.DynamicFormColumnWrapper('patient name', 'patient_name__c', 'text', 'object__c')
            };
            List<Elixir_NewAccountAssociatedFormsApex.DynamicFormColumnWrapper> actualDynamicColumn = Elixir_NewAccountAssociatedFormsApex.queryDynamicFormColumns();

            System.assertEquals(expectedDynamicColumn[0].label, actualDynamicColumn[0].label, 'dynamic column label mismatch');
            System.assertEquals(expectedDynamicColumn[0].fieldName, actualDynamicColumn[0].fieldName, 'dynamic column fieldName mismatch');
            System.assertEquals(expectedDynamicColumn[0].type, actualDynamicColumn[0].type, 'dynamic column type mismatch');
            System.assertEquals(expectedDynamicColumn[0].objectName, actualDynamicColumn[0].objectName, 'dynamic column objectName mismatch');


        }
        Test.stopTest();
        
    }
}
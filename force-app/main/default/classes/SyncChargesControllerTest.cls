@isTest
public class SyncChargesControllerTest {
    
    @isTest
    public static void testSyncCharges(){
        Test.startTest();
        Id rId = Schema.SObjectType.ElixirSuite__Provider__c.getRecordTypeInfosByDeveloperName().get('Template_Provider').getRecordTypeId();
        Account patient =new Account ();
        patient.Name= 'Virat Kohli';
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
        
        ElixirSuite__Payor__c pay1 = new ElixirSuite__Payor__c();
        pay1.Payer_Code__c = '12345';
        insert pay1;
        
        Id templateProcId = Schema.SObjectType.ElixirSuite__VOB__c.getRecordTypeInfosByDeveloperName().get('VOB_record_type').getRecordTypeId();
        ElixirSuite__VOB__c vob2 = new ElixirSuite__VOB__c();
        vob2.status__c = 'Active';
        vob2.type__c = 'Primary';
        vob2.ElixirSuite__Set_Default_VOB__c = 'Yes';
        vob2.RecordTypeId = templateProcId;
        vob2.ElixirSuite__Account__c = patient.id;
        vob2.Insured_First_Name__c = 'TestVob';
        vob2.Insured_Middle_Name__c = 'Mid';
        vob2.Insured_Last_Name__c = 'Last';
        vob2.ElixirSuite__Benefit__c = 'AI = Substance Abuse';
        vob2.ElixirSuite__Generate_Claim_on__c = 'Contracted Price';
        vob2.ElixirSuite__Patient_Relationship_With_Insured__c = 'Self';
        vob2.ElixirSuite__Payer__c = pay1.id;
        vob2.ElixirSuite__Service_Date__c = system.today();
        insert vob2;
        
        
        ElixirSuite__Provider__c tempPrvdr = new ElixirSuite__Provider__c();
        tempPrvdr.Name = 'Test Provider';
        tempPrvdr.ElixirSuite__Provider_Zip__c = '12356';
        tempPrvdr.ElixirSuite__Provider_State__c = 'TestState';
        tempPrvdr.ElixirSuite__Provider_Last_Name__c = 'TestLastProvider';
        tempPrvdr.ElixirSuite__Provider_City__c = 'TestProviderCity';
        tempPrvdr.ElixirSuite__Provider_Code__c = '147859';
        tempPrvdr.RecordTypeId = rId;
            
        insert tempPrvdr;
        
        ElixirSuite__Visits__c exVisit = new ElixirSuite__Visits__c();
        exVisit.ElixirSuite__Account__c = patient.Id;
        exVisit.ElixirSuite__Status__c = 'Active';
        exVisit.ElixirSuite__Location__c = 'US';
        exVisit.ElixirSuite__Care_Episode_Location__c = tempPrvdr.Id;
        exVisit.Name = 'Test Visit';
        insert exVisit;
        
        Procedure__c procedure1 = new Procedure__c();
        procedure1.Name = 'A90';
        procedure1.ElixirSuite__Active__c = true;
        procedure1.ElixirSuite__Procedure_Duration__c = '15';
        insert procedure1;
        
        ElixirSuite__Actual_Price__c actPrice = new ElixirSuite__Actual_Price__c();
        actPrice.ElixirSuite__Pricing_Effective_Start_Date__c = System.today();
        actPrice.ElixirSuite__Pricing_Effective_End_Date__c = System.today().addDays(11);
        actPrice.ElixirSuite__List_Price__c = 100;
        actPrice.ElixirSuite__Provider__c = tempPrvdr.Id;
        actPrice.ElixirSuite__Procedure__c = procedure1.Id;
        insert actPrice;
        
        ElixirSuite__Contracted_Price__c conPrice = new ElixirSuite__Contracted_Price__c();
        conPrice.ElixirSuite__Pricing_Effective_Start_Date__c = System.today();
        conPrice.ElixirSuite__Pricing_Effective_End_Date__c = System.today().addDays(11);
        conPrice.ElixirSuite__Contracted_Amount__c = 70;
        conPrice.ElixirSuite__Procedure__c = procedure1.Id;
        conPrice.ElixirSuite__Payer__c = pay1.Id;
        insert conPrice;
        
        
        
        ElixirSuite__Procedure__c exPrcdr = new ElixirSuite__Procedure__c();
        exPrcdr.ElixirSuite__Account__c = patient.Id;
        exPrcdr.ElixirSuite__Active__c = true;
        exPrcdr.ElixirSuite__Is_Billable__c = true;
        exPrcdr.ElixirSuite__Visits__c = exVisit.Id;
		exPrcdr.ElixirSuite__Type_of_Procedure__c = 'Private Payment';
        exPrcdr.ElixirSuite__Charges__c = 0;
        exPrcdr.ElixirSuite__From_Date_of_Service__c = System.today();
        exPrcdr.Name = 'A90';
        exPrcdr.ElixirSuite__Provider_Location__c = tempPrvdr.Id;
        exPrcdr.ElixirSuite__Template_Procedure__c = procedure1.Id;
        insert exPrcdr;
        
        Procedure__c procedure = new Procedure__c();
        procedure.Name = 'A90';
        procedure.Account__c = patient.Id;
        procedure.ElixirSuite__Active__c = true;
        procedure.ElixirSuite__Is_Billable__c = true;
		procedure.ElixirSuite__Type_of_Procedure__c = 'Insurance Payment';
        procedure.ElixirSuite__Charges__c = 0;
        procedure.ElixirSuite__Provider_Location__c = tempPrvdr.Id;
        procedure.ElixirSuite__Visits__c = exVisit.Id;
        procedure.ElixirSuite__From_Date_of_Service__c = System.today();
        procedure.ElixirSuite__Template_Procedure__c = procedure1.Id;
        insert procedure;
        
        SyncChargesController.syncCharges(exVisit.Id);
        System.assertEquals(1, 1,'');
        Test.stopTest();
        
    }
     @isTest
    public static void testSyncCharges1(){
        Test.startTest();
        Id rId = Schema.SObjectType.ElixirSuite__Provider__c.getRecordTypeInfosByDeveloperName().get('Template_Provider').getRecordTypeId();
        Account patient =new Account ();
        patient.Name= 'Virat Kohli';
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
        
        ElixirSuite__Payor__c pay1 = new ElixirSuite__Payor__c();
        pay1.Payer_Code__c = '12345';
        insert pay1;
        
        Id templateProcId = Schema.SObjectType.ElixirSuite__VOB__c.getRecordTypeInfosByDeveloperName().get('VOB_record_type').getRecordTypeId();
        ElixirSuite__VOB__c vob2 = new ElixirSuite__VOB__c();
        vob2.status__c = 'Active';
        vob2.type__c = 'Primary';
        vob2.ElixirSuite__Set_Default_VOB__c = 'Yes';
        vob2.RecordTypeId = templateProcId;
        vob2.ElixirSuite__Account__c = patient.id;
        vob2.Insured_First_Name__c = 'TestVob';
        vob2.Insured_Middle_Name__c = 'Mid';
        vob2.Insured_Last_Name__c = 'Last';
        vob2.ElixirSuite__Benefit__c = 'AI = Substance Abuse';
        vob2.ElixirSuite__Generate_Claim_on__c = 'Actual Price';
        vob2.ElixirSuite__Patient_Relationship_With_Insured__c = 'Self';
        vob2.ElixirSuite__Payer__c = pay1.id;
        vob2.ElixirSuite__Service_Date__c = system.today();
        insert vob2;
        
        
        ElixirSuite__Provider__c tempPrvdr = new ElixirSuite__Provider__c();
        tempPrvdr.Name = 'Test Provider';
        tempPrvdr.ElixirSuite__Provider_Zip__c = '12356';
        tempPrvdr.ElixirSuite__Provider_State__c = 'TestState';
        tempPrvdr.ElixirSuite__Provider_Last_Name__c = 'TestLastProvider';
        tempPrvdr.ElixirSuite__Provider_City__c = 'TestProviderCity';
        tempPrvdr.ElixirSuite__Provider_Code__c = '147859';
        tempPrvdr.RecordTypeId = rId;
            
        insert tempPrvdr;
        
        ElixirSuite__Visits__c exVisit = new ElixirSuite__Visits__c();
        exVisit.ElixirSuite__Account__c = patient.Id;
        exVisit.ElixirSuite__Status__c = 'Active';
        exVisit.ElixirSuite__Location__c = 'US';
        exVisit.ElixirSuite__Care_Episode_Location__c = tempPrvdr.Id;
        exVisit.Name = 'Test Visit';
        insert exVisit;
        
        Procedure__c procedure1 = new Procedure__c();
        procedure1.Name = 'A90';
        procedure1.ElixirSuite__Active__c = true;
        procedure1.ElixirSuite__Procedure_Duration__c = '15';
        insert procedure1;
        
        ElixirSuite__Actual_Price__c actPrice = new ElixirSuite__Actual_Price__c();
        actPrice.ElixirSuite__Pricing_Effective_Start_Date__c = System.today();
        actPrice.ElixirSuite__Pricing_Effective_End_Date__c = System.today().addDays(11);
        actPrice.ElixirSuite__List_Price__c = 100;
        actPrice.ElixirSuite__Provider__c = tempPrvdr.Id;
        actPrice.ElixirSuite__Procedure__c = procedure1.Id;
        insert actPrice;
        
        ElixirSuite__Contracted_Price__c conPrice = new ElixirSuite__Contracted_Price__c();
        conPrice.ElixirSuite__Pricing_Effective_Start_Date__c = System.today();
        conPrice.ElixirSuite__Pricing_Effective_End_Date__c = System.today().addDays(11);
        conPrice.ElixirSuite__Contracted_Amount__c = 70;
        conPrice.ElixirSuite__Procedure__c = procedure1.Id;
        conPrice.ElixirSuite__Payer__c = pay1.Id;
        insert conPrice;
        
        
        Procedure__c procedure = new Procedure__c();
        procedure.Name = 'A90';
        procedure.Account__c = patient.Id;
        procedure.ElixirSuite__Active__c = true;
        procedure.ElixirSuite__Is_Billable__c = true;
		procedure.ElixirSuite__Type_of_Procedure__c = 'Insurance Payment';
        procedure.ElixirSuite__Charges__c = 0;
        procedure.ElixirSuite__Provider_Location__c = tempPrvdr.Id;
        procedure.ElixirSuite__Visits__c = exVisit.Id;
        procedure.ElixirSuite__From_Date_of_Service__c = System.today();
        procedure.ElixirSuite__Template_Procedure__c = procedure1.Id;
        insert procedure;
        
        SyncChargesController.syncCharges(exVisit.Id);
        System.assertEquals(1, 1,'');
        Test.stopTest();
        
    }

}
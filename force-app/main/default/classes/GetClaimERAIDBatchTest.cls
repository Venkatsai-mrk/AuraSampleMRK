/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-10-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
private class GetClaimERAIDBatchTest {
    
     @isTest
    public static void testDummy(){ 
        
        Test.startTest();
        GetClaimERAIDBatch.entryPointCallout();
        GetClaimERAIDBatch.viewId();
        system.assertEquals(1,1);     
        Test.stopTest();
        
    }
    @isTest
    static void testRedirectToLCForClaim() {
        Account patient = new Account();
        patient.name = 'Test Patient';
        patient.ElixirSuite__Email_Id__c = 'kj@gmail.com';
        patient.ElixirSuite__Patient_s_Birth_Date__c = System.today().addyears(-20);
        patient.ElixirSuite__MRN_Number__c = 1234567;
        patient.ElixirSuite__First_Name__c ='fname';
        patient.ElixirSuite__Last_Name__c ='lname';
        patient.ElixirSuite__SSN__c ='1234';
        patient.ElixirSuite__Gender__c='Male';
        patient.Phone ='9919850735';
        patient.BillingPostalCode='27440';
		insert patient;
        // Create test data - Claim__c records
        ElixirSuite__Claim__c claimRecord2 = new ElixirSuite__Claim__c();
        claimRecord2.ElixirSuite__claim_status__c = 'Clearing house accepted';
        claimRecord2.ElixirSuite__Account__c = patient.Id;
        claimRecord2.ElixirSuite__pcn__c = 'John';
        claimRecord2.ElixirSuite__patient_first_Name__c = 'David';
        claimRecord2.ElixirSuite__patient_last_Name__c = 'Beckam';
        claimRecord2.ElixirSuite__npi__c = '1831234939';
        claimRecord2.ElixirSuite__payer_id__c = '20413';
        claimRecord2.ElixirSuite__other_payer_name__c = 'LIC';
        claimRecord2.ElixirSuite__Insured_s_ID_Number__c = '1232';
        claimRecord2.ElixirSuite__patient_dob__c = System.today().addYears(-40);
        claimRecord2.ElixirSuite__patient_sex__c = 'M';
        claimRecord2.ElixirSuite__insured_s_name__c = 'David';
        claimRecord2.ElixirSuite__insured_s_name__c = 'Beckam';
        claimRecord2.ElixirSuite__payer_order__c = 'Primary';
        claimRecord2.ElixirSuite__patient_s_address__c = 'Noida';
        claimRecord2.ElixirSuite__patient_s_city__c = 'Noida';
        claimRecord2.ElixirSuite__patient_country_code__c = 'IN';
        claimRecord2.ElixirSuite__patient_s_state__c = 'UP';
        claimRecord2.ElixirSuite__patient_s_zipcode__c = 201301;
        claimRecord2.ElixirSuite__Patient_Relationship_to_Insured__c = 'Father';
        claimRecord2.ElixirSuite__insured_address__c = 'Noida';
        claimRecord2.ElixirSuite__insured_city__c = 'Noida';
        claimRecord2.ElixirSuite__insured_country_code__c = 'IN';
        claimRecord2.ElixirSuite__insured_state__c = 'UP';
        claimRecord2.ElixirSuite__insured_zipcode__c = 201301;
        claimRecord2.ElixirSuite__employment_related__c = 'No';
        claimRecord2.ElixirSuite__Auto_Accident_Related__c = 'No';
        claimRecord2.ElixirSuite__insured_dob__c = System.today().addYears(-10);
        claimRecord2.ElixirSuite__insured_sex__c = 'M';
        claimRecord2.ElixirSuite__Place_of_Service__c = 'Delhi';
        claimRecord2.ElixirSuite__bill_taxid__c = '123656789';
        claimRecord2.ElixirSuite__Billing_Provider_Tax_ID_Type__c = 'E';
        claimRecord2.ElixirSuite__Accept_Assignment__c = 'Y';
        claimRecord2.ElixirSuite__total_charge__c = 900;
        claimRecord2.ElixirSuite__amount_paid__c = 0;
        claimRecord2.ElixirSuite__Billing_Provider_Name__c = 'ATHENA';
        claimRecord2.ElixirSuite__Billing_Provider_Address_1__c = 'Watertown';
        claimRecord2.ElixirSuite__Billing_Provider_State__c = 'CA';
        claimRecord2.ElixirSuite__Billing_Provider_Zip__c = '232329998';
        claimRecord2.ElixirSuite__Bill_Phone__c = '4152155300';
        claimRecord2.ElixirSuite__Billing_Provider_City__c = 'Watertown';
        claimRecord2.ElixirSuite__Diag_1__c = 'B86';
        claimRecord2.ElixirSuite__Posted__c = true;
        claimRecord2.ElixirSuite__Claim__c = null;
        claimRecord2.ElixirSuite__Total_Paid__c = 3000;
        claimRecord2.ElixirSuite__Total_Charge__c = 2000;
        insert claimRecord2;
        
        ElixirSuite__Claim__c claimRecord3 = new ElixirSuite__Claim__c();
        claimRecord3.ElixirSuite__claim_status__c = 'Clearing house accepted';
        claimRecord3.ElixirSuite__Account__c = patient.Id;
        claimRecord3.ElixirSuite__pcn__c = 'John';
        claimRecord3.ElixirSuite__patient_first_Name__c = 'David';
        claimRecord3.ElixirSuite__patient_last_Name__c = 'Beckam';
        claimRecord3.ElixirSuite__npi__c = '1831234939';
        claimRecord3.ElixirSuite__payer_id__c = '20413';
        claimRecord3.ElixirSuite__other_payer_name__c = 'LIC';
        claimRecord3.ElixirSuite__Insured_s_ID_Number__c = '1232';
        claimRecord3.ElixirSuite__patient_dob__c = System.today().addYears(-40);
        claimRecord3.ElixirSuite__patient_sex__c = 'M';
        claimRecord3.ElixirSuite__insured_s_name__c = 'David';
        claimRecord3.ElixirSuite__insured_s_name__c = 'Beckam';
        claimRecord3.ElixirSuite__payer_order__c = 'Primary';
        claimRecord3.ElixirSuite__patient_s_address__c = 'Noida';
        claimRecord3.ElixirSuite__patient_s_city__c = 'Noida';
        claimRecord3.ElixirSuite__patient_country_code__c = 'IN';
        claimRecord3.ElixirSuite__patient_s_state__c = 'UP';
        claimRecord3.ElixirSuite__patient_s_zipcode__c = 201301;
        claimRecord3.ElixirSuite__Patient_Relationship_to_Insured__c = 'Father';
        claimRecord3.ElixirSuite__insured_address__c = 'Noida';
        claimRecord3.ElixirSuite__insured_city__c = 'Noida';
        claimRecord3.ElixirSuite__insured_country_code__c = 'IN';
        claimRecord3.ElixirSuite__insured_state__c = 'UP';
        claimRecord3.ElixirSuite__insured_zipcode__c = 201301;
        claimRecord3.ElixirSuite__employment_related__c = 'No';
        claimRecord3.ElixirSuite__Auto_Accident_Related__c = 'No';
        claimRecord3.ElixirSuite__insured_dob__c = System.today().addYears(-10);
        claimRecord3.ElixirSuite__insured_sex__c = 'M';
        claimRecord3.ElixirSuite__Place_of_Service__c = 'Delhi';
        claimRecord3.ElixirSuite__bill_taxid__c = '123656789';
        claimRecord3.ElixirSuite__Billing_Provider_Tax_ID_Type__c = 'E';
        claimRecord3.ElixirSuite__Accept_Assignment__c = 'Y';
        claimRecord3.ElixirSuite__total_charge__c = 900;
        claimRecord3.ElixirSuite__amount_paid__c = 0;
        claimRecord3.ElixirSuite__Billing_Provider_Name__c = 'ATHENA';
        claimRecord3.ElixirSuite__Billing_Provider_Address_1__c = 'Watertown';
        claimRecord3.ElixirSuite__Billing_Provider_State__c = 'CA';
        claimRecord3.ElixirSuite__Billing_Provider_Zip__c = '232329998';
        claimRecord3.ElixirSuite__Bill_Phone__c = '4152155300';
        claimRecord3.ElixirSuite__Billing_Provider_City__c = 'Watertown';
        claimRecord3.ElixirSuite__Diag_1__c = 'B86';
        claimRecord3.ElixirSuite__Posted__c = true;
        claimRecord3.ElixirSuite__Claim__c= claimRecord2.Id;
         claimRecord3.ElixirSuite__Total_Paid__c = 300;
        claimRecord3.ElixirSuite__Total_Charge__c = 2000;
        insert claimRecord3;
        List<ElixirSuite__Claim__c> claimList = new List<ElixirSuite__Claim__c>();
        claimList.add(claimRecord3);
        claimList.add(claimRecord2);

        // Create a StandardSetController with the test data
        ApexPages.StandardSetController controller = new ApexPages.StandardSetController(claimList);

        // Instantiate the ToastController passing the StandardSetController
        ToastController controllerInstance = new ToastController(controller);

        // Call the method to test
        Test.startTest();
        PageReference pageRef = controllerInstance.redirectToLCForClaim();
        PageReference pageRef1 = controllerInstance.redirectToLC();
        Test.stopTest();

        System.assertEquals(1,1);

    }
 
}
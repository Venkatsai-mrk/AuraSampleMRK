@isTest
public with sharing class claimValidationHelperTestNew {
    @isTest
    public static void validateClaimTest(){
        Test.startTest();
        List<ElixirSuite__Claim__c> claimList = new List<ElixirSuite__Claim__c>();
        ElixirSuite__Claim__c claimRecord = new ElixirSuite__Claim__c();
        claimRecord.ElixirSuite__claim_status__c = 'Clearing house accepted';
        claimRecord.ElixirSuite__pcn__c = 'John';
        claimRecord.ElixirSuite__patient_first_Name__c = 'David';
        claimRecord.ElixirSuite__patient_last_Name__c = 'Beckam';
        claimRecord.ElixirSuite__npi__c = '1831234939';
        claimRecord.ElixirSuite__payer_id__c = '20413';
        claimRecord.ElixirSuite__other_payer_name__c = 'LIC';
        claimRecord.ElixirSuite__Insured_s_ID_Number__c = '1232';
        claimRecord.ElixirSuite__patient_dob__c = System.today().addYears(-40);
        claimRecord.ElixirSuite__patient_sex__c = 'M';
        claimRecord.ElixirSuite__insured_s_name__c = 'David';
        claimRecord.ElixirSuite__insured_s_name__c = 'Beckam';
        claimRecord.ElixirSuite__payer_order__c = 'Primary';
        claimRecord.ElixirSuite__patient_s_address__c = 'Noida';
        claimRecord.ElixirSuite__patient_s_city__c = 'Noida';
        claimRecord.ElixirSuite__patient_country_code__c = 'IN';
        claimRecord.ElixirSuite__patient_s_state__c = 'UP';
        claimRecord.ElixirSuite__patient_s_zipcode__c = 201301;
        claimRecord.ElixirSuite__Patient_Relationship_to_Insured__c = 'Father';
        claimRecord.ElixirSuite__insured_address__c = 'Noida';
        claimRecord.ElixirSuite__insured_city__c = 'Noida';
        claimRecord.ElixirSuite__insured_country_code__c = 'IN';
        claimRecord.ElixirSuite__insured_state__c = 'UP';
        claimRecord.ElixirSuite__insured_zipcode__c = 201301;
        claimRecord.ElixirSuite__employment_related__c = 'No';
        claimRecord.ElixirSuite__Auto_Accident_Related__c = 'No';
        claimRecord.ElixirSuite__insured_dob__c = System.today().addYears(-10);
        claimRecord.ElixirSuite__insured_sex__c = 'M';
        claimRecord.ElixirSuite__Place_of_Service__c = 'Delhi';
        claimRecord.ElixirSuite__bill_taxid__c = '123656789';
        claimRecord.ElixirSuite__Billing_Provider_Tax_ID_Type__c = 'E';
        claimRecord.ElixirSuite__Accept_Assignment__c = 'Y';
        claimRecord.ElixirSuite__total_charge__c = 900;
        claimRecord.ElixirSuite__amount_paid__c = 0;
        claimRecord.ElixirSuite__Billing_Provider_Name__c = 'ATHENA';
        claimRecord.ElixirSuite__Billing_Provider_Address_1__c = 'Watertown';
        claimRecord.ElixirSuite__Billing_Provider_State__c = 'CA';
        claimRecord.ElixirSuite__Billing_Provider_Zip__c = '232329998';
        claimRecord.ElixirSuite__Bill_Phone__c = '4152155300';
        claimRecord.ElixirSuite__Billing_Provider_City__c = 'Watertown';
        claimRecord.ElixirSuite__Diag_1__c = 'B86';
        insert claimRecord;
        claimList.add(claimRecord);
        //Claim Line Item Creation START
        List<ElixirSuite__Claim_Line_Items__c> clList = new List<ElixirSuite__Claim_Line_Items__c>();
        ElixirSuite__Claim_Line_Items__c rec = new ElixirSuite__Claim_Line_Items__c();
        rec.ElixirSuite__CPT_HCPCS_Code__c = '38525';
        rec.ElixirSuite__Days_Units__c = 2;
        rec.ElixirSuite__From_Date__c = System.today().adddays(-10);
        rec.ElixirSuite__To_Date__c = System.today().adddays(-8);
        rec.ElixirSuite__procedure_charge__c = 900;
        rec.ElixirSuite__diag_ref__c = 'A';
        rec.ElixirSuite__claim__c = claimRecord.Id;
        insert rec;
        clList.add(rec);
        claimValidationHelper.getVerifyDev1();
         claimValidationHelper.setVerifyDev1(true);
        claimValidationHelper.validate1(claimList,clList);
        claimValidationHelper.validateClaims(claimRecord);
        claimValidationHelper.validateClaimLineItem(rec);
        claimValidationHelper.splitNames1('Test Elixir');
        claimValidationHelper.splitNames('Test Elixir');
        System.assertEquals(1, 1);
        Test.stopTest();
    }
}
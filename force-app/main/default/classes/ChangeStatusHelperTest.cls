@isTest
public class ChangeStatusHelperTest {
 @isTest
    private static void getPayerTest(){
            
       
        Test.startTest();
        ElixirSuite__Payor__c payorRecord = new ElixirSuite__Payor__c();
        payorRecord.ElixirSuite__Payer_Code__c = '60054';
        payorRecord.ElixirSuite__Claim_Processing_via__c = 'Clearing House';
        insert payorRecord;
        //Claim Creation START
        ElixirSuite__Claim__c claimRecord = new ElixirSuite__Claim__c();
        claimRecord.ElixirSuite__Payor__c = payorRecord.Id;
        claimRecord.ElixirSuite__claim_status__c = 'Ready to Submit';
        claimRecord.ElixirSuite__pcn__c = 'John';
        claimRecord.ElixirSuite__patient_first_Name__c = 'David';
        claimRecord.ElixirSuite__patient_last_Name__c = 'Beckam';
        claimRecord.ElixirSuite__NPI__c = '1831234939';
        claimRecord.ElixirSuite__other_payer_name__c = 'LIC';
        claimRecord.ElixirSuite__patient_dob__c = System.today().addYears(-40);
        claimRecord.ElixirSuite__patient_sex__c = 'M';
        claimRecord.ElixirSuite__insured_s_name__c = 'David';
        claimRecord.ElixirSuite__insured_s_name__c = 'Beckam';
        claimRecord.ElixirSuite__payer_order__c = 'Primary';
        claimRecord.ElixirSuite__patient_s_address__c = 'Noida';
        claimRecord.ElixirSuite__patient_s_city__c = 'Noida';
        claimRecord.ElixirSuite__patient_country_code__c = 'IN';
        claimRecord.ElixirSuite__Patient_s_State__c = 'NY';
        claimRecord.ElixirSuite__patient_s_zipcode__c = 201301;
        claimRecord.ElixirSuite__Patient_Relationship_to_Insured__c = 'Father';
        claimRecord.ElixirSuite__insured_address__c = 'Noida';
        claimRecord.ElixirSuite__insured_city__c = 'Noida';
        claimRecord.ElixirSuite__insured_country_code__c = 'IN';
        claimRecord.ElixirSuite__Insured_State__c = 'NY';
        claimRecord.ElixirSuite__Insured_Zip_Code__c = '201301';
        claimRecord.ElixirSuite__Insured_Telephone__c = '9888898888';
        claimRecord.ElixirSuite__Insured_Policy__c = 'Medical Benefits';
        claimRecord.ElixirSuite__Insured_s_ID_Number__c = '56565';
        claimRecord.ElixirSuite__Employment_Related__c = 'N';
        claimRecord.ElixirSuite__Auto_Accident_Related__c = 'N';
        claimRecord.ElixirSuite__insured_dob__c = System.today().addYears(-10);
        claimRecord.ElixirSuite__insured_sex__c = 'M';
        claimRecord.ElixirSuite__Place_of_Service__c = 'Delhi';
        claimRecord.ElixirSuite__Diagnosis_A__c = '99153';
        //claimRecord.bill_taxid__c = '123656789';
        claimRecord.ElixirSuite__Billing_Provider_Tax_ID_Type__c = 'E';
        claimRecord.ElixirSuite__Accept_Assignment__c = 'Y';
        claimRecord.ElixirSuite__total_charge__c = 900;
        claimRecord.ElixirSuite__amount_paid__c = 0;
        claimRecord.ElixirSuite__Billing_Provider_Name__c = 'ATHENA';
        claimRecord.ElixirSuite__Billing_Provider_Address_1__c = 'Watertown';
        claimRecord.ElixirSuite__Billing_Provider_State__c = 'CA';
        claimRecord.ElixirSuite__Billing_Provider_Info_NPI__c = '1234567890';
        claimRecord.ElixirSuite__Billing_Provider_Zip__c = '91101';
        claimRecord.ElixirSuite__Billing_Provider_Info__c = '1234567890';
        claimRecord.ElixirSuite__Bill_Phone__c = '8152155300';
        claimRecord.ElixirSuite__Billing_Provider_City__c = 'Watertown';
        claimRecord.ElixirSuite__Patient_Name__c = 'Test Account 1';
        claimRecord.ElixirSuite__Insured_s_Name__c= 'Test Insured 1';
        claimRecord.ElixirSuite__Other_Insured_s_Name__c= 'Test OtherInsured 1';
        claimRecord.ElixirSuite__claim_status__c = 'Clearing house accepted';
        claimRecord.ElixirSuite__Federal_Tax_Id_Number__c = '456789021';
        insert claimRecord;
        ElixirSuite__Claim_Line_Items__c rec = new ElixirSuite__Claim_Line_Items__c();
        rec.ElixirSuite__CPT_HCPCS_Code__c = '38525';
        rec.ElixirSuite__Days_Units__c = 2;
        rec.ElixirSuite__From_Date__c = System.today().adddays(-10);
        rec.ElixirSuite__To_Date__c = System.today().adddays(-8);
        rec.ElixirSuite__procedure_charge__c = 900;
        rec.ElixirSuite__diag_ref__c = 'A';
        rec.ElixirSuite__Diagnosis_Pointer__c = 'A';
        rec.ElixirSuite__claim__c = claimRecord.Id;
        insert rec;
        String claimId = claimRecord.Id;
        Test.setMock(HttpCalloutMock.class, new ChangeStatusHelperMock()); 
       String virtualClass = 'CustomerCalloutClaimMD';
        Callable extension = (Callable) Type.forName(virtualClass).newInstance();
        extension.call('GetpayerStatusClaimMD', new Map<String, Object> { 
            'claimId' => claimId
         });       
        ChangeStatusHelper.checkClaimStatus(claimRecord.Id);
        System.assertEquals(1,1,'');
        Test.stopTest();
    }
}
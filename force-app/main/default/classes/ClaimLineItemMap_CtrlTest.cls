@isTest
public class ClaimLineItemMap_CtrlTest {

    public static void dataSetup(){
        
        Claim__c claimRecord = new Claim__c();
        claimRecord.pcn__c = 'John';
        claimRecord.patient_first_Name__c = 'David';
        claimRecord.patient_last_Name__c = 'Beckam';
        // claimRecord.npi__c = '1831234939';
        //claimRecord.payer_id__c = '20413';
        claimRecord.other_payer_name__c = 'LIC';
        //  claimRecord.Insured_s_ID_Number__c = '1232';
        claimRecord.patient_dob__c = System.today().addYears(-40);
        claimRecord.patient_sex__c = 'M';
        claimRecord.insured_s_name__c = 'David';
        claimRecord.insured_s_name__c = 'Beckam';
        claimRecord.payer_order__c = 'Primary';
        claimRecord.patient_s_address__c = 'Noida';
        claimRecord.patient_s_city__c = 'Noida';
        claimRecord.patient_country_code__c = 'IN';
        claimRecord.patient_s_state__c = 'Uttar Pradesh';
        claimRecord.patient_s_zipcode__c = 201301;
        claimRecord.Patient_Relationship_to_Insured__c = 'Father';
        claimRecord.insured_address__c = 'Noida';
        claimRecord.insured_city__c = 'Noida';
        claimRecord.insured_country_code__c = 'IN';
        claimRecord.insured_state__c = 'Uttar Pradesh';
        claimRecord.insured_zipcode__c = 201301;
        claimRecord.employment_related__c = 'No';
        claimRecord.Auto_Accident_Related__c = 'No';
        claimRecord.insured_dob__c = System.today().addYears(-10);
        claimRecord.insured_sex__c = 'M';
        claimRecord.Place_of_Service__c = 'Delhi';
        //claimRecord.bill_taxid__c = '123656789';
        claimRecord.Billing_Provider_Tax_ID_Type__c = 'E';
        claimRecord.Accept_Assignment__c = 'Y';
        claimRecord.total_charge__c = 900;
        claimRecord.amount_paid__c = 0;
        claimRecord.Billing_Provider_Name__c = 'ATHENA';
        claimRecord.Billing_Provider_Address_1__c = 'Watertown';
        claimRecord.Billing_Provider_State__c = 'CA';
        //claimRecord.Billing_Provider_Zip__c = '232329998';
        //  claimRecord.Bill_Phone__c = '4152155300';
        claimRecord.Billing_Provider_City__c = 'Watertown';
        //  claimRecord.Diag_1__c = 'B86';
        insert claimRecord;
        //Claim Line Item Creation START
        Claim_Line_Items__c rec = new Claim_Line_Items__c();
        // rec.CPT_HCPCS_Code__c = '38525';
        rec.ElixirSuite__Proc_code__c ='TST';
        rec.Days_Units__c = 2;
        rec.From_Date__c = System.today().adddays(-10);
        rec.To_Date__c = System.today().adddays(-8);
        rec.procedure_charge__c = 900;
        rec.diag_ref__c = 'A';
        rec.claim__c = claimRecord.Id;
        insert rec;
    }
    
    @isTest
    public static void getClaimLinesTestMethod(){
        dataSetup();
        
        Claim__c cl = [Select id,Name,(Select id,ElixirSuite__Proc_code__c,ElixirSuite__Procedure__r.Name from ElixirSuite__Claim_Line_Items__r) from ElixirSuite__Claim__c limit 1];
        
        Test.startTest();
        List<ClaimLineItemMap_Ctrl.claimLineWrapper> claimLineWrapperList = ClaimLineItemMap_Ctrl.getClaimLines(cl.id);
        Test.stopTest();
        
        System.assertEquals(1, claimLineWrapperList.size(),'');
     //   System.assertEquals('TST', claimLineWrapperList[0].procCode);
    }
}
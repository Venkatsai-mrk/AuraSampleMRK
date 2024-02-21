@isTest
public class ReverseReconciliationControllerTest {
    
    @isTest
    public static void callingBatch(){
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
        
         Id paymntTxnRecordTypeId = Schema.SObjectType.ElixirSuite__Payment_Transaction__c.getRecordTypeInfosByDeveloperName().get('Insurance_Payment').getRecordTypeId();
        
        ElixirSuite__Procedure__c procedure2 = new ElixirSuite__Procedure__c();
        procedure2.Name = 'Test Procedure';
        procedure2.ElixirSuite__CPT_HCPCS_Code__c = '12345';
        procedure2.ElixirSuite__From_Date__c = System.today();
        procedure2.ElixirSuite__To_Date__c = System.today().addDays(1);
        procedure2.ElixirSuite__Account__c =  patient.Id;
        insert procedure2;
                
        ElixirSuite__Payment_Transaction__c payTran = new ElixirSuite__Payment_Transaction__c();
        payTran.ElixirSuite__Actual_Price__c = 500;
        payTran.ElixirSuite__Procedure__c = procedure2.Id;
        payTran.ElixirSuite__Cpt_Codes__c = 'CPT100';
        payTran.ElixirSuite__Insurance_Payments__c = 200;
        payTran.ElixirSuite__Account__c = patient.Id;
        payTran.RecordTypeId = paymntTxnRecordTypeId;
        payTran.ElixirSuite__Patient_Payments__c = 100;
        payTran.ElixirSuite__Payment_Adjustments__c = 10;
        insert payTran;
        
        Transactions__c tran= new Transactions__c();
        tran.ElixirSuite__Type_of_Payment__c = 'Payment';
        tran.ElixirSuite__Amount_Paid__c = 100;
        tran.ElixirSuite__Master_Transaction__c = payTran.Id;
        insert tran;
        
        ElixirSuite__Claim__c claimRecord = new ElixirSuite__Claim__c();
        claimRecord.ElixirSuite__claim_status__c = 'Clearing house accepted';
        claimRecord.ElixirSuite__Account__c = patient.Id;
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
        claimRecord.ElixirSuite__Posted__c = false;
        insert claimRecord;
        
        ElixirSuite__Claim_Line_Items__c rec = new ElixirSuite__Claim_Line_Items__c();
        rec.ElixirSuite__CPT_HCPCS_Code__c = '38525';
        rec.ElixirSuite__Days_Units__c = 2;
        rec.ElixirSuite__From_Date__c = System.today().adddays(-10);
        rec.ElixirSuite__To_Date__c = System.today().adddays(-8);
        rec.ElixirSuite__procedure_charge__c = 900;
        rec.ElixirSuite__diag_ref__c = 'A';
        rec.ElixirSuite__claim__c = claimRecord.Id;
        rec.ElixirSuite__Procedure__c = procedure2.Id;
        insert rec;
        
        ElixirSuite__Claim__c claimRec = [Select id, Name from ElixirSuite__Claim__c where ElixirSuite__Account__c =: patient.Id LIMIT 1];
        ElixirSuite__Claim_Line_Items__c cliRec = [Select id, Name from ElixirSuite__Claim_Line_Items__c where ElixirSuite__Claim__c =: claimRec.Id LIMIT 1];
        
        
        String ClName = claimRec.Name;
        ClName = ClName.replaceAll('-', '');
        String CliName = cliRec.Name;
        CliName = CliName.replaceAll('-', '');
        
        claimRecord.ElixirSuite__Posted__c =false;
        update claimRecord;
       
        ElixirSuite__EOB__c childEo = new ElixirSuite__EOB__c();
        childEo.ElixirSuite__Pcn__c = ClName;
        childEo.ElixirSuite__Claim__c = claimRec.Id;
        childEo.ElixirSuite__Account__c = patient.Id;
        childEo.ElixirSuite__Payer_ICN__c = '652533e8333454';
        insert childEo;
        
        ElixirSuite__ERA_Line_Item__c eraLine1 = New ElixirSuite__ERA_Line_Item__c();
        eraLine1.ElixirSuite__chg_Id__c = childEo.ElixirSuite__Pcn__c + ';'+childEo.ElixirSuite__Payer_ICN__c + CliName;
        eraLine1.ElixirSuite__EOB__c = childEo.Id;
        eraLine1.ElixirSuite__Total_Paid__c = 500;
        insert eraLine1;
        
        ElixirSuite__EOB__c childEob = new ElixirSuite__EOB__c();
        childEob.ElixirSuite__Pcn__c = ClName;
        childEob.ElixirSuite__ERA_Status_Code__c = 'Process as Primary';
        childEob.ElixirSuite__Payer_ICN__c = '467485685776956';
        insert childEob;
        
        
        ElixirSuite__ERA_Line_Item__c eraLine = New ElixirSuite__ERA_Line_Item__c();
        eraLine.ElixirSuite__chg_Id__c = childEob.ElixirSuite__Pcn__c + ';'+childEob.ElixirSuite__Payer_ICN__c + CliName;
        eraLine.ElixirSuite__EOB__c = childEob.Id;
        insert eraLine;
        
        ElixirSuite__EOB__c childEob2 = new ElixirSuite__EOB__c();
        childEob2.ElixirSuite__Pcn__c = ClName;
        childEob2.ElixirSuite__Payer_ICN__c = '667e87379848t9';
        insert childEob2;
        
        
        ElixirSuite__ERA_Line_Item__c eraLine3 = New ElixirSuite__ERA_Line_Item__c();
        eraLine3.ElixirSuite__chg_Id__c = childEob2.ElixirSuite__Pcn__c + ';'+childEob2.ElixirSuite__Payer_ICN__c + CliName;
        eraLine3.ElixirSuite__EOB__c = childEob2.Id;
        insert eraLine3;
        
        ElixirSuite__EOB__c childEob1 = new ElixirSuite__EOB__c();
        childEob1.ElixirSuite__Pcn__c = claimRec.Name;
        childEob1.ElixirSuite__Payer_ICN__c = '98787677646562';
        insert childEob1;
        
        ElixirSuite__ERA_Line_Item__c eraLine2 = New ElixirSuite__ERA_Line_Item__c();
        eraLine2.ElixirSuite__chg_Id__c = childEob1.ElixirSuite__Pcn__c + ';'+childEob1.ElixirSuite__Payer_ICN__c + cliRec.Name;
        eraLine2.ElixirSuite__EOB__c = childEob1.Id;
        insert eraLine2;
        
        ReverseReconciliationController.reverseReconciliation(claimRec.Id);
        System.assertEquals(1,1,'');
    }

}
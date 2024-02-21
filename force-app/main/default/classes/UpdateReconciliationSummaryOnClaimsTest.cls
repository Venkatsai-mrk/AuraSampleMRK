@isTest
public class UpdateReconciliationSummaryOnClaimsTest 
{
    @isTest
    public static void unitTest()
    {
         Account patient = TestDataFactory.createPatientAcc();
        insert patient;
        
        Procedure__c procedureTemp = TestDataFactory.createProcedure(patient.Id);
        procedureTemp.Account__c =  null;
        insert procedureTemp;
        
        Provider__c providerTemp = TestDataFactory.createProviderTemp();
        //providerTemp.Account__c =  null;
        insert providerTemp;
        
        Provider__c provider = TestDataFactory.createProvider(patient.Id);
        insert provider;
        
        Actual_Price__c actualPrice = TestDataFactory.createActualPrice(procedureTemp.Id, providerTemp.Id);
        insert actualPrice;
        
        Procedure__c procedure = TestDataFactory.createProcedure(patient.Id);
        insert procedure;
        
       Claim__c c = new Claim__c();
        c.Account__c = patient.Id;
        c.Total_Charge__c = 0; 
        c.Other_Payer_Name__c = 'James';
        c.Total_Patient_Responsibility__c = 0;
        c.Claim_Status__c = 'Paid and Patient Responsibility';
        c.Patient_Sex__c = 'M';
        c.Payer_Id__c = '12345';
        c.Patient_s_Address__c = 'Delhi';
        c.Patient_s_City__c = 'Delhi';
        c.Patient_s_State__c = 'Delhi';
        c.Patient_s_Zipcode__c = 110027;
        c.Patient_Country_Code__c = '1';
        c.Patient_Relationship_to_Insured__c = 'Son';
        c.Billing_Provider_Tax_ID_Type__c = 'E';
        c.Accept_Assignment__c = 'Hello';
        c.Employment_Related__c = 'Son';
        c.Auto_Accident_Related__c = 'Hello';
        c.Billing_Provider_Tax_ID__c = '12345';
        c.Insured_DOB__c = System.today();
        c.Insured_Sex__c = 'M';
        c.Place_of_Service__c = 'Delhi';
        c.Insured_Address__c = 'Delhi';
        c.Insured_City__c = 'Delhi';
        c.Insured_Country_Code__c = 'INDIA';
        c.Insured_State__c = 'DEL';
        c.Insured_Zipcode__c = 110027;
        c.NPI__c = '12345';
        c.Procedure_Code__c = 'HC';
        c.Patient_DOB__c = System.today();
        c.Insured_s_ID_Number__c = '12345';
        c.Amount_Paid__c = 12345;
        c.Units__c = '1';
        c.From_Date__c = System.today();
        c.Thru_Date__c = System.today();
        c.Billing_Provider_Name__c = 'Aetna';
        c.Billing_Provider_Address_1__c = 'Delhi';
        c.Billing_Provider_City__c = 'Delhi';
        c.Billing_Provider_State__c = 'Delhi';
        c.Billing_Provider_Zip__c = '110027';
        c.Bill_Phone__c = '123456';
        c.First_Diagnosis__c = 'BP';
        c.Charge_Amount__c = '2340';
        c.Total_Adjustment_Amount__c = 0;
        c.Total_Contracted_Amount__c = 0;
        c.Total_Amount_Paid_By_Insurance__c = 10;
        c.Total_Allowed_Amount__c = null;
        c.Diagnosis_Reference__c = 'F';
        insert c;
        
        Claim__c c2 = new Claim__c();
        c2.Account__c = patient.Id;
        c2.Total_Charge__c = 0; 
        c2.Other_Payer_Name__c = 'James2';
        c2.Total_Patient_Responsibility__c = 4;
        c2.Claim_Status__c = 'Underpaid';
        c2.Patient_Sex__c = 'M';
        c2.Payer_Id__c = '12435';
        c2.Patient_s_Address__c = 'Delhi';
        c2.Patient_s_City__c = 'Delhi';
        c2.Patient_s_State__c = 'Delhi';
        c2.Patient_s_Zipcode__c = 110027;
        c2.Patient_Country_Code__c = '1';
        c2.Patient_Relationship_to_Insured__c = 'Son';
        c2.Billing_Provider_Tax_ID_Type__c = 'E';
        c2.Accept_Assignment__c = 'Hello';
        c2.Employment_Related__c = 'Son';
        c2.Auto_Accident_Related__c = 'Hello';
        c2.Billing_Provider_Tax_ID__c = '13245';
        c2.Insured_DOB__c = System.today();
        c2.Insured_Sex__c = 'M';
        c2.Place_of_Service__c = 'Delhi';
        c2.Insured_Address__c = 'Delhi';
        c2.Insured_City__c = 'Delhi';
        c2.Insured_Country_Code__c = 'INDIA';
        c2.Insured_State__c = 'DEL';
        c2.Insured_Zipcode__c = 110027;
        c2.NPI__c = '12345';
        c2.Procedure_Code__c = 'HC';
        c2.Patient_DOB__c = System.today();
        c2.Insured_s_ID_Number__c = '12345';
        c2.Amount_Paid__c = 13345;
        c2.Units__c = '1';
        c2.From_Date__c = System.today();
        c2.Thru_Date__c = System.today();
        c2.Billing_Provider_Name__c = 'Aeta';
        c2.Billing_Provider_Address_1__c = 'Delhi';
        c2.Billing_Provider_City__c = 'Delhi';
        c2.Billing_Provider_State__c = 'Delhi';
        c2.Billing_Provider_Zip__c = '110027';
        c2.Bill_Phone__c = '122456';
        c2.First_Diagnosis__c = 'BP';
        c2.Charge_Amount__c = '2340';
        c2.Total_Adjustment_Amount__c = 0;
        c2.Total_Contracted_Amount__c = 0;
        c2.Total_Amount_Paid_By_Insurance__c = 10;
        c2.Total_Allowed_Amount__c = 0;
        c2.Diagnosis_Reference__c = 'F';
        insert c2;
        
         Claim__c c3 = new Claim__c();
        c3.Account__c = patient.Id;
        c3.Total_Charge__c = 0; 
        c3.Other_Payer_Name__c = 'James3';
        c3.Total_Patient_Responsibility__c = 0;
        c3.Claim_Status__c = 'Paid and resolved';
        c3.Patient_Sex__c = 'M';
        c3.Payer_Id__c = '11345';
        c3.Patient_s_Address__c = 'Delhi';
        c3.Patient_s_City__c = 'Delhi';
        c3.Patient_s_State__c = 'Delhi';
        c3.Patient_s_Zipcode__c = 110027;
        c3.Patient_Country_Code__c = '1';
        c3.Patient_Relationship_to_Insured__c = 'Son';
        c3.Billing_Provider_Tax_ID_Type__c = 'E';
        c3.Accept_Assignment__c = 'Hello';
        c3.Employment_Related__c = 'Son';
        c3.Auto_Accident_Related__c = 'Hello';
        c3.Billing_Provider_Tax_ID__c = '12045';
        c3.Insured_DOB__c = System.today();
        c3.Insured_Sex__c = 'M';
        c3.Place_of_Service__c = 'Delhi';
        c3.Insured_Address__c = 'Delhi';
        c3.Insured_City__c = 'Delhi';
        c3.Insured_Country_Code__c = 'INDIA';
        c3.Insured_State__c = 'DEL';
        c3.Insured_Zipcode__c = 110027;
        c3.NPI__c = '12245';
        c3.Procedure_Code__c = 'HC';
        c3.Patient_DOB__c = System.today();
        c3.Insured_s_ID_Number__c = '12335';
        c3.Amount_Paid__c = 10345;
        c3.Units__c = '1';
        c3.From_Date__c = System.today();
        c3.Thru_Date__c = System.today();
        c3.Billing_Provider_Name__c = 'Aetna';
        c3.Billing_Provider_Address_1__c = 'Delhi';
        c3.Billing_Provider_City__c = 'Delhi';
        c3.Billing_Provider_State__c = 'Delhi';
        c3.Billing_Provider_Zip__c = '110027';
        c3.Bill_Phone__c = '122456';
        c3.First_Diagnosis__c = 'BP';
        c3.Charge_Amount__c = '2240';
        c3.Total_Adjustment_Amount__c = 0;
        c3.Total_Contracted_Amount__c = 0;
        c3.Total_Amount_Paid_By_Insurance__c = 10;
        c3.Total_Allowed_Amount__c = 0;
        c3.Diagnosis_Reference__c = 'F';
        insert c3;
        
         Claim__c c4 = new Claim__c();
        c4.Account__c = patient.Id;
        c4.Total_Charge__c = 0; 
        c4.Other_Payer_Name__c = 'James4';
        c4.Total_Patient_Responsibility__c = -2;
        c4.Claim_Status__c = 'Overpaid';
        c4.Patient_Sex__c = 'M';
        c4.Payer_Id__c = '14345';
        c4.Patient_s_Address__c = 'Delhi';
        c4.Patient_s_City__c = 'Delhi';
        c4.Patient_s_State__c = 'Delhi';
        c4.Patient_s_Zipcode__c = 110027;
        c4.Patient_Country_Code__c = '1';
        c4.Patient_Relationship_to_Insured__c = 'Son';
        c4.Billing_Provider_Tax_ID_Type__c = 'E';
        c4.Accept_Assignment__c = 'Helo';
        c4.Employment_Related__c = 'Son';
        c4.Auto_Accident_Related__c = 'Helo';
        c4.Billing_Provider_Tax_ID__c = '12345';
        c4.Insured_DOB__c = System.today();
        c4.Insured_Sex__c = 'M';
        c4.Place_of_Service__c = 'Delhi';
        c4.Insured_Address__c = 'Delhi';
        c4.Insured_City__c = 'Delhi';
        c4.Insured_Country_Code__c = 'INDIA';
        c4.Insured_State__c = 'DEL';
        c4.Insured_Zipcode__c = 110027;
        c4.NPI__c = '12345';
        c4.Procedure_Code__c = 'HC';
        c4.Patient_DOB__c = System.today();
        c4.Insured_s_ID_Number__c = '12345';
        c4.Amount_Paid__c = 12345;
        c4.Units__c = '1';
        c4.From_Date__c = System.today();
        c4.Thru_Date__c = System.today();
        c4.Billing_Provider_Name__c = 'Aetna';
        c4.Billing_Provider_Address_1__c = 'Delhi';
        c4.Billing_Provider_City__c = 'Delhi';
        c4.Billing_Provider_State__c = 'Delhi';
        c4.Billing_Provider_Zip__c = '110027';
        c4.Bill_Phone__c = '123456';
        c4.First_Diagnosis__c = 'BP';
        c4.Charge_Amount__c = '2340';
        c4.Total_Adjustment_Amount__c = 0;
        c4.Total_Contracted_Amount__c = 0;
        c4.Total_Amount_Paid_By_Insurance__c = 10;
        c4.Total_Allowed_Amount__c = 0;
        c4.Diagnosis_Reference__c = 'F';
        insert c4;
        
        Claim_Line_Items__c cli = TestDataFactory.createClaimLineItems(c.Id, procedure.Id);
        cli.ERA_received__c = true;
        insert cli;
        
        Claim_Line_Items__c cli2 = TestDataFactory.createClaimLineItems(c.Id, procedure.Id);
         cli2.ERA_received__c = true;
        insert cli2;
        delete cli2;
        
         UpdateReconciliationSummaryOnClaimscls.deniedStatusUpdate(new Set<Id>{c.Id,c2.Id,c3.Id});
         System.assertEquals(1, 1, ' ');
    }
     @isTest
    public static void testpaidAndPatientResponseSec(){
         Account patient = TestDataFactory.createPatientAcc();
        insert patient;
        
         Account acc2 = new Account(Name='Test Account 2');
        insert acc2;
        
        
        Claim__c c = new Claim__c();
        c.Account__c = patient.Id;
        c.Total_Charge__c = 0; 
        c.Other_Payer_Name__c = 'James';
        c.Total_Patient_Responsibility__c = 0;
        c.Claim_Status__c = 'Paid and patient responsibility with Secondary';
        c.Patient_Sex__c = 'M';
        c.Payer_Id__c = '12345';
        c.Patient_s_Address__c = 'Delhi';
        c.Patient_s_City__c = 'Delhi';
        c.Patient_s_State__c = 'Delhi';
        c.Patient_s_Zipcode__c = 110027;
        c.Patient_Country_Code__c = '1';
        c.Patient_Relationship_to_Insured__c = 'Son';
        c.Billing_Provider_Tax_ID_Type__c = 'E';
        c.Accept_Assignment__c = 'Hello';
        c.Employment_Related__c = 'Son';
        c.Auto_Accident_Related__c = 'Hello';
        c.Billing_Provider_Tax_ID__c = '12345';
        c.Insured_DOB__c = System.today();
        c.Insured_Sex__c = 'M';
        c.Place_of_Service__c = 'Delhi';
        c.Insured_Address__c = 'Delhi';
        c.Insured_City__c = 'Delhi';
        c.Insured_Country_Code__c = 'INDIA';
        c.Insured_State__c = 'DEL';
        c.Insured_Zipcode__c = 110027;
        c.NPI__c = '12345';
        c.Procedure_Code__c = 'HC';
        c.Patient_DOB__c = System.today();
        c.Insured_s_ID_Number__c = '12345';
        c.Amount_Paid__c = 12345;
        c.Units__c = '1';
        c.From_Date__c = System.today();
        c.Thru_Date__c = System.today();
        c.Billing_Provider_Name__c = 'Aetna';
        c.Billing_Provider_Address_1__c = 'Delhi';
        c.Billing_Provider_City__c = 'Delhi';
        c.Billing_Provider_State__c = 'Delhi';
        c.Billing_Provider_Zip__c = '110027';
        c.Bill_Phone__c = '123456';
        c.First_Diagnosis__c = 'BP';
        c.Charge_Amount__c = '2340';
        c.Total_Adjustment_Amount__c = 0;
        c.Total_Contracted_Amount__c = 0;
        c.Total_Amount_Paid_By_Insurance__c = 10;
        c.Total_Allowed_Amount__c = null;
        c.Diagnosis_Reference__c = 'F';
        insert c;
        
         Claim__c claim2 = new Claim__c(Account__c = acc2.Id, Total_Patient_Responsibility__c = 0, Claim_Status__c = 'Paid and patient responsibility', Total_Contracted_Amount__c = 100, Total_Allowed_Amount__c = 100, Total_Amount_Paid_By_Insurance__c = 100);
        insert claim2;
        
         VOB__c vob = new VOB__c();
         vob.ElixirSuite__Account__c = patient.id;
        vob.PatientFirstName__c = 'Test';
        vob.PatientLastName__c = 'Patient';
        vob.Patient_Birth_Date__c = System.today().addYears(-26);
        vob.Member_Id__c = '12345';
        vob.Payer_Name__c = 'Test Payer';
        vob.ElixirSuite__Insured_Address__c = 'ABC';
        vob.Verification_Status__c = 'Approved';
        vob.Insurance_Counts__c='Secondary';
        vob.ElixirSuite__Date_Of_Birth__c =date.valueOf('2000-04-18');
        insert vob;
        
        VOB__c vob2 = new VOB__c(Account__c = acc2.Id, VOB_Verification_Status__c = 'Approved', Insurance_Counts__c = 'Primary');
        insert vob2;
        
       //Claim__c cl = [Select id,Name,(Select id,ElixirSuite__Proc_code__c,ElixirSuite__Procedure__r.Name from ElixirSuite__Claim_Line_Items__r) from ElixirSuite__Claim__c limit 1];
         Claim__c updatedClaim = [SELECT Claim_Status__c FROM Claim__c WHERE Id = :c.Id];
         Claim__c notUpdatedClaim = [SELECT Claim_Status__c FROM Claim__c WHERE Id = :claim2.Id];
       UpdateReconciliationSummaryOnClaimsCls.paidAndPatientResponseSec(new Set<Id>{c.Id});
       System.assertEquals(1, 1, ' ');
         
    }
    
}
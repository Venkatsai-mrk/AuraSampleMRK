public class Testdatasynfactory {
    public static Account createPatientAcc()
    {
        Account patient = new Account();
        patient.name = 'Test Patient';
        patient.ElixirSuite__Email_Id__c = 'kj@gmail.com';
        patient.Patient_s_Birth_Date__c = System.today().addyears(-20);
        patient.MRN_Number__c = 1234567;
        patient.ElixirSuite__First_Name__c ='fname';
        patient.ElixirSuite__Last_Name__c ='lname';
        patient.ElixirSuite__SSN__c ='1234';
        patient.ElixirSuite__Gender__c='Male';
        patient.Phone ='9919850735';
        patient.BillingPostalCode='27440';
        
        return patient;
    }
    public static Procedure__c createProcedure(Id accId)
    {
        Procedure__c procedure = new Procedure__c();
        procedure.Name = 'Test Procedure';
        procedure.Account__c = accId;
        procedure.CPT_HCPCS_Code__c = '12345';
        procedure.From_Date__c = System.today();
        procedure.To_Date__c = System.today().addDays(1);
        procedure.ElixirSuite__Charges__c = 1000 ;
        return procedure;
    }
    /*Public static Procedure_Diagnosis__c createProcedureDiag(Id AccountId){
        Procedure_Diagnosis__c Pdiag = New Procedure_Diagnosis__c();
        Pdiag.ICD_Codes__r.name = 'Test';
            Pdiag.Procedure__c = 'Demo';
        Pdiag.Account__c = 'AccountId';
        return Pdiag;
    }*/
    /*public static ElixirSuite__CMS_1500_Claim_Generation__c createcustomstg(){
        ElixirSuite__CMS_1500_Claim_Generation__c Custg =New ElixirSuite__CMS_1500_Claim_Generation__c();
        
        Custg.ElixirSuite__Billing_Provider_Address__c = 'Surya';
            Custg.ElixirSuite__Billing_Provider_City__c = 'CA';
            Custg.ElixirSuite__Billing_Provider_Name__c = 'Test';
            Custg.ElixirSuite__Billing_Provider_NPI__c = '12345';
            Custg.ElixirSuite__Billing_Provider_Phone__c = '7083';
            Custg.ElixirSuite__Billing_Provider_State__c = 'CA';
            Custg.ElixirSuite__Billing_Provider_Tax_ID__c = '12345';
            Custg.ElixirSuite__Billing_Provider_Zipcode__c = '4403';
        return Custg;
    } */
    
   
    
 public static Claim__c createClaim(Id accId, Id PayId, Id VobId)
    {
        Claim__c c = new Claim__c();
        c.ElixirSuite__VOB_lookup__c = VobId;
        c.ElixirSuite__Payor__c = PayId;
        c.Account__c = accId;
        c.Total_Charge__c = 0; 
        c.Other_Payer_Name__c = 'James';
        c.Total_Patient_Responsibility__c = 0;
        c.Claim_Status__c = 'Ready to Submit';
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
        c.Total_Amount_Paid_By_Insurance__c = 0;
        c.Total_Allowed_Amount__c = 0;
        c.Diagnosis_Reference__c = 'F';
        return c;
    }
    
    
    public static Claim_Line_Items__c createClaimLineItems(Id claimId, Id procedureId)
    {
        Claim_Line_Items__c cli = new Claim_Line_Items__c ();
        cli.Claim__c = claimId;
        cli.Procedure__c = procedureId;
        cli.CPT_HCPCS_Code__c = 'G0001';
        cli.Proc_code__c = 'G0001';
        cli.To_Date__c = System.today();
        cli.From_date__c = System.today();
        cli.Procedure_Charge__c = 600;
        cli.Total_Adjustment__c = 100;
        cli.Amount_Paid_by_Insurance__c = 200;
        cli.Total_Allowed_Amount__c = 300;
        cli.Contracted_Amount__c = 500;
        
        return cli;
    }
    
    
    public static Provider__c createProvider(Id patientId)
    {
        Provider__c providerRec = new Provider__c();
        providerRec.Account__c = patientId;
        providerRec.Provider_Code__c  = 'Test123';
        providerRec.Name = 'TestProvider';
        
        return providerRec;
        
    }
    public static Payor__c Payorcreate(){
        Payor__c pay= new Payor__c();
        pay.Name = 'Lokesh';
        pay.ElixirSuite__Payer_Code__c ='12345';
        return pay;
    }
    public static VOB__c createVOB()
    {
        VOB__c vob = new VOB__c();
        vob.PatientFirstName__c = 'Test';
        vob.PatientLastName__c = 'Patient';
        vob.Patient_Birth_Date__c = System.today().addYears(-26);
        vob.Member_Id__c = '12345';
        vob.Payer_Name__c = 'Test Payer';
        vob.ElixirSuite__Insured_Address__c = 'ABC';
        vob.ElixirSuite__Date_Of_Birth__c =date.valueOf('2000-04-18');
        vob.ElixirSuite__Patient_Relationship_With_Insured__c ='18';
        return vob;
    }

}
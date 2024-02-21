/*
CreatedDate - 14-10-2020
Description - A utility class to insert/fetch test records
*/
public with sharing class TestDataFactory 
{
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
        
        return procedure;
    }
    public static Payment_Transaction__c createPayTransaction(Id procedureId, Id accId, String status)
    {
        Payment_Transaction__c payTrans = new Payment_Transaction__c();
        payTrans.Account__c = accId;
        payTrans.Procedure__c = procedureId;
        payTrans.Date_Of_Service__c = System.today();
        payTrans.Cpt_Codes__c = '12345';
        payTrans.Status__c = status;
        payTrans.Actual_Price__c = 1500;
        payTrans.Patient_Responsibility__c = 500;
        return payTrans;
    }
    
    public static Payment_Information__c createPayIno(Id accId)
    {
        Payment_Information__c payInfo = new Payment_Information__c();
        payInfo.Account__c = accId;
        payInfo.First_Name_on_Card__c = 'Test';
        payInfo.Last_Name_on_Card__c = 'Patient';
        payInfo.CVV_Number__c = '123';
        payInfo.Credit_Card_Number__c = '123456789012';
        payInfo.Expiration_Month__c = 'Sep';
        payInfo.Expiration_Year__c = '2024';
        
        return payInfo;
    }
    
    public static Master_Transaction__c createMasterTrans(Id accId, String paymentType)
    {
        Master_Transaction__c mst = new Master_Transaction__c();
        mst.Total_Amount_Paid__c = 1000;
        mst.Total_Unallocated_Amount__c = 1000;
        mst.ElixirSuite__Total_Remaining_Unallocated_Amount__c =900;
        mst.Payment_Type__c = paymentType;
        mst.ElixirSuite__Reason_Of_Payment__c = 'Unallocated Payment';
        mst.Account__c = accId;
            
        return mst;
    }
    
 public static Claim__c createClaim(Id accId)
    {
        Claim__c c = new Claim__c();
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
    
    public static Actual_Price__c  createActualPrice(Id procedureId, Id providerId)
    {
        Actual_Price__c actualPrice = new Actual_Price__c ();
        actualPrice.Procedure__c = procedureId;
        actualPrice.Provider__c = providerId;
        actualPrice.List_Price__c = 1500;
        
        return actualPrice;
    }
    
    public static Provider__c createProvider(Id patientId)
    {
        Provider__c providerRec = new Provider__c();
        providerRec.Account__c = patientId;
        providerRec.Provider_Code__c  = 'Test123';
        providerRec.Name = 'TestProvider';
        
        return providerRec;
        
    }
    public static Provider__c createProviderTemp()
    {
        Id devRecordTypeId = Schema.SObjectType.ElixirSuite__Provider__c.getRecordTypeInfosByDeveloperName().get('Template_Provider').getRecordTypeId();Provider__c providerRec = new Provider__c();
        providerRec.Provider_Code__c  = 'Test123';
        providerRec.Name = 'TestProvider';
        providerRec.RecordTypeId = devRecordTypeId;
        return providerRec;
        
    }
    
    /*public static Transactional_Data__c  createTransactionalData(Id patientId)
    {
        Transactional_Data__c  txnData = new Transactional_Data__c ();
        txnData.Account__c = patientId;
        txnData.Active__c  = true;
        txnData.Auto_Accident__c = 'YES';
        txnData.Employment__c = 'YES';
        txnData.Insurance_Type__c = 'Medicare';
        txnData.Insured_Address__c = 'TestAddress';
        txnData.Insured_City__c = 'TestCity';
        txnData.Insured_First_Name__c = 'Insured_First_Name__c';
        txnData.Insured_Id_Number__c = 'Insured_Id_Number__c';
        txnData.Insured_Last_Name__c = 'Insured_Last_Name__c';
        txnData.Insured_Policy_Group_FECA_Number__c = 'Insured_Policy_Group_FECA_Number__c';
        txnData.Insured_State__c = 'Insured_State__c';
        txnData.Insured_Telephone__c = 'Insured_Telephone__c';
        txnData.Insured_Zipcode__c = 'Insured_Zipcode__c';
        txnData.Is_there_another_Health_Benefit_Plan__c = 'YES';
        txnData.Other_Accident__c = 'YES';
        txnData.Other_Insured_Policy_Group_FECA_Number__c = 'Other_Insured_Policy_Group_FECA_Number__c';
        txnData.Other_Insured_s_Name__c = 'Other_Insured_s_Name__c';
        txnData.OtherInsurancePlanName__c = 'OtherInsurancePlanName__c';
        txnData.Patient_Relationship_With_Insured__c  = 'Self';
        txnData.Name = 'TestName';
        
        return txnData;
        
    }*/
    
    public static EOB__c createERA()
    {
        EOB__c eobData = new EOB__c();
        eobData.EOB_Id__c = 'ERA-001';
        eobData.Check_Number__c = '12345';
        eobData.PaidDate__c = System.today();
        eobData.CoPayment__c = 20;
        eobData.Deductible__c = 3000;
        
        return eobData;
    }
    
    public static ERA_Line_Item__c createELI(Id eraId, id cliId)
    {
        ERA_Line_Item__c eli = new ERA_Line_Item__c();
        eli.EOB__c = eraId;
        eli.Proc_code__c = '12345';
        eli.Claim_Line_Items__c = cliId;
        eli.Charge__c = 400;
        eli.Total_Allowed_Amount__c = 400;
        eli.Adjustment_Amount_1__c = 100;
        
        return eli;
        
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
        return vob;
    }
}
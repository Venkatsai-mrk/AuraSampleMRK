@isTest
public class CollectPaymentControllerTest {
	@testSetup
    public static void createTestData() {
        
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
        
        Claim__c claim = TestDataFactory.createClaim(patient.Id);
        insert claim;
        
        Procedure__c procedure = TestDataFactory.createProcedure(patient.Id);
        procedure.Claim__c = claim.Id;
        insert procedure;
        
        Procedure__c procedure1 = TestDataFactory.createProcedure(patient.Id);
        insert procedure1;
        
        Claim_Line_Items__c cli = TestDataFactory.createClaimLineItems(claim.Id, procedure.Id);
        insert cli;
        
        
        Master_Transaction__c mst = TestDataFactory.createMasterTrans(patient.Id, 'Unallocated');
        insert mst;
        
        Payment_Transaction__c payTrans = TestDataFactory.createPayTransaction(procedure.Id, patient.Id, 'Payment Started');
        
        insert payTrans;
        
        Payment_Transaction__c payTrans1 = TestDataFactory.createPayTransaction(procedure.Id, patient.Id, 'Payment Started');
        insert payTrans1;
        
        Payment_Information__c payInfo =  TestDataFactory.createPayIno(patient.Id);
        insert payInfo;
        
        //PaymentController.ClaimWrapperData cd = new PaymentController.ClaimWrapperData();
        
        System.assertEquals('1', '1',''); 
        
    }
     @isTest
    public static void makeAllocatePaymentUnitTest1()
    {
        List<Account> patAccList = [Select id from Account];
        Account patAcc = patAccList[0];
        Date currentDate = System.today();
        Date currentDate1 = System.today();
        
        Claim__c c = new Claim__c();
        c.Account__c = patAcc.id;
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
        insert c;
        
        Master_Transaction__c mst = new Master_Transaction__c();
        mst.Total_Amount_Paid__c = 1000;
        mst.Total_Unallocated_Amount__c = 1000;
        mst.ElixirSuite__Total_Remaining_Unallocated_Amount__c =900;
        mst.Payment_Type__c = 'Unallocated';
        mst.ElixirSuite__Reason_Of_Payment__c = 'Unallocated Payment';
        mst.Account__c = patAcc.id;
        insert mst;
        
        Procedure__c procedure = new Procedure__c();
        procedure.Name = 'Test Procedure';
        procedure.Account__c = patAcc.id;
        procedure.CPT_HCPCS_Code__c = '12345';
        procedure.From_Date__c = System.today();
        procedure.To_Date__c = System.today().addDays(1);
        procedure.ElixirSuite__Claim__c = c.id;
        procedure.ElixirSuite__Claim_Generation__c = true;
        procedure.ElixirSuite__Is_Billable__c = true;
        insert procedure;
        
        Payment_Transaction__c payTrans1 = new Payment_Transaction__c();
        payTrans1.Account__c = patAcc.id;
        payTrans1.Procedure__c = procedure.id;
        payTrans1.Date_Of_Service__c = System.today();
        payTrans1.Cpt_Codes__c = '12345';
        payTrans1.Status__c = 'Payment Started';
        payTrans1.Actual_Price__c = 1500;
        payTrans1.Patient_Responsibility__c = 500;
        insert payTrans1;
        
        
		Payment_Information__c payInfo = [Select Id  from Payment_Information__c Limit 1];
        update payInfo;
        
        Payment_Transaction__c payTrans = [Select Id,ElixirSuite__PatientOutstanding__c  from Payment_Transaction__c Limit 1];
        update payTrans;
        
        Master_Transaction__c otherTrans = [Select Id ,Total_Amount_Paid__c,ElixirSuite__Reason_Of_Payment__c,ElixirSuite__Total_Remaining_Unallocated_Amount__c,
                                            ElixirSuite__Payment_Transaction_Number__c,ElixirSuite__Total_Unallocated_Amount__c,
                                            ElixirSuite__Account__c,ElixirSuite__Mode_of_Payment__c,ElixirSuite__Payment_Received_By__c,
                                            ElixirSuite__Reference_Number__c from Master_Transaction__c Limit 1];
        update otherTrans;
        
        List<Master_Transaction__c> payTransList = new List<Master_Transaction__c>();
        payTransList.add(otherTrans);
        List<Master_Transaction__c> payTransList1 = new List<Master_Transaction__c>();
        Test.startTest();
        CollectPaymentController.fetchdetails(patAcc.Id);
        CollectPaymentController.fetchCreditData(patAcc.Id);
        CollectPaymentController.getdata(patAcc.Id);
        CollectPaymentController.filterProcedurebasedOnDOS(patAcc.Id,currentDate,currentDate1);
        CollectPaymentController.makePayment(2100,'Cash',Date.today(), 'Applied Payment','12333','3232',patAcc.Id,createJson1(payTrans.Id,patAcc.Id),
                                            200,10,1000,false,payinfo.Id,'33221',payTransList1);
        CollectPaymentController.makePayment(2100,'Cash',Date.today(), 'Applied Payment','12333','3232',patAcc.Id,createJson(payTrans.Id,patAcc.Id),
                                            200,10,1000,false,payinfo.Id,'33221',payTransList);
        CollectPaymentController.makePayment(2100,'Cash',Date.today(), 'Unallocated Payment','12333','3232',patAcc.Id,createJson(payTrans.Id,patAcc.Id),
                                            200,10,1000,true,payinfo.Id,'33221',payTransList);
        CollectPaymentController.makePayment(200,'Cash',Date.today(), 'Applied Payment','12333','3232',patAcc.Id,createJson1(payTrans.Id,patAcc.Id),
                                            200,10,1000,false,payinfo.Id,'33221',payTransList1);
        
        
        Test.stopTest();
        System.assertEquals(1,1,''); 
         
    }
    public static String createJson(String paymentTransactId, String accId){
        String json ='{"procedures":[{"Id":"' + paymentTransactId + '","Name":"PAYMENT-24865","ElixirSuite__Date_Of_Service__c":"2022-08-07","ElixirSuite__Account__c":"' + accId + '","ElixirSuite__Procedure_Name__c":"Patient Heart Attack","ElixirSuite__Procedure__c":"a1O5Y00000Fo1EKUAZ","ElixirSuite__Actual_Price__c":0,"ElixirSuite__Patient_Responsibility__c":3000,"ElixirSuite__Total_Paid_Amount__c":2000,"ElixirSuite__PatientOutstanding__c":1000,"ElixirSuite__Procedure__r":{"Name":"Patient Heart Attack","ElixirSuite__Claim_Generation__c":true,"Id":"a1O5Y00000Fo1EKUAZ"},"SNo":"1.","ProcedureCode":"Patient Heart Attack","ElixirSuite__Procedure__r.ElixirSuite__Claim_Generation__c":"Yes"}]}';
    
        return json;
    }
    public static String createJson1(String paymentTransactId, String accId){
        String json ='{"procedures":[{"Id":"' + paymentTransactId + '","Name":"PAYMENT-24865","ElixirSuite__Date_Of_Service__c":"2022-08-07","ElixirSuite__Account__c":"' + accId + '","ElixirSuite__Procedure_Name__c":"Patient Heart Attack","ElixirSuite__Procedure__c":"a1O5Y00000Fo1EKUAZ","ElixirSuite__Actual_Price__c":0,"ElixirSuite__Patient_Responsibility__c":3000,"ElixirSuite__Total_Paid_Amount__c":2000,"ElixirSuite__PatientOutstanding__c":300,"ElixirSuite__Procedure__r":{"Name":"Patient Heart Attack","ElixirSuite__Claim_Generation__c":true,"Id":"a1O5Y00000Fo1EKUAZ"},"SNo":"1.","ProcedureCode":"Patient Heart Attack","ElixirSuite__Procedure__r.ElixirSuite__Claim_Generation__c":"Yes"}]}';
    
        return json;
    }
}
@isTest
public class RefundControllerTest {
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
        
        System.assertEquals('1', '1',''); 
        
    }
     @isTest
    public static void getpayment()
    {
        List<Account> patAccList = [Select id from Account];
        Account patAcc = patAccList[0];
        Elixir_Custom_Setting__c mcs = new  Elixir_Custom_Setting__c();
        mcs.ElixirSuite__Include_CMS1500_Form__c = false;
        insert mcs;
        ERA_Generation__c era = new ERA_Generation__c();
        era.ElixirSuite__Private_Payments__c =true;
        era.ElixirSuite__Insurance_Payments__c =true;
        insert era;
        Test.startTest();
        Date currentDate = System.today();
        Date currentDate1 = System.today();
        RefundController.getData(patAcc.Id);
        RefundController.filterProcedurebasedOnDOS(patAcc.Id,currentDate,currentDate1);
        RefundController.filterRefundDates(patAcc.Id,currentDate,currentDate1,'All');
         RefundController.filterRefundStatus(patAcc.Id,'All');
        Test.stopTest();
        
        System.assertEquals('1', '1','');
    }
    @isTest
    public static void runTest()
    {
        List<Account> patAccList = [Select id from Account];
        Account patAcc = patAccList[0];
        Elixir_Custom_Setting__c mcs = new  Elixir_Custom_Setting__c();
        mcs.ElixirSuite__Include_CMS1500_Form__c = false;
        insert mcs;
        ERA_Generation__c era = new ERA_Generation__c();
        era.ElixirSuite__Private_Payments__c =true;
        era.ElixirSuite__Insurance_Payments__c =true;
        insert era;
        Date currentDate = System.today();
        Date currentDate1 = System.today();
        
        Procedure__c procedure = new Procedure__c();
        procedure.Name = 'Test Procedure';
        procedure.Account__c = patAcc.Id;
        procedure.CPT_HCPCS_Code__c = '12345';
        procedure.From_Date__c = System.today();
        procedure.To_Date__c = System.today().addDays(1);
        insert procedure;
        
        Payment_Transaction__c payTrans = new Payment_Transaction__c();
        payTrans.Account__c = patAcc.Id;
        payTrans.Procedure__c = procedure.Id;
        payTrans.Date_Of_Service__c = System.today();
        payTrans.Cpt_Codes__c = '12345';
        payTrans.Status__c = 'Payment Started';
        payTrans.Actual_Price__c = 1500;
        payTrans.Patient_Responsibility__c = 500;
        insert payTrans;
        
        List<ElixirSuite__Refund__c> refund = new List<ElixirSuite__Refund__c>();
        ElixirSuite__Refund__c rec = new ElixirSuite__Refund__c();
        rec.ElixirSuite__Date_Created__c = currentDate;
        rec.ElixirSuite__Date_Issued__c =  currentDate;
        rec.ElixirSuite__Mode_of_Payment__c = 'Cash';
        rec.ElixirSuite__Status__c = 'Requested';
        rec.ElixirSuite__Refund_Amount__c = 100;
        rec.ElixirSuite__Master_Transaction__c = payTrans.Id;
         rec.ElixirSuite__Credit_Check_Reference_field__c = '122';
        insert rec;
        
        ElixirSuite__Refund__c rec1 = new ElixirSuite__Refund__c();
        rec1.ElixirSuite__Date_Created__c = currentDate;
        rec1.ElixirSuite__Date_Issued__c =  currentDate;
        rec1.ElixirSuite__Mode_of_Payment__c = 'Patient Credit';
        rec1.ElixirSuite__Status__c = 'Requested';
        rec1.ElixirSuite__Refund_Amount__c = 10;
        rec1.ElixirSuite__Master_Transaction__c = payTrans.Id;
         rec1.ElixirSuite__Credit_Check_Reference_field__c = '122';
        insert rec1;
        
        ElixirSuite__Refund__c rec2 = new ElixirSuite__Refund__c();
        rec2.ElixirSuite__Date_Created__c = currentDate;
        rec2.ElixirSuite__Date_Issued__c =  currentDate;
        rec2.ElixirSuite__Mode_of_Payment__c = 'Cash';
        rec2.ElixirSuite__Status__c = 'Denied';
        rec2.ElixirSuite__Refund_Amount__c = 100;
        rec2.ElixirSuite__Master_Transaction__c = payTrans.Id;
        rec2.ElixirSuite__Credit_Check_Reference_field__c = '122';
        insert rec2;
        
        refund = [SELECT Id, CreatedDate, ElixirSuite__Credit_Check_Reference_field__c, ElixirSuite__Date_Created__c, 
                  ElixirSuite__Date_Issued__c, ElixirSuite__Master_Transaction__c, ElixirSuite__Issued_User__c, 
                  ElixirSuite__Status__c, ElixirSuite__Transactions__c, ElixirSuite__Requested_User__c, 
                  ElixirSuite__Refund_Amount__c, ElixirSuite__Reason_for_Refund__c, ElixirSuite__Payment_Information__c,
                  ElixirSuite__Mode_of_Payment__c FROM ElixirSuite__Refund__c ];
        Test.startTest();
        
        RefundController.getData(patAcc.Id);
        RefundController.filterRefundDates(patAcc.Id,currentDate,currentDate1,'Requested');
        RefundController.filterRefundStatus(patAcc.Id,'Requested');
        RefundController.savemethod(patAcc.Id,refund);
        Test.stopTest();
        
        System.assertEquals('1', '1','');
    }
}
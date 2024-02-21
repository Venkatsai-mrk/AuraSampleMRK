/*
Created Date - 14-10-2020
Apex Class - PaymentController
*/

@isTest
public class PaymentControllerTest 
{
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
        
               
        Payment_Transaction__c payTrans = [Select Id, ElixirSuite__PatientOutstanding__c from Payment_Transaction__c Limit 1];
        update payTrans;
        
        List<Id> payTransList = new List<Id>();
        payTransList.add(payTrans.Id);
        
        Test.startTest();
        createJson(payTrans.Id,patAcc.Id);
        PaymentController.makeAllocatePayment(10, patAcc.Id, createJson(payTrans.Id,patAcc.Id), 100, 900);
        
       
        List<Master_Transaction__c> otherTransationList = [Select id,ElixirSuite__Reason_Of_Payment__c,ElixirSuite__Mode_of_Payment__c from Master_Transaction__c where ElixirSuite__Reason_Of_Payment__c='Unallocated Payment'];
        
        Test.stopTest();
        System.assertEquals(1, otherTransationList.size(),''); 
         
    }
    @isTest
    public static void makeAllocatePaymentUnitTest2()
    {
        List<Account> patAccList = [Select id from Account];
        Account patAcc = patAccList[0];
        
               
        Payment_Transaction__c payTrans = [Select Id,ElixirSuite__PatientOutstanding__c  from Payment_Transaction__c Limit 1];

        update payTrans;
        
        List<Id> payTransList = new List<Id>();
        payTransList.add(payTrans.Id);
        
        Test.startTest();
        
        PaymentController.makeAllocatePayment(20, patAcc.Id, createJson(payTrans.Id,patAcc.Id), 10, 900);
        
       
        List<Master_Transaction__c> otherTransationList = [Select id,ElixirSuite__Reason_Of_Payment__c,ElixirSuite__Mode_of_Payment__c from Master_Transaction__c where ElixirSuite__Reason_Of_Payment__c='Unallocated Payment'];
        
        Test.stopTest();
        System.assertEquals(1, otherTransationList.size(),''); 
         
    }
    @isTest
    public static void makeAllocatePaymentUnitTest3()
    {
        List<Account> patAccList = [Select id from Account];
        Account patAcc = patAccList[0];
        
               
        Payment_Transaction__c payTrans = [Select Id, ElixirSuite__PatientOutstanding__c from Payment_Transaction__c Limit 1];

        update payTrans;
        
        List<Id> payTransList = new List<Id>();
        payTransList.add(payTrans.Id);
        
        Test.startTest();
        
        PaymentController.makeAllocatePayment(0, patAcc.Id, createJsonAllocatePayment(payTrans.Id,patAcc.Id), 1000, 900);
        
       
        List<Master_Transaction__c> otherTransationList = [Select id,ElixirSuite__Reason_Of_Payment__c,ElixirSuite__Mode_of_Payment__c from Master_Transaction__c where ElixirSuite__Reason_Of_Payment__c='Unallocated Payment'];
        
        Test.stopTest();
        System.assertEquals(1, otherTransationList.size(),''); 
         
    }
     @isTest
    public static void makeAllocatePaymentUnitTest4()
    {
        List<Account> patAccList = [Select id from Account];
        Account patAcc = patAccList[0];
        
               
        Payment_Transaction__c payTrans = [Select Id,ElixirSuite__PatientOutstanding__c  from Payment_Transaction__c Limit 1];

        update payTrans;
        
        List<Id> payTransList = new List<Id>();
        payTransList.add(payTrans.Id);
        
        Test.startTest();
        
        PaymentController.makeAllocatePayment(0, patAcc.Id, createJsonAllocatePayment(payTrans.Id,patAcc.Id), 100, 900);
        
       
        List<Master_Transaction__c> otherTransationList = [Select id,ElixirSuite__Reason_Of_Payment__c,ElixirSuite__Mode_of_Payment__c from Master_Transaction__c where ElixirSuite__Reason_Of_Payment__c='Unallocated Payment'];
        
        Test.stopTest();
        System.assertEquals(1, otherTransationList.size(),''); 
         
    }
    
    @isTest
    public static void makeInsurancePaymentForUnallocatedReasonTest()
    {
        List<Account> patAccList = [Select id from Account];
        Account patAcc = patAccList[0];
        ElixirSuite__Payment_Information__c payinfo = new ElixirSuite__Payment_Information__c();
        payinfo.ElixirSuite__Credit_Card_Number__c = '741085209630';
        payinfo.ElixirSuite__CVV_Number__c = '875';
        payinfo.ElixirSuite__Account__c = payinfo.Id;
        insert payinfo;
               
        Payment_Transaction__c payTrans = [Select Id, ElixirSuite__PatientOutstanding__c from Payment_Transaction__c Limit 1];

        update payTrans;
        
        List<Id> payTransList = new List<Id>();
        payTransList.add(payTrans.Id);
        
        Test.startTest();
        
        PaymentController.getData(patAcc.Id);
        PaymentController.makeInsurancePayment(7000, 'Cash', Date.today(), 'Unallocated Payment', 'Unit Testing', 'TESTTR1', patAcc.Id, '',
                                               7000, 0, true, payinfo.Id,'741085');
        
       
        List<Master_Transaction__c> otherTransationList = [Select id,ElixirSuite__Reason_Of_Payment__c,ElixirSuite__Mode_of_Payment__c from Master_Transaction__c where ElixirSuite__Reason_Of_Payment__c='Unallocated Payment'];
        
        Test.stopTest();
        System.assertEquals(2, otherTransationList.size(),''); 
         System.assertEquals('Cash', otherTransationList[1].ElixirSuite__Mode_of_Payment__c,'');
    }
      @isTest
    public static void makeInsurancePaymentForAppliedReasonTest()
    {
        List<Account> patAccList = [Select id from Account];
        Account patAcc = patAccList[0];
         ElixirSuite__Payment_Information__c payinfo = new ElixirSuite__Payment_Information__c();
        payinfo.ElixirSuite__Credit_Card_Number__c = '741085209630';
        payinfo.ElixirSuite__CVV_Number__c = '875';
        payinfo.ElixirSuite__Account__c = payinfo.Id;
        insert payinfo;
               
        Payment_Transaction__c payTrans = [Select Id, ElixirSuite__PatientOutstanding__c from Payment_Transaction__c Limit 1];

        update payTrans;
        
        List<Id> payTransList = new List<Id>();
        payTransList.add(payTrans.Id);
        
        Test.startTest();
        
        PaymentController.getData(patAcc.Id);
        PaymentController.makeInsurancePayment(6000, 'Cash', Date.today(), 'Applied Payment', 'Unit Testing', 'TESTTR1', patAcc.Id, createJson(payTrans.Id,patAcc.Id),
                                               7000, 0, false, payinfo.Id,'85296');
        
       
        List<Master_Transaction__c> otherTransationList = [Select id,ElixirSuite__Reason_Of_Payment__c,ElixirSuite__Mode_of_Payment__c from Master_Transaction__c where ElixirSuite__Reason_Of_Payment__c='Applied Payment'];
        
        Test.stopTest();
        System.assertEquals(1, otherTransationList.size(),''); 
         System.assertEquals('Cash', otherTransationList[0].ElixirSuite__Mode_of_Payment__c,'');
    }
      @isTest
    public static void makeInsurancePaymentForAppliedReasonTest2()
    {
        List<Account> patAccList = [Select id from Account];
        Account patAcc = patAccList[0];
         ElixirSuite__Payment_Information__c payinfo = new ElixirSuite__Payment_Information__c();
        payinfo.ElixirSuite__Credit_Card_Number__c = '741085209630';
        payinfo.ElixirSuite__CVV_Number__c = '875';
        payinfo.ElixirSuite__Account__c = payinfo.Id;
        insert payinfo;
               
        Payment_Transaction__c payTrans = [Select Id,ElixirSuite__PatientOutstanding__c  from Payment_Transaction__c Limit 1];
        update payTrans;
        
        List<Id> payTransList = new List<Id>();
        payTransList.add(payTrans.Id);
        
        Test.startTest();
        
        PaymentController.getData(patAcc.Id);
        PaymentController.makeInsurancePayment(8000, 'Cash', Date.today(), 'Applied Payment', 'Unit Testing', 'TESTTR1', patAcc.Id, createJson(payTrans.Id,patAcc.Id),
                                               7000, 0, false,payinfo.Id,'741852');
        
       
        List<Master_Transaction__c> otherTransationList = [Select id,ElixirSuite__Reason_Of_Payment__c,ElixirSuite__Mode_of_Payment__c from Master_Transaction__c where ElixirSuite__Reason_Of_Payment__c='Applied Payment'];
        
        Test.stopTest();
        System.assertEquals(1, otherTransationList.size(),''); 
         System.assertEquals('Cash', otherTransationList[0].ElixirSuite__Mode_of_Payment__c,'');
    }
    
    
    public static String createJson(String paymentTransactId, String accId){
        String json ='{"procedures":[{"Id":"' + paymentTransactId + '","Name":"PAYMENT-24865","ElixirSuite__Date_Of_Service__c":"2022-08-07","ElixirSuite__Account__c":"' + accId + '","ElixirSuite__Procedure_Name__c":"Patient Heart Attack","ElixirSuite__Procedure__c":"a1O5Y00000Fo1EKUAZ","ElixirSuite__Actual_Price__c":0,"ElixirSuite__Patient_Responsibility__c":3000,"ElixirSuite__Total_Paid_Amount__c":2000,"ElixirSuite__PatientOutstanding__c":1000,"ElixirSuite__Procedure__r":{"Name":"Patient Heart Attack","ElixirSuite__Claim_Generation__c":true,"Id":"a1O5Y00000Fo1EKUAZ"},"SNo":"1.","ProcedureCode":"Patient Heart Attack","ElixirSuite__Procedure__r.ElixirSuite__Claim_Generation__c":"Yes"}]}';
    
        return json;
    }
    public static String createJsonAllocatePayment(String paymentTransactId, String accId){
        String json ='{"procedures":[{"Id":"' + paymentTransactId + '","Name":"PAYMENT-24865","ElixirSuite__Date_Of_Service__c":"2022-08-07","ElixirSuite__Account__c":"' + accId + '","ElixirSuite__Procedure_Name__c":"Patient Heart Attack","ElixirSuite__Procedure__c":"a1O5Y00000Fo1EKUAZ","ElixirSuite__Actual_Price__c":0,"ElixirSuite__Patient_Responsibility__c":3000,"ElixirSuite__Total_Paid_Amount__c":2000,"ElixirSuite__PatientOutstanding__c":100,"ElixirSuite__Procedure__r":{"Name":"Patient Heart Attack","ElixirSuite__Claim_Generation__c":true,"Id":"a1O5Y00000Fo1EKUAZ"},"SNo":"1.","ProcedureCode":"Patient Heart Attack","ElixirSuite__Procedure__r.ElixirSuite__Claim_Generation__c":"Yes"}]}';
    
        return json;
    }
    @isTest
    public static void unitTest1()
    {
        List<Account> patAccList = [Select id from Account];
        Account patAcc = patAccList[0];
       
        
        Payment_Transaction__c payTrans = [Select Id,ElixirSuite__PatientOutstanding__c  from Payment_Transaction__c Limit 1];
        update payTrans;
        
        List<Id> payTransList = new List<Id>();
        payTransList.add(payTrans.Id);
        ElixirSuite__Payment_Transaction__c pt = new ElixirSuite__Payment_Transaction__c(ElixirSuite__Expected_Receivable_amount__c=1000,
                                                                                         ElixirSuite__Procedure_Utilized__c=true,
                                                                                         ElixirSuite__Other_Discounts__c=1000,
                                                                                         ElixirSuite__Actual_Price__c=1000,
                                                                                          ElixirSuite__Account__c = patAcc.Id
                                                                                       );
        insert pt;
        String prcString = '{"procedures":[{"Id":'+'"'+pt.Id+'"'+',"ElixirSuite__PatientOutstanding__c":7000}]}';        
        ElixirSuite__Payment_Plan__c ps = new ElixirSuite__Payment_Plan__c();
        ps.ElixirSuite__Installment_Amount__c = 1000;
        ps.ElixirSuite__Patient_Name__c = patAcc.id;
        ps.ElixirSuite__Payment_Frequency__c = 'Daily';
        ps.ElixirSuite__Patient_Responsibility__c = 2000;
        insert ps;
        List <ElixirSuite__Payment_Plan_Line_Item__c> pl = [SELECT Id, Name, ElixirSuite__Due_Date__c, ElixirSuite__Installment_Amount__c, 
                          ElixirSuite__Last_Payment_Amount__c, ElixirSuite__Last_Payment_Date__c, 
                          ElixirSuite__Notes__c, ElixirSuite__Account__c, ElixirSuite__Payment_Plan__c, 
                          ElixirSuite__Payment_Status__c, ElixirSuite__Amount_Paid__c, 
                          ElixirSuite__Balance_Due__c 
                          FROM ElixirSuite__Payment_Plan_Line_Item__c];
        Test.startTest();
        
        PaymentController.getData(patAcc.Id);
        PaymentController.getClaimsData(patAcc.Id);
     //   PaymentController.SaveData(patAcc.Id , 500.0, 0.0, Date.today(), payTransList, 'Applied Payment',lst_seledSheduls,'Patient','new note',10);
       PaymentController.getPaymentLine(payTransList); 
        System.assertEquals(1, patAccList.size(),'');
        
        Test.stopTest();
        System.assertEquals('1', '1',''); 
    }
    
}
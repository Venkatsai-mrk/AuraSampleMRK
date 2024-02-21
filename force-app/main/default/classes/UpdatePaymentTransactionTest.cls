@isTest
public class UpdatePaymentTransactionTest {

    @testSetup
    public static void createTestData() {
        
        Account patient = TestDataFactory.createPatientAcc();
        patient.Unallocated_Amount__c =0;
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
        
    }
    
    @isTest
    public static void unitTest1() {
        
        Payment_Transaction__c payTrans = [Select id,ElixirSuite__PatientOutstanding__c from Payment_Transaction__c LIMIT 1];

        update payTrans; 
        
        List<Account> patAccList = [Select id from Account];
        Account patAcc = patAccList[0];
        
        List<Id> txnIdList = new List<Id>();
        txnIdList.add(payTrans.id);
        
        Estimates__c estimateRec = new Estimates__c();
        estimateRec.Account__c = patAcc.Id;
        insert estimateRec;
        
        test.startTest();
        UpdatePaymentTransaction.updateTxn(patAcc.Id, 5000, 100, Date.today(), txnIdList);
        System.assertEquals(1, patAccList.size(),'');
        test.stopTest();
    }
    
    @isTest
    public static void unitTest2() {
        
        Payment_Transaction__c payTrans = [Select id, ElixirSuite__PatientOutstanding__c from Payment_Transaction__c LIMIT 1];

        update payTrans; 
        
        List<Account> patAccList = [Select id from Account];
        Account patAcc = patAccList[0];
        
        List<Id> txnIdList = new List<Id>();
        txnIdList.add(payTrans.id);
        
        Estimates__c estimateRec = new Estimates__c();
        estimateRec.Account__c = patAcc.Id;
        insert estimateRec;
        
        test.startTest();
        UpdatePaymentTransaction.updateTxn(patAcc.Id, 200, 100, Date.today(), txnIdList);
        System.assertEquals(1, patAccList.size(),'');
        test.stopTest();
    }
    
    @isTest
    public static void unitTest3() {
        
        Payment_Transaction__c payTrans = [Select id, ElixirSuite__PatientOutstanding__c from Payment_Transaction__c LIMIT 1];

        update payTrans; 
        
        List<Account> patAccList = [Select id from Account];
        Account patAcc = patAccList[0];
        
        List<Id> txnIdList = new List<Id>();
        //txnIdList.add(payTrans.id);
        
        Estimates__c estimateRec = new Estimates__c();
        estimateRec.Account__c = patAcc.Id;
        insert estimateRec;
        
        test.startTest();
        UpdatePaymentTransaction.updateTxn(patAcc.Id, 200, 100, Date.today(), txnIdList);
        System.assertEquals(1, patAccList.size(),'');
        test.stopTest();
    }
    
    @isTest
    public static void unitTest4() {
        
        Payment_Transaction__c payTrans = [Select id,ElixirSuite__PatientOutstanding__c from Payment_Transaction__c LIMIT 1];

        update payTrans; 
        
        List<Account> patAccList = [Select id from Account];
        Account patAcc = patAccList[0];
        
        List<Id> txnIdList = new List<Id>();
        txnIdList.add(payTrans.id);
        
        Estimates__c estimateRec = new Estimates__c();
        estimateRec.Account__c = patAcc.Id;
        insert estimateRec;
        
        test.startTest();
        UpdatePaymentTransaction.updateTxn(patAcc.Id, 0, 100, Date.today(), txnIdList);
        System.assertEquals(1, patAccList.size(),'');
        test.stopTest();
    }
}
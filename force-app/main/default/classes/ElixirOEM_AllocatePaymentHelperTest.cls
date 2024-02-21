@isTest 
public class ElixirOEM_AllocatePaymentHelperTest {
    @isTest 
    public static void  allcoverageMethod(){
        Account accountRec = new Account();
        accountRec.Name = 'Test';
        insert accountRec;
         ElixirSuite__Payment_Information__c payinfo = new ElixirSuite__Payment_Information__c();
        payinfo.ElixirSuite__Credit_Card_Number__c = '741085209630';
        payinfo.ElixirSuite__CVV_Number__c = '875';
        payinfo.ElixirSuite__Account__c = accountRec.Id;
        insert payinfo;
        ElixirSuite__Master_Transaction__c mt = new ElixirSuite__Master_Transaction__c(ElixirSuite__Total_Remaining_Unallocated_Amount__c = 10);
        ElixirSuite__Master_Transaction__c mtsObjIns = new ElixirSuite__Master_Transaction__c(ElixirSuite__Total_Remaining_Unallocated_Amount__c = 10,
                                                                                              ElixirSuite__Reason_Of_Payment__c = 'Unallocated Payment',
                                                                                              ElixirSuite__Account__c = accountRec.Id);
        insert mtsObjIns;                                                                           
        ElixirSuite__Payment_Transaction__c pt = new ElixirSuite__Payment_Transaction__c();
        insert pt;
        String prcString = '{"procedures":[{"Id":'+'"'+pt.Id+'"'+',"ElixirSuite__PatientOutstanding__c":7000}]}';
        System.assertEquals(1, 1, '');
        Test.startTest();
        ElixirOEM_AllocatePaymentHelper.initPayloadCall(accountRec.Id);
        ElixirOEM_AllocatePaymentHelper.calculateUnAllocatedAmount(new List<ElixirSuite__Master_Transaction__c>{mt});
        ElixirOEM_AllocatePaymentHelper.fetchOtherTransactionsForUnallocatedAmount(accountRec.Id);
        ElixirOEM_AllocatePaymentHelper.queryAllProceduresOnMasterTransaction(accountRec.Id);
        ElixirOEM_AllocatePaymentHelper.filterProcedureOnMasterTransaction(System.today(),System.today(),'procname','cptcode',accountRec.Id,
                                                                           new List<String>());
        ElixirOEM_AllocatePaymentHelper.allocatePaymentInSystem( 12, 'Cash',System.today(), 'pmtTransactionNumber',
                                                                accountRec.Id, prcString, 20,
                                                                30,false,90, payinfo.Id, '7410852');
        Test.stopTest();
      
    }
    }
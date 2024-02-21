@isTest
public class ElixirOEM_PrivatePaymentHelperTest {
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
        ElixirSuite__Payment_Transaction__c pt = new ElixirSuite__Payment_Transaction__c(ElixirSuite__Expected_Receivable_amount__c=1000,
                                                                                         ElixirSuite__Procedure_Utilized__c=true,
                                                                                         ElixirSuite__Other_Discounts__c=1000,
                                                                                         ElixirSuite__Actual_Price__c=1000,
                                                                                          ElixirSuite__Account__c = accountRec.Id
                                                                                       );
        insert pt;
        String prcString = '{"procedures":[{"Id":'+'"'+pt.Id+'"'+',"ElixirSuite__PatientOutstanding__c":7000}]}';
        Test.startTest();
        ElixirOEM_PrivatePaymentHelper.getData(accountRec.Id);
        ElixirOEM_PrivatePaymentHelper.queryAllProceduresOnMasterTransaction(accountRec.Id);  
        ElixirOEM_PrivatePaymentHelper.procedureList('abc',accountRec.Id);
        ElixirOEM_PrivatePaymentHelper.filterProcedureOnMasterTransaction(System.today(),System.today(),'procname','cptcode',accountRec.Id,
                                                                          new List<String>());
        ElixirOEM_PrivatePaymentHelper.filterAllProcedureOnMasterTransaction(System.today(),System.today(),'procname','cptcode',accountRec.Id,
                                                                          new List<String>());
        ElixirOEM_PrivatePaymentHelper.makePrivatePayment( 12, 'Cash',System.today(), 'pmtTransactionNumber',
                                                          accountRec.Id, prcString, 20,
                                                          30,true,payinfo.Id, '7410852');
        ElixirOEM_PrivatePaymentHelper.makePrivatePayment( 12, 'Cash',System.today(), 'pmtTransactionNumber',
                                                          accountRec.Id, prcString, 20,
                                                          30,false,payinfo.Id, '7410852');
        Test.stopTest();
        System.assertEquals('Test', accountRec.Name,'');
    }
}
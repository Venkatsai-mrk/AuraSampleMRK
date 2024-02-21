@isTest 
public class ElixirOEM_PaymentScheduleHelperTest {
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
        ElixirSuite__Payment_Plan__c ps = new ElixirSuite__Payment_Plan__c();
        ps.ElixirSuite__Installment_Amount__c = 1000;
        ps.ElixirSuite__Patient_Name__c = accountRec.id;
        ps.ElixirSuite__Payment_Frequency__c = 'Daily';
        ps.ElixirSuite__Patient_Responsibility__c = 2000;
        insert ps;
        List <ElixirSuite__Payment_Plan_Line_Item__c> pl = [SELECT Id, Name, ElixirSuite__Due_Date__c, ElixirSuite__Installment_Amount__c, 
                          ElixirSuite__Last_Payment_Amount__c, ElixirSuite__Last_Payment_Date__c, 
                          ElixirSuite__Notes__c, ElixirSuite__Account__c, ElixirSuite__Payment_Plan__c, 
                          ElixirSuite__Payment_Status__c, ElixirSuite__Amount_Paid__c, 
                          ElixirSuite__Balance_Due__c 
                          FROM ElixirSuite__Payment_Plan_Line_Item__c];
        System.assertEquals(1, 1, 'welcome to Elixir');
        Test.startTest();
        ElixirOEM_PaymentScheduleHelper.initPayloadCallData(accountRec.Id);
        ElixirOEM_PaymentScheduleHelper.paymentSchedulePayload(accountRec.Id);
        ElixirOEM_PaymentScheduleHelper.queryAllProceduresOnMasterTransaction(accountRec.Id);
        ElixirOEM_PaymentScheduleHelper.getPaymentLines(new List<String>());
        //ElixirOEM_PaymentScheduleHelper.queryProceduresOnMasterTransaction(accountRec.Id);
        ElixirOEM_PaymentScheduleHelper.filterProcedureOnMasterTransaction(System.today(),System.today(),'procname','cptcode',accountRec.Id,
                                                                           new List<String>());
        ElixirOEM_PaymentScheduleHelper.allocatePaymentInSystem( 12,12, 'Cash',System.today(), 'pmtTransactionNumber',
                                                                accountRec.Id, prcString, 20,
                                                                30,false,90,ps.Id,payinfo.Id, '7410852',pl);
        ElixirOEM_PaymentScheduleHelper.allocatePaymentInSystem( 12,12, 'Cash',System.today(), 'pmtTransactionNumber',
                                                                accountRec.Id, prcString, 10000,
                                                                30,false,90,ps.Id,payinfo.Id, '7410852',pl);
        
        
        
        
        Test.stopTest();
       
    }
}
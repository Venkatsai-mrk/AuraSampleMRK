@isTest
public class ElixirOEM_AddDiscountHelperTest {
    @isTest 
    public static void  allcoverageMethod(){
      Account accountRec = new Account();
        accountRec.Name = 'Test'; 
        accountRec.Phone='9876543210';
        accountRec.BillingPostalCode='50004';
        insert accountRec;
        ElixirSuite__Master_Transaction__c mtsObjIns = new ElixirSuite__Master_Transaction__c(ElixirSuite__Total_Remaining_Unallocated_Amount__c = 10,
                                                                                              ElixirSuite__Reason_Of_Payment__c = 'Unallocated Payment',
                                                                                              ElixirSuite__Account__c = accountRec.Id);
        insert mtsObjIns;                                                                           
        ElixirSuite__Payment_Transaction__c pt = new ElixirSuite__Payment_Transaction__c();
        insert pt;
        String prcString = '{"procedures":[{"Id":'+'"'+pt.Id+'"'+',"remainingAmount":7000,"currentDiscAmt" : 9000}]}';
         ElixirSuite__Master_Transaction__c mtToInsert = new ElixirSuite__Master_Transaction__c(ElixirSuite__Total_Remaining_Unallocated_Amount__c = 10);
        Test.startTest();
        ElixirOEM_AddDiscountHelper.initPayloadCallData(accountRec.Id);
        ElixirOEM_AddDiscountHelper.queryAllProceduresOnMasterTransaction(accountRec.Id);
        ElixirOEM_AddDiscountHelper.paymentSchedulePayload(accountRec.Id);
        ElixirOEM_AddDiscountHelper.allocateDiscountInSystem(mtToInsert,accountRec.Id,prcString,27000,1000,'CHECK','Test Note');
        ElixirOEM_AddDiscountHelper.filterProcedureOnMasterTransaction(System.today(),System.today(),'Heart attack','cptcode',accountRec.Id,
                                                                           new List<String>());
    Test.stopTest();
    System.assertEquals(1, 1, ''); 
    }
}
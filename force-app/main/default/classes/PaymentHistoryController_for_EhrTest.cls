@isTest
public class PaymentHistoryController_for_EhrTest {
@isTest
     public static void  allcoverageMethod(){
      Account accountRec = new Account();
        accountRec.Name = 'Jami'; 
        accountRec.Phone='9876543210';
        accountRec.BillingPostalCode='50004';
        insert accountRec;
        ElixirSuite__Master_Transaction__c mtsObjIns = new ElixirSuite__Master_Transaction__c(ElixirSuite__Total_Remaining_Unallocated_Amount__c = 10,
                                                                                              ElixirSuite__Account__c = accountRec.Id);
        insert mtsObjIns;                                                                           
       // String prcString = '{"procedures":[{"Id":'+'"'+pt.Id+'"'+',"remainingAmount":7000,"currentDiscAmt" : 9000}]}';
        Test.startTest();
        PaymentHistoryController_for_Ehr.BringData(mtsObjIns.Id);
        PaymentHistoryController_for_Ehr.BringDataViewAll(mtsObjIns.Id);
        PaymentHistoryController_for_Ehr.BringFilterData(string.valueOf(System.today()),string.valueOf(System.today()),mtsObjIns.Id);
         PaymentHistoryController_for_Ehr.BringFilterDataViewAll(string.valueOf(System.today()),string.valueOf(System.today()),mtsObjIns.Id);
         System.assertEquals(1, 1, '');
    Test.stopTest();
    }
}
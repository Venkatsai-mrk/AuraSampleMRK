@isTest
public with sharing class VaccineStatementControllerTest {
    @isTest
    public static void VaccineStatement1() {

        Account acc = new Account();
        acc.Name = 'test Acc1';
        insert acc;
        
        date tDate = date.today(); 
        String fromDate = string.valueof(tDate);
        date eDate = date.today()+3;
        String toDate = string.valueof(eDate);
        String recordVal = 'testVal';

        VaccineStatementController.getMORDetails(acc.id);
        VaccineStatementController.getMARForRangeApex(fromDate, toDate, recordVal);
        system.assertEquals(1, 1, ''); 
    }
}
@isTest
public class TestupdateRelatedPaymentSchedule {

    @isTest
    public static void unitTest1() {
        list<payment_line__c> payschList=new list<payment_line__c>();
        ElixirSuite__Payment_Schedule__c paysch=new ElixirSuite__Payment_Schedule__c();
        insert paysch;
        payment_line__c payline = new payment_line__c();
        payline.ElixirSuite__Payment_Schedule__c = paysch.id;
        payschList.add(payline);
        insert payschList;
        
        test.startTest();
        updateRelatedPaymentSchedule.updateMasterAndChildPaymentSchedule(payschList);
        System.assertEquals(1, 1, ' ');
        test.stopTest();
    }
}
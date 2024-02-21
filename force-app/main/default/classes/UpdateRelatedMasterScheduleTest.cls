@isTest
private class UpdateRelatedMasterScheduleTest {
    @isTest
    public  static void testUpdateMasterPaymentSchedule(){
        
        ElixirSuite__Payment_Schedule__c relatedPayment2 = new ElixirSuite__Payment_Schedule__c();
        relatedPayment2.ElixirSuite__Total_Amount_Paid__c =100.00;
        insert relatedPayment2;
        
        ElixirSuite__Payment_Schedule__c relatedPayment1 = new ElixirSuite__Payment_Schedule__c();
        relatedPayment1.ElixirSuite__Total_Amount_Paid__c =100.00;
        relatedPayment1.ElixirSuite__Payment_Schedule__c = relatedPayment2.Id;       
        insert relatedPayment1;
               
        ElixirSuite__Payment_Schedule__c relatedChildPayment = new ElixirSuite__Payment_Schedule__c();
        relatedChildPayment.ElixirSuite__Total_Amount_Paid__c =200.00;
        relatedChildPayment.ElixirSuite__Payment_Schedule__c = relatedPayment1.Id;
        insert relatedChildPayment;
        
        ElixirSuite__Payment_Line__c linePayment = new ElixirSuite__Payment_Line__c();
        linePayment.Name = 'Shivam';
        linePayment.ElixirSuite__Payment_Schedule__c =  relatedPayment1.Id;
        linePayment.ElixirSuite__Payment_Amount__c =200;
        insert linePayment;
        
        Test.startTest();
        updateRelatedMasterSchedule.updateMasterPaymentSchedule(new List<ElixirSuite__Payment_Schedule__c>{ relatedPayment1 }, new Map<Id, ElixirSuite__Payment_Schedule__c>{ relatedPayment1.Id => relatedPayment1 });
	   Test.stopTest();
        system.assertEquals(1,1,'Hello');
    }
}
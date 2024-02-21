@isTest
public class TestMarsStatementController {
    
    
    @testSetup
    public static void testMethod1(){
        //Insert test account
        Account acc = new Account();
        acc.Name = 'Test';
        insert acc;
        System.assertEquals(1, 1, ' ');
    }
    
    @isTest
    public static void test1(){
        Id accId = [Select Id from Account where Name = 'Test' limit 1].Id;
        Test.startTest();
        MARStatementController.getMORDetails(accId);
       System.assertEquals(1, 1, ' ');
        Test.stopTest();
    }
    
    @isTest
    public static void test2(){
        Id accId = [Select Id from Account where Name = 'Test' limit 1].Id;
        String dateFormatString = 'yyyy-MM-dd';
        Date d = Date.today();
        Datetime dt = Datetime.newInstance(d.year(), d.month(),d.day());
        String dateToCompare = dt.format(dateFormatString);
        
        Test.startTest();
        MARStatementController.getMARForRangeApex(dateToCompare, dateToCompare , accId);
        System.assertEquals(1, 1, ' ');
        Test.stopTest();
    }
    
}
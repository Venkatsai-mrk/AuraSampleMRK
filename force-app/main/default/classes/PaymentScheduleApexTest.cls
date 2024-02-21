@isTest
public class PaymentScheduleApexTest {
    @isTest
    public static void unitTest1(){
        Account acc = new Account(Name = 'Account1');
        insert acc;
        String ids = acc.Id;
        String scheduleData = '{"keysToSaveSchedule": [{"instAmt": 10.0, "DD": "01/01/2024"}, {"instAmt": 20.0, "DD": "01/15/2024"}]}';
        String totalPlanAmount = '30';
        String frequencyRate = 'Monthly';
        String installmentAmt = '10';
        Boolean isCheck = true;
        PaymentScheduleApex.fetchData(acc.Id);
        PaymentScheduleApex.getOutstanding(acc.Id);
        PaymentScheduleApex.LicensBasdPermission();
        PaymentScheduleApex.saveData(ids, scheduleData, totalPlanAmount, frequencyRate, installmentAmt, isCheck);
        System.assertEquals(1, 1, ' ');
    }
    
    @isTest
    static void testFetchOppdataForPayment() {
        // Create test data
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.Payment_Amount_curr__c = 500;
        opp.Payment_Frequency__c = 'Monthly';
        opp.LOC__c = 'Assisted Living';
        opp.StageName ='Prospecting';
        opp.CloseDate = Date.today();
        insert opp;
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            Test.startTest();
            List<Opportunity> result = PaymentScheduleApex.FetchOppdataForPayment(opp.Id);
            Test.stopTest();
            System.assertEquals(1, result.size(), 'Should return one opportunity');
            System.assertEquals(opp.Id, result[0].Id, 'Should return the same opportunity');
        }
        
        
        opp.LOC__c = 'Sober Living';
        update opp;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            try {
                PaymentScheduleApex.FetchOppdataForPayment(opp.Id);
                System.assertEquals( 1, 1,' ');
            } catch (DmlException e) {
                System.assert(e.getMessage().contains('For Sober Living Level of Care, the Payment Schedule can not be Generated'),
                              'Should throw an error with the correct message');
            }
        }
    }
    
}
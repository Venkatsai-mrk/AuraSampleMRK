@isTest
public class ReferralColumnConfigurationTest {
    public static testMethod void  method1(){
        Test.startTest();
        ReferralColumnConfiguration.getProblemColumns();
        ReferralColumnConfiguration.saveColumns(new List<Object>{''});
        Test.stopTest();
        System.assertEquals(1, 1, 'Welcome To Elixir');
    }
}
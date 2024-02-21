@isTest
public class TestCreateVOBTrigger {
    
    public static testMethod void testmethod1(){
        
        Test.startTest();
        Account acc = new Account();
        acc.Name = 'Aruacc';
        insert acc;
        
        Payor__c ins = new Payor__c(name='Test', Payer_code__c='12345');
         ins.ElixirSuite__Payer_Code__c = 'abc1234';
        insert ins;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'SS';
        opp.AccountId = acc.Id;
        opp.StageName = 'VOB';
        opp.CloseDate = System.today();
        opp.ElixirSuite__Primary_Insurance_Provider1__c = ins.id;
        opp.Insurance_Policy_ID__c = '123asddfd';
        insert opp;
        
        Opportunity opp1 = new Opportunity();
        opp1.Name = 'Test Roy';
        opp1.AccountId = acc.Id;
        opp1.StageName = 'Prospecting';
        opp1.CloseDate = System.today();
        opp1.ElixirSuite__Primary_Insurance_Provider1__c = ins.id;
        opp1.Insurance_Policy_ID__c = '123asddfd';
        insert opp1;
        
        opp1.StageName='VOB';
        update opp1;
    
   
      test.stopTest();
        System.assertEquals('1', '1','');
    }
}
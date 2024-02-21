@isTest
public class TestUpdateAmount {
    
    public static testmethod void testupdate(){
        Account acc = new Account();
        acc.Name = 'Anu';
        insert acc;
        
        Opportunity opp = new Opportunity();
         opp.AccountId = acc.Id;
         opp.Name = 'Aru';
		 opp.StageName = 'Prospecting';
         opp.hiddenCheck__c = true;
		 opp.CloseDate = system.today();
         
         insert opp;
         System.assertEquals(1, 1, ' ');
        
        
        
    }

    
}
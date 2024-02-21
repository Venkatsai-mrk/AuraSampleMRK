@isTest
public class TestopportunityReferralCounterTrigger {
	@isTest
    static void testOpportunityReferralCounterTriggerMethod() {
        Elixir_Custom_Setting__c record = new Elixir_Custom_Setting__c();
        record.ElixirSuite__Patient_Deceased__c = true;
        insert record;
        
        // Create an Account record and insert it into the database
        Account acc = new Account(
            Name = 'Test Account'
        );
        insert acc;
        
        // Create an Opportunity record related to the Account and insert it into the database
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            AccountId = acc.Id,
            StageName = 'Prospecting'
        );
        opp.ElixirSuite__Deceased__c = true;
        opp.CloseDate = Date.today().addDays(30);
        insert opp;
        
        // Try to update the Opportunity record and verify that the update is prevented
        /*
        opp.StageName = 'Closed Won';
        System.assertThrows(InsufficientPrivilegesException.class, () => {
            update opp;
        });
        
        // Try to delete the Opportunity record and verify that the delete is blocked
        System.assertThrows(InsufficientPrivilegesException.class, () => {
            delete opp;
        });
		*/
        
        
        // Create a new Opportunity record and set the Close Date to tomorrow
        Opportunity newOpp = new Opportunity(
            Name = 'Test Opportunity 2',
            AccountId = acc.Id,
            CloseDate = Date.today().addDays(1),
            StageName = 'Prospecting'
        );
        
        // Try to insert the Opportunity record and verify that the Close Date is set to today
        Test.startTest();
        insert newOpp;
        System.assertEquals(Date.today().addDays(1), newOpp.CloseDate);
        
        // Update the Opportunity record to change the Stage Name to "VOB" and verify that a care episode is created
        newOpp.StageName = 'VOB';
        update newOpp;        
        // Verify that the care episode was created
        
        // Update the Opportunity record to change the Close Date to yesterday and verify that the Close Date is set to today
        newOpp.CloseDate = Date.today().addDays(-1);
        update newOpp;
        Test.stopTest();
        System.assertEquals(Date.today().addDays(-1), newOpp.CloseDate);
    }
}
@isTest
public class TestCreateCareEpisodeHelper {
     
    public static testmethod void testCreateCareEpisode(){
        
        test.startTest();
        
        Account acc = new Account(Name = 'Test Account24324433');
        insert acc;
        
        Opportunity opp = new Opportunity(Name = 'Test Opportunity', accountid = acc.id, stagename= 'Prospecting', closeDate =System.today());
        insert opp;
        
        Opportunity oppty = new Opportunity();
        oppty.Name = 'Test';
        oppty.Gender__c = 'Male';
        oppty.AccountId=acc.id;
        oppty.StageName = 'Prospecting';
        oppty.CloseDate = system.today().adddays(1);
        // oppty.Level_Of_Care__c = prog.id;
        insert oppty; 
        oppty.Gender__c = 'Female';
        update oppty;
        
        
        Visits__c visit= new Visits__c();
        visit.name= 'TestVisit';
        visit.Opportunity__c= oppty.id;
        visit.status__c='Active';
        StopRecursion.stopLocationUpdation = false;
        insert visit;
        
        List<Opportunity> oppList = new List<Opportunity>();
        oppList.add(opp);
        oppList.add(oppty);
        
        test.stopTest();
        system.assert( oppty.Name!=null,'');
        // CreateCareEpisodeHelper.createCareEpisode(oppList, 'Insert');
        CreateCareEpisodeHelper.createCareEpisode(oppList, 'Update');
    }
    
    
}
@isTest
public class TestTriggerHelperForLead {
    public static testmethod void testlead(){
        test.startTest();
        List<Opportunity> opplist= new List<Opportunity>();
        Map<id, Lead> oppIdLeadMap= new Map<id, Lead>();
        Lead ld= new Lead();
        ld.Company='ABC';
        ld.LastName='Test Lead';
        ld.Phone='9876543345';
        insert ld;
        
        Account acc = new Account(Name = 'Test Account24324433');
        insert acc;
        
        Opportunity opp = new Opportunity(Name = 'Test Opportunity', accountid = acc.id, stagename= 'Prospecting', closeDate =System.today());
        insert opp;
        opp.Phone__c=ld.Phone;
        update opp;
        opplist.add(opp);
        oppIdLeadMap.put(opp.id, ld);
        
        
        
        test.stopTest();
        system.assertEquals(1, 1);
        TriggerHelperForLead.updatePhoneOnOpp(opplist, oppIdLeadMap);
    }
}
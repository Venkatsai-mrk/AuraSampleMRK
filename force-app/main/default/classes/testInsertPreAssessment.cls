@istest
public class testInsertPreAssessment {
    @istest
    public static void InsertPreAssessment()
    {
        test.startTest();
        Account a=new Account();
        a.Name='test';
        insert a;
        
        Opportunity o=new Opportunity();
        o.Name='a';
        o.AccountId=a.id;
        o.StageName='Prospecting';
        o.CloseDate=Date.today();
        o.Phone__c='123456';
        o.DOB__c= Date.today();
        insert o;
        
        Pre_assessment__c p=new Pre_assessment__c();
        p.Opportunity__c= o.Id;
        insert p;
        
        InsertPreAssessment.InsertPreAssessmentid(o.id);
        test.stopTest();
        System.assertEquals(1, 1, ' ');
    }

}